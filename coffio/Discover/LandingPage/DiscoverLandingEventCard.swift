//
//  DiscoverLandingEventCard.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/06/26.
//

import SwiftUI

struct DiscoverLandingEventCard: View {
    let width: CGFloat = 200
    let height: CGFloat = 250
    let dataModel: DiscoverEventItem
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 1. Background Image Layer
            if let imageUrl = dataModel.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height) // 💡 Keep it locked
                        
                    case .failure, .empty:
                        placeholderView
                            .frame(width: width, height: height) // 💡 Keep it locked
                            
                    @unknown default:
                        placeholderView
                            .frame(width: width, height: height)
                    }
                }
            } else {
                placeholderView
                    .frame(width: width, height: height)
            }
            
            // 2. Linear Gradient Scrim
            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.3),
                    .black.opacity(0.75),
                    .black.opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 3. Metadata Layout Block
            VStack(alignment: .leading, spacing: 4) {
                Text(dataModel.title)
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                
                Text(DateFormatterUtil.formatDate(dataModel.eventDate))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)
                
                HStack(alignment: .bottom) {
                    Text(dataModel.price == 0 ? "Free" : PriceUtil.formatLong(dataModel.price))
                        .font(.caption)
                        .bold()
                        .foregroundStyle(Color(hex: "f3b375"))
                    
                    Spacer()
                    
                    if dataModel.capacity - dataModel.participantRegistered == 0 {
                        Text("Sold Out")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                            .foregroundStyle(.white)
                    }
                    else {
                        Text("\(dataModel.capacity - dataModel.participantRegistered) left")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top, 2)
            }
            .padding(12)
        }
        .frame(width: width, height: height)
        // Clones the clipped boundaries to prevent image spill during loading phases
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
    
    var placeholderView: some View {
        Image("il_cafe")
            .resizable()
            .scaledToFill()
    }
}
