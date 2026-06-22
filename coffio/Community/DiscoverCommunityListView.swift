//
//  DiscoverCommunityListView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 22/06/26.
//

import SwiftUI

struct DiscoverCommunityListView: View {
    @StateObject private var viewModel = DiscoverCommunityListViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Search Field Header Block
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                    
                    TextField("Search coffee clubs...", text: $viewModel.searchText)
                        .font(.subheadline)
                        .autocorrectionDisabled()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(hex: "f2efed"))
            
            // MARK: - Content Stream Canvas
            Group {
                if viewModel.isLoading {
                    renderSkeletonList()
                } else if viewModel.isError {
                    renderErrorState()
                } else if viewModel.filteredCommunities.isEmpty {
                    renderEmptyState()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.filteredCommunities, id: \.id) { community in
                                NavigationLink(destination: CommunityDetailView(communityId: community.id)) {
                                    CommunityRowCard(community: community)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "f2efed"))
        }
        .navigationTitle("Communities")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.black)
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .task {
            await viewModel.loadAllCommunities()
        }
        .refreshable {
            await viewModel.loadAllCommunities()
        }
    }
    
    // MARK: - Local Rendering UI Sub-Blocks
    
    private func renderSkeletonList() -> some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(0..<6) { _ in
                    HStack(spacing: 16) {
                        Color.white.frame(width: 64, height: 64).cornerRadius(16)
                        VStack(alignment: .leading, spacing: 8) {
                            Color.white.frame(width: 140, height: 16).cornerRadius(4)
                            Color.white.frame(width: 220, height: 12).cornerRadius(4)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 18).fill(.white))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .shimmering()
    }
    
    private func renderEmptyState() -> some View {
        ContentUnavailableView {
            Label("No Hubs Match", systemImage: "person.3.sequence")
        } description: {
            Text("We couldn't track down that specific coffee group circle. Try looking for another keyword.")
        }
    }
    
    private func renderErrorState() -> some View {
        ContentUnavailableView {
            Label("Sync Interrupted", systemImage: "wifi.exclamationmark")
        } description: {
            Text("Unable to pull database clusters down. Pull down to refresh your terminal connection stream.")
        }
    }
}

// MARK: - CommunityRowCard Sub-Component
struct CommunityRowCard: View {
    let community: CommunityItem
    
    var body: some View {
        HStack(spacing: 16) {
            // 1. Scaled Image Thumbnail Row
            if let imageUrl = community.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color(hex: "fcede1")
                }
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color(hex: "fcede1"))
                    Text(String(community.name.prefix(1)).uppercased())
                        .font(.title3).bold().foregroundStyle(Color(hex: "642e13"))
                }
                .frame(width: 64, height: 64)
            }
            
            // 2. Metadata Context Grid Info
            VStack(alignment: .leading, spacing: 4) {
                Text(community.name)
                    .font(.callout).bold()
                    .foregroundStyle(Color(hex: "642e13"))
                    .lineLimit(1)
                
                if let desc = community.description, !desc.isEmpty {
                    Text(desc)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
            
            // 3. Navigation Indicator Caret Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.gray.opacity(0.6))
                .padding(.trailing, 4)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(.white))
        .shadow(color: .black.opacity(0.02), radius: 6, x: 0, y: 2)
    }
}
