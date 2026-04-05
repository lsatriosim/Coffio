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
}
