import Foundation

struct CoachAdvice: Equatable {
    enum Tone: Equatable { case go, rest, win }

    let greeting: String
    let tone: Tone
    let title: String
    let body: String
    /// When set, the coach recommends a shorter session of this many minutes.
    let suggestedMinutes: Int?
}

/// Turns recent training, the plan and recovery data into one calm, specific suggestion.
enum SmartCoach {

    static func advice(now: Date = Date(),
                       name: String,
                       logs: [WorkoutLog],
                       next: WorkoutDay?,
                       trainingWeekdays: [Int],
                       sleepHours: Double?,
                       calendar: Calendar = .current) -> CoachAdvice {
        let hour = calendar.component(.hour, from: now)
        let base = hour < 12 ? "Good morning" : (hour < 17 ? "Good afternoon" : "Good evening")
        let greeting = name.isEmpty ? base : "\(base), \(name)"

        func make(_ tone: CoachAdvice.Tone, _ title: String, _ body: String, _ minutes: Int? = nil) -> CoachAdvice {
            CoachAdvice(greeting: greeting, tone: tone, title: title, body: body, suggestedMinutes: minutes)
        }

        let sorted = logs.sorted { $0.start > $1.start }
        let recentRPE = sorted.prefix(3).map { Double($0.rpe) }
        let daysSince: Int? = sorted.first.map {
            calendar.dateComponents([.day], from: calendar.startOfDay(for: $0.start), to: calendar.startOfDay(for: now)).day ?? 0
        }
        let isPlannedDay = trainingWeekdays.contains(calendar.component(.weekday, from: now))

        guard let next else {
            return make(.win, "Program complete",
                        "You finished all 8 weeks. Retest your baseline in Profile to build your next block.")
        }
        if daysSince == 0 {
            return make(.win, "Today's training is done",
                        "Nice work. Recovery now matters most: protein within a couple of hours, water, and 7–9 hours of sleep.")
        }
        if let sleep = sleepHours, sleep < 6 {
            return make(.rest, "Go easier today",
                        String(format: "Your watch logged %.1f hours of sleep. Take the 20-minute version and keep the effort smooth.", sleep), 20)
        }
        if recentRPE.count >= 2, (recentRPE[0] + recentRPE[1]) / 2 >= 9 {
            return make(.rest, "Ease off a little today",
                        "Your last two sessions felt close to max effort. Take the 20-minute version and keep every rep smooth.", 20)
        }
        if recentRPE.count >= 3, recentRPE.reduce(0, +) / 3 <= 5 {
            return make(.go, "This is getting easier",
                        "Your last three sessions felt moderate or easy. Retest your maxes in Profile so the plan can level up with you.")
        }
        if let days = daysSince, days >= 4 {
            return make(.rest, "Welcome back",
                        "It's been \(days) days. Ease back in with a shorter session today, then return to the full plan.", 20)
        }
        if next.isDeload {
            return make(.rest, "Recovery week",
                        "Volume is lighter this week by design. Focus on clean form and good sleep.")
        }
        if !isPlannedDay {
            return make(.rest, "Planned rest day",
                        "Rest is part of the plan. A walk or the mobility drills will help you recover, or train now if today suits you better.")
        }
        return make(.go, "Ready for today's session",
                    "\(next.title): about \(next.estimatedMinutes) minutes. Short on time? Choose a quicker version when you start.")
    }
}

extension ProgramGenerator {
    /// A shorter version of a session that keeps the main strength work.
    /// Trims warm-up and cool-down first, then sets, then trailing drills. Keeps the same id so it counts as that day.
    static func quickVersion(of day: WorkoutDay, minutes: Int) -> WorkoutDay {
        var d = day
        guard d.estimatedMinutes > minutes, let first = d.blocks.indices.first, let last = d.blocks.indices.last else { return d }
        d.blocks[first].items = Array(d.blocks[first].items.prefix(minutes <= 15 ? 2 : 3))
        d.blocks[last].items = Array(d.blocks[last].items.prefix(minutes <= 15 ? 1 : 2))
        fit(&d, toMinutes: minutes)
        var guardCounter = 0
        while d.estimatedMinutes > minutes && guardCounter < 20 {
            guardCounter += 1
            guard let bi = d.blocks.indices.last(where: { d.blocks[$0].kind == .main && d.blocks[$0].items.count > 1 }) else { break }
            d.blocks[bi].items.removeLast()
        }
        d.title = "\(day.title) · \(minutes) min"
        return d
    }

    /// Session lengths worth offering for a day (only ones meaningfully shorter than the full session).
    static func quickOptions(for day: WorkoutDay) -> [Int] {
        [30, 20, 15].filter { $0 < day.estimatedMinutes - 3 }
    }
}
