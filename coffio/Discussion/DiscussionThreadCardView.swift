//
//  DiscussionThreadCardView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/05/26.
//


import SwiftUI

struct DiscussionThreadCardView: View {
    let thread: DiscussionThreadItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // 1. Avatar (X-style placement)
                AsyncImage(url: URL(string: thread.user.avatarUrl ?? "")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.2))
                        .overlay(Text(thread.user.username?.prefix(1).uppercased() ?? "?").font(.caption).bold())
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    // 2. Header Info
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(thread.user.fullName ?? "Anonymous")
                            .font(.subheadline)
                            .bold()
                            .lineLimit(1)
                        
                        if let username = thread.user.username {
                            Text("@\(username.lowercased())")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(thread.createdAt.formatted(.dateTime.day().month()))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        // Tag styling from your reference
                        Text(thread.tag.replacingOccurrences(of: "-", with: " ").capitalized)
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                    }
                    
                    // 3. Thread Content
                    Text(thread.title)
                        .font(.headline)
                        .bold()
                        .padding(.top, 2)
                    
                    Text(thread.content)
                        .font(.subheadline)
                        .foregroundStyle(.primary.opacity(0.8))
                        .lineLimit(3)
                        .padding(.top, 2)
                    
                    // 4. Interaction Bar (X-style footer)
                    HStack(spacing: 20) {
                        Label("\(thread.commentCount)", systemImage: "bubble.left")
                        Spacer()
//                        Image(systemName: "square.and.arrow.up")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct DiscussionThreadCardSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                
                // 1. Avatar Placeholder
                Circle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(width: 44, height: 44)
                    .shimmering()
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    // 2. Header Information Line Placeholder
                    HStack(alignment: .center, spacing: 6) {
                        // Full name token
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 90, height: 12)
                            .shimmering()
                        
                        // Username token
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 55, height: 10)
                            .shimmering()
                        
                        Spacer()
                        
                        // Right-aligned Tag Pill Capsule
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 50, height: 18)
                            .shimmering()
                    }
                    
                    // 3. Thread Title Placeholder
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 180, height: 14)
                        .padding(.top, 4)
                        .shimmering()
                    
                    // 4. Multi-Line Body Content Mock
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.18))
                            .frame(maxWidth: .infinity, maxHeight: 11)
                            .shimmering()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.18))
                            .frame(maxWidth: .infinity, maxHeight: 11)
                            .shimmering()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.18))
                            .frame(width: 130, height: 11)
                            .shimmering()
                    }
                    .padding(.top, 4)
                    
                    // 5. Interaction Footer Bar
                    HStack {
                        // Comment metric grouping placeholder
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 40, height: 12)
                            .shimmering()
                        
                        Spacer()
                    }
                    .padding(.top, 12)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
