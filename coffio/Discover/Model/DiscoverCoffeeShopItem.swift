//
//  DiscoverCoffeeShopItem.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import Foundation

struct DiscoverCoffeeShopItem: JSONDecodable {
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
    var distanceLabel: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case address
        case latitude
        case longitude
        case imageUrl = "image_url"
        case instagramUrl = "instagram_url"
        case mapUrl = "map_url"
        case priceMin = "price_min"
        case priceMax = "price_max"
        case facilities
        case distanceLabel
    }
}

enum CoffeeShopFacilities: String, JSONDecodable {
    case wifi = "wifi"
    case powerOutlet = "power_outlet"
    case outdoor = "outdoor"
}

let discoverCoffeeShopItemMock = [
    DiscoverCoffeeShopItem(
        id: "1",
        name: "Kopi Kenangan alam Sutera",
        description: nil,
        address: "jlds dsds",
        latitude: 10.0,
        longitude: 32.0,
        imageUrl: nil,
        instagramUrl: nil,
        mapUrl: nil,
        priceMin: nil,
        priceMax: nil,
        facilities: [.outdoor, .powerOutlet]
    ),
    DiscoverCoffeeShopItem(
        id: "1",
        name: "Cafe 1",
        description: nil,
        address: "jlds dsds",
        latitude: 10.0,
        longitude: 32.0,
        imageUrl: nil,
        instagramUrl: nil,
        mapUrl: nil,
        priceMin: nil,
        priceMax: nil,
        facilities: [.wifi]
    )
]

