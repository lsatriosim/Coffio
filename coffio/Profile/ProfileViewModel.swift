//
//  ProfileViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 08/04/26.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    let authenticationService: AuthenticationService = .shared
    @Published var showEditProfile: Bool = false
    
    @Published var initialName: String = ""
    @Published var imageUrl: String? = nil
    @Published var email: String = ""
    @Published var fullName: String = ""
    
    func onViewDidLoad() {
        if let user = authenticationService.user {
            imageUrl = user.avatarUrl
            initialName = "\(String(user.fullName.prefix(1)).uppercased())"
            fullName = user.fullName
            email = user.email
        }
        else {
            authenticationService.showLoginPage()
        }
    }
    
    func onLogoutButtonDidTap() {
        Task {
            do {
                try await authenticationService.logout()
            }
            catch {
                print(error)
            }
        }
    }
}
