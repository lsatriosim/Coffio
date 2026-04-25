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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Main Content
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView()
                }
                .tag(0)
                .toolbar(.hidden, for: .tabBar) // Hide native bar
                
                Text("Connect View")
                    .tag(1)
                    .toolbar(.hidden, for: .tabBar)
                
                Text("Spending Menu")
                    .tag(2)
                    .toolbar(.hidden, for: .tabBar)
                
                ProfileView()
                    .tag(3)
                    .toolbar(.hidden, for: .tabBar)
            }
            
            // MARK: - Floating Glass Tab Bar
            customFloatingTabBar
        }
        .fullScreenCover(isPresented: $authService.showAuthPage) {
            LoginView()
        }
    }
    
    private var customFloatingTabBar: some View {
        HStack(spacing: 0) {
            tabButton(id: 0, icon: selectedTab == 0 ? "ic_pin_orange" : "ic_pin_black", label: "Discover")
            tabButton(id: 1, systemIcon: "bubble", label: "Connect")
            tabButton(id: 2, icon: selectedTab == 2 ? "ic_bill_orange" : "ic_bill_black", label: "Spending")
            tabButton(id: 3, systemIcon: "person", label: "Profile")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            Capsule()
                .fill(.ultraThinMaterial) // Liquid Glass Base
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        }
        .overlay {
            // The "Refraction" Edge
            Capsule()
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.6), .clear, .white.opacity(0.2)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing),
                    lineWidth: 0.5
                )
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24) // Floats it above the Home Indicator
    }
    
    @ViewBuilder
    private func tabButton(id: Int, icon: String? = nil, systemIcon: String? = nil, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = id
            }
        } label: {
            VStack(spacing: 4) {
                if let iconName = icon {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                } else if let systemName = systemIcon {
                    Image(systemName: systemName)
                        .font(.system(size: 20))
                }
                
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(selectedTab == id ? Color.orange : .secondary)
            .padding(.vertical, 8)
            .background {
                if selectedTab == id {
                    Capsule()
                        .fill(.white.opacity(0.4)) // The "inner liquid" highlight
                        .matchedGeometryEffect(id: "TAB_INDICATOR", in: animation)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
