import Foundation

struct CityMood {
    let city: String
    let dominantEmotion: Emotion
    let emotionPercentages: [String: Double]
    let lastUpdated: Date
    
    // Dictionary mapping area codes to cities
    static let areaCodesToCity: [String: String] = [
        "212": "New York City",
        "917": "New York City",
        "213": "Los Angeles",
        "323": "Los Angeles",
        "312": "Chicago",
        "415": "San Francisco",
        "305": "Miami",
        "202": "Washington DC",
        "713": "Houston",
        "214": "Dallas",
        "404": "Atlanta",
        "617": "Boston",
        "702": "Las Vegas",
        "303": "Denver",
        "615": "Nashville",
        "503": "Portland",
        "206": "Seattle",
        "512": "Austin",
        // Add more as needed
    ]
    
    static func getCityFromAreaCode(_ areaCode: String) -> String? {
        return areaCodesToCity[areaCode]
    }
} 