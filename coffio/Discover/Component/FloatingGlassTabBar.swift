//
//  FloatingGlassTabBar.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 25/04/26.
//

import SwiftUI

struct FloatingGlassTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation
    
    let tabs = [
        (icon: "ic_pin", label: "Discover"),
        (icon: "bubble.left.and.bubble.right", label: "Connect"),
        (icon: "ic_bill", label: "Spending"),
        (icon: "person.crop.circle", label: "Profile")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        // Use your custom asset or fallback to systemName
                        if tabs[index].icon.hasPrefix("ic_") {
                            Image("\(tabs[index].icon)\(selectedTab == index ? "_orange" : "_black")")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        } else {
                            Image(systemName: tabs[index].icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(selectedTab == index ? .orange : .primary.opacity(0.6))
                        }
                        
                        Text(tabs[index].label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(selectedTab == index ? .orange : .primary.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        if selectedTab == index {
                            // The "Apple Style" selection: Very subtle light lift
                            Capsule()
                                .fill(.white.opacity(0.35))
                                .matchedGeometryEffect(id: "SELECTED_TAB", in: animation)
                                .padding(.horizontal, 4)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            // Stronger material for that premium Luma feel
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 15, y: 10)
        }
        .overlay {
            // Extremely thin bezel to catch light
            Capsule()
                .stroke(.white.opacity(0.3), lineWidth: 0.5)
        }
        .padding(.horizontal, 16) // Wider bar looks more native than the narrow capsule
        .padding(.bottom, 12)      // Tighter to the bottom for seamlessness
    }
}
