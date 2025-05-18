import SwiftUI
import WebKit

struct LottieEmojiView: UIViewRepresentable {
    let emojiName: String
    let size: CGFloat
    let onLoadFailure: () -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let baseURL = "https://googlefonts.github.io/noto-emoji-animation/data"
        let url = "\(baseURL)/\(emojiName).json"
        
        let html = """
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
                    
                    animation.addEventListener('data_failed', function() {
                        window.webkit.messageHandlers.loadFailed.postMessage('');
                    });
                } catch(e) {
                    window.webkit.messageHandlers.loadFailed.postMessage('');
                }
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: LottieEmojiView
        
        init(_ parent: LottieEmojiView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Set up message handler for load failures
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

// Convenience view for use with Emotion enum
struct EmotionLottieView: View {
    let emotion: Emotion
    let size: CGFloat
    @State private var showFallback: Bool = false
    
    // Get emoji name based on emotion
    private var emojiName: String {
        switch emotion {
        case .happy: return "face_with_tears_of_joy"
        case .sad: return "crying_face"
        case .angry: return "pouting_face"
        case .surprised: return "astonished_face"
        case .fearful: return "fearful_face"
        case .disgusted: return "nauseated_face"
        case .neutral: return "neutral_face"
        }
    }
    
    var body: some View {
        if showFallback {
            // Fallback to SF Symbol icons when Lottie fails
            Image(systemName: emotion.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(emotion.color)
                .frame(width: size * 0.7, height: size * 0.7)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(emotion.color.opacity(0.2))
                        .frame(width: size, height: size)
                )
        } else {
            LottieEmojiView(emojiName: emojiName, size: size, onLoadFailure: {
                withAnimation {
                    showFallback = true
                }
            })
            .frame(width: size, height: size)
            .onAppear {
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
}