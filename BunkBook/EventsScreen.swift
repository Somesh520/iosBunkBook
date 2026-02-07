import SwiftUI

struct EventsScreen: View {
    @State private var selectedTab: EventType = .activity
    @Environment(\.presentationMode) var presentationMode
    
    var filteredEvents: [String: [AcademicEvent]] {
        let events = CalendarData.events.filter { $0.type == selectedTab }
        return Dictionary(grouping: events, by: { $0.month })
    }
    

    var sortedMonths: [String] {
        let monthsOrder = ["January 2026", "February 2026", "March 2026", "April 2026", "May 2026", "June 2026"]
        return filteredEvents.keys.sorted {
            (monthsOrder.firstIndex(of: $0) ?? 99) < (monthsOrder.firstIndex(of: $1) ?? 99)
        }
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {

                Picker("View Type", selection: $selectedTab) {
                    Text("Activities").tag(EventType.activity)
                    Text("Holidays").tag(EventType.holiday)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(uiColor: .systemBackground))
                
                ScrollView {
                    LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
                        ForEach(sortedMonths, id: \.self) { month in
                            Section(header: MonthHeader(title: month)) {
                                if let events = filteredEvents[month] {
                                    ForEach(events) { event in
                                        EventRow(event: event)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Calendar Events")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct MonthHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            Spacer()
        }
        .background(Color(uiColor: .systemGroupedBackground).opacity(0.95))
    }
}


struct EventRow: View {
    let event: AcademicEvent
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {

            VStack(spacing: 4) {
                Text(extractDay(from: event.dateRange))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(event.type.color)
                
                Text(extractMonth(from: event.month))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            }
            .frame(width: 60)
            .padding(.vertical, 4)
            

            Capsule()
                .fill(event.type.color)
                .frame(width: 4)
            

            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let desc = event.description {
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(event.dateRange)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(6)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    

    func extractDay(from range: String) -> String {
        return range.components(separatedBy: " ").first ?? ""
    }
    
    func extractMonth(from monthStr: String) -> String {
        return String(monthStr.prefix(3))
    }
}
