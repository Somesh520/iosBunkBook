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
                        VStack(spacing: 5) {
                            Text("Overall CGPA")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(String(format: "%.2f", scores.cgpa ?? 0.0))
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(scores.fullName ?? "Student")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.top, 5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(25)
                        .background(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(20)
                        .shadow(radius: 8)
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // 📚 Semesters List
                        if let semesters = scores.studentSemesterWiseMarksDetailsList {
                            ForEach(semesters) { semester in
                                SemesterCard(semester: semester)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .refreshable {
                    await viewModel.fetchScores()
                }
            } else {
                // Empty State
                VStack {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No Results Found")
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                    
                    Button("Retry") {
                        Task { await viewModel.fetchScores() }
                    }
                    .padding(.top, 10)
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

// Sub-View: Semester Card (Expandable)
struct SemesterCard: View {
    let semester: SemesterScore
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Semester \(semester.semesterName ?? "-")")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(semester.sessionName ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack {
                        Text("SGPA")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                        Text(String(format: "%.2f", semester.sgpa ?? 0.0))
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .background(Color.green)
                    .cornerRadius(8)
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
            }
            
            // Expanded Subjects List
            if isExpanded {
                Divider()
                VStack(spacing: 0) {
                    if let subjects = semester.studentMarksDetailsDTO {
                        ForEach(subjects) { subject in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(subject.courseName ?? "Unknown")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(subject.courseCode ?? "")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text(subject.finalGrade)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(getGradeColor(subject.finalGrade))
                                    .frame(width: 35)
                            }
                            .padding()
                            Divider()
                        }
                    }
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground))
            }
        }
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
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
