//
//  HomeView.swift
//  Ecom
//
//  Created by MMI Softwares Pvt Ltd on 14/06/25.
//

import SwiftUI
import Combine

struct HomeView: View {
    @State private var currentUser: User?
    @State private var showingLogoutAlert = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Welcome Header
                VStack(spacing: 15) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Welcome!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let user = currentUser {
                        Text("Hello, \(user.username)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    } else {
                        Text("You have successfully logged in")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)
                
                // User Info Card
                if let user = currentUser {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                            Text("User Information")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                        
                        InfoRow(icon: "envelope", title: "Email", value: user.email)
                        InfoRow(icon: "person", title: "Username", value: user.username)
                        InfoRow(icon: "checkmark.shield", title: "Verified", value: user.isVerified ? "Yes" : "No")
                        
                        if let phoneNumber = user.phoneNumber {
                            InfoRow(icon: "phone", title: "Phone", value: phoneNumber)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        // TODO: Navigate to product catalog
                        print("Browse Products tapped")
                    }) {
                        HStack {
                            Image(systemName: "bag.fill")
                            Text("Browse Products")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // TODO: Navigate to user profile
                        print("View Profile tapped")
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("View Profile")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    logout()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
        .onAppear {
            loadCurrentUser()
        }
    }
    
    private func loadCurrentUser() {
        currentUser = AuthService.shared.getCurrentUser()
    }
    
    private func logout() {
        isLoading = true
        
        AuthService.shared.signOut()
            .sink(receiveCompletion: { completion in
                isLoading = false
                switch completion {
                case .failure(let error):
                    print("Logout error: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { _ in
                // Navigate back to login
                // This would typically be handled by a navigation coordinator
                print("Successfully logged out")
            })
            .store(in: &Set<AnyCancellable>())
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    HomeView()
}
