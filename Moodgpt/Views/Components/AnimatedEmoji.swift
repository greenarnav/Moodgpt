import SwiftUI

struct AnimatedEmoji: View {
    let emoji: String
    let size: CGFloat
    let animation: EmojiAnimation
    
    @State private var animationState: CGFloat = 0
    @State private var rotation: CGFloat = 0
    @State private var scale: CGFloat = 1
    @State private var opacity: CGFloat = 1
    
    init(emoji: String, size: CGFloat = 40, animation: EmojiAnimation = .pulse) {
        self.emoji = emoji
        self.size = size
        self.animation = animation
    }
    
    enum EmojiAnimation {
        case pulse
        case bounce
        case spin
        case wave
        case fadeInOut
        case shake
    }
    
    var body: some View {
        Text(emoji)
            .font(.system(size: size))
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(animation == .shake ? nil : .easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    switch animation {
                    case .pulse:
                        scale = 1.2
                    case .bounce:
                        animationState = 1
                    case .spin:
                        rotation = 360
                    case .wave:
                        animationState = 1
                    case .fadeInOut:
                        opacity = 0.5
                    case .shake:
                        // Shake is handled with a different animation
                        break
                    }
                }
                
                if animation == .shake {
                    withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                        rotation = 15
                    }
                }
            }
            .modifier(BounceModifier(animationValue: animationState, animation: animation))
    }
}

struct BounceModifier: GeometryEffect {
    var animationValue: CGFloat
    var animation: AnimatedEmoji.EmojiAnimation
    
    var animatableData: CGFloat {
        get { animationValue }
        set { animationValue = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        switch animation {
        case .bounce:
            let bounce = sin(animationValue * .pi * 2) * 10
            return ProjectionTransform(CGAffineTransform(translationX: 0, y: bounce))
        case .wave:
            let wave = sin(animationValue * .pi * 2) * 5
            return ProjectionTransform(CGAffineTransform(translationX: wave, y: 0))
        default:
            return ProjectionTransform(.identity)
        }
    }
}

// Preview for the animated emoji
struct AnimatedEmoji_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AnimatedEmoji(emoji: "😊", animation: .pulse)
            AnimatedEmoji(emoji: "🎉", animation: .bounce)
            AnimatedEmoji(emoji: "🌟", animation: .spin)
            AnimatedEmoji(emoji: "👋", animation: .wave)
            AnimatedEmoji(emoji: "❤️", animation: .fadeInOut)
            AnimatedEmoji(emoji: "😂", animation: .shake)
            AnimatedEmoji(emoji: "🤔", size: 60, animation: .pulse)
        }
        .padding()
    }
} 