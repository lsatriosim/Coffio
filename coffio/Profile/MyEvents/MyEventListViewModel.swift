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
    
    // MARK: - Report Tracking Dependencies
    private let reportFetcher: ReportFetcher
    
    init(
        fetcher: EventFetcher = EventFetcher(),
        reportFetcher: ReportFetcher = ReportFetcher()
    ) {
        self.fetcher = fetcher
        self.reportFetcher = reportFetcher
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
            
            // 1. Concurrently fetch raw user events, registration metrics, and local flag history exclusions
            async let eventsTask = fetcher.fetchEvent(authorId: currentUserId)
            async let registrationsTask = fetcher.fetchAllRegistrationsAcrossView()
            async let reportedEventIdsTask = fetchUserReportedEventIds(userId: currentUserId)
            
            let (rawItems, allRegistrations, reportedEventIds) = try await (eventsTask, registrationsTask, reportedEventIdsTask)
            
            // 2. Filter out any events that match reported list metrics
            let filteredRawItems = rawItems.filter { item in
                !reportedEventIds.contains(item.id.lowercased())
            }
            
            // 3. Map into full display data models
            self.events = filteredRawItems.map { item in
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

// MARK: - Safe Exclusions Helpers
private extension MyEventListViewModel {
    /// Safe internal helper to parse out all reported event primary keys
    func fetchUserReportedEventIds(userId: String) async -> Set<String> {
        do {
            let userReports = try await reportFetcher.fetchMyReports(reporterId: userId.lowercased())
            let mappedIds = userReports.compactMap { $0.eventId?.lowercased() }
            return Set(mappedIds)
        } catch {
            print("Non-fatal exclusion framework error inside MyEventList parsing: \(error)")
            return []
        }
    }
}

// MARK: - Delegate Event Update Extension
extension MyEventListViewModel: @MainActor DiscoverDetailEventViewModelDelegate {
    func notifyToUpdateEventList() {
        Task {
            await fetchUserCreatedEvents()
        }
    }
}
