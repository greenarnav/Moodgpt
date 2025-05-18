import SwiftUI

// A simple view for displaying emojis without animations
struct StaticEmojiView: View {
    let emotion: Emotion
    let size: CGFloat
    
    init(emotion: Emotion, size: CGFloat = 40) {
        self.emotion = emotion
        self.size = size
    }
    
    var body: some View {
        Text(emotion.emoji)
            .font(.system(size: size))
    }
}

// For SF Symbol alternative
struct SFSymbolEmojiView: View {
    let emotion: Emotion
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(emotion.color.opacity(0.2))
                .frame(width: size, height: size)
            
            Image(systemName: emotion.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(emotion.color)
                .frame(width: size * 0.5, height: size * 0.5)
        }
    }
} 