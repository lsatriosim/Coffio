//
//  EventRegistrationSheet.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 22/04/26.
//

import SwiftUI

struct EventRegistrationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let eventId: String
    @State private var fullName: String = ""
    @State private var contactNumber: String = ""
    @EnvironmentObject var viewModel: DiscoverEventListViewModel
    
    var body: some View {
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
                // Full Name Field
                inputField(label: "Full Name", placeholder: "Enter your full name", text: $fullName)
                
                // Contact Number Field
                inputField(label: "Contact Number", placeholder: "08xxxxxxx", text: $contactNumber, keyboardType: .phonePad)
            }
            .padding(.horizontal, 24)

            Button(action: {
                viewModel.registerEvent(eventId: eventId, fullname: fullName, phoneNumber: contactNumber) {
                    dismiss()
                }
            }) {
                HStack {
                    Spacer()
                    Text("Confirm Registration")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .bold()
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
            .disabled(fullName.isEmpty || contactNumber.isEmpty)
            .opacity(fullName.isEmpty || contactNumber.isEmpty ? 0.6 : 1.0)

            Spacer()
        }
        .background(Color(hex: "f2efed"))
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
}
