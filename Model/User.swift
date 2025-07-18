//
//  User.swift
//  Ecom
//
//  Created by MMI Softwares Pvt Ltd on 14/06/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let phoneNumber: String?
    let isVerified: Bool
    let createdAt: Date
    
    init(username: String, email: String, phoneNumber: String? = nil) {
        self.id = UUID().uuidString
        self.username = username
        self.email = email
        self.phoneNumber = phoneNumber
        self.isVerified = false
        self.createdAt = Date()
    }
    
    // Convenience initializer for Firebase Auth
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.username = firebaseUser.displayName ?? firebaseUser.email ?? ""
        self.email = firebaseUser.email ?? ""
        self.phoneNumber = firebaseUser.phoneNumber
        self.isVerified = firebaseUser.isEmailVerified
        self.createdAt = firebaseUser.metadata.creationDate ?? Date()
    }
}
