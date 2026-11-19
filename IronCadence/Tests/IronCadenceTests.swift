import XCTest
@testable import IronCadence

final class ProgramGeneratorTests: XCTestCase {

    private func profile(age: Int = 28, sex: Sex = .male, weight: Double = 78, height: Double = 180,
                         push: Int = 25, pull: Int = 5, plank: Int = 90, squats: Int = 40,
                         goal: TrainingGoal = .generalReadiness, days: Int = 4, minutes: Int = 45) -> UserProfile {
        var p = UserProfile()
        p.age = age; p.sex = sex; p.weightKg = weight; p.heightCm = height
        p.goal = goal; p.daysPerWeek = days; p.sessionMinutes = minutes
        p.baseline = Baseline(pushUps: push, pullUps: pull, plankSeconds: plank, squats: squats)
        return p
    }

    func testProgramHasEightWeeksOfRequestedDays() {
        for days in 3...6 {
            let program = ProgramGenerator.generate(for: profile(days: days))
            XCTAssertEqual(program.days.count, 8 * days)
            XCTAssertEqual(program.days(inWeek: 1).count, days)
        }
    }

    func testDeloadWeeks() {
        let program = ProgramGenerator.generate(for: profile())
        XCTAssertTrue(program.days(inWeek: 4).allSatisfy(\.isDeload))
        XCTAssertTrue(program.days(inWeek: 8).allSatisfy(\.isDeload))
        XCTAssertFalse(program.days(inWeek: 1).contains(where: \.isDeload))
    }

    func testLevelAssessment() {
        XCTAssertEqual(ProgramGenerator.assessLevel(profile(push: 3, pull: 0, plank: 20, squats: 15)), .recruit)
        XCTAssertEqual(ProgramGenerator.assessLevel(profile(push: 35, pull: 8, plank: 110, squats: 45)), .soldier)
        XCTAssertEqual(ProgramGenerator.assessLevel(profile(push: 70, pull: 20, plank: 240, squats: 80)), .elite)
    }

    func testOlderTraineeGetsLessVolumeAndMoreRest() {
        XCTAssertLessThan(ProgramGenerator.ageFactor(55), ProgramGenerator.ageFactor(25))
        XCTAssertGreaterThan(ProgramGenerator.restMultiplier(55), ProgramGenerator.restMultiplier(25))
    }

    func testHighBMIUsesLowImpactExercises() {
        let p = profile(weight: 120, height: 175)  // BMI ≈ 39
        XCTAssertTrue(ProgramGenerator.prefersLowImpact(p))
        let program = ProgramGenerator.generate(for: p)
        let ids = program.days.flatMap { $0.blocks.flatMap { $0.items.map(\.exerciseID) } }
        XCTAssertFalse(ids.contains("burpee"))
        XCTAssertFalse(ids.contains("jump-squat"))
        XCTAssertFalse(ids.contains("jumping-jack"))
    }

    func testNoPullUpsUsesRowsAndNegatives() {
        let program = ProgramGenerator.generate(for: profile(pull: 0))
        let pullDay = program.days.first { $0.title.hasPrefix("Pull") }!
        let ids = pullDay.blocks.flatMap { $0.items.map(\.exerciseID) }
        XCTAssertTrue(ids.contains("inverted-row"))
        XCTAssertTrue(ids.contains("negative-pull-up"))
    }

    func testArmyGoalUsesHandReleasePushUps() {
        let program = ProgramGenerator.generate(for: profile(goal: .armyTest))
        let ids = program.days.flatMap { $0.blocks.flatMap { $0.items.map(\.exerciseID) } }
        XCTAssertTrue(ids.contains("hand-release-push-up"))
    }

    func testRepsProgressAcrossBuildWeeks() {
        let program = ProgramGenerator.generate(for: profile(push: 30))
        func pushReps(_ week: Int) -> Int {
            program.days(inWeek: week).first!.blocks[1].items[0].reps!
        }
        XCTAssertLessThanOrEqual(pushReps(1), pushReps(3))
        XCTAssertLessThan(pushReps(4), pushReps(3))   // deload
    }

    func testSessionsRespectTimeBudget() {
        let program = ProgramGenerator.generate(for: profile(push: 60, pull: 15, days: 6, minutes: 30))
        for day in program.days {
            // Allow slack: fitting can't drop below 2 sets per item.
            XCTAssertLessThan(day.estimatedMinutes, 45, "\(day.title) is \(day.estimatedMinutes) min")
        }
    }

    func testAllExerciseIDsExistInLibrary() {
        for goal in TrainingGoal.allCases {
            for push in [2, 30] {
                for pull in [0, 2, 10] {
                    let program = ProgramGenerator.generate(for: profile(age: 60, push: push, pull: pull, goal: goal, days: 6))
                    for id in program.days.flatMap({ $0.blocks.flatMap { $0.items.map(\.exerciseID) } }) {
                        XCTAssertNotNil(ExerciseLibrary.byID[id], "Missing exercise \(id)")
                    }
                }
            }
        }
    }

    func testLibraryRegressionsAndProgressionsResolve() {
        for ex in ExerciseLibrary.all {
            if let e = ex.easier { XCTAssertNotNil(ExerciseLibrary.byID[e], "\(ex.id) easier → \(e)") }
            if let h = ex.harder { XCTAssertNotNil(ExerciseLibrary.byID[h], "\(ex.id) harder → \(h)") }
            XCTAssertFalse(ex.steps.isEmpty)
        }
    }

    func testSequencerHasNoTrailingRest() {
        let day = ProgramGenerator.generate(for: profile()).days[2]   // circuit day
        let steps = WorkoutSequencer.steps(for: day)
        XCTAssertFalse(steps.isEmpty)
        XCTAssertFalse(steps.last!.isRest)
    }
}

final class NutritionCalculatorTests: XCTestCase {

    func testMifflinStJeor() {
        var p = UserProfile()
        p.sex = .male; p.age = 30; p.heightCm = 180; p.weightKg = 80
        // 10*80 + 6.25*180 - 5*30 + 5 = 1780
        XCTAssertEqual(NutritionCalculator.bmr(p), 1780, accuracy: 0.1)
        p.sex = .female
        XCTAssertEqual(NutritionCalculator.bmr(p), 1614, accuracy: 0.1)
    }

    func testFatLossIsDeficitAndHighProtein() {
        var p = UserProfile()
        p.weightKg = 90; p.heightCm = 178; p.goal = .fatLoss
        let plan = NutritionCalculator.plan(for: p)
        XCTAssertLessThan(plan.targetCalories, plan.tdee)
        XCTAssertGreaterThanOrEqual(plan.proteinG, Int(2.0 * 90))
    }

    func testCalorieFloor() {
        var p = UserProfile()
        p.sex = .female; p.weightKg = 45; p.heightCm = 150; p.age = 60
        p.activityLevel = .sedentary; p.goal = .fatLoss; p.daysPerWeek = 3; p.sessionMinutes = 20
        XCTAssertGreaterThanOrEqual(NutritionCalculator.plan(for: p).targetCalories, 1200)
    }

    func testMacrosRoughlyMatchCalories() {
        let plan = NutritionCalculator.plan(for: UserProfile())
        let macroKcal = plan.proteinKcal + plan.carbsKcal + plan.fatKcal
        XCTAssertEqual(Double(macroKcal), Double(plan.targetCalories), accuracy: Double(plan.targetCalories) * 0.05)
    }

    func testHydrationScalesWithWeight() {
        var light = UserProfile(); light.weightKg = 60
        var heavy = UserProfile(); heavy.weightKg = 100
        XCTAssertGreaterThan(NutritionCalculator.plan(for: heavy).waterMl, NutritionCalculator.plan(for: light).waterMl)
    }
}
