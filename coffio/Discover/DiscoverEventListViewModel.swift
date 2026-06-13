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
}

private extension DiscoverEventListViewModel {
    func fetchNextEventPage() async throws {
        let offsetFrom = currentPage * pageSize
        let offsetTo = offsetFrom + pageSize - 1
        
        let response = try await fetcher.fetchEvent(from: offsetFrom, to: offsetTo)
        
        if response.isEmpty || response.count < pageSize {
            canLoadMorePages = false // No more entries remain in Supabase table logs
        }
        
        appendEvents(newEvents: response)
        currentPage += 1
    }
}

private extension DiscoverEventListViewModel {
    @MainActor
    func appendEvents(newEvents: [DiscoverEventItem]) {
        self.events.append(contentsOf: newEvents) // Gracefully stacks new rows to the view
    }
    
    @MainActor
    func updateIsLoading(isLoading: Bool) {
        self.isLoading = isLoading
    }
}
