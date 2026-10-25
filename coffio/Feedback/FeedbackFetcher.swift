//
//  FeedbackFetcher.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 12/09/26.
//

import FactoryKit
import Foundation
import Storage
import SwiftUI

final class FeedbackFetcher {
    @Injected(\.networkService) private var networkService

    /// Submits feedback to your Go backend API (/api/feedback)
    func submitFeedback(
        reporterId: String,
        reportType: String,
        description: String,
        images: [Data],
        imageNames: [String]
    ) async throws {
        // Step 1: Upload images first if any are provided
        let uploadedURLs = try await uploadFeedbackImages(images: images, fileNames: imageNames)
        
        // Step 2: Construct the request payload matching your Go backend struct
        let payload = FeedbackRequest(
            reporterId: reporterId,
            reportType: reportType,
            description: description,
            imageURLs: uploadedURLs
        )
        
        // Step 3: Send to Go Backend via NetworkService (POST /api/feedback)
        // Note: NetworkService handles JSON encoding, headers, and Bearer token injection automatically.
        let _: EmptyResponse? = try await networkService.request(
            endpoint: "/feedback",
            method: "POST",
            body: payload
        )
    }
}

private extension FeedbackFetcher {
    /// Uploads multiple images to the Supabase storage bucket and returns their public URLs
    func uploadFeedbackImages(images: [Data], fileNames: [String]) async throws -> [String] {
        var publicURLs: [String] = []
        
        for (index, imageData) in images.enumerated() {
            let originalName = index < fileNames.count ? fileNames[index] : "image"
            let filePath = "feedback/\(UUID().uuidString)_\(originalName).jpg"
            
            // 1. Upload to Supabase Storage bucket "feedback-images"
            try await supabaseClient.storage
                .from("feedback-images")
                .upload(
                    filePath,
                    data: imageData,
                    options: FileOptions(
                        contentType: "image/jpeg",
                        upsert: true
                    )
                )
            
            // 2. Retrieve public URL for the uploaded asset
            let publicURL = try supabaseClient.storage
                .from("feedback-images")
                .getPublicURL(path: filePath)
            
            publicURLs.append(publicURL.absoluteString)
        }
        
        return publicURLs
    }
}

// Helper struct if your backend returns an empty/generic response body on success
struct EmptyResponse: Decodable {}
