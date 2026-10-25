//
//  AddCoffeeView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/10/26.
//

import PhotosUI
import SwiftUI

struct AddCoffeeView: View {
    let targetDate: Date
    var onSave: () -> Void

    @StateObject private var viewModel = AddCoffeeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Pickers and Source Selection States
    @State private var showCameraPicker: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var showPhotoSourceSelection: Bool = false

    private let primaryBrown = Color(hex: "ad6928")

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24.0) {
                    // Header Title
                    VStack(spacing: 8.0) {
                        Text("New Coffee Sip")
                            .font(.title2)
                            .bold()
                        
                        Text("Log your coffee consumption and extract its sticker cutout")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    // Form Inputs Container
                    VStack(alignment: .leading, spacing: 20.0) {
                        
                        // 1. Coffee Details
                        inputField(
                            label: "Coffee Name",
                            placeholder: "e.g., Caramel Latte",
                            text: $viewModel.coffeeName
                        )
                        
                        inputField(
                            label: "Price (IDR)",
                            placeholder: "e.g., 10000",
                            text: $viewModel.priceString,
                            keyboardType: .numberPad
                        )

                        // 2. Interactive Pressable Photo Preview Card
                        VStack(alignment: .leading, spacing: 4.0) {
                            Text("Coffee Photo & Sticker")
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .padding(.leading, 4)

                            Button(action: {
                                showPhotoSourceSelection = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                        .shadow(color: .black.opacity(0.02), radius: 4)
                                        .frame(height: 220)

                                    if viewModel.isExtractionLoading {
                                        VStack(spacing: 8) {
                                            ProgressView()
                                                .tint(primaryBrown)
                                            Text("Extracting coffee sticker...")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    } else if let cutout = viewModel.cutoutImage {
                                        VStack(spacing: 8) {
                                            Image(uiImage: cutout)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 150)
                                                .shadow(color: .white, radius: 2)
                                                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                                            
                                            Text("Tap to change photo")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    } else if let original = viewModel.originalImage {
                                        VStack(spacing: 8) {
                                            Image(uiImage: original)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 150)
                                                .cornerRadius(8)
                                            
                                            Text("Tap to change photo")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    } else {
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.viewfinder")
                                                .font(.system(size: 36))
                                                .foregroundColor(primaryBrown)
                                            Text("Tap to add coffee photo")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Submit Action Button
                    VStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .padding(.vertical, 12)
                        } else {
                            Button(action: {
                                Task {
                                    await viewModel.saveCoffeeLog(for: targetDate) {
                                        onSave()
                                        dismiss()
                                    }
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Save Coffee Log")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(isFormInvalid ? Color.gray.opacity(0.4) : primaryBrown)
                                .cornerRadius(12)
                            }
                            .disabled(isFormInvalid)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .background(Color(hex: "f2efed"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showCameraPicker) {
                CameraPicker(selectedImage: $viewModel.cameraImage)
            }
            // Corrected PhotosPicker binding using isPresented
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $viewModel.selectedLibraryItem,
                matching: .images
            )
            // Source Selection Popup (Camera vs Gallery)
            .coffioPopup(isPresented: $showPhotoSourceSelection) {
                VStack(spacing: 16) {
                    Text("Select Photo Source")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    VStack(spacing: 10) {
                        Button(action: {
                            showPhotoSourceSelection = false
                            showCameraPicker = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(primaryBrown)
                                Text("Take a Photo")
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            showPhotoSourceSelection = false
                            showPhotoPicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .foregroundColor(primaryBrown)
                                Text("Choose from Library")
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }

                    Button(action: {
                        showPhotoSourceSelection = false
                    }) {
                        Text("Cancel")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(16)
            }
            // Cutout Error Popup Modifier Integration
            .coffioPopup(isPresented: $viewModel.showErrorPopup) {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(primaryBrown)
                    
                    VStack(spacing: 6) {
                        Text(viewModel.errorPopupTitle)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(viewModel.errorPopupSubtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        viewModel.showErrorPopup = false
                    }) {
                        Text(viewModel.errorPopupCTAButtonLabel)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(primaryBrown)
                            .cornerRadius(12)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
}

// MARK: - View Helpers & Subcomponents Extension
private extension AddCoffeeView {
    var isFormInvalid: Bool {
        viewModel.coffeeName.trimmingCharacters(in: .whitespaces).isEmpty ||
        viewModel.priceString.isEmpty ||
        viewModel.cutoutImage == nil ||
        viewModel.isLoading ||
        viewModel.isExtractionLoading
    }

    @ViewBuilder
    func inputField(label: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 4)
            
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textFieldStyle(.plain)
                .padding(12.0)
                .background(fieldBackground)
        }
    }

    var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.02), radius: 4)
    }
}
