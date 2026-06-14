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
    
    static func formatEventDuration(
        start startDate: Date,
        end endDate: Date?,
        showTime: Bool = false,
        useShortMonth: Bool = false
    ) -> String {
        let calendar = Calendar.current
        
        // Setup base formatting elements
        let monthFormat = useShortMonth ? "MMM" : "MMMM"
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = monthFormat
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let startDay = dayFormatter.string(from: startDate)
        let startMonth = monthFormatter.string(from: startDate)
        let startYear = yearFormatter.string(from: startDate)
        let dateString = "\(startDay) \(startMonth) \(startYear)"
        
        // 💡 Handle Nil End Date Case early
        guard let endDate = endDate else {
            if showTime {
                let startTime = timeFormatter.string(from: startDate)
                return "\(startTime), \(dateString)"
            } else {
                return dateString
            }
        }
        
        // Extract component flags to compare ranges safely now that endDate is unwrapped
        let startComponents = calendar.dateComponents([.day, .month, .year], from: startDate)
        let endComponents = calendar.dateComponents([.day, .month, .year], from: endDate)
        
        let isSameDay = startComponents.day == endComponents.day &&
                        startComponents.month == endComponents.month &&
                        startComponents.year == endComponents.year
        
        let isSameMonth = startComponents.month == endComponents.month &&
                          startComponents.year == endComponents.year
        
        let isSameYear = startComponents.year == endComponents.year
        
        let endDay = dayFormatter.string(from: endDate)
        let endMonth = monthFormatter.string(from: endDate)
        let endYear = yearFormatter.string(from: endDate)
        
        // 1. Same Day Handling
        if isSameDay {
            if showTime {
                let startTime = timeFormatter.string(from: startDate)
                let endTime = timeFormatter.string(from: endDate)
                return "\(startTime) - \(endTime), \(dateString)"
            } else {
                return dateString
            }
        }
        
        // 2. Different Day, Same Month Handling -> "12 - 14 April 2002"
        if isSameMonth {
            return "\(startDay) - \(endDay) \(startMonth) \(startYear)"
        }
        
        // 3. Different Month, Same Year Handling -> "12 April - 16 April 2002"
        if isSameYear {
            return "\(startDay) \(startMonth) - \(endDay) \(endMonth) \(startYear)"
        }
        
        // 4. Different Year Handling -> "31 December 2021 - 2 January 2022"
        return "\(startDay) \(startMonth) \(startYear) - \(endDay) \(endMonth) \(endYear)"
    }
}
