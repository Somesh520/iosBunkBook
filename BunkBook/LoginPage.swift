import SwiftUI
import WebKit

struct LoginPage: View {
    @AppStorage("authToken") var authToken: String? // 💾 Stores Raw Token
    @State private var isLoading: Double = 1.0
    @State private var injectScript: String? = nil
    
    // 📝 Native Form State
    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var loginAttempted = false
    @State private var errorMessage: String?
    
    let loginURL = URL(string: "https://kiet.cybervidya.net/")!
    
    // 🛡️ ANTI-BOT USER AGENT
    let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
    
    // ⚡️ Fast Login Script (Token Capture - Runs Continuously)
    let fastLoginScript = """
      (function() {
        // Poll for NEW Token
        var check = setInterval(function() {
            var token = localStorage.getItem('authenticationtoken');
            if (token && token.length > 10) { 
                clearInterval(check);
                window.webkit.messageHandlers.ReactNativeWebView.postMessage(JSON.stringify({ token: token }));
            }
        }, 500);
      })();
    """

    var body: some View {
        ZStack {
            // 🖼️ Background Layer
            backgrounView
                .ignoresSafeArea()
            
            // 🕸️ Hidden WebView (The Engine)
            // It MUST be in hierarchy to work, but we hide it visually.
            BunkWebView(
                url: loginURL,
                script: fastLoginScript,
                userAgent: userAgent,
                isLoading: $isLoading,
                onMessage: handleMessage,
                injectScript: $injectScript
            )
            .frame(width: 1, height: 1) // Tiny frame
            .opacity(0.001) // Invisible
            .allowsHitTesting(false) // No touches
            
            // 💎 Glassmorphic Login Form
            ScrollView {
                VStack(spacing: 40) {
                    Spacer().frame(height: 100)
                    
                    // 🎓 Logo / Title
                    VStack(spacing: 10) {
                        Image(systemName: "graduationcap.fill") // Placeholder for App Logo
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text("BunkBook")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5)
                        
                        Text("Your Attendance Buddy")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    // 🧊 Liquid Glass Card
                    VStack(spacing: 25) {
                        Text("Sign In")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // 👤 Username Field
                        customTextField(icon: "person.fill", placeholder: "Student ID / Username", text: $username)
                        
                        // 🔒 Password Field
                        customPasswordField(icon: "lock.fill", placeholder: "Password", text: $password, isVisible: $showPassword)
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                        }
                        
                        // 🚀 Login Button
                        Button(action: performNativeLogin) {
                            HStack {
                                if isLoading > 0.1 && loginAttempted {
                                    ProgressView()
                                        .tint(.blue)
                                } else {
                                    Text("Login")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 55) // Tall button
                            .background(Color.white)
                            .foregroundColor(.blue) // Brand color text
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                        }
                        .disabled(isLoading > 0.1 && loginAttempted)
                    }
                    .padding(30)
                    .background(.ultraThinMaterial) // 💎 The Glass Effect
                    .cornerRadius(30)
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            BunkWebView.clearWebViewData()
        }
    }
    
    // 🎨 Components
    
    var backgrounView: some View {
        ZStack {
            // Priority 1: User provided image "LoginBackground"
            // Priority 2: Fallback Gradient
            GeometryReader { proxy in
                Image("LoginBackground") // Expects this asset
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .overlay(Color.black.opacity(0.3)) // Dark overlay for text readability
            }
            .background(
                // Fallback Gradient
                LinearGradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        }
    }
    
    func customTextField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
            
            TextField("", text: text)
                .placeholder(when: text.wrappedValue.isEmpty) {
                    Text(placeholder).foregroundColor(.white.opacity(0.6))
                }
                .foregroundColor(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
    
    func customPasswordField(icon: String, placeholder: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
            
            if isVisible.wrappedValue {
                TextField("", text: text)
                    .placeholder(when: text.wrappedValue.isEmpty) {
                        Text(placeholder).foregroundColor(.white.opacity(0.6))
                    }
                    .foregroundColor(.white)
            } else {
                SecureField("", text: text)
                    .placeholder(when: text.wrappedValue.isEmpty) {
                        Text(placeholder).foregroundColor(.white.opacity(0.6))
                    }
                    .foregroundColor(.white)
            }
            
            Button(action: { isVisible.wrappedValue.toggle() }) {
                Image(systemName: isVisible.wrappedValue ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
    
    // 🧠 Logic
    
    func performNativeLogin() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter username and password"
            return
        }
        
        loginAttempted = true
        errorMessage = nil
        
        // 💉 JS Injection: Robustly find fields & Submit
        let safeUser = username.replacingOccurrences(of: "'", with: "\\'")
        let safePass = password.replacingOccurrences(of: "'", with: "\\'")
        
        let js = """
        (function() {
            function setVal(selector, val) {
                var el = document.querySelector(selector);
                if (el) {
                    el.value = val;
                    el.dispatchEvent(new Event('input', { bubbles: true }));
                    el.dispatchEvent(new Event('change', { bubbles: true }));
                    return true; // Success
                }
                return false;
            }
            
            // 🔍 Try Multiple Selectors (Angular/React often vary)
            // 1. Username
            var u1 = setVal('input[type="text"]', '\(safeUser)');
            var u2 = setVal('input[name="username"]', '\(safeUser)');
            var u3 = setVal('input[placeholder*="User"]', '\(safeUser)');
            
            // 2. Password
            var p1 = setVal('input[type="password"]', '\(safePass)');
            
            // 3. Click Login
            if (u1 || u2 || u3) {
                 var btn = document.querySelector('button[type="submit"]') || 
                           document.querySelector('button.btn-primary') ||
                           document.querySelector('input[type="submit"]');
                 if(btn) { 
                     btn.click(); 
                     return "CLICKED";
                 }
            }
            return "FAILED";
        })();
        """
        
        // 🚀 Inject!
        injectScript = js
        
        // Reset loading state if nothing happens after 10s
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.authToken == nil {
                self.loginAttempted = false
                self.errorMessage = "Login timed out. Please check your credentials."
            }
        }
    }
    
    func handleMessage(_ message: String) {
        guard let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              var token = json["token"] as? String else { return }
            
        // 🧹 Clean Quote from JSON string
        if token.hasPrefix("\"") && token.hasSuffix("\"") {
            token = String(token.dropFirst().dropLast())
        }
        if !token.contains("GlobalEducation") {
            token = "GlobalEducation \(token)"
        }
        
        print("\n🔑 TOKEN CAPTURED SUCCESS!")
        
        DispatchQueue.main.async {
            self.authToken = token
            UserDefaults.standard.set(token, forKey: "authToken")
            self.loginAttempted = false
        }
    }
}

// Helper for Placeholder Color
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
