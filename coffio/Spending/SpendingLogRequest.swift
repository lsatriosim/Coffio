//
//  SpendingLogRequest.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 06/06/26.
//

import Foundation

struct SpendingLogRequest: Encodable {
    let user_id: String
    let coffee_shop_id: String?
    let item_name: String
    let amount: Int
    let quantity: Int
    let purchase_date: String // Database expects "YYYY-MM-DD" style representation
    let notes: String?
    let receipt_url: String?
    
    init(
        userId: String,
        coffeeShopId: String?,
        itemName: String,
        amount: Int,
        quantity: Int,
        purchaseDate: Date,
        notes: String?,
        receiptUrl: String? = nil
    ) {
        self.user_id = userId
        self.coffee_shop_id = coffeeShopId
        self.item_name = itemName
        self.amount = amount
        self.quantity = quantity
        self.notes = notes
        self.receipt_url = receiptUrl
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.purchase_date = formatter.string(from: purchaseDate)
    }
}
