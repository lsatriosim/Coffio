//
//  PriceUtil.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import Foundation

final class PriceUtil {
    static func formatToK(_ value: Int) -> String {
        let thousands = value / 1000
        return "Rp\(thousands)k"
    }
    
    static func formatLong(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.locale = Locale(identifier: "id_ID")
        
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "Rp\(formatted)"
    }
}
