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
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                    
                    if viewModel.isLoading {
                        ForEach(0..<6) { _ in
                            DiscoverFrontCardSkeletonView()
                        }
                    } else {
                        ForEach(viewModel.coffeeShop, id: \.id) { coffeeShop in
                            DiscoverFrontCardView(dataModel: coffeeShop)
                        }
                    }
                }
                .padding(.horizontal, 20.0)
                .padding(.top, 8)
            }
        }
        .task() {
            guard !viewModel.hasViewModelLoaded else { return }
            await viewModel.onViewDidLoad()
        }
    }
}

#Preview {
    DiscoverFrontCardListView()
}
