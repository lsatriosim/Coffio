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
    @Published var isLoading = false
    @Published var isError = false
    
    private let coffeeShopFetcher = CoffeeShopFetcher()
    private let eventFetcher = EventFetcher()

    func loadDashboardContent() async {
        isLoading = true
        isError = false
        
        do {
            // 1. Fetch raw top limits concurrently from the database wrappers
            async let coffeeShopsTask = coffeeShopFetcher.fetchTopCoffeeShops(limit: 10)
            async let eventsTask = eventFetcher.fetchTopEvents(limit: 5)
            
            let (rawShops, fetchedEvents) = try await (coffeeShopsTask, eventsTask)
            
            // 2. Parse raw coffee shops into your populated data models with distance calculations
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
            
            // 3. Sort your generated array by absolute proximity on the Main Actor thread safely
            parsedShopsBatch.sort { lhs, rhs in
                switch (lhs.distance, rhs.distance) {
                case let (l?, r?): return l < r
                case (_?, nil):    return true
                case (nil, _?):    return false
                case (nil, nil):   return false
                }
            }
            
            // 4. Update landing state streams
            guard !Task.isCancelled else { return }
            self.topCoffeeShops = parsedShopsBatch
            self.topEvents = fetchedEvents
            
        } catch {
            guard !(error is CancellationError) else { return }
            self.isError = true
            print("Landing Dashboard Fetch Failure via fetcher framework: \(error)")
        }
        
        self.isLoading = false
    }
}
