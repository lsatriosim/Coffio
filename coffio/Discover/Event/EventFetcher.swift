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

final class EventFetcher: SupabaseParsable {
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
    
    func fetchTopEvents(limit: Int) async throws -> [DiscoverEventItem] {
        let response = try await supabaseClient
            .from("discover_events_view")
            .select()
            .limit(limit)
            .execute()
        
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

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
    
    func fetchEvent(authorId: String) async throws -> [DiscoverEventItem] {
        let response = try await supabaseClient
            .from("discover_events_view")
            .select()
            .eq("created_by", value: authorId) // Filter by the current user
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
    
    func fetchEvent(from: Int, to: Int) async throws -> [DiscoverEventItem] {
        let response = try await supabaseClient
            .from("discover_events_view")
            .select()
            .range(from: from, to: to) // 💡 Tells PostgreSQL view to only slice out this batch window
            .execute()
        
        let decoder = makeSupabaseJSONDecoder()
        return try decoder.decode([DiscoverEventItem].self, from: response.data)
    }
    
    func registerEvent(request: EventRegistrationRequest) async throws {
        try await supabaseClient
            .from("event_registrations")
            .insert(request)
            .execute()
    }
    
    func uploadPaymentProof(
        image: Data,
        eventId: String,
        userId: String
    ) async throws -> String {
        let filePath = "\(eventId)/\(userId).jpg"
        
        try await supabaseClient.storage
            .from("payment-proofs")
            .upload(
                filePath,
                data: image,
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
    
    func uploadEventAsset(imageData: Data, fileName: String) async throws -> String {
        let uniqueId = UUID().uuidString
        let filePath = "assets/\(UUID().uuidString)_\(fileName).jpg"
        
        try await supabaseClient.storage
            .from("event-images")
            .upload(
                filePath,
                data: imageData,
                options: FileOptions(
                    contentType: "image/jpeg",
                    upsert: true
                )
            )
        
        let publicURL = try supabaseClient.storage
            .from("event-images")
            .getPublicURL(path: filePath)
            
        return publicURL.absoluteString
    }

    func createEvent(request: CreateEventRequest) async throws {
        try await supabaseClient
            .from("events")
            .insert(request)
            .execute()
    }
    
    func updateEvent(id: String, request: UpdateEventRequest) async throws {
        try await supabaseClient
            .from("events")        // 💡 Targeting the mutable source table
            .update(request)
            .eq("id", value: id)   // Isolates transaction to this single event row
            .execute()
    }
}

//MARK: Registration
extension EventFetcher {
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
    
    func fetchAllRegistrationsAcrossView() async throws -> [EventRegistrationItem] {
        let response = try await supabaseClient
            .from("view_event_registration_items")
            .select()
            .execute()
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let fractionalFormatter = DateFormatter()
            fractionalFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
            if let date = fractionalFormatter.date(from: dateString) {
                return date
            }
            
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        
        return try decoder.decode([EventRegistrationItem].self, from: response.data)
    }
    
    func fetchRegistrationsForEvent(eventId: String) async throws -> [EventRegistrationItem] {
        // Query the updated view with the joined user profiles
        let response = try await supabaseClient
            .from("view_event_registration_items")
            .select()
            .execute()
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // 1. Try format with fractional seconds (standard Supabase timestamp)
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
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        
        // Decode all items from the response payload
        let allRegistrations = try decoder.decode([EventRegistrationItem].self, from: response.data)
        
        // Filter out items matching this specific event instance
        return allRegistrations.filter { $0.eventDetail.id == eventId }
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
    
    func approveRegistration(id: String) async throws {
        // Formulate request updating status string and timestamp log context
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let currentTimestamp = formatter.string(from: Date())
        
        let request = UpdateRegistrationStatusRequest(
            status: "approved",
            approvedAt: currentTimestamp
        )
        
        try await supabaseClient
            .from("event_registrations")
            .update(request)
            .eq("id", value: id)
            .execute()
    }
    
    func rejectRegistration(id: String) async throws {
        let request = UpdateRegistrationStatusRequest(
            status: "rejected",
            approvedAt: nil
        )
        
        try await supabaseClient
            .from("event_registrations")
            .update(request)
            .eq("id", value: id)
            .execute()
    }
}
