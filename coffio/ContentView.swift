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
            Text("Home")
                .tabItem {
                    Image(selectedTab == 0 ? "ic_hot_coffee_orange" : "ic_hot_coffee_black")
                    Text("Home")
                }
                .tag(0)

            Text("Discover")
                .tabItem {
                    Image(selectedTab == 1 ? "ic_pin_orange" : "ic_pin_black")
                    Text("Discover")
                }
                .tag(1)
            
            Text("Spending")
                .tabItem {
                    Image(selectedTab == 2 ? "ic_bill_orange" : "ic_bill_black")
                    Text("Spending")
                }
                .tag(2)
            
            Text("Events")
                .tabItem {
                    Image(selectedTab == 3 ? "ic_calendar_orange" : "ic_calendar_black")
                    Text("Spending")
                }
                .tag(3)
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
}
