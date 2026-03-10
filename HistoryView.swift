import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var waterManager: WaterManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    chartCard
                    bestDayCard
                    streakHistoryCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("History")
        }
    }

    private var chartCard: some View {
        let data = waterManager.lastSevenDays()
        let maxValue = max(data.map(\.amountOz).max() ?? 1, waterManager.dailyGoalOz)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(data, id: \.date) { item in
                    VStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(height: CGFloat((item.amountOz / maxValue) * 140))

                        Text(item.date, format: .dateTime.weekday(.narrow))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 170)
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var bestDayCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Best Hydration Day")
                .font(.headline)

            if let best = waterManager.bestHydrationDayLastWeek() {
                Text("\(best.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.title3.bold())
                Text(waterManager.measurementUnit.format(best.amountOz))
                    .foregroundStyle(.secondary)
            } else {
                Text("No entries yet")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var streakHistoryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Streak History")
                .font(.headline)
            Text("Current Streak: \(waterManager.currentStreak) days")
            Text("Longest Streak: \(waterManager.longestStreak) days")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
