//
//  SpendingItemDataModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 06/06/26.
//

import Foundation

struct SpendingItemDataModel: Identifiable, JSONCodable {
    let id: UUID
    let userId: UUID
    let coffeeShopId: UUID?
    let itemName: String
    let amount: Int
    let quantity: Int
    let purchaseDate: Date
    let notes: String?
    let receiptUrl: String?
    let createdAt: Date
    
    // Optional context injection matching DiscoverCoffeeShopItemDataModel relationships
    var coffeeShopName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case coffeeShopId = "coffee_shop_id"
        case itemName = "item_name"
        case amount
        case quantity
        case purchaseDate = "purchase_date"
        case notes
        case receiptUrl = "receipt_url"
        case createdAt = "created_at"
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: purchaseDate)
    }
}
