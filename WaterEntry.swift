import Foundation

struct WaterEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amountOz: Double

    init(id: UUID = UUID(), date: Date = Date(), amountOz: Double) {
        self.id = id
        self.date = date
        self.amountOz = amountOz
    }
}

enum MeasurementUnit: String, CaseIterable, Codable {
    case ounces = "oz"
    case milliliters = "ml"

    var title: String {
        switch self {
        case .ounces: return "Ounces (oz)"
        case .milliliters: return "Milliliters (ml)"
        }
    }

    func format(_ ounces: Double) -> String {
        switch self {
        case .ounces:
            return "\(Int(ounces.rounded())) oz"
        case .milliliters:
            let ml = ounces * 29.5735
            return "\(Int(ml.rounded())) ml"
        }
    }
}
