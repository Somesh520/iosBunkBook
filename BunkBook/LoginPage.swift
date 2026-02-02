import SwiftUI
import WebKit

struct LoginPage: View {
    @AppStorage("authToken") var authToken: String? // 💾 Stores Raw Token
    @State private var isLoading: Double = 1.0 // Start loading immediately
    
    let loginURL = URL(string: "https://kiet.cybervidya.net/")!
    
    // 🛡️ ANTI-BOT USER AGENT (iPhone 15 Pro Max on iOS 17.5)
    // Yeh exact string Captcha ko trust dilati hai ki hum mobile hain.
    let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
    
    // ⚡️ Fast Login Script (Token Capture)
    let fastLoginScript = """
      (function() {
        // 3. 🔥 ALWAYS Clear Storage on Initial Load (Prevents Stale Tokens)
        try {
            window.localStorage.clear();
            window.sessionStorage.clear();
            console.log('🧹 Storage cleared to force fresh token');
        } catch(e) { console.log('Clear failed:', e); }

        // 4. Poll for NEW Token
        var check = setInterval(function() {
            var token = localStorage.getItem('authenticationtoken');
            if (token && token.length > 10) { // Ensure it's not empty/garbage
                clearInterval(check);
                // Use the correct message handler name 'ReactNativeWebView' as expected by the Coordinator
                window.webkit.messageHandlers.ReactNativeWebView.postMessage(JSON.stringify({ token: token }));
            }
        }, 500); // Slower poll to allow login to happen
      })();
    """

    var body: some View {
        ZStack {
            WebView(url: loginURL, script: fastLoginScript, userAgent: userAgent, isLoading: $isLoading, onMessage: handleMessage)
                .ignoresSafeArea()
            
            if isLoading > 0.1 {
                ZStack {
                    Color.white.ignoresSafeArea()
                    VStack(spacing: 15) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Connecting to KIET Portal...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .transition(.opacity.animation(.easeInOut))
            }
        }
        .onAppear {
            print("🧹 Resetting WebView Session...")
            WebView.clearWebViewData()
        }
    }
    
    func handleMessage(_ message: String) {
        guard let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              var token = json["token"] as? String else { return }
            
        // 🧹 Clean Quote from JSON string if present
        if token.hasPrefix("\"") && token.hasSuffix("\"") {
            token = String(token.dropFirst().dropLast())
        }

        // 🛡️ Robust Prefix Logic (Matches Android)
        // Android: if (!finalToken.includes('GlobalEducation')) finalToken = `GlobalEducation ${finalToken}`;
        if !token.contains("GlobalEducation") {
            token = "GlobalEducation \(token)"
        }
        
        print("\n🔑 TOKEN CAPTURED SUCCESS!")
        
        // ✅ Save Token & Auto-Redirect
        DispatchQueue.main.async {
            self.authToken = token
            UserDefaults.standard.set(token, forKey: "authToken") // Force Save
        }
    }
}

// 🌐 WEBVIEW COMPONENT (With Anti-Bot Fixes)
struct WebView: UIViewRepresentable {
    let url: URL
    let script: String
    let userAgent: String
    @Binding var isLoading: Double
    var onMessage: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        // 🔥 CRITICAL FIX: Default Data Store use karo (Cookies/Cache enable)
        // Isse website ko lagega ye Real Browser hai, Bot nahi.
        config.websiteDataStore = WKWebsiteDataStore.default()
        
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "ReactNativeWebView")
        config.userContentController = controller
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        // 🔥 Set User Agent on WebView Instance
        webView.customUserAgent = userAgent
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url == nil {
            var request = URLRequest(url: url)
            // 🔥 Headers mein bhi User-Agent bhejo
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            uiView.load(request)
        }
    }

    static func clearWebViewData() {
        // Sirf tab call karna jab logout karein
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { WKWebsiteDataStore.default().removeData(ofTypes: $0.dataTypes, for: [$0], completionHandler: {}) }
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView
        init(_ parent: WebView) { self.parent = parent }
        
        func userContentController(_ cc: WKUserContentController, didReceive msg: WKScriptMessage) {
            if let body = msg.body as? String { parent.onMessage(body) }
        }
        
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async { self.parent.isLoading = 1.0 }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript(parent.script)
            // Delay removing loader slightly to avoid white flash
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.parent.isLoading = 0.0
            }
        }
    }
}
