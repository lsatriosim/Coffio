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
    let coffeeShopName: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case coffeeShopId
        case itemName
        case amount
        case quantity
        case purchaseDate
        case notes
        case receiptUrl
        case createdAt
        case coffeeShopName
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: purchaseDate)
    }
}
