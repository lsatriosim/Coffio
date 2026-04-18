//
//  DiscoverEventListViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import Foundation
import SwiftUI

final class DiscoverEventListViewModel: ObservableObject {
    @Published var events: [DiscoverEventItem] = []
    @Published var isLoading: Bool = false
    
    func onViewDidLoad() {
        Task {
            await updateIsLoading(isLoading: true)
            try await fetchEvent()
            await updateIsLoading(isLoading: false)
        }
    }
    
    private let fetcher: EventFetcher = EventFetcher()
}

private extension DiscoverEventListViewModel {
    func fetchEvent() async throws {
        let response = try await fetcher.fetchEvent()
        await updateEvents(events: response)
    }
}

private extension DiscoverEventListViewModel {
    @MainActor func updateEvents(events: [DiscoverEventItem]) {
        self.events = events
    }
    
    @MainActor
    func updateIsLoading(isLoading: Bool) {
        self.isLoading = isLoading
    }
}
