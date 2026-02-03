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

// ...
    var body: some View {
        ZStack {
            BunkWebView(url: loginURL, script: fastLoginScript, userAgent: userAgent, isLoading: $isLoading, onMessage: handleMessage)
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
            BunkWebView.clearWebViewData()
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

