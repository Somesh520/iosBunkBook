import SwiftUI

@main
struct BunkBookApp: App {
    @AppStorage("authToken") var authToken: String?
    @State private var isSplashFinished = false
    
    // ✅ Shared ViewModel taaki data Splash Screen se Home tak flow kare
    @StateObject private var sharedViewModel = HomeViewModel()

    var body: some Scene {
        WindowGroup {
            if isSplashFinished {
                if authToken != nil && !authToken!.isEmpty {
                    // Agar login hai -> Main Tab View (Jo ContentView.swift mein hai)
                    MainTabView(viewModel: sharedViewModel)
                } else {
                    // Login Page
                    LoginPage()
                }
            } else {
                // Splash Screen (Data Fetching Start)
                SplashScreenView(isFinished: $isSplashFinished, viewModel: sharedViewModel)
            }
        }
        .onChange(of: authToken) { oldToken, newToken in
            if let token = newToken, !token.isEmpty {
                print("🔄 Token detected! Refreshing ViewModel...")
                Task { await sharedViewModel.fetchData() }
            }
        }
    }
}
