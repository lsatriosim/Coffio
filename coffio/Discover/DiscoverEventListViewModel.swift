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
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    let authService: AuthenticationService = AuthenticationService.shared
    
    func onViewDidLoad() {
        Task {
            updateIsLoading(isLoading: true)
            try await fetchEvent()
            updateIsLoading(isLoading: false)
        }
    }
    
    func registerEvent(eventId: String, fullname: String, phoneNumber: String, paymentProofImage: Image, completion: @escaping () -> Void) {
        isLoading = true
        guard let user = authService.user
        else {
            authService.showLoginPage()
            return
        }
        
        Task {
            do {
                _ = try await fetcher.uploadPaymentProof(
                    image: paymentProofImage,
                    eventId: eventId,
                    userId: user.id
                )
                
                let eventRegistrationRequest: EventRegistrationRequest = EventRegistrationRequest(
                    id: UUID().uuidString,
                    eventId: eventId,
                    userId: user.id,
                    userPhone: phoneNumber,
                    userName: fullname
                )
                
                try await fetcher.registerEvent(request: eventRegistrationRequest)
                isLoading = false
                completion()
            }
            catch {
                isLoading = false
                isError = true
                errorMessage = "Server Error! Please try again"
            }
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
