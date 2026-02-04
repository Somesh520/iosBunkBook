import SwiftUI

struct ExamResultView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            if viewModel.isScoreLoading {
                ProgressView("Fetching Marks...")
            } else if let scores = viewModel.examScores {
                ScrollView {
                    VStack(spacing: 20) {
                        // 🏆 CGPA Card
                        VStack(spacing: 8) {
                            Text("Overall CGPA")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(String(format: "%.2f", scores.cgpa ?? 0.0))
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.1), radius: 5)
                            
                            Text(scores.fullName ?? "Student")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(30)
                        .background(
                            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(24)
                        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // 🎯 Target CGPA Calculator
                        TargetCGPACalculatorView(
                            currentCGPA: scores.cgpa ?? 0.0,
                            completedSemesters: scores.studentSemesterWiseMarksDetailsList?.count ?? 0
                        )
                        
                            // 📚 Semesters List
                            if let semesters = scores.studentSemesterWiseMarksDetailsList {
                                VStack(spacing: 15) {
                                    ForEach(semesters) { semester in
                                        SemesterCard(semester: semester)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                .refreshable {
                    await viewModel.fetchScores()
                }
            } else {
                // Empty State
                VStack(spacing: 15) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("No Results Found")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Button("Retry") {
                        Task { await viewModel.fetchScores() }
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .task {
            if viewModel.examScores == nil {
                await viewModel.fetchScores()
            }
        }
    }
}

// 🎯 Target CGPA Calculator
struct TargetCGPACalculatorView: View {
    let currentCGPA: Double
    let completedSemesters: Int
    let totalSemesters: Int = 8
    
    @State private var targetCGPA: Double
    
    init(currentCGPA: Double, completedSemesters: Int) {
        self.currentCGPA = currentCGPA
        self.completedSemesters = completedSemesters
        _targetCGPA = State(initialValue: currentCGPA + 0.5) // Default target slightly higher
    }
    
    var body: some View {
        let remainingSemesters = totalSemesters - completedSemesters
        
        VStack(spacing: 15) {
            // Header
            HStack {
                Image(systemName: "target")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Target Goal")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            if remainingSemesters > 0 {
                // Slider Input
                VStack(spacing: 5) {
                    HStack {
                        Text("Desired CGPA")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f", targetCGPA))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Slider(value: $targetCGPA, in: 7.0...10.0, step: 0.1)
                        .accentColor(.blue)
                }
                
                // Calculation Result
                let requiredSGPA = calculateRequiredSGPA()
                
                HStack(spacing: 15) {
                    // Result Box
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Required SGPA")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if requiredSGPA > 10.0 {
                            Text("Impossible 😢")
                                .font(.headline)
                                .foregroundColor(.red)
                        } else {
                            Text(String(format: "%.2f", requiredSGPA))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(getDifficultyColor(requiredSGPA))
                            
                            Text("for next \(remainingSemesters) semesters")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Difficulty Indicator
                    if requiredSGPA <= 10.0 {
                        ZStack {
                            Circle()
                                .trim(from: 0, to: 0.75)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(135))
                            
                            Circle()
                                .trim(from: 0, to: min(CGFloat(requiredSGPA / 10.0) * 0.75, 0.75))
                                .stroke(getDifficultyColor(requiredSGPA), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(135))
                            
                            Text(getDifficultyEmoji(requiredSGPA))
                                .font(.title2)
                        }
                    } else {
                         Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
                
            } else {
                Text("Congratulations! You have completed all semesters.")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .padding(20)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // 🧮 Calculation Logic
    func calculateRequiredSGPA() -> Double {
        let totalPointsNeeded = targetCGPA * Double(totalSemesters)
        let currentPoints = currentCGPA * Double(completedSemesters)
        let remainingPointsNeeded = totalPointsNeeded - currentPoints
        return remainingPointsNeeded / Double(totalSemesters - completedSemesters)
    }
    
    func getDifficultyColor(_ sgpa: Double) -> Color {
        if sgpa > 9.5 { return .red }      // Very Hard
        if sgpa > 8.5 { return .orange }   // Hard
        return .green                      // Achievable
    }
    
    func getDifficultyEmoji(_ sgpa: Double) -> String {
        if sgpa > 9.5 { return "🔥" }
        if sgpa > 8.5 { return "😅" }
        return "😎"
    }
}

// 🔷 Premium Semester Card
struct SemesterCard: View {
    let semester: SemesterScore
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isExpanded.toggle() } }) {
                HStack(spacing: 15) {
                    // SGPA Box
                    VStack(spacing: 2) {
                        Text("SGPA")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        Text(String(format: "%.2f", semester.sgpa ?? 0.0))
                            .font(.title3)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                    }
                    .frame(width: 60, height: 60)
                    .background(
                        LinearGradient(colors: [getSgpaColor(semester.sgpa ?? 0), getSgpaColor(semester.sgpa ?? 0).opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(12)
                    .shadow(color: getSgpaColor(semester.sgpa ?? 0).opacity(0.3), radius: 4, y: 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Semester \(semester.semesterName ?? "-")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(semester.sessionName ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(12)
                .background(Color(uiColor: .systemBackground))
            }
            
            // Expanded Subjects List
            if isExpanded {
                Divider()
                VStack(spacing: 0) {
                    if let subjects = semester.studentMarksDetailsDTO {
                        ForEach(subjects.indices, id: \.self) { index in
                            let subject = subjects[index]
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(getGradeColor(subject.finalGrade))
                                    .frame(width: 8, height: 8)
                                    .padding(.top, 6)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(subject.courseName ?? "Unknown")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                    
                                    if let code = subject.courseCode {
                                        Text(code)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(4)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                Text(subject.finalGrade)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(getGradeColor(subject.finalGrade))
                            }
                            .padding()
                            .background(index % 2 == 0 ? Color.gray.opacity(0.02) : Color.white)
                            
                            if index < subjects.count - 1 {
                                Divider().padding(.leading, 40)
                            }
                        }
                    }
                }
                .background(Color(uiColor: .systemBackground))
            }
        }
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
    
    func getSgpaColor(_ sgpa: Double) -> Color {
        if sgpa >= 8.0 { return .green }
        if sgpa >= 6.0 { return .blue }
        return .orange
    }
    
    func getGradeColor(_ grade: String) -> Color {
        switch grade {
        case "A+", "A": return .green
        case "B+", "B": return .blue
        case "C+", "C": return .orange
        case "F": return .red
        default: return .gray
        }
    }
}

