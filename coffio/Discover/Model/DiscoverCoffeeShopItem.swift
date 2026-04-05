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
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case address
        case latitude
        case longitude
        case imageUrl = "image_url"
    }
}

let discoverCoffeeShopItemMock = [
    DiscoverCoffeeShopItem(
        id: "1",
        name: "Cafe 1",
        description: nil,
        address: "jlds dsds",
        latitude: 10.0,
        longitude: 32.0,
        imageUrl: nil
    ),
    DiscoverCoffeeShopItem(
        id: "1",
        name: "Cafe 1",
        description: nil,
        address: "jlds dsds",
        latitude: 10.0,
        longitude: 32.0,
        imageUrl: nil
    )
]

