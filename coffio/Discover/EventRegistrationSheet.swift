//
//  EventRegistrationSheet.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 22/04/26.
//

import SwiftUI
import PhotosUI

struct EventRegistrationSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let eventId: String
    let paymentInfo: PaymentInfo?
    var onReservationSuccess: (String) -> Void // 💡 Added callback closure to trigger parent navigation push
    
    @State private var fullName: String = ""
    @State private var contactNumber: String = ""
    @State private var selectionNotes: String = "" // 💡 Added optional notes selection field state
    @State private var isSubmitting: Bool = false  // 💡 Local safety UI submission lock status flag
    
    @EnvironmentObject private var viewModel: DiscoverDetailEventViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24.0) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 6)
                    .padding(.top, 12)
                
                VStack(spacing: 8.0) {
                    Text("Secure Your Slot")
                        .font(.title2)
                        .bold()
                    
                    Text("Please enter your details below to hold your vacancy vacancy reservation slot.")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 16.0) {
                    // Full Name Field
                    inputField(label: "Full Name", placeholder: "Enter your full name", text: $fullName)
                    
                    // Contact Number Field
                    inputField(label: "Contact Number", placeholder: "08xxxxxxx", text: $contactNumber, keyboardType: .phonePad)
                    
                    // Optional Menu Selection Notes Field
                    inputTextArea(label: "Menu Selection / Special Requests", placeholder: "Specify bundle items or beverage preferences (Optional)", text: $selectionNotes)
                }
                .padding(.horizontal, 24)

                // Confirm Action Button Layout Component
                Button(
                    action: {
                        executeFormReservationSubmission()
                    }
                ) {
                    HStack {
                        Spacer()
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Reserve My Slot")
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
                // Form validation requirement: fields must not be empty
                .disabled(fullName.isEmpty || contactNumber.isEmpty || isSubmitting)
                .opacity(fullName.isEmpty || contactNumber.isEmpty || isSubmitting ? 0.6 : 1.0)

                Spacer()
            }
        }
        .background(Color(hex: "f2efed"))
        .coffioPopup(isPresented: $viewModel.isError) {
            VStack {
                Text(viewModel.errorMessage)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .bold()
                
                Button(action: {
                    viewModel.isError = false
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

// MARK: - Core Execution Logic Extension
private extension EventRegistrationSheet {
    
    func executeFormReservationSubmission() {
        isSubmitting = true
        
        let generatedRegistrationId = UUID().uuidString.lowercased()
        let trackingDeadlineString = Date().addingTimeInterval(3600)
        
        Task {
            do {
                try await viewModel.createAwaitingPaymentSlot(
                    id: generatedRegistrationId,
                    eventId: eventId,
                    fullname: fullName,
                    phoneNumber: contactNumber,
                    notes: selectionNotes,
                    deadline: trackingDeadlineString
                )
                
                isSubmitting = false
                
                onReservationSuccess(generatedRegistrationId)
            } catch {
                isSubmitting = false
                viewModel.errorMessage = error.localizedDescription
                viewModel.isError = true
            }
        }
    }
}
