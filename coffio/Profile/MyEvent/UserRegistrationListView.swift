//
//  UserRegistrationListView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/05/26.
//

import SwiftUI

struct UserRegistrationListView: View {
    @StateObject private var viewModel = UserRegistrationViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "f2efed").ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Color(hex: "ad6928"))
                } else if viewModel.registrations.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.registrations, id: \.id) { registration in
                                NavigationLink(destination: DiscoverDetailEventView(eventId: registration.eventDetail.id)) {
                                    EventRegistrationCardView(registration: registration)
                                        .padding(.horizontal, 20)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .refreshable {
                        await viewModel.fetchRegistrations()
                    }
                }
            }
            .navigationTitle("My Events")
            .onAppear {
                viewModel.onViewDidLoad()
            }
            .alert("Error", isPresented: $viewModel.isError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(.gray)
            Text("No registrations yet")
                .font(.headline)
            Text("Your registered events will appear here.")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
    }
}
