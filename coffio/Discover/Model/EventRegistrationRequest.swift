//
//  EventRegistrationRequest.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 22/04/26.
//

import Foundation

struct EventRegistrationRequest: JSONEncodable {
    let id: String
    let eventId: String
    let userId: String
    let userPhone: String
    let userName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case userId = "user_id"
        case userPhone = "user_phone"
        case userName = "user_name"
    }
}
