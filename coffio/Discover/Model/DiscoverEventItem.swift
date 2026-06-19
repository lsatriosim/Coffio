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
    let menuImageUrl: String?
    let location: String?
    let eventDate: Date
    let endDate: Date?
    let price: Int
    let capacity: Int
    let cafeName: String?
    let createdBy: String
    let registrationType: RegistrationType
    let externalRegistrationURL: String?
    let participantRegistered: Int
    let paymentInfo: PaymentInfo?
    let eventStatus: EventStatus
    let slotLeft: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageUrl = "image_url"
        case menuImageUrl = "menu_image_url"
        case location
        case eventDate = "event_date"
        case endDate = "end_date"
        case price
        case capacity
        case cafeName
        case createdBy = "created_by"
        case registrationType = "registration_type"
        case externalRegistrationURL = "external_registration_url"
        case participantRegistered = "participant_registered"
        case paymentInfo = "payment_info"
        case eventStatus = "status"
        case slotLeft = "slot_left"
    }
}

enum RegistrationType: String, JSONDecodable {
    case `internal`
    case external
}

enum EventStatus: String, JSONDecodable {
    case approved
    case pending
    case rejected
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

let discoverEventMock: [DiscoverEventItem] = [
    .init(
        id: "1",
        title: "Brew with Barista",
        description: "Brewing with barista newdsaodjasoid pasjdpajd p",
        imageUrl: nil,
        menuImageUrl: nil,
        location: "Jl Pamekarsa No 148",
        eventDate: .now,
        endDate: nil,
        price: 100000,
        capacity: 30,
        cafeName: "Kopi Kenangan",
        createdBy: UUID().uuidString,
        registrationType: .internal,
        externalRegistrationURL: nil,
        participantRegistered: 10,
        paymentInfo: .init(
            bankName: "BCA",
            bankAccount: "8632321",
            bankHolder: "Liefran Satrio"
        ),
        eventStatus: .approved,
        slotLeft: 0
    ),
    .init(
        id: "2",
        title: "Work from Cafe",
        description: "Brewing with barista newdsaodjasoid pasjdpajd p",
        imageUrl: nil,
        menuImageUrl: nil,
        location: "Jl Pamekarsa No 148",
        eventDate: .now,
        endDate: nil,
        price: 100000,
        capacity: 30,
        cafeName: "Kopi Kenangan",
        createdBy: UUID().uuidString,
        registrationType: .external,
        externalRegistrationURL: "https://www.google.com",
        participantRegistered: 10,
        paymentInfo: .init(
            bankName: "BCA",
            bankAccount: "8632321",
            bankHolder: "Liefran Satrio"
        ),
        eventStatus: .approved,
        slotLeft: 0
    )
]
