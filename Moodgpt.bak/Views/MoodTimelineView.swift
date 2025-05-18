import SwiftUI

struct MoodTimelineView: View {
    let entries: [TimelineEntry]
    var onItemSelected: (TimelineEntry) -> Void = { _ in }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Timeline")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(entries) { entry in
                        Button {
                            onItemSelected(entry)
                        } label: {
                            VStack(alignment: .center, spacing: 2) {
                                Text(entry.day)
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                
                                Text(entry.timeSegment)
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                
                                // Use animated emojis based on emotion
                                AnimatedEmoji(
                                    emoji: entry.emotion.emoji,
                                    size: 32,
                                    animation: getTimelineAnimation(for: entry.emotion)
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
                                            gradient: Gradient(colors: getGradientColors(for: entry.emotion)),
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
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    // Custom animation mapping for timeline items
    private func getTimelineAnimation(for emotion: Emotion) -> AnimatedEmoji.EmojiAnimation {
        switch emotion {
        case .happy: return .bounce
        case .sad: return .fadeInOut
        case .angry: return .shake
        case .surprised: return .pulse
        case .fearful: return .wave
        case .disgusted: return .spin
        case .neutral: return .pulse
        }
    }
    
    // Custom gradient colors for timeline items
    private func getGradientColors(for emotion: Emotion) -> [Color] {
        switch emotion {
        case .happy: return [Color.yellow.opacity(0.7), Color.orange.opacity(0.7)]
        case .sad: return [Color.blue.opacity(0.7), Color.indigo.opacity(0.7)]
        case .angry: return [Color.red.opacity(0.7), Color.pink.opacity(0.7)]
        case .surprised: return [Color.orange.opacity(0.7), Color.yellow.opacity(0.7)]
        case .fearful: return [Color.purple.opacity(0.7), Color.indigo.opacity(0.7)]
        case .disgusted: return [Color.green.opacity(0.7), Color.mint.opacity(0.7)]
        case .neutral: return [Color.gray.opacity(0.7), Color.gray.opacity(0.5)]
        }
    }
} 