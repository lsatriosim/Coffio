//
//  CommunityDetailItem.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 21/06/26.
//

import Foundation

struct CommunityDetailItem: Identifiable, JSONDecodable {
    let id: String
    let name: String
    let description: String?
    let imageUrl: String?
    let whatsappUrl: String?
    let discordUrl: String?
    let instagramUrl: String?
    let facebookUrl: String?
    let memberCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case imageUrl = "image_url"
        case whatsappUrl = "whatsapp_url"
        case discordUrl = "discord_url"
        case instagramUrl = "instagram_url"
        case facebookUrl = "facebook_url"
        case memberCount = "member_count"
    }
}

struct CommunityPostItem: Identifiable, JSONDecodable {
    let id: String
    let communityId: String
    let userId: String
    let category: String
    let title: String
    let content: String
    let createdAt: Date
    let authorName: String? // 💡 Extracted from profile joins
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, category
        case communityId = "community_id"
        case userId = "user_id"
        case createdAt = "created_at"
        case authorName = "author_name"
    }
}
