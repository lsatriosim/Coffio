//
//  MyEventListView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//

import SwiftUI

struct MyEventListView: View {
    @StateObject private var viewModel = MyEventListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background overlay color framework
                Color(hex: "f2efed").ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.events.isEmpty {
                    ProgressView()
                        .tint(Color(hex: "ad6928"))
                } else if viewModel.events.isEmpty {
                    emptyState
                } else {
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 16.0) {
                            ForEach(viewModel.events) { cardModel in
                                NavigationLink(destination: DiscoverDetailEventView(eventId: cardModel.id)) {
                                    MyEventCardView(dataModel: cardModel)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16.0)
                        .padding(.vertical, 20.0)
                    }
                    .refreshable {
                        await viewModel.fetchUserCreatedEvents()
                    }
                }
            }
            .navigationTitle("My Events")
            .navigationBarTitleDisplayMode(.automatic)
            .onAppear {
                viewModel.onViewDidLoad()
            }
            .alert("Error Occurred", isPresented: $viewModel.isError) {
                Button("Dismiss", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var emptyState: some View {
        EmptyStateView(
            title: "No Events Hosted Yet",
            description: "Any coffee gatherings, masterclasses, or events you create will show up here."
        )
    }
}

#Preview {
    MyEventListView()
}
