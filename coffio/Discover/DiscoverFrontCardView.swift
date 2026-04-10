//
//  DiscoverFrontCardView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 21/03/26.
//

import SwiftUI

struct DiscoverFrontCardView: View {
    let cardWidth: CGFloat = 160
    let cardHeight: CGFloat = 160
    let index: [String] = ["1", "2", "3"]
    let dataModel: DiscoverCoffeeShopItem
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            ZStack(alignment: .topLeading) {
                if let imageUrl = dataModel.imageUrl,
                   let url = URL(string: imageUrl) {
                    
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                            
                        case .failure(_), .empty:
                            placeholderView
                            
                        @unknown default:
                            placeholderView
                        }
                    }
                    .frame(width: cardWidth, height: cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                } else {
                    placeholderView
                }
                
                HStack(alignment: .center) {
                    Spacer()
                    Image(systemName: "heart")
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 4.0)
                }
                .padding(.horizontal, 12.0)
                .padding(.vertical, 16.0)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack(alignment: .leading, spacing: 4.0) {
                Text(dataModel.name)
                    .font(.body)
                    .bold()
                    .lineLimit(2)
                    .truncationMode(.tail)
                if let priceLabel = dataModel.getPriceRangeLabel() {
                    Text("\(priceLabel) | ★ 4.5")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
        .frame(width: cardWidth)
    }
    
    var placeholderView: some View {
        Image("mock_cafe_\(index.randomElement() ?? "")")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack {
            DiscoverFrontCardView(dataModel: discoverCoffeeShopItemMock[0])
            DiscoverFrontCardView(dataModel: discoverCoffeeShopItemMock[1])
        }
    }
}
