import SwiftUI

struct DeveloperProfile: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let color: Color
    let linkedinURL: String
    let image: String // Placeholder for now
}

struct AboutScreen: View {
    @Environment(\.openURL) var openURL
    
    let developers = [
        DeveloperProfile(name: "Satyam Singh", role: "Developer", color: .green, linkedinURL: "https://www.linkedin.com/in/satyam-singh-4510b9323/", image: "person.fill"),
        DeveloperProfile(name: "Somesh Tiwari", role: "Developer", color: .blue, linkedinURL: "https://www.linkedin.com/in/somesh-tiwari-236555322/", image: "person.fill"),
        DeveloperProfile(name: "Vishek Tyagi", role: "Developer", color: .orange, linkedinURL: "https://www.linkedin.com/in/vishek-tyagi-a42b18313/", image: "person.fill")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // 🎨 Header (Original Simple Style)
                ZStack {
                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(height: 200)
                        .cornerRadius(20)
                        .offset(y: -50)
                        .padding(.bottom, -50)
                    
                    VStack {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                        
                        Text("BunkBook")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("v1.0.1")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 2)
                    }
                    .padding(.top, 40)
                }
                
                // 👨‍💻 Developers Section
                Text("Meet the Developers")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    ForEach(developers) { dev in
                        DeveloperCard(profile: dev)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Footer
                Text("Made with ❤️ for KIET Students")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                // 🔔 Test Notification Button (Debug)
                Button("Test Notification (5s Delay)") {
                    NotificationManager.shared.scheduleNotification(
                        title: "BunkBook",
                        body: "This is a test notification!",
                        timeInterval: 5
                    )
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
    }
}

// Simple Original Card + LinkedIn
struct DeveloperCard: View {
    let profile: DeveloperProfile
    @Environment(\.openURL) var openURL
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(profile.color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Text(String(profile.name.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(profile.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(profile.role)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            // Link Button
            Button(action: {
                if let url = URL(string: profile.linkedinURL) {
                    openURL(url)
                }
            }) {
                Image(systemName: "link")
                    .font(.system(size: 20, weight: .semibold)) // Bigger icon
                    .foregroundColor(.blue.opacity(0.8))
                    .padding(10)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    AboutScreen()
}
