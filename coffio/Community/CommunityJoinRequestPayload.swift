//
//  CommunityJoinRequestPayload.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 24/06/26.
//

enum CommunityJoinRequestStatus: String, JSONCodable {
    case pending = "pending"
    case approved = "approved"
}

struct CommunityJoinRequestPayload: JSONCodable {
    let communityId: String
    let userId: String
    let status: CommunityJoinRequestStatus
    
    enum CodingKeys: String, CodingKey {
        case communityId = "community_id"
        case userId = "user_id"
        case status
    }
}
