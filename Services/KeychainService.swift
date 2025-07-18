//
//  KeychainService.swift
//  Ecom
//
//  Created by MMI Softwares Pvt Ltd on 14/06/25.
//

import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private let serviceIdentifier = "com.mmi.ecom.auth"
    private let accountIdentifier = "authToken"

    func saveToken(_ token: String) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: accountIdentifier,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Check if item already exists
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: serviceIdentifier,
                kSecAttrAccount as String: accountIdentifier
            ]
            
            let attributes: [String: Any] = [
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            
            return SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary) == errSecSuccess
        }
        
        return status == errSecSuccess
    }

    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: accountIdentifier,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, 
              let data = item as? Data, 
              let token = String(data: data, encoding: .utf8) else { 
            return nil 
        }
        return token
    }

    func deleteToken() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: accountIdentifier
        ]
        
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
    
    func isTokenValid() -> Bool {
        guard let token = getToken() else { return false }
        return !token.isEmpty
    }
}
