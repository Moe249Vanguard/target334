import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var health: HealthKitManager
    @State private var activeDay: WorkoutDay?
    @State private var choosingFor: WorkoutDay?

    private var advice: CoachAdvice {
        SmartCoach.advice(name: store.profile?.name ?? "",
                          logs: store.logs,
                          next: store.nextWorkout,
                          trainingWeekdays: store.settings.trainingWeekdays,
                          sleepHours: health.sleepHoursLastNight)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    CoachCard(advice: advice)
                    sessionCard
                    WeekStrip()
                    statsGrid
                    waterCard
                    recoveryCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .calmBackground()
            .navigationTitle("Today")
            .refreshable { await health.refresh() }
            .fullScreenCover(item: $activeDay) { day in
                WorkoutPlayerView(day: day)
            }
            .confirmationDialog("How much time do you have?", isPresented: Binding(
                get: { choosingFor != nil }, set: { if !$0 { choosingFor = nil } }
            ), titleVisibility: .visible, presenting: choosingFor) { day in
                Button("Full session · \(day.estimatedMinutes) min") { activeDay = day }
                ForEach(ProgramGenerator.quickOptions(for: day), id: \.self) { minutes in
                    let quick = ProgramGenerator.quickVersion(of: day, minutes: minutes)
                    Button("\(minutes == advice.suggestedMinutes ? "Suggested: " : "")\(minutes)-minute version · \(quick.exerciseCount) drills") {
                        activeDay = quick
                    }
                }
                Button("Not now", role: .cancel) {}
            } message: { _ in
                Text("Shorter versions keep the main strength work and trim the rest.")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(advice.greeting)
                .font(.system(.title, design: .rounded).weight(.bold))
            if let program = store.program {
                Text("Week \(store.currentWeek) of \(program.weeks) · \(program.level.label) level")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var sessionCard: some View {
        if let day = store.nextWorkout {
            Card {
                HStack(spacing: 8) {
                    Chip(text: "Week \(day.week) · Day \(day.dayNumber)")
                    if day.isDeload { Chip(text: "Recovery week", color: Theme.sky, fill: Theme.skySoft) }
                }
                Text(day.title)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                Text(day.focus)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Chip(text: "\(day.estimatedMinutes) min")
                    Chip(text: "\(day.exerciseCount) drills")
                }
                Button("Start workout") { choosingFor = day }
                    .buttonStyle(PrimaryButtonStyle())
                NavigationLink {
                    WorkoutDetailView(day: day)
                } label: {
                    Text("See what's in it")
                }
                .buttonStyle(SoftButtonStyle())
            }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            StatTile(title: "Plan complete", value: "\(Int((store.programProgress * 100).rounded()))%", icon: "chart.bar")
            StatTile(title: "Week streak", value: "\(store.weekStreak)", icon: "flame", tint: Theme.apricot)
            StatTile(title: "Sessions", value: "\(store.logs.count)", icon: "checkmark.circle")
            StatTile(title: "Steps today", value: health.stepsToday.map { "\(Int($0))" } ?? "—", icon: "figure.walk", tint: Theme.sky)
        }
    }

    @ViewBuilder
    private var waterCard: some View {
        if let plan = store.nutrition {
            let goal = plan.waterMl + plan.trainingDayExtraWaterMl
            Card {
                HStack {
                    Text("Water").font(.headline)
                    Spacer()
                    Text(String(format: "%.2f of %.1f L", Double(store.waterToday) / 1000, Double(goal) / 1000))
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                }
                ProgressView(value: min(Double(store.waterToday), Double(goal)), total: Double(goal))
                    .tint(Theme.sky)
                HStack(spacing: 10) {
                    Button("+ Glass") { store.addWater(250) }
                        .buttonStyle(SoftButtonStyle(tint: Theme.sky, fill: Theme.skySoft))
                    Button("+ Bottle") { store.addWater(500) }
                        .buttonStyle(SoftButtonStyle(tint: Theme.sky, fill: Theme.skySoft))
                }
            }
        }
    }

    private var recoveryCard: some View {
        Card {
            HStack {
                Text("Garmin recovery").font(.headline)
                Spacer()
                if health.garminSourceDetected {
                    Chip(text: "Connected", color: Theme.primary, fill: Theme.primarySoft)
                }
            }
            if !health.hasRequestedAccess {
                Text("Connect Apple Health in Profile to see resting heart rate, HRV and sleep from your Garmin. The coach uses them to suggest easier days.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                HStack {
                    metric("Resting HR", health.restingHeartRate.map { "\(Int($0)) bpm" })
                    metric("HRV", health.hrv.map { "\(Int($0)) ms" })
                    metric("Sleep", health.sleepHoursLastNight.map { String(format: "%.1f h", $0) })
                }
            }
        }
    }

    private func metric(_ title: String, _ value: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value ?? "—").font(.headline).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CoachCard: View {
    let advice: CoachAdvice

    private var icon: String {
        switch advice.tone {
        case .go: return "bolt.fill"
        case .rest: return "moon.fill"
        case .win: return "checkmark"
        }
    }

    var body: some View {
        let colors = Theme.toneColors(advice.tone)
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.onPrimary)
                .frame(width: 38, height: 38)
                .background(colors.icon, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(advice.title).font(.headline)
                Text(advice.body).font(.subheadline)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(colors.fill, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

/// Monday–Sunday strip: dashed = planned, filled = done, outlined = today.
struct WeekStrip: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekdayIndex = (cal.component(.weekday, from: today) + 5) % 7   // 0 = Monday
        let monday = cal.date(byAdding: .day, value: -weekdayIndex, to: today) ?? today
        let days = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: monday) }
        let doneDays = Set(store.logs.map { cal.startOfDay(for: $0.start) })
        let planned = Set(store.settings.trainingWeekdays)
        let doneCount = days.filter { doneDays.contains($0) }.count

        return Card {
            HStack {
                Text("This week").font(.headline)
                Spacer()
                Text("\(doneCount) of \(store.profile?.daysPerWeek ?? 0) sessions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    let isDone = doneDays.contains(day)
                    let isPlanned = planned.contains(cal.component(.weekday, from: day))
                    let isToday = day == today
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(isDone ? Theme.primary : (isPlanned ? Theme.primarySoft : Theme.surface2))
                            if isPlanned && !isDone {
                                Circle().strokeBorder(Theme.primary, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                            }
                            if isDone {
                                Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(Theme.onPrimary)
                            } else {
                                Text("\(cal.component(.day, from: day))")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(isPlanned ? Theme.primary : .secondary)
                            }
                        }
                        .frame(width: 34, height: 34)
                        .overlay(Circle().stroke(isToday ? Theme.sky : .clear, lineWidth: 2).padding(-4))
                        Text(String(cal.veryShortWeekdaySymbols[cal.component(.weekday, from: day) - 1]))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(isToday ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(day.formatted(.dateTime.weekday(.wide))): \(isDone ? "done" : (isPlanned ? "planned" : "rest"))")
                }
            }
        }
    }
}
