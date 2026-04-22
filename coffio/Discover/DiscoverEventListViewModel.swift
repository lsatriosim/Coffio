//
//  DiscoverEventListViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import Foundation
import SwiftUI

@MainActor
final class DiscoverEventListViewModel: ObservableObject {
    @Published var events: [DiscoverEventItem] = []
    @Published var isLoading: Bool = false
    let authService: AuthenticationService = AuthenticationService.shared
    
    func onViewDidLoad() {
        Task {
            updateIsLoading(isLoading: true)
            try await fetchEvent()
            updateIsLoading(isLoading: false)
        }
    }
    
    func registerEvent(eventId: String, fullname: String, phoneNumber: String, completion: @escaping () -> Void) {
        guard let user = authService.user
        else {
            authService.showLoginPage()
            return
        }
        
        let eventRegistrationRequest: EventRegistrationRequest = EventRegistrationRequest(
            id: UUID().uuidString,
            eventId: eventId,
            userId: user.id,
            userPhone: phoneNumber,
            userName: fullname
        )
        
        Task {
            do {
                try await fetcher.registerEvent(request: eventRegistrationRequest)
            }
            catch {
                
            }
            completion()
        }
    }
    
    private let fetcher: EventFetcher = EventFetcher()
}

private extension DiscoverEventListViewModel {
    func fetchEvent() async throws {
        let response = try await fetcher.fetchEvent()
        updateEvents(events: response)
    }
}

private extension DiscoverEventListViewModel {
    @MainActor func updateEvents(events: [DiscoverEventItem]) {
        self.events = events
    }
    
    @MainActor
    func updateIsLoading(isLoading: Bool) {
        self.isLoading = isLoading
    }
}
