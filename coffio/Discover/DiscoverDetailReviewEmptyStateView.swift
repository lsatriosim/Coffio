//
//  DiscoverDetailReviewEmptyStateView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import SwiftUI

struct DiscoverDetailReviewEmptyStateView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("il_coffee_hello")
                .resizable()
                .scaledToFit()
                .frame(width: 280)
            
            VStack(alignment: .center, spacing: 8.0) {
                Text("No Reviews Found")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.black)
                
                Text("We couldn't find any reviews from this cafe. Become the first to review!")
                    .font(.body)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, -24.0)
            Spacer()
        }
        .padding(24.0)
    }
}

#Preview {
    DiscoverDetailReviewEmptyStateView()
}
