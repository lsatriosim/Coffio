//
//  PhoneUtil.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 24/06/26.
//

import Foundation

struct PhoneUtil {
    /// Cleans and reformats any Indonesian phone input string into standard "628xxxxxxxx" layout formats.
    /// - Parameter input: The raw text string entered by the user.
    /// - Returns: A tuple containing whether the parsed format string is valid, and the converted phone string output.
    static func formatIndonesianId(from input: String) -> (isValid: Bool, phoneNumber: String) {
        // 1. Strip away all non-numeric characters (spaces, hyphens, plus signs, brackets)
        let digitsOnly = input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        var formatted = digitsOnly
        
        // 2. Normalize prefixes to standard 62 base frame
        if digitsOnly.hasPrefix("08") {
            // Drop leading "0", substitute "62"
            formatted = "62" + digitsOnly.dropFirst()
        } else if digitsOnly.hasPrefix("628") {
            // Already matches correct country frame layout rule
            formatted = digitsOnly
        } else if digitsOnly.hasPrefix("8") {
            // Append explicit country dialing prefix rule
            formatted = "62" + digitsOnly
        } else {
            // Anything else (e.g. starting with other numbers or prefix groups entirely) is invalid
            return (false, input)
        }
        
        // 3. Structural Validation: Check standard Indonesian mobile number length parameters
        // Standard range for 628xxxxxxxx numbers is typically 11 to 14 total digits.
        if formatted.count >= 11 && formatted.count <= 14 {
            return (true, formatted)
        } else {
            return (false, input)
        }
    }
}
