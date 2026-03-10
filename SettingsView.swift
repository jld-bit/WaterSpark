import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var waterManager: WaterManager

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    Stepper(value: $waterManager.dailyGoalOz, in: 32...256, step: 4) {
                        Text("Daily Goal: \(waterManager.measurementUnit.format(waterManager.dailyGoalOz))")
                    }
                }

                Section("Preferences") {
                    Picker("Measurement Unit", selection: $waterManager.measurementUnit) {
                        ForEach(MeasurementUnit.allCases, id: \.rawValue) { unit in
                            Text(unit.title).tag(unit)
                        }
                    }

                    Toggle("Enable Haptics", isOn: $waterManager.hapticsEnabled)
                }

                Section("Disclaimer") {
                    Text("This app is for informational and personal wellness tracking only and is not medical advice. Consult a qualified professional for health concerns.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
