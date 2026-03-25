import AppIntents
import ActivityKit
import Foundation

// MARK: - Shared UserDefaults Keys
private let workoutEventKey = "workout_session_event"
private let sharedSuiteName = RestTimerNotificationSupport.sharedSuiteName
private let currentRestDurationKey = "current_exercise_rest_duration"
private let rpeEnabledKey = "rpe_tracking_enabled"
private let defaultRestDuration = 90 // Default 90 seconds if not set

// Next exercise info keys (written by Flutter via setNextExerciseInfo)
private let nextExerciseNameKey = "next_exercise_name"
private let nextExerciseSetKey = "next_exercise_set"
private let nextExerciseTotalSetsKey = "next_exercise_total_sets"
private let nextExerciseWeightKey = "next_exercise_weight"
private let nextExerciseTargetRepsKey = "next_exercise_target_reps"
private let nextExerciseRestDurationKey = "next_exercise_rest_duration"
private let isLastSetOfExerciseKey = "is_last_set_of_exercise"

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
public struct WorkoutCompleteSetIntent: LiveActivityIntent {
    public init() {}
    public static var title: LocalizedStringResource { "Complete Set" }
    public static var description: IntentDescription { "Mark the current set as complete and start rest timer" }
    public static var openAppWhenRun: Bool = false

    public func perform() async throws -> some IntentResult {
        print("🟢 [WorkoutCompleteSetIntent] perform() called!")

        let userDefaults = UserDefaults(suiteName: sharedSuiteName)

        // Check if RPE tracking is enabled
        let rpeEnabled = userDefaults?.bool(forKey: rpeEnabledKey) ?? false
        print("📊 [WorkoutCompleteSetIntent] RPE enabled: \(rpeEnabled)")

        // 1. Update Live Activity directly for immediate feedback
        if let activity = Activity<WorkoutSessionAttributes>.activities.first {
            let currentState = activity.content.state
            print("📊 [WorkoutCompleteSetIntent] Current mode: \(currentState.mode)")

            // FIX: Allow completion when in exercise mode OR when rest timer has expired
            // This fixes the bug where tapping "Fatto" after timer expires does nothing
            // because iOS mode is still .rest (Flutter's transitionToExercise was throttled)
            let isRestComplete: Bool = {
                if currentState.mode == .rest, let endDate = currentState.restEndDate {
                    return Date() >= endDate && !currentState.isPaused
                }
                return false
            }()
            let isExerciseReady = currentState.mode == .exercise || isRestComplete

            if isExerciseReady {
                if rpeEnabled {
                    // If RPE is enabled, transition to RPE mode and let Flutter handle completion
                    print("🎯 [WorkoutCompleteSetIntent] RPE enabled - transitioning to RPE mode")

                    var updatedState = currentState
                    updatedState.mode = .rpe
                    updatedState.restStartDate = nil
                    updatedState.restEndDate = nil
                    updatedState.restTotalSeconds = 0
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

                    let isLastSet = currentState.currentSet >= currentState.totalSets
                    var actualRestDuration: Int
                    var updatedState = currentState
                    updatedState.mode = .rest

                    if isLastSet {
                        // Last set of exercise: read next exercise info from UserDefaults
                        let nextName = userDefaults?.string(forKey: nextExerciseNameKey)
                        let nextSet = userDefaults?.integer(forKey: nextExerciseSetKey) ?? 1
                        let nextTotalSets = userDefaults?.integer(forKey: nextExerciseTotalSetsKey)
                        let nextWeight = userDefaults?.double(forKey: nextExerciseWeightKey)
                        let nextReps = userDefaults?.integer(forKey: nextExerciseTargetRepsKey)
                        let interRest = userDefaults?.integer(forKey: nextExerciseRestDurationKey)

                        if let nextName = nextName, !nextName.isEmpty {
                            print("📋 [WorkoutCompleteSetIntent] Last set → next exercise: \(nextName)")
                            updatedState.exerciseName = nextName
                            updatedState.currentSet = nextSet > 0 ? nextSet : 1
                            if let ts = nextTotalSets, ts > 0 { updatedState.totalSets = ts }
                            if let w = nextWeight { updatedState.weight = w }
                            if let r = nextReps, r > 0 { updatedState.targetReps = r }
                        }

                        // Use inter-exercise rest duration if available
                        let interRestDuration = (interRest ?? 0) > 0 ? interRest! : (userDefaults?.integer(forKey: currentRestDurationKey) ?? defaultRestDuration)
                        actualRestDuration = interRestDuration > 0 ? interRestDuration : defaultRestDuration
                    } else {
                        // Not last set: increment set number, use current rest duration
                        updatedState.currentSet = currentState.currentSet + 1
                        let restDuration = userDefaults?.integer(forKey: currentRestDurationKey) ?? defaultRestDuration
                        actualRestDuration = restDuration > 0 ? restDuration : defaultRestDuration
                    }

                    let now = Date()
                    let endDate = now.addingTimeInterval(TimeInterval(actualRestDuration))
                    updatedState.restStartDate = now
                    updatedState.restEndDate = endDate
                    updatedState.restTotalSeconds = actualRestDuration
                    updatedState.lastUpdated = now

                    // FIX: Use long staleDate (2 hours from now) to allow future updates
                    // iOS ignores updates on "stale" activities
                    await activity.update(
                        ActivityContent(
                            state: updatedState,
                            staleDate: Date().addingTimeInterval(7200)  // 2 hours from now
                        )
                    )

                    // 🔔 CRITICAL FIX: Schedule notification for timer completion
                    // This is the ONLY reliable way to get audio when app is in background
                    // iOS delivers this notification with sound even if app is killed
                    await scheduleRestTimerNotification(
                        duration: actualRestDuration,
                        exerciseName: updatedState.exerciseName
                    )
                    print("🔔 [WorkoutCompleteSetIntent] Timer notification scheduled from Intent!")
                }
            } else {
                // Mode is not ready - LA already in rest/RPE mode, don't send spurious event to Flutter
                print("⚠️ [WorkoutCompleteSetIntent] Not in exercise-ready mode (\(currentState.mode)) - skipping event")
                return .result()
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
public struct WorkoutSkipRestIntent: LiveActivityIntent {
    public init() {}
    public static var title: LocalizedStringResource { "Skip Rest" }
    public static var description: IntentDescription { "Skip the rest timer and proceed to next set" }
    public static var openAppWhenRun: Bool = false

    public func perform() async throws -> some IntentResult {
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

                // 🔔 CRITICAL FIX: Cancel pending notification since user is skipping rest
                // Prevents notification from firing after skip
                await cancelRestTimerNotification()
                print("🗑️ [WorkoutSkipRestIntent] Timer notification cancelled due to skip!")
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

// MARK: - Extend Rest Intent
/// Called when user taps "+15s" button to add time to rest timer
@available(iOS 17.0, *)
public struct WorkoutExtendRestIntent: LiveActivityIntent {
    public init() {}
    public static var title: LocalizedStringResource { "Extend Rest" }
    public static var description: IntentDescription { "Add 15 seconds to the rest timer" }
    public static var openAppWhenRun: Bool = false

    public func perform() async throws -> some IntentResult {
        print("🟢 [WorkoutExtendRestIntent] perform() called")

        // Reschedule notification with extended time (only if in rest mode, not paused)
        if let activity = Activity<WorkoutSessionAttributes>.activities.first {
            let currentState = activity.content.state
            if currentState.mode == .rest, !currentState.isPaused,
               let currentEndDate = currentState.restEndDate {
                let newEndDate = currentEndDate.addingTimeInterval(15)
                let remainingSeconds = Int(newEndDate.timeIntervalSinceNow)
                if remainingSeconds > 0 {
                    await scheduleRestTimerNotification(
                        duration: remainingSeconds,
                        exerciseName: currentState.exerciseName
                    )
                    print("🔔 [WorkoutExtendRestIntent] Notification rescheduled for \(remainingSeconds)s")
                }
            }
        }

        // Signal Flutter via UserDefaults + Darwin notification.
        // Flutter will update the LA via syncRestEndTime (proven MethodChannel path).
        saveEventToUserDefaults(
            eventType: .addTime,
            additionalData: [
                "addedSeconds": 15,
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )

        return .result()
    }
}

// MARK: - Select RPE Intent
/// Called when user selects an RPE value
@available(iOS 17.0, *)
public struct WorkoutSelectRPEIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource { "Select RPE" }
    public static var description: IntentDescription { "Select the perceived exertion for this set" }
    public static var openAppWhenRun: Bool = false

    @Parameter(title: "RPE Value")
    public var rpeValue: Int

    public init() {
        self.rpeValue = 7
    }

    public init(rpeValue: Int) {
        self.rpeValue = rpeValue
    }

    public func perform() async throws -> some IntentResult {
        // FIX C2: Update Live Activity immediately for instant UI feedback.
        // Without this, the RPE button stays un-highlighted until Flutter processes
        // the Darwin notification — which can take seconds or never happen when locked.
        if let activity = Activity<WorkoutSessionAttributes>.activities.first {
            let currentState = activity.content.state

            // Only update if we're in RPE mode and the selection actually changed
            if currentState.mode == .rpe && currentState.selectedRPE != rpeValue {
                var updatedState = currentState
                updatedState.selectedRPE = rpeValue
                updatedState.lastUpdated = Date()

                await activity.update(
                    ActivityContent(
                        state: updatedState,
                        staleDate: nil
                    )
                )
            }
        }

        // Signal Flutter via UserDefaults (secondary sync path)
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
public struct WorkoutConfirmRPEIntent: LiveActivityIntent {
    public init() {}
    public static var title: LocalizedStringResource { "Confirm RPE" }
    public static var description: IntentDescription { "Confirm RPE selection and start rest timer" }
    public static var openAppWhenRun: Bool = false

    public func perform() async throws -> some IntentResult {
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

                let isLastSet = currentState.currentSet >= currentState.totalSets
                var actualRestDuration: Int
                var updatedState = currentState
                updatedState.mode = .rest
                updatedState.selectedRPE = lastRPE

                if isLastSet {
                    // Last set of exercise: read next exercise info from UserDefaults
                    let nextName = userDefaults?.string(forKey: nextExerciseNameKey)
                    let nextSet = userDefaults?.integer(forKey: nextExerciseSetKey) ?? 1
                    let nextTotalSets = userDefaults?.integer(forKey: nextExerciseTotalSetsKey)
                    let nextWeight = userDefaults?.double(forKey: nextExerciseWeightKey)
                    let nextReps = userDefaults?.integer(forKey: nextExerciseTargetRepsKey)
                    let interRest = userDefaults?.integer(forKey: nextExerciseRestDurationKey)

                    if let nextName = nextName, !nextName.isEmpty {
                        print("📋 [WorkoutConfirmRPEIntent] Last set → next exercise: \(nextName)")
                        updatedState.exerciseName = nextName
                        updatedState.currentSet = nextSet > 0 ? nextSet : 1
                        if let ts = nextTotalSets, ts > 0 { updatedState.totalSets = ts }
                        if let w = nextWeight { updatedState.weight = w }
                        if let r = nextReps, r > 0 { updatedState.targetReps = r }
                    }

                    let interRestDuration = (interRest ?? 0) > 0 ? interRest! : (userDefaults?.integer(forKey: currentRestDurationKey) ?? defaultRestDuration)
                    actualRestDuration = interRestDuration > 0 ? interRestDuration : defaultRestDuration
                } else {
                    // Not last set: increment set number
                    updatedState.currentSet = currentState.currentSet + 1
                    let restDuration = userDefaults?.integer(forKey: currentRestDurationKey) ?? defaultRestDuration
                    actualRestDuration = restDuration > 0 ? restDuration : defaultRestDuration
                }

                let now = Date()
                let endDate = now.addingTimeInterval(TimeInterval(actualRestDuration))
                updatedState.restStartDate = now
                updatedState.restEndDate = endDate
                updatedState.restTotalSeconds = actualRestDuration
                updatedState.lastUpdated = now

                // FIX: Use long staleDate (2 hours from now) to allow future updates
                // iOS ignores updates on "stale" activities
                await activity.update(
                    ActivityContent(
                        state: updatedState,
                        staleDate: Date().addingTimeInterval(7200)  // 2 hours from now
                    )
                )
                print("✅ [WorkoutConfirmRPEIntent] LA transitioned to REST (\(actualRestDuration)s)")

                // 🔔 CRITICAL FIX: Schedule notification for timer completion
                // This is the ONLY reliable way to get audio when app is in background
                // iOS delivers this notification with sound even if app is killed
                await scheduleRestTimerNotification(
                    duration: actualRestDuration,
                    exerciseName: updatedState.exerciseName
                )
                print("🔔 [WorkoutConfirmRPEIntent] Timer notification scheduled from Intent!")
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
public struct WorkoutPauseResumeIntent: LiveActivityIntent {
    public init() {}
    public static var title: LocalizedStringResource { "Pause/Resume" }
    public static var description: IntentDescription { "Pause or resume the rest timer" }
    public static var openAppWhenRun: Bool = false

    public func perform() async throws -> some IntentResult {
        print("🟢 [WorkoutPauseResumeIntent] perform() called!")

        // 1. Update Live Activity and handle notification
        if let activity = Activity<WorkoutSessionAttributes>.activities.first {
            let currentState = activity.content.state
            print("📊 [WorkoutPauseResumeIntent] Current state: mode=\(currentState.mode), isPaused=\(currentState.isPaused)")

            // Only handle if in rest mode
            if currentState.mode == .rest {
                let newPausedState = !currentState.isPaused

                if newPausedState {
                    // PAUSING: Cancel the notification since timer is stopped
                    print("⏸️ [WorkoutPauseResumeIntent] Pausing timer - cancelling notification")
                    await cancelRestTimerNotification()

                    // Calculate remaining time and store it
                    var updatedState = currentState
                    updatedState.isPaused = true

                    if let endDate = currentState.restEndDate {
                        let remainingSeconds = Int(endDate.timeIntervalSinceNow)
                        updatedState.pausedRemainingSeconds = max(0, remainingSeconds)
                        print("   - Stored remaining: \(updatedState.pausedRemainingSeconds ?? 0)s")
                    }

                    updatedState.lastUpdated = Date()

                    await activity.update(
                        ActivityContent(
                            state: updatedState,
                            staleDate: nil  // No stale date when paused
                        )
                    )
                    print("✅ [WorkoutPauseResumeIntent] Timer PAUSED, notification cancelled")

                } else {
                    // RESUMING: Reschedule notification with remaining time
                    print("▶️ [WorkoutPauseResumeIntent] Resuming timer - rescheduling notification")

                    let remainingSeconds = currentState.pausedRemainingSeconds ?? currentState.restRemainingSeconds

                    if remainingSeconds > 0 {
                        let now = Date()
                        let newEndDate = now.addingTimeInterval(TimeInterval(remainingSeconds))

                        var updatedState = currentState
                        updatedState.isPaused = false
                        updatedState.restStartDate = now
                        updatedState.restEndDate = newEndDate
                        updatedState.pausedRemainingSeconds = nil
                        updatedState.lastUpdated = now

                        // FIX: Use long staleDate (2 hours from now) to allow future updates
                        // iOS ignores updates on "stale" activities
                        await activity.update(
                            ActivityContent(
                                state: updatedState,
                                staleDate: Date().addingTimeInterval(7200)  // 2 hours from now
                            )
                        )

                        // 🔔 Reschedule notification for remaining time
                        await scheduleRestTimerNotification(
                            duration: remainingSeconds,
                            exerciseName: currentState.exerciseName
                        )
                        print("✅ [WorkoutPauseResumeIntent] Timer RESUMED, notification scheduled for \(remainingSeconds)s")
                    }
                }
            }
        }

        // 2. Signal Flutter via UserDefaults + Darwin notification
        print("📤 [WorkoutPauseResumeIntent] Saving event to UserDefaults...")
        saveEventToUserDefaults(
            eventType: .pauseResume,
            additionalData: [
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )

        return .result()
    }
}

// MARK: - Timer Notification Scheduling
/// 🔔 CRITICAL FIX: Schedule iOS local notification for timer completion
/// This is called directly from Intent when REST timer starts
/// iOS delivers the notification with sound even if app is killed
/// NOTE: Awaited directly from perform() to guarantee completion before iOS terminates the extension.
@available(iOS 16.1, *)
func scheduleRestTimerNotification(duration: Int, exerciseName: String = "Set") async {
    print("🔔 [INTENT-NOTIFICATION] Scheduling timer notification for \(duration)s")

    let userDefaults = UserDefaults(suiteName: RestTimerNotificationSupport.sharedSuiteName)
    let soundName = RestTimerNotificationSupport.preferredSoundName(from: userDefaults)
    let userInfo: [AnyHashable: Any] = [
        "type": "rest_timer_completion",
        "exercise": exerciseName,
        "scheduledAt": Date().timeIntervalSince1970,
        "duration": duration,
        "source": "intent_direct"
    ]

    let identifier = RestTimerNotificationSupport.scheduleCompletion(
        after: TimeInterval(duration),
        soundName: soundName,
        title: "⏱️ Rest Complete",
        body: "Time to start your next set!",
        userInfo: userInfo
    ) { error in
        if let error {
            print("❌ [INTENT-NOTIFICATION] Failed to schedule: \(error.localizedDescription)")
        }
    }

    let resolvedFileName =
        RestTimerNotificationSupport.resolvedSoundFileName(for: soundName) ??
        RestTimerNotificationSupport.defaultSoundName

    print("✅ [INTENT-NOTIFICATION] Scheduled successfully!")
    print("   - Duration: \(duration)s")
    print("   - Sound: \(resolvedFileName)")
    print("   - ID: \(identifier)")
    print("   - This notification fires even if app is killed!")
}

/// Cancel ALL pending timer completion notifications (called when user skips/pauses rest)
/// Cancels both by fixed ID and by category to catch app-scheduled notifications too
/// NOTE: Awaited directly from perform() to guarantee completion before iOS terminates the extension.
@available(iOS 16.1, *)
func cancelRestTimerNotification() async {
    RestTimerNotificationSupport.cancelCompletion()
    print("🗑️ [INTENT-NOTIFICATION] Cancelled rest timer notification")
}

@available(iOS 16.1, *)
func rescheduleRestTimerNotification(
    remainingSeconds: Int,
    exerciseName: String = "Set"
) async {
    await scheduleRestTimerNotification(
        duration: remainingSeconds,
        exerciseName: exerciseName
    )
}

// MARK: - Helper Function
/// Shared helper: saves event to UserDefaults and posts Darwin notification.
/// Used by both WorkoutSession intents (iOS 17+) and GymBroTimer intents (iOS 16.1+).
/// Must be non-private so AppIntent.swift can call it from the same target.
///
/// ARCH NOTE: With LiveActivityIntent, perform() runs in the MAIN APP PROCESS.
/// The Darwin notification is now reliable (delivered in-process to WorkoutSessionManager's
/// observer). UserDefaults save acts as safety net for checkPendingEvents() on app resume.
@available(iOS 16.1, *)
func saveEventToUserDefaults(
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
    print("✅ [saveEventToUserDefaults] Saved to UserDefaults with key: \(workoutEventKey)")

    // Also save last RPE if this is a select RPE event
    if eventType == .selectRPE, let rpe = additionalData["selectedRPE"] as? Int {
        userDefaults.set(rpe, forKey: "last_selected_rpe")
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
