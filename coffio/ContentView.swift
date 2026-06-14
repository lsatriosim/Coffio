//
//  ContentView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/03/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authService: AuthenticationService
    @Namespace private var animation // For the smooth sliding highlight
    @SceneStorage("selectedTab") private var selectedTabIndex = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Main Content
            TabView(selection: $selectedTab) {
                Tab("Discover", systemImage: "cup.and.saucer", value: 0) {
                    NavigationStack {
                        HomeView()
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
                    ProfileView()
                }
            }
            .tint(Color(hex: "ad6928"))
        }
        .fullScreenCover(isPresented: $authService.showAuthPage) {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
