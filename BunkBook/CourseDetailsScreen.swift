import SwiftUI

struct CourseDetailsScreen: View {
    // Parameters passed from Home
    let courseName: String
    let courseCode: String
    let studentId: Int
    let courseId: Int
    let courseCompId: Int
    
    @State private var lectures: [Lecture] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    // Animation State
    @State private var showContent = false
    
    // Environment
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                // The image shows "Lecture Details" in nav bar, and Course Name below it.
                
                // Course Name Title
                VStack(alignment: .leading, spacing: 5) {
                    Text(courseName)
                        .font(.title2) // Matches "Universal Human Values" size
                        .fontWeight(.bold)
                        .foregroundColor(.primary) // Adaptive Color
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                
                Divider()
                
                // Content List
                if isLoading {
                    // 🦴 Skeleton Loader
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(0..<5, id: \.self) { _ in
                                SkeletonRow()
                            }
                        }
                        .padding()
                    }
                } else if let error = errorMessage {
                    // ❌ Error View
                    VStack(spacing: 15) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            Task { await loadLectures() }
                        }
                        .padding(.top)
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                } else if lectures.isEmpty {
                    // 📭 Empty View
                    VStack(spacing: 10) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No Lecture History Found")
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    // 📜 Lecture List (ScrollView for Cards)
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(lectures) { lecture in
                                LectureRow(lecture: lecture)
                            }
                        }
                        .padding()
                        .opacity(showContent ? 1 : 0) // Fade In Animation
                        .animation(.easeIn(duration: 0.3), value: showContent)
                    }
                }
            }
        }
        .navigationTitle("Lecture Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground))
        // 🔥 CRITICAL FIX: Use .task instead of .onAppear to prevent loops
        .task {
            if lectures.isEmpty {
                await loadLectures()
            }
        }
    }
    
    // API Call
    func loadLectures() async {
        isLoading = true
        errorMessage = nil
        
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            errorMessage = "Please Login Again"
            isLoading = false
            return
        }
        
        do {
            // Background Thread API Call
            let fetched = try await APIManager.fetchLectures(
                token: token,
                studentId: studentId,
                courseId: courseId,
                courseCompId: courseCompId
            )
            
            // Main Thread Update
            await MainActor.run {
                // 🗓 Sort: Newest First
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
                
                self.lectures = fetched.sorted {
                    guard let d1 = formatter.date(from: $0.planLecDate),
                          let d2 = formatter.date(from: $1.planLecDate) else { return false }
                    return d1 > d2
                }
                
                self.isLoading = false
                self.showContent = true
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load history."
                self.isLoading = false
            }
        }
    }
}

// 📌 Lecture Row Component (Card Style)
struct LectureRow: View {
    let lecture: Lecture
    
    // Helper for Status
    enum Status {
        case present
        case absent
        case notMarked
        
        var color: Color {
            switch self {
            case .present: return Color(red: 0.0, green: 0.7, blue: 0.3) // Green
            case .absent: return Color(red: 0.85, green: 0.2, blue: 0.2) // Red
            case .notMarked: return Color(red: 0.85, green: 0.2, blue: 0.2) // Red (As per image)
            }
        }
        
        var icon: String {
            switch self {
            case .present: return "checkmark.circle"
            case .absent: return "xmark.circle"
            case .notMarked: return "xmark.circle" // Assuming 'x' for not marked too?
            }
        }
        
        var text: String {
            switch self {
            case .present: return "PRESENT"
            case .absent: return "ABSENT"
            case .notMarked: return "NOT MARKED"
            }
        }
    }
    
    var status: Status {
        let s = lecture.attendance.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s == "P" || s == "PRESENT" { return .present }
        if s == "A" || s == "ABSENT" { return .absent }
        return .notMarked
    }
    
    var formattedDate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        
        if let date = inputFormatter.date(from: lecture.planLecDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMM yyyy" // "30 Jan 2026"
            return outputFormatter.string(from: date)
        }
        return lecture.planLecDate
    }
    
    var body: some View {
        HStack {
            // Left: Date
            Text(formattedDate)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            Spacer()
            
            // Right: Status Capsule
            HStack(spacing: 6) {
                Image(systemName: status.icon)
                    .font(.system(size: 14, weight: .bold))
                
                Text(status.text)
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(status.color)
            .clipShape(Capsule())
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        // Card Shadow
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// 💀 Skeleton Row
struct SkeletonRow: View {
    @State private var blink = false
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 100, height: 16)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 100, height: 30)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .opacity(blink ? 0.5 : 1.0)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                blink = true
            }
        }
    }
}
