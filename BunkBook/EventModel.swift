import Foundation
import SwiftUI

// 🗓️ Event Type Enum
enum EventType: String, CaseIterable, Identifiable {
    case holiday = "Holidays"
    case activity = "Activities"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .holiday: return .red
        case .activity: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .holiday: return "calendar.badge.exclamationmark"
        case .activity: return "star.fill"
        }
    }
}

// 📅 Event Data Model
struct AcademicEvent: Identifiable {
    let id = UUID()
    let title: String
    let dateRange: String // e.g., "22nd Jan" or "22nd - 27th Jan"
    let month: String // For Grouping (e.g., "January 2026")
    let rawDate: Date // For Sorting
    let type: EventType
    let description: String?
}

// 🗂️ Data Source
class CalendarData {
    static let events: [AcademicEvent] = [
        // --- JANUARY 2026 ---
        AcademicEvent(title: "New Year / Winter Vacations", dateRange: "1st - 16th Jan", month: "January 2026", rawDate: Date.from(2026, 1, 1), type: .holiday, description: "Winter Break"),
        AcademicEvent(title: "First Saturday", dateRange: "3rd Jan", month: "January 2026", rawDate: Date.from(2026, 1, 3), type: .holiday, description: "Holiday"),
        AcademicEvent(title: "Load Distribution", dateRange: "5th - 7th Jan", month: "January 2026", rawDate: Date.from(2026, 1, 5), type: .activity, description: "Academic Activity"),
        AcademicEvent(title: "Finalization of Course Coordinators", dateRange: "9th Jan", month: "January 2026", rawDate: Date.from(2026, 1, 9), type: .activity, description: "Academic Activity"),
        AcademicEvent(title: "Meeting of Course Teachers", dateRange: "10th - 13th Jan", month: "January 2026", rawDate: Date.from(2026, 1, 10), type: .activity, description: "Semester Planning"),
        AcademicEvent(title: "Uploading Lesson Plan on ERP", dateRange: "14th - 16th Jan", month: "January 2026", rawDate: Date.from(2026, 1, 14), type: .activity, description: "Academic Activity"),
        AcademicEvent(title: "Third Saturday", dateRange: "17th Jan", month: "January 2026", rawDate: Date.from(2026, 1, 17), type: .holiday, description: "Holiday"),
        AcademicEvent(title: "Registration & Classes Begin", dateRange: "22nd Jan", month: "January 2026", rawDate: Date.from(2026, 1, 22), type: .activity, description: "Commencement of Classes"),
        AcademicEvent(title: "Orientation Programme", dateRange: "22nd - 27th Jan", month: "January 2026", rawDate: Date.from(2026, 1, 22), type: .activity, description: "For New Students"),
        AcademicEvent(title: "Bondathon", dateRange: "24th Jan & 31st Jan", month: "January 2026", rawDate: Date.from(2026, 1, 24), type: .activity, description: "Additional Activity"),
        AcademicEvent(title: "Republic Day", dateRange: "26th Jan", month: "January 2026", rawDate: Date.from(2026, 1, 26), type: .holiday, description: "National Holiday"),

        // --- FEBRUARY 2026 ---
        AcademicEvent(title: "IGNITE'26", dateRange: "5th - 6th Feb", month: "February 2026", rawDate: Date.from(2026, 2, 5), type: .activity, description: "Sports/Cultural Event"),
        AcademicEvent(title: "First Saturday", dateRange: "7th Feb", month: "February 2026", rawDate: Date.from(2026, 2, 7), type: .holiday, description: "Holiday"),
        AcademicEvent(title: "Blood Donation Camp", dateRange: "10th Feb", month: "February 2026", rawDate: Date.from(2026, 2, 10), type: .activity, description: "Social Activity"),
        AcademicEvent(title: "RANN'26", dateRange: "12th - 14th Feb", month: "February 2026", rawDate: Date.from(2026, 2, 12), type: .activity, description: "Major Sports Event"),
        AcademicEvent(title: "Attendance Display (Dept)", dateRange: "14th Feb", month: "February 2026", rawDate: Date.from(2026, 2, 14), type: .activity, description: "Department Level"),
        AcademicEvent(title: "Finalization of Class Reps", dateRange: "14th Feb", month: "February 2026", rawDate: Date.from(2026, 2, 14), type: .activity, description: "Academic Activity"),
        AcademicEvent(title: "Shivratri", dateRange: "15th Feb", month: "February 2026", rawDate: Date.from(2026, 2, 15), type: .holiday, description: "Festival Holiday"),
        AcademicEvent(title: "Provisional Detention List (CT)", dateRange: "20th Feb", month: "February 2026", rawDate: Date.from(2026, 2, 20), type: .activity, description: "Academic Warning"),
        AcademicEvent(title: "Third Saturday", dateRange: "21st Feb", month: "February 2026", rawDate: Date.from(2026, 2, 21), type: .holiday, description: "Holiday"),
        AcademicEvent(title: "Uploading CA1 (Theory/Prac)", dateRange: "23rd Feb - 28th Feb", month: "February 2026", rawDate: Date.from(2026, 2, 23), type: .activity, description: "Exam Activity"),
        AcademicEvent(title: "Departmental CR Meeting 1", dateRange: "26th - 28th Feb", month: "February 2026", rawDate: Date.from(2026, 2, 26), type: .activity, description: "Meeting"),
        AcademicEvent(title: "SportX Industry Meet", dateRange: "28th Feb", month: "February 2026", rawDate: Date.from(2026, 2, 28), type: .activity, description: "Industry Interaction"),

        // --- MARCH 2026 ---
        AcademicEvent(title: "Holika Dahan", dateRange: "2nd Mar", month: "March 2026", rawDate: Date.from(2026, 3, 2), type: .holiday, description: "Festival"),
        AcademicEvent(title: "Holi / Dulhendi", dateRange: "3rd - 4th Mar", month: "March 2026", rawDate: Date.from(2026, 3, 3), type: .holiday, description: "Festival Holiday"),
        AcademicEvent(title: "First Saturday", dateRange: "7th Mar", month: "March 2026", rawDate: Date.from(2026, 3, 7), type: .holiday, description: "Holiday"),
        AcademicEvent(title: "IQAC Academic Audit 1", dateRange: "9th - 14th Mar", month: "March 2026", rawDate: Date.from(2026, 3, 9), type: .activity, description: "Audit"),
        AcademicEvent(title: "Technoverse 3.0", dateRange: "18th Mar", month: "March 2026", rawDate: Date.from(2026, 3, 18), type: .activity, description: "Tech Fest"),
        AcademicEvent(title: "Eid-Ul-Fitr", dateRange: "21st Mar", month: "March 2026", rawDate: Date.from(2026, 3, 21), type: .holiday, description: "Festival Holiday"),
        AcademicEvent(title: "Department Level EPOQUE", dateRange: "21st & 28th Mar", month: "March 2026", rawDate: Date.from(2026, 3, 21), type: .activity, description: "Cultural Event"),
        AcademicEvent(title: "Mid Sem Feedback", dateRange: "23rd - 25th Mar", month: "March 2026", rawDate: Date.from(2026, 3, 23), type: .activity, description: "Feedback"),
        AcademicEvent(title: "CR Meeting Institute Level", dateRange: "23rd - 28th Mar", month: "March 2026", rawDate: Date.from(2026, 3, 23), type: .activity, description: "Meeting"),
        AcademicEvent(title: "MSE1 Examination (Central)", dateRange: "24th - 28th Mar", month: "March 2026", rawDate: Date.from(2026, 3, 24), type: .activity, description: "Important Exam"),
        AcademicEvent(title: "Ram Navmi", dateRange: "26th Mar", month: "March 2026", rawDate: Date.from(2026, 3, 26), type: .holiday, description: "Festival Holiday"),
        
        // --- APRIL 2026 ---
        AcademicEvent(title: "CR Meeting 2", dateRange: "1st - 3rd Apr", month: "April 2026", rawDate: Date.from(2026, 4, 1), type: .activity, description: "Meeting"),
        AcademicEvent(title: "EPOQUE @ PRASTUTI'26", dateRange: "2nd - 4th Apr", month: "April 2026", rawDate: Date.from(2026, 4, 2), type: .activity, description: "Annual Cultural Fest"),
        AcademicEvent(title: "Attendance Display (Dept)", dateRange: "2nd Apr", month: "April 2026", rawDate: Date.from(2026, 4, 2), type: .activity, description: "Attendance"),
        AcademicEvent(title: "TEDxKIET", dateRange: "10th Apr", month: "April 2026", rawDate: Date.from(2026, 4, 10), type: .activity, description: "Event"),
        AcademicEvent(title: "Provisional Detention List (MSE2)", dateRange: "11th Apr", month: "April 2026", rawDate: Date.from(2026, 4, 11), type: .activity, description: "Warning"),
        AcademicEvent(title: "MSE2 Examination (Central)", dateRange: "20th - 25th Apr", month: "April 2026", rawDate: Date.from(2026, 4, 20), type: .activity, description: "Important Exam"),
        AcademicEvent(title: "ICICI-2026 Conference", dateRange: "24th - 25th Apr", month: "April 2026", rawDate: Date.from(2026, 4, 24), type: .activity, description: "Conference"),
        AcademicEvent(title: "Student Faculty Feedback", dateRange: "27th Apr - 9th May", month: "April 2026", rawDate: Date.from(2026, 4, 27), type: .activity, description: "Feedback"),
        
        // --- MAY 2026 ---
        AcademicEvent(title: "First Saturday", dateRange: "2nd May", month: "May 2026", rawDate: Date.from(2026, 5, 2), type: .holiday, description: "Holiday"),
        AcademicEvent(title: "Evaluation of Answer Sheets", dateRange: "1st - 5th May", month: "May 2026", rawDate: Date.from(2026, 5, 1), type: .activity, description: "Academic"),
        AcademicEvent(title: "Last Instructional Day", dateRange: "9th May", month: "May 2026", rawDate: Date.from(2026, 5, 9), type: .activity, description: "Classes End"),
        AcademicEvent(title: "Make-up Examination", dateRange: "11th - 14th May", month: "May 2026", rawDate: Date.from(2026, 5, 11), type: .activity, description: "Exam"),
        AcademicEvent(title: "Detention List Publication (ESE)", dateRange: "12th May", month: "May 2026", rawDate: Date.from(2026, 5, 12), type: .activity, description: "Final Detention"),
        AcademicEvent(title: "End Semester Exam (ESE)", dateRange: "15th - 30th May", month: "May 2026", rawDate: Date.from(2026, 5, 15), type: .activity, description: "Final Exams"),
        AcademicEvent(title: "Third Saturday", dateRange: "16th May", month: "May 2026", rawDate: Date.from(2026, 5, 16), type: .holiday, description: "Holiday"),
        AcademicEvent(title: "Eid-Ul-Zuha (Bakrid)", dateRange: "27th May", month: "May 2026", rawDate: Date.from(2026, 5, 27), type: .holiday, description: "Festival Holiday"),
        
        // --- JUNE 2026 ---
        AcademicEvent(title: "Commencement of Summer Sem", dateRange: "2nd June", month: "June 2026", rawDate: Date.from(2026, 6, 2), type: .activity, description: "Summer Term"),
        AcademicEvent(title: "IQAC Academic Audit 2", dateRange: "8th - 12th June", month: "June 2026", rawDate: Date.from(2026, 6, 8), type: .activity, description: "Audit"),
        AcademicEvent(title: "Result Publication", dateRange: "23rd June", month: "June 2026", rawDate: Date.from(2026, 6, 23), type: .activity, description: "Results"),
    ]
}

extension Date {
    static func from(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}
