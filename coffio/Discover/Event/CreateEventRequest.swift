//
//  CreateEventRequest.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 13/06/26.
//


struct CreateEventRequest: Encodable {
    let title: String
    let description: String?
    let imageUrl: String?            // Event Poster Storage Link
    let menuImageUrl: String?        // Menu Selection Storage Link
    let eventDate: String            // ISO8601 Start Timestamp
    let endDate: String?             // ISO8601 End Timestamp
    let cafeName: String?
    let location: String?            // Full Structural Street Address
    let capacity: Int?
    let registrationType: String     // 'internal' or 'external'
    let price: Int?
    let bankName: String?
    let bankAccount: String?
    let bankHolder: String?
    let createdBy: String?           // Host User Profile ID link

    enum CodingKeys: String, CodingKey {
        case title, description, price, capacity, location
        case imageUrl = "image_url"
        case menuImageUrl = "menu_image_url"
        case eventDate = "event_date"
        case endDate = "end_date"
        case cafeName = "cafe_name"
        case registrationType = "registration_type"
        case bankName = "bank_name"
        case bankAccount = "bank_account"
        case bankHolder = "bank_holder"
        case createdBy = "created_by"
    }
}