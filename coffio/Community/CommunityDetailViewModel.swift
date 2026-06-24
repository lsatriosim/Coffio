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
    @Published var membershipStatus: CommunityJoinRequestStatus? = nil
    
    @Published var isLoading = true
    @Published var isError = false
    @Published var isSubmittingJoin = false
    
    var isApprovedMember: Bool {
        membershipStatus == .approved
    }
    
    var hasRequestedToJoin: Bool {
        membershipStatus != nil // If it has any value (.pending or .approved), it's already requested
    }
    
    var joinButtonLabel: String {
        switch membershipStatus {
        case .pending:
            return "Request Pending Approval"
        case .approved:
            return "You are a Member"
        case nil:
            return "Request to Join Community"
        }
    }
    
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
            if let currentUserId = supabaseClient.auth.currentUser?.id.uuidString {
                async let fetchedStatus: CommunityJoinRequestStatus? = {
                    return try? await communityFetcher.fetchMembershipStatus(communityId: communityId, userId: currentUserId)
                }()
                self.membershipStatus = await fetchedStatus
            }
            
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
    
    func submitJoinRequest() async {
        guard !hasRequestedToJoin, let currentUserId = supabaseClient.auth.currentUser?.id.uuidString else { return }
        
        isSubmittingJoin = true
        do {
            try await communityFetcher.requestToJoinCommunity(communityId: communityId, userId: currentUserId)
            self.membershipStatus = .pending
        } catch {
            print("Failed to dispatch join request mutation layer: \(error)")
        }
        isSubmittingJoin = false
    }
}
