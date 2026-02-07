import SwiftUI
import WebKit

struct LoginPage: View {
    @AppStorage("authToken") var authToken: String?
    @State private var isLoading: Double = 1.0
    @State private var injectScript: String? = nil
    

    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var loginAttempted = false
    @State private var isSuccess = false
    
    let loginURL = URL(string: "https://kiet.cybervidya.net/")!
    
  
    let userAgent = "" 
    

    let fastLoginScript = """
      (function() {
        var check = setInterval(function() {
            var token = localStorage.getItem('authenticationtoken');
            if (!token) {
                 token = sessionStorage.getItem('authenticationtoken');
            }
            if (!token) {

                 var match = document.cookie.match(new RegExp('(^| )authenticationtoken=([^;]+)'));
                 if (match) token = match[2];
            }

            if (token && token.length > 10) { 
                clearInterval(check);
                window.webkit.messageHandlers.ReactNativeWebView.postMessage(JSON.stringify({ token: token }));
            }
        }, 2000);
      })();
    """

    var body: some View {
        ZStack {

            BunkWebView(
                url: loginURL,
                script: fastLoginScript,
                userAgent: userAgent,
                isLoading: $isLoading,
                onMessage: handleMessage,
                injectScript: $injectScript
            )
            .edgesIgnoringSafeArea(.all)
            .opacity(isSuccess ? 0 : 1)
            

            if isLoading > 0.1 || isSuccess {
                ZStack {
                    Color.white.ignoresSafeArea()
                    if !isSuccess {
                        ProgressView("Loading...")
                    } else {

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .onAppear {
            BunkWebView.clearWebViewData()
        }
    }

    func handleMessage(_ message: String) {
        guard let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              var token = json["token"] as? String else { return }
            

        if token.hasPrefix("\"") && token.hasSuffix("\"") {
            token = String(token.dropFirst().dropLast())
        }
        if !token.contains("GlobalEducation") {
            token = "GlobalEducation \(token)"
        }
        
        print("\n🔑 TOKEN CAPTURED SUCCESS!")
        
        DispatchQueue.main.async {
            self.isSuccess = true
            

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.authToken = token
                UserDefaults.standard.set(token, forKey: "authToken")
                self.loginAttempted = false
            }
        }
    }
}


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
