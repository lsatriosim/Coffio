//
//  DiscoverErrorView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import SwiftUI

struct DiscoverErrorView: View {
    let onClick: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Image("il_coffee_cute")
                .resizable()
                .scaledToFit()
                .frame(width: 280)
            
            VStack(alignment: .center, spacing: 8.0) {
                Text("Oops! Something Went Wrong")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.black)
                
                Text("We couldn't load the cafes. Please check your connection and try again.")
                    .font(.body)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, -24.0)
            
            Button(action: onClick) {
                HStack {
                    Spacer()
                    Text("Try Again")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Image(systemName: "arrow.counterclockwise")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16.0)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12.0)
                        .fill(Color(hex: "ad6928"))
                }
            }
        }
        .padding(24.0)
    }
}

#Preview {
    DiscoverErrorView() {
        
    }
}
