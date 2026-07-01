//
//  EventRegistrationRequest.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 22/04/26.
//

import Foundation

struct EventRegistrationRequest: Encodable {
    let id: String
    let eventId: String
    let userId: String
    let userPhone: String
    let userName: String
    let notes: String
    let status: String = "awaiting_payment"
    let paymentDeadline: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case userId = "user_id"
        case userPhone = "user_phone"
        case userName = "user_name"
        case notes = "menu_notes"
        case status
        case paymentDeadline = "payment_deadline_at"
    }
}

struct EventPaymentSubmissionPayload: Encodable {
    let status: String = "payment_submitted"
    let paymentSubmittedAt: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case paymentSubmittedAt = "payment_submitted_at"
    }
}
