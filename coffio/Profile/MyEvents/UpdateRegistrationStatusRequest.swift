//
//  UpdateRegistrationStatusRequest.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//


struct UpdateRegistrationStatusRequest: Encodable {
    let status: String
    let approvedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case approvedAt = "approved_at"
    }
}