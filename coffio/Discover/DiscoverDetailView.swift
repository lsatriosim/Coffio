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
    let dataModel: DiscoverCoffeeShopItemDataModel
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0.0) {
                    ZStack(alignment: .topLeading) {
                        if dataModel.imageUrls.isEmpty {
                            placeholderView
                        }
                        else {
                            TabView {
                                ForEach(Array(dataModel.imageUrls.enumerated()), id: \.offset) { index, imageUrl in
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
            
            HStack {
                DiscoverTopButtonView(iconName: "chevron.left") {
                    dismiss()
                }
                Spacer()
                DiscoverTopButtonView(iconName: "square.and.arrow.up") {
                    
                }
                DiscoverTopButtonView(iconName: "heart") {
                    
                }
            }
            .padding(.horizontal, 24.0)
            .padding(.top, 72.0)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden()
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Text(dataModel.name)
                .font(.title)
            VStack(alignment: .leading, spacing: 4.0) {
                if !dataModel.reviews.isEmpty {
                    Text("★ \(dataModel.getAverageReviews(), specifier: "%.1f") ‧ \(dataModel.reviews.count) review(s)")
                        .foregroundStyle(Color(hex: "563122"))
                }
                if let description = dataModel.description {
                    Text(description)
                }
            }
    
            VStack(alignment: .leading, spacing: 20.0) {
                DiscoverDetailFacilitiesSectionView(facilities: dataModel.facilities.filter { $0 != .unknown })
                
                DiscoverDetailGeneralInfoSectionView(address: dataModel.address)
                
                if let mapUrl = dataModel.mapUrl {
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
                
                DiscoverDetailReviewView(reviews: dataModel.reviews)
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

private struct DiscoverTopButtonView: View {
    let iconName: String
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.black)
        }
        .padding(8.0)
        .frame(width: 36.0, height: 36.0)
        .background(
            Circle()
                .fill(.white)
                .shadow(color: .black.opacity(0.3), radius: 12.0)
        )
    }
}

#Preview {
    DiscoverDetailView(dataModel: .init(coffeeShopItem: discoverCoffeeShopItemMock[0]))
}
