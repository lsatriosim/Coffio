//
//  DiscoverInternalGuestRegistrationViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 30/08/26.
//


import Foundation
import SwiftUI

protocol DiscoverInternalGuestRegistrationViewModelDelegate: AnyObject {
    func notifyRegistrationSuccess()
}

@MainActor
final class DiscoverInternalGuestRegistrationViewModel: ObservableObject {
    @Published var guestName: String = ""
    @Published var guestEmail: String = ""
    @Published var guestPhone: String = ""
    @Published var note: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let eventId: String
    private let existingGuest: DiscoverInternalGuestItem?
    private let fetcher = EventFetcher()
    private weak var parentViewModel: DiscoverDetailEventViewModel?
    private weak var delegate: DiscoverInternalGuestRegistrationViewModelDelegate?
    private let authService: AuthenticationService = .shared
    
    init(eventId: String, guestToEdit: DiscoverInternalGuestItem? = nil, delegate: DiscoverInternalGuestRegistrationViewModelDelegate?) {
        self.eventId = eventId
        self.existingGuest = guestToEdit
        self.delegate = delegate
        
        if let guest = guestToEdit {
            self.guestName = guest.guestName
            self.guestEmail = guest.guestEmail ?? ""
            self.guestPhone = guest.guestPhone ?? ""
            self.note = guest.notes ?? ""
        }
    }
    
    var isEditing: Bool {
        existingGuest != nil
    }
    
    var isFormValid: Bool {
        !guestName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !guestEmail.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    @discardableResult
    func saveInternalGuest() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        guard let user = authService.user else {
            isLoading = false
            return false
        }
        
        do {
            let request = DiscoverInternalGuestRequest(
                id: existingGuest?.id ?? UUID().uuidString,
                eventId: eventId,
                guestName: guestName,
                guestEmail: guestEmail.isEmpty ? nil : guestEmail,
                guestPhone: guestPhone.isEmpty ? nil : guestPhone,
                notes: note.isEmpty ? nil : note,
                addedBy: user.id
            )

            if isEditing {
                try await fetcher.updateInternalGuest(request: request)
            } else {
                try await fetcher.createInternalGuest(request: request)
            }
            
            isLoading = false
            
            delegate?.notifyRegistrationSuccess()
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
