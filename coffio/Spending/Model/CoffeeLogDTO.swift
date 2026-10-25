//
//  CoffeeLogDTO.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/10/26.
//


import Foundation

struct CoffeeLogDTO: Codable, Identifiable {
    let id: UUID?
    let userId: UUID?
    let coffeeName: String
    let price: Double
    let consumedAt: String
    let imageUrl: String
    let latitude: Double?
    let longitude: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case coffeeName = "coffee_name"
        case price
        case consumedAt = "consumed_at"
        case imageUrl = "image_url"
        case latitude
        case longitude
    }
}
