import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject private var waterManager: WaterManager
    @State private var animateProgress = false
    @State private var showCelebration = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("WaterSpark")
                        .font(.largeTitle.bold())
                        .foregroundStyle(
                            LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
                        )

                    ZStack {
                        Circle()
                            .stroke(Color.cyan.opacity(0.2), lineWidth: 24)
                            .frame(width: 240, height: 240)

                        Circle()
                            .trim(from: 0, to: animateProgress ? waterManager.progress : 0)
                            .stroke(
                                AngularGradient(colors: [.cyan, .blue, .teal], center: .center),
                                style: StrokeStyle(lineWidth: 24, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 240, height: 240)
                            .animation(.easeInOut(duration: 0.7), value: waterManager.progress)

                        VStack(spacing: 8) {
                            Text("\(Int(waterManager.progress * 100))%")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                            Text("of today's goal")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        if showCelebration {
                            Text("🎉")
                                .font(.largeTitle)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }

                    summaryCard
                    quickAddCard
                    streakCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .onAppear { animateProgress = true }
            .onChange(of: waterManager.progress) { _, newValue in
                if newValue >= 1 {
                    withAnimation(.spring) { showCelebration = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation { showCelebration = false }
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            statRow(title: "Daily Goal", value: waterManager.measurementUnit.format(waterManager.dailyGoalOz))
            statRow(title: "Consumed Today", value: waterManager.measurementUnit.format(waterManager.consumedTodayOz))
            statRow(title: "Remaining", value: waterManager.measurementUnit.format(waterManager.remainingTodayOz))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var quickAddCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .font(.headline)

            HStack(spacing: 12) {
                quickAddButton(8)
                quickAddButton(12)
                quickAddButton(16)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Streak")
                .font(.headline)
            Text("🔥 \(waterManager.currentStreak) days")
                .font(.title2.bold())
                .foregroundStyle(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }

    private func quickAddButton(_ ounces: Double) -> some View {
        Button {
            waterManager.addWater(amountOz: ounces)
            if waterManager.hapticsEnabled {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        } label: {
            Text("+\(Int(ounces)) oz")
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
