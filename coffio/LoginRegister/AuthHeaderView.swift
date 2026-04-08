//
//  AuthHeaderView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import SwiftUI

struct AuthHeaderView: View {
    let title: String
    let ctaLabel: String
    let trailingText: String
    let trailingAction: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [
                    Color(hex: "ad6928"),
                    Color(hex: "563122")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 220)
            .ignoresSafeArea()

            VStack(alignment: .center, spacing: 36.0) {
                HStack {
                    Spacer()
                    Text(ctaLabel)
                        .foregroundStyle(.white)
                        .font(.footnote)
                        .bold()
                    Button(action: trailingAction) {
                        Text(trailingText)
                            .font(.footnote)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 8.0)
                    .padding(.vertical, 6.0)
                    .background(.white.opacity(0.4))
                    .cornerRadius(8.0)
                }

                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
            }
            .padding(8.0)
        }
        .frame(height: 220)
    }
}


#Preview {
    AuthHeaderView(
        title: "Login",
        ctaLabel: "Login Here",
        trailingText: "dsds",
        trailingAction: {
            
        }
    )
}
