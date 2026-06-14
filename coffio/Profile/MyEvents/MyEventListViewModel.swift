//
//  MyEventListViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//


//
//  MyEventListViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//

import SwiftUI
import Supabase

@MainActor
final class MyEventListViewModel: ObservableObject {
    // published state properties matching coffio architectural patterns
    @Published var events: [MyEventCardDataModel] = []
    @Published var isLoading = false
    @Published var isError = false
    @Published var errorMessage = ""
    
    /// Entrypoint trigger lifecycle method
    func onViewDidLoad() {
        guard events.isEmpty else { return }
        Task {
            await fetchUserCreatedEvents()
        }
    }
    
    /// Pulls current session uid context and fetches mapped UI models from Supabase view source
    func fetchUserCreatedEvents() async {
        isLoading = true
        isError = false
        
        do {
            // Retrieve current authenticated session profile user ID
            guard let currentUserId = supabaseClient.auth.currentUser?.id.uuidString else {
                throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User session not found. Please log in again."])
            }
            
            // Execute view network data fetch
            let rawItems = try await fetchEvent(authorId: currentUserId)
            
            // Map models cleanly into the dedicated UI Presentation structure format
            self.events = rawItems.map { item in
                MyEventCardDataModel(
                    id: item.id,
                    title: item.title,
                    startDate: item.eventDate,
                    endDate: item.endDate,
                    location: item.cafeName ?? "Venue Partner",
                    address: item.location ?? "No structural address provided"
                )
            }
        } catch {
            self.errorMessage = error.localizedDescription
            self.isError = true
        }
        
        self.isLoading = false
    }
    
    // MARK: - Supabase Query Request Layer
    private func fetchEvent(authorId: String) async throws -> [DiscoverEventItem] {
        let response = try await supabaseClient
            .from("discover_events_view")
            .select()
            .eq("created_by", value: authorId)
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
                debugDescription: "Invalid date representation: \(string)"
            )
        }
        
        return try decoder.decode([DiscoverEventItem].self, from: response.data)
    }
}
