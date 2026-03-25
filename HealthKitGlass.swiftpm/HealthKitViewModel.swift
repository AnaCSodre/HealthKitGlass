import SwiftUI
import HealthKit
import Observation

// MARK: - ViewModel

@Observable
@MainActor
final class HealthKitViewModel {
    var summary = HealthSummary()
    var isAuthorized = false
    var isLoading = false
    var errorMessage: String?
    var selectedMetric: HealthMetricType = .steps

    private let healthStore = HKHealthStore()

    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

    func requestAuthorization() async {
        guard isHealthKitAvailable else {
            errorMessage = "HealthKit não disponível neste dispositivo."
            return
        }

        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned)
        ]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            isAuthorized = true
            await fetchAllData()
        } catch {
            errorMessage = "Erro na autorização: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch All Data

    func fetchAllData() async {
        isLoading = true
        defer { isLoading = false }

        async let steps = fetchTodaySteps()
        async let calories = fetchTodayCalories()
        async let heartRate = fetchLatestHeartRate()
        async let weeklySteps = fetchWeeklySteps()
        async let recentHR = fetchRecentHeartRates()

        summary.todaySteps = await steps
        summary.todayCalories = await calories
        summary.currentHeartRate = await heartRate
        summary.weeklySteps = await weeklySteps
        summary.recentHeartRates = await recentHR
    }

    // MARK: - Steps

    private func fetchTodaySteps() async -> Int {
        let type = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: .now),
            end: .now
        )

        do {
            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(
                    quantityType: type,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, statistics, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        let sum = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                        continuation.resume(returning: sum)
                    }
                }
                healthStore.execute(query)
            }
            return Int(result)
        } catch {
            return 0
        }
    }

    // MARK: - Calories

    private func fetchTodayCalories() async -> Double {
        let type = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: .now),
            end: .now
        )

        do {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(
                    quantityType: type,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, statistics, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        let sum = statistics?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                        continuation.resume(returning: sum)
                    }
                }
                healthStore.execute(query)
            }
        } catch {
            return 0
        }
    }

    // MARK: - Heart Rate

    private func fetchLatestHeartRate() async -> Double {
        let type = HKQuantityType(.heartRate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        do {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
                let query = HKSampleQuery(
                    sampleType: type,
                    predicate: nil,
                    limit: 1,
                    sortDescriptors: [sortDescriptor]
                ) { _, samples, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        let bpm = (samples?.first as? HKQuantitySample)?
                            .quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
                        continuation.resume(returning: bpm)
                    }
                }
                healthStore.execute(query)
            }
        } catch {
            return 0
        }
    }

    // MARK: - Weekly Steps

    private func fetchWeeklySteps() async -> [StepData] {
        let type = HKQuantityType(.stepCount)
        let calendar = Calendar.current
        let endDate = Date.now
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: endDate)) else {
            return []
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        var interval = DateComponents()
        interval.day = 1

        do {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[StepData], Error>) in
                let query = HKStatisticsCollectionQuery(
                    quantityType: type,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum,
                    anchorDate: startDate,
                    intervalComponents: interval
                )

                query.initialResultsHandler = { _, collection, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    var results: [StepData] = []
                    collection?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                        let count = Int(statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                        results.append(StepData(date: statistics.startDate, count: count))
                    }
                    continuation.resume(returning: results)
                }

                healthStore.execute(query)
            }
        } catch {
            return []
        }
    }

    // MARK: - Recent Heart Rates

    private func fetchRecentHeartRates() async -> [HeartRateData] {
        let type = HKQuantityType(.heartRate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        do {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HeartRateData], Error>) in
                let query = HKSampleQuery(
                    sampleType: type,
                    predicate: nil,
                    limit: 20,
                    sortDescriptors: [sortDescriptor]
                ) { _, samples, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    let data = (samples as? [HKQuantitySample])?.map { sample in
                        HeartRateData(
                            date: sample.startDate,
                            bpm: sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                        )
                    } ?? []
                    continuation.resume(returning: data)
                }
                healthStore.execute(query)
            }
        } catch {
            return []
        }
    }

    // MARK: - Sample Data (Preview/Simulator)

    func loadSampleData() {
        let calendar = Calendar.current
        summary.todaySteps = 7_432
        summary.todayCalories = 342.5
        summary.currentHeartRate = 72

        summary.weeklySteps = (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -6 + dayOffset, to: .now)!
            return StepData(date: date, count: Int.random(in: 3000...12000))
        }

        summary.recentHeartRates = (0..<20).map { i in
            let date = calendar.date(byAdding: .minute, value: -i * 30, to: .now)!
            return HeartRateData(date: date, bpm: Double.random(in: 58...95))
        }
    }
}
