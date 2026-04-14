//
//  DiscoverCoffeeShopItemDataModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 12/04/26.
//

import Foundation

struct DiscoverCoffeeShopItemDataModel {
    let id: String
    let name: String
    let description: String?
    let address: String
    let latitude: Float
    let longitude: Float
    let imageUrl: String?
    let instagramUrl: String?
    let mapUrl: String?
    let priceMin: Int?
    let priceMax: Int?
    let facilities: [CoffeeShopFacilities]
    let distanceLabel: String?
    let images: [DiscoverCoffeeShopImage]
    let reviews: [DiscoverCoffeeShopReview]
    
    var imageUrls: [String] {
        images.map { $0.imageUrl }
    }
    
    init(
        coffeeShopItem: DiscoverCoffeeShopItem,
        distanceLabel: String? = nil,
        images: [DiscoverCoffeeShopImage] = [],
        reviews: [DiscoverCoffeeShopReview] = []
    ) {
        self.id = coffeeShopItem.id
        self.name = coffeeShopItem.name
        self.description = coffeeShopItem.description
        self.address = coffeeShopItem.address
        self.latitude = coffeeShopItem.latitude
        self.longitude = coffeeShopItem.longitude
        self.imageUrl = coffeeShopItem.imageUrl
        self.instagramUrl = coffeeShopItem.instagramUrl
        self.mapUrl = coffeeShopItem.mapUrl
        self.priceMin = coffeeShopItem.priceMin
        self.priceMax = coffeeShopItem.priceMax
        self.facilities = coffeeShopItem.facilities
        self.distanceLabel = distanceLabel
        self.images = images
        self.reviews = reviews
    }
    
    func getPriceRangeLabel() -> String? {
        guard let priceMin, let priceMax else {
            return nil
        }
        
        return formatPriceRange(priceMin: priceMin, priceMax: priceMax)
    }
    
    func getAverageReviews() -> Double {
        guard !reviews.isEmpty else { return 0.0 }
        
        let avg = Double(reviews.map { $0.rating }.reduce(0, +)) / Double(reviews.count)
        return (avg * 10).rounded() / 10
    }
    
    private func formatPriceRange(priceMin: Int, priceMax: Int) -> String {
        func formatToK(_ value: Int) -> String {
            let thousands = value / 1000
            return "Rp\(thousands)k"
        }
        
        return "\(formatToK(priceMin))-\(formatToK(priceMax))"
    }
}
