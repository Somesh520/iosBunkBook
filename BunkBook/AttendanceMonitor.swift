import Foundation

class AttendanceMonitor {
    static let shared = AttendanceMonitor()
    
    private init() {}
    
    /// ✅ Main function: Schedule aur courses check karo, aur agar attendance kam hai to notify karo
    func checkAndScheduleReminders(courses: [RegisteredCourse], schedule: [TimetableEvent]) {
        print("🧠 Smart Monitor: Checking schedule for notifications...")
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let tomorrowKey = formatDateKey(tomorrow) // "dd/MM/yyyy" format from ScheduleScreen
        
        // 1. Filter tomorrow's classes
        let tomorrowClasses = schedule.filter { event in
            return event.start.hasPrefix(tomorrowKey) && event.type == "CLASS"
        }
        
        if tomorrowClasses.isEmpty {
            print("📅 No classes found for tomorrow (\(tomorrowKey)).")
            return
        }
        
        print("📅 Found \(tomorrowClasses.count) classes for tomorrow.")
        
        // 2. Logic: Har class ke liye attendance check karo
        for event in tomorrowClasses {
            guard let courseName = event.courseName else { continue }
            
            // Find matching course in user's registered courses
            // Matches partial name/code if exact match fails
            if let course = courses.first(where: { matchCourse(eventCourse: courseName, registeredCourse: $0) }) {
                
                // Calculate percentage
                // Assuming first component is theory (common case)
                if let comp = course.studentCourseCompDetails?.first {
                    let total = Double(comp.totalLecture)
                    let present = Double(comp.presentLecture)
                    
                    if total > 0 {
                        let percentage = (present / total) * 100.0
                        
                        // ❌ ALERT CONDITION: < 75%
                        if percentage < 75.0 {
                            scheduleAlert(for: course.courseName, percentage: percentage, time: event.start)
                        }
                    }
                }
            }
        }
    }
    
    // Helper to match API course names which might differ slightly
    private func matchCourse(eventCourse: String, registeredCourse: RegisteredCourse) -> Bool {
        return eventCourse.lowercased().contains(registeredCourse.courseCode.lowercased()) ||
               registeredCourse.courseName.lowercased().contains(eventCourse.lowercased())
    }
    
    private func scheduleAlert(for subject: String, percentage: Double, time: String) {
        let title = "⚠️ Low Attendance Alert: \(subject)"
        let body = "You have a class tomorrow at \(formatTime(parseCustomDate(time))). Your attendance is only \(String(format: "%.1f", percentage))%. Don't bunk!"
        
        // Schedule for 7:00 AM tomorrow
        if let eventDate = DateUtils.apiFormatter.date(from: time) { // "dd/MM/yyyy HH:mm:ss"
            // Get 7 AM on that day
            if let eightAM = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: eventDate) {
                let timeInternal = eightAM.timeIntervalSinceNow
                
                if timeInternal > 0 {
                    NotificationManager.shared.scheduleNotification(title: title, body: body, timeInterval: timeInternal)
                } else {
                    // Agar abhi 7 AM se late ho chuka hai (e.g. testing), to 5 seconds baad bhejo
                     NotificationManager.shared.scheduleNotification(title: title, body: body, timeInterval: 5)
                }
            }
        }
    }
}
