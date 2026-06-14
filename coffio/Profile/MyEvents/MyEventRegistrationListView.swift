//
//  MyEventRegistrationListView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//


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
