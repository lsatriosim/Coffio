//
//  CoffeeFetcher.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/10/26.
//

import Foundation
import FactoryKit
import Storage

final class CoffeeLogFetcher: SupabaseParsable {
    @Injected(\.networkService) private var networkService

    func fetchCoffeeLogs() async throws -> [CoffeeLogDTO] {
        do {
            let response = try await supabaseClient
                .from("coffee_logs")
                .select()
                .order("consumed_at", ascending: false)
                .execute()
            
            let decoder = JSONDecoder()
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]

            let fallbackFormatter = ISO8601DateFormatter()
            fallbackFormatter.formatOptions = [.withInternetDateTime]

            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let string = try container.decode(String.self)

                // 1. Try parsing with fractional seconds
                if let date = formatter.date(from: string) {
                    return date
                }
                
                // 2. Fallback to standard internet datetime format
                if let date = fallbackFormatter.date(from: string) {
                    return date
                }

                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid date: \(string)"
                )
            }

            return try decoder.decode([CoffeeLogDTO].self, from: response.data)
        }
        catch {
            print(error)
            return []
        }
    }

    func insertCoffeeLog(_ log: CoffeeLogDTO) async throws {
        try await supabaseClient
            .from("coffee_logs")
            .insert(log)
            .execute()
    }
    
    func uploadCoffeeCutout(
        image: Data,
        filePath: String
    ) async throws -> String {
        try await supabaseClient.storage
            .from("coffee-logs")
            .upload(
                filePath,
                data: image,
                options: FileOptions(
                    contentType: "image/png",
                    upsert: false
                )
            )
         
        let publicURL = try supabaseClient.storage
            .from("coffee-logs")
            .getPublicURL(path: filePath)
         
        return publicURL.absoluteString
    }
}
