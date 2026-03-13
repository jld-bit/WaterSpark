import SwiftUI

struct ReminderView: View {
    @EnvironmentObject private var notificationManager: NotificationManager

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder Status") {
                    Toggle("Enable Reminders", isOn: enabledBinding)
                }

                Section("Interval") {
                    Picker("Reminder Interval", selection: intervalBinding) {
                        Text("Every 1 hour").tag(1)
                        Text("Every 2 hours").tag(2)
                        Text("Every 3 hours").tag(3)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Quiet Hours") {
                    DatePicker("Start Time", selection: quietStartBinding, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: quietEndBinding, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Reminders")
            .onAppear {
                notificationManager.requestPermission()
            }
        }
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { notificationManager.settings.isEnabled },
            set: {
                notificationManager.settings.isEnabled = $0
            }
        )
    }

    private var intervalBinding: Binding<Int> {
        Binding(
            get: { notificationManager.settings.intervalHours },
            set: {
                notificationManager.settings.intervalHours = $0
            }
        )
    }

    private var quietStartBinding: Binding<Date> {
        Binding(
            get: { notificationManager.settings.quietStart },
            set: {
                notificationManager.settings.quietStart = $0
            }
        )
    }

    private var quietEndBinding: Binding<Date> {
        Binding(
            get: { notificationManager.settings.quietEnd },
            set: {
                notificationManager.settings.quietEnd = $0
            }
        )
    }
}
