//
//  MyEventRegistrationListView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//

import SwiftUI

struct MyEventRegistrationListView: View {
    @StateObject private var viewModel: MyEventRegistrationListViewModel
    @State private var selectedPaymentProof: EventRegistrationItem?
    @State private var editingInternalGuest: DiscoverInternalGuestItem?
    @State private var guestToDelete: DiscoverInternalGuestItem?
    
    init(eventId: String) {
        _viewModel = StateObject(wrappedValue: MyEventRegistrationListViewModel(eventId: eventId))
    }
    
    var body: some View {
        ZStack {
            Color(hex: "f2efed").ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView().tint(Color(hex: "ad6928"))
            } else if viewModel.registrations.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        if !viewModel.internalGuests.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Internal Guests")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 20)
                                
                                ForEach(viewModel.internalGuests) { guest in
                                    DiscoverInternalGuestCardView(
                                        guest: guest,
                                        onEdit: {
                                            editingInternalGuest = guest
                                        },
                                        onRemove: {
                                            guestToDelete = guest
                                        }
                                    )
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        
                        if !viewModel.registrations.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Registered User")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 20)
                                
                                ForEach(viewModel.registrations) { registration in
                                    MyEventRegistrationCardView(
                                        registration: registration,
                                        isProcessing: viewModel.processingIds[registration.id] ?? false,
                                        onApprove: {
                                            Task { await viewModel.approveRegistration(id: registration.id) }
                                        },
                                        onReject: {
                                            Task { await viewModel.rejectRegistration(id: registration.id) }
                                        },
                                        onShowProof: {
                                            selectedPaymentProof = registration
                                        }
                                    )
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                .refreshable { await viewModel.fetchRegistrations() }
            }
        }
        .navigationTitle("Registrations")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.onViewDidLoad() }
        .sheet(item: $selectedPaymentProof) { registration in
            MyEventPaymentProofModalSheet(registration: registration)
        }
        .sheet(item: $editingInternalGuest) { guest in
            DiscoverInternalGuestRegistrationSheet(
                eventId: viewModel.eventId,
                guestToEdit: guest,
                delegate: viewModel
            )
            .presentationDetents([.large])
        }
        .coffioPopup(isPresented: Binding(
                    get: { guestToDelete != nil },
                    set: { if !$0 { guestToDelete = nil } }
        )) {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Hapus Internal Guest")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.primary)
                    
                    Text("Apakah Anda yakin ingin menghapus **\(guestToDelete?.guestName ?? "tamu ini")** dari daftar internal guest?")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                }
                
                HStack(spacing: 12) {
                    // Tombol Batal
                    Button(action: {
                        guestToDelete = nil
                    }) {
                        HStack {
                            Spacer()
                            Text("Batal")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.15))
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Tombol Konfirmasi Hapus
                    Button(action: {
                        if let guest = guestToDelete {
                            let idToRemove = guest.id
                            guestToDelete = nil
                            Task {
                                await viewModel.removeInternalGuest(id: idToRemove)
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Hapus")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.isError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.slash").font(.largeTitle).foregroundStyle(.gray)
            Text("No attendees registered").font(.headline)
        }
    }
}
