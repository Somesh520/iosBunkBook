import SwiftUI

struct AboutScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // 🎨 Header
                ZStack {
                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(height: 200)
                        .cornerRadius(20)
                        .offset(y: -50)
                        .padding(.bottom, -50)
                    
                    VStack {
                        Image(systemName: "app.badge.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                        
                        Text("BunkBook")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("v1.0.0")
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
                    DeveloperCard(name: "Somesh Tiwari", role: "Developer", color: .blue)
                    DeveloperCard(name: "Vishek Tyagi", role: "Developer", color: .orange)
                    DeveloperCard(name: "Satyam Singh", role: "Developer", color: .green)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Footer
                Text("Made with ❤️ for KIET Students")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
    }
}

struct DeveloperCard: View {
    let name: String
    let role: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar Placeholder
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Text(String(name.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(role)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    AboutScreen()
}
