//
//  CoffioPopupModifier.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 25/04/26.
//


import SwiftUI

struct CoffioPopupModifier<PopupContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let popupContent: () -> PopupContent

    func body(content: Content) -> some View {
        ZStack {
            // Main View Content
            content
                .disabled(isPresented) // Disable interaction when popup is up

            if isPresented {
                // 1. Dimmed Background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)

                // 2. Popup Card
                VStack(spacing: 0) {
                    popupContent()
                }
                .padding(24)
                .background(Color(hex: "f2efed")) // Matching your sheet background
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 40) // Standard margins
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPresented)
    }
}

// Easy-to-use View Extension
extension View {
    func coffioPopup<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(CoffioPopupModifier(isPresented: isPresented, popupContent: content))
    }
}
