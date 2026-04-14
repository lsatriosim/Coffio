//
//  DiscoverCoffeeShopReview.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/04/26.
//

import Foundation

struct DiscoverCoffeeShopReview: JSONDecodable {
    let id: String
    let coffeeShopId: String
    let user: ReviewUser
    let rating: Int
    let comment: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case coffeeShopId = "coffee_shop_id"
        case user
        case rating
        case comment
        case createdAt = "created_at"
    }
    
    struct ReviewUser: JSONDecodable {
        let id: String
        let username: String
        let avatarUrl: String?
        let fullName: String
        let email: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case username
            case avatarUrl = "avatar_url"
            case fullName = "full_name"
            case email
        }
    }
}
