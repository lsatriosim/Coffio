//
//  EventRegistrationItem.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 29/04/26.
//

import Foundation
import SwiftUI

struct EventRegistrationItem: JSONDecodable {
    let id: String
    let eventDetail: EventRegistrationEventDetail
    let registeredAt: Date
    let status: RegistrationStatus
    let cancelReason: String?
    let menuNotes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventDetail = "event_detail"
        case registeredAt = "registered_at"
        case status
        case cancelReason = "cancel_reason"
        case menuNotes = "menu_notes"
    }
    
    enum RegistrationStatus: String, JSONDecodable {
        case approved
        case paymentSubmitted = "payment_submitted"
        case expired
        case pending
    }
    
    struct EventRegistrationEventDetail: JSONDecodable {
        let id: String
        let title: String
        let location: String
        let eventDate: Date
        let endDate: Date
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case location
            case eventDate = "event_date"
            case endDate = "end_date"
        }
    }
}

extension EventRegistrationItem.RegistrationStatus {
    var color: Color {
        switch self {
        case .approved: return .green
        case .paymentSubmitted: return .blue
        case .pending: return .orange
        case .expired: return .gray
        }
    }
    
    var displayName: String {
        switch self {
        case .approved: return "Approved"
        case .paymentSubmitted: return "Payment Submitted"
        case .expired: return "Expired"
        case .pending: return "Pending"
        }
    }
}

