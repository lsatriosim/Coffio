//
//  CommunityDetailView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 21/06/26.
//

import SwiftUI

struct CommunityDetailView: View {
    @StateObject private var viewModel: CommunityDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(communityId: String) {
        _viewModel = StateObject(wrappedValue: CommunityDetailViewModel(communityId: communityId))
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                if viewModel.isLoading {
                    renderSkeleton()
                } else if viewModel.isError {
                    renderErrorState()
                } else if let community = viewModel.community {
                    renderHeaderSection(community)
                    renderSocialsRow(community)
                    renderEventsSection()
                    renderPostsSection()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(Color(hex: "f2efed").ignoresSafeArea())
        .navigationTitle("Community")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(.black)
                }
            }
        }
        .task {
            await viewModel.loadPageData()
        }
    }
    
    // MARK: - Component Renders
    
    private func renderHeaderSection(_ community: CommunityDetailItem) -> some View {
        HStack(spacing: 16) {
            if let imageUrl = community.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color(hex: "fcede1")
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 18).fill(Color(hex: "fcede1"))
                    Text(String(community.name.prefix(1)).uppercased())
                        .font(.title2).bold().foregroundStyle(Color(hex: "642e13"))
                }
                .frame(width: 72, height: 72)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(community.name)
                    .font(.title2).bold()
                    .foregroundStyle(Color(hex: "642e13"))
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                    Text("\(community.memberCount) members")
                        .font(.subheadline).bold()
                }
                .foregroundStyle(Color(hex: "ad6928"))
            }
        }
    }
    
    private func renderSocialsRow(_ community: CommunityDetailItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let desc = community.description {
                Text(desc)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)
            }
            
            HStack(spacing: 12) {
                SocialButton(type: .whatsapp, urlString: community.whatsappUrl)
                SocialButton(type: .discord, urlString: community.discordUrl)
                SocialButton(type: .instagram, urlString: community.instagramUrl)
            }
        }
    }
    
    private func renderEventsSection() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Upcoming Events")
                .font(.headline)
                .foregroundStyle(Color(hex: "642e13"))
            
            if viewModel.events.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                        .foregroundStyle(.gray.opacity(0.7))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("No active events planned")
                            .font(.subheadline).bold()
                            .foregroundStyle(.primary)
                        Text("Check back later for community gatherings.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(.white))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(viewModel.events, id:\.id) { event in
                            DiscoverLandingEventCard(dataModel: event)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func renderPostsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Community Discussions")
                .font(.headline)
                .foregroundStyle(Color(hex: "642e13"))
            
            if viewModel.posts.isEmpty {
                // Expanded Clean Empty State Container Module
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 44))
                        .foregroundStyle(.gray.opacity(0.5))
                    Text("No posts yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Be the first to share an insight or question with this community group.")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(RoundedRectangle(cornerRadius: 20).fill(.white))
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.posts) { post in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(post.category.uppercased())
                                    .font(.caption2).bold()
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Capsule().fill(Color(hex: "fcede1")))
                                    .foregroundStyle(Color(hex: "642e13"))
                                Spacer()
                                Text(post.createdAt.timeAgoDisplay())
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                            }
                            
                            Text(post.title)
                                .font(.body).bold()
                                .foregroundStyle(.primary)
                            
                            Text(post.content)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 20).fill(.white))
                    }
                }
            }
        }
    }
    
    private func renderSkeleton() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 16) {
                Color.white.frame(width: 72, height: 72).cornerRadius(18)
                VStack(alignment: .leading, spacing: 8) {
                    Color.white.frame(width: 160, height: 20).cornerRadius(4)
                    Color.white.frame(width: 90, height: 14).cornerRadius(4)
                }
            }
            Color.white.frame(height: 44).cornerRadius(12)
            VStack(spacing: 14) {
                ForEach(0..<3) { _ in
                    Color.white.frame(height: 110).cornerRadius(20)
                }
            }
        }
        .shimmering()
    }
    
    private func renderErrorState() -> some View {
        ContentUnavailableView("Connection Failed", systemImage: "wifi.exclamationmark", description: Text("Unable to stream community channels."))
    }
}

// MARK: - Supporting Embedded Sub-Components

private enum SocialType {
    case whatsapp, discord, instagram
    var icon: String {
        switch self {
        case .whatsapp: return "phone.circle.fill"
        case .discord: return "bubble.left.and.right.circle.fill"
        case .instagram: return "camera.circle.fill"
        }
    }
}

private struct SocialButton: View {
    let type: SocialType
    let urlString: String?
    
    var body: some View {
        if let urlString, let url = URL(string: urlString) {
            Link(destination: url) {
                HStack(spacing: 6) {
                    Image(systemName: type.icon)
                    Text(String(describing: type).capitalized)
                        .font(.footnote).bold()
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Capsule().fill(.white))
                .foregroundStyle(Color(hex: "642e13"))
            }
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
