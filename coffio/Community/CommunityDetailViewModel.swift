//
//  CommunityDetailViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 21/06/26.
//

import Foundation

@MainActor
final class CommunityDetailViewModel: ObservableObject {
    let communityId: String
    
    private let communityFetcher: CommunityFetcherProtocol
    
    @Published var community: CommunityDetailItem?
    @Published var posts: [CommunityPostItem] = []
    @Published var events: [DiscoverEventItem] = []
    
    @Published var isLoading = true
    @Published var isError = false
    
    init(
        communityId: String,
        communityFetcher: CommunityFetcherProtocol = CommunityFetcher(),
    ) {
        self.communityId = communityId
        self.communityFetcher = communityFetcher
    }
    
    func loadPageData() async {
        isLoading = true
        isError = false
        
        do {
            async let fetchedCommunity = communityFetcher.fetchCommunityDetail(by: communityId)
            async let fetchedPosts = communityFetcher.fetchPosts(for: communityId)
            async let fetchedEvents = communityFetcher.fetchCommunityEvents(communityId: communityId)
            
            self.community = try await fetchedCommunity
            self.posts = try await fetchedPosts
            self.events = try await fetchedEvents
            
            self.isLoading = false
        } catch {
            print("Error stream interrupted through fetcher layers: \(error)")
            self.isError = true
            self.isLoading = false
        }
    }
}
