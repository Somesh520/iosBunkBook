import SwiftUI

struct HallTicketView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var isDownloading = false
    @State private var activeDownloadURL: URL?
    @State private var showShareSheet = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 🔽 Stylish Session Selector
                if !viewModel.hallTicketSessions.isEmpty {
                    sessionSelector
                }
                
                // 🎫 Tickets Content
                if viewModel.isTicketLoading {
                    Spacer()
                    ProgressView("Fetching Hall Tickets...")
                        .tint(.blue)
                    Spacer()
                } else if viewModel.hallTickets.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(viewModel.hallTickets) { ticket in
                                HallTicketCard(ticket: ticket) {
                                                                    Task {
                                        await downloadAndShare(ticket: ticket)
                                    }
                                }
                            }
                        }
                        .padding()
                        .padding(.bottom, 20)
                    }
                    .refreshable {
                        if let session = viewModel.selectedSession {
                            await viewModel.fetchTickets(for: session.sessionId)
                        }
                    }
                }
            }
        }
        .onAppear {
            if viewModel.hallTicketSessions.isEmpty {
                Task { await viewModel.fetchSessions() }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = activeDownloadURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    // MARK: - Components
    
    var sessionSelector: some View {
        Menu {
            ForEach(viewModel.hallTicketSessions) { session in
                Button {
                    viewModel.selectedSession = session
                    Task { await viewModel.fetchTickets(for: session.sessionId) }
                } label: {
                    HStack {
                        Text(session.sessionName)
                        if viewModel.selectedSession?.id == session.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ACADEMIC SESSION")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .tracking(1)
                    
                    Text(viewModel.selectedSession?.sessionName ?? "Select Session")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundColor(.blue)
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 5)
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 15) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            Text("No Hall Tickets Found")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Text("Try selecting a different academic session.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
        }
    }
    
    func downloadAndShare(ticket: HallTicketOption) async {
        isDownloading = true
        if let url = await viewModel.downloadTicket(ticket: ticket) {
            activeDownloadURL = url
            showShareSheet = true
        }
        isDownloading = false
    }
}

// 🎫 Premium Ticket Card
struct HallTicketCard: View {
    let ticket: HallTicketOption
    let onDownload: () -> Void
    @State private var isDownloading = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Strip
            Rectangle()
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
                .frame(width: 6)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ticket.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Examination Form")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                    }
                    Spacer()
                    Image(systemName: "doc.text.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue.opacity(0.2))
                }
                
                Divider()
                
                HStack {
                    Label("PDF Document", systemImage: "doc.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        isDownloading = true
                        onDownload()
                        // Reset spinner after short delay if needed, 
                        // but parent handles the actual sheet logic.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { isDownloading = false }
                    }) {
                        HStack(spacing: 8) {
                            if isDownloading {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.down.doc.fill")
                                    .font(.system(size: 14))
                            }
                            Text(isDownloading ? "Downloading..." : "Download")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .disabled(isDownloading)
                }
            }
            .padding(16)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}

// 📤 Helper for Sharing PDF
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
