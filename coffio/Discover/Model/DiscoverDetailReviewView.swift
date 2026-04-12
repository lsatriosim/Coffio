//
//  DiscoverDetailReviewView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 12/04/26.
//

import SwiftUI

struct DiscoverDetailReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Reviews")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: "563122"))
        }
    }
}

#Preview {
    DiscoverDetailReviewView()
}
