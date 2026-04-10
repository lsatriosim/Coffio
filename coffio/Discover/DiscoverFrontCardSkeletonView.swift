//
//  DiscoverFrontCardSkeletonView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/04/26.
//

import Foundation
import SwiftUI

struct DiscoverFrontCardSkeletonView: View {
    let cardWidth: CGFloat = 160
    let cardHeight: CGFloat = 160
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            
            // Image Skeleton
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.3))
                .frame(width: cardWidth, height: cardHeight)
                .shimmering()
            
            VStack(alignment: .leading, spacing: 6) {
                
                // Title Skeleton
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 14)
                    .frame(width: cardWidth * 0.8)
                    .shimmering()
                
                // Subtitle Skeleton
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 12)
                    .frame(width: cardWidth * 0.6)
                    .shimmering()
            }
        }
        .frame(width: cardWidth)
    }
}
