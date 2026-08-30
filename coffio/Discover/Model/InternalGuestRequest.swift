//
//  InternalGuestRequest.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 30/08/26.
//


struct DiscoverInternalGuestRequest: JSONEncodable {
    let id: String
    let eventId: String
    let guestName: String
    let guestEmail: String?
    let guestPhone: String?
    let notes: String?
    let addedBy: String

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case guestName = "guest_name"
        case guestEmail = "guest_email"
        case guestPhone = "guest_phone"
        case notes
        case addedBy = "added_by"
    }
}
