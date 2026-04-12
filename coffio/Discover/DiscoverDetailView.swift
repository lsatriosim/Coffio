//
//  DiscoverDetailView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 23/03/26.
//

import SwiftUI

struct DiscoverDetailView: View {
    let dataModel: DiscoverCoffeeShopItemDataModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            ZStack(alignment: .topLeading) {
                Image("mock_cafe_1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea(edges: .top)
                HStack {
                    DiscoverTopButtonView(iconName: "chevron.left") {
                        
                    }
                    Spacer()
                    DiscoverTopButtonView(iconName: "square.and.arrow.up") {
                        
                    }
                    DiscoverTopButtonView(iconName: "heart") {
                        
                    }
                }
                .padding(.horizontal, 24.0)
                .padding(.vertical, 16.0)
            }
            content
                .padding(.horizontal, 24.0)
                .padding(.vertical, -36.0)
            Spacer()
        }
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
