//
//  ReportType.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 16/07/26.
//

import Foundation

enum ReportType: String, JSONEncodable {
    case post
    case user
    case event
}

enum ReportReason: String, CaseIterable, Identifiable {
    case spam = "Spam or Scams"
    case harassment = "Harassment or Bullying"
    case hateSpeech = "Hate Speech or Discrimination"
    case inappropriateContent = "Inappropriate Content"
    case incorrectInfo = "Misleading or Fake Information" // Good for Events
    case canceledEvent = "Event does not exist / Canceled" // Good for Events

    var id: String { self.rawValue }

    static func reasons(for type: ReportType) -> [ReportReason] {
        switch type {
        case .post, .user:
            return [.spam, .harassment, .hateSpeech, .inappropriateContent]
        case .event:
            return [.spam, .inappropriateContent, .incorrectInfo, .canceledEvent]
        }
    }
}

struct ReportRequest: JSONEncodable {
    let reporterId: String
    let reportType: ReportType
    let reason: String
    var threadId: String? = nil
    var reportedUserId: String? = nil
    var eventId: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case reporterId = "reporter_id"
        case reportType = "report_type"
        case reason
        case threadId = "thread_id"
        case reportedUserId = "reported_user_id"
        case eventId = "event_id"
    }
}

struct UserReportItem: JSONDecodable {
    let reporterId: String
    let reportType: String
    let threadId: String?
    let reportedUserId: String?

    enum CodingKeys: String, CodingKey {
        case reporterId = "reporter_id"
        case reportType = "report_type"
        case threadId = "thread_id"
        case reportedUserId = "reported_user_id"
    }
}
