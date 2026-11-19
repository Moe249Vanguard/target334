import Foundation

/// Builds a progressive, personalised calisthenics program from age, sex, height,
/// weight (BMI), goal, schedule and baseline test results.
enum ProgramGenerator {

    // MARK: - Personalisation factors

    /// Volume scaling by age: recovery capacity declines, so older trainees get fewer sets.
    static func ageFactor(_ age: Int) -> Double {
        switch age {
        case ..<30: return 1.0
        case ..<40: return 0.92
        case ..<50: return 0.84
        case ..<60: return 0.75
        default: return 0.65
        }
    }

    /// Longer rests for older trainees.
    static func restMultiplier(_ age: Int) -> Double {
        switch age {
        case ..<35: return 1.0
        case ..<45: return 1.15
        case ..<55: return 1.3
        default: return 1.5
        }
    }

    /// Joint-friendly mode swaps jumping movements for low-impact alternatives.
    static func prefersLowImpact(_ p: UserProfile) -> Bool {
        p.bmi >= 30 || p.age >= 55
    }

    struct Standards: Equatable {
        var pushUps: Double
        var pullUps: Double
        var plankSeconds: Double
        var squats: Double
    }

    /// Rough "solid pass" reference values by age and sex, used only to grade the baseline.
    static func standards(for p: UserProfile) -> Standards {
        let bracket: Int
        switch p.age {
        case ..<30: bracket = 0
        case ..<40: bracket = 1
        case ..<50: bracket = 2
        case ..<60: bracket = 3
        default: bracket = 4
        }
        let malePush: [Double] = [40, 35, 30, 25, 20]
        let malePull: [Double] = [10, 8, 6, 4, 3]
        let femalePush: [Double] = [22, 19, 16, 14, 11]
        let femalePull: [Double] = [4, 3, 2, 1, 1]
        let plank: [Double] = [120, 120, 100, 90, 75]
        let squat: [Double] = [50, 45, 40, 35, 30]
        let male = p.sex == .male
        return Standards(
            pushUps: male ? malePush[bracket] : femalePush[bracket],
            pullUps: male ? malePull[bracket] : femalePull[bracket],
            plankSeconds: plank[bracket],
            squats: squat[bracket]
        )
    }

    static func score(_ p: UserProfile) -> Double {
        let s = standards(for: p)
        let b = p.baseline
        let ratios = [
            Double(b.pushUps) / s.pushUps,
            Double(b.pullUps) / s.pullUps,
            Double(b.plankSeconds) / s.plankSeconds,
            Double(b.squats) / s.squats
        ].map { min($0, 2.0) }
        return ratios.reduce(0, +) / Double(ratios.count)
    }

    static func assessLevel(_ p: UserProfile) -> FitnessLevel {
        let s = score(p)
        if s < 0.6 { return .recruit }
        if s < 1.1 { return .soldier }
        return .elite
    }

    /// Weekly intensity multiplier: 3 build weeks, then a deload; each block starts higher.
    static func weekMultiplier(week: Int) -> (mult: Double, deload: Bool) {
        let index = (week - 1) % 4
        let block = (week - 1) / 4
        let wave: [Double] = [1.0, 1.08, 1.16, 0.85]
        return (wave[index] * (1 + 0.15 * Double(block)), index == 3)
    }

    // MARK: - Generation

    static func generate(for p: UserProfile, weeks: Int = 8) -> TrainingProgram {
        let level = assessLevel(p)
        var days: [WorkoutDay] = []
        let templates = dayTemplates(for: min(max(p.daysPerWeek, 3), 6))

        for week in 1...weeks {
            let wm = weekMultiplier(week: week)
            let ctx = Context(profile: p, level: level, mult: wm.mult, deload: wm.deload)
            for (i, template) in templates.enumerated() {
                var day = build(template, ctx: ctx, week: week, dayNumber: i + 1)
                fit(&day, toMinutes: p.sessionMinutes)
                days.append(day)
            }
        }

        return TrainingProgram(
            createdAt: Date(), level: level, weeks: weeks, days: days,
            notes: programNotes(for: p, level: level)
        )
    }

    enum Template: String, CaseIterable {
        case pushCore, pullLegs, ptCircuit, testPrep, fullBody, mobility
    }

    static func dayTemplates(for days: Int) -> [Template] {
        let all: [Template] = [.pushCore, .pullLegs, .ptCircuit, .testPrep, .fullBody, .mobility]
        return Array(all.prefix(days))
    }

    struct Context {
        let profile: UserProfile
        let level: FitnessLevel
        let mult: Double
        let deload: Bool

        var lowImpact: Bool { ProgramGenerator.prefersLowImpact(profile) }
        var goal: TrainingGoal { profile.goal }
        var b: Baseline { profile.baseline }

        var sets: Int {
            let base: Double
            switch level {
            case .recruit: base = 3
            case .soldier: base = 4
            case .elite: base = 5
            }
            var s = Int((base * ProgramGenerator.ageFactor(profile.age)).rounded())
            if goal == .strengthEndurance { s += 1 }
            if deload { s -= 1 }
            return max(2, s)
        }

        var rounds: Int {
            var r = level == .recruit ? 3 : (level == .soldier ? 4 : 5)
            if goal == .fatLoss { r += 1 }
            if deload { r -= 1 }
            return max(2, Int((Double(r) * ProgramGenerator.ageFactor(profile.age)).rounded()))
        }

        func rest(_ seconds: Int) -> Int {
            var r = Double(seconds) * ProgramGenerator.restMultiplier(profile.age)
            if goal == .fatLoss { r *= 0.75 }
            return Int((r / 5).rounded() * 5)
        }

        /// Sub-maximal reps: a fraction of the tested max, progressed weekly.
        func reps(fromMax max: Int, fraction: Double = 0.55, min lo: Int, max hi: Int) -> Int {
            let value = Int((Double(max) * fraction * mult).rounded())
            return Swift.min(Swift.max(value, lo), hi)
        }

        func seconds(fromMax max: Int, fraction: Double = 0.6, min lo: Int, max hi: Int) -> Int {
            let value = Double(max) * fraction * mult
            let rounded = Int((value / 5).rounded() * 5)
            return Swift.min(Swift.max(rounded, lo), hi)
        }

        func pick(_ normal: String, lowImpact alt: String) -> String { lowImpact ? alt : normal }
    }

    // MARK: Blocks

    static func warmup(_ ctx: Context) -> WorkoutBlock {
        WorkoutBlock(kind: .warmup, title: "Warm-up", items: [
            PrescribedExercise(exerciseID: ctx.pick("jumping-jack", lowImpact: "march-in-place"), sets: 1, seconds: 60, restSeconds: 10),
            PrescribedExercise(exerciseID: "arm-circles", sets: 1, seconds: 30, restSeconds: 10),
            PrescribedExercise(exerciseID: "inchworm", sets: 1, reps: 5, restSeconds: 10),
            PrescribedExercise(exerciseID: "worlds-greatest-stretch", sets: 1, reps: 3, restSeconds: 10, perSide: true)
        ])
    }

    static func cooldown() -> WorkoutBlock {
        WorkoutBlock(kind: .cooldown, title: "Cool-down", items: [
            PrescribedExercise(exerciseID: "childs-pose", sets: 1, seconds: 45, restSeconds: 5),
            PrescribedExercise(exerciseID: "hip-flexor-stretch", sets: 1, seconds: 30, restSeconds: 5, perSide: true),
            PrescribedExercise(exerciseID: "hamstring-stretch", sets: 1, seconds: 30, restSeconds: 5, perSide: true)
        ])
    }

    /// Main push movement chosen from the push-up baseline and goal.
    static func primaryPush(_ ctx: Context) -> PrescribedExercise {
        let max = ctx.b.pushUps
        if max < 5 {
            return PrescribedExercise(exerciseID: "incline-push-up", sets: ctx.sets,
                                      reps: ctx.reps(fromMax: 10, fraction: 1.0, min: 6, max: 15),
                                      restSeconds: ctx.rest(60),
                                      note: "Lower the incline once 3 × 15 feels easy.")
        }
        let id = ctx.goal == .armyTest ? "hand-release-push-up" : "push-up"
        return PrescribedExercise(exerciseID: id, sets: ctx.sets,
                                  reps: ctx.reps(fromMax: max, min: 3, max: 40),
                                  restSeconds: ctx.rest(75))
    }

    /// Pull progression: rows + negatives until the first pull-ups arrive.
    static func primaryPull(_ ctx: Context) -> [PrescribedExercise] {
        let max = ctx.b.pullUps
        switch max {
        case 0:
            return [
                PrescribedExercise(exerciseID: "inverted-row", sets: ctx.sets,
                                   reps: ctx.reps(fromMax: 10, fraction: 1.0, min: 6, max: 15), restSeconds: ctx.rest(75)),
                PrescribedExercise(exerciseID: "negative-pull-up", sets: 3, reps: 3, restSeconds: ctx.rest(90),
                                   note: "5-second lowering on every rep.")
            ]
        case 1...3:
            return [
                PrescribedExercise(exerciseID: "pull-up", sets: ctx.sets + 1, reps: Swift.max(1, max - 1),
                                   restSeconds: ctx.rest(90), note: "Low reps, perfect form. Stop before failure."),
                PrescribedExercise(exerciseID: "negative-pull-up", sets: 3, reps: 3, restSeconds: ctx.rest(90))
            ]
        default:
            return [
                PrescribedExercise(exerciseID: "pull-up", sets: ctx.sets,
                                   reps: ctx.reps(fromMax: max, min: 2, max: 20), restSeconds: ctx.rest(90)),
                PrescribedExercise(exerciseID: "inverted-row", sets: 2,
                                   reps: ctx.reps(fromMax: 12, fraction: 1.0, min: 8, max: 20), restSeconds: ctx.rest(60))
            ]
        }
    }

    static func plank(_ ctx: Context, fraction: Double = 0.6) -> PrescribedExercise {
        PrescribedExercise(exerciseID: "plank", sets: Swift.max(2, ctx.sets - 1),
                           seconds: ctx.seconds(fromMax: ctx.b.plankSeconds, fraction: fraction, min: 15, max: 180),
                           restSeconds: ctx.rest(45))
    }

    static func squatReps(_ ctx: Context) -> Int {
        ctx.reps(fromMax: ctx.b.squats, fraction: 0.5, min: 10, max: 40)
    }

    // MARK: Day builders

    static func build(_ t: Template, ctx: Context, week: Int, dayNumber: Int) -> WorkoutDay {
        let push = ctx.b.pushUps
        var blocks: [WorkoutBlock] = [warmup(ctx)]
        let title: String
        let focus: String

        switch t {
        case .pushCore:
            title = "Push & Core"
            focus = "Chest, shoulders, triceps and a bulletproof trunk"
            var items = [primaryPush(ctx)]
            if ctx.level != .recruit {
                items.append(PrescribedExercise(exerciseID: ctx.level == .elite ? "decline-push-up" : "pike-push-up",
                                                sets: 3, reps: ctx.reps(fromMax: push, fraction: 0.35, min: 5, max: 20),
                                                restSeconds: ctx.rest(60)))
            }
            items.append(PrescribedExercise(exerciseID: "bench-dip", sets: 3,
                                            reps: ctx.reps(fromMax: Swift.max(push, 10), fraction: 0.5, min: 6, max: 20),
                                            restSeconds: ctx.rest(60)))
            blocks.append(WorkoutBlock(kind: .main, title: "Strength", items: items))
            blocks.append(WorkoutBlock(kind: .main, title: "Core", items: [
                plank(ctx),
                PrescribedExercise(exerciseID: "flutter-kick", sets: 3, seconds: ctx.seconds(fromMax: 40, fraction: 1, min: 20, max: 60), restSeconds: ctx.rest(30)),
                PrescribedExercise(exerciseID: "side-plank", sets: 2, seconds: ctx.seconds(fromMax: ctx.b.plankSeconds, fraction: 0.35, min: 15, max: 60), restSeconds: ctx.rest(20), perSide: true)
            ]))

        case .pullLegs:
            title = "Pull & Legs"
            focus = "Back, grip and lower-body strength"
            blocks.append(WorkoutBlock(kind: .main, title: "Pull", items: primaryPull(ctx)))
            blocks.append(WorkoutBlock(kind: .main, title: "Legs", items: [
                PrescribedExercise(exerciseID: "air-squat", sets: ctx.sets, reps: squatReps(ctx), restSeconds: ctx.rest(60)),
                PrescribedExercise(exerciseID: ctx.pick("walking-lunge", lowImpact: "reverse-lunge"), sets: 3,
                                   reps: ctx.reps(fromMax: 12, fraction: 1, min: 8, max: 16), restSeconds: ctx.rest(60), perSide: true),
                PrescribedExercise(exerciseID: "glute-bridge", sets: 3, reps: ctx.reps(fromMax: 15, fraction: 1, min: 12, max: 25), restSeconds: ctx.rest(45)),
                PrescribedExercise(exerciseID: "dead-hang", sets: 2, seconds: ctx.seconds(fromMax: 40, fraction: 1, min: 15, max: 60), restSeconds: ctx.rest(60))
            ]))

        case .ptCircuit:
            title = "PT Circuit"
            focus = "Military-style conditioning: keep moving, minimal rest"
            let work = ctx.goal == .fatLoss ? 40 : 30
            blocks.append(WorkoutBlock(kind: .circuit, title: "Circuit", rounds: ctx.rounds, roundRestSeconds: ctx.rest(90), items: [
                PrescribedExercise(exerciseID: ctx.pick("burpee", lowImpact: "step-back-burpee"), sets: 1, seconds: work, restSeconds: ctx.rest(15)),
                PrescribedExercise(exerciseID: "air-squat", sets: 1, reps: squatReps(ctx), restSeconds: ctx.rest(15)),
                PrescribedExercise(exerciseID: push < 5 ? "incline-push-up" : "push-up", sets: 1,
                                   reps: ctx.reps(fromMax: Swift.max(push, 8), fraction: 0.35, min: 4, max: 25), restSeconds: ctx.rest(15)),
                PrescribedExercise(exerciseID: "mountain-climber", sets: 1, seconds: work, restSeconds: ctx.rest(15)),
                PrescribedExercise(exerciseID: "flutter-kick", sets: 1, seconds: work, restSeconds: ctx.rest(15)),
                PrescribedExercise(exerciseID: ctx.pick("high-knees", lowImpact: "march-in-place"), sets: 1, seconds: work, restSeconds: ctx.rest(15))
            ]))

        case .testPrep:
            let prep = testPrepDay(ctx, blocks: blocks)
            title = prep.0
            focus = prep.1
            blocks = prep.2

        case .fullBody:
            title = "Full-Body Strength"
            focus = "Compound bodyweight strength with harder variations"
            blocks.append(WorkoutBlock(kind: .main, title: "Strength", items: [
                PrescribedExercise(exerciseID: ctx.pick(ctx.level == .elite ? "eight-count-bodybuilder" : "burpee", lowImpact: "step-back-burpee"),
                                   sets: 3, reps: ctx.reps(fromMax: 10, fraction: 1, min: 5, max: 15), restSeconds: ctx.rest(60)),
                PrescribedExercise(exerciseID: ctx.b.pullUps >= 3 ? "chin-up" : "inverted-row", sets: ctx.sets,
                                   reps: ctx.reps(fromMax: Swift.max(ctx.b.pullUps, 10), fraction: 0.6, min: 3, max: 15), restSeconds: ctx.rest(75)),
                PrescribedExercise(exerciseID: ctx.level == .recruit ? "step-up" : "bulgarian-split-squat", sets: 3,
                                   reps: ctx.reps(fromMax: 10, fraction: 1, min: 6, max: 14), restSeconds: ctx.rest(60), perSide: true),
                PrescribedExercise(exerciseID: push >= 15 ? "diamond-push-up" : (push < 5 ? "incline-push-up" : "push-up"), sets: 3,
                                   reps: ctx.reps(fromMax: Swift.max(push, 10), fraction: 0.4, min: 5, max: 20), restSeconds: ctx.rest(60)),
                PrescribedExercise(exerciseID: ctx.level == .recruit ? "bird-dog" : "hollow-hold", sets: 3,
                                   seconds: ctx.seconds(fromMax: 30, fraction: 1, min: 15, max: 45), restSeconds: ctx.rest(30)),
                PrescribedExercise(exerciseID: "bear-crawl", sets: 3, seconds: ctx.seconds(fromMax: 25, fraction: 1, min: 15, max: 40), restSeconds: ctx.rest(45))
            ]))

        case .mobility:
            title = "Mobility & Recovery"
            focus = "Active recovery: move, stretch, breathe"
            blocks.append(WorkoutBlock(kind: .main, title: "Mobility flow", items: [
                PrescribedExercise(exerciseID: "worlds-greatest-stretch", sets: 2, reps: 5, restSeconds: 15, perSide: true),
                PrescribedExercise(exerciseID: "bird-dog", sets: 2, reps: 8, restSeconds: 15, perSide: true),
                PrescribedExercise(exerciseID: "glute-bridge", sets: 2, reps: 12, restSeconds: 20),
                PrescribedExercise(exerciseID: "dead-hang", sets: 2, seconds: 20, restSeconds: 30),
                PrescribedExercise(exerciseID: "wall-sit", sets: 2, seconds: 30, restSeconds: 30)
            ]))
        }

        blocks.append(cooldown())
        return WorkoutDay(week: week, dayNumber: dayNumber,
                          title: ctx.deload ? "\(title) (Deload)" : title,
                          focus: ctx.deload ? "Recovery week: lighter volume, crisp form. " + focus : focus,
                          isDeload: ctx.deload, blocks: blocks)
    }

    static func testPrepDay(_ ctx: Context, blocks: [WorkoutBlock]) -> (String, String, [WorkoutBlock]) {
        var blocks = blocks
        let push = ctx.b.pushUps
        switch ctx.goal {
        case .armyTest:
            blocks.append(WorkoutBlock(kind: .main, title: "Test events", items: [
                PrescribedExercise(exerciseID: push < 5 ? "incline-push-up" : "hand-release-push-up", sets: ctx.sets,
                                   reps: ctx.reps(fromMax: Swift.max(push, 8), fraction: 0.6, min: 4, max: 40), restSeconds: ctx.rest(90)),
                plank(ctx, fraction: 0.75),
                PrescribedExercise(exerciseID: ctx.pick("shuttle-sprint", lowImpact: "step-up"), sets: ctx.rounds,
                                   seconds: 30, restSeconds: ctx.rest(60), note: "Sprint-drag-carry style effort."),
                PrescribedExercise(exerciseID: ctx.pick("jump-squat", lowImpact: "reverse-lunge"), sets: 3,
                                   reps: ctx.reps(fromMax: 10, fraction: 1, min: 6, max: 15), restSeconds: ctx.rest(60))
            ]))
            return ("Army Test Prep", "Hand-release push-ups, plank and sprint conditioning", blocks)
        case .marineTest:
            var items = primaryPull(ctx)
            items.append(PrescribedExercise(exerciseID: ctx.b.pullUps >= 3 ? "flexed-arm-hang" : "dead-hang", sets: 2,
                                            seconds: ctx.seconds(fromMax: 30, fraction: 1, min: 15, max: 60), restSeconds: ctx.rest(60)))
            items.append(plank(ctx, fraction: 0.75))
            items.append(PrescribedExercise(exerciseID: push < 5 ? "incline-push-up" : "push-up", sets: 3,
                                            reps: ctx.reps(fromMax: Swift.max(push, 8), fraction: 0.6, min: 4, max: 40), restSeconds: ctx.rest(75)))
            blocks.append(WorkoutBlock(kind: .main, title: "Test events", items: items))
            return ("Marine PFT Prep", "Pull-up volume, plank endurance and push-ups", blocks)
        case .navyTest:
            blocks.append(WorkoutBlock(kind: .main, title: "Test events", items: [
                PrescribedExercise(exerciseID: push < 5 ? "incline-push-up" : "push-up", sets: ctx.sets + 1,
                                   reps: ctx.reps(fromMax: Swift.max(push, 8), fraction: 0.6, min: 4, max: 45), restSeconds: ctx.rest(75)),
                plank(ctx, fraction: 0.8),
                PrescribedExercise(exerciseID: ctx.pick("high-knees", lowImpact: "step-up"), sets: ctx.rounds,
                                   seconds: 40, restSeconds: ctx.rest(40), note: "Interval effort to support the run.")
            ]))
            return ("Navy PRT Prep", "Push-up endurance, forearm plank and intervals", blocks)
        case .generalReadiness, .fatLoss, .strengthEndurance:
            blocks.append(WorkoutBlock(kind: .main, title: "Max-effort ladder", items: [
                PrescribedExercise(exerciseID: push < 5 ? "incline-push-up" : "push-up", sets: ctx.sets,
                                   reps: ctx.reps(fromMax: Swift.max(push, 8), fraction: 0.5, min: 4, max: 35), restSeconds: ctx.rest(60)),
                PrescribedExercise(exerciseID: ctx.b.pullUps > 0 ? "pull-up" : "inverted-row", sets: ctx.sets,
                                   reps: ctx.reps(fromMax: Swift.max(ctx.b.pullUps, 10), fraction: 0.5, min: 1, max: 15), restSeconds: ctx.rest(75)),
                PrescribedExercise(exerciseID: "sit-up", sets: 3, reps: ctx.reps(fromMax: 20, fraction: 1, min: 10, max: 35), restSeconds: ctx.rest(45)),
                plank(ctx, fraction: 0.7)
            ]))
            return ("Test Prep", "Practice the movements you'll be tested on", blocks)
        }
    }

    // MARK: - Time fitting

    /// Trims sets / rounds until the session fits the user's chosen duration.
    static func fit(_ day: inout WorkoutDay, toMinutes minutes: Int) {
        let target = minutes * 60
        var guardCounter = 0
        while day.blocks.reduce(0, { $0 + $1.estimatedSeconds }) > target && guardCounter < 60 {
            guardCounter += 1
            var changed = false
            for bi in day.blocks.indices where day.blocks[bi].kind == .circuit && day.blocks[bi].rounds > 2 {
                day.blocks[bi].rounds -= 1
                changed = true
                break
            }
            if changed { continue }
            // Reduce the item with the most sets in a main block.
            var best: (Int, Int, Int)? = nil  // block, item, sets
            for bi in day.blocks.indices where day.blocks[bi].kind == .main {
                for ii in day.blocks[bi].items.indices {
                    let s = day.blocks[bi].items[ii].sets
                    if s > 2 && (best == nil || s > best!.2) { best = (bi, ii, s) }
                }
            }
            if let best {
                day.blocks[best.0].items[best.1].sets -= 1
            } else {
                break
            }
        }
    }

    // MARK: - Notes

    static func programNotes(for p: UserProfile, level: FitnessLevel) -> [String] {
        var notes: [String] = []
        notes.append("Assessed level: \(level.label). Reps are set at about 55% of your tested max and rise roughly 8% a week.")
        notes.append("Weeks 4 and 8 are deload weeks with less volume, so you recover and adapt.")
        if p.age >= 40 {
            notes.append("Age \(p.age): volume reduced and rest extended to protect recovery. Warm up thoroughly.")
        }
        if prefersLowImpact(p) {
            notes.append("Joint-friendly mode: jumping movements swapped for low-impact alternatives (BMI \(String(format: "%.1f", p.bmi)), age \(p.age)).")
        }
        if p.baseline.pullUps == 0 {
            notes.append("No pull-ups yet: rows and slow negatives will build your first rep. Retest every 4 weeks.")
        }
        notes.append("Retest your maxes after week 4 (Settings → Retest baseline) to recalibrate the plan.")
        return notes
    }
}
