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
}
