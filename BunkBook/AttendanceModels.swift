import Foundation

// 1. User Profile
struct UserDetails: Codable, Sendable {
    let fullName: String
    let rollNumber: String?
    let branchShortName: String?
    let semesterName: String?
    let profilePhoto: String?
}

// 2. Dashboard Stats
struct DashboardData: Codable, Sendable {
    let presentPerc: Double
    let absentPerc: Double?
}

// 3. Course List
struct RegisteredCourse: Identifiable, Codable, Sendable {
    let id = UUID()
    let courseId: Int
    let courseName: String
    let courseCode: String
    let studentId: Int
    let studentCourseCompDetails: [AttendanceComponent]?
    
    enum CodingKeys: String, CodingKey {
        case courseId, courseName, courseCode, studentId, studentCourseCompDetails
    }
}

struct AttendanceComponent: Codable, Sendable {
    let courseCompId: Int
    let presentLecture: Int
    let totalLecture: Int
}

// 4. Lecture History
struct Lecture: Codable, Identifiable, Sendable {
    let id = UUID()
    let planLecDate: String
    let topicCovered: String?
    let attendance: String
    
    enum CodingKeys: String, CodingKey {
        case planLecDate, topicCovered, attendance
    }
}

// 5. Timetable Event
struct TimetableEvent: Codable, Identifiable, Sendable {
    let id = UUID()
    let type: String
    let start: String
    let end: String
    let courseName: String?
    let facultyName: String?
    let classRoom: String?
    let title: String?
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case type, start, end, courseName, facultyName, classRoom, title, content
    }
}

// 6. Exam Schedule
struct ExamSchedule: Codable, Identifiable, Sendable {
    let id = UUID()
    let strExamDate: String?
    let courseDetails: String?
    let courseCode: String?
    let courseName: String?
    let evalLevelComponentName: String?
    
    enum CodingKeys: String, CodingKey {
        case strExamDate, courseDetails, courseCode, courseName, evalLevelComponentName
    }
}

// 7. API Response Wrapper
struct APIResponse<T: Codable>: Codable {
    let success: Bool?
    let data: T?
    let error: String?
}

// MARK: - 🎓 Exam Score Models (Updated)

struct ScoreResponse: Codable {
    let data: ScoreData
}

struct ScoreData: Codable {
    let fullName: String?
    let rollNumber: String?
    let branchShortName: String?
    let semesterName: String?
    let cgpa: Double?
    let sgpa: Double? // Sometimes at root? Or inside semester?
    let studentSemesterWiseMarksDetailsList: [SemesterScore]?
}

struct SemesterScore: Codable, Identifiable {
    let id = UUID()
    let semesterName: String?
    let sgpa: Double?
    let sessionName: String?
    let regSessionName: String?
    let studentMarksDetailsDTO: [SubjectScore]?
    
    enum CodingKeys: String, CodingKey {
        case semesterName, sgpa, sessionName, regSessionName, studentMarksDetailsDTO
    }
}

struct SubjectScore: Codable, Identifiable {
    let id = UUID()
    let courseName: String?
    let courseCode: String?
    let resultSort: String? // "PASS", "FAIL"
    let courseCompDTOList: [ResultComponent]?
    
    var finalGrade: String {
        // Try to find "THEORY" or "PRACTICAL" component grade first
        if let comps = courseCompDTOList {
            for comp in comps {
                if let marks = comp.compSessionLevelMarks?.first {
                    return marks.grade ?? "N/A"
                }
            }
        }
        return "N/A"
    }
    
    enum CodingKeys: String, CodingKey {
        case courseName, courseCode, resultSort, courseCompDTOList
    }
}

struct ResultComponent: Codable {
    let courseCompName: String? // "THEORY", "PRACTICAL", "BLENDED"
    let compSessionLevelMarks: [SessionMarks]?
}

struct SessionMarks: Codable {
    let grade: String?
    let gradePoint: Double?
    let result: String? // "PASS"
    let marksObtained: Double?
    let marksOutOf: Double?
}

// 8. 🎫 Hall Ticket Models

struct ExamSession: Codable, Identifiable, Hashable {
    let sessionId: Int
    let sessionName: String
    
    var id: Int { sessionId }
}

struct HallTicketOption: Codable, Identifiable {
    let id: Int // This is the hallTicketId used for download
    let title: String
}
