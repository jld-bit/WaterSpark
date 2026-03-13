import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "drop.circle.fill")
                }

            ReminderView()
                .tabItem {
                    Label("Reminders", systemImage: "bell.circle.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color.blue)
    }
}
