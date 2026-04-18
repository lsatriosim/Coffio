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
    @Published var isLoading: Bool = false
    @Published var hasViewModelLoaded: Bool = false
    @Published var isError: Bool = false
    
    func onViewDidLoad() async {
        do {
            await updateHasViewModelLoaded(hasViewModelLoaded: true)
            await updateIsLoading(isLoading: true)
            
            let newCoffeeShop = try await fetchCoffeeShop()
            await updateCoffeeShop(newDataModel: newCoffeeShop)
            
            await updateIsLoading(isLoading: false)
        }
        catch {
            await updateIsError(isError: true)
            await updateIsLoading(isLoading: false)
        }
    }
    
    func refetchCoffeShop() async {
        await updateIsError(isError: false)
        await updateIsLoading(isLoading: true)
        do {
            let newCoffeeShop = try await fetchCoffeeShop()
            await updateCoffeeShop(newDataModel: newCoffeeShop)
            await updateIsLoading(isLoading: false)
        }
        catch {
            await updateIsError(isError: true)
            await updateIsLoading(isLoading: false)
        }
    }
    
    private let fetcher = CoffeeShopFetcher()
}

//MARK: Private Function
private extension DiscoverFrontCardListViewModel {
    func fetchCoffeeShop() async throws -> [DiscoverCoffeeShopItemDataModel] {
        let response: [DiscoverCoffeeShopItem] = try await fetcher.fetchCoffeeShop()
        
        var parsedDataModel: [DiscoverCoffeeShopItemDataModel] = []
        for shop in response {
            let locationInfo: (distance: Double, distanceLabel: String)? = LocationProvider.shared.calculateDistance(latitude: Double(shop.latitude), longitude: Double(shop.longitude))
            let images: [DiscoverCoffeeShopImage] = try await fetcher.fetchCoffeeShopImage(shopId: shop.id)
            let reviews: [DiscoverCoffeeShopReview] = try await fetcher.fetchCoffeeShopReviews(shopId: shop.id)
            parsedDataModel.append(
                DiscoverCoffeeShopItemDataModel(
                    coffeeShopItem: shop,
                    locationInfo: locationInfo,
                    images: images,
                    reviews: reviews
                )
            )
        }
        parsedDataModel.sort { lhs, rhs in
            switch (lhs.distance, rhs.distance) {
            case let (l?, r?):
                return l < r          // both have distance
            case (_?, nil):
                return true          // lhs has value, rhs nil -> lhs first
            case (nil, _?):
                return false         // rhs has value -> rhs first
            case (nil, nil):
                return false         // same priority
            }
        }
        return parsedDataModel
    }
}

//MARK: Main Actor
private extension DiscoverFrontCardListViewModel {
    @MainActor
    private func updateCoffeeShop(newDataModel: [DiscoverCoffeeShopItemDataModel]) {
        self.coffeeShop = newDataModel
    }
    
    @MainActor
    private func updateIsLoading(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    @MainActor
    private func updateIsError(isError: Bool) {
        self.isError = isError
    }
    
    @MainActor
    private func updateHasViewModelLoaded(hasViewModelLoaded: Bool) {
        self.hasViewModelLoaded = hasViewModelLoaded
    }
}
