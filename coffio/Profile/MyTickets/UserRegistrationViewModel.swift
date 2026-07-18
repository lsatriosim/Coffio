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
    
    // MARK: - Report Tracking Dependencies
    private let reportFetcher = ReportFetcher()
    
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
            // 1. Concurrently pull both registration list and reported events history matching this user session
            async let itemsTask = fetcher.fetchUserRegistrations(userId: user.id)
            async let reportedEventIdsTask = fetchUserReportedEventIds(userId: user.id)
            
            let (items, reportedEventIds) = try await (itemsTask, reportedEventIdsTask)
            
            // 2. Filter out registrations where the corresponding nested event has been reported
            // Note: Update item.eventDetail.id based on the property name inside your EventRegistrationItem structural model
            self.registrations = items.filter { item in
                !reportedEventIds.contains(item.eventDetail.id.lowercased())
            }
            
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.isError = true
            self.errorMessage = "Failed to load registrations"
            print("Error: \(error)")
        }
    }
}

// MARK: - Safe Exclusions Helpers
private extension UserRegistrationViewModel {
    /// Safe internal helper to parse out all reported event primary keys
    func fetchUserReportedEventIds(userId: String) async -> Set<String> {
        do {
            let userReports = try await reportFetcher.fetchMyReports(reporterId: userId.lowercased())
            let mappedIds = userReports.compactMap { $0.eventId?.lowercased() }
            return Set(mappedIds)
        } catch {
            print("Non-fatal exclusion framework error inside UserRegistration data streaming: \(error)")
            return []
        }
    }
}

// MARK: - Delegate Event Update Extension
extension UserRegistrationViewModel: @MainActor DiscoverDetailEventViewModelDelegate {
    func notifyToUpdateEventList() {
        Task {
            await fetchRegistrations()
        }
    }
}
