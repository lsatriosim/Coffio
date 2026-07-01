//
//  UploadTransactionRequest.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 01/07/26.
//

import Foundation

struct UploadTransactionRequest: JSONEncodable {
    let id: String = UUID().uuidString.lowercased()
    let userId: String
    let eventId: String
    let registrationId: String
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case eventId = "event_id"
        case registrationId = "registration_id"
        case imageUrl = "image_url"
    }
}
