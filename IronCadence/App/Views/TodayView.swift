import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var health: HealthKitManager
    @State private var activeDay: WorkoutDay?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    missionCard
                    statsGrid
                    readinessCard
                    fuelCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Today")
            .refreshable { await health.refresh() }
            .fullScreenCover(item: $activeDay) { day in
                WorkoutPlayerView(day: day)
            }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = store.profile?.name.isEmpty == false ? ", \(store.profile!.name)" : ""
        switch hour {
        case 4..<12: return "Morning\(name)"
        case 12..<17: return "Afternoon\(name)"
        default: return "Evening\(name)"
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting).font(.title2.bold())
            if let program = store.program {
                Text("Week \(store.currentWeek) of \(program.weeks) · \(program.level.label) level")
                    .foregroundStyle(.secondary)
                ProgressView(value: store.programProgress)
                    .padding(.top, 4)
            }
        }
    }

    @ViewBuilder
    private var missionCard: some View {
        if let day = store.nextWorkout {
            Card {
                HStack {
                    Text("NEXT MISSION").font(.caption.bold()).foregroundStyle(Theme.olive)
                    Spacer()
                    if day.isDeload {
                        Text("DELOAD").font(.caption2.bold())
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Theme.sand.opacity(0.4), in: Capsule())
                    }
                }
                Text(day.title).font(.title2.bold())
                Text(day.focus).foregroundStyle(.secondary)
                HStack(spacing: 16) {
                    Label("~\(day.estimatedMinutes) min", systemImage: "clock")
                    Label("\(day.exerciseCount) drills", systemImage: "list.bullet")
                    Label("W\(day.week) D\(day.dayNumber)", systemImage: "calendar")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)

                NavigationLink {
                    WorkoutDetailView(day: day)
                } label: {
                    Text("View briefing")
                }
                .padding(.top, 4)

                Button {
                    activeDay = day
                } label: {
                    Label("Start workout", systemImage: "play.fill")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        } else {
            Card {
                Label("Program complete", systemImage: "medal.fill")
                    .font(.title3.bold())
                Text("Outstanding work. Retest your baseline in Profile and generate the next 8-week block.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatTile(title: "This week", value: "\(store.workoutsThisWeek)/\(store.profile?.daysPerWeek ?? 0)", icon: "checkmark.seal")
            StatTile(title: "Week streak", value: "\(store.weekStreak)", icon: "flame", tint: Theme.ranger)
            StatTile(title: "Total sessions", value: "\(store.logs.count)", icon: "figure.strengthtraining.traditional")
            StatTile(title: "Steps today", value: health.stepsToday.map { "\(Int($0))" } ?? "—", icon: "figure.walk")
        }
    }

    private var readinessCard: some View {
        Card {
            HStack {
                Label("Readiness", systemImage: "heart.text.square")
                    .font(.headline)
                Spacer()
                if health.garminSourceDetected {
                    Label("Garmin", systemImage: "applewatch")
                        .font(.caption.bold())
                        .foregroundStyle(Theme.olive)
                }
            }
            if !health.hasRequestedAccess {
                Text("Connect Apple Health in Profile to see resting HR, HRV and sleep from your Garmin watch.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                HStack {
                    metric("Resting HR", health.restingHeartRate.map { "\(Int($0)) bpm" })
                    metric("HRV", health.hrv.map { "\(Int($0)) ms" })
                    metric("Sleep", health.sleepHoursLastNight.map { String(format: "%.1f h", $0) })
                }
                Text(readinessAdvice)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var readinessAdvice: String {
        if let sleep = health.sleepHoursLastNight, sleep < 6 {
            return "Short sleep last night. Keep today's effort moderate and focus on form."
        }
        return "Recovered and ready. Train as prescribed."
    }

    private func metric(_ title: String, _ value: String?) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value ?? "—").font(.headline).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var fuelCard: some View {
        if let plan = store.nutrition {
            Card {
                Label("Fuel today", systemImage: "fork.knife").font(.headline)
                HStack {
                    metric("Calories", "\(plan.targetCalories)")
                    metric("Protein", "\(plan.proteinG) g")
                    metric("Water", String(format: "%.1f / %.1f L", Double(store.waterToday) / 1000, Double(plan.waterMl) / 1000))
                }
                Button {
                    store.addWater(250)
                } label: {
                    Label("Log a glass (250 ml)", systemImage: "drop.fill")
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
