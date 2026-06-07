//
//  EmptyStateView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import SwiftUI

struct EmptyStateView: View {
    let image: String
    let title: String
    let description: String
    
    init(image: String = "il_coffee_meditation", title: String, description: String) {
        self.image = image
        self.title = title
        self.description = description
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 280)
            
            VStack(alignment: .center, spacing: 8.0) {
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.black)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, -24.0)
        }
        .padding(24.0)
    }
}
