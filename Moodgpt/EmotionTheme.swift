import SwiftUI

struct EmotionTheme {
    static func gradientColors(for emotion: Emotion) -> [Color] {
        switch emotion {
        case .happy: 
            return [Color.yellow.opacity(0.7), Color.orange.opacity(0.7)]
        case .sad: 
            return [Color.blue.opacity(0.7), Color.indigo.opacity(0.7)]
        case .angry: 
            return [Color.red.opacity(0.7), Color.pink.opacity(0.7)]
        case .surprised: 
            return [Color.orange.opacity(0.7), Color.yellow.opacity(0.7)]
        case .fearful: 
            return [Color.purple.opacity(0.7), Color.indigo.opacity(0.7)]
        case .disgusted: 
            return [Color.green.opacity(0.7), Color.mint.opacity(0.7)]
        case .neutral: 
            return [Color.gray.opacity(0.7), Color.gray.opacity(0.5)]
        }
    }
} 