//
//  DiscussionDetailViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/05/26.
//


import SwiftUI

@MainActor
final class DiscussionDetailViewModel: ObservableObject {
    @Published var thread: DiscussionThreadItem?
    @Published var comments: [DiscussionCommentItem] = []
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var commentText: String = ""
    @Published var isSubmitting: Bool = false
    
    private let fetcher = DiscussionFetcher()
    private let authService = AuthenticationService.shared
    let threadId: String
    
    init(threadId: String, initialThread: DiscussionThreadItem? = nil) {
        self.threadId = threadId
        self.thread = initialThread
    }
    
    func fetchDetails() async {
        if thread == nil { isLoading = true }
        await fetchComments()
        self.isLoading = false
    }
    
    func fetchComments() async {
        do {
            self.comments = try await fetcher.fetchComments(for: threadId)
        } catch {
            print("Error fetching comments: \(error)")
            self.isError = true
        }
    }
    
    func submitComment() async {
        guard !commentText.trimmingCharacters(in: .whitespaces).isEmpty,
              let userId = authService.user?.id else { return }
        
        isSubmitting = true
        
        let request = CommentRequest(
            threadId: threadId.lowercased(),
            userId: userId.lowercased(),
            content: commentText,
            parentCommentId: nil
        )
        
        do {
            try await fetcher.postComment(request: request)
            
            self.commentText = ""
            await fetchComments() // Refetch the list
        } catch {
            print("Error submitting comment: \(error)")
            self.isError = true
        }
        
        isSubmitting = false
    }
}
