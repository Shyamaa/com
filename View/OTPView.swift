//
//  OTPView.swift
//  Ecom
//
//  Created by MMI Softwares Pvt Ltd on 14/06/25.
//

import SwiftUI

struct OTPView: View {
    @StateObject var otpViewModel = OTPViewModel()
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("OTP Verification")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Enter the 4-digit code sent to your device")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // OTP Input Field
            VStack(alignment: .leading, spacing: 10) {
                Text("Enter OTP")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("0000", text: $otpViewModel.otpCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(otpViewModel.isOTPValid ? Color.green : Color.clear, lineWidth: 1)
                    )
                    .accessibilityLabel("OTP verification code field")
                    .onChange(of: otpViewModel.otpCode) { newValue in
                        // Limit to 4 digits
                        if newValue.count > 4 {
                            otpViewModel.otpCode = String(newValue.prefix(4))
                        }
                    }
                
                if !otpViewModel.otpCode.isEmpty && !otpViewModel.isOTPValid {
                    Text("Please enter a valid 4-digit OTP")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 20)
            
            // Verify Button
            Button(action: {
                otpViewModel.verifyOTP()
            }) {
                HStack {
                    if otpViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Verify OTP")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    otpViewModel.isOTPValid ? Color.green : Color.gray
                )
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(otpViewModel.isLoading || !otpViewModel.isOTPValid)
            .padding(.horizontal, 20)
            
            // Error Message
            if !otpViewModel.errorMessage.isEmpty {
                Text(otpViewModel.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Success Navigation
            if otpViewModel.isOTPSuccessful {
                NavigationLink(destination: HomeView()) {
                    HStack {
                        Text("Continue to Home")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                }
            }
            
            // Resend OTP Button
            Button(action: {
                // TODO: Implement resend OTP functionality
                print("Resend OTP tapped")
            }) {
                Text("Resend OTP")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .navigationTitle("OTP Verification")
        .navigationBarTitleDisplayMode(.inline)
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
        OTPView()
    }
}
