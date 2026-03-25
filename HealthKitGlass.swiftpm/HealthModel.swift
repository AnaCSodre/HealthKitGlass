import Foundation

// MARK: - Models

struct StepData: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct HeartRateData: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let bpm: Double
}

struct HealthSummary: Sendable {
    var todaySteps: Int = 0
    var todayCalories: Double = 0
    var currentHeartRate: Double = 0
    var weeklySteps: [StepData] = []
    var recentHeartRates: [HeartRateData] = []
}

enum HealthMetricType: String, CaseIterable, Identifiable {
    case steps = "Passos"
    case heartRate = "Freq. Cardíaca"
    case calories = "Calorias"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .steps: return "figure.walk"
        case .heartRate: return "heart.fill"
        case .calories: return "flame.fill"
        }
    }

    var unit: String {
        switch self {
        case .steps: return "passos"
        case .heartRate: return "bpm"
        case .calories: return "kcal"
        }
    }

    var color: String {
        switch self {
        case .steps: return "blue"
        case .heartRate: return "red"
        case .calories: return "orange"
        }
    }
}
