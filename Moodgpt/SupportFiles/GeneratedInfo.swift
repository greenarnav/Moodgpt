import Foundation
import UIKit

// This file contains info.plist declarations in code form
// You can access these values for debugging purposes
struct AppInfo {
    static let bundleId = "com.arnav.moody.Moodgpt"
    static let appName = "Moodgpt"
    static let version = "1.0"
    
    static let permissionMessages = [
        "NSContactsUsageDescription": "MoodGPT needs access to your contacts to show their mood based on location.",
        "NSLocationWhenInUseUsageDescription": "MoodGPT needs your location to show your city's mood and nearby contacts.",
        "NSLocationAlwaysUsageDescription": "MoodGPT needs your location to show your city's mood and nearby contacts.",
        "NSLocationAlwaysAndWhenInUseUsageDescription": "MoodGPT needs your location to show your city's mood and nearby contacts.",
        "NSCalendarsUsageDescription": "MoodGPT needs access to your calendar to correlate your schedule with mood patterns and provide better insights.",
        "NSHealthShareUsageDescription": "MoodGPT needs access to your health data to analyze and provide insights on how your physical health affects your mood patterns.",
        "NSHealthUpdateUsageDescription": "MoodGPT needs to update health data to track the relationship between your activities and mood variations."
    ]
    
    static func initialize() {
        // This is called automatically when the app launches
        // No implementation needed for now - just ensuring the file is included in the build
    }
} 