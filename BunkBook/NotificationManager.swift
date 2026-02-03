import Foundation
import UserNotifications

class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // 1. Request Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification Permission Granted")
            } else if let error = error {
                print("❌ Notification Permission Error: \(error.localizedDescription)")
            } else {
                print("⚠️ Notification Permission Denied")
            }
        }
    }
    
    // 2. Schedule Notification
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval, identifier: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        // Use custom identifier or generate unique one
        let notificationId = identifier ?? UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("📢 Notification Scheduled: \(title) - in \(timeInterval) seconds (ID: \(notificationId))")
            }
        }
    }
    
    // 3. Clear Badges
    func clearBadges() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    // 4. Get Pending (Debug)
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    // 5. Test Notification
    func scheduleTestNotification() {
        scheduleNotification(title: "Debug Test", body: "Checking if notifications work!", timeInterval: 5)
    }
}

// Handle Foreground Notifications
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // App khula hone par bhi notification dikhao
        completionHandler([.banner, .sound])
    }
}
