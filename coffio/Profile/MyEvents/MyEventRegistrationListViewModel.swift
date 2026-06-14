//
//  MyEventRegistrationListViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//

import SwiftUI

@MainActor
final class MyEventRegistrationListViewModel: ObservableObject {
    @Published var registrations: [EventRegistrationItem] = []
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    
    // Tracks ongoing localized registration state updates: [RegistrationID: LoadingState]
    @Published var processingIds: [String: Bool] = [:]
    
    private let fetcher = EventFetcher()
    let eventId: String
    
    init(eventId: String) {
        self.eventId = eventId
    }
    
    func onViewDidLoad() {
        Task { await fetchRegistrations() }
    }
    
    func fetchRegistrations() async {
        isLoading = true
        do {
            let items = try await fetcher.fetchRegistrationsForEvent(eventId: eventId)
            self.registrations = items
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.isError = true
            self.errorMessage = "Failed to load registrations"
        }
    }
    
    // MARK: - Action Placeholders
    
    func approveRegistration(id: String) async {
        processingIds[id] = true
        defer { processingIds[id] = false }
        
        do {
            // Trigger remote transaction updates via Supabase
            try await fetcher.approveRegistration(id: id)
            print("Successfully approved registration: \(id)")
            
            // Reload the collection view layout to show updated badge status states
            await fetchRegistrations()
        } catch {
            self.isError = true
            self.errorMessage = "Could not approve registration status. Please try again."
            print("Approval Error: \(error)")
        }
    }
    
    func rejectRegistration(id: String) async {
        processingIds[id] = true
        defer { processingIds[id] = false }
        
        do {
            // Trigger remote mutation
            try await fetcher.rejectRegistration(id: id)
            print("Successfully rejected registration: \(id)")
            
            // Refresh table view items
            await fetchRegistrations()
        } catch {
            self.isError = true
            self.errorMessage = "Could not reject registration status. Please try again."
            print("Rejection Error: \(error)")
        }
    }
}
