//
//  MyEventPaymentProofModalSheet.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//

import SwiftUI

struct MyEventPaymentProofModalSheet: View {
    let registration: EventRegistrationItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "f2efed").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Image Canvas View Layout
                        VStack {
                            if let imageUrlString = registration.paymentProofUrl, let url = URL(string: imageUrlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView().tint(Color(hex: "ad6928"))
                                    case .success(let image):
                                        image.resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    case .failure:
                                        Image(systemName: "exclamationmark.triangle")
                                            .font(.largeTitle).foregroundStyle(.gray)
                                        Text("Failed to load receipt image").font(.caption)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.largeTitle).foregroundStyle(.gray)
                                Text("No upload record associated").font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .minHeightFrame(240)
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Structured Context Metadata Info Table Card
                        VStack(spacing: 12) {
                            InfoRow(title: "Applicant Name", value: registration.userProfile.safeName)
                            Divider()
                            InfoRow(title: "Submitted At", value: registration.paymentSubmittedAt?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Receipt Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .bold()
                        .foregroundStyle(Color(hex: "ad6928"))
                }
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title).font(.footnote).foregroundStyle(.gray)
            Spacer()
            Text(value).font(.footnote).bold().foregroundStyle(.primary)
        }
    }
}

// Layout helper configuration
extension View {
    @ViewBuilder func minHeightFrame(_ height: CGFloat) -> some View {
        self.frame(minHeight: height)
    }
}
