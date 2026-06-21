//
//  CommunityItem.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 21/06/26.
//

import Foundation

struct CommunityItem: Identifiable, JSONDecodable {
    let id: String
    let name: String
    let description: String?
    let imageUrl: String?
    let createdBy: UUID?
    let createdAt: Date
    let whatsappUrl: String?
    let discordUrl: String?
    let instagramUrl: String?
    let facebookUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl = "image_url"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case whatsappUrl = "whatsapp_url"
        case discordUrl = "discord_url"
        case instagramUrl = "instagram_url"
        case facebookUrl = "facebook_url"
    }
}
