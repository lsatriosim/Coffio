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
    @State private var fullName: String = ""
    @State private var contactNumber: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    @State private var selectedImage: Image?
    
    @State private var showPhotoPicker = false
    
    @EnvironmentObject var viewModel: DiscoverEventListViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24.0) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 6)
                    .padding(.top, 12)
                
                VStack(spacing: 8.0) {
                    Text("Event Registration")
                        .font(.title2)
                        .bold()
                    
                    Text("Please fill in your details to join")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 16.0) {
                    if let paymentInfo {
                        PaymentInfoCardView(paymentInfo: paymentInfo)
                    }
                    
                    // Full Name Field
                    inputField(label: "Full Name", placeholder: "Enter your full name", text: $fullName)
                    
                    // Contact Number Field
                    inputField(label: "Contact Number", placeholder: "08xxxxxxx", text: $contactNumber, keyboardType: .phonePad)
                    
                    photoPickerField()
                }
                .padding(.horizontal, 24)

                Button(
                    action: {
                        guard let selectedImage else { return }
                        viewModel.registerEvent(
                            eventId: eventId,
                            fullname: fullName,
                            phoneNumber: contactNumber,
                            paymentProofImage: selectedImage
                        ) {
                        dismiss()
                    }
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(.circular)
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        else {
                            Text("Confirm Registration")
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
                .disabled(fullName.isEmpty || contactNumber.isEmpty || selectedPhotoItem == nil)
                .opacity(fullName.isEmpty || contactNumber.isEmpty || selectedPhotoItem == nil ? 0.6 : 1.0)

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
                        .shadow(color: .black.opacity(0.05), radius: 5)
                }
        }
    }
    
    @ViewBuilder
    private func photoPickerField() -> some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text("Payment Proof")
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 4)

            Button {
                showPhotoPicker = true
            } label: {
                HStack {
                    Image(systemName: "photo")
                        .foregroundStyle(Color(hex: "ad6928"))

                    Text(selectedImage == nil ? "Choose payment proof" : "Change payment proof")
                        .foregroundStyle(selectedImage == nil ? .gray : .primary)

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
                isPresented: $showPhotoPicker,
                selection: $selectedPhotoItem,
                matching: .images
            )
            .onChange(of: selectedPhotoItem) {
                Task {
                    if let loaded = try? await selectedPhotoItem?.loadTransferable(type: Image.self) {
                        selectedImage = loaded
                    } else {
                        print("Failed")
                    }
                }
            }

            if let selectedImage {
                selectedImage
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

private struct PaymentInfoCardView: View {
    let paymentInfo: PaymentInfo
    
    var body: some View {
        HStack(alignment: .center, spacing: 12.0) {
            Image(systemName: "dollarsign.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 20.0, height: 20.0)
                .foregroundStyle(Color(hex: "ad6928"))
            VStack(alignment: .leading, spacing: 4.0) {
                Text("Payment Info")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                HStack(spacing: 8.0) {
                    Text("\(paymentInfo.bankName ?? "") \(paymentInfo.bankAccount ?? "")")
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Button {
                        UIPasteboard.general.string = paymentInfo.bankAccount ?? ""
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundStyle(Color(hex: "ad6928"))
                    }
                    .buttonStyle(.plain)
                }
                
                Text("\(paymentInfo.bankHolder ?? "")")
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            Spacer()
        }
        .padding(.leading, 12.0)
        .padding(.vertical, 8.0)
        .background {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(.white)
        }
    }
}
