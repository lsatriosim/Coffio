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
    @State private var isSearchExpanded = false // 💡 Tracks the expansion state
    @FocusState private var isTextFieldFocused: Bool // 💡 Auto-focuses keyboard when expanded
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12, alignment: .top),
        GridItem(.flexible(), spacing: 12, alignment: .top)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                if !isSearchExpanded {
                    Text("All Coffee Shops")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(Color(hex: "642e13"))
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                Spacer(minLength: 0)
                
                // Expandable Search Component Container
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSearchExpanded ? .gray : Color(hex: "642e13"))
                        .padding(.leading, isSearchExpanded ? 12 : 0)
                    
                    if isSearchExpanded {
                        TextField("Search coffee shops...", text: $searchText)
                            .textFieldStyle(.plain)
                            .focused($isTextFieldFocused)
                            .font(.body)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                            }
                            .padding(.trailing, 4)
                        }
                        
                        Button("Cancel") {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                searchText = ""
                                isSearchExpanded = false
                                isTextFieldFocused = false
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "ad6928"))
                        .padding(.trailing, 12)
                    }
                }
                // Matches the clean pill geometry of your custom layout components
                .frame(width: isSearchExpanded ? nil : 44, height: 44)
                .frame(maxWidth: isSearchExpanded ? .infinity : nil)
                .background(
                    Capsule()
                        .fill(isSearchExpanded ? Color(.systemGray6) : Color(hex: "fcede1"))
                )
                .onTapGesture {
                    guard !isSearchExpanded else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isSearchExpanded = true
                        isTextFieldFocused = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            .padding(.top, 8)
            
            // Core Dashboard Content Layout Conditional Tree
            if viewModel.isError {
                DiscoverErrorView {
                    Task {
                        await viewModel.refetchCoffeShop()
                    }
                }
                Spacer()
            }
            else if !viewModel.isLoading && viewModel.filteredCoffeeShops(matching: searchText).isEmpty {
                EmptyStateView(
                    title: searchText.isEmpty ? "No Cafes Found" : "No Results for \"\(searchText)\"",
                    description: searchText.isEmpty
                        ? "We couldn't find any cafes nearby. Try adjusting your location or check back later."
                        : "Check your spelling or try searching for another coffee shop."
                )
                Spacer()
            }
            else {
                ScrollView(.vertical, showsIndicators: false) {
                    HStack {
                        Text("Coffio Popular's")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color(hex: "642e13"))
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
        .task {
            guard !viewModel.hasViewModelLoaded else { return }
            await viewModel.onViewDidLoad()
        }
        .toolbar(.hidden, for: .tabBar)
    }
}
