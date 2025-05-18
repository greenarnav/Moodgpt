import SwiftUI

struct TimelineItemView: View {
    let entry: TimelineEntry
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(entry.day)
                .font(.footnote)
                .foregroundColor(.white)
            
            Text(entry.timeSegment)
                .font(.footnote)
                .foregroundColor(.white)
            
            // Replace static emoji with animated emoji
            AnimatedEmoji(
                emoji: entry.emotion.emoji,
                size: 32,
                animation: entry.emotion.animation
            )
            .padding(.vertical, 1)
            
            Text(entry.emotion.description)
                .font(.caption)
                .foregroundColor(.white)
            
            if entry.isNow {
                Text("NOW")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 1)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: EmotionTheme.gradientColors(for: entry.emotion).map { $0.opacity(0.75) }),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(entry.isNow ? Color.white : Color.clear, lineWidth: 2)
                )
        )
        .frame(width: 90)
    }
} 