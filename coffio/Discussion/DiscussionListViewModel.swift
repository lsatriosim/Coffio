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
    
    func onViewDidLoad() async {
        guard !hasViewModelLoaded else { return }
        await fetchThreads()
        self.hasViewModelLoaded = true
    }
    
    func fetchThreads() async {
        updateIsLoading(true)
        updateIsError(false)
        
        do {
            let fetchedThreads = try await fetcher.fetchThreads()
            updateThreads(fetchedThreads)
        } catch {
            updateIsError(true)
            print("Error fetching threads: \(error)")
        }
        
        updateIsLoading(false)
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
