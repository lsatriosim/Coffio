//
//  Color+Hex.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 07/04/26.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String, alpha: Double = 1.0) {
        let hexSanitized = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r, g, b: Double
        switch hexSanitized.count {
        case 6:
            r = Double((rgb & 0xFF0000) >> 16) / 255
            g = Double((rgb & 0x00FF00) >> 8) / 255
            b = Double(rgb & 0x0000FF) / 255
        case 3:
            r = Double((rgb & 0xF00) >> 8) / 15
            g = Double((rgb & 0x0F0) >> 4) / 15
            b = Double(rgb & 0x00F) / 15
        default:
            r = 0; g = 0; b = 0
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
