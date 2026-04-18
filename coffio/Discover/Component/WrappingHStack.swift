//
//  WrappingHStack.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import SwiftUI

struct WrappingHStack: Layout {
    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? 0

        var width: CGFloat = 0
        var height: CGFloat = 0

        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if rowWidth + size.width > maxWidth {
                width = max(width, rowWidth)
                height += rowHeight + verticalSpacing

                rowWidth = size.width + horizontalSpacing
                rowHeight = size.height
            } else {
                rowWidth += size.width + horizontalSpacing
                rowHeight = max(rowHeight, size.height)
            }
        }

        width = max(width, rowWidth)
        height += rowHeight

        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(size)
            )

            x += size.width + horizontalSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
