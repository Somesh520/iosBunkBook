import SwiftUI

struct HomeScreen: View {
    @ObservedObject var viewModel: HomeViewModel
    @AppStorage("authToken") var authToken: String? // 💾 Logout ke liye zaroori hai

    @State private var showLogoutAlert = false // 🚨 Logout Alert State

    // 🎨 Theme Colors
    let cardBg = Color(uiColor: .secondarySystemGroupedBackground).opacity(0.9)

    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Background
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                // Subtle Gradient Blob
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .offset(x: -150, y: -300)
                    .blur(radius: 50)

                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Syncing Attendance...")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                } else if let error = viewModel.errorMessage {
                    // ❌ ERROR STATE WITH LOGOUT BUTTON
                    VStack(spacing: 20) {
                        Image(systemName: "lock.slash.fill") // Icon change kiya
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .padding(.bottom, 10)
                        
                        Text("Session Expired")
                            .font(.title2)
                            .bold()
                        
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        // 🔄 Retry Button
                        Button(action: {
                            Task { await viewModel.fetchData() }
                        }) {
                            Label("Retry", systemImage: "arrow.clockwise")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                        
                        // 🚪 LOGOUT BUTTON (Ye zaroori hai 401 fix karne ke liye)
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            Label("Logout & Re-Login", systemImage: "rectangle.portrait.and.arrow.right")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(30)
                    
                } else {
                    // ✅ MAIN CONTENT (Dashboard)
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // 🏁 TOP BAR (Logo + Logout)
                            HStack {
                                Text("BunkBook")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // 🔔 Notification Debug
                                NavigationLink(destination: NotificationDebugView()) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.blue)
                                        .padding(10)
                                        .background(
                                            Circle()
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                }
                                
                                Button(action: {
                                    showLogoutAlert = true
                                }) {
                                    Image(systemName: "power")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.red)
                                        .padding(10)
                                        .background(
                                            Circle()
                                                .fill(Color.red.opacity(0.1))
                                        )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .alert("Logout", isPresented: $showLogoutAlert) {
                                Button("Cancel", role: .cancel) { }
                                Button("Logout", role: .destructive) {
                                    withAnimation {
                                        authToken = nil // Token delete -> Login Screen aa jayegi
                                    }
                                }
                            } message: {
                                Text("Are you sure you want to logout?")
                            }

                            
                            // --- HEADER SECTION (Profile Card + Summary) ---
                            StudentProfileCard(
                                user: viewModel.userData,
                                greeting: viewModel.greeting,
                                profileImage: viewModel.profileImage,
                                attendancePercentage: viewModel.dashboardData?.presentPerc ?? 0.0
                            )
                            .padding(.horizontal)
                            .padding(.top, 10)

                            // --- SUBJECTS HEADER ---
                            HStack {
                                Text("Your Subjects")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(viewModel.courses.count) Courses")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(20)
                            }
                            .padding(.horizontal)

                            // --- COURSE LIST ---
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.courses) { course in
                                    NavigationLink(destination: CourseDetailsScreen(
                                        courseName: course.courseName,
                                        courseCode: course.courseCode,
                                        studentId: course.studentId,
                                        courseId: course.courseId,
                                        courseCompId: course.studentCourseCompDetails?.first?.courseCompId ?? 0
                                    )) {
                                        CourseCard(course: course)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            

                        }
                    }
                    .refreshable {
                        await viewModel.fetchData()
                    }
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
        }
    }
}
