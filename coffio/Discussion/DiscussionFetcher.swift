//
//  DiscussionFetcher.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/05/26.
//


import Foundation

final class DiscussionFetcher {
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // 1. Try format with fractional seconds (Supabase default)
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
        return decoder
    }()

    /// Get list of all threads from the view
    func fetchThreads() async throws -> [DiscussionThreadItem] {
        let response = try await supabaseClient
            .from("discussion_threads_with_user")
            .select()
            .order("created_at", ascending: false)
            .execute()
        
        return try decoder.decode([DiscussionThreadItem].self, from: response.data)
    }

    /// Get list of comments for a specific thread
    /// This includes the user profile and reply counts
    func fetchComments(for threadId: String) async throws -> [DiscussionCommentItem] {
        let response = try await supabaseClient
            .from("discussion_comments_with_user")
            .select()
            .eq("thread_id", value: threadId)
            .order("created_at", ascending: true)
            .execute()
        
        return try decoder.decode([DiscussionCommentItem].self, from: response.data)
    }
    
    /// Optional: Fetch only top-level comments for a thread
    func fetchTopLevelComments(for threadId: String) async throws -> [DiscussionCommentItem] {
        let response = try await supabaseClient
            .from("discussion_comments_with_user")
            .select()
            .eq("thread_id", value: threadId)
            .is("parent_comment_id", value: nil)
            .order("created_at", ascending: true)
            .execute()
        
        return try decoder.decode([DiscussionCommentItem].self, from: response.data)
    }
    
    func postComment(request: CommentRequest) async throws {
        try await supabaseClient
            .from("discussion_comments")
            .insert(request)
            .execute()
    }
    
    func postThread(request: CreateThreadRequest) async throws {
        try await supabaseClient
            .from("discussion_threads")
            .insert(request)
            .execute()
    }
}
