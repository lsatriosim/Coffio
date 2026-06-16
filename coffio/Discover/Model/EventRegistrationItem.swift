//
//  EventRegistrationItem.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//

import Foundation
import SwiftUI

struct EventRegistrationItem: JSONDecodable, Identifiable {
    let id: String
    let eventDetail: EventRegistrationEventDetail
    let userProfile: UserProfileDetail
    let registeredAt: Date
    let status: RegistrationStatus
    let cancelReason: String?
    let menuNotes: String?
    let paymentProofUrl: String?
    let paymentDeadlineAt: Date?
    let paymentSubmittedAt: Date?
    let referralCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventDetail = "event_detail"
        case userProfile = "user_profile"
        case registeredAt = "registered_at"
        case status
        case cancelReason = "cancel_reason"
        case menuNotes = "menu_notes"
        case paymentProofUrl = "payment_proof_url"
        case paymentDeadlineAt = "payment_deadline_at"
        case paymentSubmittedAt = "payment_submitted_at"
        case referralCode = "referral_code"
    }
    
    enum RegistrationStatus: String, JSONDecodable {
        case approved
        case paymentSubmitted = "payment_submitted"
        case awaitingPayment = "awaiting_payment"
        case rejected
        case expired
        case pending
        case cancelled
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

    struct UserProfileDetail: JSONDecodable {
        let fullName: String?
        let email: String?
        
        enum CodingKeys: String, CodingKey {
            case fullName = "full_name"
            case email
        }
        
        var safeName: String { fullName ?? "Unknown User" }
        var safeEmail: String { email ?? "No Email Provided" }
    }
}

extension EventRegistrationItem.RegistrationStatus {
    var color: Color {
        switch self {
        case .approved: return .green
        case .paymentSubmitted: return .blue
        case .pending: return .orange
        case .awaitingPayment: return .gray
        case .expired, .rejected, .cancelled: return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .approved: return "Approved"
        case .paymentSubmitted: return "Payment Submitted"
        case .expired: return "Expired"
        case .pending: return "Pending"
        case .awaitingPayment: return "Awaiting Payment"
        case .rejected: return "Rejected"
        case .cancelled: return "Cancelled"
        }
    }
}
