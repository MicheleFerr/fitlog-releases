import AppIntents
import ActivityKit
import Foundation

// MARK: - Shared UserDefaults Keys
private let workoutEventKey = "workout_session_event"
private let sharedSuiteName = "group.com.michele.gymbro.flutter"
private let currentRestDurationKey = "current_exercise_rest_duration"
private let rpeEnabledKey = "rpe_tracking_enabled"
private let defaultRestDuration = 90 // Default 90 seconds if not set

// MARK: - Event Types
enum WorkoutSessionEventType: String {
    case completeSet = "complete_set"
    case skipRest = "skip_rest"
    case addTime = "add_time"
    case selectRPE = "select_rpe"
    case confirmRPE = "confirm_rpe"
    case pauseResume = "pause_resume"
}

// MARK: - Complete Set Intent
/// Called when user taps "Fatto" button to complete current set
/// Updates Live Activity directly to REST mode for immediate feedback,
/// then signals main app via UserDefaults for state sync
@available(iOS 17.0, *)
struct WorkoutCompleteSetIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Complete Set" }
    static var description: IntentDescription { "Mark the current set as complete and start rest timer" }
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        print("🟢 [WorkoutCompleteSetIntent] perform() called!")

        let userDefaults = UserDefaults(suiteName: sharedSuiteName)

        // Check if RPE tracking is enabled
        let rpeEnabled = userDefaults?.bool(forKey: rpeEnabledKey) ?? false
        print("📊 [WorkoutCompleteSetIntent] RPE enabled: \(rpeEnabled)")

        // 1. Update Live Activity directly for immediate feedback
        if let activity = Activity<WorkoutSessionAttributes>.activities.first {
            let currentState = activity.content.state
            print("📊 [WorkoutCompleteSetIntent] Current mode: \(currentState.mode)")

            // Only transition if in exercise mode (not already in rest or RPE)
            if currentState.mode == .exercise {
                if rpeEnabled {
                    // If RPE is enabled, transition to RPE mode and let Flutter handle completion
                    print("🎯 [WorkoutCompleteSetIntent] RPE enabled - transitioning to RPE mode")

                    var updatedState = currentState
                    updatedState.mode = .rpe
                    updatedState.lastUpdated = Date()

                    await activity.update(
                        ActivityContent(
                            state: updatedState,
                            staleDate: nil
                        )
                    )
                } else {
                    // No RPE - transition directly to REST mode
                    print("✅ [WorkoutCompleteSetIntent] No RPE - transitioning to REST")

                    let restDuration = userDefaults?.integer(forKey: currentRestDurationKey) ?? defaultRestDuration
                    let actualRestDuration = restDuration > 0 ? restDuration : defaultRestDuration

                    let now = Date()
                    let endDate = now.addingTimeInterval(TimeInterval(actualRestDuration))

                    var updatedState = currentState
                    updatedState.mode = .rest
                    updatedState.restStartDate = now
                    updatedState.restEndDate = endDate
                    updatedState.restTotalSeconds = actualRestDuration
                    updatedState.lastUpdated = now

                    // Increment set number for "next set" display
                    if currentState.currentSet < currentState.totalSets {
                        updatedState.currentSet = currentState.currentSet + 1
                    }

                    await activity.update(
                        ActivityContent(
                            state: updatedState,
                            staleDate: endDate.addingTimeInterval(10)
                        )
                    )
                }
            }
        }

        // 2. Signal Flutter via UserDefaults + Darwin notification
        //    This allows Flutter to sync its state when app becomes active
        print("📤 [WorkoutCompleteSetIntent] Saving event to UserDefaults and posting Darwin notification...")
        saveEventToUserDefaults(
            eventType: .completeSet,
            additionalData: [
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )
        print("✅ [WorkoutCompleteSetIntent] Event saved and notification posted!")

        return .result()
    }
}

// MARK: - Skip Rest Intent
/// Called when user taps "Salta" button to skip rest timer
/// Updates Live Activity directly to EXERCISE mode for immediate feedback
@available(iOS 17.0, *)
struct WorkoutSkipRestIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Skip Rest" }
    static var description: IntentDescription { "Skip the rest timer and proceed to next set" }
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        print("🟢 [WorkoutSkipRestIntent] perform() called!")

        // 1. Update Live Activity directly to EXERCISE mode for immediate feedback
        if let activity = Activity<WorkoutSessionAttributes>.activities.first {
            let currentState = activity.content.state
            print("📊 [WorkoutSkipRestIntent] Current mode: \(currentState.mode)")

            // Only transition if in rest mode
            if currentState.mode == .rest {
                print("✅ [WorkoutSkipRestIntent] Mode is REST, transitioning to EXERCISE")

                var updatedState = currentState
                updatedState.mode = .exercise
                updatedState.restStartDate = nil
                updatedState.restEndDate = nil
                updatedState.restTotalSeconds = 0
                updatedState.isPaused = false  // Reset pause state
                updatedState.pausedRemainingSeconds = nil
                updatedState.lastUpdated = Date()

                await activity.update(
                    ActivityContent(
                        state: updatedState,
                        staleDate: nil
                    )
                )
                print("✅ [WorkoutSkipRestIntent] LA transitioned to EXERCISE")
            }
        }

        // 2. Signal Flutter via UserDefaults + Darwin notification
        print("📤 [WorkoutSkipRestIntent] Saving event to UserDefaults...")
        saveEventToUserDefaults(
            eventType: .skipRest,
            additionalData: [
                "audioSkipped": true,
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )

        return .result()
    }
}

// MARK: - Add Time Intent
/// Called when user taps "+30s" button to add time to rest timer
@available(iOS 17.0, *)
struct WorkoutAddTimeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Add Time" }
    static var description: IntentDescription { "Add 30 seconds to the rest timer" }
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        print("🟢 [WorkoutAddTimeIntent] perform() called at \(Date())")

        // 1. Update Live Activity directly for immediate UI feedback
        let activities = Activity<WorkoutSessionAttributes>.activities
        print("📊 [WorkoutAddTimeIntent] Found \(activities.count) active activities")

        if let activity = activities.first {
            let currentState = activity.content.state
            print("📊 [WorkoutAddTimeIntent] BEFORE UPDATE:")
            print("   - mode: \(currentState.mode)")
            print("   - isPaused: \(currentState.isPaused)")
            print("   - restStartDate: \(String(describing: currentState.restStartDate))")
            print("   - restEndDate: \(String(describing: currentState.restEndDate))")
            print("   - restTotalSeconds: \(currentState.restTotalSeconds)")

            // Only extend if in rest mode with valid dates
            if currentState.mode == .rest,
               let currentEndDate = currentState.restEndDate {
                let newEndDate = currentEndDate.addingTimeInterval(30)
                let newTotalSeconds = currentState.restTotalSeconds + 30

                print("⏰ [WorkoutAddTimeIntent] Extending: oldEnd=\(currentEndDate), newEnd=\(newEndDate)")
                print("   - isPaused: \(currentState.isPaused)")

                var updatedState = currentState
                updatedState.restEndDate = newEndDate
                updatedState.restTotalSeconds = newTotalSeconds
                updatedState.lastUpdated = Date()

                // IMPORTANT: If paused, also update pausedRemainingSeconds
                // because that's what the UI displays when paused
                if currentState.isPaused {
                    let currentPausedRemaining = currentState.pausedRemainingSeconds ?? currentState.restRemainingSeconds
                    updatedState.pausedRemainingSeconds = currentPausedRemaining + 30
                    print("⏸️ [WorkoutAddTimeIntent] Timer is paused, updating pausedRemainingSeconds: \(currentPausedRemaining) -> \(currentPausedRemaining + 30)")
                }

                print("📊 [WorkoutAddTimeIntent] UPDATING to:")
                print("   - restEndDate: \(String(describing: updatedState.restEndDate))")
                print("   - restTotalSeconds: \(updatedState.restTotalSeconds)")
                print("   - pausedRemainingSeconds: \(String(describing: updatedState.pausedRemainingSeconds))")

                await activity.update(
                    ActivityContent(
                        state: updatedState,
                        staleDate: currentState.isPaused ? nil : newEndDate.addingTimeInterval(10)
                    )
                )

                // VERIFICATION: Read back the state after update
                let verifyState = activity.content.state
                print("✅ [WorkoutAddTimeIntent] AFTER UPDATE (verification):")
                print("   - restEndDate: \(String(describing: verifyState.restEndDate))")
                print("   - restTotalSeconds: \(verifyState.restTotalSeconds)")
                print("   - pausedRemainingSeconds: \(String(describing: verifyState.pausedRemainingSeconds))")
                print("   - restEndDate match? \(verifyState.restEndDate == newEndDate ? "YES ✓" : "NO ✗")")

            } else {
                print("⚠️ [WorkoutAddTimeIntent] Skipping LA update - mode=\(currentState.mode), hasEndDate=\(currentState.restEndDate != nil)")
            }
        } else {
            print("⚠️ [WorkoutAddTimeIntent] No active Live Activity found!")
        }

        // 2. Signal Flutter via UserDefaults + Darwin notification
        //    This allows Flutter to sync its timer when app becomes active
        print("📤 [WorkoutAddTimeIntent] Saving event to UserDefaults...")
        saveEventToUserDefaults(
            eventType: .addTime,
            additionalData: [
                "addedSeconds": 30,
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )
        print("✅ [WorkoutAddTimeIntent] Complete!")

        return .result()
    }
}

// MARK: - Select RPE Intent
/// Called when user selects an RPE value
@available(iOS 17.0, *)
struct WorkoutSelectRPEIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Select RPE" }
    static var description: IntentDescription { "Select the perceived exertion for this set" }
    static var openAppWhenRun: Bool = false

    @Parameter(title: "RPE Value")
    var rpeValue: Int

    init() {
        self.rpeValue = 7
    }

    init(rpeValue: Int) {
        self.rpeValue = rpeValue
    }

    func perform() async throws -> some IntentResult {
        // Signal Flutter via UserDefaults
        saveEventToUserDefaults(
            eventType: .selectRPE,
            additionalData: [
                "selectedRPE": rpeValue,
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )

        return .result()
    }
}

// MARK: - Confirm RPE Intent
/// Called when user confirms RPE and proceeds to rest timer
@available(iOS 17.0, *)
struct WorkoutConfirmRPEIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Confirm RPE" }
    static var description: IntentDescription { "Confirm RPE selection and start rest timer" }
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        print("🟢 [WorkoutConfirmRPEIntent] perform() called!")

        let userDefaults = UserDefaults(suiteName: sharedSuiteName)

        // Read the selected RPE from UserDefaults if available
        let lastRPE = userDefaults?.integer(forKey: "last_selected_rpe") ?? 7
        print("📊 [WorkoutConfirmRPEIntent] Confirmed RPE: \(lastRPE)")

        // 1. Transition Live Activity to REST mode for immediate feedback
        if let activity = Activity<WorkoutSessionAttributes>.activities.first {
            let currentState = activity.content.state

            if currentState.mode == .rpe {
                print("✅ [WorkoutConfirmRPEIntent] Mode is RPE, transitioning to REST")

                let restDuration = userDefaults?.integer(forKey: currentRestDurationKey) ?? defaultRestDuration
                let actualRestDuration = restDuration > 0 ? restDuration : defaultRestDuration

                let now = Date()
                let endDate = now.addingTimeInterval(TimeInterval(actualRestDuration))

                var updatedState = currentState
                updatedState.mode = .rest
                updatedState.restStartDate = now
                updatedState.restEndDate = endDate
                updatedState.restTotalSeconds = actualRestDuration
                updatedState.selectedRPE = lastRPE
                updatedState.lastUpdated = now

                // Increment set number for "next set" display
                if currentState.currentSet < currentState.totalSets {
                    updatedState.currentSet = currentState.currentSet + 1
                }

                await activity.update(
                    ActivityContent(
                        state: updatedState,
                        staleDate: endDate.addingTimeInterval(10)
                    )
                )
                print("✅ [WorkoutConfirmRPEIntent] LA transitioned to REST (\(actualRestDuration)s)")
            }
        }

        // 2. Signal Flutter via UserDefaults + Darwin notification
        print("📤 [WorkoutConfirmRPEIntent] Saving event to UserDefaults...")
        saveEventToUserDefaults(
            eventType: .confirmRPE,
            additionalData: [
                "confirmedRPE": lastRPE,
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )

        return .result()
    }
}

// MARK: - Pause/Resume Rest Intent
@available(iOS 17.0, *)
struct WorkoutPauseResumeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Pause/Resume" }
    static var description: IntentDescription { "Pause or resume the rest timer" }
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        // Signal Flutter via UserDefaults
        saveEventToUserDefaults(
            eventType: .pauseResume,
            additionalData: [
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )

        return .result()
    }
}

// MARK: - Helper Function
@available(iOS 17.0, *)
private func saveEventToUserDefaults(
    eventType: WorkoutSessionEventType,
    additionalData: [String: Any]
) {
    print("📝 [saveEventToUserDefaults] Saving event: \(eventType.rawValue)")

    guard let userDefaults = UserDefaults(suiteName: sharedSuiteName) else {
        print("❌ [saveEventToUserDefaults] Failed to access shared UserDefaults!")
        return
    }

    var eventData: [String: Any] = [
        "eventType": eventType.rawValue,
        "timestamp": Date().timeIntervalSince1970 * 1000
    ]

    // Merge additional data
    for (key, value) in additionalData {
        eventData[key] = value
    }

    print("📝 [saveEventToUserDefaults] Event data: \(eventData)")

    // Save to UserDefaults
    userDefaults.set(eventData, forKey: workoutEventKey)
    userDefaults.synchronize()
    print("✅ [saveEventToUserDefaults] Saved to UserDefaults with key: \(workoutEventKey)")

    // Also save last RPE if this is a select RPE event
    if eventType == .selectRPE, let rpe = additionalData["selectedRPE"] as? Int {
        userDefaults.set(rpe, forKey: "last_selected_rpe")
        userDefaults.synchronize()
    }

    // Post a Darwin notification for immediate Flutter response
    print("📡 [saveEventToUserDefaults] Posting Darwin notification: com.gymbro.workoutSession.event")
    let notificationName = CFNotificationName("com.gymbro.workoutSession.event" as CFString)
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        notificationName,
        nil,
        nil,
        true
    )
    print("✅ [saveEventToUserDefaults] Darwin notification posted!")
}
