//
//  DiscoverFrontCardListView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 21/03/26.
//

import SwiftUI

struct DiscoverFrontCardListView: View {
    @StateObject var viewModel: DiscoverFrontCardListViewModel = .init()
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12, alignment: .top),
        GridItem(.flexible(), spacing: 12, alignment: .top)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6.0) {
            Text("Coffio Popular's")
                .font(.title2)
                .bold()
                .padding(.horizontal, 20.0)
            
            if viewModel.isError {
                DiscoverErrorView {
                    Task {
                        await viewModel.refetchCoffeShop()
                    }
                }
            }
            else if !viewModel.isLoading && viewModel.coffeeShop.isEmpty {
                EmptyStateView(title: "No Cafes Found", description: "We couldn't find any cafes nearby. Try adjusting your location or check back later.")
            }
            else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                            
                            if viewModel.isLoading && viewModel.coffeeShop.isEmpty {
                                ForEach(0..<6) { _ in
                                    DiscoverFrontCardSkeletonView()
                                }
                            }
                            else {
                                ForEach(viewModel.coffeeShop, id: \.id) { shop in
                                    DiscoverFrontCardView(dataModel: shop)
                                        .task {
                                            // 💡 Trigger load evaluation check whenever item renders near bottom
                                            await viewModel.loadMoreContentIfNeeded(currentItem: shop)
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 20.0)
                        .padding(.top, 8)
                        
                        // Inline Infinite Bottom Pagination Progress View Spinner Frame
                        if viewModel.isPageLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(Color(hex: "5c4033"))
                                    .padding(.vertical, 20)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .task {
            guard !viewModel.hasViewModelLoaded else { return }
            await viewModel.onViewDidLoad()
        }
    }
}
