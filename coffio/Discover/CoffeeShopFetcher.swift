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
}
