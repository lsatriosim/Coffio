//
//  DiscoverEventFrontCardSkeletonView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import SwiftUI

struct DiscoverEventFrontCardSkeletonView: View {
    let cardHeight: CGFloat = 320
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            
            // Image Skeleton
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.3))
                .frame(maxWidth: .infinity)
                .frame(height: cardHeight)
                .shimmering()
            
            VStack(alignment: .leading, spacing: 8) {
                
                // Title line 1
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)
                    .shimmering()
                
                // Title line 2
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 16)
                    .frame(width: 220)
                    .shimmering()
                
                // Date + Cafe Name
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 12)
                        .shimmering()
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 90, height: 12)
                        .shimmering()
                }
                
                // Price + Slot Left
                HStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 20)
                        .shimmering()
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 90, height: 12)
                        .shimmering()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    DiscoverEventFrontCardSkeletonView()
        .padding()
}
