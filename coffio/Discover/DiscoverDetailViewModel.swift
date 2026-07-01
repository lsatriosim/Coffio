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
    @Published var isAuthor: Bool = false
    @Published var registerStatus: EventRegistrationStatus? = nil
    @Published var registerId: String? = nil
    @Published var registerPaymentDeadlineTime: Date? = nil
    @Published var isEditEventSheetPresented: Bool = false
    @Published var selectedImageData: Data? = nil
    
    var isAlreadyRegistered: Bool {
        if let registerStatus {
            switch registerStatus {
            case .approved, .paymentSubmitted , .awaitingPayment, .rejected:
                return true
            default:
                return false
            }
        }
        else {
            return false
        }
    }
    
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
    
    func createAwaitingPaymentSlot(
            id: String,
            eventId: String,
            fullname: String,
            phoneNumber: String,
            notes: String,
            deadline: Date
    ) async throws {
        guard let user = authService.user else {
            authService.showLoginPage()
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User session not active"])
        }
        
        // Match your updated EventRegistrationItem model schema fields
        let eventRegistrationRequest = EventRegistrationRequest(
            id: id,
            eventId: eventId,
            userId: user.id,
            userPhone: phoneNumber,
            userName: fullname,
            notes: notes,
            paymentDeadline: deadline
        )
        
        try await fetcher.registerEvent(request: eventRegistrationRequest)
        
        await checkRegistrationStatus()
    }
    
    @MainActor
    func checkRegistrationStatus() async {
        guard let userId = authService.user?.id else { return }
        
        do {
            if let registration = try await fetcher.fetchUserRegistration(eventId: self.eventId, userId: userId) {
                self.registerStatus = registration.status
                self.registerId = registration.id
                self.registerPaymentDeadlineTime = registration.paymentDeadlineTime
            } else {
                self.registerStatus = nil
                self.registerId = nil
                self.registerPaymentDeadlineTime = nil
            }
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
