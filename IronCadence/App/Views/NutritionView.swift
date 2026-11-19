import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationStack {
            Group {
                if let plan = store.nutrition, let profile = store.profile {
                    content(plan, profile)
                } else {
                    ContentUnavailableView("No profile", systemImage: "fork.knife")
                }
            }
            .navigationTitle("Fuel")
        }
    }

    private func content(_ plan: NutritionPlan, _ profile: UserProfile) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(plan.targetCalories) kcal / day")
                        .font(.largeTitle.bold())
                        .monospacedDigit()
                    Text(goalLine(profile))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    MacroBar(plan: plan)
                        .frame(height: 14)
                        .padding(.vertical, 6)
                    HStack {
                        macro("Protein", plan.proteinG, .red)
                        macro("Carbs", plan.carbsG, .orange)
                        macro("Fat", plan.fatG, .yellow)
                    }
                }
                .padding(.vertical, 4)
            }

            if !plan.warnings.isEmpty {
                Section {
                    ForEach(plan.warnings, id: \.self) {
                        Label($0, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                    }
                }
            }

            Section("How this was calculated") {
                LabeledContent("Basal metabolic rate", value: "\(plan.bmr) kcal")
                LabeledContent("Maintenance (incl. PT)", value: "\(plan.tdee) kcal")
                LabeledContent("Body", value: "\(profile.age) y · \(Units.height(profile.heightCm, profile.units)) · \(Units.weight(profile.weightKg, profile.units))")
                LabeledContent("Protein target", value: String(format: "%.1f g/kg", NutritionCalculator.proteinPerKg(profile)))
            }

            Section {
                let goal = plan.waterMl + plan.trainingDayExtraWaterMl
                LabeledContent("Today", value: String(format: "%.2f / %.1f L", Double(store.waterToday) / 1000, Double(goal) / 1000))
                ProgressView(value: min(Double(store.waterToday), Double(goal)), total: Double(goal))
                HStack {
                    Button("+250 ml") { store.addWater(250) }
                    Button("+500 ml") { store.addWater(500) }
                    Spacer()
                    Button("Undo") { store.addWater(-250) }
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.bordered)
            } header: {
                Text("Hydration")
            } footer: {
                Text("Base \(plan.waterMl) ml plus about \(plan.trainingDayExtraWaterMl) ml on training days. Drink more in heat or when rucking.")
            }

            Section("Meal timing") {
                ForEach(plan.meals) { meal in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(meal.name).font(.headline)
                            Spacer()
                            Text("\(meal.kcal) kcal · \(meal.proteinG) g P")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        Text(meal.time).font(.caption).foregroundStyle(Theme.olive)
                        ForEach(meal.examples, id: \.self) { ex in
                            Text("• \(ex)").font(.callout)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            Section("Field guidance") {
                ForEach(plan.tips, id: \.self) { Text($0).font(.callout) }
            }

            Section {
                Text("These are general estimates, not medical or dietetic advice. If you have a medical condition, are pregnant, have a history of disordered eating, or are under 18, consult a qualified professional.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func goalLine(_ p: UserProfile) -> String {
        switch p.goal {
        case .fatLoss: return "About a 20% deficit for steady fat loss while keeping strength."
        case .strengthEndurance: return "About a 10% surplus to support strength gains."
        default: return "Maintenance calories to fuel training and recovery."
        }
    }

    private func macro(_ name: String, _ grams: Int, _ color: Color) -> some View {
        VStack(alignment: .leading) {
            Label(name, systemImage: "circle.fill")
                .font(.caption)
                .foregroundStyle(color)
            Text("\(grams) g").font(.headline).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MacroBar: View {
    let plan: NutritionPlan

    var body: some View {
        GeometryReader { geo in
            let total = max(Double(plan.proteinKcal + plan.carbsKcal + plan.fatKcal), 1)
            HStack(spacing: 2) {
                Rectangle().fill(.red).frame(width: geo.size.width * Double(plan.proteinKcal) / total)
                Rectangle().fill(.orange).frame(width: geo.size.width * Double(plan.carbsKcal) / total)
                Rectangle().fill(.yellow)
            }
            .clipShape(Capsule())
        }
    }
}
