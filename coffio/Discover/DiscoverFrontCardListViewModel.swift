//
//  DiscoverFrontCardListViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 12/04/26.
//

import Foundation
import SwiftUI

final class DiscoverFrontCardListViewModel: ObservableObject {
    @Published var coffeeShop: [DiscoverCoffeeShopItemDataModel] = []
    @Published var events: [DiscoverEventItem] = []
    @Published var isLoading: Bool = false
    @Published var isPageLoading: Bool = false // 💡 Inline footer pagination tracker
    @Published var hasViewModelLoaded: Bool = false
    @Published var isError: Bool = false
    
    // Pagination Controls
    private var currentPage: Int = 0
    private let pageSize: Int = 10
    private var canLoadMorePages: Bool = true
    
    func onViewDidLoad() async {
        do {
            await updateHasViewModelLoaded(hasViewModelLoaded: true)
            await updateIsLoading(isLoading: true)
            
            // Initial payload batch runs concurrently
            async let initialShops: () = fetchNextCoffeeShopPage()
            async let initialEvents: () = fetchEvents()
            
            _ = try await [initialShops, initialEvents]
            await updateIsLoading(isLoading: false)
        }
        catch {
            print("Failed to fetch dashboard content data: \(error)")
            await updateIsError(isError: true)
            await updateIsLoading(isLoading: false)
        }
    }
    
    func refetchCoffeShop() async {
        currentPage = 0
        canLoadMorePages = true
        await updateCoffeeShop(newDataModel: [])
        await updateIsError(isError: false)
        await updateIsLoading(isLoading: true)
        
        do {
            try await fetchNextCoffeeShopPage()
            try await fetchEvents()
            await updateIsLoading(isLoading: false)
        }
        catch {
            await updateIsError(isError: true)
            await updateIsLoading(isLoading: false)
        }
    }
    
    /// Triggers incremental fetching when the user approaches the grid bottom
    func loadMoreContentIfNeeded(currentItem item: DiscoverCoffeeShopItemDataModel) async {
        guard let itemIndex = coffeeShop.firstIndex(where: { $0.id == item.id }),
              itemIndex == coffeeShop.count - 1 else { return }
        
        guard !isPageLoading && canLoadMorePages else { return }
        
        await updateIsPageLoading(isLoading: true)
        do {
            try await fetchNextCoffeeShopPage()
        } catch {
            print("Failed to load more pages smoothly: \(error)")
        }
        await updateIsPageLoading(isLoading: false)
    }
    
    private let fetcher = CoffeeShopFetcher()
    private let eventFetcher = EventFetcher()
}

//MARK: - Private Fetch Engine Operations
private extension DiscoverFrontCardListViewModel {
    
    func fetchNextCoffeeShopPage() async throws {
        let offsetFrom = currentPage * pageSize
        let offsetTo = offsetFrom + pageSize - 1
        
        // 💡 Requests a clean 10 item batch payload window
        let response: [DiscoverCoffeeShopItem] = try await fetcher.fetchCoffeeShop(from: offsetFrom, to: offsetTo)
        
        if response.isEmpty || response.count < pageSize {
            canLoadMorePages = false
        }
        
        var parsedPageBatch: [DiscoverCoffeeShopItemDataModel] = []
        
        // Dynamically resolve internal lookups concurrently across this page slice
        for shop in response {
            let locationInfo = LocationProvider.shared.calculateDistance(latitude: Double(shop.latitude), longitude: Double(shop.longitude))
            let images = try await fetcher.fetchCoffeeShopImage(shopId: shop.id)
            let reviews = try await fetcher.fetchCoffeeShopReviews(shopId: shop.id)
            
            parsedPageBatch.append(
                DiscoverCoffeeShopItemDataModel(
                    coffeeShopItem: shop,
                    locationInfo: locationInfo,
                    images: images,
                    reviews: reviews
                )
            )
        }
        
        // Sort individual incoming page arrays relative to proximity values
        parsedPageBatch.sort { lhs, rhs in
            switch (lhs.distance, rhs.distance) {
            case let (l?, r?): return l < r
            case (_?, nil):    return true
            case (nil, _?):    return false
            case (nil, nil):   return false
            }
        }
        
        await appendCoffeeShopsOnMainActor(newShops: parsedPageBatch)
        currentPage += 1
    }
    
    func fetchEvents() async throws {
        // Initial dashboard event view request window boundary (0 to 4 items)
        let response = try await eventFetcher.fetchEvent(from: 0, to: 4)
        await updateEvents(events: response)
    }
}

//MARK: - Main Actor Thread Dispatching Safeguards
private extension DiscoverFrontCardListViewModel {
    @MainActor
    private func appendCoffeeShopsOnMainActor(newShops: [DiscoverCoffeeShopItemDataModel]) {
        self.coffeeShop.append(contentsOf: newShops)
    }
    
    @MainActor
    private func updateCoffeeShop(newDataModel: [DiscoverCoffeeShopItemDataModel]) {
        self.coffeeShop = newDataModel
    }
    
    @MainActor
    private func updateIsLoading(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    @MainActor
    private func updateIsPageLoading(isLoading: Bool) {
        self.isPageLoading = isLoading
    }
    
    @MainActor
    private func updateIsError(isError: Bool) {
        self.isError = isError
    }
    
    @MainActor
    private func updateHasViewModelLoaded(hasViewModelLoaded: Bool) {
        self.hasViewModelLoaded = hasViewModelLoaded
    }
    
    @MainActor
    private func updateEvents(events: [DiscoverEventItem]) {
        self.events = events
    }
}
