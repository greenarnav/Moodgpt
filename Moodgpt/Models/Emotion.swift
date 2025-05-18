import Foundation
import SwiftUI

enum Emotion: String, Identifiable, CaseIterable {
    case happy
    case sad
    case angry
    case surprised
    case fearful
    case disgusted
    case neutral
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .happy: return "Happy"
        case .sad: return "Sad"
        case .angry: return "Angry"
        case .surprised: return "Surprised"
        case .fearful: return "Fearful"
        case .disgusted: return "Disgusted"
        case .neutral: return "Neutral"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .sad: return .blue
        case .angry: return .red
        case .surprised: return .orange
        case .fearful: return .purple
        case .disgusted: return .green
        case .neutral: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .happy: return "face.smiling"
        case .sad: return "face.sad"
        case .angry: return "face.angry"
        case .surprised: return "face.dashed"
        case .fearful: return "face.concerned"
        case .disgusted: return "face.grimace"
        case .neutral: return "face.neutral"
        }
    }
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .angry: return "😡"
        case .surprised: return "😲"
        case .fearful: return "😨"
        case .disgusted: return "🤢"
        case .neutral: return "😐"
        }
    }
    
    var animation: AnimatedEmoji.EmojiAnimation {
        switch self {
        case .happy: return .bounce
        case .sad: return .fadeInOut
        case .angry: return .shake
        case .surprised: return .pulse
        case .fearful: return .wave
        case .disgusted: return .spin
        case .neutral: return .pulse
        }
    }
    
    static func fromMoodScore(_ score: Double) -> Emotion {
        switch score {
        case 0.8...1.0: return .happy
        case 0.6..<0.8: return .surprised
        case 0.4..<0.6: return .neutral
        case 0.2..<0.4: return .sad
        case 0.0..<0.2: return .angry
        default: return .neutral
        }
    }
} 