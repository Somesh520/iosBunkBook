import SwiftUI
import UserNotifications

struct NotificationDebugView: View {
    @State private var pendingRequests: [UNNotificationRequest] = []
    @State private var timer: Timer?
    
    var body: some View {
        List {
            Section(header: Text("Actions")) {
                Button(action: {
                    NotificationManager.shared.scheduleTestNotification()
                    refreshList()
                }) {
                    Label("Test Notification (5s)", systemImage: "timer")
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    refreshList()
                }) {
                    Label("Refresh List", systemImage: "arrow.clockwise")
                }
            }
            
            Section(header: Text("Pending Notifications (\(pendingRequests.count))")) {
                if pendingRequests.isEmpty {
                    Text("No pending notifications")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(pendingRequests, id: \.identifier) { request in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(request.content.title)
                                .font(.headline)
                            Text(request.content.body)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                                Text("Triggers in: \(Int(trigger.timeInterval))s")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            } else if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                                Text("Scheduled: \(trigger.dateComponents)")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .navigationTitle("Notifications Debug")
        .onAppear {
            refreshList()
        }
    }
    
    func refreshList() {
        NotificationManager.shared.getPendingNotifications { requests in
            self.pendingRequests = requests
        }
    }
}
