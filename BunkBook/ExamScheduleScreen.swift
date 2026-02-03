import SwiftUI

struct ExamScheduleScreen: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.isExamLoading {
                    ScrollView {
                        VStack(spacing: 15) {
                            ExamSkeletonCard()
                            ExamSkeletonCard()
                            ExamSkeletonCard()
                        }
                        .padding()
                    }
                } else if viewModel.exams.isEmpty {
                    EmptyExamStateView()
                } else {
                    List {
                        ForEach(viewModel.exams) { exam in
                            ExamCard(exam: exam)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .padding(.bottom, 10)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await viewModel.fetchExams()
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Exam Schedule")
            // ✅ Only fetch if empty to prevent loops
            .task {
                if viewModel.exams.isEmpty {
                    await viewModel.fetchExams()
                }
            }
        }
    }
}

struct ExamCard: View {
    let exam: ExamSchedule
    
    var parsedDetails: (name: String, code: String, type: String) {
        if let details = exam.courseDetails {
            let parts = details.components(separatedBy: "-")
            if parts.count >= 1 {
                return (
                    name: parts[0].trimmingCharacters(in: .whitespaces),
                    code: exam.courseCode ?? "N/A",
                    type: parts.dropFirst(2).joined(separator: "-").trimmingCharacters(in: .whitespaces)
                )
            }
        }
        return (exam.courseName ?? "Unknown", exam.courseCode ?? "N/A", exam.evalLevelComponentName ?? "Exam")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(parsedDetails.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(parsedDetails.code)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(parsedDetails.type.isEmpty ? "Exam" : parsedDetails.type)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.1))
                    .cornerRadius(10)
            }
            
            Divider()
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                // ✅ FIX: Safely Unwrap Optional String
                Text(exam.strExamDate ?? "Date N/A")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// [Keep EmptyExamStateView & ExamSkeletonCard here if not defined elsewhere]
struct EmptyExamStateView: View {
    @State private var float = false
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "cup.and.saucer.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
                .offset(y: float ? -10 : 10)
                .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: float)
                .onAppear { float = true }
            
            Text("No Exams Scheduled!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Relax and enjoy your time off. 🎮☕")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

struct ExamSkeletonCard: View {
    @State private var blink = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 20)
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 20)
            }
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 16)
            
            Divider()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 200, height: 16)
        }
        .padding()
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
