//
//  CoffioPhotoPickerField.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//

import SwiftUI
import PhotosUI

struct CoffioPhotoPickerField: View {
    let label: String
    let placeholder: String
    
    // Core structural inputs
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var selectedImage: Image?
    var remoteUrlString: String? = nil
    
    // Internal view state control context
    @State private var isPickerPresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 4)

            // Interactive Selector Bar Trigger
            Button {
                isPickerPresented = true
            } label: {
                HStack {
                    Image(systemName: "photo")
                        .foregroundStyle(Color(hex: "ad6928"))

                    let hasAsset = (selectedImage != nil || remoteUrlString != nil)
                    Text(hasAsset ? "Change image selection" : placeholder)
                        .foregroundStyle(hasAsset ? .primary : Color.gray)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                .padding(12)
                .background(fieldBackground)
            }
            .buttonStyle(.plain)
            .photosPicker(
                isPresented: $isPickerPresented,
                selection: $selectedItem,
                matching: .images
            )
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    if let loaded = try? await newValue?.loadTransferable(type: Image.self) {
                        await MainActor.run {
                            self.selectedImage = loaded
                        }
                    }
                }
            }
            
            // Standardized Aspect-Fit Uncropped Rendering Engine Layout Box
            if let selectedImage {
                renderImageContainer {
                    selectedImage
                        .resizable()
                        .scaledToFit()
                }
            } else if let remoteUrlString, let url = URL(string: remoteUrlString) {
                renderImageContainer {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure, .empty:
                            Color.gray.opacity(0.1)
                                .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
        }
    }
    
    // Encapsulated structural layout frame view decorator to ensure unified presentation styling
    @ViewBuilder
    private func renderImageContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            Color.white
            content()
                .frame(maxHeight: 180)
                .padding(8)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.top, 4)
    }
    
    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.02), radius: 4)
    }
}
