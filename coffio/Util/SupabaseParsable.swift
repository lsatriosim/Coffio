//
//  SupabaseParsable.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 09/06/26.
//

import Foundation

protocol SupabaseParsable {}

extension SupabaseParsable {
    /// Generates a standardized JSONDecoder capable of parsing both standard ISO8601 targets
    /// and microsecond high-precision timestamps from Supabase postgres views.
    func makeSupabaseJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // 1. Try microsecond parsing sequence (e.g., yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ)
            let fractionalFormatter = DateFormatter()
            fractionalFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
            if let date = fractionalFormatter.date(from: dateString) {
                return date
            }
            
            // 2. Fallback sequence for standard ISO8601 targets
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unexpected date registration string token encountered: \(dateString)"
            )
        }
        
        return decoder
    }
}
