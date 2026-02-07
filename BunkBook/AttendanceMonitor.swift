import Foundation
import UserNotifications

class AttendanceMonitor {
    static let shared = AttendanceMonitor()
    
    private init() {}
    
    
    func checkAndScheduleReminders(courses: [RegisteredCourse], schedule: [TimetableEvent]) {
        print("🧠 Smart Monitor: Checking schedule for notifications...")
        
       
        clearAllScheduledNotifications()
        
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        // Check today and tomorrow
        checkAndSchedule(for: today, courses: courses, schedule: schedule, isToday: true)
        checkAndSchedule(for: tomorrow, courses: courses, schedule: schedule, isToday: false)
    }
    
    /// Check and schedule notifications for a specific date
    private func checkAndSchedule(for date: Date, courses: [RegisteredCourse], schedule: [TimetableEvent], isToday: Bool) {
        let dateKey = formatDateKey(date)
        
        // Filter classes for this date
        let classes = schedule.filter { event in
            return event.start.hasPrefix(dateKey) && event.type == "CLASS"
        }
        
        if classes.isEmpty {
            print("📅 No classes found for \(isToday ? "today" : "tomorrow") (\(dateKey)).")
            return
        }
        
        print("📅 Found \(classes.count) classes for \(isToday ? "today" : "tomorrow").")
        
        // Track courses to avoid duplicates
        var lowAttendanceCourses: [(course: RegisteredCourse, classTime: Date)] = []
        var notifiedCourses = Set<String>()
        
        // Check each class
        for event in classes {
            guard let courseName = event.courseName else { continue }
            
            // Find matching course
            if let course = courses.first(where: { matchCourse(eventCourse: courseName, registeredCourse: $0) }) {
                
                let courseKey = course.courseCode.lowercased()
                if notifiedCourses.contains(courseKey) {
                    continue
                }
                
                // Calculate percentage
                if let comp = course.studentCourseCompDetails?.first {
                    let total = Double(comp.totalLecture)
                    let present = Double(comp.presentLecture)
                    
                    if total > 0 {
                        let percentage = (present / total) * 100.0
                        
                        // ❌ ALERT CONDITION: < 75%
                        if percentage < 75.0 {
                            if let classTime = parseCustomDate(event.start) {
                                lowAttendanceCourses.append((course, classTime))
                                notifiedCourses.insert(courseKey)
                            }
                        }
                    }
                }
            }
        }
        
        // 📢 SCHEDULE NOTIFICATIONS
        if !lowAttendanceCourses.isEmpty {
            if isToday {
                // TODAY: 9 AM summary + 10 mins before each class
                scheduleDailySummary(courses: lowAttendanceCourses)
                
                for (course, classTime) in lowAttendanceCourses {
                    scheduleClassReminder(course: course, classTime: classTime)
                }
            } else {
                // TOMORROW: 9 AM summary only
                scheduleTomorrowSummary(courses: lowAttendanceCourses)
            }
        }
    }
    
    // MARK: - Notification Scheduling
    
    /// 1️⃣ Today's 9 AM Summary
    private func scheduleDailySummary(courses: [(course: RegisteredCourse, classTime: Date)]) {
        let now = Date()
        let calendar = Calendar.current
        
        guard let nineAM = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) else { return }
        
        // Only schedule if before 9 AM
        if nineAM > now {
            let timeInterval = nineAM.timeIntervalSinceNow
            let courseNames = courses.map { $0.course.courseName }.prefix(3).joined(separator: ", ")
            let title = "⚠️ Low Attendance Alert"
            let body = "You have \(courses.count) class(es) today with low attendance: \(courseNames). Don't skip!"
            
            NotificationManager.shared.scheduleNotification(
                title: title,
                body: body,
                timeInterval: timeInterval,
                identifier: "daily_summary_today"
            )
            
            print("📲 Scheduled TODAY 9 AM summary (\(Int(timeInterval/3600)) hours from now)")
        }
    }
    
    /// 2️⃣ Tomorrow's 9 AM Summary
    private func scheduleTomorrowSummary(courses: [(course: RegisteredCourse, classTime: Date)]) {
        let now = Date()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        
        guard let nineAM = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) else { return }
        
        let timeInterval = nineAM.timeIntervalSinceNow
        
        if timeInterval > 0 {
            let courseNames = courses.map { $0.course.courseName }.prefix(3).joined(separator: ", ")
            let title = "⚠️ Low Attendance Alert"
            let body = "Tomorrow you have \(courses.count) class(es) with low attendance: \(courseNames). Be prepared!"
            
            NotificationManager.shared.scheduleNotification(
                title: title,
                body: body,
                timeInterval: timeInterval,
                identifier: "daily_summary_tomorrow"
            )
            
            print("📲 Scheduled TOMORROW 9 AM summary (\(Int(timeInterval/3600)) hours from now)")
        }
    }
    
    /// 3️⃣ 10 Minutes Before Class (Today only)
    private func scheduleClassReminder(course: RegisteredCourse, classTime: Date) {
        let now = Date()
        let tenMinsBefore = Calendar.current.date(byAdding: .minute, value: -10, to: classTime)!
        
        // Only schedule if class hasn't started yet
        if classTime > now {
            let timeInterval: TimeInterval
            
            if tenMinsBefore > now {
                // Class is more than 10 mins away
                timeInterval = tenMinsBefore.timeIntervalSinceNow
            } else {
                // Class is within 10 mins, notify immediately
                timeInterval = 5
            }
            
            if let comp = course.studentCourseCompDetails?.first {
                let total = Double(comp.totalLecture)
                let present = Double(comp.presentLecture)
                let percentage = total > 0 ? (present / total) * 100.0 : 0
                
                let title = "📚 Class Starting Soon"
                let body = "\(course.courseName): Class starts in 10 minutes! Attendance: \(String(format: "%.1f", percentage))%"
                
                let identifier = "class_reminder_\(course.courseCode.lowercased())"
                
                NotificationManager.shared.scheduleNotification(
                    title: title,
                    body: body,
                    timeInterval: timeInterval,
                    identifier: identifier
                )
                
                print("📲 Scheduled 10-min reminder for \(course.courseName) (in \(Int(timeInterval/60)) mins)")
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func matchCourse(eventCourse: String, registeredCourse: RegisteredCourse) -> Bool {
        return eventCourse.lowercased().contains(registeredCourse.courseCode.lowercased()) ||
               registeredCourse.courseName.lowercased().contains(eventCourse.lowercased())
    }
    
    private func clearAllScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🧹 Cleared all pending notifications")
    }
    
    private func parseCustomDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return formatter.date(from: dateString)
    }
    
    private func formatDateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return formatter.string(from: date)
    }
}
