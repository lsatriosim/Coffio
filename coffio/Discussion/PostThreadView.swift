//
//  PostThreadView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/05/26.
//

import SwiftUI

struct PostThreadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var isPosting: Bool = false
    
    let fetcher = DiscussionFetcher()
    let onPostSuccess: () async -> Void
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    // Placeholder Avatar
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    VStack(spacing: 12) {
                        TextField("Title of your discussion", text: $title)
                            .font(.headline)
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                            .overlay(alignment: .topLeading) {
                                if content.isEmpty {
                                    Text("What's on your mind?")
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 8)
                                }
                            }
                    }
                }
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.black)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        submitThread()
                    } label: {
                        if isPosting {
                            ProgressView().tint(.white)
                        } else {
                            Text("Post").bold()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "ad6928"))
                    .disabled(title.isEmpty || content.isEmpty || isPosting)
                    .clipShape(Capsule())
                }
            }
        }
    }
    
    private func submitThread() {
        guard let userId = AuthenticationService.shared.user?.id else { return }
        isPosting = true
        
        Task {
            do {
                let request = CreateThreadRequest(
                    userId: userId,
                    title: title,
                    content: content,
                    tag: "general" // Default tag
                )
                try await fetcher.postThread(request: request)
                await onPostSuccess()
                dismiss()
            } catch {
                print("Error posting thread: \(error)")
            }
            isPosting = false
        }
    }
}
