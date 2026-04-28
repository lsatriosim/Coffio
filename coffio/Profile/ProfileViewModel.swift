//
//  ProfileViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 08/04/26.
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    let authenticationService: AuthenticationService = .shared
    private var cancellables = Set<AnyCancellable>()
    @Published var showEditProfile: Bool = false
    
    @Published var initialName: String = ""
    @Published var imageUrl: String? = nil
    @Published var email: String = ""
    @Published var fullName: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    
    @Published var isLogoutLoading: Bool = false
    
    init() {
        setupUserObserver()
    }
    
    func onViewDidLoad() {
        if let user = authenticationService.user {
            imageUrl = user.avatarUrl
            initialName = "\(String(user.fullName.prefix(1)).uppercased())"
            fullName = user.fullName
            email = user.email
            isLoggedIn = true
        }
        else {
            isLoggedIn = false
        }
    }
    
    func onLogoutButtonDidTap(completion: @escaping () -> Void) {
        isLogoutLoading = true
        Task {
            do {
                try await authenticationService.logout()
                isLogoutLoading = false
                completion()
            }
            catch {
                isLogoutLoading = false
                print(error)
            }
        }
    }
}

private extension ProfileViewModel {
    private func setupUserObserver() {
        authenticationService.$user
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                self?.updateUI(with: user)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with user: ProfileUser?) {
        if let user = user {
            self.imageUrl = user.avatarUrl
            self.initialName = String(user.fullName.prefix(1)).uppercased()
            self.fullName = user.fullName
            self.email = user.email
            self.isLoggedIn = true
        } else {
            self.isLoggedIn = false
            self.initialName = ""
            self.fullName = ""
            self.email = ""
            self.imageUrl = nil
        }
    }
}
