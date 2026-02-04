import SwiftUI

// MARK: - Data Model
struct DeveloperProfile: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let linkedinURL: String
    let initial: String
}

struct AboutScreen: View {
    // Developers Data
    let developers = [
        DeveloperProfile(name: "Satyam Singh", color: .teal, linkedinURL: "https://www.linkedin.com/in/satyam-singh-4510b9323/", initial: "S"),
        DeveloperProfile(name: "Somesh Tiwari", color: .indigo, linkedinURL: "https://www.linkedin.com/in/somesh-tiwari-236555322/", initial: "S"),
        DeveloperProfile(name: "Vishek Tyagi", color: .orange, linkedinURL: "https://www.linkedin.com/in/vishek-tyagi-a42b18313/", initial: "V")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Background: Blurred Image
                GeometryReader { geometry in
                    Image("aboutbackground") // Ensure asset name is correct
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .blur(radius: 2)
                        .overlay(Color.black.opacity(0.3))
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // 2. Header
                        VStack(spacing: 12) {
                            Image(systemName: "book.pages.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.white.opacity(0.9))
                                .shadow(radius: 5)
                            
                            VStack(spacing: 5) {
                                Text("K-Sync")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                
                                Text("v2.0.1")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, 40)
                        
                        // 3. Developers List (Separate Cards)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("CREATORS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.leading, 16)
                            
                            // ⚡️ Main Change: Spacing 15 between cards
                            VStack(spacing: 15) {
                                ForEach(developers) { dev in
                                    DeveloperCardSeparate(profile: dev)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                        
                        // 4. Footer
                        VStack(spacing: 16) {
                            Text("Made with ❤️ for KIET Students")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Button(action: {
                                print("Test Notification")
                            }) {
                                Text("Test Notification")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(.ultraThinMaterial)
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

// 🎴 Separate Glass Card Component
struct DeveloperCardSeparate: View {
    let profile: DeveloperProfile
    
    var body: some View {
        Link(destination: URL(string: profile.linkedinURL)!) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(profile.color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Text(profile.initial)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Name (Highlighted)
                Text(profile.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                    )
                
                Spacer()
                
                // Icon
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(16)
            // 👇 Card Styling moved here for separation
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AboutScreen()
}
