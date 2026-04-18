//
//  DiscoverEventItem.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import Foundation

struct DiscoverEventItem: JSONDecodable {
    let id: String
    let title: String
    let description: String?
    let imageUrl: String?
    let location: String?
    let eventDate: Date
    let endDate: Date?
    let price: Int
    let capacity: Int
    let cafeName: String?
    let participantRegistered: Int
    let paymentInfo: PaymentInfo?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageUrl = "image_url"
        case location
        case eventDate = "event_date"
        case endDate = "end_date"
        case price
        case capacity
        case cafeName
        case participantRegistered = "participant_registered"
        case paymentInfo = "payment_info"
    }
}

struct PaymentInfo: JSONDecodable {
    let bankName: String?
    let bankAccount: String?
    let bankHolder: String?
    
    enum CodingKeys: String, CodingKey {
        case bankName = "bank_name"
        case bankAccount = "bank_account"
        case bankHolder = "bank_holder"
    }
}
