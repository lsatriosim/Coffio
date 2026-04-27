//
//  DiscoverDetailView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 23/03/26.
//

import SwiftUI

private let kImageHeight: CGFloat = 320.0

struct DiscoverDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DiscoverDetailCafeViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0.0) {
                    ZStack(alignment: .topLeading) {
                        if viewModel.coffeeShop.imageUrls.isEmpty {
                            placeholderView
                        }
                        else {
                            TabView {
                                ForEach(Array(viewModel.coffeeShop.imageUrls.enumerated()), id: \.offset) { index, imageUrl in
                                    carouselItem(imageUrl: imageUrl)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .automatic))
                            .frame(height: kImageHeight)
                        }
                    }
                    .frame(height: kImageHeight)
                    
                    content
                        .padding(.horizontal, 24.0)
                        .padding(.top, 24.0)
                    Spacer()
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.black)
                }
            }
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Text(viewModel.coffeeShop.name)
                .font(.title)
            VStack(alignment: .leading, spacing: 4.0) {
                if !viewModel.coffeeShop.reviews.isEmpty {
                    Text("★ \(viewModel.coffeeShop.getAverageReviews(), specifier: "%.1f") ‧ \(viewModel.coffeeShop.reviews.count) review(s)")
                        .foregroundStyle(Color(hex: "563122"))
                }
                if let description = viewModel.coffeeShop.description {
                    Text(description)
                }
            }
    
            VStack(alignment: .leading, spacing: 20.0) {
                DiscoverDetailFacilitiesSectionView(facilities: viewModel.coffeeShop.facilities.filter { $0 != .unknown })
                
                DiscoverDetailGeneralInfoSectionView(address: viewModel.coffeeShop.address)
                
                if let mapUrl = viewModel.coffeeShop.mapUrl {
                    Button(action: {
                        if let url: URL = URL(string: mapUrl) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Get Directions")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Image(systemName: "car")
                                .foregroundStyle(.white)
                            Spacer()
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "ad6928"))
                    }
                }
                
                DiscoverDetailReviewView()
                .environmentObject(viewModel)
            }
        }
    }
    
    @ViewBuilder
    private func carouselItem(imageUrl: String) -> some View {
        if let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                    
                case .failure(_), .empty:
                    placeholderView
                    
                @unknown default:
                    placeholderView
                }
            }
            .frame(height: kImageHeight)
            .aspectRatio(1.2, contentMode: .fit) // adjust height ratio
            .clipped()
        } else {
            placeholderView
        }
    }
    
    private var placeholderView: some View {
        GeometryReader { geo in
            Image("il_cafe")
                .resizable()
                .frame(width: geo.size.width)
                .aspectRatio(1.2, contentMode: .fit) // adjust height ratio
        }
        .frame(height: kImageHeight)
    }
}

private struct DiscoverDetailItemView: View {
    let iconName: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 4.0) {
            Image(systemName: iconName)
            Text(text)
            Spacer()
        }
    }
}

#Preview {
    DiscoverDetailView(viewModel: .init(coffeeShop: .init(coffeeShopItem: discoverCoffeeShopItemMock[0])))
}
