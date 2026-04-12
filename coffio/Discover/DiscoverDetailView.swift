//
//  DiscoverDetailView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 23/03/26.
//

import SwiftUI

private let kImageHeight: CGFloat = 360.0

struct DiscoverDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let dataModel: DiscoverCoffeeShopItemDataModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            ZStack(alignment: .topLeading) {
                TabView {
                    ForEach(Array(dataModel.imageUrls.enumerated()), id: \.offset) { index, imageUrl in
                        carouselItem(imageUrl: imageUrl)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic)) // native dots
                .frame(height: kImageHeight)
                
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
            .frame(height: kImageHeight)
            
            content
                .padding(.horizontal, 24.0)
                .padding(.top, 24.0)
            Spacer()
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden()
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Text(dataModel.name)
                .font(.title)
            VStack(alignment: .leading, spacing: 4.0) {
                Text("★5.0 ‧ 3 review(s)")
                Text("Tangerang Selatan, Indonesia")
            }
            
            Rectangle()
                .fill(.gray)
                .frame(height: 0.75)
                .opacity(0.5)
                .padding(.vertical, 12.0)
            
            VStack(alignment: .leading, spacing: 4.0) {
                DiscoverDetailItemView(
                    iconName: "mappin",
                    text: dataModel.address
                )
                DiscoverDetailItemView(
                    iconName: "clock",
                    text: "08:00 - 22:00"
                )
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
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .aspectRatio(1.2, contentMode: .fit)
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
                .shadow(color: .black, radius: 4.0)
        )
    }
}

#Preview {
    DiscoverDetailView(dataModel: .init(coffeeShopItem: discoverCoffeeShopItemMock[0]))
}
