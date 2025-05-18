import Foundation
import SwiftUI

struct PhoneNumberHelper {
    // Common country codes with their flags and formatting patterns
    static let countryCodes: [String: (flag: String, pattern: String)] = [
        "1": ("🇺🇸", "XXX-XXX-XXXX"),         // USA/Canada
        "44": ("🇬🇧", "XXXX XXXXXX"),        // UK
        "91": ("🇮🇳", "XXXXX XXXXX"),        // India
        "86": ("🇨🇳", "XXX XXXX XXXX"),      // China
        "49": ("🇩🇪", "XXXX XXXXXXX"),       // Germany
        "33": ("🇫🇷", "X XX XX XX XX"),      // France
        "61": ("🇦🇺", "XXX XXX XXX"),        // Australia
        "81": ("🇯🇵", "XX XXXX XXXX"),       // Japan
        "7": ("🇷🇺", "XXX XXX XXXX"),        // Russia
        "55": ("🇧🇷", "XX XXXXX XXXX"),      // Brazil
        "82": ("🇰🇷", "XX XXXX XXXX"),       // South Korea
        "39": ("🇮🇹", "XXX XXX XXXX"),       // Italy
        "34": ("🇪🇸", "XXX XXX XXX"),        // Spain
        "52": ("🇲🇽", "XXX XXX XXXX"),       // Mexico
        "31": ("🇳🇱", "X XX XX XX XX"),      // Netherlands
        "90": ("🇹🇷", "XXX XXX XXXX"),       // Turkey
        "966": ("🇸🇦", "XX XXX XXXX"),       // Saudi Arabia
        "65": ("🇸🇬", "XXXX XXXX"),          // Singapore
        "971": ("🇦🇪", "XX XXX XXXX"),       // UAE
        "27": ("🇿🇦", "XX XXX XXXX")         // South Africa
    ]
    
    // Extract country code from a phone number
    static func extractCountryCode(from phoneNumber: String) -> (countryCode: String, nationalNumber: String) {
        let cleanNumber = phoneNumber.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        
        if cleanNumber.hasPrefix("+") {
            // Try to match with known country codes, starting with longer ones
            let sortedCodes = countryCodes.keys.sorted { $0.count > $1.count }
            
            for code in sortedCodes {
                if cleanNumber.hasPrefix("+" + code) {
                    let nationalStart = cleanNumber.index(cleanNumber.startIndex, offsetBy: code.count + 1)
                    let nationalNumber = String(cleanNumber[nationalStart...])
                    return (code, nationalNumber)
                }
            }
        }
        
        // Try to guess country code if number starts with digits
        if cleanNumber.first?.isNumber == true {
            // Check if it's a long number that might have country code without +
            if cleanNumber.count > 10 {
                // Try common country codes (1-3 digits)
                for codeLength in 1...3 {
                    if cleanNumber.count > codeLength {
                        let potentialCode = String(cleanNumber.prefix(codeLength))
                        if countryCodes[potentialCode] != nil {
                            let nationalStart = cleanNumber.index(cleanNumber.startIndex, offsetBy: codeLength)
                            let nationalNumber = String(cleanNumber[nationalStart...])
                            return (potentialCode, nationalNumber)
                        }
                    }
                }
            }
        }
        
        // Default to treating the whole thing as a national number with no country code
        return ("", cleanNumber)
    }
    
    // Format a phone number for display, with country code identification
    static func formatPhoneNumber(_ phoneNumber: String) -> String {
        let (countryCode, nationalNumber) = extractCountryCode(from: phoneNumber)
        
        if !countryCode.isEmpty, let (flag, _) = countryCodes[countryCode] {
            return "\(flag) +\(countryCode) \(formatNationalNumber(nationalNumber, countryCode: countryCode))"
        } else if !phoneNumber.isEmpty {
            // No country code identified, return as is with better formatting
            return formatUnknownNumber(phoneNumber)
        }
        
        return phoneNumber
    }
    
    // Format the national part of the number according to country patterns
    private static func formatNationalNumber(_ number: String, countryCode: String) -> String {
        guard let (_, pattern) = countryCodes[countryCode] else {
            return number // No pattern found, return as is
        }
        
        var formattedNumber = ""
        var numberIndex = number.startIndex
        
        for char in pattern {
            if char == "X" {
                if numberIndex < number.endIndex {
                    formattedNumber.append(number[numberIndex])
                    numberIndex = number.index(after: numberIndex)
                } else {
                    break // Ran out of digits
                }
            } else {
                formattedNumber.append(char)
            }
        }
        
        // Add any remaining digits
        if numberIndex < number.endIndex {
            formattedNumber.append(" ")
            formattedNumber.append(String(number[numberIndex...]))
        }
        
        return formattedNumber
    }
    
    // Basic formatting for unknown number patterns
    private static func formatUnknownNumber(_ number: String) -> String {
        let cleanNumber = number.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        
        if cleanNumber.count <= 4 {
            return cleanNumber
        } else if cleanNumber.count <= 7 {
            let index = cleanNumber.index(cleanNumber.startIndex, offsetBy: cleanNumber.count - 4)
            return "\(cleanNumber[..<index]) \(cleanNumber[index...])"
        } else {
            let index1 = cleanNumber.index(cleanNumber.startIndex, offsetBy: cleanNumber.count - 7)
            let index2 = cleanNumber.index(cleanNumber.startIndex, offsetBy: cleanNumber.count - 4)
            return "\(cleanNumber[..<index1]) \(cleanNumber[index1..<index2]) \(cleanNumber[index2...])"
        }
    }
    
    // Validate a phone number
    static func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let cleanNumber = phoneNumber.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        
        // Check if it has a reasonable number of digits
        if cleanNumber.count < 7 || cleanNumber.count > 15 {
            return false
        }
        
        // Must contain only digits and optionally a + at the start
        let validChars = CharacterSet(charactersIn: "+0123456789")
        return cleanNumber.unicodeScalars.allSatisfy { validChars.contains($0) }
    }
    
    // Return the country flag if identified
    static func countryFlag(for phoneNumber: String) -> String? {
        let (countryCode, _) = extractCountryCode(from: phoneNumber)
        return countryCodes[countryCode]?.flag
    }
}

// Create a custom view for formatting a phone number with country indicator
struct FormattedPhoneNumber: View {
    let phoneNumber: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(PhoneNumberHelper.formatPhoneNumber(phoneNumber))
                .contentTransition(.numericText())
        }
    }
} 