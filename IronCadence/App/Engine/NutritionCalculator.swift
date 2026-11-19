import Foundation

struct MealSlot: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let time: String
    let kcal: Int
    let proteinG: Int
    let examples: [String]
}

struct NutritionPlan {
    let bmr: Int
    let tdee: Int
    let targetCalories: Int
    let proteinG: Int
    let fatG: Int
    let carbsG: Int
    let waterMl: Int
    let trainingDayExtraWaterMl: Int
    let meals: [MealSlot]
    let tips: [String]
    let warnings: [String]

    var proteinKcal: Int { proteinG * 4 }
    var fatKcal: Int { fatG * 9 }
    var carbsKcal: Int { carbsG * 4 }
}

/// Evidence-based estimates: Mifflin-St Jeor BMR, activity multiplier plus training load,
/// goal-adjusted calories and sports-nutrition protein ranges. General guidance, not medical advice.
enum NutritionCalculator {

    static func bmr(_ p: UserProfile) -> Double {
        let base = 10 * p.weightKg + 6.25 * p.heightCm - 5 * Double(p.age)
        return p.sex == .male ? base + 5 : base - 161
    }

    /// Average daily kcal from calisthenics sessions (~6 METs), spread over the week.
    static func trainingKcalPerDay(_ p: UserProfile) -> Double {
        let met = 6.0
        let perSession = met * p.weightKg * Double(p.sessionMinutes) / 60
        return perSession * Double(p.daysPerWeek) / 7
    }

    static func proteinPerKg(_ p: UserProfile) -> Double {
        var g = 1.8
        if p.goal == .fatLoss { g = 2.2 }           // preserve muscle in a deficit
        if p.goal == .strengthEndurance { g = 2.0 }
        if p.age >= 50 { g = max(g, 2.0) }          // offset age-related muscle loss
        return g
    }

    static func plan(for p: UserProfile) -> NutritionPlan {
        let b = bmr(p)
        let tdee = b * p.activityLevel.multiplier + trainingKcalPerDay(p)
        var warnings: [String] = []

        var target: Double
        switch p.goal {
        case .fatLoss:
            target = tdee * 0.8
            if p.bmi < 20 {
                target = tdee
                warnings.append("Your BMI is already lean (\(String(format: "%.1f", p.bmi))). Calories are set to maintenance instead of a deficit.")
            }
        case .strengthEndurance:
            target = tdee * 1.1
        default:
            target = tdee
        }
        let floor: Double = p.sex == .male ? 1500 : 1200
        if target < floor {
            target = floor
            warnings.append("Target raised to a safe minimum of \(Int(floor)) kcal.")
        }
        if p.bmi < 18.5 {
            warnings.append("BMI is in the underweight range. Consider eating above maintenance and speak with a doctor or dietitian.")
        }

        // Protein is set per kg, but for higher BMIs it's based on a reference weight at BMI 25.
        let referenceWeight = p.bmi > 30 ? 25 * pow(p.heightCm / 100, 2) : p.weightKg
        let protein = referenceWeight * proteinPerKg(p)
        let fat = max(target * 0.27 / 9, 0.6 * p.weightKg)
        let carbs = max((target - protein * 4 - fat * 9) / 4, 50)

        // Hydration: ~35 ml/kg/day plus extra for a training session.
        let water = p.weightKg * 35
        let extraWater = Double(p.sessionMinutes) / 60 * 600

        let meals = mealSlots(totalKcal: target, proteinG: protein, goal: p.goal)

        return NutritionPlan(
            bmr: Int(b.rounded()),
            tdee: Int(tdee.rounded()),
            targetCalories: Int((target / 10).rounded() * 10),
            proteinG: Int(protein.rounded()),
            fatG: Int(fat.rounded()),
            carbsG: Int(carbs.rounded()),
            waterMl: Int((water / 50).rounded() * 50),
            trainingDayExtraWaterMl: Int((extraWater / 50).rounded() * 50),
            meals: meals,
            tips: tips(for: p),
            warnings: warnings
        )
    }

    static func mealSlots(totalKcal: Double, proteinG: Double, goal: TrainingGoal) -> [MealSlot] {
        let split: [(String, String, Double, [String])] = [
            ("Breakfast", "06:30–08:00", 0.25,
             ["Oats with milk, berries and a scoop of whey", "3 eggs + wholegrain toast + fruit", "Greek yogurt, granola and banana"]),
            ("Lunch", "12:00–13:30", 0.30,
             ["Chicken, rice and mixed vegetables", "Tuna wholegrain wrap with salad", "Lean beef chilli with beans and rice"]),
            ("Pre-training snack", "60–90 min before PT", 0.10,
             ["Banana + small handful of nuts", "Rice cakes with honey", "Toast with peanut butter"]),
            ("Post-training", "Within ~2 h after PT", 0.10,
             ["Protein shake + fruit", "Chocolate milk", "Cottage cheese with pineapple"]),
            ("Dinner", "18:00–19:30", 0.25,
             ["Salmon, potatoes and greens", "Turkey stir-fry with noodles", "Lentil and chickpea curry with rice"])
        ]
        return split.map { name, time, fraction, examples in
            MealSlot(name: name, time: time,
                     kcal: Int((totalKcal * fraction / 10).rounded() * 10),
                     proteinG: Int((proteinG * fraction).rounded()),
                     examples: examples)
        }
    }

    static func tips(for p: UserProfile) -> [String] {
        var tips = [
            "Spread protein over 4–5 feedings of roughly 0.3–0.4 g/kg each to support muscle repair.",
            "Build every plate around a protein, a vegetable, a quality carb and a little fat.",
            "Carbs fuel high-rep PT and circuits. Eat more on training days and slightly less on rest days.",
            "Check your hydration from urine colour: aim for pale straw. Add electrolytes when sweating heavily or training in heat.",
            "Limit alcohol. It impairs recovery, sleep and test-day performance.",
            "Sleep 7–9 hours. Recovery happens when you sleep, not when you train."
        ]
        switch p.goal {
        case .fatLoss:
            tips.append("Aim to lose about 0.5–1% of body weight per week. Faster than that costs muscle and performance.")
            tips.append("Fill up on high-volume foods: vegetables, lean protein, potatoes, fruit.")
        case .strengthEndurance:
            tips.append("A modest surplus supports strength gains. Track weight weekly and adjust by ±150 kcal.")
        case .armyTest, .marineTest, .navyTest:
            tips.append("Test day: eat a familiar carb-based meal 2–3 h before, and don't try new foods or supplements.")
        case .generalReadiness:
            break
        }
        if p.age >= 50 {
            tips.append("Over 50: prioritise protein at every meal and ask your doctor about vitamin D and calcium.")
        }
        tips.append("Creatine monohydrate (3–5 g/day) is one of the best-researched supplements for strength. Check with a doctor first if you have kidney issues.")
        return tips
    }
}
