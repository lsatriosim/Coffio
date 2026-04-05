//
//  ContentView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/03/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(selectedTab == 0 ? "ic_pin_orange" : "ic_pin_black")
                    Text("Discover")
                }
                .tag(0)
            
            Text("Spending Menu")
                .tabItem {
                    Image(selectedTab == 1 ? "ic_bill_orange" : "ic_bill_black")
                    Text("Spending")
                }
                .tag(1)
            
            Text("Profile Menu")
                .tabItem {
                    Image(systemName: "person")
                        .foregroundStyle(selectedTab == 2 ? .orange : .black)
                    Text("Profile")
                }
                .tag(2)
        }
        .tint(.orange)
        .task {
            do {
                try await AuthenticationService.shared.login(email: "Liefran123@gmail.com", password: "Abun2002")
            }
            catch {
                print("[AuthService]: \(error)" )
            }
        }
    }
}

#Preview {
    ContentView()
}
