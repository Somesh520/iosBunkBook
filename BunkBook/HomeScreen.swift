import SwiftUI

struct HomeScreen: View {
    @ObservedObject var viewModel: HomeViewModel
    @AppStorage("authToken") var authToken: String?

    @State private var showLogoutAlert = false

    let cardBg = Color(uiColor: .secondarySystemGroupedBackground).opacity(0.9)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                

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

                    VStack(spacing: 20) {
                        Image(systemName: "lock.slash.fill")
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

                    ScrollView {
                        VStack(spacing: 24) {
                            
                            HStack {
                                Text("K-Sync")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
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
                                        viewModel.forceLogout()
                                        authToken = nil
                                    }
                                }
                            } message: {
                                Text("Are you sure you want to logout?")
                            }

                            
                            StudentProfileCard(
                                user: viewModel.userData,
                                greeting: viewModel.greeting,
                                profileImage: viewModel.profileImage,
                                attendancePercentage: viewModel.dashboardData?.presentPerc ?? 0.0
                            )
                            .padding(.horizontal)
                            .padding(.top, 10)

                            NavigationLink(destination: EventsScreen()) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 45, height: 45)
                                        
                                        Image(systemName: "calendar.badge.clock")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Academic Calendar")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Text("Holidays & Exams")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.headline)
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                                .padding(12)
                                .background(
                                    ZStack {
                                        Color.gray.opacity(0.1)
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    }
                                )
                                .cornerRadius(16)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                            
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
