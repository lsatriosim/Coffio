//
//  DiscoverLandingCoffeeShopCard.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/06/26.
//

import SwiftUI

struct DiscoverLandingCoffeeShopCard: View {
    let width: CGFloat = 260
    let height: CGFloat = 100
    let dataModel: DiscoverCoffeeShopItemDataModel
    
    var body: some View {
        NavigationLink {
            let detailViewModel = DiscoverDetailCafeViewModel(coffeeShop: dataModel)
            DiscoverDetailView(viewModel: detailViewModel)
        } label: {
            HStack(spacing: 12) {
                // Left Image Element
                if let imageUrl = dataModel.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure, .empty:
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    placeholderView
                        .frame(width: 76, height: 76)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Right Context Metadata Info Layout Block
                VStack(alignment: .leading, spacing: 4) {
                    Text(dataModel.name)
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(Color(hex: "642e13"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer(minLength: 0)
                    
                    HStack(spacing: 4) {
                        if let priceLabel = dataModel.getPriceRangeLabel() {
                            Text(priceLabel)
                                .foregroundStyle(.secondary)
                            Text("•").foregroundStyle(.tertiary)
                        }
                        
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        
                        Text("4.5")
                            .bold()
                            .foregroundStyle(.primary)
                    }
                    .font(.caption)
                    
                    if let distanceLabel = dataModel.distanceLabel {
                        Text(distanceLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 2)
                
                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(width: width, height: height, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray6), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    var placeholderView: some View {
        Image("il_cafe")
            .resizable()
            .scaledToFill()
    }
}
