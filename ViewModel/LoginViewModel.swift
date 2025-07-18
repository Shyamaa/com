//
//  LoginViewModel.swift
//  Ecom
//
//  Created by MMI Softwares Pvt Ltd on 14/06/25.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var isEmailValid = false
    @Published var isPasswordValid = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
        checkLoginState()
    }
    
    private func setupValidation() {
        // Validate email format
        $username
            .map { email in
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                return emailPredicate.evaluate(with: email)
            }
            .assign(to: \.isEmailValid, on: self)
            .store(in: &cancellables)
        
        // Validate password length
        $password
            .map { password in
                return password.count >= 6
            }
            .assign(to: \.isPasswordValid, on: self)
            .store(in: &cancellables)
    }

    func authenticate() {
        guard isEmailValid && isPasswordValid else {
            errorMessage = "Please enter a valid email and password (minimum 6 characters)"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        AuthService.shared.authenticate(username: username, password: password)
            .sink(receiveCompletion: { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    case .finished:
                        break
                    }
                }
            }, receiveValue: { [weak self] user in
                DispatchQueue.main.async {
                    self?.isAuthenticated = true
                    if KeychainService.shared.saveToken(user.id) {
                        print("Token saved successfully")
                    } else {
                        print("Failed to save token")
                    }
                }
            })
            .store(in: &cancellables)
    }

    func checkLoginState() {
        if KeychainService.shared.isTokenValid() {
            self.isAuthenticated = true
        }
    }
    
    func clearError() {
        errorMessage = ""
    }
    
    func resetForm() {
        username = ""
        password = ""
        errorMessage = ""
        isAuthenticated = false
    }
}

