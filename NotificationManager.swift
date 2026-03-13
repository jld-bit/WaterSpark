import Foundation
import UserNotifications

struct ReminderSettings: Codable {
    var isEnabled: Bool
    var intervalHours: Int
    var quietStart: Date
    var quietEnd: Date

    static var `default`: ReminderSettings {
        let calendar = Calendar.current
        let start = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
        let end = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
        return ReminderSettings(isEnabled: false, intervalHours: 2, quietStart: start, quietEnd: end)
    }
}

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var settings: ReminderSettings {
        didSet {
            saveSettings()
            if settings.isEnabled {
                scheduleReminders()
            } else {
                cancelReminders()
            }
        }
    }

    private let center = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    private let settingsKey = "reminderSettings"

    private let messages = [
        "Time for a sip 💧",
        "Hydrate and keep going 🌊",
        "A little water break helps 💙"
    ]

    private init() {
        if let data = defaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(ReminderSettings.self, from: data) {
            settings = decoded
        } else {
            settings = .default
        }
    }

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleReminders() {
        cancelReminders()

        // We schedule separate daily recurring notifications for each hour slot.
        // This keeps reminders local-only and lets us skip user-defined quiet hours.
        // For example with a 2-hour interval, we create notifications at 00:00, 02:00,
        // 04:00, etc., excluding any hour that falls inside quiet time.
        for hour in stride(from: 0, to: 24, by: settings.intervalHours) {
            guard !isInQuietHours(hour: hour) else { continue }

            let content = UNMutableNotificationContent()
            content.title = "WaterSpark"
            content.body = messages.randomElement() ?? "Time for a sip 💧"
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "waterspark.reminder.\(hour)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    func cancelReminders() {
        center.removePendingNotificationRequests(withIdentifiers: (0..<24).map { "waterspark.reminder.\($0)" })
    }

    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: settingsKey)
        }
    }

    private func isInQuietHours(hour: Int) -> Bool {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: settings.quietStart)
        let endHour = calendar.component(.hour, from: settings.quietEnd)

        if startHour == endHour { return false }
        if startHour < endHour {
            return hour >= startHour && hour < endHour
        } else {
            return hour >= startHour || hour < endHour
        }
    }
}
