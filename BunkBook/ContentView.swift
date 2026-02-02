import SwiftUI
import UIKit

struct MainTabView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        TabView {
            // 🏠 Home Tab
            HomeScreen(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            // 📅 Schedule Tab
            ScheduleScreen()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Time Table")
                }
            
            // 📝 Exams Tab (UPDATED ✅)
            ExamMainView(viewModel: viewModel) // 🔥 Yahan change kiya hai
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Exams")
                }
            
            // ℹ️ About Tab
            AboutScreen()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("About")
                }
        }
        .accentColor(.blue)
        .onAppear {
            // Tab Bar Appearance Fix
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
