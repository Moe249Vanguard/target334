import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var health: HealthKitManager
    @State private var profile = UserProfile()
    @State private var page = 0

    private let pageCount = 5

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(page + 1), total: Double(pageCount))
                    .padding(.horizontal)
                    .padding(.top, 8)

                TabView(selection: $page) {
                    welcome.tag(0)
                    bodyStats.tag(1)
                    goalPage.tag(2)
                    baselinePage.tag(3)
                    connectPage.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: page)

                HStack {
                    if page > 0 {
                        Button("Back") { page -= 1 }
                            .buttonStyle(.bordered)
                    }
                    Spacer()
                    Button(page == pageCount - 1 ? "Generate my program" : "Next") {
                        if page == pageCount - 1 {
                            store.completeOnboarding(profile)
                        } else {
                            page += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(page == 1 && !statsValid)
                }
                .padding()
            }
            .navigationTitle("Enlist")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var statsValid: Bool {
        (14...90).contains(profile.age) && (120...230).contains(profile.heightCm) && (35...250).contains(profile.weightKg)
    }

    // MARK: Pages

    private var welcome: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                Text("Iron Cadence")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity)
                Text("Military-style calisthenics built around your age, height, weight and current fitness, with form coaching, Garmin heart-rate tracking via Apple Health, reminders and a nutrition plan.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                TextField("Your name or call sign", text: $profile.name)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top)
                Text("Check with a doctor before starting a new exercise program, especially if you have injuries, heart conditions or are returning after a long break.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    private var bodyStats: some View {
        Form {
            Section("Units") {
                Picker("Units", selection: $profile.units) {
                    ForEach(UnitSystem.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            Section("About you") {
                Picker("Sex", selection: $profile.sex) {
                    ForEach(Sex.allCases) { Text($0.label).tag($0) }
                }
                Stepper("Age: \(profile.age)", value: $profile.age, in: 14...90)
            }
            Section("Body") {
                BodyMeasurementFields(profile: $profile)
                LabeledContent("BMI", value: String(format: "%.1f · %@", profile.bmi, profile.bmiCategory))
            }
            Section("Daily activity (outside training)") {
                Picker("Activity", selection: $profile.activityLevel) {
                    ForEach(ActivityLevel.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
    }

    private var goalPage: some View {
        Form {
            Section("Mission") {
                ForEach(TrainingGoal.allCases) { goal in
                    Button {
                        profile.goal = goal
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: goal.icon)
                                .frame(width: 28)
                                .foregroundStyle(Theme.primary)
                            VStack(alignment: .leading) {
                                Text(goal.label).foregroundStyle(.primary)
                                Text(goal.summary).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if profile.goal == goal {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.primary)
                            }
                        }
                    }
                }
            }
            Section("Schedule") {
                Stepper("Training days per week: \(profile.daysPerWeek)", value: $profile.daysPerWeek, in: 3...6)
                Stepper("Session length: \(profile.sessionMinutes) min", value: $profile.sessionMinutes, in: 20...90, step: 5)
            }
        }
    }

    private var baselinePage: some View {
        Form {
            Section {
                Text("Do a quick max-effort test, or enter your best estimate. Rest 3 minutes between tests. Strict form only. Stop when form breaks.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            BaselineFields(baseline: $profile.baseline)
        }
    }

    private var connectPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Connect").font(.title.bold())

                Card {
                    Label("Garmin watch via Apple Health", systemImage: "applewatch.radiowaves.left.and.right")
                        .font(.headline)
                    Text("1. In the Garmin Connect app: tap More → Settings → Connected Apps → Apple Health, and turn on sharing.\n2. Tap below to let Iron Cadence read your heart rate, sleep, steps and weight, and to save your sessions.\n3. During PT, start a Strength activity on your watch. Afterwards, Iron Cadence pulls your average and max heart rate for the session.")
                        .font(.callout)
                    Button(health.hasRequestedAccess ? "Apple Health connected" : "Connect Apple Health") {
                        Task { await health.requestAuthorization() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(health.hasRequestedAccess || !health.isAvailable)
                }

                Card {
                    Label("Reminders", systemImage: "bell.badge")
                        .font(.headline)
                    Text("Get reminders for training days, hydration, meals and a weekly check-in. You can change them any time in Profile.")
                        .font(.callout)
                    Button("Allow notifications") {
                        Task { await NotificationManager.requestPermission() }
                    }
                    .buttonStyle(.bordered)
                }

                Card {
                    let level = ProgramGenerator.assessLevel(profile)
                    Label("Your starting level: \(level.label)", systemImage: "chevron.up.2")
                        .font(.headline)
                    Text("8-week program, \(profile.daysPerWeek) sessions a week, about \(profile.sessionMinutes) minutes each, focused on \(profile.goal.label.lowercased()).")
                        .font(.callout)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

/// Height/weight inputs that respect the chosen unit system.
struct BodyMeasurementFields: View {
    @Binding var profile: UserProfile

    var body: some View {
        if profile.units == .metric {
            Stepper("Height: \(Int(profile.heightCm)) cm", value: $profile.heightCm, in: 120...230, step: 1)
            Stepper(String(format: "Weight: %.1f kg", profile.weightKg), value: $profile.weightKg, in: 35...250, step: 0.5)
        } else {
            let fi = Units.cmToFeetInches(profile.heightCm)
            Stepper("Height: \(fi.feet)′ \(fi.inches)″", value: Binding(
                get: { Int((profile.heightCm / 2.54).rounded()) },
                set: { profile.heightCm = Double($0) * 2.54 }
            ), in: 48...90)
            Stepper("Weight: \(Int(Units.kgToLb(profile.weightKg).rounded())) lb", value: Binding(
                get: { Int(Units.kgToLb(profile.weightKg).rounded()) },
                set: { profile.weightKg = Units.lbToKg(Double($0)) }
            ), in: 77...550)
        }
    }
}

struct BaselineFields: View {
    @Binding var baseline: Baseline

    var body: some View {
        Section("Max strict push-ups") {
            Stepper("\(baseline.pushUps) reps", value: $baseline.pushUps, in: 0...150)
        }
        Section("Max strict pull-ups (dead hang)") {
            Stepper("\(baseline.pullUps) reps", value: $baseline.pullUps, in: 0...50)
        }
        Section("Max forearm plank") {
            Stepper("\(baseline.plankSeconds.mmss)", value: $baseline.plankSeconds, in: 0...600, step: 5)
        }
        Section("Air squats in 1 minute") {
            Stepper("\(baseline.squats) reps", value: $baseline.squats, in: 0...100)
        }
    }
}
