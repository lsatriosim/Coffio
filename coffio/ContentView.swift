//
//  ContentView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/03/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var navigationRouter: AppNavigationRouter
    
    @Namespace private var animation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Main Content
            // 2. Bind the TabView directly to the router's published selectedTab
            TabView(selection: $navigationRouter.selectedTab) {
                Tab("Discover", systemImage: "cup.and.saucer", value: 0) {
                    NavigationStack(path: $navigationRouter.discoverPath) {
                        DiscoverLandingView()
                            .navigationDestination(for: AppNavigationRouter.DiscoverDestination.self) { route in
                                switch route {
                                case .eventDetail:
                                    Text("migrated")
                                }
                            }
                    }
                }
                
                Tab("Connect", systemImage: "bubble.left.and.bubble.right", value: 1) {
                    NavigationStack {
                        DiscussionListView()
                    }
                }
                
                Tab("Spending", systemImage: "wallet.bifold", value: 2) {
                    NavigationStack {
                        SpendingTrackerView()
                    }
                }
                
                Tab("Profile", systemImage: "person.circle", value: 3) {
                    NavigationStack {
                        ProfileView()
                    }
                }
            }
            .tint(Color(hex: "ad6928"))
        }
        .fullScreenCover(isPresented: $authService.showAuthPage) {
            LoginView()
        }
        .onChange(of: navigationRouter.discoverPath) { oldPath, newPath in
            print("➡️ ContentView detected path change: \(newPath)")
        }
    }
}
