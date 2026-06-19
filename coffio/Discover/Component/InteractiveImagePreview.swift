//
//  InteractiveImagePreview.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 19/06/26.
//

import SwiftUI

struct InteractiveImagePreview: View {
    let imageUrl: String?
    @Binding var isPresented: Bool
    
    // Gesture States for Zooming & Dragging
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // 1. Dark Dimmed Backdrop Canvas
            Color.black
                .opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    // Close preview when tapping the dark background area
                    withAnimation(.easeOut(duration: 0.25)) {
                        isPresented = false
                    }
                }
            
            // 2. Main Image Presentation Layer
            if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            // Applies the interactive zoom transform alterations
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                // Combines zoom pinch gestures and drag tracking side-by-side
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        // Restricts excessive zooming thresholds
                                        scale = min(max(scale * delta, 1.0), 4.0)
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                        if scale < 1.0 {
                                            withAnimation(.spring()) {
                                                scale = 1.0
                                                offset = .zero
                                                lastOffset = .zero
                                            }
                                        }
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in
                                        // Only permit panning behavior if the user is currently zoomed in
                                        guard scale > 1.0 else { return }
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            // Double-tap shortcut to reset zoom level immediately
                            .onTapGesture(count: 2) {
                                withAnimation(.spring()) {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                        
                    case .failure, .empty:
                        ProgressView().tint(.white)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // 3. Absolute Pinned Exit/Close Interface Button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding()
                    }
                }
                Spacer()
            }
        }
        // Prevents layout shifting animations under other tabs while active
        .transition(.opacity) 
    }
}
