import Foundation

enum Sex: String, Codable, CaseIterable, Identifiable {
    case male, female
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

enum UnitSystem: String, Codable, CaseIterable, Identifiable {
    case metric, imperial
    var id: String { rawValue }
    var label: String { self == .metric ? "Metric (kg / cm)" : "Imperial (lb / ft-in)" }
}

enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary, light, moderate, high, extreme
    var id: String { rawValue }

    var label: String {
        switch self {
        case .sedentary: return "Desk job, little movement"
        case .light: return "Lightly active"
        case .moderate: return "Active job or daily walking"
        case .high: return "Physical job / on your feet all day"
        case .extreme: return "Field duty / manual labour"
        }
    }

    /// Multiplier applied to BMR for non-exercise daily activity.
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.35
        case .moderate: return 1.45
        case .high: return 1.6
        case .extreme: return 1.75
        }
    }
}

enum TrainingGoal: String, Codable, CaseIterable, Identifiable {
    case generalReadiness, armyTest, marineTest, navyTest, fatLoss, strengthEndurance
    var id: String { rawValue }

    var label: String {
        switch self {
        case .generalReadiness: return "General combat readiness"
        case .armyTest: return "Army-style fitness test prep"
        case .marineTest: return "Marine-style PFT prep"
        case .navyTest: return "Navy-style PRT prep"
        case .fatLoss: return "Fat loss / make weight"
        case .strengthEndurance: return "Strength-endurance"
        }
    }

    var summary: String {
        switch self {
        case .generalReadiness: return "Balanced push, pull, legs, core and conditioning."
        case .armyTest: return "Hand-release push-ups, plank and sprint-style conditioning."
        case .marineTest: return "Pull-up volume, plank endurance and push-ups."
        case .navyTest: return "Push-up endurance, forearm plank and intervals."
        case .fatLoss: return "Shorter rests, more circuits and a calorie deficit."
        case .strengthEndurance: return "Extra sets and harder progressions."
        }
    }

    var icon: String {
        switch self {
        case .generalReadiness: return "shield.lefthalf.filled"
        case .armyTest: return "star.fill"
        case .marineTest: return "flag.fill"
        case .navyTest: return "anchor"
        case .fatLoss: return "flame.fill"
        case .strengthEndurance: return "bolt.fill"
        }
    }
}

enum FitnessLevel: String, Codable, CaseIterable {
    case recruit, soldier, elite
    var label: String {
        switch self {
        case .recruit: return "Recruit"
        case .soldier: return "Soldier"
        case .elite: return "Elite"
        }
    }
}

/// Self-tested maximums captured during onboarding (and re-tests).
struct Baseline: Codable, Equatable {
    var pushUps: Int = 10        // max strict reps
    var pullUps: Int = 0         // max strict reps
    var plankSeconds: Int = 45   // max forearm plank hold
    var squats: Int = 25         // max bodyweight squats in 1 minute
}

struct UserProfile: Codable, Equatable {
    var name: String = ""
    var age: Int = 30
    var sex: Sex = .male
    var heightCm: Double = 175
    var weightKg: Double = 75
    var units: UnitSystem = .metric
    var activityLevel: ActivityLevel = .moderate
    var goal: TrainingGoal = .generalReadiness
    var daysPerWeek: Int = 4
    var sessionMinutes: Int = 45
    var baseline: Baseline = Baseline()

    var bmi: Double {
        let m = heightCm / 100
        guard m > 0 else { return 0 }
        return weightKg / (m * m)
    }

    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case ..<25: return "Healthy range"
        case ..<30: return "Overweight"
        default: return "Obese range"
        }
    }
}

// MARK: - Unit helpers

enum Units {
    static func kgToLb(_ kg: Double) -> Double { kg * 2.20462 }
    static func lbToKg(_ lb: Double) -> Double { lb / 2.20462 }
    static func cmToFeetInches(_ cm: Double) -> (feet: Int, inches: Int) {
        let totalInches = Int((cm / 2.54).rounded())
        return (totalInches / 12, totalInches % 12)
    }
    static func feetInchesToCm(feet: Int, inches: Int) -> Double { Double(feet * 12 + inches) * 2.54 }

    static func weight(_ kg: Double, _ units: UnitSystem) -> String {
        units == .metric ? String(format: "%.1f kg", kg) : String(format: "%.0f lb", kgToLb(kg))
    }

    static func height(_ cm: Double, _ units: UnitSystem) -> String {
        if units == .metric { return String(format: "%.0f cm", cm) }
        let fi = cmToFeetInches(cm)
        return "\(fi.feet)′ \(fi.inches)″"
    }
}
