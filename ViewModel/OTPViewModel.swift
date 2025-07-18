//
//  OTPViewModel.swift
//  Ecom
//
//  Created by MMI Softwares Pvt Ltd on 14/06/25.
//

import Foundation
import Combine

class OTPViewModel: ObservableObject {
    @Published var otpCode = ""
    @Published var isOTPSuccessful = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var isOTPValid = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        $otpCode
            .map { otp in
                return otp.count == 4 && otp.allSatisfy { $0.isNumber }
            }
            .assign(to: \.isOTPValid, on: self)
            .store(in: &cancellables)
    }
    
    func verifyOTP() {
        guard isOTPValid else {
            errorMessage = "Please enter a valid 4-digit OTP"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        AuthService.shared.verifyOTP(otp: otpCode)
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
            }, receiveValue: { [weak self] success in
                DispatchQueue.main.async {
                    self?.isOTPSuccessful = success
                }
            })
            .store(in: &cancellables)
    }
    
    func clearError() {
        errorMessage = ""
    }
    
    func resetForm() {
        otpCode = ""
        errorMessage = ""
        isOTPSuccessful = false
    }
}
