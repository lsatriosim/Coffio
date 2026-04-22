//
//  EventFetcher.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import Foundation

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
}
