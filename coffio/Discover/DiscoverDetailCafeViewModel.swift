//
//  DiscoverDetailCafeViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 27/04/26.
//

import Foundation

@MainActor
final class DiscoverDetailCafeViewModel: ObservableObject {
    @Published var coffeeShop: DiscoverCoffeeShopItemDataModel
    
    init(coffeeShop: DiscoverCoffeeShopItemDataModel) {
        self.coffeeShop = coffeeShop
    }
    
    private let fetcher: CoffeeShopFetcher = .init()
}

extension DiscoverDetailCafeViewModel: @MainActor DiscoverReviewViewModelDelegate {
    func onReviewSubmitted() {
        Task {
            await updateReview()
        }
    }
}

private extension DiscoverDetailCafeViewModel {
    func updateReview() async {
        do {
            let reviews: [DiscoverCoffeeShopReview] = try await fetcher.fetchCoffeeShopReviews(shopId: coffeeShop.id)
            let newDataModel: DiscoverCoffeeShopItemDataModel = DiscoverCoffeeShopItemDataModel(dataModel: coffeeShop, reviews: reviews)
            self.coffeeShop = newDataModel
        }
        catch {
            print("Fetch coffee shop failed:", error)
        }
    }
}
