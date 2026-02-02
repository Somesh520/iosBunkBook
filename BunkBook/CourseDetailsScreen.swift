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
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 5) {
                    Text(courseCode)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(6)
                    
                    Text(courseName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineLimit(2)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                
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
                    // 📜 Lecture List
                    List {
                        ForEach(lectures) { lecture in
                            LectureRow(lecture: lecture)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0) // Fade In Animation
                    .animation(.easeIn(duration: 0.3), value: showContent)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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

// 📌 Lecture Row Component
struct LectureRow: View {
    let lecture: Lecture
    
    var isPresent: Bool {
        let status = lecture.attendance.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return status == "P" || status == "PRESENT"
    }
    
    var formattedDate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        
        if let date = inputFormatter.date(from: lecture.planLecDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d MMM" // "28 Jan"
            return outputFormatter.string(from: date)
        }
        return lecture.planLecDate
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Status Icon (replaced with Text)
            ZStack {
                Circle()
                    .fill(isPresent ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Text(isPresent ? "P" : "A") // 🔡 Changed Icon to Text
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(isPresent ? .green : .red)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 6) {
                // If Topic is missing, use Date as Title (Big Font)
                if lecture.topicCovered == nil || lecture.topicCovered == "No Topic Mentioned" {
                    Text(formattedDate)
                        .font(.title3) // ✨ Bigger & Cleaner
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.vertical, 2) // Center slighty
                } else {
                    Text(formattedDate) // 🗓 Small Date
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase) // 🎨 Added style
                    
                    Text(lecture.topicCovered ?? "")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

// 💀 Skeleton Row
struct SkeletonRow: View {
    @State private var blink = false
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 12)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 12)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .opacity(blink ? 0.5 : 1.0)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                blink = true
            }
        }
    }
}
