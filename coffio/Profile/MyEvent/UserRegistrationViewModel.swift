//
//  UserRegistrationViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/05/26.
//

import SwiftUI

@MainActor
final class UserRegistrationViewModel: ObservableObject {
    @Published var registrations: [EventRegistrationItem] = []
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    
    private let fetcher = EventFetcher()
    private let authService = AuthenticationService.shared
    
    func onViewDidLoad() {
        Task {
            await fetchRegistrations()
        }
    }
    
    func fetchRegistrations() async {
        guard let user = authService.user else {
            self.errorMessage = "Please login to see your registrations"
            self.isError = true
            return
        }
        
        isLoading = true
        do {
            let items = try await fetcher.fetchUserRegistrations(userId: user.id)
            self.registrations = items
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.isError = true
            self.errorMessage = "Failed to load registrations"
            print("Error: \(error)")
        }
    }
}
