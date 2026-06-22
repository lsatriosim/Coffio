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
    let communityInfo: CommunityInfo?
    let ownerPhone: String?
    let ownerEmail: String?
    
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
        case communityInfo = "community_info"
        case ownerPhone = "owner_phone"
        case ownerEmail = "owner_email"
    }
}

struct CommunityInfo: JSONDecodable {
    let id: String
    let name: String
    let description: String?
    let imageUrl: String?
    let whatsappUrl: String?
    let discordUrl: String?
    let instagramUrl: String?
    let facebookUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case imageUrl = "image_url"
        case whatsappUrl = "whatsapp_url"
        case discordUrl = "discord_url"
        case instagramUrl = "instagram_url"
        case facebookUrl = "facebook_url"
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
