//
//  LoginView.swift
//  Ecom
//
//  Created by MMI Softwares Pvt Ltd on 14/06/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject var loginViewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Sign in to your account")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // Form Fields
            VStack(spacing: 15) {
                // Email Field
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter your email", text: $loginViewModel.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(loginViewModel.isEmailValid ? Color.green : Color.clear, lineWidth: 1)
                        )
                        .accessibilityLabel("Email address field")
                    
                    if !loginViewModel.username.isEmpty && !loginViewModel.isEmailValid {
                        Text("Please enter a valid email address")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 5) {
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    SecureField("Enter your password", text: $loginViewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(loginViewModel.isPasswordValid ? Color.green : Color.clear, lineWidth: 1)
                        )
                        .accessibilityLabel("Password field")
                    
                    if !loginViewModel.password.isEmpty && !loginViewModel.isPasswordValid {
                        Text("Password must be at least 6 characters")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Login Button
            Button(action: {
                loginViewModel.authenticate()
            }) {
                HStack {
                    if loginViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Sign In")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    loginViewModel.isEmailValid && loginViewModel.isPasswordValid ? Color.blue : Color.gray
                )
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(loginViewModel.isLoading || !loginViewModel.isEmailValid || !loginViewModel.isPasswordValid)
            .padding(.horizontal, 20)
            
            // Error Message
            if !loginViewModel.errorMessage.isEmpty {
                Text(loginViewModel.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Navigation to OTP
            if loginViewModel.isAuthenticated {
                NavigationLink(destination: OTPView()) {
                    HStack {
                        Text("Continue to OTP Verification")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                }
            }
            
            Spacer()
        }
        .navigationTitle("Login")
        .navigationBarHidden(true)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    NavigationView {
        LoginView()
    }
}
