//
//  EditProfileView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 28/04/26.
//


import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = EditProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "f2efed").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 0) {
                        ReadOnlyField(label: "Username", value: viewModel.username)
                        Divider().padding(.leading, 16)
                        ReadOnlyField(label: "Email", value: viewModel.email)
                        Divider().padding(.leading, 16)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("Enter your full name", text: $viewModel.fullName)
                                .font(.body)
                                .autocorrectionDisabled()
                        }
                        .padding()
                    }
                    .background(RoundedCardBackground())
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.saveProfile { dismiss() }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Save Changes").bold()
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(hex: "ad6928"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(hex: "ad6928"))
                }
            }
        }
    }
}

struct ReadOnlyField: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}