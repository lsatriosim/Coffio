//
//  DiscoverEmptyStateView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import SwiftUI

struct DiscoverEmptyStateView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("il_coffee_meditation")
                .resizable()
                .scaledToFit()
                .frame(width: 280)
            
            VStack(alignment: .center, spacing: 8.0) {
                Text("No Cafes Found")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.black)
                
                Text("We couldn't find any cafes nearby. Try adjusting your location or check back later.")
                    .font(.body)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, -24.0)
        }
        .padding(24.0)
    }
}

#Preview {
    DiscoverEmptyStateView()
}
