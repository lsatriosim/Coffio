//
//  DiscussionListViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/05/26.
//

import Foundation
import SwiftUI

@MainActor
final class DiscussionListViewModel: ObservableObject {
    @Published var threads: [DiscussionThreadItem] = []
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var hasViewModelLoaded: Bool = false
    
    private let fetcher: DiscussionFetcher = DiscussionFetcher()
    private let reportFetcher: ReportFetcher = ReportFetcher()
    private let authService = AuthenticationService.shared
    
    func onViewDidLoad() async {
        guard !hasViewModelLoaded else { return }
        await fetchThreads()
        self.hasViewModelLoaded = true
    }
    
    func fetchThreads() async {
        updateIsLoading(true)
        updateIsError(false)
        
        do {
            if let currentUserId = authService.user?.id {
                // ⚡️ Fetch both live threads and user reports concurrently to maximize performance
                async let fetchedThreadsTask = fetcher.fetchThreads()
                async let myReportsTask = reportFetcher.fetchMyReports(reporterId: currentUserId)
                
                let (fetchedThreads, myReports) = try await (fetchedThreadsTask, myReportsTask)
                
                // ⚡️ Standardize to lowercase strings to prevent casing mismatch comparison bugs
                let reportedThreadIds = Set(myReports.compactMap { $0.threadId?.lowercased() })
                let reportedUserIds = Set(myReports.compactMap { $0.reportedUserId?.lowercased() })
                
                // Filter out reported threads and content created by reported/blocked accounts
                let filteredThreads = fetchedThreads.filter { thread in
                    let isThreadReported = reportedThreadIds.contains(thread.id.lowercased())
                    let isUserReported = reportedUserIds.contains(thread.user.id.lowercased())
                    
                    return !isThreadReported && !isUserReported
                }
                
                updateThreads(filteredThreads)
            } else {
                // Fallback for unauthenticated state
                let fetchedThreads = try await fetcher.fetchThreads()
                updateThreads(fetchedThreads)
            }
            
        } catch {
            updateIsError(true)
            print("Error fetching threads: \(error)")
        }
        
        updateIsLoading(false)
    }
}

extension DiscussionListViewModel: @MainActor DiscussionDetailViewModelDelegate {
    func notifyToUpdateThreads() {
        Task {
            await fetchThreads()
        }
    }
}

// MARK: - Private Updates
private extension DiscussionListViewModel {
    func updateThreads(_ threads: [DiscussionThreadItem]) {
        self.threads = threads
    }
    
    func updateIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func updateIsError(_ isError: Bool) {
        self.isError = isError
    }
}
