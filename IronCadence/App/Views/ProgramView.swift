import SwiftUI

struct ProgramView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedWeek = 1
    @State private var activeDay: WorkoutDay?

    var body: some View {
        NavigationStack {
            List {
                if let program = store.program {
                    Section {
                        Picker("Week", selection: $selectedWeek) {
                            ForEach(1...program.weeks, id: \.self) { Text("W\($0)").tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("Week \(selectedWeek)") {
                        ForEach(program.days(inWeek: selectedWeek)) { day in
                            NavigationLink {
                                WorkoutDetailView(day: day)
                            } label: {
                                DayRow(day: day, completed: store.isCompleted(day))
                            }
                        }
                    }

                    Section("Program notes") {
                        ForEach(program.notes, id: \.self) { Text($0).font(.callout) }
                    }
                }

                Section {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Label("Workout history & Garmin data", systemImage: "clock.arrow.circlepath")
                    }
                }
            }
            .navigationTitle("Program")
            .onAppear { selectedWeek = store.currentWeek }
        }
    }
}

struct DayRow: View {
    let day: WorkoutDay
    let completed: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(completed ? Theme.olive : .secondary)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("Day \(day.dayNumber): \(day.title)").font(.headline)
                Text("~\(day.estimatedMinutes) min · \(day.exerciseCount) drills")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct WorkoutDetailView: View {
    let day: WorkoutDay
    @EnvironmentObject var store: AppStore
    @State private var playing = false

    var body: some View {
        List {
            Section {
                Text(day.focus).foregroundStyle(.secondary)
                Label("About \(day.estimatedMinutes) minutes", systemImage: "clock")
                Button {
                    playing = true
                } label: {
                    Label(store.isCompleted(day) ? "Repeat workout" : "Start workout", systemImage: "play.fill")
                }
                .buttonStyle(PrimaryButtonStyle())
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            ForEach(day.blocks) { block in
                Section(block.kind == .circuit ? "\(block.title) · \(block.rounds) rounds, \(block.roundRestSeconds)s between" : block.title) {
                    ForEach(block.items) { item in
                        NavigationLink {
                            ExerciseDetailView(exercise: item.exercise)
                        } label: {
                            PrescriptionRow(item: item, isCircuit: block.kind == .circuit)
                        }
                    }
                }
            }
        }
        .navigationTitle(day.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $playing) {
            WorkoutPlayerView(day: day)
        }
    }
}

struct PrescriptionRow: View {
    let item: PrescribedExercise
    var isCircuit = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.exercise.category.icon)
                .foregroundStyle(Theme.categoryColor(item.exercise.category))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.exercise.name).font(.headline)
                Text(isCircuit ? item.targetLabel : item.setsLabel)
                    .font(.subheadline)
                    .monospacedDigit()
                if item.restSeconds > 0 {
                    Text("Rest \(item.restSeconds)s").font(.caption).foregroundStyle(.secondary)
                }
                if let note = item.note {
                    Text(note).font(.caption).foregroundStyle(Theme.olive)
                }
            }
        }
    }
}

struct HistoryView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var health: HealthKitManager
    @State private var syncing = false

    var body: some View {
        List {
            Section {
                Button {
                    Task { await syncHeartRate() }
                } label: {
                    Label(syncing ? "Syncing…" : "Pull heart rate from Garmin / Apple Health", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(syncing || !health.hasRequestedAccess)
            } footer: {
                Text("Garmin data reaches Apple Health after the Garmin Connect app syncs, so it can lag a few minutes behind the workout.")
            }

            Section("Iron Cadence sessions") {
                if store.logs.isEmpty {
                    Text("No sessions yet.").foregroundStyle(.secondary)
                }
                ForEach(store.logs) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(log.title).font(.headline)
                        Text(log.start.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption).foregroundStyle(.secondary)
                        HStack(spacing: 12) {
                            Label("\(log.durationMinutes) min", systemImage: "clock")
                            Label("\(log.totalReps) reps", systemImage: "number")
                            Label("RPE \(log.rpe)", systemImage: "gauge.medium")
                            Label("\(Int(log.estimatedKcal)) kcal", systemImage: "flame")
                        }
                        .font(.caption)
                        if let avg = log.avgHeartRate, let max = log.maxHeartRate {
                            Label("Avg \(Int(avg)) · Max \(Int(max)) bpm", systemImage: "heart.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .onDelete { idx in
                    let logs = store.logs
                    idx.map { logs[$0] }.forEach(store.deleteLog)
                }
            }

            if !health.recentGarminWorkouts.isEmpty {
                Section("Other workouts in Apple Health (last 14 days)") {
                    ForEach(health.recentGarminWorkouts) { w in
                        VStack(alignment: .leading) {
                            Text("\(w.name) · \(w.source)").font(.subheadline.bold())
                            Text("\(w.start.formatted(date: .abbreviated, time: .shortened)) · \(Int(w.end.timeIntervalSince(w.start) / 60)) min"
                                 + (w.kcal.map { " · \(Int($0)) kcal" } ?? ""))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        .task { await health.refresh() }
    }

    private func syncHeartRate() async {
        syncing = true
        defer { syncing = false }
        for var log in store.logs where log.avgHeartRate == nil {
            if let hr = await health.heartRateStats(start: log.start, end: log.end) {
                log.avgHeartRate = hr.avg
                log.maxHeartRate = hr.max
                store.updateLog(log)
            }
        }
        await health.refresh()
    }
}
