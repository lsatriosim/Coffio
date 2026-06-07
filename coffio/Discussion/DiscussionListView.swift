//
//  DiscussionListView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/05/26.
//


import SwiftUI

struct DiscussionListView: View {
    @StateObject private var viewModel = DiscussionListViewModel()
    @State private var showPostSheet = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                if viewModel.isError {
                    // Reusing your existing error view pattern
                    DiscoverErrorView {
                        Task { await viewModel.fetchThreads() }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if !viewModel.isLoading && viewModel.threads.isEmpty {
                    VStack(spacing: 20) {
                        // Your existing empty state illustration/text
                        EmptyStateView(title: "No Discussion Found", description: "We couldn't find discussion yet. Be the first to open the discussion!")
                        
                        // The Refetch Button based on your reference
                        Button(action: {
                            Task {
                                await viewModel.fetchThreads()
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("Refresh Feed")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Image(systemName: "arrow.clockwise")
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "ad6928")) // Using your signature coffee brown
                        }
                        .padding(.horizontal, 40) // Give it some side padding in the empty state
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    renderThreadList
                }
            }
            
            Button(action: { showPostSheet = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color(hex: "ad6928"))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
            }
            .padding(24)
        }
        .background(Color(hex: "f2efed"))
        .task {
            await viewModel.onViewDidLoad()
        }
        .navigationTitle("Community Threads")
        .sheet(isPresented: $showPostSheet) {
            PostThreadView {
                await viewModel.fetchThreads() // Refresh the list after posting
            }
        }
    }
    
    private var renderThreadList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading {
                    DiscussionThreadCardSkeletonView()
                    DiscussionThreadCardSkeletonView()
                    DiscussionThreadCardSkeletonView()
                }
                else {
                    ForEach(viewModel.threads) { thread in
                        NavigationLink(destination: DiscussionDetailView(threadId: thread.id, thread: thread)) {
                            DiscussionThreadCardView(thread: thread)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 80) // Padding so FAB doesn't hide the last thread
        }
        .refreshable { await viewModel.fetchThreads() }
    }
}

#Preview {
    NavigationStack {
        DiscussionListView()
    }
}
