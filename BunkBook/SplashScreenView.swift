import SwiftUI

struct SplashScreenView: View {
    @Binding var isFinished: Bool
    
    // ✅ ViewModel yahan pass karenge taaki API call trigger kar sakein
    @ObservedObject var viewModel: HomeViewModel
    
    // Animation States
    @State private var letterStates: [Bool] = Array(repeating: false, count: 6)
    @State private var isLineExpanded = false
    @State private var showTagline = false
    
    let characters = Array("K-Sync")
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            // Abstract Background
            Circle()
                .fill(Color(red: 0.94, green: 0.98, blue: 1.0))
                .frame(width: 300, height: 300)
                .offset(x: 100, y: -250)
            
            Circle()
                .fill(Color(red: 0.96, green: 0.95, blue: 1.0))
                .frame(width: 250, height: 250)
                .offset(x: -120, y: 350)
            
            VStack(spacing: 0) {
                // Animated Text
                HStack(spacing: 2) {
                    ForEach(0..<characters.count, id: \.self) { index in
                        Text(String(characters[index]))
                            .font(.system(size: 48, weight: .black, design: .default))
                            .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.23))
                            .scaleEffect(letterStates[index] ? 1 : 0.5)
                            .opacity(letterStates[index] ? 1 : 0)
                            .offset(y: letterStates[index] ? 0 : 50)
                            .animation(
                                .interactiveSpring(response: 0.4, dampingFraction: 0.6), // Faster Spring
                                value: letterStates[index]
                            )
                    }
                }
                .frame(height: 60)
                
                // Line
                Capsule()
                    .fill(Color.blue)
                    .frame(width: isLineExpanded ? 120 : 0, height: 4)
                    .padding(.top, 5)
                    .animation(.easeOut(duration: 0.4), value: isLineExpanded) // Faster Line
                
                // Tagline
                if showTagline {
                    Text("It syncs your timetable, results and attendance")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.blue)
                        .tracking(0.5)
                        .padding(.top, 20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .onAppear {
            // 🔥 YAHAN MAGIC HOGA: Animation shuru hote hi Data Load karo
            startAnimationAndFetchData()
        }
    }
    
    func startAnimationAndFetchData() {
        // 1. 🚀 Background API Call Trigger (Async)
        Task {
            print("🚀 Splash Screen: Starting Background Data Fetch...")
            await viewModel.fetchData()
        }

        // 2. ⚡️ Fast Animations (Timings reduced significantly)
        
        // Letters appearing quickly
        for i in 0..<characters.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05 + 0.1) { // Super fast stagger
                letterStates[i] = true
            }
        }
        
        // Line Expand
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isLineExpanded = true
        }
        
        // Tagline
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation { showTagline = true }
        }
        
        // 3. 🏁 Finish Splash (Total Time: 1.8 seconds)
        // Agar API data jaldi aa gaya toh bhi thoda wait karega taaki animation complete ho
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation {
                isFinished = true
            }
        }
    }
}
