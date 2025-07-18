//
//  AuthService.swift
//  Ecom
//
//  Created by MMI Softwares Pvt Ltd on 14/06/25.
//

import Foundation
import FirebaseAuth
import Combine

enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case userNotFound
    case invalidOTP
    case unknownError
    case signUpFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network error. Please check your connection"
        case .userNotFound:
            return "User not found"
        case .invalidOTP:
            return "Invalid OTP code"
        case .unknownError:
            return "An unknown error occurred"
        case .signUpFailed:
            return "Failed to create account"
        }
    }
}

class AuthService {
    static let shared = AuthService()
    
    private let firebaseManager = FirebaseManager.shared
    private init() {}

    // MARK: - Authenticate User (Async/Await)
    func authenticateAsync(username: String, password: String) async throws -> User {
        guard !username.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        do {
            return try await firebaseManager.signIn(email: username, password: password)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Authenticate User (Combine - for backward compatibility)
    func authenticate(username: String, password: String) -> AnyPublisher<User, Error> {
        guard !username.isEmpty, !password.isEmpty else {
            return Fail(error: AuthError.invalidCredentials)
                .eraseToAnyPublisher()
        }
        
        return Future { [weak self] promise in
            Task {
                do {
                    let user = try await self?.firebaseManager.signIn(email: username, password: password)
                    promise(.success(user!))
                } catch {
                    promise(.failure(self?.mapFirebaseError(error) ?? AuthError.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Sign Up User
    func signUp(email: String, password: String, username: String) async throws -> User {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        do {
            return try await firebaseManager.signUp(email: email, password: password, username: username)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Send OTP to User
    func sendOTP(to phoneNumber: String) -> AnyPublisher<String, Error> {
        guard !phoneNumber.isEmpty else {
            return Fail(error: AuthError.invalidCredentials)
                .eraseToAnyPublisher()
        }
        
        return Future { [weak self] promise in
            Task {
                do {
                    let verificationID = try await self?.firebaseManager.sendPhoneVerificationCode(phoneNumber: phoneNumber)
                    promise(.success(verificationID ?? "mock_verification_id"))
                } catch {
                    promise(.failure(AuthError.networkError))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Verify OTP
    func verifyOTP(otp: String, expectedOTP: String = "1234") -> AnyPublisher<Bool, Error> {
        guard !otp.isEmpty else {
            return Fail(error: AuthError.invalidOTP)
                .eraseToAnyPublisher()
        }
        
        return Future { [weak self] promise in
            Task {
                do {
                    let success = try await self?.firebaseManager.verifyPhoneCode(verificationID: "mock_verification_id", code: otp)
                    promise(.success(success ?? false))
                } catch {
                    promise(.failure(AuthError.invalidOTP))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Sign Out
    func signOut() -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            do {
                try self?.firebaseManager.signOut()
                KeychainService.shared.deleteToken()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Check Current User
    func getCurrentUser() -> User? {
        return firebaseManager.getCurrentUser()
    }
    
    // MARK: - Update User Profile
    func updateUserProfile(_ user: User) async throws {
        try await firebaseManager.updateUserProfile(user)
    }
    
    // MARK: - Get User Profile from Firestore
    func getUserProfile(userId: String) async throws -> User? {
        return try await firebaseManager.getUserProfile(userId: userId)
    }
    
    // MARK: - Upload Profile Image
    func uploadProfileImage(userId: String, imageData: Data) async throws -> String {
        return try await firebaseManager.uploadProfileImage(userId: userId, imageData: imageData)
    }
    
    // MARK: - Analytics
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        firebaseManager.logEvent(name, parameters: parameters)
    }
    
    func setUserProperty(_ value: String?, forName name: String) {
        firebaseManager.setUserProperty(value, forName: name)
    }
    
    // MARK: - Private Methods
    private func mapFirebaseError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue,
             AuthErrorCode.invalidEmail.rawValue,
             AuthErrorCode.userNotFound.rawValue:
            return .invalidCredentials
        case AuthErrorCode.networkError.rawValue:
            return .networkError
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .signUpFailed
        default:
            return .unknownError
        }
    }
}
