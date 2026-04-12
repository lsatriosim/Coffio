//
//  DiscoverCoffeeShopImage.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 12/04/26.
//

import Foundation

struct DiscoverCoffeeShopImage: JSONDecodable {
    let id: String
    let coffeeShopId: String
    let imageUrl: String
    let position: Int
    let isCover: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case coffeeShopId = "coffee_shop_id"
        case imageUrl = "image_url"
        case position
        case isCover = "is_cover"
    }
}
