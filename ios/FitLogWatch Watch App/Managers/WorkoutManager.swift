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

    /// Key for persisting HealthKit authorization request status
    private static let healthKitAuthRequestedKey = "hasRequestedHealthKitAuthorization"

    /// Track if HealthKit authorization has been requested (persisted across app launches)
    /// Prevents repeated authorization prompts
    private var hasRequestedAuthorization: Bool {
        get { UserDefaults.standard.bool(forKey: Self.healthKitAuthRequestedKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.healthKitAuthRequestedKey)
            // ✅ Force immediate persistence (important for watchOS which may terminate app)
            UserDefaults.standard.synchronize()
        }
    }

    /// User's maximum heart rate for HR zone calculations
    /// Default: 190 (assumes ~30 year old, using 220-age formula)
    /// Can be set from iPhone or calculated from HealthKit date of birth
    var userMaxHR: Double = 190

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

        // ✅ FIX: Only recover if session is actually running or paused
        // If session is ended/stopped, don't treat it as active
        guard recoveredSession.state == .running || recoveredSession.state == .paused else {
            print("⌚ [RECOVERY] Recovered session is in state \(recoveredSession.state.rawValue), not recovering")
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

    /// Start a workout session
    /// - Parameters:
    ///   - type: The type of workout (strength, HIIT, functional)
    ///   - isCompanion: If true, this session is started as companion to iPhone workout
    ///                  (haptic feedback is skipped since ConnectivityManager already played it)
    func startWorkout(type: WorkoutType, isCompanion: Bool = false) async throws {
        // 🧹 CRITICAL FIX: Force cleanup any stale session before starting new one
        // This prevents "Unable to transition from Ended state" errors
        if session != nil {
            print("⌚ [WORKOUT] ⚠️ Detected stale session (state: \(workoutState.rawValue))")
            print("⌚ [WORKOUT] 🧹 Force cleaning up before starting new session...")

            // End the stale session first (important!)
            session?.end()

            // Then clear all state
            resetState()

            // Small delay to let HealthKit process the cleanup
            try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1s

            print("⌚ [WORKOUT] ✅ Stale session cleaned up")
        }

        // 1. Request authorization ONLY if not already determined
        // This prevents the "Consenti Salute" dialog from appearing every time
        try await requestHealthKitAuthorizationIfNeeded()

        // 1b. Calculate maxHR from HealthKit date of birth (if available)
        // This improves HR zone accuracy based on user's actual age
        await calculateMaxHRFromHealthKit()

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
        print("⌚ [WORKOUT] 🚀 Starting HKWorkoutSession...")
        session?.startActivity(with: startDate)
        print("⌚ [WORKOUT] 🚀 Beginning data collection...")
        try await builder?.beginCollection(at: startDate)

        self.workoutStartDate = startDate
        isWorkoutActive = true

        print("⌚ [WORKOUT] ✅ HKWorkoutSession started successfully!")
        print("⌚ [WORKOUT] Type: \(type.rawValue), StartDate: \(startDate)")

        // NOTE: No timers needed!
        // - Elapsed time: Views use Text(workoutStartDate, style: .timer) - native, battery efficient
        // - Health metrics: Sent only when HR changes by ±5 BPM (in HKLiveWorkoutBuilderDelegate)

        // Trigger haptic feedback (skip for companion mode - already played by ConnectivityManager)
        if !isCompanion {
            WKInterfaceDevice.current().play(.start)
        }
    }

    // MARK: - Computed Properties

    /// Check if there's a session instance (active, paused, or ended)
    /// Used to detect stale sessions that need cleanup before starting new workout
    var hasSessionInstance: Bool {
        session != nil
    }

    /// Elapsed time since workout started (for non-UI calculations)
    var elapsedTime: TimeInterval {
        guard let start = workoutStartDate else { return 0 }
        return Date().timeIntervalSince(start)
    }

    // MARK: - Max HR Calculation

    /// Calculate user's max HR from HealthKit date of birth
    /// Uses the standard formula: 220 - age
    /// Falls back to default (190) if date of birth is not available
    func calculateMaxHRFromHealthKit() async {
        do {
            let dateOfBirth = try await healthStore.dateOfBirthComponents()
            guard let birthYear = dateOfBirth.year else {
                print("⌚ [HEALTHKIT] Birth year not available, using default maxHR: \(userMaxHR)")
                return
            }

            let currentYear = Calendar.current.component(.year, from: Date())
            let age = currentYear - birthYear
            let calculatedMaxHR = max(100, Double(220 - age))  // Minimum 100 for safety

            userMaxHR = calculatedMaxHR
            print("⌚ [HEALTHKIT] Calculated maxHR from birth year: \(userMaxHR) (age: \(age))")
        } catch {
            // Date of birth not available or not authorized - use default
            print("⌚ [HEALTHKIT] Could not read date of birth: \(error.localizedDescription)")
            print("⌚ [HEALTHKIT] Using default maxHR: \(userMaxHR)")
        }
    }

    // MARK: - HealthKit Authorization

    /// Request HealthKit authorization ONLY if not already determined
    /// This prevents the "Consenti Salute" dialog from appearing every time
    private func requestHealthKitAuthorizationIfNeeded() async throws {
        // Log current state for debugging
        let workoutStatus = healthStore.authorizationStatus(for: HKObjectType.workoutType())
        print("⌚ [HEALTHKIT] Authorization check - UserDefaults: \(hasRequestedAuthorization), workoutStatus: \(workoutStatus.rawValue)")

        // Skip if already requested AND already authorized
        // This double-check prevents dialog from showing even if UserDefaults was reset
        if hasRequestedAuthorization && workoutStatus == .sharingAuthorized {
            print("⌚ [HEALTHKIT] ✅ Already fully authorized, skipping")
            return
        }

        // If already authorized to write workouts (even if UserDefaults was reset)
        // Skip dialog - permissions are already granted
        if workoutStatus == .sharingAuthorized {
            print("⌚ [HEALTHKIT] ✅ Workout write authorized (persisting to UserDefaults)")
            hasRequestedAuthorization = true
            return
        }

        // If UserDefaults says we requested before, but status is denied
        // Don't keep asking - user made their choice
        if hasRequestedAuthorization && workoutStatus == .sharingDenied {
            print("⌚ [HEALTHKIT] ⚠️ Authorization was denied, not asking again")
            return
        }

        // Only request if truly not determined yet
        // Note: In development builds, this may still show the dialog occasionally
        // because Xcode reinstalls can reset permissions
        print("⌚ [HEALTHKIT] 📋 Requesting authorization (status: \(workoutStatus.rawValue))...")

        let typesToShare: Set = [HKQuantityType.workoutType()]
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            HKCharacteristicType(.dateOfBirth)  // ✅ For maxHR calculation
        ]

        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        hasRequestedAuthorization = true
        print("⌚ [HEALTHKIT] ✅ Authorization request completed")
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

    /// End workout and SAVE to HealthKit
    func endWorkout() async throws {
        // ✅ FIX: Mark that we're ending workout internally
        // This prevents the delegate from notifying iPhone (we already know)
        isEndingWorkoutInternally = true
        defer { isEndingWorkoutInternally = false }

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
        // ✅ FIX: Mark that we're ending workout internally
        isEndingWorkoutInternally = true
        defer { isEndingWorkoutInternally = false }

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

    /// Force reset session state (callable from external code)
    /// Used to clean up stale sessions before starting a new workout
    /// This prevents "Unable to transition from Ended state" errors
    func forceResetSession() async {
        print("⌚ [WORKOUT] 🧹 Force resetting stale session (state: \(workoutState.rawValue))")

        // End any lingering session gracefully
        if let session = session {
            session.end()
            print("⌚ [WORKOUT] Ended stale session")
        }

        // Clear all state
        resetState()

        // Small delay to let HealthKit process the end
        // This ensures the session is fully cleaned up before we create a new one
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1s

        print("⌚ [WORKOUT] ✅ Session reset complete")
    }

    /// Flag to track if we initiated the workout end
    /// Used to distinguish between our code ending workout vs external end (Health app, etc.)
    private var isEndingWorkoutInternally = false

    private func calculateHeartRateZone(bpm: Double) -> HeartRateZone {
        // ✅ FIX: Use configurable userMaxHR instead of hardcoded value
        // userMaxHR can be set from iPhone or HealthKit date of birth
        let percentage = bpm / userMaxHR

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

                // ✅ FIX: If workout ended externally (not by our code), notify iPhone
                // This handles cases like user ending workout via Health app
                if !isEndingWorkoutInternally {
                    print("⌚ [WORKOUT] Session ended EXTERNALLY (Health app or system)")

                    // Request fresh state from iPhone to stay in sync
                    // iPhone is source of truth - if it thinks workout is still active,
                    // it will send update and we'll restart HKWorkoutSession
                    ConnectivityManager.shared.syncWorkoutStateFromiPhone(skipCache: true)
                }
            default:
                break
            }
        }
    }

    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {
        let nsError = error as NSError
        print("⌚ [WORKOUT] ❌ Session failed with error: \(error.localizedDescription)")
        print("⌚ [WORKOUT] Error domain: \(nsError.domain), code: \(nsError.code)")

        Task { @MainActor in
            // Notify user with haptic feedback
            WKInterfaceDevice.current().play(.failure)

            // Notify iPhone about the failure
            ConnectivityManager.shared.sendWorkoutError(
                message: "Workout session failed: \(error.localizedDescription)"
            )

            // If session is in a bad state, attempt to clean up
            if workoutSession.state == .notStarted || workoutSession.state == .ended {
                print("⌚ [WORKOUT] Resetting state after error")
                self.resetState()
            }
        }
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
