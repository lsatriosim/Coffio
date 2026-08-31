//
//  EventRegistrationResponse.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 30/08/26.
//

import Foundation

 struct EventRegistrationResponse: JSONDecodable {
    let id: String
    let status: EventRegistrationStatus
    let paymentDeadlineTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case paymentDeadlineTime = "payment_deadline_at"
    }
}
