//
//  EditProfileViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 28/04/26.
//


import Foundation

@MainActor
final class EditProfileViewModel: ObservableObject {
    private let authService = AuthenticationService.shared
    
    @Published var fullName: String = ""
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    
    init() {
        if let user = authService.user {
            self.fullName = user.fullName
            self.username = user.username
            self.email = user.email
        }
    }
    
    func saveProfile(completion: @escaping () -> Void) {
        guard !fullName.isEmpty else { return }
        isLoading = true
        
        Task {
            do {
                try await authService.updateProfile(fullName: fullName)
                isLoading = false
                completion()
            } catch {
                isLoading = false
                print("Update failed: \(error)")
            }
        }
    }
}