import Foundation
import HealthKit

/// Bridge to Apple Health, which is also how Garmin data reaches the app:
/// Garmin Connect (iPhone app) → Apple Health → Iron Cadence.
/// Garmin syncs one way, so workouts written here won't appear in Garmin Connect.
@MainActor
final class HealthKitManager: ObservableObject {
    private let store = HKHealthStore()

    @Published private(set) var isAvailable = HKHealthStore.isHealthDataAvailable()
    @Published private(set) var hasRequestedAccess = UserDefaults.standard.bool(forKey: "hk.requested")
    @Published private(set) var restingHeartRate: Double?
    @Published private(set) var hrv: Double?
    @Published private(set) var stepsToday: Double?
    @Published private(set) var latestWeightKg: Double?
    @Published private(set) var sleepHoursLastNight: Double?
    @Published private(set) var garminSourceDetected = false
    @Published private(set) var recentGarminWorkouts: [ExternalWorkout] = []
    @Published var lastError: String?

    struct ExternalWorkout: Identifiable, Hashable {
        let id: UUID
        let name: String
        let source: String
        let start: Date
        let end: Date
        let kcal: Double?
    }

    private static let bpm = HKUnit.count().unitDivided(by: .minute())

    private func qType(_ id: HKQuantityTypeIdentifier) -> HKQuantityType? {
        HKQuantityType.quantityType(forIdentifier: id)
    }

    private var readTypes: Set<HKObjectType> {
        var set: Set<HKObjectType> = [HKObjectType.workoutType()]
        let ids: [HKQuantityTypeIdentifier] = [.heartRate, .restingHeartRate, .heartRateVariabilitySDNN,
                                               .stepCount, .bodyMass, .activeEnergyBurned, .vo2Max]
        for id in ids { if let t = qType(id) { set.insert(t) } }
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { set.insert(sleep) }
        return set
    }

    private var shareTypes: Set<HKSampleType> {
        var set: Set<HKSampleType> = [HKObjectType.workoutType()]
        for id in [HKQuantityTypeIdentifier.activeEnergyBurned, .bodyMass] {
            if let t = qType(id) { set.insert(t) }
        }
        return set
    }

    // MARK: Authorization

    func requestAuthorization() async {
        guard isAvailable else {
            lastError = "Apple Health isn't available on this device."
            return
        }
        do {
            try await store.requestAuthorization(toShare: shareTypes, read: readTypes)
            hasRequestedAccess = true
            UserDefaults.standard.set(true, forKey: "hk.requested")
            await refresh()
        } catch {
            lastError = error.localizedDescription
        }
    }

    // MARK: Dashboard metrics

    func refresh() async {
        guard isAvailable, hasRequestedAccess else { return }
        restingHeartRate = await mostRecent(.restingHeartRate, unit: Self.bpm)
        hrv = await mostRecent(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli))
        latestWeightKg = await mostRecent(.bodyMass, unit: .gramUnit(with: .kilo))
        let startOfDay = Calendar.current.startOfDay(for: Date())
        stepsToday = await sum(.stepCount, unit: .count(), start: startOfDay, end: Date())
        sleepHoursLastNight = await sleepHours()
        recentGarminWorkouts = await externalWorkouts(days: 14)
        garminSourceDetected = await hasGarminSource()
    }

    private func mostRecent(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let type = qType(id) else { return nil }
        let store = self.store
        return await withCheckedContinuation { cont in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                cont.resume(returning: value)
            }
            store.execute(query)
        }
    }

    private func sum(_ id: HKQuantityTypeIdentifier, unit: HKUnit, start: Date, end: Date) async -> Double? {
        guard let type = qType(id) else { return nil }
        let store = self.store
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        return await withCheckedContinuation { cont in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
                cont.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit))
            }
            store.execute(query)
        }
    }

    /// Average and max heart rate between two dates, from any source, including a Garmin watch synced via Garmin Connect.
    func heartRateStats(start: Date, end: Date) async -> (avg: Double, max: Double)? {
        guard isAvailable, let type = qType(.heartRate) else { return nil }
        let store = self.store
        let unit = Self.bpm
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        return await withCheckedContinuation { cont in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate,
                                          options: [.discreteAverage, .discreteMax]) { _, stats, _ in
                if let avg = stats?.averageQuantity()?.doubleValue(for: unit),
                   let max = stats?.maximumQuantity()?.doubleValue(for: unit) {
                    cont.resume(returning: (avg, max))
                } else {
                    cont.resume(returning: nil)
                }
            }
            store.execute(query)
        }
    }

    /// Sleep in the 24 h window ending at noon today. Uses the single source with the most sleep
    /// (e.g. Garmin vs iPhone) to avoid double counting.
    private func sleepHours() async -> Double? {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        let cal = Calendar.current
        let noon = cal.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
        let start = noon.addingTimeInterval(-24 * 3600)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: noon, options: [])
        let asleepValues = Set(HKCategoryValueSleepAnalysis.allAsleepValues.map(\.rawValue))
        let store = self.store
        return await withCheckedContinuation { cont in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                var bySource: [String: Double] = [:]
                for case let s as HKCategorySample in samples ?? [] where asleepValues.contains(s.value) {
                    bySource[s.sourceRevision.source.bundleIdentifier, default: 0] += s.endDate.timeIntervalSince(s.startDate)
                }
                let best = bySource.values.max()
                cont.resume(returning: best.map { $0 / 3600 })
            }
            store.execute(query)
        }
    }

    /// Workouts recorded by other apps (e.g. a Garmin "Strength" activity synced through Garmin Connect).
    func externalWorkouts(days: Int) async -> [ExternalWorkout] {
        let start = Date().addingTimeInterval(-Double(days) * 86400)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: [])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let store = self.store
        let ownBundle = Bundle.main.bundleIdentifier ?? ""
        return await withCheckedContinuation { cont in
            let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: 30, sortDescriptors: [sort]) { _, samples, _ in
                let workouts = (samples as? [HKWorkout] ?? [])
                    .filter { $0.sourceRevision.source.bundleIdentifier != ownBundle }
                    .map { w -> ExternalWorkout in
                        let kcal = w.statistics(for: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!)?
                            .sumQuantity()?.doubleValue(for: .kilocalorie())
                        return ExternalWorkout(id: w.uuid, name: Self.name(for: w.workoutActivityType),
                                               source: w.sourceRevision.source.name,
                                               start: w.startDate, end: w.endDate, kcal: kcal)
                    }
                cont.resume(returning: workouts)
            }
            store.execute(query)
        }
    }

    private func hasGarminSource() async -> Bool {
        guard let type = qType(.heartRate) else { return false }
        let store = self.store
        return await withCheckedContinuation { cont in
            let query = HKSourceQuery(sampleType: type, samplePredicate: nil) { _, sources, _ in
                let found = (sources ?? []).contains {
                    $0.bundleIdentifier.lowercased().contains("garmin") || $0.name.lowercased().contains("garmin")
                }
                cont.resume(returning: found)
            }
            store.execute(query)
        }
    }

    nonisolated private static func name(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .traditionalStrengthTraining, .functionalStrengthTraining: return "Strength"
        case .running: return "Run"
        case .walking: return "Walk"
        case .hiking: return "Hike / Ruck"
        case .cycling: return "Ride"
        case .swimming: return "Swim"
        case .highIntensityIntervalTraining: return "HIIT"
        case .crossTraining: return "Cross training"
        default: return "Workout"
        }
    }

    // MARK: Writing

    /// Saves a completed session to Apple Health as Functional Strength Training.
    func saveWorkout(start: Date, end: Date, kcal: Double) async throws {
        guard isAvailable else { return }
        let config = HKWorkoutConfiguration()
        config.activityType = .functionalStrengthTraining
        config.locationType = .indoor
        let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: HKDevice.local())

        try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, Error>) in
            builder.beginCollection(withStart: start) { _, error in
                if let error { c.resume(throwing: error) } else { c.resume() }
            }
        }
        if kcal > 0, let energy = qType(.activeEnergyBurned) {
            let sample = HKQuantitySample(type: energy, quantity: HKQuantity(unit: .kilocalorie(), doubleValue: kcal),
                                          start: start, end: end)
            try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, Error>) in
                builder.add([sample]) { _, error in
                    if let error { c.resume(throwing: error) } else { c.resume() }
                }
            }
        }
        try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, Error>) in
            builder.endCollection(withEnd: end) { _, error in
                if let error { c.resume(throwing: error) } else { c.resume() }
            }
        }
        try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, Error>) in
            builder.finishWorkout { _, error in
                if let error { c.resume(throwing: error) } else { c.resume() }
            }
        }
    }

    func saveBodyMass(kg: Double) async {
        guard isAvailable, hasRequestedAccess, let type = qType(.bodyMass) else { return }
        let sample = HKQuantitySample(type: type, quantity: HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: kg),
                                      start: Date(), end: Date())
        do { try await store.save(sample) } catch { lastError = error.localizedDescription }
    }
}
