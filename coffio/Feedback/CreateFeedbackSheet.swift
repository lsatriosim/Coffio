//
//  CreateFeedbackSheet.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 12/09/26.
//

import SwiftUI
import PhotosUI

struct CreateFeedbackSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateFeedbackViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 6)
                    .padding(.top, 12)
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // 1. Report Type Selector Picker Block
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Feedback Type")
                                .font(.caption).bold()
                                .foregroundStyle(.gray)
                            
                            Picker("Report Type", selection: $viewModel.reportType) {
                                ForEach(FeedbackType.allCases) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        
                        // 2. Description Text Field Block
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Description")
                                .font(.caption).bold()
                                .foregroundStyle(.gray)
                            
                            ZStack(alignment: .topLeading) {
                                if viewModel.description.isEmpty {
                                    Text("Describe the bug or share your suggestion here...")
                                        .foregroundStyle(Color.gray.opacity(0.6))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                                
                                TextEditor(text: $viewModel.description)
                                    .frame(minHeight: 120)
                                    .scrollContentBackground(.hidden)
                            }
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        
                        // 3. Document/Photo Upload Picker Field (Max 3 files)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Attach Screenshots (Optional)")
                                    .font(.caption).bold()
                                    .foregroundStyle(.gray)
                                Spacer()
                                Text("\(viewModel.selectedImages.count)/3")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            
                            if viewModel.selectedImages.count < 3 {
                                photoPickerField
                            }
                            
                            // Image Previews Grid with Delete Option
                            if !viewModel.selectedImages.isEmpty {
                                imagePreview
                            }
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        
                        // 4. Action Layer
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else {
                            Button {
                                viewModel.submitFeedback()
                            } label: {
                                Text("Submit Feedback")
                                    .font(.body).bold()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(viewModel.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color(hex: "ad6928"))
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(viewModel.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .background(Color(hex: "f2efed"))
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "ad6928"))
                }
            }
            .coffioPopup(isPresented: Binding(
                get: { viewModel.errorMessage != "" },
                set: { if !$0 { viewModel.errorMessage = "" } }
            )) {
                VStack(spacing: 16) {
                    Text(viewModel.errorMessage)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .bold()
                        .multilineTextAlignment(.center)
                 
                    Button(action: {
                        viewModel.errorMessage = ""
                    }) {
                        HStack {
                            Text("Close")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .padding(.vertical, 12.0)
                        .padding(.horizontal, 16.0)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "ad6928"))
                                .shadow(color: .black.opacity(0.1), radius: 10)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .coffioPopup(isPresented: $viewModel.showNotificationPopUp) {
                VStack(spacing: 16) {
                    Text("Thank you for submitting your feedback!")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .bold()
                        .multilineTextAlignment(.center)
                 
                    Button(action: {
                        viewModel.showNotificationPopUp = false
                        dismiss()
                    }) {
                        HStack {
                            Text("Close")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .padding(.vertical, 12.0)
                        .padding(.horizontal, 16.0)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "ad6928"))
                                .shadow(color: .black.opacity(0.1), radius: 10)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    @ViewBuilder
    var photoPickerField: some View {
        PhotosPicker(
            selection: $viewModel.selectedPhotoItems,
            maxSelectionCount: 3 - viewModel.selectedImages.count,
            matching: .images
        ) {
            HStack {
                Image(systemName: "photo.badge.plus")
                    .foregroundStyle(Color(hex: "ad6928"))
                Text("Choose Images (Max 3)")
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "f9f8f7")))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
        }
        .onChange(of: viewModel.selectedPhotoItems) { _, newItems in
            viewModel.addImages(from: newItems)
        }
    }
    
    @ViewBuilder
    var imagePreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Button {
                            viewModel.removeImage(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white, .black.opacity(0.6))
                                .padding(4)
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
    }
}
