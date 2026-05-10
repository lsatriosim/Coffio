//
//  CreateThreadRequest.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/05/26.
//


struct CreateThreadRequest: Encodable {
    let userId: String
    let title: String
    let content: String
    let tag: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case title, content, tag
    }
}
