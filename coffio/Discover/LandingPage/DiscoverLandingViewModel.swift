//
//  DiscoverLandingViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/06/26.
//

import SwiftUI

@MainActor
class DiscoverLandingViewModel: ObservableObject {
    @Published var topCoffeeShops: [DiscoverCoffeeShopItemDataModel] = []
    @Published var topEvents: [DiscoverEventItem] = []
    @Published var topCommunities: [CommunityItem] = []
    @Published var isLoading = false
    @Published var isError = false
    
    private let coffeeShopFetcher = CoffeeShopFetcher()
    private let eventFetcher = EventFetcher()
    private let communityFetcher = CommunityFetcher()
    private let reportFetcher = ReportFetcher()
    private let authService = AuthenticationService.shared

    func loadDashboardContent() async {
        isLoading = true
        isError = false
        
        do {
            // 1. Fetch raw top limits concurrently from the database wrappers
            async let coffeeShopsTask = coffeeShopFetcher.fetchTopCoffeeShops(limit: 10)
            async let eventsTask = eventFetcher.fetchTopEvents(limit: 5)
            async let communitiesTask = communityFetcher.fetchTopCommunities(limit: 6)
            
            // Fetch reports submitted by the active user session if available
            async let reportedEventIdsTask = fetchUserReportedEventIds()
            
            let (rawShops, fetchedEvents, fetchedCommunities, reportedEventIds) = try await (
                coffeeShopsTask,
                eventsTask,
                communitiesTask,
                reportedEventIdsTask
            )
            
            // 2. Filter out events reported by the active logged-in User ID
            let filteredEvents = fetchedEvents.filter { event in
                !reportedEventIds.contains(event.id.lowercased())
            }
            
            // 3. Parse raw coffee shops into your populated data models with distance calculations
            var parsedShopsBatch: [DiscoverCoffeeShopItemDataModel] = []
            
            for shop in rawShops {
                // Perform location calculation via your shared singleton mapping provider
                let locationInfo = LocationProvider.shared.calculateDistance(
                    latitude: Double(shop.latitude),
                    longitude: Double(shop.longitude)
                )
                
                // Concurrently gather auxiliary assets to populate full card requirements
                async let imagesTask = coffeeShopFetcher.fetchCoffeeShopImage(shopId: shop.id)
                async let reviewsTask = coffeeShopFetcher.fetchCoffeeShopReviews(shopId: shop.id)
                
                let (images, reviews) = try await (imagesTask, reviewsTask)
                
                parsedShopsBatch.append(
                    DiscoverCoffeeShopItemDataModel(
                        coffeeShopItem: shop,
                        locationInfo: locationInfo,
                        images: images,
                        reviews: reviews
                    )
                )
            }
            
            // 4. Sort your generated array by absolute proximity on the Main Actor thread safely
            parsedShopsBatch.sort { lhs, rhs in
                switch (lhs.distance, rhs.distance) {
                case let (l?, r?): return l < r
                case (_?, nil):    return true
                case (nil, _?):    return false
                case (nil, nil):   return false
                }
            }
            
            // 5. Update landing state streams
            guard !Task.isCancelled else { return }
            self.topCoffeeShops = parsedShopsBatch
            self.topEvents = filteredEvents
            self.topCommunities = fetchedCommunities
            
        } catch {
            guard !(error is CancellationError) else { return }
            self.isError = true
            print("Landing Dashboard Fetch Failure via fetcher framework: \(error)")
        }
        
        self.isLoading = false
    }
    
    /// Internal safe helper to get array string of eventIds flagged by this user
    private func fetchUserReportedEventIds() async -> Set<String> {
        var currentUserId: String? = authService.user?.id
        
        // Retry loop: If the auth state is restoration-bound, check 3 times with a 150ms delay interval
        if currentUserId == nil {
            for _ in 0..<3 {
                do {
                    try await Task.sleep(nanoseconds: 150_000_000) // 150 milliseconds
                    if let userId = authService.user?.id {
                        currentUserId = userId
                        break
                    }
                } catch {
                    break // Task cancellation handled safely
                }
            }
        }
        
        // Fall back gracefully if no user session turns up after the wait steps
        guard let resolvedUserId = currentUserId else {
            print("Notice: No active authenticated session user found during dashboard setup. Skipping exclusions.")
            return []
        }
        
        do {
            let userReports = try await reportFetcher.fetchMyReports(reporterId: resolvedUserId.lowercased())
            let mappedIds = userReports.compactMap { $0.eventId?.lowercased() }
            return Set(mappedIds)
        } catch {
            print("Non-fatal exception reading past event reports history: \(error)")
            return []
        }
    }
}

extension DiscoverLandingViewModel: @MainActor DiscoverDetailEventViewModelDelegate {
    func notifyToUpdateEventList() {
        Task {
            await loadDashboardContent()
        }
    }
}
