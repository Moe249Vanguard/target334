import Foundation

struct PrescribedExercise: Codable, Identifiable, Hashable {
    var id = UUID()
    var exerciseID: String
    var sets: Int
    var reps: Int? = nil        // rep-based when set
    var seconds: Int? = nil     // timed when set
    var restSeconds: Int
    var perSide: Bool = false
    var note: String? = nil

    var exercise: Exercise { ExerciseLibrary.exercise(exerciseID) }
    var isTimed: Bool { reps == nil }

    var targetLabel: String {
        let side = perSide ? " /side" : ""
        if let reps { return "\(reps) reps\(side)" }
        return "\(seconds ?? 30)s\(side)"
    }

    var setsLabel: String { "\(sets) × \(targetLabel)" }

    /// Approximate work time for one set, in seconds (≈3 s per rep).
    var workSecondsPerSet: Int {
        let base = reps.map { $0 * 3 } ?? (seconds ?? 30)
        return perSide ? base * 2 : base
    }
}

struct WorkoutBlock: Codable, Identifiable, Hashable {
    enum Kind: String, Codable { case warmup, main, circuit, cooldown }

    var id = UUID()
    var kind: Kind
    var title: String
    /// Circuit blocks run every item once per round; other blocks use straight sets.
    var rounds: Int = 1
    var roundRestSeconds: Int = 0
    var items: [PrescribedExercise]

    var estimatedSeconds: Int {
        if kind == .circuit {
            let perRound = items.reduce(0) { $0 + $1.workSecondsPerSet + $1.restSeconds }
            return rounds * perRound + max(0, rounds - 1) * roundRestSeconds
        }
        return items.reduce(0) { total, item in
            total + item.sets * item.workSecondsPerSet + max(0, item.sets - 1) * item.restSeconds + 20
        }
    }
}

struct WorkoutDay: Codable, Identifiable, Hashable {
    var id = UUID()
    var week: Int          // 1-based
    var dayNumber: Int     // 1-based within the week
    var title: String
    var focus: String
    var isDeload: Bool = false
    var blocks: [WorkoutBlock]

    var estimatedMinutes: Int {
        Int((Double(blocks.reduce(0) { $0 + $1.estimatedSeconds }) / 60).rounded())
    }

    var exerciseCount: Int { blocks.reduce(0) { $0 + $1.items.count } }
}

struct TrainingProgram: Codable {
    var createdAt: Date
    var level: FitnessLevel
    var weeks: Int
    var days: [WorkoutDay]
    var notes: [String]

    func days(inWeek week: Int) -> [WorkoutDay] { days.filter { $0.week == week } }
}

struct WorkoutLog: Codable, Identifiable, Hashable {
    var id = UUID()
    var dayID: UUID?
    var title: String
    var start: Date
    var end: Date
    var setsCompleted: Int
    var totalReps: Int
    var rpe: Int
    var estimatedKcal: Double
    var avgHeartRate: Double? = nil
    var maxHeartRate: Double? = nil
    var savedToHealth: Bool = false

    var durationMinutes: Int { max(1, Int(end.timeIntervalSince(start) / 60)) }
}

struct ReminderTime: Codable, Hashable {
    var hour: Int
    var minute: Int

    var date: Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }

    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    init(date: Date) {
        let c = Calendar.current.dateComponents([.hour, .minute], from: date)
        hour = c.hour ?? 7
        minute = c.minute ?? 0
    }
}

struct AppSettings: Codable, Equatable {
    var workoutRemindersOn = true
    var workoutTime = ReminderTime(hour: 6, minute: 30)
    /// Calendar weekdays (1 = Sunday … 7 = Saturday).
    var trainingWeekdays: [Int] = [2, 3, 5, 6]
    var hydrationRemindersOn = true
    var hydrationIntervalHours = 2
    var mealRemindersOn = false
    var mealTimes: [ReminderTime] = [
        ReminderTime(hour: 7, minute: 0),
        ReminderTime(hour: 12, minute: 30),
        ReminderTime(hour: 18, minute: 30)
    ]
    var weeklyCheckInOn = true
    var healthSyncOn = false
    var voiceCuesOn = true

    static func defaultWeekdays(for daysPerWeek: Int) -> [Int] {
        switch daysPerWeek {
        case ...3: return [2, 4, 6]
        case 4: return [2, 3, 5, 6]
        case 5: return [2, 3, 4, 5, 6]
        default: return [2, 3, 4, 5, 6, 7]
        }
    }
}
