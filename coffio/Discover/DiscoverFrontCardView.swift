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
                Image("mock_cafe_\(index.randomElement() ?? "")")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardWidth, height: cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                HStack(alignment: .center) {
                    Group {
                        Text("Popular")
                            .font(.caption)
                            .padding(.horizontal, 8.0)
                            .padding(.vertical, 4.0)
                    }
                    .background{
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .shadow(color: .black, radius: 4.0)
                    }
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
                Text("Rp30k-Rp50k | ★ 4.5")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .frame(width: cardWidth)
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
