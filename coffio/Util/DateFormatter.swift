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
    
    static func getDateOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US") // for English month
        
        return formatter.string(from: date)
    }
    
    static func formatDateRange(start: Date, end: Date? = nil) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_US")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        
        guard let end else {
            return "\(dateFormatter.string(from: start)) • \(timeFormatter.string(from: start))"
        }
        
        let calendar = Calendar.current
        let sameDay = calendar.isDate(start, inSameDayAs: end)
        
        if sameDay {
            return "\(dateFormatter.string(from: start)) • \(timeFormatter.string(from: start)) - \(timeFormatter.string(from: end))"
        } else {
            let fullFormatter = DateFormatter()
            fullFormatter.dateFormat = "d MMM yyyy HH:mm"
            fullFormatter.locale = Locale(identifier: "en_US")
            
            return "\(fullFormatter.string(from: start)) - \(fullFormatter.string(from: end))"
        }
    }
}
