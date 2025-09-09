import SwiftUI
import FirebaseFirestore
import Charts

struct ReportsView: View {
    @State private var kickData: [KickData] = []  // To store fetched data
    @State private var selectedTimeRange = TimeRange.week
    @State private var showReport = false

    // Sample data structure for kick counts
    struct KickData: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
    }

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case all = "All Time"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time range selector
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue)
                            .tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Statistics cards
                HStack(spacing: 16) {
                    StatCard(title: "Total Kicks", value: "\(totalKicks())")
                    StatCard(title: "Daily Average", value: "\(dailyAverage())")
                }
                .padding(.horizontal)
                
                // Chart
                if #available(iOS 16.0, *) {
                    Chart(kickData) { data in
                        BarMark(
                            x: .value("Date", data.date),
                            y: .value("Kicks", data.count)
                        )
                        .foregroundStyle(.blue)
                    }
                    .frame(height: 200)
                    .padding()
                } else {
                    // Fallback for older iOS versions
                    Text("Charts available in iOS 16+")
                        .foregroundColor(.gray)
                }


                // History list
                VStack(alignment: .leading, spacing: 12) {
                    Text("History")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(kickData) { data in
                        HistoryRow(date: data.date, count: data.count)
                    }
                }
            }
            .padding(.vertical)
            .onAppear {
                fetchKickData()
            }
        }
    }

    // Fetch kick data from Firestore
    func fetchKickData() {
        let db = Firestore.firestore()
        db.collection("kickCounts")
            .order(by: "date", descending: true)  // Order by the date
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }

                // Process fetched data
                kickData = snapshot?.documents.compactMap { document in
                    guard let dateTimestamp = document.data()["date"] as? Timestamp else { return nil }
                    let date = dateTimestamp.dateValue()
                    guard let count = document.data()["count"] as? Int else { return nil }
                    return KickData(date: date, count: count)
                } ?? []
            }
    }

    // Helper function to calculate total kicks
    func totalKicks() -> Int {
        kickData.reduce(0) { $0 + $1.count }
    }

    // Helper function to calculate daily average
    func dailyAverage() -> Double {
        let days = Double(kickData.count)
        return days > 0 ? Double(totalKicks()) / days : 0
    }
}

// Helper views for ReportsView
struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct HistoryRow: View {
    let date: Date
    let count: Int
    
    var body: some View {
        HStack {
            Text(date, style: .date)
            Spacer()
            Text("\(count) kicks")
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
        .padding(.horizontal)
    }
}
