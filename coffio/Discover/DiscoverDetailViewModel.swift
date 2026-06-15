//
//  DiscoverDetailViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/05/26.
//

import SwiftUI

@MainActor
final class DiscoverDetailEventViewModel: ObservableObject {
    @Published var event: DiscoverEventItem?
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isAlreadyRegistered: Bool = false
    @Published var isAuthor: Bool = false
    @Published var isEditEventSheetPresented: Bool = false
    @Published var selectedImageData: Data? = nil
    
    private let fetcher = EventFetcher()
    let authService: AuthenticationService = .shared
    let eventId: String
    
    init(eventId: String, initialEvent: DiscoverEventItem? = nil) {
        self.eventId = eventId
        self.event = initialEvent
    }
    
    func fetchEventDetails() async {
        // If we already have the event, we can skip loading state for a smoother transition
        if event == nil { isLoading = true }
        
        do {
            let fetchedEvent = try await fetcher.fetchEventById(id: eventId)
            self.event = fetchedEvent
            await checkAuthor()
            await checkRegistrationStatus()
            self.isLoading = false
        } catch {
            print("Error fetching event: \(error)")
            self.isError = true
            self.isLoading = false
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
                guard let selectedImageData else { return}
                _ = try await fetcher.uploadPaymentProof(
                    image: selectedImageData,
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
                isAlreadyRegistered = true
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
    
    @MainActor
    func checkRegistrationStatus() async {
        guard let userId = authService.user?.id else { return }
        
        do {
            let registered = try await fetcher.isUserRegistered(
                eventId: self.eventId,
                userId: userId
            )
            self.isAlreadyRegistered = registered
        } catch {
            print("Error checking registration: \(error)")
        }
    }
    
    @MainActor
    func checkAuthor() async {
        guard let userId = authService.user?.id else { return }
        self.isAuthor = event?.createdBy == userId
    }
}
