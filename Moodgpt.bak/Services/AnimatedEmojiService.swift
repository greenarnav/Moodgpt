import Foundation
import Combine
import SwiftUI
import WebKit

// Service for handling animated emojis
class AnimatedEmojiService {
    static let shared = AnimatedEmojiService()
    
    private let baseURL = "https://googlefonts.github.io/noto-emoji-animation/data"
    private var cancellables = Set<AnyCancellable>()
    private var cache = NSCache<NSString, NSData>()
    
    private init() {
        // Configure cache
        cache.countLimit = 20
        cache.totalCostLimit = 5 * 1024 * 1024 // 5MB
    }
    
    // Get animation data for a specific emoji
    func getAnimationData(for emojiName: String) -> AnyPublisher<Data, Error> {
        let url = "\(baseURL)/\(emojiName).json"
        
        // Check cache first
        if let cachedData = cache.object(forKey: url as NSString) {
            return Just(cachedData as Data)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: url) else {
            return Fail(error: NSError(domain: "Invalid URL", code: 0, userInfo: nil))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in data }
            .mapError { $0 as Error }
            .handleEvents(receiveOutput: { [weak self] data in
                // Cache the result
                self?.cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
            })
            .eraseToAnyPublisher()
    }
    
    // Get HTML for a Lottie animation
    func getLottieHTML(for emojiName: String, size: CGFloat) -> String {
        let url = "\(baseURL)/\(emojiName).json"
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <script src="https://cdnjs.cloudflare.com/ajax/libs/lottie-web/5.9.6/lottie.min.js"></script>
            <style>
                body { margin: 0; padding: 0; background-color: transparent; overflow: hidden; }
                #lottie { width: \(size)px; height: \(size)px; }
            </style>
        </head>
        <body>
            <div id="lottie"></div>
            <script>
                var animation;
                try {
                    animation = lottie.loadAnimation({
                        container: document.getElementById('lottie'),
                        renderer: 'svg',
                        loop: true,
                        autoplay: true,
                        path: '\(url)'
                    });
                    
                    // Handle loading failures
                    animation.addEventListener('data_failed', function() {
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.loadFailed) {
                            window.webkit.messageHandlers.loadFailed.postMessage('');
                        }
                    });
                    
                    // Also set a timeout in case animation loads but doesn't play properly
                    setTimeout(function() {
                        if (animation && !animation.isLoaded) {
                            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.loadFailed) {
                                window.webkit.messageHandlers.loadFailed.postMessage('');
                            }
                        }
                    }, 2000);
                } catch(e) {
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.loadFailed) {
                        window.webkit.messageHandlers.loadFailed.postMessage('');
                    }
                }
            </script>
        </body>
        </html>
        """
    }
    
    // Get the appropriate emoji name for an emotion
    func getEmojiNameForEmotion(_ emotion: Emotion) -> String {
        switch emotion {
        case .happy:
            return "face_with_tears_of_joy"
        case .sad:
            return "crying_face"
        case .angry:
            return "pouting_face"
        case .surprised:
            return "astonished_face"
        case .fearful:
            return "fearful_face"
        case .disgusted:
            return "nauseated_face"
        case .neutral:
            return "neutral_face"
        }
    }
    
    // Fetch and cache all emotion animations for faster access
    func precacheEmotionAnimations() {
        for emotion in Emotion.allCases {
            let emojiName = getEmojiNameForEmotion(emotion)
            getAnimationData(for: emojiName)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)
        }
    }
}

// Enhanced Lottie animation view using WKWebView
struct EnhancedLottieView: UIViewRepresentable {
    let emojiName: String
    let size: CGFloat
    let onLoadFailure: () -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        
        // For better performance
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = AnimatedEmojiService.shared.getLottieHTML(for: emojiName, size: size)
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: EnhancedLottieView
        
        init(_ parent: EnhancedLottieView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Add script to handle load failures
            let script = """
            var animation = lottie.getRegisteredAnimations()[0];
            if (animation) {
                animation.addEventListener('data_failed', function() {
                    window.webkit.messageHandlers.loadFailed.postMessage('');
                });
            } else {
                window.webkit.messageHandlers.loadFailed.postMessage('');
            }
            """
            
            webView.evaluateJavaScript(script) { _, error in
                if error != nil {
                    self.parent.onLoadFailure()
                }
            }
            
            // Set up message handler
            webView.configuration.userContentController.add(self, name: "loadFailed")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.onLoadFailure()
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.onLoadFailure()
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "loadFailed" {
                DispatchQueue.main.async {
                    self.parent.onLoadFailure()
                }
            }
        }
    }
}

// Enhanced Emotion Lottie View
struct EnhancedEmotionView: View {
    let emotion: Emotion
    let size: CGFloat
    @State private var isLoading = true
    @State private var showFallback = false
    
    var body: some View {
        ZStack {
            if showFallback {
                // Fallback to SF Symbol icons when Lottie fails
                Image(systemName: emotion.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(emotion.color)
                    .frame(width: size * 0.7, height: size * 0.7)
                    .background(
                        Circle()
                            .fill(emotion.color.opacity(0.2))
                            .frame(width: size, height: size)
                    )
            } else {
                // Show loading indicator until animation is ready
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                }
                
                EnhancedLottieView(
                    emojiName: AnimatedEmojiService.shared.getEmojiNameForEmotion(emotion),
                    size: size,
                    onLoadFailure: {
                        withAnimation {
                            showFallback = true
                            isLoading = false
                        }
                    }
                )
                .onAppear {
                    // Add a short delay to show loading state
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isLoading = false
                    }
                    
                    // Set a timeout for loading animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        if !showFallback {
                            withAnimation {
                                showFallback = true
                            }
                        }
                    }
                }
            }
        }
        .frame(width: size, height: size)
    }
} 