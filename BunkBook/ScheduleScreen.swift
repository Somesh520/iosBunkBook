import SwiftUI

// ✅ Helper Functions (Optimized)
struct DateUtils {
    static let apiFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let dateKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()
    
    static let dayNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    static let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter
    }()
}

func parseCustomDate(_ dateString: String) -> Date {
    return DateUtils.apiFormatter.date(from: dateString) ?? Date()
}

func formatDateKey(_ date: Date) -> String {
    return DateUtils.dateKeyFormatter.string(from: date)
}

func formatTime(_ date: Date) -> String {
    return DateUtils.timeFormatter.string(from: date)
}

func getDayName(_ date: Date) -> String {
    return DateUtils.dayNameFormatter.string(from: date)
}

func getDayNumber(_ date: Date) -> String {
    return DateUtils.dayNumberFormatter.string(from: date)
}

func getFullDateString(_ date: Date) -> String {
    return DateUtils.fullDateFormatter.string(from: date)
}

// --- MAIN SCREEN ---
struct ScheduleScreen: View {
    @AppStorage("authToken") var authToken: String? // ✅ Token Access
    
    @State private var selectedDate = Date()
    @State private var calendarDays: [Date] = []
    @State private var allEvents: [TimetableEvent] = [] // Saare events store karenge
    @State private var filteredEvents: [TimetableEvent] = [] // Sirf selected date ke events
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    // Theme Colors
    let bgLight = Color(uiColor: .systemGroupedBackground)
    
    var body: some View {
        NavigationStack {
            ZStack {
                bgLight.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // --- HEADER ---
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Schedule")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(getFullDateString(selectedDate))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // --- CALENDAR STRIP ---
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(calendarDays, id: \.self) { date in
                                CalendarDayItem(
                                    date: date,
                                    isSelected: formatDateKey(selectedDate) == formatDateKey(date),
                                    onTap: {
                                        withAnimation {
                                            selectedDate = date
                                            filterEvents()
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                    }
                    .frame(height: 90)
                    
                    // --- CONTENT AREA ---
                    if isLoading {
                        ScrollView {
                            VStack(spacing: 20) {
                                SkeletonCard()
                                SkeletonCard()
                                SkeletonCard()
                            }
                            .padding()
                        }
                    } else if let error = errorMessage {
                         VStack {
                             Image(systemName: "wifi.slash")
                                 .font(.largeTitle)
                                 .foregroundColor(.orange)
                             Text("Failed to load schedule")
                                 .font(.headline)
                                 .padding(.top, 5)
                             Text(error)
                                 .font(.caption)
                                 .foregroundColor(.gray)
                                 .multilineTextAlignment(.center)
                                 .padding(.horizontal)
                             
                             Button("Retry") {
                                 Task { await loadData() }
                             }
                             .padding(.top)
                         }
                         .frame(maxHeight: .infinity)
                    } else if filteredEvents.isEmpty {
                        EmptyScheduleView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(filteredEvents.enumerated()), id: \.element.id) { index, event in
                                    HStack(alignment: .top, spacing: 0) {
                                        // Timeline Line Logic
                                        TimelineIndicator(type: event.type, isLast: index == filteredEvents.count - 1)
                                        
                                        // Card
                                        if event.type == "CLASS" {
                                            ClassCard(event: event)
                                        } else {
                                            HolidayCard(event: event)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                        }
                        .refreshable {
                            await loadData()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                generateCalendarDays()
                Task { await loadData() }
            }
        }
    }
    
    // --- LOGIC ---
    func generateCalendarDays() {
        let today = Date()
        // Agle 7 din generate karo
        calendarDays = (0..<7).compactMap { day -> Date? in
            return Calendar.current.date(byAdding: .day, value: day, to: today)
        }
    }
    
    // ✅ REAL API CALL
    func loadData() async {
        guard let token = authToken else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            print("📡 Fetching Weekly Schedule...")
            // API se saare hafte ka data mangwaya
            let fetchedEvents = try await APIManager.fetchWeeklySchedule(token: token)
            
            self.allEvents = fetchedEvents
            filterEvents() // Abhi ki selected date ke hisaab se filter karo
            
        } catch let error as URLError where error.code == .userAuthenticationRequired {
            print("⚠️ Schedule Auth Error (401) - Ignoring to prevent app logout.")
            self.errorMessage = "Schedule unavailable (Auth Error)"
            // self.authToken = nil // ❌ DISABLED AUTO-LOGOUT caused by flaky API
            
        } catch {
            print("❌ Schedule Error: \(error)")
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func filterEvents() {
        let key = formatDateKey(selectedDate)
        
        // 1. Filter by Date (String match: "dd/MM/yyyy")
        let dailyEvents = allEvents.filter { event in
            // Event ki start date string mein se date part match karo
            // API Start: "29/01/2026 09:00:00"
            return event.start.hasPrefix(key)
        }
        
        // 2. Sort by Time
        filteredEvents = dailyEvents.sorted {
            parseCustomDate($0.start) < parseCustomDate($1.start)
        }
    }
}

// --- COMPONENTS (Same as before) ---

struct CalendarDayItem: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(getDayName(date).uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .gray)
                
                Text(getDayNumber(date))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if isSelected {
                    Circle().fill(Color.white).frame(width: 4, height: 4)
                }
            }
            .frame(width: 60, height: 75)
            .background(isSelected ? Color.blue : Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(), value: isSelected)
        }
    }
}

struct TimelineIndicator: View {
    let type: String
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(type == "CLASS" ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: type == "CLASS" ? "book.fill" : "sun.max.fill")
                    .font(.system(size: 14))
                    .foregroundColor(type == "CLASS" ? .blue : .orange)
            }
            if !isLast {
                Rectangle()
                    .fill(type == "CLASS" ? Color.gray.opacity(0.3) : Color.orange.opacity(0.3))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 40)
        .padding(.trailing, 12)
    }
}

struct ClassCard: View {
    let event: TimetableEvent
    var timeString: String {
        let start = formatTime(parseCustomDate(event.start))
        let end = formatTime(parseCustomDate(event.end))
        return "\(start) - \(end)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(timeString).font(.caption).fontWeight(.bold).foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.courseName ?? "Unknown Subject").font(.headline).foregroundColor(.primary)
                Text(event.facultyName ?? "Unknown Faculty").font(.subheadline).foregroundColor(.secondary)
            }
            Divider()
            HStack {
                Image(systemName: "location.fill").font(.caption).foregroundColor(.gray)
                Text(event.classRoom ?? "N/A").font(.caption).foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.bottom, 20)
    }
}

struct HolidayCard: View {
    let event: TimetableEvent
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "face.smiling.fill").resizable().frame(width: 80, height: 80).foregroundColor(Color.orange.opacity(0.2)).offset(x: 100, y: 30).rotationEffect(.degrees(-20))
            VStack(alignment: .leading, spacing: 6) {
                Text("RELAX & CHILL").font(.caption2).fontWeight(.black).foregroundColor(.orange).tracking(1)
                Text(event.title ?? "Holiday").font(.title3).fontWeight(.bold).foregroundColor(Color.orange.opacity(0.8))
                Text(event.content ?? "Enjoy your break!").font(.body).foregroundColor(Color.orange)
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding()
        }
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.orange.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5])))
        .shadow(color: Color.orange.opacity(0.1), radius: 8, x: 0, y: 4)
        .offset(y: isAnimating ? -5 : 0)
        // .onAppear { withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) { isAnimating = true } }
        .padding(.bottom, 20)
    }
}

struct SkeletonCard: View {
    @State private var blink = false
    var body: some View {
        HStack(alignment: .top) {
            Circle().fill(Color.gray.opacity(0.2)).frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.2)).frame(width: 80, height: 12)
                RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.2)).frame(height: 18)
                RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.1)).frame(width: 150, height: 14)
            }
            .padding().background(Color.white).cornerRadius(12).frame(maxWidth: .infinity)
        }
        .opacity(blink ? 0.5 : 1.0)
        // .onAppear { withAnimation(Animation.easeInOut(duration: 0.8).repeatForever()) { blink = true } }
    }
}

struct EmptyScheduleView: View {
    @State private var bounce = false
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "bed.double.fill").font(.system(size: 60)).foregroundColor(Color.gray.opacity(0.4)).offset(y: bounce ? -10 : 0)
                // .onAppear { withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { bounce = true } }
            Text("No Schedule Found").font(.title3).fontWeight(.bold).foregroundColor(.secondary)
            Text("Select another date or enjoy your day!").font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).padding(.top, 50)
    }
}
