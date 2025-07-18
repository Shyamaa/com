//
//  FirebaseManager.swift
//  Ecom
//
//  Created by MMI Softwares Pvt Ltd on 14/06/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseAnalytics

class FirebaseManager {
    static let shared = FirebaseManager()
    
    // Firebase services
    let auth: Auth
    let firestore: Firestore
    let storage: Storage
    let analytics: Analytics
    
    private init() {
        // Configure Firebase if not already configured
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Initialize Firebase services
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.storage = Storage.storage()
        self.analytics = Analytics.analytics()
        
        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        firestore.settings = settings
        
        print("Firebase Manager initialized successfully")
    }
    
    // MARK: - Authentication Methods
    
    func signIn(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        let user = User(firebaseUser: result.user)
        
        // Log analytics event
        Analytics.logEvent("login", parameters: [
            AnalyticsParameterMethod: "email"
        ])
        
        return user
    }
    
    func signUp(email: String, password: String, username: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        
        // Update user profile
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = username
        try await changeRequest.commitChanges()
        
        let user = User(firebaseUser: result.user)
        
        // Save user data to Firestore
        try await saveUserToFirestore(user)
        
        // Log analytics event
        Analytics.logEvent("sign_up", parameters: [
            AnalyticsParameterMethod: "email"
        ])
        
        return user
    }
    
    func signOut() throws {
        try auth.signOut()
        
        // Log analytics event
        Analytics.logEvent("logout", parameters: nil)
    }
    
    func getCurrentUser() -> User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        return User(firebaseUser: firebaseUser)
    }
    
    // MARK: - Firestore Methods
    
    private func saveUserToFirestore(_ user: User) async throws {
        let userData: [String: Any] = [
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "phoneNumber": user.phoneNumber ?? "",
            "isVerified": user.isVerified,
            "createdAt": user.createdAt,
            "lastLoginAt": Date()
        ]
        
        try await firestore.collection("users").document(user.id).setData(userData)
    }
    
    func updateUserProfile(_ user: User) async throws {
        let userData: [String: Any] = [
            "username": user.username,
            "phoneNumber": user.phoneNumber ?? "",
            "isVerified": user.isVerified,
            "updatedAt": Date()
        ]
        
        try await firestore.collection("users").document(user.id).updateData(userData)
    }
    
    func getUserProfile(userId: String) async throws -> User? {
        let document = try await firestore.collection("users").document(userId).getDocument()
        
        guard let data = document.data() else { return nil }
        
        return User(
            id: data["id"] as? String ?? "",
            username: data["username"] as? String ?? "",
            email: data["email"] as? String ?? "",
            phoneNumber: data["phoneNumber"] as? String,
            isVerified: data["isVerified"] as? Bool ?? false,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    // MARK: - Storage Methods
    
    func uploadProfileImage(userId: String, imageData: Data) async throws -> String {
        let storageRef = storage.reference().child("profile_images/\(userId).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        return downloadURL.absoluteString
    }
    
    // MARK: - Analytics Methods
    
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
    
    // MARK: - Phone Authentication
    
    func sendPhoneVerificationCode(phoneNumber: String) async throws -> String {
        // This would integrate with Firebase Phone Auth
        // For now, returning a mock verification ID
        return "mock_verification_id"
    }
    
    func verifyPhoneCode(verificationID: String, code: String) async throws -> Bool {
        // This would verify the phone code with Firebase
        // For now, returning true for demo purposes
        return code == "1234"
    }
    
    // MARK: - Error Handling
    
    enum FirebaseError: LocalizedError {
        case userNotFound
        case invalidCredentials
        case networkError
        case unknownError
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "User not found"
            case .invalidCredentials:
                return "Invalid credentials"
            case .networkError:
                return "Network error occurred"
            case .unknownError:
                return "An unknown error occurred"
            }
        }
    }
} 