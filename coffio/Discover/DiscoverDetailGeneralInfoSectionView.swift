//
//  DiscoverDetailGeneralInfoSectionView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 12/04/26.
//

import SwiftUI

struct DiscoverDetailGeneralInfoSectionView: View {
    let address: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Location & Hours")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: "563122"))
            
            VStack(alignment: .leading, spacing: 8.0) {
                createInformationItemView(iconName: "map", label: address)
                createInformationItemView(iconName: "clock", label: "08.00 - 20.00")
            }
            .padding(.horizontal, 16.0)
            .padding(.vertical, 12.0)
            .background {
                RoundedRectangle(cornerRadius: 12.0)
                    .fill(.white)
                    .stroke(Color(hex: "f2efed", alpha: 1.0), lineWidth: 1.0)
            }
        }
    }
    
    func createInformationItemView(iconName: String, label: String) -> some View {
        HStack(alignment: .top, spacing: 4.0) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 14.0)
                .foregroundStyle(Color(hex: "563122"))
            Text(label)
                .font(.footnote)
            Spacer()
        }
    }
}

#Preview {
    DiscoverDetailGeneralInfoSectionView(address: discoverCoffeeShopItemMock[0].address)
}
