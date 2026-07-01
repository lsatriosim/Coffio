//
//  EventPaymentSheet.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 01/07/26.
//

import SwiftUI
import PhotosUI

struct EventPaymentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EventPaymentViewModel
    
    @State private var receiptItem: PhotosPickerItem?
    @State private var receiptImage: Image?
    
    init(registrationId: String, event: DiscoverEventItem, paymentDeadlineTime: Date) {
        _viewModel = StateObject(wrappedValue: EventPaymentViewModel(registrationId: registrationId, event: event, paymentDeadlineTime: paymentDeadlineTime))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 6)
                    .padding(.top, 12)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. Timer Display Block
                        VStack(spacing: 8) {
                            Text("Secure Your Reservation Slot")
                                .font(.headline)
                                .foregroundStyle(.gray)
                            
                            Text(viewModel.timeRemainingString)
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                                .foregroundStyle(viewModel.isTimerExpired ? .red : Color(hex: "ad6928"))
                            
                            Text("Complete transfer before expiration window closes.")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        
                        // 2. Routing Account Information
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Transfer Details")
                                .font(.caption).bold()
                                .foregroundStyle(.gray)
                            
                            VStack(spacing: 12) {
                                detailRow(title: "Bank", value: viewModel.event.paymentInfo?.bankName ?? "BCA")
                                Divider()
                                detailRow(title: "Account Number", value: viewModel.event.paymentInfo?.bankAccount ?? "-")
                                Divider()
                                detailRow(title: "Account Holder", value: viewModel.event.paymentInfo?.bankHolder ?? "-")
                                Divider()
                                detailRow(title: "Total Price", value: "IDR \(viewModel.event.price)")
                                    .bold()
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                        }
                        
                        // 3. Document/Photo Upload Picker Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Upload Receipt Proof")
                                .font(.caption).bold()
                                .foregroundStyle(.gray)
                            
                            PhotosPicker(selection: $receiptItem, matching: .images) {
                                HStack {
                                    Image(systemName: "doc.viewfinder.fill")
                                        .foregroundStyle(Color(hex: "ad6928"))
                                    Text(receiptImage != nil ? "Change Receipt File" : "Choose Image selection...")
                                        .foregroundStyle(receiptImage != nil ? .primary : Color.gray)
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.gray)
                                }
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                            }
                        }
                        
                        if let receiptImage {
                            receiptImage
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(14)
                        }
                        
                        // 4. Action Layer
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Button {
                                viewModel.submitPaymentProof {
                                    dismiss()
                                }
                            } label: {
                                Text("Complete Verification")
                                    .font(.body).bold()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(viewModel.isTimerExpired || receiptImage == nil ? Color.gray : Color(hex: "ad6928"))
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(viewModel.isTimerExpired || receiptImage == nil)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
            .background(Color(hex: "f2efed"))
            .onChange(of: receiptItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        viewModel.receiptData = data
                    }
                    if let image = try? await newValue?.loadTransferable(type: Image.self) {
                        self.receiptImage = image
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.gray)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
    }
}
