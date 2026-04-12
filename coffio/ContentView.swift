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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
                .tabItem {
                    Image(selectedTab == 0 ? "ic_pin_orange" : "ic_pin_black")
                    Text("Discover")
                }
                .tag(0)
            
            Text("Connect")
                .tabItem {
                    Image(systemName: "bubble")
                        .foregroundStyle(selectedTab == 1 ? .orange : .black)
                    Text("Connect")
                }
                .tag(1)
            
            Text("Spending Menu")
                .tabItem {
                    Image(selectedTab == 2 ? "ic_bill_orange" : "ic_bill_black")
                    Text("Spending")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                        .foregroundStyle(selectedTab == 3 ? .orange : .black)
                    Text("Profile")
                }
                .tag(3)
        }
        .tint(.orange)
        .fullScreenCover(isPresented: $authService.showAuthPage) {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
