//
//  DiscoverEventListView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import SwiftUI

struct DiscoverEventListView: View {
    @StateObject var viewModel: DiscoverEventListViewModel = DiscoverEventListViewModel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 6.0) {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(alignment: .center, spacing: 16) {
                        if viewModel.isLoading && viewModel.events.isEmpty {
                            ForEach(0..<3) { _ in
                                DiscoverEventFrontCardSkeletonView()
                            }
                        } else {
                            ForEach(viewModel.events, id: \.id) { event in
                                DiscoverEventFrontCardItemView(dataModel: event)
                                    .onAppear {
                                        viewModel.loadMoreContentIfNeeded(currentItem: event)
                                    }
                            }
                            
                            if viewModel.isPageLoading {
                                ProgressView()
                                    .padding(.vertical, 12)
                                    .tint(Color(hex: "5c4033"))
                            }
                        }
                    }
                    .padding(.horizontal, 20.0)
                    .padding(.top, 8)
                    .padding(.bottom, 88) // Keeps the last card completely readable above the FAB
                }
            }
            // 💡 FIX: Force the layout content stack layer to fill the screen space
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            // Floating Action Button
            Button(action: { viewModel.isCreateEventSheetPresented = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color(hex: "ad6928"))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("All Events")
        .task {
            viewModel.onViewDidLoad()
        }
        .sheet(isPresented: $viewModel.isCreateEventSheetPresented) {
            EventFormSheet()
                .presentationDetents([.large])
        }
        .environmentObject(viewModel)
        .toolbar(.hidden, for: .tabBar)
    }
}
