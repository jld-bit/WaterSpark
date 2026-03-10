import Foundation
import SwiftUI

final class WaterManager: ObservableObject {
    static let shared = WaterManager()

    @Published var dailyGoalOz: Double {
        didSet { saveDailyGoal() }
    }

    @Published var measurementUnit: MeasurementUnit {
        didSet { saveMeasurementUnit() }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Keys.hapticsEnabled) }
    }

    @Published private(set) var intakeByDay: [String: Double] {
        didSet { saveIntakeByDay() }
    }

    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current

    private enum Keys {
        static let dailyGoalOz = "dailyGoalOz"
        static let measurementUnit = "measurementUnit"
        static let hapticsEnabled = "hapticsEnabled"
        static let intakeByDay = "intakeByDay"
    }

    private init() {
        self.dailyGoalOz = defaults.object(forKey: Keys.dailyGoalOz) as? Double ?? 96

        let unitRaw = defaults.string(forKey: Keys.measurementUnit) ?? MeasurementUnit.ounces.rawValue
        self.measurementUnit = MeasurementUnit(rawValue: unitRaw) ?? .ounces

        self.hapticsEnabled = defaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? true
        self.intakeByDay = defaults.dictionary(forKey: Keys.intakeByDay) as? [String: Double] ?? [:]
    }

    var todayKey: String {
        dayKey(for: Date())
    }

    var consumedTodayOz: Double {
        intakeByDay[todayKey] ?? 0
    }

    var remainingTodayOz: Double {
        max(dailyGoalOz - consumedTodayOz, 0)
    }

    var progress: Double {
        guard dailyGoalOz > 0 else { return 0 }
        return min(consumedTodayOz / dailyGoalOz, 1)
    }

    var currentStreak: Int {
        var streak = 0
        var date = Date()

        while true {
            let key = dayKey(for: date)
            let amount = intakeByDay[key] ?? 0
            if amount >= dailyGoalOz {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else { break }
                date = previousDay
            } else {
                break
            }
        }
        return streak
    }

    var longestStreak: Int {
        let sortedDates = intakeByDay.keys.compactMap { keyToDate($0) }.sorted()
        guard !sortedDates.isEmpty else { return 0 }

        var best = 0
        var current = 0
        var previous: Date?

        for date in sortedDates {
            let goalMet = (intakeByDay[dayKey(for: date)] ?? 0) >= dailyGoalOz
            if !goalMet {
                current = 0
                previous = date
                continue
            }

            if let previous,
               let delta = calendar.dateComponents([.day], from: previous, to: date).day,
               delta == 1 {
                current += 1
            } else {
                current = 1
            }

            best = max(best, current)
            previous = date
        }

        return best
    }

    func addWater(amountOz: Double) {
        intakeByDay[todayKey, default: 0] += amountOz
    }

    func intake(for date: Date) -> Double {
        intakeByDay[dayKey(for: date)] ?? 0
    }

    func lastSevenDays() -> [(date: Date, amountOz: Double)] {
        (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            return (date, intake(for: date))
        }
        .reversed()
    }

    func bestHydrationDayLastWeek() -> (date: Date, amountOz: Double)? {
        lastSevenDays().max(by: { $0.amountOz < $1.amountOz })
    }

    private func dayKey(for date: Date) -> String {
        let start = calendar.startOfDay(for: date)
        return ISO8601DateFormatter().string(from: start)
    }

    private func keyToDate(_ key: String) -> Date? {
        ISO8601DateFormatter().date(from: key)
    }

    private func saveDailyGoal() {
        defaults.set(dailyGoalOz, forKey: Keys.dailyGoalOz)
    }

    private func saveMeasurementUnit() {
        defaults.set(measurementUnit.rawValue, forKey: Keys.measurementUnit)
    }

    private func saveIntakeByDay() {
        defaults.set(intakeByDay, forKey: Keys.intakeByDay)
    }
}
