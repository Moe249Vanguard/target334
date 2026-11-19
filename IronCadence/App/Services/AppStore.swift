import Foundation
import SwiftUI

struct AppData: Codable {
    var profile: UserProfile?
    var program: TrainingProgram?
    var logs: [WorkoutLog] = []
    var settings = AppSettings()
    /// Water intake in ml keyed by yyyy-MM-dd.
    var water: [String: Int] = [:]
    var baselineHistory: [BaselineEntry] = []
}

struct BaselineEntry: Codable, Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var pushUps: Int
    var pullUps: Int
    var plankSeconds: Int
    var squats: Int
}

/// Single source of truth, persisted as JSON in the app's Documents folder.
@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var data: AppData

    private static let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("iron-cadence.json")
    }()

    init() {
        if let raw = try? Data(contentsOf: Self.fileURL),
           let decoded = try? JSONDecoder.iso.decode(AppData.self, from: raw) {
            data = decoded
        } else {
            data = AppData()
        }
    }

    private func save() {
        do {
            let raw = try JSONEncoder.iso.encode(data)
            try raw.write(to: Self.fileURL, options: .atomic)
        } catch {
            print("Save failed: \(error)")
        }
    }

    private func mutate(_ change: (inout AppData) -> Void) {
        change(&data)
        save()
    }

    // MARK: Accessors

    var profile: UserProfile? { data.profile }
    var program: TrainingProgram? { data.program }
    var logs: [WorkoutLog] { data.logs.sorted { $0.start > $1.start } }
    var settings: AppSettings { data.settings }

    var nutrition: NutritionPlan? { profile.map(NutritionCalculator.plan(for:)) }

    var completedDayIDs: Set<UUID> { Set(data.logs.compactMap(\.dayID)) }

    func isCompleted(_ day: WorkoutDay) -> Bool { completedDayIDs.contains(day.id) }

    var nextWorkout: WorkoutDay? {
        program?.days.first { !completedDayIDs.contains($0.id) }
    }

    var currentWeek: Int { nextWorkout?.week ?? (program?.weeks ?? 1) }

    var programProgress: Double {
        guard let program, !program.days.isEmpty else { return 0 }
        let done = program.days.filter { completedDayIDs.contains($0.id) }.count
        return Double(done) / Double(program.days.count)
    }

    var workoutsThisWeek: Int {
        let cal = Calendar.current
        return data.logs.filter { cal.isDate($0.start, equalTo: Date(), toGranularity: .weekOfYear) }.count
    }

    /// Consecutive calendar weeks (including this one) in which the weekly target was met.
    var weekStreak: Int {
        guard let target = profile?.daysPerWeek else { return 0 }
        let cal = Calendar.current
        var streak = 0
        var weekStart = cal.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        for i in 0..<52 {
            let count = data.logs.filter { cal.isDate($0.start, equalTo: weekStart, toGranularity: .weekOfYear) }.count
            if count >= target {
                streak += 1
            } else if i > 0 {
                break   // the current week may still be in progress
            }
            guard let prev = cal.date(byAdding: .weekOfYear, value: -1, to: weekStart) else { break }
            weekStart = prev
        }
        return streak
    }

    // MARK: Profile & program

    func completeOnboarding(_ profile: UserProfile) {
        mutate {
            $0.profile = profile
            $0.program = ProgramGenerator.generate(for: profile)
            $0.settings.trainingWeekdays = AppSettings.defaultWeekdays(for: profile.daysPerWeek)
            $0.baselineHistory.append(BaselineEntry(date: Date(), pushUps: profile.baseline.pushUps, pullUps: profile.baseline.pullUps,
                                                    plankSeconds: profile.baseline.plankSeconds, squats: profile.baseline.squats))
        }
        rescheduleNotifications()
    }

    /// Saves profile changes. Regenerating starts a fresh program (history is kept).
    func updateProfile(_ profile: UserProfile, regenerate: Bool) {
        let baselineChanged = data.profile?.baseline != profile.baseline
        mutate {
            $0.profile = profile
            if regenerate { $0.program = ProgramGenerator.generate(for: profile) }
            if baselineChanged {
                $0.baselineHistory.append(BaselineEntry(date: Date(), pushUps: profile.baseline.pushUps, pullUps: profile.baseline.pullUps,
                                                        plankSeconds: profile.baseline.plankSeconds, squats: profile.baseline.squats))
            }
        }
        rescheduleNotifications()
    }

    var baselineHistory: [BaselineEntry] { data.baselineHistory }

    // MARK: Logs

    func addLog(_ log: WorkoutLog) {
        mutate { $0.logs.append(log) }
        rescheduleNotifications()
    }

    func updateLog(_ log: WorkoutLog) {
        mutate {
            if let i = $0.logs.firstIndex(where: { $0.id == log.id }) { $0.logs[i] = log }
        }
    }

    func deleteLog(_ log: WorkoutLog) {
        mutate { $0.logs.removeAll { $0.id == log.id } }
    }

    // MARK: Settings

    func updateSettings(_ settings: AppSettings) {
        mutate { $0.settings = settings }
        rescheduleNotifications()
    }

    func rescheduleNotifications() {
        let settings = data.settings
        let next = nextWorkout?.title
        Task { await NotificationManager.reschedule(settings: settings, nextWorkoutTitle: next) }
    }

    // MARK: Water

    static func dayKey(_ date: Date = Date()) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    var waterToday: Int { data.water[Self.dayKey()] ?? 0 }

    func addWater(_ ml: Int) {
        mutate { $0.water[Self.dayKey(), default: 0] = max(0, ($0.water[Self.dayKey()] ?? 0) + ml) }
    }

    // MARK: Reset

    func resetAll() {
        mutate { $0 = AppData() }
        Task { await NotificationManager.removeAll() }
    }
}

extension JSONEncoder {
    static var iso: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }
}

extension JSONDecoder {
    static var iso: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
}
