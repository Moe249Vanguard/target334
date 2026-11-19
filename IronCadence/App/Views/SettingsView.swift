import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var health: HealthKitManager
    @State private var settings = AppSettings()
    @State private var editingProfile = false
    @State private var retesting = false
    @State private var confirmReset = false
    @State private var notificationsAllowed = true

    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols  // index 0 = Sunday

    var body: some View {
        NavigationStack {
            Form {
                if let p = store.profile {
                    Section("Profile") {
                        LabeledContent("Name", value: p.name.isEmpty ? "—" : p.name)
                        LabeledContent("Age / sex", value: "\(p.age) · \(p.sex.label)")
                        LabeledContent("Height", value: Units.height(p.heightCm, p.units))
                        LabeledContent("Weight", value: Units.weight(p.weightKg, p.units))
                        LabeledContent("BMI", value: String(format: "%.1f", p.bmi))
                        LabeledContent("Goal", value: p.goal.label)
                        Button("Edit profile & goal") { editingProfile = true }
                        Button("Retest baseline (new program)") { retesting = true }
                    }
                    if store.baselineHistory.count > 1 {
                        Section("Baseline history") {
                            ForEach(store.baselineHistory.reversed()) { b in
                                VStack(alignment: .leading) {
                                    Text(b.date.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundStyle(.secondary)
                                    Text("Push \(b.pushUps) · Pull \(b.pullUps) · Plank \(b.plankSeconds.mmss) · Squat \(b.squats)")
                                        .font(.callout.monospacedDigit())
                                }
                            }
                        }
                    }
                }

                Section {
                    Toggle("Save sessions to Apple Health", isOn: $settings.healthSyncOn)
                    if !health.hasRequestedAccess {
                        Button("Connect Apple Health") { Task { await health.requestAuthorization() } }
                    } else {
                        LabeledContent("Garmin data detected", value: health.garminSourceDetected ? "Yes" : "Not yet")
                    }
                    if let err = health.lastError { Text(err).font(.caption).foregroundStyle(.red) }
                } header: {
                    Text("Garmin & Apple Health")
                } footer: {
                    Text("Pair your Garmin in the Garmin Connect app, then enable Garmin Connect → Settings → Connected Apps → Apple Health. Heart rate, sleep, steps and workouts then reach Iron Cadence through Apple Health. To edit permissions later, open the Health app → Sharing → Apps → Iron Cadence.")
                }

                Section {
                    if !notificationsAllowed {
                        Button("Allow notifications") {
                            Task {
                                notificationsAllowed = await NotificationManager.requestPermission()
                                store.rescheduleNotifications()
                            }
                        }
                    }
                    Toggle("Workout reminders", isOn: $settings.workoutRemindersOn)
                    if settings.workoutRemindersOn {
                        DatePicker("Time", selection: Binding(
                            get: { settings.workoutTime.date },
                            set: { settings.workoutTime = ReminderTime(date: $0) }
                        ), displayedComponents: .hourAndMinute)
                        weekdayPicker
                    }
                    Toggle("Hydration reminders", isOn: $settings.hydrationRemindersOn)
                    if settings.hydrationRemindersOn {
                        Stepper("Every \(settings.hydrationIntervalHours) h (09:00–20:00)",
                                value: $settings.hydrationIntervalHours, in: 1...4)
                    }
                    Toggle("Meal reminders", isOn: $settings.mealRemindersOn)
                    if settings.mealRemindersOn {
                        ForEach(settings.mealTimes.indices, id: \.self) { i in
                            DatePicker(["Breakfast", "Lunch", "Dinner", "Snack", "Snack"][min(i, 4)], selection: Binding(
                                get: { settings.mealTimes[i].date },
                                set: { settings.mealTimes[i] = ReminderTime(date: $0) }
                            ), displayedComponents: .hourAndMinute)
                        }
                    }
                    Toggle("Weekly check-in (Sunday 08:00)", isOn: $settings.weeklyCheckInOn)
                } header: {
                    Text("Notifications")
                }

                Section("Workout player") {
                    Toggle("Voice coaching cues", isOn: $settings.voiceCuesOn)
                }

                Section {
                    Button("Reset all data", role: .destructive) { confirmReset = true }
                } footer: {
                    Text("Iron Cadence is a training aid, not medical advice. Stop if you feel pain, dizziness or chest discomfort.")
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                settings = store.settings
                Task { notificationsAllowed = await NotificationManager.isAuthorized() }
            }
            .onChange(of: settings) { _, new in
                if new != store.settings { store.updateSettings(new) }
            }
            .sheet(isPresented: $editingProfile) {
                if let p = store.profile { ProfileEditor(profile: p, mode: .edit) }
            }
            .sheet(isPresented: $retesting) {
                if let p = store.profile { ProfileEditor(profile: p, mode: .retest) }
            }
            .confirmationDialog("Erase profile, program and history?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Erase everything", role: .destructive) { store.resetAll() }
            }
        }
    }

    private var weekdayPicker: some View {
        HStack(spacing: 6) {
            ForEach(1...7, id: \.self) { day in
                let on = settings.trainingWeekdays.contains(day)
                Button {
                    if on { settings.trainingWeekdays.removeAll { $0 == day } }
                    else { settings.trainingWeekdays.append(day); settings.trainingWeekdays.sort() }
                } label: {
                    Text(String(weekdaySymbols[day - 1].prefix(2)))
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .background(on ? Theme.olive : Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(on ? Color.white : Color.primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ProfileEditor: View {
    enum Mode { case edit, retest }

    @State var profile: UserProfile
    let mode: Mode
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var health: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var regenerate = true

    var body: some View {
        NavigationStack {
            Form {
                if mode == .edit {
                    Section("Identity") {
                        TextField("Name or call sign", text: $profile.name)
                        Picker("Units", selection: $profile.units) {
                            ForEach(UnitSystem.allCases) { Text($0.label).tag($0) }
                        }
                        Picker("Sex", selection: $profile.sex) {
                            ForEach(Sex.allCases) { Text($0.label).tag($0) }
                        }
                        Stepper("Age: \(profile.age)", value: $profile.age, in: 14...90)
                    }
                    Section("Body") {
                        BodyMeasurementFields(profile: $profile)
                        Picker("Daily activity", selection: $profile.activityLevel) {
                            ForEach(ActivityLevel.allCases) { Text($0.label).tag($0) }
                        }
                    }
                    Section("Training") {
                        Picker("Goal", selection: $profile.goal) {
                            ForEach(TrainingGoal.allCases) { Text($0.label).tag($0) }
                        }
                        Stepper("Days per week: \(profile.daysPerWeek)", value: $profile.daysPerWeek, in: 3...6)
                        Stepper("Session: \(profile.sessionMinutes) min", value: $profile.sessionMinutes, in: 20...90, step: 5)
                    }
                    Section {
                        Toggle("Regenerate program", isOn: $regenerate)
                    } footer: {
                        Text("Regenerating starts a new 8-week plan from week 1. Your history is kept.")
                    }
                } else {
                    Section {
                        Text("Max-effort test with strict form. Rest 3 minutes between events. A new program is built from the results.")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                    BaselineFields(baseline: $profile.baseline)
                }
            }
            .navigationTitle(mode == .edit ? "Edit profile" : "Retest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let weightChanged = store.profile?.weightKg != profile.weightKg
                        store.updateProfile(profile, regenerate: mode == .retest || regenerate)
                        if weightChanged && store.settings.healthSyncOn {
                            let kg = profile.weightKg
                            Task { await health.saveBodyMass(kg: kg) }
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
