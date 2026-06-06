//
//  SpendingFetcher.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 06/06/26.
//

import Foundation
import Storage
import SwiftUI
import UIKit

final class SpendingFetcher {
    
    func fetchUserSpendings(userId: String) async throws -> [SpendingItemDataModel] {
        let response = try await supabaseClient
            .from("discover_spendings_view")
            .select()
            .eq("userId", value: userId)
            .order("purchaseDate", ascending: false)
            .execute()
            
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let fractionalFormatter = DateFormatter()
            fractionalFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
            if let date = fractionalFormatter.date(from: dateString) { return date }
            
            let plainDateFormatter = DateFormatter()
            plainDateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = plainDateFormatter.date(from: dateString) { return date }
            
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: dateString) { return date }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
        }
        
        return try decoder.decode([SpendingItemDataModel].self, from: response.data)
    }
    
    func insertSpending(request: SpendingLogRequest) async throws {
        try await supabaseClient
            .from("cafe_spendings")
            .insert(request)
            .execute()
    }
    
    /// Uploads the selected receipt proof to Supabase Storage bucket
    func uploadReceipt(uiImage: UIImage, userId: String, spendingId: String) async throws -> String {
        guard let imageData = uiImage.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert receipt image to data"])
        }
        
        let filePath = "\(userId)/receipt_\(spendingId).jpg"
        
        try await supabaseClient.storage
            .from("receipt-proofs")
            .upload(
                filePath,
                data: imageData,
                options: FileOptions(contentType: "image/jpeg", upsert: true)
            )
        
        let publicURL = try supabaseClient.storage
            .from("receipt-proofs")
            .getPublicURL(path: filePath)
            
        return publicURL.absoluteString
    }
}
