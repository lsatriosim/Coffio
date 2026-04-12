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
    
    func onViewDidLoad() async {
        do {
            hasViewModelLoaded = true
            await updateIsLoading(isLoading: true)
            let response: [DiscoverCoffeeShopItem] = try await fetcher.fetchCoffeeShop()
            
            var parsedDataModel: [DiscoverCoffeeShopItemDataModel] = []
            for shop in response {
                let distanceLabel = LocationProvider.shared.calculateDistance(latitude: Double(shop.latitude), longitude: Double(shop.longitude))
                let images: [DiscoverCoffeeShopImage] = try await fetcher.fetchCoffeeShopImage(shopId: shop.id)
                parsedDataModel.append(
                    DiscoverCoffeeShopItemDataModel(
                        coffeeShopItem: shop,
                        distanceLabel: distanceLabel,
                        images: images
                    )
                )
                if !images.isEmpty {
                    print(shop)
                }
            }
            await updateCoffeeShop(newDataModel: parsedDataModel)
            await updateIsLoading(isLoading: false)
        }
        catch {
            await updateIsLoading(isLoading: false)
        }
    }
    
    @MainActor
    private func updateCoffeeShop(newDataModel: [DiscoverCoffeeShopItemDataModel]) {
        self.coffeeShop = newDataModel
    }
    
    @MainActor
    private func updateIsLoading(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    private let fetcher = CoffeeShopFetcher()
}
