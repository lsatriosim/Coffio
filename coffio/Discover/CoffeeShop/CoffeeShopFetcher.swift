//
//  CoffeeShopFetcher.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import Foundation

final class CoffeeShopFetcher {
    func fetchCoffeeShop() async throws -> [DiscoverCoffeeShopItem] {
        let response = try await supabaseClient
            .from("coffee_shops")
            .select()
            .execute()
        
        let decoder = JSONDecoder()
        return try decoder.decode([DiscoverCoffeeShopItem].self, from: response.data)
    }
    
    func fetchCoffeeShopDetail(id: String) async throws -> DiscoverCoffeeShopItem {
        let response = try await supabaseClient
            .from("coffee_shops")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        return try decoder.decode(DiscoverCoffeeShopItem.self, from: response.data)
    }
    
    func fetchCoffeeShopImage(shopId: String) async throws -> [DiscoverCoffeeShopImage] {
        do {
            let response = try await supabaseClient
                .from("cafe_images")
                .select()
                .eq("coffee_shop_id", value: shopId)
                .execute()
            
            let decoder = JSONDecoder()
            let parsedResponse = try decoder.decode([DiscoverCoffeeShopImage].self, from: response.data)
            return parsedResponse
        }
        catch {
            print(error)
            return []
        }
    }
    
    func fetchCoffeeShopReviews(shopId: String) async throws -> [DiscoverCoffeeShopReview] {
        do {
            let response = try await supabaseClient
                .from("cafe_reviews_with_user")
                .select()
                .eq("coffee_shop_id", value: shopId)
                .execute()
            
            let decoder = JSONDecoder()
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]

            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let string = try container.decode(String.self)
                
                if let date = formatter.date(from: string) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid date: \(string)"
                )
            }
            let parsedResponse = try decoder.decode([DiscoverCoffeeShopReview].self, from: response.data)
            return parsedResponse
        }
        catch {
            print("[Fetch Review]: \(error)")
            return []
        }
    }
    
    func postCoffeeShopReview(request: DiscoverCoffeeShopReviewRequest) async throws {
        try await supabaseClient
            .from("cafe_reviews")
            .insert(request)
            .execute()
    }
}
