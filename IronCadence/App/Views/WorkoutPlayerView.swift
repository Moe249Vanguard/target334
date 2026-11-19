import SwiftUI

struct WorkoutPlayerView: View {
    let day: WorkoutDay

    @EnvironmentObject var store: AppStore
    @EnvironmentObject var health: HealthKitManager
    @Environment(\.dismiss) private var dismiss

    @State private var steps: [PlayerStep] = []
    @State private var index = 0
    @State private var phaseEnd: Date?
    @State private var remaining = 0
    @State private var paused = false
    @State private var startDate = Date()
    @State private var setsCompleted = 0
    @State private var totalReps = 0
    @State private var finished = false
    @State private var confirmQuit = false
    @State private var showForm = false
    @State private var lastSpokenSecond = -1

    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            Group {
                if finished {
                    WorkoutSummaryView(day: day, start: startDate, end: Date(),
                                       setsCompleted: setsCompleted, totalReps: totalReps) {
                        dismiss()
                    }
                } else if steps.indices.contains(index) {
                    stepView(steps[index])
                } else {
                    ProgressView()
                }
            }
            .toolbar {
                if !finished {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("End") { confirmQuit = true }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("\(min(index + 1, steps.count)) / \(steps.count)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .confirmationDialog("End workout?", isPresented: $confirmQuit, titleVisibility: .visible) {
                Button("Finish and save progress") { finish() }
                Button("Discard workout", role: .destructive) { dismiss() }
                Button("Keep going", role: .cancel) {}
            }
            .sheet(isPresented: $showForm) {
                if steps.indices.contains(index), case .work(let item, _, _) = steps[index].kind {
                    NavigationStack { ExerciseDetailView(exercise: item.exercise) }
                }
            }
        }
        .onAppear(perform: start)
        .onReceive(timer) { _ in tick() }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    // MARK: Step UI

    @ViewBuilder
    private func stepView(_ step: PlayerStep) -> some View {
        switch step.kind {
        case .work(let item, let set, let of):
            workView(item: item, set: set, of: of, block: step.blockTitle)
        case .rest(_, let upNext):
            restView(upNext: upNext)
        }
    }

    private func workView(item: PrescribedExercise, set: Int, of: Int, block: String) -> some View {
        let ex = item.exercise
        return VStack(spacing: 20) {
            Text(block.uppercased())
                .font(.caption.bold())
                .foregroundStyle(Theme.olive)
            Image(systemName: ex.category.icon)
                .font(.system(size: 56))
                .foregroundStyle(Theme.categoryColor(ex.category))
            Text(ex.name)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("Set \(set) of \(of)")
                .font(.headline)
                .foregroundStyle(.secondary)

            if item.isTimed {
                Text(remaining.mmss)
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                if item.perSide { Text("each side").foregroundStyle(.secondary) }
            } else {
                Text("\(item.reps ?? 0)")
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                Text(item.perSide ? "reps each side" : "reps").foregroundStyle(.secondary)
            }

            if let cue = ex.cues.first {
                Label(cue, systemImage: "quote.bubble")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            HStack(spacing: 12) {
                Button {
                    showForm = true
                } label: {
                    Label("Form", systemImage: "play.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                if item.isTimed {
                    Button {
                        togglePause()
                    } label: {
                        Label(paused ? "Resume" : "Pause", systemImage: paused ? "play.fill" : "pause.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }

            Button(item.isTimed ? "Skip ahead" : "Set complete") {
                completeWork()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }

    private func restView(upNext: String) -> some View {
        VStack(spacing: 20) {
            Text("REST").font(.caption.bold()).foregroundStyle(.secondary)
            Text(remaining.mmss)
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(Theme.olive)
            if !upNext.isEmpty {
                VStack(spacing: 4) {
                    Text("Up next").font(.caption).foregroundStyle(.secondary)
                    Text(upNext).font(.headline)
                }
            }
            Text("Breathe in through the nose, out through the mouth. Shake it out.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            HStack(spacing: 12) {
                Button("+15 s") { addRest(15) }
                    .buttonStyle(.bordered).controlSize(.large)
                Button(paused ? "Resume" : "Pause") { togglePause() }
                    .buttonStyle(.bordered).controlSize(.large)
            }
            Button("Skip rest") { advance() }
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }

    // MARK: Engine

    private func start() {
        UIApplication.shared.isIdleTimerDisabled = true
        Coach.shared.enabled = store.settings.voiceCuesOn
        steps = WorkoutSequencer.steps(for: day)
        startDate = Date()
        index = 0
        beginStep()
    }

    private func beginStep() {
        guard steps.indices.contains(index) else { finish(); return }
        paused = false
        lastSpokenSecond = -1
        switch steps[index].kind {
        case .work(let item, let set, let of):
            let what = item.reps.map { "\($0) reps" } ?? "\(item.seconds ?? 30) seconds"
            Coach.shared.say("\(item.exercise.name). Set \(set) of \(of). \(what).")
            if let secs = item.seconds, item.isTimed {
                let total = item.perSide ? secs * 2 : secs
                remaining = total
                phaseEnd = Date().addingTimeInterval(TimeInterval(total))
            } else {
                phaseEnd = nil
            }
        case .rest(let seconds, _):
            Coach.shared.say("Rest.")
            remaining = seconds
            phaseEnd = Date().addingTimeInterval(TimeInterval(seconds))
        }
    }

    private func tick() {
        guard !paused, !finished, let end = phaseEnd else { return }
        let left = Int(ceil(end.timeIntervalSinceNow))
        if left != remaining { remaining = max(0, left) }
        if left <= 3 && left > 0 && left != lastSpokenSecond {
            lastSpokenSecond = left
            Coach.shared.tick()
            if case .rest = steps[index].kind { Coach.shared.say("\(left)") }
        }
        if left <= 0 {
            if case .work = steps[index].kind {
                completeWork()
            } else {
                Coach.shared.warning()
                advance()
            }
        }
    }

    private func completeWork() {
        if case .work(let item, _, _) = steps[index].kind {
            setsCompleted += 1
            if let reps = item.reps { totalReps += item.perSide ? reps * 2 : reps }
            Coach.shared.success()
        }
        advance()
    }

    private func advance() {
        index += 1
        if index >= steps.count {
            finish()
        } else {
            beginStep()
        }
    }

    private func togglePause() {
        if paused {
            phaseEnd = Date().addingTimeInterval(TimeInterval(remaining))
            paused = false
        } else {
            paused = true
        }
    }

    private func addRest(_ seconds: Int) {
        remaining += seconds
        if !paused { phaseEnd = Date().addingTimeInterval(TimeInterval(remaining)) }
    }

    private func finish() {
        phaseEnd = nil
        finished = true
        Coach.shared.say("Workout complete. Outstanding.")
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

struct WorkoutSummaryView: View {
    let day: WorkoutDay
    let start: Date
    let end: Date
    let setsCompleted: Int
    let totalReps: Int
    let onDone: () -> Void

    @EnvironmentObject var store: AppStore
    @EnvironmentObject var health: HealthKitManager
    @State private var rpe = 7
    @State private var saving = false
    @State private var message: String?

    private var kcal: Double {
        WorkoutSequencer.estimatedKcal(weightKg: store.profile?.weightKg ?? 75, start: start, end: end, rpe: rpe)
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 8) {
                    Image(systemName: "medal.fill").font(.system(size: 54)).foregroundStyle(Theme.ranger)
                    Text("Mission complete").font(.title.bold())
                    Text(day.title).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            Section("Debrief") {
                LabeledContent("Duration", value: "\(max(1, Int(end.timeIntervalSince(start) / 60))) min")
                LabeledContent("Sets completed", value: "\(setsCompleted)")
                LabeledContent("Total reps", value: "\(totalReps)")
                LabeledContent("Est. energy", value: "\(Int(kcal)) kcal")
            }
            Section {
                Stepper("Effort (RPE): \(rpe)/10", value: $rpe, in: 1...10)
                Text(rpeDescription).font(.caption).foregroundStyle(.secondary)
            } header: {
                Text("How hard was it?")
            }
            Section {
                Button(saving ? "Saving…" : "Save workout") {
                    Task { await save() }
                }
                .disabled(saving)
                if let message { Text(message).font(.footnote).foregroundStyle(.secondary) }
            } footer: {
                Text(store.settings.healthSyncOn
                     ? "Saved to Apple Health as Functional Strength Training. Heart rate from your Garmin is attached when it syncs."
                     : "Turn on Apple Health sync in Profile to save sessions to Apple Health and pull in Garmin heart rate.")
            }
        }
        .navigationTitle("Debrief")
    }

    private var rpeDescription: String {
        switch rpe {
        case ...4: return "Easy: could have done a lot more."
        case 5...6: return "Moderate: several reps left in the tank."
        case 7...8: return "Hard: 1–3 reps left. This is the sweet spot."
        default: return "Max effort: nothing left."
        }
    }

    private func save() async {
        saving = true
        var log = WorkoutLog(dayID: day.id, title: day.title, start: start, end: end,
                             setsCompleted: setsCompleted, totalReps: totalReps, rpe: rpe, estimatedKcal: kcal)
        if store.settings.healthSyncOn && health.isAvailable {
            do {
                try await health.saveWorkout(start: start, end: end, kcal: kcal)
                log.savedToHealth = true
            } catch {
                message = "Couldn't save to Apple Health: \(error.localizedDescription)"
            }
            if let hr = await health.heartRateStats(start: start, end: end) {
                log.avgHeartRate = hr.avg
                log.maxHeartRate = hr.max
            }
        }
        store.addLog(log)
        if store.settings.mealRemindersOn { NotificationManager.schedulePostWorkoutRefuel() }
        saving = false
        onDone()
    }
}
