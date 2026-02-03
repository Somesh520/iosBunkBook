import SwiftUI

struct ExamMainView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedTab = 0 // 0: Schedule, 1: Results
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header & Segmented Picker
                VStack {
                    Picker("Options", selection: $selectedTab) {
                        Text("Schedule").tag(0)
                        Text("Results").tag(1)
                        Text("Hall Ticket").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
                .background(Color.white)
                
                // Content
                    if selectedTab == 0 {
                        // Purana Exam Schedule Screen (Same logic)
                        ExamScheduleScreen(viewModel: viewModel)
                    } else if selectedTab == 1 {
                        // Naya Result View 
                        ExamResultView(viewModel: viewModel)
                    } else {
                        // 🎫 New Hall Ticket View
                        HallTicketView(viewModel: viewModel)
                    }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Exams")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
