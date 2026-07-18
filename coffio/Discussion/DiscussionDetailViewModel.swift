//
//  DiscussionDetailViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/05/26.
//


import SwiftUI

protocol DiscussionDetailViewModelDelegate: AnyObject {
    func notifyToUpdateThreads()
}

@MainActor
final class DiscussionDetailViewModel: ObservableObject {
    weak var delegate: DiscussionDetailViewModelDelegate?
    
    @Published var thread: DiscussionThreadItem?
    @Published var comments: [DiscussionCommentItem] = []
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var commentText: String = ""
    @Published var isSubmitting: Bool = false
    
    @Published var activeReportTarget: (type: ReportType, userId: String, threadId: String?)? = nil
    @Published var selectedReason: ReportReason = .spam
    @Published var isReporting: Bool = false
    @Published var showReportSuccessAlert: Bool = false
    
    private let fetcher = DiscussionFetcher()
    private let reportFetcher = ReportFetcher()
    private let authService = AuthenticationService.shared
    let threadId: String
    
    init(
        threadId: String,
        initialThread: DiscussionThreadItem? = nil,
        detailViewModelDelegate: DiscussionDetailViewModelDelegate? = nil
    ) {
        self.threadId = threadId
        self.thread = initialThread
        self.delegate = detailViewModelDelegate
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
    
    func submitReport() async {
        guard let target = activeReportTarget,
              let currentUserId = authService.user?.id else { return }
        
        isReporting = true
        
        let request = ReportRequest(
            reporterId: currentUserId.lowercased(),
            reportType: target.type,
            reason: selectedReason.rawValue,
            threadId: target.threadId?.lowercased(),
            reportedUserId: target.userId.lowercased(),
            eventId: nil
        )
        
        do {
            try await reportFetcher.submitReport(request: request)
            
            self.activeReportTarget = nil
            self.showReportSuccessAlert = true
            self.delegate?.notifyToUpdateThreads()
            
            // ⚡️ IMMEDIATELY HIDE/DISMISS CONTENT LOCALLY FOR THE USER
            if target.type == .post {
                // If they reported the thread itself, clear it so the view handles the missing state or dismisses
                self.thread = nil
            } else if target.type == .user {
                // If they reported the account user, strip all comments written by that user instantly
                self.comments.removeAll { $0.user.id == target.userId }
                
                // If the main poster is the one reported, remove the thread context
                if self.thread?.user.id == target.userId {
                    self.thread = nil
                }
            }
            
        } catch {
            print("Error submitting report: \(error)")
            self.isError = true
        }
        
        isReporting = false
    }
}
