//
//  CommunityFetcherProtocol.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 21/06/26.
//

import Foundation
import Supabase

protocol CommunityFetcherProtocol {
    func fetchCommunity(by id: String) async throws -> CommunityItem
    func fetchPosts(for communityId: String) async throws -> [CommunityPostItem]
    func fetchCommunityDetail(by communityId: String) async throws -> CommunityDetailItem
    func fetchCommunityEvents(communityId: String) async throws -> [DiscoverEventItem]
}

final class CommunityFetcher: CommunityFetcherProtocol {
    /// Fetches a specific community model by its UUID primary key string
    func fetchCommunity(by id: String) async throws -> CommunityItem {
        let response = try await supabaseClient
            .from("communities")
            .select()
            .eq("id", value: id.lowercased())
            .single() // 💡 Automatically unpacks single row JSON payload instead of an array
            .execute()
        
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        // Handles optional fractional seconds from Postgres timestamp columns securely
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            
            // Try standard internet timestamp formatting, fallback to non-fractional fallback
            if let date = formatter.date(from: string) { return date }
            
            let backupFormatter = ISO8601DateFormatter()
            backupFormatter.formatOptions = [.withInternetDateTime]
            if let date = backupFormatter.date(from: string) { return date }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date parsing configuration format threshold: \(string)"
            )
        }
        
        return try decoder.decode(CommunityItem.self, from: response.data)
    }
    
    func fetchPosts(for communityId: String) async throws -> [CommunityPostItem] {
        return try await supabaseClient
            .from("community_posts")
            .select("*, profiles:user_id(full_name)")
            .eq("community_id", value: communityId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    func fetchCommunityDetail(by communityId: String) async throws -> CommunityDetailItem {
        return try await supabaseClient
            .from("community_detail_view")
            .select()
            .eq("id", value: communityId)
            .single()
            .execute()
            .value
    }
    
    func fetchCommunityEvents(communityId: String) async throws -> [DiscoverEventItem] {
        let response = try await supabaseClient
            .from("discover_events_view")
            .select()
            .eq("community_info->>id", value: communityId)
            .eq("status", value: "approved")
            .order("event_date", ascending: false)
            .execute()
        
        // Match the exact custom JSON ISO8601 date handling strategy you used in EventFetcher
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = formatter.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(string)")
        }
        
        return try decoder.decode([DiscoverEventItem].self, from: response.data)
    }
}
