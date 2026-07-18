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
    @Published var isPageLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isCreateEventSheetPresented: Bool = false
    
    // Pagination Controls
    private var currentPage: Int = 0
    private let pageSize: Int = 10
    private var canLoadMorePages: Bool = true
    
    let authService: AuthenticationService = AuthenticationService.shared
    private let fetcher: EventFetcher = EventFetcher()
    
    // MARK: - Report Tracking Dependencies
    private let reportFetcher: ReportFetcher = ReportFetcher()
    
    func onViewDidLoad() {
        guard events.isEmpty else { return }
        
        Task {
            updateIsLoading(isLoading: true)
            try await fetchNextEventPage()
            updateIsLoading(isLoading: false)
        }
    }
    
    func loadMoreContentIfNeeded(currentItem item: DiscoverEventItem) {
        guard let itemIndex = events.firstIndex(where: { $0.id == item.id }),
              itemIndex == events.count - 1 else { return }
        
        guard !isPageLoading && canLoadMorePages else { return }
        
        Task {
            isPageLoading = true
            try await fetchNextEventPage()
            isPageLoading = false
        }
    }
    
    /// Resets the full pagination lifecycle states for a clean refresh sweep
    func refreshEventsList() async {
        currentPage = 0
        canLoadMorePages = true
        
        do {
            let offsetFrom = currentPage * pageSize
            let offsetTo = offsetFrom + pageSize - 1
            
            async let responseTask = fetcher.fetchEvent(from: offsetFrom, to: offsetTo)
            async let reportedEventIdsTask = fetchUserReportedEventIds()
            
            let (response, reportedEventIds) = try await (responseTask, reportedEventIdsTask)
            
            if response.isEmpty || response.count < pageSize {
                canLoadMorePages = false
            }
            
            // Clear current items and assign the freshly filtered first page
            let approvedEvents = response.filter { $0.eventStatus == .approved }
            self.events = approvedEvents.filter { !reportedEventIds.contains($0.id.lowercased()) }
            
            currentPage += 1
        } catch {
            self.isError = true
            self.errorMessage = error.localizedDescription
            print("Error refreshing event stream: \(error)")
        }
    }
}

private extension DiscoverEventListViewModel {
    func fetchNextEventPage() async throws {
        let offsetFrom = currentPage * pageSize
        let offsetTo = offsetFrom + pageSize - 1
        
        // Concurrently fetch the page contents and the current user's submitted flag records
        async let responseTask = fetcher.fetchEvent(from: offsetFrom, to: offsetTo)
        async let reportedEventIdsTask = fetchUserReportedEventIds()
        
        let (response, reportedEventIds) = try await (responseTask, reportedEventIdsTask)
        
        if response.isEmpty || response.count < pageSize {
            canLoadMorePages = false // No more entries remain in Supabase table logs
        }
        
        appendEvents(newEvents: response, excludingReportedIds: reportedEventIds)
        currentPage += 1
    }
    
    /// Helper to look up unique event IDs reported by the current active session user profile
    func fetchUserReportedEventIds() async -> Set<String> {
        guard let currentUserId = authService.user?.id else { return [] }
        do {
            let userReports = try await reportFetcher.fetchMyReports(reporterId: currentUserId.lowercased())
            let mappedIds = userReports.compactMap { $0.eventId?.lowercased() }
            return Set(mappedIds)
        } catch {
            print("Non-fatal exclusion check failure gathering user reports: \(error)")
            return []
        }
    }
}

private extension DiscoverEventListViewModel {
    @MainActor
    func appendEvents(newEvents: [DiscoverEventItem], excludingReportedIds reportedIds: Set<String>) {
        let approvedEvents = newEvents.filter { $0.eventStatus == .approved }
        
        // Filter out items that match the user's flagged reports history locally
        let filteredEvents = approvedEvents.filter { !reportedIds.contains($0.id.lowercased()) }
        
        self.events.append(contentsOf: filteredEvents)
    }
    
    @MainActor
    func updateIsLoading(isLoading: Bool) {
        self.isLoading = isLoading
    }
}

// MARK: - Delegate Event Update Extension
extension DiscoverEventListViewModel: @MainActor DiscoverDetailEventViewModelDelegate {
    func notifyToUpdateEventList() {
        Task {
            updateIsLoading(isLoading: true)
            await refreshEventsList()
            updateIsLoading(isLoading: false)
        }
    }
}
