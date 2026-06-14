//
//  DiscoverFrontCardListView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 21/03/26.
//

import SwiftUI

struct DiscoverFrontCardListView: View {
    @StateObject var viewModel: DiscoverFrontCardListViewModel = .init()
    @State private var searchText = ""
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12, alignment: .top),
        GridItem(.flexible(), spacing: 12, alignment: .top)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6.0) {
            if viewModel.isError {
                DiscoverErrorView {
                    Task {
                        await viewModel.refetchCoffeShop()
                    }
                }
            }
            else if !viewModel.isLoading && viewModel.filteredCoffeeShops(matching: searchText).isEmpty {
                EmptyStateView(
                    title: searchText.isEmpty ? "No Cafes Found" : "No Results for \"\(searchText)\"",
                    description: searchText.isEmpty
                        ? "We couldn't find any cafes nearby. Try adjusting your location or check back later."
                        : "Check your spelling or try searching for another coffee shop."
                )
            }
            else {
                ScrollView(.vertical, showsIndicators: false) {
                    HStack {
                        Text("Coffio Popular's")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal, 20.0)
                    VStack(spacing: 0) {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                            
                            if viewModel.isLoading && viewModel.coffeeShop.isEmpty {
                                ForEach(0..<6) { _ in
                                    DiscoverFrontCardSkeletonView()
                                }
                            }
                            else {
                                ForEach(viewModel.filteredCoffeeShops(matching: searchText), id: \.id) { shop in
                                    DiscoverFrontCardView(dataModel: shop)
                                }
                            }
                        }
                        .padding(.horizontal, 20.0)
                        .padding(.top, 8)
                        
                        if viewModel.isPageLoading && searchText.isEmpty {
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search coffee shops...")
        .task {
            guard !viewModel.hasViewModelLoaded else { return }
            await viewModel.onViewDidLoad()
        }
    }
}
