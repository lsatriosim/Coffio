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
    
    func onViewDidLoad() async {
        do {
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
        } catch {
            
        }
    }
    
    @MainActor
    private func updateCoffeeShop(newDataModel: [DiscoverCoffeeShopItemDataModel]) {
        self.coffeeShop = newDataModel
    }
    
    private let fetcher = CoffeeShopFetcher()
}
