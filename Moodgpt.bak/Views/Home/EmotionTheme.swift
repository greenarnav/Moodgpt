import SwiftUI

struct EmotionTheme {
    // Function to get gradient colors for each emotion
    static func gradientColors(for emotion: String) -> [Color] {
        switch emotion.lowercased() {
        case "happy", "joyful", "positive", "very positive":
            // Pink gradient for positive instead of yellow
            return [Color.pink.opacity(0.7), Color.purple.opacity(0.4), Color.pink.opacity(0.3)]
            
        case "sad", "negative", "very negative":
            // Cool, blue gradient
            return [Color.blue.opacity(0.7), Color.indigo.opacity(0.6), Color.blue.opacity(0.3)]
            
        case "angry":
            // Intense red gradient
            return [Color.red.opacity(0.7), Color.pink.opacity(0.6), Color.red.opacity(0.3)]
            
        case "fear", "fearful":
            // Deep purple gradient
            return [Color.purple.opacity(0.7), Color.indigo.opacity(0.6), Color.purple.opacity(0.3)]
            
        case "excited":
            // Now using yellow for excited (moved from positive)
            return [Color.yellow.opacity(0.7), Color.orange.opacity(0.6), Color.yellow.opacity(0.3)]
            
        case "calm":
            // Serene teal/mint gradient
            return [Color.mint.opacity(0.7), Color.teal.opacity(0.5), Color.mint.opacity(0.3)]
            
        case "tired":
            // Muted, soft gradient
            return [Color.gray.opacity(0.7), Color.blue.opacity(0.3), Color.gray.opacity(0.2)]
            
        case "surprised":
            // Bright, contrasting gradient
            return [Color.orange.opacity(0.7), Color.yellow.opacity(0.5), Color.orange.opacity(0.3)]
            
        case "confident":
            // Rich, deep gradient
            return [Color.indigo.opacity(0.7), Color.purple.opacity(0.5), Color.blue.opacity(0.3)]
            
        case "neutral", "mixed":
            // Balanced, neutral gradient
            return [Color.gray.opacity(0.5), Color.blue.opacity(0.3), Color.white.opacity(0.3)]
            
        case "disgusted":
            // Green-based gradient
            return [Color.green.opacity(0.7), Color.teal.opacity(0.5), Color.green.opacity(0.3)]
            
        default:
            // Default gradient
            return [Color.blue.opacity(0.6), Color.purple.opacity(0.5), Color.white.opacity(0.3)]
        }
    }

    // Card background color based on emotion
    static func cardColor(for emotion: String) -> Color {
        switch emotion.lowercased() {
        case "happy", "joyful", "positive", "very positive":
            return Color.pink
        case "sad", "negative", "very negative":
            return Color.blue
        case "angry":
            return Color.red
        case "fear", "fearful":
            return Color.purple
        case "excited":
            return Color.yellow
        case "calm":
            return Color.mint
        case "tired":
            return Color.gray
        case "surprised":
            return Color.orange
        case "confident":
            return Color.indigo
        case "neutral", "mixed":
            return Color.gray
        case "disgusted":
            return Color.green
        default:
            return Color.gray
        }
    }
    
    // Gets the gradient for a specific Emotion type
    static func gradientColors(for emotion: Emotion) -> [Color] {
        return gradientColors(for: emotion.description)
    }
    
    // Gets the card color for a specific Emotion type
    static func cardColor(for emotion: Emotion) -> Color {
        return cardColor(for: emotion.description)
    }
} 