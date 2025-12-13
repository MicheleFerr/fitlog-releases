//
//  WorkoutManager.swift
//  FitLogWatch Watch App
//
//  Created by Claude on 08/12/25.
//

import Foundation
import HealthKit
import WatchKit
import Combine
import SwiftUI

/// Manages HKWorkoutSession for real-time workout tracking
@MainActor
class WorkoutManager: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var isWorkoutActive = false
    @Published var heartRate: Double = 0
    @Published var activeCalories: Double = 0
    @Published var currentHeartRateZone: HeartRateZone = .warmup
    @Published var workoutState: HKWorkoutSessionState = .notStarted

    /// Exposed for native SwiftUI Text(.timer) - battery efficient
    @Published private(set) var workoutStartDate: Date?

    // MARK: - Private Properties

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var lastSentHeartRate: Double = 0

    /// Threshold for sending HR updates to iPhone (±5 BPM)
    private let heartRateDeltaThreshold: Double = 5.0

    // MARK: - Heart Rate Zones

    enum HeartRateZone: String, CaseIterable {
        case warmup = "Warmup"      // < 50% max
        case fatBurn = "Fat Burn"   // 50-60%
        case cardio = "Cardio"      // 60-70%
        case peak = "Peak"          // 70-85%
        case extreme = "Extreme"    // > 85%

        var color: Color {
            switch self {
            case .warmup: return .gray
            case .fatBurn: return .blue
            case .cardio: return .green
            case .peak: return .orange
            case .extreme: return .red
            }
        }
    }

    // MARK: - Workout Types

    enum WorkoutType: String, CaseIterable {
        case strengthTraining = "Strength"
        case hiit = "HIIT"
        case functionalTraining = "Functional"

        var hkType: HKWorkoutActivityType {
            switch self {
            case .strengthTraining: return .traditionalStrengthTraining
            case .hiit: return .highIntensityIntervalTraining
            case .functionalTraining: return .functionalStrengthTraining
            }
        }

        var icon: String {
            switch self {
            case .strengthTraining: return "dumbbell.fill"
            case .hiit: return "flame.fill"
            case .functionalTraining: return "figure.mixed.cardio"
            }
        }
    }

    // MARK: - Public Methods

    /// Recover active workout session if app crashed during workout
    /// Call this on app launch to restore workout state
    func recoverWorkoutSessionIfNeeded() async throws {
        // Attempt to recover active session
        guard let recoveredSession = try await healthStore.recoverActiveWorkoutSession() else {
            // No active session to recover
            return
        }

        // Assign recovered session
        self.session = recoveredSession

        // Create builder from recovered session
        self.builder = recoveredSession.associatedWorkoutBuilder()

        // Set delegates to continue receiving updates
        recoveredSession.delegate = self
        self.builder?.delegate = self

        // Restore published state
        self.isWorkoutActive = true
        self.workoutStartDate = recoveredSession.startDate
        self.workoutState = recoveredSession.state

        // Re-establish data source for live metrics
        if let builder = self.builder {
            // Read current statistics to update UI
            let heartRateType = HKQuantityType(.heartRate)
            let caloriesType = HKQuantityType(.activeEnergyBurned)

            if let hrStats = builder.statistics(for: heartRateType) {
                let bpm = hrStats.mostRecentQuantity()?.doubleValue(
                    for: HKUnit.count().unitDivided(by: .minute())
                ) ?? 0
                self.heartRate = bpm
                self.currentHeartRateZone = calculateHeartRateZone(bpm: bpm)
                self.lastSentHeartRate = bpm
            }

            if let calStats = builder.statistics(for: caloriesType) {
                self.activeCalories = calStats.sumQuantity()?.doubleValue(
                    for: HKUnit.kilocalorie()
                ) ?? 0
            }
        }

        // Trigger haptic to indicate recovery
        WKInterfaceDevice.current().play(.notification)
    }

    func startWorkout(type: WorkoutType) async throws {
        // 1. Request authorization
        let typesToShare: Set = [HKQuantityType.workoutType()]
        let typesToRead: Set = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning)
        ]

        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)

        // 2. Create workout configuration
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = type.hkType
        configuration.locationType = .indoor

        // 3. Create and start session
        session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session?.associatedWorkoutBuilder()

        guard session != nil, builder != nil else {
            throw NSError(domain: "WorkoutManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create workout session"])
        }

        session?.delegate = self
        builder?.delegate = self

        // 4. Set data source for live workout
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )

        // 5. Start session and builder
        let startDate = Date()
        session?.startActivity(with: startDate)
        try await builder?.beginCollection(at: startDate)

        self.workoutStartDate = startDate
        isWorkoutActive = true

        // NOTE: No timers needed!
        // - Elapsed time: Views use Text(workoutStartDate, style: .timer) - native, battery efficient
        // - Health metrics: Sent only when HR changes by ±5 BPM (in HKLiveWorkoutBuilderDelegate)

        // Trigger haptic feedback
        WKInterfaceDevice.current().play(.start)
    }

    // MARK: - Computed Properties

    /// Elapsed time since workout started (for non-UI calculations)
    var elapsedTime: TimeInterval {
        guard let start = workoutStartDate else { return 0 }
        return Date().timeIntervalSince(start)
    }

    // MARK: - Private Methods

    /// Send health metrics to iPhone only when HR changes significantly (±5 BPM)
    /// Called from HKLiveWorkoutBuilderDelegate when new HR data arrives
    private func sendHealthMetricsIfNeeded() {
        let hrDelta = abs(heartRate - lastSentHeartRate)

        // Only send if HR changed by threshold or more
        guard hrDelta >= heartRateDeltaThreshold else { return }

        ConnectivityManager.shared.sendHealthMetrics(
            heartRate: heartRate,
            calories: activeCalories,
            elapsedTime: elapsedTime
        )

        lastSentHeartRate = heartRate

        // Also update ConnectivityManager's local HR for WaitingView
        ConnectivityManager.shared.updateHeartRate(heartRate)
    }

    func pauseWorkout() {
        session?.pause()
        WKInterfaceDevice.current().play(.click)
    }

    func resumeWorkout() {
        session?.resume()
        WKInterfaceDevice.current().play(.start)
    }

    /// End workout and SAVE to HealthKit
    func endWorkout() async throws {
        session?.end()

        guard let builder = builder else {
            resetState()
            return
        }

        try await builder.endCollection(at: Date())

        // Finalize and save workout to HealthKit
        if let workout = try await builder.finishWorkout() {
            // Notify iPhone app via ConnectivityManager
            await ConnectivityManager.shared.sendWorkoutCompleted(workout)
        }

        resetState()

        // Trigger success haptic
        WKInterfaceDevice.current().play(.success)
    }

    /// Discard workout WITHOUT saving to HealthKit
    func discardWorkout() async throws {
        session?.end()

        guard let builder = builder else {
            resetState()
            return
        }

        try await builder.endCollection(at: Date())

        // ✅ Discard instead of finishWorkout - does NOT save to HealthKit
        builder.discardWorkout()

        resetState()

        // Trigger stop haptic (not success, since we discarded)
        WKInterfaceDevice.current().play(.stop)
    }

    /// Reset internal state after workout ends
    private func resetState() {
        self.session = nil
        self.builder = nil
        self.workoutStartDate = nil
        self.isWorkoutActive = false
    }

    private func calculateHeartRateZone(bpm: Double) -> HeartRateZone {
        // Assuming max HR = 220 - age (simplified)
        let maxHR: Double = 190 // Placeholder for 30-year-old
        let percentage = bpm / maxHR

        switch percentage {
        case ..<0.5: return .warmup
        case 0.5..<0.6: return .fatBurn
        case 0.6..<0.7: return .cardio
        case 0.7..<0.85: return .peak
        default: return .extreme
        }
    }
}

// MARK: - HKWorkoutSessionDelegate

extension WorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        Task { @MainActor in
            workoutState = toState

            switch toState {
            case .running:
                isWorkoutActive = true
            case .paused:
                isWorkoutActive = false
            case .ended:
                isWorkoutActive = false
            default:
                break
            }
        }
    }

    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {
        // Session failed - could log to analytics in production
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        Task { @MainActor in
            for type in collectedTypes {
                guard let quantityType = type as? HKQuantityType else { continue }

                let statistics = workoutBuilder.statistics(for: quantityType)

                switch quantityType {
                case HKQuantityType(.heartRate):
                    let bpm = statistics?.mostRecentQuantity()?.doubleValue(
                        for: HKUnit.count().unitDivided(by: .minute())
                    ) ?? 0
                    heartRate = bpm
                    currentHeartRateZone = calculateHeartRateZone(bpm: bpm)

                    // Send to iPhone only if HR changed significantly (±5 BPM)
                    sendHealthMetricsIfNeeded()

                case HKQuantityType(.activeEnergyBurned):
                    activeCalories = statistics?.sumQuantity()?.doubleValue(
                        for: HKUnit.kilocalorie()
                    ) ?? 0

                default:
                    break
                }
            }
        }
    }

    nonisolated func workoutBuilderDidCollectEvent(
        _ workoutBuilder: HKLiveWorkoutBuilder
    ) {
        // Handle workout events if needed
    }
}
