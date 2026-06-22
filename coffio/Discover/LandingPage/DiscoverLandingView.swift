//
//  DiscoverLandingView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/06/26.
//

import SwiftUI

struct DiscoverLandingView: View {
    @StateObject private var viewModel = DiscoverLandingViewModel()
    
    // State indicators for deep navigation mapping
    @State private var navigateToAllCafes = false
    @State private var navigateToAllEvents = false
    @State private var navigateToAllCommunities = false
    
    private let cardWidth: CGFloat = 200
    private let cardHeight: CGFloat = 250

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // MARK: - Section 1: Standout Highlighted Events
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader(title: "Featured Events", actionTitle: "See All") {
                            navigateToAllEvents = true
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if viewModel.isLoading {
                                    ForEach(0..<3) { _ in
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.gray.opacity(0.12))
                                            .frame(width: cardWidth, height: cardHeight)
                                    }
                                } else {
                                    ForEach(viewModel.topEvents, id:\.id) { event in
                                        NavigationLink(destination: DiscoverDetailEventView(eventId: event.id, event: event)) {
                                            DiscoverLandingEventCard(dataModel: event)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    
                                    // Sized "See More" Card Component
                                    seeMoreCard(width: cardWidth, height: cardHeight, action: { navigateToAllEvents = true })
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    communitySection
                    
                    // MARK: - Section 2: Top 10 Coffee Shops
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader(title: "Top Coffee Shops", actionTitle: "See All") {
                            navigateToAllCafes = true
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if viewModel.isLoading {
                                    ForEach(0..<3) { _ in
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.gray.opacity(0.12))
                                            .frame(width: 260, height: 100)
                                    }
                                } else {
                                    ForEach(viewModel.topCoffeeShops, id:\.id) { shop in
                                        // Update to target your detailed coffee shop overview sheet or navigation link destination
                                        DiscoverLandingCoffeeShopCard(dataModel: shop)
                                    }
                                    
                                    seeMoreCard(width: 260, height: 100, action: { navigateToAllCafes = true })
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                        }
                        .frame(height: 120)
                    }
                }
            }
            .background(Color(hex: "f2efed")) // Keeping brand background structure uniform
            .navigationTitle("Discover")
            .refreshable {
                await viewModel.loadDashboardContent()
            }
            .task {
                await viewModel.loadDashboardContent()
            }
            // Hidden navigation destination bindings managed by headers and tail cards
            .navigationDestination(isPresented: $navigateToAllCafes) {
                DiscoverFrontCardListView()
            }
            .navigationDestination(isPresented: $navigateToAllEvents) {
                DiscoverEventListView()
            }
            .navigationDestination(isPresented: $navigateToAllCommunities) {
                DiscoverCommunityListView() // 💡 Your dedicated list screen
            }
        }
    }
    
    @ViewBuilder
    var communitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Coffee Communities", actionTitle: "See All") {
                navigateToAllCommunities = true
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    if viewModel.isLoading {
                        ForEach(0..<4) { _ in
                            VStack(spacing: 8) {
                                Circle().fill(.gray.opacity(0.12)).frame(width: 68, height: 68)
                                RoundedRectangle(cornerRadius: 4).fill(.gray.opacity(0.12)).frame(width: 60, height: 12)
                            }
                        }
                    } else {
                        ForEach(viewModel.topCommunities, id: \.id) { community in
                            NavigationLink(destination: CommunityDetailView(communityId: community.id)) {
                                VStack(spacing: 8) {
                                    // Community Avatar Circle Card
                                    if let imageUrl = community.imageUrl, let url = URL(string: imageUrl) {
                                        AsyncImage(url: url) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            Color(hex: "fcede1")
                                        }
                                        .frame(width: 68, height: 68)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                                    } else {
                                        ZStack {
                                            Circle().fill(Color(hex: "fcede1"))
                                            Text(String(community.name.prefix(1)).uppercased())
                                                .font(.headline).bold().foregroundStyle(Color(hex: "642e13"))
                                        }
                                        .frame(width: 68, height: 68)
                                    }
                                    
                                    // Title Text
                                    Text(community.name)
                                        .font(.caption).bold()
                                        .foregroundStyle(Color(hex: "642e13"))
                                        .lineLimit(1)
                                        .frame(width: 76)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Custom Tiny Circular "See More" implementation for avatars
                        Button { navigateToAllCommunities = true } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle().fill(.white)
                                    Image(systemName: "arrow.forward")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(Color(hex: "ad6928"))
                                }
                                .frame(width: 68, height: 68)
                                .overlay(Circle().stroke(Color(hex: "ad6928").opacity(0.15), lineWidth: 1))
                                
                                Text("See More")
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: "ad6928"))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 2)
            }
        }
    }
    
    // MARK: - Layout Subviews
    
    private func sectionHeader(title: String, actionTitle: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.title3)
                .bold()
                .foregroundStyle(Color(hex: "642e13"))
            Spacer()
            Button(action: action) {
                Text(actionTitle)
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(Color(hex: "ad6928"))
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func seeMoreCard(width: CGFloat, height: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: "arrow.forward.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color(hex: "ad6928"))
                
                Text("See More")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "642e13"))
            }
            .frame(width: width, height: height)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "ad6928").opacity(0.1), lineWidth: 1)
            )
        }
    }
}
