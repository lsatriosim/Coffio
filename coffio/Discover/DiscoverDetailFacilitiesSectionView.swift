//
//  DiscoverDetailFacilitiesSectionView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 12/04/26.
//

import SwiftUI

struct DiscoverDetailFacilitiesSectionView: View {
    let facilities: [CoffeeShopFacilities]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Facilities")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: "563122"))
            
            HStack {
                ForEach(facilities, id: \.rawValue) { facility in
                    DiscoverDetailFacilitiesItemView(facility: facility)
                }
            }
        }
    }
}

private struct DiscoverDetailFacilitiesItemView: View {
    let facility: CoffeeShopFacilities
    
    var iconName: String {
        switch facility {
        case .wifi:
            "wifi"
        case .powerOutlet:
            "poweroutlet.type.c.fill"
        case .outdoor:
            "leaf"
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 6.0) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 14.0)
                .foregroundStyle(Color(hex: "ad6928"))
            Text(facility.rawValue)
                .font(.footnote)
        }
        .padding(.horizontal, 8.0)
        .padding(.vertical, 4.0)
        .background {
            Capsule()
                .fill(.white)
                .stroke(Color(hex: "f2efed", alpha: 1.0), lineWidth: 1.0)
        }
    }
}

#Preview {
    DiscoverDetailFacilitiesSectionView(facilities: [.outdoor, .powerOutlet, .wifi])
}
