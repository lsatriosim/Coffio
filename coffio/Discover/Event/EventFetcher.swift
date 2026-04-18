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
        
        if let jsonString = String(data: response.data, encoding: .utf8) {
            print("📦 Raw Response:")
            print(jsonString)
        }

        // Pretty print JSON (better readability)
        if let jsonObject = try? JSONSerialization.jsonObject(with: response.data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("📦 Pretty JSON:")
            print(prettyString)
        }
        
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
}
