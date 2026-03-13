import SwiftUI

@main
struct WaterSparkApp: App {
    @StateObject private var waterManager = WaterManager.shared
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(waterManager)
                .environmentObject(notificationManager)
                .preferredColorScheme(.light)
        }
    }
}
