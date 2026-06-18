//
//  MyEventListViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//


//
//  MyEventListViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//

import SwiftUI
import Supabase

@MainActor
final class MyEventListViewModel: ObservableObject {
    // published state properties matching coffio architectural patterns
    @Published var events: [MyEventCardDataModel] = []
    @Published var isLoading = false
    @Published var isError = false
    @Published var errorMessage = ""
    
    private let fetcher: EventFetcher
    
    init(fetcher: EventFetcher = EventFetcher()) {
        self.fetcher = fetcher
    }
    
    func onViewDidLoad() {
        guard events.isEmpty else { return }
        Task {
            await fetchUserCreatedEvents()
        }
    }
    
    /// Pulls current session uid context and fetches mapped UI models from Supabase view source
    func fetchUserCreatedEvents() async {
        isLoading = true
        isError = false
        
        do {
            // Retrieve current authenticated session profile user ID
            guard let currentUserId = supabaseClient.auth.currentUser?.id.uuidString else {
                throw NSError(
                    domain: "AuthError",
                    code: 401,
                    userInfo: [NSLocalizedDescriptionKey: "User session not found. Please log in again."]
                )
            }
            
            async let eventsTask = fetcher.fetchEvent(authorId: currentUserId)
            async let registrationsTask = fetcher.fetchAllRegistrationsAcrossView()
            
            let (rawItems, allRegistrations) = try await (eventsTask, registrationsTask)
            
            self.events = rawItems.map { item in
                let pendingCount = allRegistrations.filter { registration in
                    registration.eventDetail.id == item.id &&
                    registration.status == .paymentSubmitted
                }.count
                
                return MyEventCardDataModel(
                    id: item.id,
                    title: item.title,
                    startDate: item.eventDate,
                    endDate: item.endDate,
                    location: item.cafeName ?? "Venue Partner",
                    address: item.location ?? "No structural address provided",
                    participantNeedConfirmation: pendingCount,
                    status: item.eventStatus
                )
            }
        } catch {
            guard !(error is CancellationError) else { return }
            self.errorMessage = error.localizedDescription
            self.isError = true
            print("Execution layer mapping error context: \(error)")
        }
        
        self.isLoading = false
    }
}
