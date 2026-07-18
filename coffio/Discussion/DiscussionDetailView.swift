//
//  DiscussionDetailView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/05/26.
//

import SwiftUI

struct DiscussionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DiscussionDetailViewModel
    
    init(
        threadId: String,
        thread: DiscussionThreadItem? = nil,
        detailViewModelDelegate: DiscussionDetailViewModelDelegate? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: DiscussionDetailViewModel(
                threadId: threadId,
                initialThread: thread,
                detailViewModelDelegate: detailViewModelDelegate
            )
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "f2efed").ignoresSafeArea()
            
            VStack(spacing: 0) {
                if let thread = viewModel.thread {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            headerView(thread)
                            
                            Text(thread.title)
                                .font(.title2)
                                .bold()
                            
                            Text(thread.content)
                                .font(.body)
                                .lineSpacing(4)
                            
                            Text(thread.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Divider()
                            
                            if viewModel.isLoading {
                                ProgressView().padding()
                            } else {
                                ForEach(viewModel.comments) { comment in
                                    commentRow(comment)
                                }
                            }
                        }
                        .padding(20)
                        .padding(.bottom, 80)
                    }
                } else {
                    ProgressView()
                }
            }
            
            stickyCommentInput
        }
        .navigationBarBackButtonHidden()
        .task { await viewModel.fetchDetails() }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left").foregroundStyle(.black)
                }
            }
        }
        .sheet(item: Binding(
            get: { viewModel.activeReportTarget != nil ? ReportTargetContainer(target: viewModel.activeReportTarget!) : nil },
            set: { newValue in viewModel.activeReportTarget = newValue?.target }
        )) { container in
            reportReasonSelectionSheet(for: container.target.type)
        }
        .alert("Thank You", isPresented: $viewModel.showReportSuccessAlert) {
            Button("OK", role: .cancel) {
                // ⚡️ Automatically pop the user back out to the main timeline feed
                dismiss()
            }
        } message: {
            Text("We have received your report and will review it within 24 hours. Action will be taken if terms are violated.")
        }
    }
    
    // MARK: - Subviews
    
    private func headerView(_ thread: DiscussionThreadItem) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: thread.user.avatarUrl ?? "")) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.2))
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(thread.user.fullName ?? "User").font(.headline)
                Text("@\(thread.user.username ?? "user")").font(.subheadline).foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // UGC Moderation Access Context Dropdown
            Menu {
                Button(role: .destructive) {
                    viewModel.activeReportTarget = (type: .post, userId: thread.user.id, threadId: thread.id)
                } label: {
                    Label("Report Post", systemImage: "flag")
                }
                
                Button(role: .destructive) {
                    viewModel.activeReportTarget = (type: .user, userId: thread.user.id, threadId: nil)
                } label: {
                    Label("Report User Account", systemImage: "person.crop.circle.badge.exclam")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(8)
            }
        }
    }
    
    private func reportReasonSelectionSheet(for type: ReportType) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Why are you reporting this \(type == .post ? "post" : "user")?")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                List(ReportReason.reasons(for: type)) { reason in
                    HStack {
                        Text(reason.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                        if viewModel.selectedReason == reason {
                            Image(systemName: "checkmark")
                                .bold()
                                .foregroundColor(Color(hex: "ad6928"))
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectedReason = reason
                    }
                }
                .listStyle(.plain)
                
                Button(action: {
                    Task {
                        await viewModel.submitReport()
                    }
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isReporting {
                            ProgressView().tint(.white)
                        } else {
                            Text("Submit Report")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .frame(height: 50)
                    .background(Color(hex: "ad6928"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                }
                .disabled(viewModel.isReporting)
            }
            .navigationTitle("Report Content")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        viewModel.activeReportTarget = nil
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // Existing components preserved below ...
    private func commentRow(_ comment: DiscussionCommentItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: comment.user.avatarUrl ?? "")) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.2))
            }
            .frame(width: 36, height: 36)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.user.fullName ?? "User").font(.subheadline).bold()
                    Text("•").foregroundStyle(.secondary)
                    Text(comment.createdAt.formatted(.dateTime.day().month().hour().minute()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(comment.content).font(.subheadline)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var stickyCommentInput: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .bottom, spacing: 12) {
                TextField("Post your reply", text: $viewModel.commentText, axis: .vertical)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .lineLimit(1...5)
                    .disabled(viewModel.isSubmitting)
                
                Button(action: {
                    Task { await viewModel.submitComment() }
                }) {
                    ZStack {
                        if viewModel.isSubmitting {
                            ProgressView().tint(.white).scaleEffect(0.8)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .background(
                        Circle().fill(viewModel.commentText.isEmpty || viewModel.isSubmitting ? Color.gray.opacity(0.5) : Color(hex: "ad6928"))
                    )
                }
                .disabled(viewModel.commentText.isEmpty || viewModel.isSubmitting)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.white)
        }
    }
}

// MARK: - Identifiable Wrapper for Sheet Presentation Target
struct ReportTargetContainer: Identifiable {
    var id: String {
        "\(target.type.rawValue)_\(target.userId)_\(target.threadId ?? "none")"
    }
    
    let target: (type: ReportType, userId: String, threadId: String?)
}
