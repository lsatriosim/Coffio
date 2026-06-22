//
//  DiscoverCommunityListViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 22/06/26.
//

import SwiftUI

@MainActor
final class DiscoverCommunityListViewModel: ObservableObject {
    @Published var communities: [CommunityItem] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var isError = false
    
    private let fetcher: CommunityFetcher = CommunityFetcher()
    
    var filteredCommunities: [CommunityItem] {
        guard !searchText.isEmpty else { return communities }
        return communities.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    func loadAllCommunities() async {
        isLoading = true
        isError = false
        
        do {
            self.communities = try await fetcher.fetchAllCommunities()
        } catch {
            print("Error parsing deep community lists: \(error)")
            self.isError = true
        }
        
        self.isLoading = false
    }
}
