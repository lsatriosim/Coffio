//
//  DiscoverInternalGuestRegistrationSheet.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 30/08/26.
//

import SwiftUI

struct DiscoverInternalGuestRegistrationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DiscoverInternalGuestRegistrationViewModel
    
    init(eventId: String, guestToEdit: DiscoverInternalGuestItem? = nil, delegate: DiscoverInternalGuestRegistrationViewModelDelegate?) {
        _viewModel = StateObject(wrappedValue: DiscoverInternalGuestRegistrationViewModel(
            eventId: eventId,
            guestToEdit: guestToEdit,
            delegate: delegate
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24.0) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 6)
                    .padding(.top, 12)
                
                VStack(spacing: 8.0) {
                    Text(viewModel.isEditing ? "Edit Internal Guest" : "Daftar Internal Guest")
                        .font(.title2)
                        .bold()
                    
                    Text("Daftarkan tamu internal atau panitia secara manual untuk event ini.")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 16.0) {
                    // Full Name Field
                    inputField(label: "Full Name", placeholder: "Masukkan nama lengkap tamu", text: $viewModel.guestName)
                    
                    // Email Address Field
                    inputField(label: "Email Address", placeholder: "cth: nama@email.com", text: $viewModel.guestEmail, keyboardType: .emailAddress)
                        .textInputAutocapitalization(.never)
                    
                    // Phone Number Field
                    inputField(label: "Phone Number", placeholder: "cth: 08123456789", text: $viewModel.guestPhone, keyboardType: .phonePad)
                    
                    // Optional Notes Field
                    inputTextArea(label: "Notes (Opsional)", placeholder: "Catatan tambahan (Opsional)", text: $viewModel.note)
                }
                .padding(.horizontal, 24)

                // Confirm Action Button Layout Component
                Button(
                    action: {
                        Task {
                            let isSuccess = await viewModel.saveInternalGuest()
                            if isSuccess {
                                dismiss()
                            }
                        }
                    }
                ) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text(viewModel.isEditing ? "Update Guest" : "Register Guest")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .bold()
                        }
                        Spacer()
                    }
                    .padding(.vertical, 16.0)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "ad6928"))
                            .shadow(color: .black.opacity(0.1), radius: 10)
                    }
                }
                .padding(.horizontal, 24)
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
                .opacity(!viewModel.isFormValid || viewModel.isLoading ? 0.6 : 1.0)

                Spacer()
            }
        }
        .background(Color(hex: "f2efed"))
        .coffioPopup(isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            VStack(spacing: 16) {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .bold()
                        .multilineTextAlignment(.center)
                }
             
                Button(action: {
                    viewModel.errorMessage = nil
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

    @ViewBuilder
    private func inputField(label: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 4)
            
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textFieldStyle(.plain)
                .padding(12.0)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.02), radius: 4)
                }
        }
    }
    
    @ViewBuilder
    private func inputTextArea(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 4)
            
            TextEditor(text: text)
                .frame(minHeight: 100)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.02), radius: 4)
                }
                .overlay(alignment: .topLeading) {
                    if text.wrappedValue.isEmpty {
                        Text(placeholder)
                            .font(.body)
                            .foregroundStyle(.gray.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
}
