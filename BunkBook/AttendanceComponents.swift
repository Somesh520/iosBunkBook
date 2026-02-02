import SwiftUI

// 1. Circular Progress View
struct CircularProgressView: View {
    let percentage: Double
    
    var color: Color {
        if percentage >= 75 { return .green }
        else if percentage >= 65 { return .orange }
        else { return .red }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.1)
                .foregroundColor(color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(percentage / 100, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: percentage)
            
            VStack(spacing: 0) {
                Text(String(format: "%.0f", percentage))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                Text("%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color.opacity(0.8))
            }
        }
    }
}

// 2. Course Card (With Bunk Logic)
// 2. Course Card (Redesigned Layout)
struct CourseCard: View {
    let course: RegisteredCourse
    
    // --- 🧮 Bunk Calculation Logic ---
    
    var present: Int {
        course.studentCourseCompDetails?.first?.presentLecture ?? 0
    }
    
    var total: Int {
        course.studentCourseCompDetails?.first?.totalLecture ?? 0
    }
    
    var percent: Double {
        total > 0 ? (Double(present) / Double(total) * 100) : 0
    }
    
    var safeBunks: Int {
        let p = Double(present)
        // Avoid division by zero
        if p == 0 { return 0 }
        
        let maxClasses = p / 0.75
        let bunks = Int(floor(maxClasses)) - total
        return bunks > 0 ? bunks : 0
    }
    
    var mustAttend: Int {
        let p = Double(present)
        let t = Double(total)
        let required = Int(ceil(3 * t - 4 * p))
        return required > 0 ? required : 0
    }
    
    // --- UI Logic ---
    
    var statusColor: Color {
        if percent >= 75 { return .green }
        // Simple buffer for "Edge" (e.g. 75 exactly or close to dropping)
        // but for now, < 75 is Red/Orange
        if percent >= 65 { return .orange }
        return .red
    }
    
    var statusBoxColor: Color {
        if safeBunks > 0 { return Color(red: 0.9, green: 1.0, blue: 0.9) } // Light Green
        if percent >= 75 { return Color(red: 1.0, green: 0.95, blue: 0.8) } // Light Yellow/Orange
        return Color(red: 1.0, green: 0.9, blue: 0.9) // Light Red
    }
    
    var statusIcon: String {
        if safeBunks > 0 { return "checkmark.shield.fill" }
        if percent >= 75 { return "exclamationmark.shield.fill" }
        return "exclamationmark.triangle.fill"
    }
    
    var statusTitle: String {
        if safeBunks > 0 { return "Attendance is Safe" }
        if percent >= 75 { return "On the Edge!" }
        return "Action Required!"
    }
    
    var statusSubtitle: String {
        if safeBunks > 0 {
            return "You can miss \(safeBunks) more classes."
        } else if percent >= 75 {
            return "Check your calculator! You can't miss any."
        } else {
            return "You must attend next \(mustAttend) classes for 75%."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // Row 1: Header (Name & Percent)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.courseName)
                        .font(.system(size: 18, weight: .bold)) // Slightly Bigger
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text("\(present) of \(total) Attended")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Percentage Badge
                Text("\(String(format: "%.1f", percent))%") // Decimal Precision
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(statusColor.opacity(0.15))
                .foregroundColor(statusColor) // Darker Text
                .cornerRadius(12)
            }
            
            // Row 2: Linear Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.1)
                        .foregroundColor(statusColor)
                    
                    Capsule()
                        .frame(width: min(CGFloat(percent / 100) * geometry.size.width, geometry.size.width), height: 8)
                        .foregroundColor(statusColor)
                }
            }
            .frame(height: 8)
            
            // Row 3: Status Box
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: statusIcon)
                    .font(.title2)
                    .foregroundColor(statusColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(statusTitle)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.black.opacity(0.8))
                    
                    Text(statusSubtitle)
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(12)
            .background(statusBoxColor)
            .cornerRadius(12)
            
            // 🔗 View Details Link (Subtle)
            HStack {
                Spacer()
                Text("View Details ›")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue.opacity(0.8))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// 3. Student Profile Card (Redesigned Split Layout)
struct StudentProfileCard: View {
    let user: UserDetails?
    let greeting: String
    let profileImage: UIImage?
    let attendancePercentage: Double // Passed from DashboardData
    
    var body: some View {
        VStack(spacing: 15) {
            // Card 1: Personal Info
            VStack(alignment: .leading, spacing: 15) {
                // Card 1: Personal Info
                VStack(alignment: .leading, spacing: 15) {
                    // Header with Image
                    HStack(spacing: 12) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text(user?.fullName ?? "Student")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                    }
                    
                    Divider()
                    
                    // Details Rows
                    ProfileRow(icon: "person", title: "Roll No.", value: user?.rollNumber ?? "N/A")
                    ProfileRow(icon: "graduationcap", title: "Branch", value: user?.branchShortName ?? "N/A")
                    ProfileRow(icon: "books.vertical", title: "Semester", value: user?.semesterName ?? "N/A")
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                
                // Card 2: Overall Summary
                HStack(spacing: 20) {
                    // Circular Ring
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 8)
                            .opacity(0.1)
                            .foregroundColor(attendancePercentage >= 75 ? .green : (attendancePercentage >= 65 ? .orange : .red))
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(attendancePercentage / 100, 1.0)))
                            .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                            .foregroundColor(attendancePercentage >= 75 ? .green : (attendancePercentage >= 65 ? .orange : .red))
                            .rotationEffect(Angle(degrees: 270.0))
                        
                        Text("\(String(format: "%.1f", attendancePercentage))%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .frame(width: 70, height: 70)
                    
                    // Text Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Attendance")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Your official attendance summary from the dashboard.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }
    
    // Helper Row
    struct ProfileRow: View {
        let icon: String
        let title: String
        let value: String
        
        var body: some View {
            HStack(spacing: 15) { // Fixed Icons Spacing
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.gray)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(value)
                    .font(.body)
                    .fontWeight(.bold) // Bold Value
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 4)
        }
    }
}
