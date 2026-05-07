//
//  EventFetcher.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import Foundation
import Storage
import SwiftUI
import UIKit

final class EventFetcher {
    func fetchEvent() async throws -> [DiscoverEventItem] {
        let response = try await supabaseClient
            .from("discover_events_view")
            .select()
            .execute()
        
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime
        ]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            
            if let date = formatter.date(from: string) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(string)"
            )
        }
        
        return try decoder.decode([DiscoverEventItem].self, from: response.data)
    }
    
    func registerEvent(request: EventRegistrationRequest) async throws {
        try await supabaseClient
            .from("event_registrations")
            .insert(request)
            .execute()
    }
    
    func uploadPaymentProof(
        image: Image,
        eventId: String,
        userId: String
    ) async throws -> String {
        guard let uiImage = await image.asUIImage(),
              let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
            throw NSError(
                domain: "ImageConversion",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to convert image"
                ]
            )
        }
        
        let filePath = "\(eventId)/\(userId).jpg"
        
        try await supabaseClient.storage
            .from("payment-proofs")
            .upload(
                filePath,
                data: imageData,
                options: FileOptions(
                    contentType: "image/jpeg",
                    upsert: true
                )
            )
        
        let publicURL = try supabaseClient.storage
            .from("payment-proofs")
            .getPublicURL(path: filePath)
        
        return publicURL.absoluteString
    }
    
    func fetchUserRegistrations(userId: String) async throws -> [EventRegistrationItem] {
        // Querying the view you specified
        let response = try await supabaseClient
            .from("view_event_registration_items")
            .select()
            .eq("user_id", value: userId) // Filter by the current user
            .execute()
        
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // 1. Try format with fractional seconds (standard Supabase format)
            let fractionalFormatter = DateFormatter()
            fractionalFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
            if let date = fractionalFormatter.date(from: dateString) {
                return date
            }
            
            // 2. Fallback to standard ISO8601
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
        }
        
        return try decoder.decode([EventRegistrationItem].self, from: response.data)
    }
    
    func fetchEventById(id: String) async throws -> DiscoverEventItem {
        let response = try await supabaseClient
            .from("discover_events_view")
            .select()
            .eq("id", value: id)
            .limit(1)
            .single() // Ensures we get a single object, not an array
            .execute()
        
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = formatter.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
        
        return try decoder.decode(DiscoverEventItem.self, from: response.data)
    }
    
    func isUserRegistered(eventId: String, userId: String) async throws -> Bool {
        let response = try await supabaseClient
            .from("event_registrations")
            .select("id") // We only need to see if a record exists
            .eq("event_id", value: eventId)
            .eq("user_id", value: userId)
            .limit(1)
            .execute()

        let data = response.data
        
        return !data.isEmpty && data != "[]".data(using: .utf8)
    }
}
