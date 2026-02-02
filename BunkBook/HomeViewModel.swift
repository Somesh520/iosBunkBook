import SwiftUI
import Combine

// ⚙️ API Configuration
struct APIConfig {
    static let baseURL = "https://kiet.cybervidya.net/api"
    static let userDetailsURL = baseURL + "/info/student/fetch"
    static let dashboardURL = baseURL + "/student/dashboard/attendance"
    static let coursesURL = baseURL + "/student/dashboard/registered-courses"
    static let lectureWiseURL = baseURL + "/attendance/schedule/student/course/attendance/percentage"
    static let examURL_New = baseURL + "/exam/schedule/student/exams" // 🔙 Reverted to match Android
    static let examURL_Old = baseURL + "/exam/schedule/student/exams"
    
    static let scoreURL = baseURL + "/exam/score/get/score"
}

// 🛠 API MANAGER
@MainActor
struct APIManager {
    static let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
    
    // 🚀 Performance: Static Formatter
    static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return formatter
    }()
    
    static func fetchUserDetails(token: String) async throws -> UserDetails {
        let data = try await performRequest(url: APIConfig.userDetailsURL, token: token)
        let wrapper = try JSONDecoder().decode(APIResponse<UserDetails>.self, from: data)
        return wrapper.data!
    }
    
    static func fetchDashboard(token: String) async throws -> DashboardData {
        let data = try await performRequest(url: APIConfig.dashboardURL, token: token)
        let wrapper = try JSONDecoder().decode(APIResponse<DashboardData>.self, from: data)
        return wrapper.data!
    }
    
    static func fetchCourses(token: String) async throws -> [RegisteredCourse] {
        let data = try await performRequest(url: APIConfig.coursesURL, token: token)
        let wrapper = try JSONDecoder().decode(APIResponse<[RegisteredCourse]>.self, from: data)
        return wrapper.data ?? []
    }
    
    static func fetchWeeklySchedule(token: String) async throws -> [TimetableEvent] {
        let today = Date()
        guard let nextWeek = Calendar.current.date(byAdding: .day, value: 6, to: today) else { return [] }
        let startStr = apiDateFormatter.string(from: today)
        let endStr = apiDateFormatter.string(from: nextWeek)
        let url = "\(APIConfig.baseURL)/student/schedule/class?weekStartDate=\(startStr)&weekEndDate=\(endStr)"
        
        let data = try await performRequest(url: url, token: token)
        let wrapper = try JSONDecoder().decode(APIResponse<[TimetableEvent]>.self, from: data)
        return wrapper.data ?? []
    }
    
    static func fetchExamSchedule(token: String) async throws -> [ExamSchedule] {
        do {
            let data = try await performRequest(url: APIConfig.examURL_New, token: token)
            let wrapper = try JSONDecoder().decode(APIResponse<[ExamSchedule]>.self, from: data)
            return wrapper.data ?? []
        } catch {
            // 🛡️ Handled "Exams not scheduled" 400 error as empty list
            if let urlError = error as? URLError, urlError.code == .badServerResponse {
                print("ℹ️ No exams scheduled (400 caught)")
                return []
            }
            throw error
        }
    }
    
    static func fetchExamScores(token: String) async throws -> ScoreData {
        let data = try await performRequest(url: APIConfig.scoreURL, token: token)
        let wrapper = try JSONDecoder().decode(ScoreResponse.self, from: data)
        return wrapper.data
    }

    static func fetchLectures(token: String, studentId: Int, courseId: Int, courseCompId: Int) async throws -> [Lecture] {
        guard let url = URL(string: APIConfig.lectureWiseURL) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        setupHeaders(request: &request, token: token)
        let body: [String: Any] = ["studentId": studentId, "courseId": courseId, "courseCompId": courseCompId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Lecture Fetch Status: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 401 || httpResponse.statusCode == -1013 { throw URLError(.userAuthenticationRequired) }
            guard httpResponse.statusCode == 200 else { 
                print("❌ Lecture Fetch Failed with Status: \(httpResponse.statusCode)")
                throw URLError(.badServerResponse) 
            }
        }
        struct LectureWrapper: Decodable { let data: [LectureContainer]? }
        struct LectureContainer: Decodable { let lectureList: [Lecture]? }
        let wrapper = try JSONDecoder().decode(LectureWrapper.self, from: data)
        return wrapper.data?.first?.lectureList ?? []
    }
    
    private static func performRequest(url: String, token: String) async throws -> Data {
        guard let serverURL = URL(string: url) else { throw URLError(.badURL) }
        var request = URLRequest(url: serverURL)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        setupHeaders(request: &request, token: token)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 || httpResponse.statusCode == -1013 {
                print("❌ Auth Error (401). Response: \(String(data: data, encoding: .utf8) ?? "nil")")
                throw URLError(.userAuthenticationRequired)
            }
            if httpResponse.statusCode == 403 {
                print("❌ Forbidden (403). Response: \(String(data: data, encoding: .utf8) ?? "nil")")
                throw URLError(.noPermissionsToReadFile)
            }
            guard httpResponse.statusCode == 200 else {
                print("❌ Server Error (\(httpResponse.statusCode)). Response: \(String(data: data, encoding: .utf8) ?? "nil")")
                throw URLError(.badServerResponse)
            }
        }
        return data
    }
    
    private static func setupHeaders(request: inout URLRequest, token: String) {
        // 🟢 Pass-through token exactly like Android (Auth logic handled by Token itself)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(getUserAgent(), forHTTPHeaderField: "User-Agent")
    }
    
    // Helper helper to get clean UA
    static func getUserAgent() -> String {
        return "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
    }
}

// 🏠 VIEW MODEL
@MainActor
class HomeViewModel: ObservableObject {
    @Published var userData: UserDetails?
    @Published var dashboardData: DashboardData?
    @Published var courses: [RegisteredCourse] = []
    @Published var profileImage: UIImage?
    @Published var exams: [ExamSchedule] = []
    @Published var examScores: ScoreData?
    
    @Published var isLoading = true
    @Published var isExamLoading = false
    @Published var isScoreLoading = false
    @Published var errorMessage: String?
    @Published var examError: String?
    
    private var hasFetchedExams = false
    private var hasFetchedScores = false

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning," }
        if hour < 17 { return "Good Afternoon," }
        return "Good Evening,"
    }
    
    func forceLogout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
    
    // ✅ Caching Keys
    private let kCacheUser = "CACHE_USER"
    private let kCacheDashboard = "CACHE_DASHBOARD"
    private let kCacheCourses = "CACHE_COURSES"

    func fetchData() async {
        self.isLoading = true
        self.errorMessage = nil
        
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            self.errorMessage = "Not Logged In"; self.isLoading = false; return
        }
        
        // 1️⃣ Try fetching fresh data
        do {
            async let user = APIManager.fetchUserDetails(token: token)
            async let dash = APIManager.fetchDashboard(token: token)
            async let course = APIManager.fetchCourses(token: token)
            
            let fetchedUser = try await user
            let fetchedDash = try await dash
            let fetchedCourses = try await course
            
            // ✅ Save to Cache
            if let encodedUser = try? JSONEncoder().encode(fetchedUser) { UserDefaults.standard.set(encodedUser, forKey: kCacheUser) }
            if let encodedDash = try? JSONEncoder().encode(fetchedDash) { UserDefaults.standard.set(encodedDash, forKey: kCacheDashboard) }
            if let encodedCourses = try? JSONEncoder().encode(fetchedCourses) { UserDefaults.standard.set(encodedCourses, forKey: kCacheCourses) }
            
            self.userData = fetchedUser
            self.dashboardData = fetchedDash
            self.courses = fetchedCourses
            
            if let photoUrl = self.userData?.profilePhoto { fetchSecureImage(url: photoUrl, token: token) }
            self.isLoading = false
            print("✅ Dashboard Data Loaded (Fresh)")
            
            // 🕵️‍♂️ BACKGROUND FETCH: Get Branch Name from Scores if missing
            if self.userData?.branchShortName == nil {
                Task {
                    do {
                        let scores = try await APIManager.fetchExamScores(token: token)
                        if let branch = scores.branchShortName {
                            print("💡 Found Branch in Scores: \(branch)")
                            // Patch UserData
                            let patchedUser = UserDetails(
                                fullName: self.userData?.fullName ?? "",
                                rollNumber: self.userData?.rollNumber,
                                branchShortName: branch,
                                semesterName: self.userData?.semesterName,
                                profilePhoto: self.userData?.profilePhoto
                            )
                            self.userData = patchedUser
                            // Update Cache
                            if let encodedUser = try? JSONEncoder().encode(patchedUser) { 
                                UserDefaults.standard.set(encodedUser, forKey: kCacheUser) 
                            }
                        }
                    } catch {
                        print("⚠️ Failed to fetch background branch info: \(error.localizedDescription)")
                    }
                }
            }
            
        } catch {
            print("⚠️ Data Fetch Failed: \(error.localizedDescription)")
            
            // 🚨 PRIORITY 1: Check for 401 Auth Error FIRST
            if let urlError = error as? URLError, urlError.code == .userAuthenticationRequired {
                print("💀 401 Detected - Logging Out Immediately (Ignoring Cache)")
                self.forceLogout()
                return
            }

            // 2️⃣ Fallback to Cache (Only if NOT 401)
            print("Checking Cache...")
            if let dataUser = UserDefaults.standard.data(forKey: kCacheUser),
               let dataDash = UserDefaults.standard.data(forKey: kCacheDashboard),
               let dataCourses = UserDefaults.standard.data(forKey: kCacheCourses),
               let cachedUser = try? JSONDecoder().decode(UserDetails.self, from: dataUser),
               let cachedDash = try? JSONDecoder().decode(DashboardData.self, from: dataDash),
               let cachedCourses = try? JSONDecoder().decode([RegisteredCourse].self, from: dataCourses) {
                
                self.userData = cachedUser
                self.dashboardData = cachedDash
                self.courses = cachedCourses
                
                print("✅ Served from Cache")
                self.isLoading = false
            } else {
                // No Cache + No Internet = Error
                self.errorMessage = "Could not load data. Check Internet."
                self.isLoading = false
            }
        }
    }
    
    func fetchExams() async {
        if hasFetchedExams { return }
        self.isExamLoading = true
        self.examError = nil
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        
        do {
            var fetched = try await APIManager.fetchExamSchedule(token: token)
            let formatter = APIManager.apiDateFormatter
            
            fetched.sort {
                guard let strA = $0.strExamDate, let strB = $1.strExamDate,
                      let dateA = formatter.date(from: strA),
                      let dateB = formatter.date(from: strB) else { return false }
                return dateA < dateB
            }
            self.exams = fetched
            self.hasFetchedExams = true
        } catch {
            self.exams = []
        }
        self.isExamLoading = false
    }
    
    func fetchScores() async {
        if hasFetchedScores { return }
        self.isScoreLoading = true
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        
        do {
            let data = try await APIManager.fetchExamScores(token: token)
            self.examScores = data
            self.hasFetchedScores = true
        } catch {
            // Silently fail for scores as they might not be available for all students
            print("ℹ️ Scores not available or fetch failed: \(error.localizedDescription)")
        }
        self.isScoreLoading = false
    }
    
    func fetchSecureImage(url: String, token: String) {
        guard let imageUrl = URL(string: url) else { return }
        var request = URLRequest(url: imageUrl)
        // 🟢 Pass-through token
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue(APIManager.userAgent, forHTTPHeaderField: "User-Agent")
        
        print("📸 Fetching Secure Image: \(url)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📸 Image Fetch Status: \(httpResponse.statusCode)")
            }
            if let error = error {
                print("❌ Image Fetch Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                print("✅ Image Loaded Successfully")
                DispatchQueue.main.async { self.profileImage = image }
            } else {
                print("❌ Failed to decode image data")
            }
        }.resume()
    }
}
