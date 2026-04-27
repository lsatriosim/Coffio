//
//  DiscoverCoffeeShopReviewRequest.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 26/04/26.
//

struct DiscoverCoffeeShopReviewRequest: JSONEncodable {
    let id: String
    let coffeeShopId: String
    let userId: String
    let rating: Int
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case coffeeShopId = "coffee_shop_id"
        case userId = "user_id"
        case rating
        case comment
    }
}
