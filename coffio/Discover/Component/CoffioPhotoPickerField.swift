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
    
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var selectedImage: Image?
    @Binding var selectedData: Data? // 💡 Add this binding to extract raw data cleanly
    var remoteUrlString: String? = nil
    
    @State private var isPickerPresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 4)

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
            .photosPicker(isPresented: $isPickerPresented, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    if let rawData = try? await newValue?.loadTransferable(type: Data.self) {
                        
                        if let decodedUIImage = UIImage(data: rawData),
                           let pristineJPEGData = decodedUIImage.jpegData(compressionQuality: 0.5) {
                            
                            await MainActor.run {
                                self.selectedData = pristineJPEGData
                                self.selectedImage = Image(uiImage: decodedUIImage)
                            }
                        }
                    }
                }
            }
            
            // Preview rendering logic remains here...
            if let selectedImage {
                renderImageContainer {
                    selectedImage.resizable().scaledToFit()
                }
            } else if let remoteUrlString, let url = URL(string: remoteUrlString) {
                renderImageContainer {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFit()
                        } else {
                            Color.gray.opacity(0.1).overlay(Image(systemName: "photo").foregroundStyle(.gray))
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func renderImageContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxHeight: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            .padding(.top, 4)
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.white)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}
