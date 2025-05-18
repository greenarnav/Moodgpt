import Foundation
import SwiftUI

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String
    var city: String?
    var emotion: Emotion
    var notes: String?
    var interests: [String] = []
    var thoughtsAndFeelings: String?
    var factsAndFigures: String?
    var conversationStarters: [String] = []
    
    // Get country code and national number from the phone number
    var phoneNumberComponents: (countryCode: String, nationalNumber: String) {
        return PhoneNumberHelper.extractCountryCode(from: phoneNumber)
    }
    
    // Get country code if available
    var countryCode: String? {
        let code = phoneNumberComponents.countryCode
        return code.isEmpty ? nil : code
    }
    
    // Get formatted phone number with country code if available
    var formattedPhoneNumber: String {
        return PhoneNumberHelper.formatPhoneNumber(phoneNumber)
    }
    
    // Get country flag if available
    var countryFlag: String? {
        guard let code = countryCode else { return nil }
        return PhoneNumberHelper.countryCodes[code]?.flag
    }
    
    // Legacy method - keeping for backward compatibility
    var areaCode: String? {
        // For international numbers, this would be the country code
        if let countryCode = self.countryCode, !countryCode.isEmpty {
            return countryCode
        }
        
        // For US numbers, extract area code
        let digits = phoneNumber.filter { $0.isNumber }
        guard digits.count >= 3 else { return nil }
        return String(digits.prefix(3))
    }
    
    // Sample conversation starters based on emotion
    func getConversationStarters() -> [String] {
        if !conversationStarters.isEmpty {
            return conversationStarters
        }
        
        // Default conversation starters based on emotion
        switch emotion {
        case .happy:
            return [
                "What made your day so great?",
                "Any exciting news to share?",
                "You seem to be in a great mood! What's up?"
            ]
        case .sad:
            return [
                "Just checking in - how are you holding up?",
                "Is there anything I can do to help?",
                "I'm here if you need to talk"
            ]
        case .angry:
            return [
                "Sounds like you've had a rough time. Want to talk about it?",
                "I'm here to listen if you want to vent",
                "Need some space? Just let me know"
            ]
        case .surprised:
            return [
                "What's got you so surprised?",
                "Anything unexpected happen lately?",
                "You seem shocked! What's new?"
            ]
        case .fearful:
            return [
                "Is everything okay? I'm here for you",
                "What's worrying you? Maybe I can help",
                "Just wanted you to know I'm thinking of you"
            ]
        case .disgusted:
            return [
                "Sounds like something really bothered you",
                "Want to talk about what's going on?",
                "Hope your day gets better"
            ]
        case .neutral:
            return [
                "How's your day going?",
                "Any plans for the weekend?",
                "What have you been up to lately?"
            ]
        }
    }
    
    // Get a description of the emotion
    func getEmotionDescription() -> String {
        switch emotion {
        case .happy:
            return "They're feeling joyful and content! This is a great time to share positive news or plan fun activities together."
        case .sad:
            return "They seem to be feeling down. A little compassion and understanding could go a long way right now."
        case .angry:
            return "They're experiencing frustration or anger. It might be best to give them space or listen if they need to vent."
        case .surprised:
            return "Something unexpected has happened in their life. They might be processing new information or adjusting to change."
        case .fearful:
            return "They're feeling anxious or worried about something. Reassurance and support would be appreciated."
        case .disgusted:
            return "They're encountering something that doesn't align with their values. They might need validation for their feelings."
        case .neutral:
            return "They're in a balanced emotional state - neither particularly positive nor negative."
        }
    }
} 