//
//  DateFormatter.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/04/26.
//

import Foundation

final class DateFormatterUtil {
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm d MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US") // for English month
        
        return formatter.string(from: date)
    }
}
