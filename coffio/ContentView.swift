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
    
    let featureControlService: FeatureControlService = FeatureControlService.sharedInstance
    
    // Feature flag states
    @State private var isSpendingRevampEnabled: Bool = false
    @State private var isLoadingFeature: Bool = true
    
    @Namespace private var animation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Main Content
            TabView(selection: $navigationRouter.selectedTab) {
                Tab("Discover", systemImage: "cup.and.saucer", value: 0) {
                    NavigationStack(path: $navigationRouter.discoverPath) {
                        DiscoverLandingView()
                            .navigationDestination(for: AppNavigationRouter.DiscoverDestination.self) { route in
                                switch route {
                                case .eventDetail(let eventId):
                                    DiscoverDetailEventView(eventId: eventId, event: nil, delegate: nil)
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
                        Group {
                            if isLoadingFeature {
                                ProgressView()
                                    .tint(Color(hex: "ad6928"))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else if isSpendingRevampEnabled {
                                CoffeeCalendarView()
                            } else {
                                SpendingTrackerView()
                            }
                        }
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
        .task {
            // Asynchronously fetch the feature flag status when ContentView appears
            isSpendingRevampEnabled = await featureControlService.isSpendingRevampEnabled()
            isLoadingFeature = false
        }
        .onChange(of: navigationRouter.discoverPath) { oldPath, newPath in
            print("➡️ ContentView detected path change: \(newPath)")
        }
    }
}
