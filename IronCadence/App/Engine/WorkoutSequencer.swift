import Foundation

struct PlayerStep: Identifiable, Hashable {
    enum Kind: Hashable {
        case work(item: PrescribedExercise, set: Int, of: Int)
        case rest(seconds: Int, upNext: String)
    }

    let id = UUID()
    let blockTitle: String
    let kind: Kind

    var isRest: Bool {
        if case .rest = kind { return true }
        return false
    }
}

/// Flattens a workout day into an ordered list of work and rest steps for the player.
enum WorkoutSequencer {
    static func steps(for day: WorkoutDay) -> [PlayerStep] {
        var steps: [PlayerStep] = []

        for block in day.blocks {
            if block.kind == .circuit {
                for round in 1...max(1, block.rounds) {
                    for (i, item) in block.items.enumerated() {
                        steps.append(PlayerStep(blockTitle: "\(block.title) · Round \(round)/\(block.rounds)",
                                                kind: .work(item: item, set: round, of: block.rounds)))
                        let isLastItem = i == block.items.count - 1
                        let rest = isLastItem ? block.roundRestSeconds : item.restSeconds
                        steps.append(PlayerStep(blockTitle: block.title, kind: .rest(seconds: rest, upNext: "")))
                    }
                }
            } else {
                for item in block.items {
                    for set in 1...max(1, item.sets) {
                        steps.append(PlayerStep(blockTitle: block.title,
                                                kind: .work(item: item, set: set, of: item.sets)))
                        steps.append(PlayerStep(blockTitle: block.title, kind: .rest(seconds: item.restSeconds, upNext: "")))
                    }
                }
            }
        }

        // Drop zero-length rests and trailing rest, then fill in "up next" labels.
        steps = steps.filter {
            if case .rest(let s, _) = $0.kind { return s > 0 }
            return true
        }
        while let last = steps.last, last.isRest { steps.removeLast() }

        var result: [PlayerStep] = []
        for (i, step) in steps.enumerated() {
            if case .rest(let seconds, _) = step.kind {
                var next = ""
                if i + 1 < steps.count, case .work(let item, let set, let of) = steps[i + 1].kind {
                    next = "\(item.exercise.name) · set \(set)/\(of)"
                }
                result.append(PlayerStep(blockTitle: step.blockTitle, kind: .rest(seconds: seconds, upNext: next)))
            } else {
                result.append(step)
            }
        }
        return result
    }

    /// Calisthenics ≈ 6 METs for working time; calories = METs × kg × hours.
    static func estimatedKcal(weightKg: Double, start: Date, end: Date, rpe: Int) -> Double {
        let hours = max(end.timeIntervalSince(start), 0) / 3600
        let met = 4.5 + Double(min(max(rpe, 1), 10)) * 0.35   // 4.85 … 8.0
        return (met * weightKg * hours).rounded()
    }
}
