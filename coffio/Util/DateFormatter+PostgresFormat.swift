//
//  DateFormatter+PostgresFormat.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/04/26.
//

import Foundation

extension DateFormatter {
    static let postgres: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSXXXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
