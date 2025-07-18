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
        }
    }
}

class AuthService {
    static let shared = AuthService()
    
    private init() {}

    // MARK: - Authenticate User
    func authenticate(username: String, password: String) -> AnyPublisher<User, Error> {
        guard !username.isEmpty, !password.isEmpty else {
            return Fail(error: AuthError.invalidCredentials)
                .eraseToAnyPublisher()
        }
        
        return Future { promise in
            Auth.auth().signIn(withEmail: username, password: password) { authResult, error in
                if let error = error {
                    let authError = self.mapFirebaseError(error)
                    promise(.failure(authError))
                    return
                }
                
                if let user = authResult?.user {
                    let userModel = User(firebaseUser: user)
                    promise(.success(userModel))
                } else {
                    promise(.failure(AuthError.userNotFound))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Send OTP to User
    func sendOTP(to phoneNumber: String) -> AnyPublisher<String, Error> {
        guard !phoneNumber.isEmpty else {
            return Fail(error: AuthError.invalidCredentials)
                .eraseToAnyPublisher()
        }
        
        // TODO: Implement actual Firebase Phone Authentication
        // For now, using simulation for development
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Simulate network delay
                let otp = String(format: "%04d", Int.random(in: 1000...9999))
                print("DEBUG: Generated OTP: \(otp) for \(phoneNumber)")
                promise(.success(otp))
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
        
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Simulate verification delay
                if otp == expectedOTP {
                    promise(.success(true))
                } else {
                    promise(.failure(AuthError.invalidOTP))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Sign Out
    func signOut() -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try Auth.auth().signOut()
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
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return User(firebaseUser: firebaseUser)
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
        default:
            return .unknownError
        }
    }
}
