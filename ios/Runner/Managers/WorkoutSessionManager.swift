import Foundation
import ActivityKit
import Flutter

/// Manages the unified Workout Session Live Activity
/// Handles communication between Flutter and iOS Live Activity
@available(iOS 17.0, *)
class WorkoutSessionManager: NSObject {
    static let shared = WorkoutSessionManager()

    private var currentActivity: Activity<WorkoutSessionAttributes>?
    private var methodChannel: FlutterMethodChannel?
    private var eventObserver: CFRunLoopObserver?

    private let sharedSuiteName = "group.com.michele.gymbro.flutter"
    private let eventKey = "workout_session_event"

    private override init() {
        super.init()
        setupDarwinNotificationObserver()
    }

    deinit {
        removeDarwinNotificationObserver()
    }

    // MARK: - Setup

    func setupMethodChannel(with binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.gymbro.timer/workout_session",
            binaryMessenger: binaryMessenger
        )

        self.methodChannel = channel

        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call, result: result)
        }

        Logger.shared.debug("✅ WorkoutSessionManager: MethodChannel setup complete", category: .general)
    }

    // MARK: - Method Call Handler

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startWorkoutSession":
            startWorkoutSession(call.arguments as? [String: Any], result: result)
        case "updateWorkoutSession":
            updateWorkoutSession(call.arguments as? [String: Any], result: result)
        case "transitionToRest":
            transitionToRest(call.arguments as? [String: Any], result: result)
        case "transitionToExercise":
            transitionToExercise(call.arguments as? [String: Any], result: result)
        case "transitionToRPE":
            transitionToRPE(call.arguments as? [String: Any], result: result)
        case "updateSelectedRPE":
            updateSelectedRPE(call.arguments as? [String: Any], result: result)
        case "extendRestTimer":
            extendRestTimer(call.arguments as? [String: Any], result: result)
        case "pauseRestTimer":
            pauseRestTimer(call.arguments as? [String: Any], result: result)
        case "resumeRestTimer":
            resumeRestTimer(call.arguments as? [String: Any], result: result)
        case "endWorkoutSession":
            endWorkoutSession(call.arguments as? [String: Any], result: result)
        case "isWorkoutSessionActive":
            isWorkoutSessionActive(result: result)
        case "getWorkoutSessionState":
            getWorkoutSessionState(result: result)
        case "setCurrentRestDuration":
            setCurrentRestDuration(call.arguments as? [String: Any], result: result)
        case "setRpeTrackingEnabled":
            setRpeTrackingEnabled(call.arguments as? [String: Any], result: result)
        case "checkPendingEvents":
            checkPendingEvents(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Start Workout Session

    private func startWorkoutSession(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            result(FlutterError(code: "DISABLED", message: "Live Activities are disabled", details: nil))
            return
        }

        guard let args = arguments,
              let workoutId = args["workoutId"] as? String,
              let workoutName = args["workoutName"] as? String,
              let exerciseName = args["exerciseName"] as? String,
              let currentSet = args["currentSet"] as? Int,
              let totalSets = args["totalSets"] as? Int,
              let weight = args["weight"] as? Double,
              let targetReps = args["targetReps"] as? Int,
              let completedExercises = args["completedExercises"] as? Int,
              let totalExercises = args["totalExercises"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required parameters", details: nil))
            return
        }

        let rpeEnabled = args["rpeEnabled"] as? Bool ?? false

        // End any existing session first
        Task {
            await endAllExistingSessions()

            // Create attributes
            let attributes = WorkoutSessionAttributes(
                workoutId: workoutId,
                workoutName: workoutName
            )

            // Create initial state
            let initialState = WorkoutSessionAttributes.ContentState(
                mode: .exercise,
                exerciseName: exerciseName,
                currentSet: currentSet,
                totalSets: totalSets,
                weight: weight,
                targetReps: targetReps,
                workoutStartDate: Date(),
                restStartDate: nil,
                restEndDate: nil,
                restTotalSeconds: 0,
                selectedRPE: nil,
                actualReps: nil,
                rpeEnabled: rpeEnabled,
                completedExercises: completedExercises,
                totalExercises: totalExercises,
                lastUpdated: Date(),
                isPaused: false,
                pausedRemainingSeconds: nil
            )

            do {
                let activity = try Activity<WorkoutSessionAttributes>.request(
                    attributes: attributes,
                    content: ActivityContent(state: initialState, staleDate: nil),
                    pushType: nil
                )

                self.currentActivity = activity
                Logger.shared.debug("✅ WorkoutSession Live Activity started: \(activity.id)", category: .general)
                result(activity.id)

            } catch {
                Logger.shared.log(.error, "❌ Failed to start WorkoutSession LA: \(error)", category: .general)
                result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
            }
        }
    }

    // MARK: - Update Workout Session

    private func updateWorkoutSession(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let activity = currentActivity else {
            result(FlutterError(code: "NO_ACTIVITY", message: "No active workout session", details: nil))
            return
        }

        guard let args = arguments else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
            return
        }

        let currentState = activity.content.state

        // Build updated state
        var updatedState = currentState
        updatedState.exerciseName = args["exerciseName"] as? String ?? currentState.exerciseName
        updatedState.currentSet = args["currentSet"] as? Int ?? currentState.currentSet
        updatedState.totalSets = args["totalSets"] as? Int ?? currentState.totalSets
        updatedState.weight = args["weight"] as? Double ?? currentState.weight
        updatedState.targetReps = args["targetReps"] as? Int ?? currentState.targetReps
        updatedState.completedExercises = args["completedExercises"] as? Int ?? currentState.completedExercises
        updatedState.totalExercises = args["totalExercises"] as? Int ?? currentState.totalExercises
        updatedState.lastUpdated = Date()

        Task {
            await activity.update(
                ActivityContent(state: updatedState, staleDate: nil)
            )
            result(true)
        }
    }

    // MARK: - Transition to Rest

    private func transitionToRest(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let activity = currentActivity else {
            result(FlutterError(code: "NO_ACTIVITY", message: "No active workout session", details: nil))
            return
        }

        guard let args = arguments,
              let restDuration = args["restDuration"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing restDuration", details: nil))
            return
        }

        let currentState = activity.content.state
        let now = Date()
        let endDate = now.addingTimeInterval(TimeInterval(restDuration))

        var updatedState = currentState
        updatedState.mode = .rest
        updatedState.restStartDate = now
        updatedState.restEndDate = endDate
        updatedState.restTotalSeconds = restDuration
        updatedState.selectedRPE = nil
        updatedState.isPaused = false  // New rest timer starts running
        updatedState.pausedRemainingSeconds = nil
        updatedState.lastUpdated = now

        // Update exercise info if provided
        if let exerciseName = args["nextExerciseName"] as? String {
            updatedState.exerciseName = exerciseName
        }
        if let nextSet = args["nextSet"] as? Int {
            updatedState.currentSet = nextSet
        }
        if let totalSets = args["totalSets"] as? Int {
            updatedState.totalSets = totalSets
        }
        if let weight = args["weight"] as? Double {
            updatedState.weight = weight
        }
        if let targetReps = args["targetReps"] as? Int {
            updatedState.targetReps = targetReps
        }

        Task {
            await activity.update(
                ActivityContent(
                    state: updatedState,
                    staleDate: endDate.addingTimeInterval(10)
                )
            )

            Logger.shared.debug("🔄 WorkoutSession transitioned to REST mode (\(restDuration)s)", category: .general)
            result(true)
        }
    }

    // MARK: - Transition to Exercise

    private func transitionToExercise(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        print("🔄 [WorkoutSession] transitionToExercise called")

        // FIX: Always get the activity from the system instead of using potentially stale reference
        let activities = Activity<WorkoutSessionAttributes>.activities
        print("📋 [WorkoutSession] Found \(activities.count) active WorkoutSession activities")

        guard let activity = activities.first else {
            print("❌ [WorkoutSession] No activity found in system - cannot transition!")
            if currentActivity != nil {
                print("⚠️ [WorkoutSession] Local currentActivity exists but system has no activities - reference was stale!")
                currentActivity = nil
            }
            result(FlutterError(code: "NO_ACTIVITY", message: "No active workout session", details: nil))
            return
        }

        print("✅ [WorkoutSession] Got activity from system: \(activity.id)")

        // WORKAROUND: iOS seems to ignore updates after rest timer's staleDate.
        // Instead of just updating, we'll end the current activity and create a new one.
        // This ensures the UI transitions properly from REST to EXERCISE mode.
        // DISABLED: RECREATE workaround destroys the LA and can't recreate in background
        // The client-side effectiveMode in WorkoutSessionLiveActivity.swift now handles
        // the visual transition from REST to EXERCISE automatically when timer expires
        let useRecreateWorkaround = false

        let currentState = activity.content.state
        let args = arguments ?? [:]

        // Debug: Check if activity is stale
        print("🔍 [WorkoutSession] Current state before update:")
        print("   - mode: \(currentState.mode)")
        print("   - activityState: \(activity.activityState)")
        if let restEnd = currentState.restEndDate {
            let timeSinceRestEnd = Date().timeIntervalSince(restEnd)
            print("   - restEndDate: \(restEnd)")
            print("   - seconds since rest ended: \(String(format: "%.1f", timeSinceRestEnd))s")
        }

        // Build the new state for EXERCISE mode
        var updatedState = currentState
        updatedState.mode = .exercise
        updatedState.restStartDate = nil
        updatedState.restEndDate = nil
        updatedState.restTotalSeconds = 0
        updatedState.selectedRPE = nil
        updatedState.isPaused = false  // Reset pause state
        updatedState.pausedRemainingSeconds = nil
        updatedState.lastUpdated = Date()

        // Update exercise info from arguments
        if let exerciseName = args["exerciseName"] as? String {
            updatedState.exerciseName = exerciseName
        }
        if let currentSet = args["currentSet"] as? Int {
            updatedState.currentSet = currentSet
        }
        if let totalSets = args["totalSets"] as? Int {
            updatedState.totalSets = totalSets
        }
        if let weight = args["weight"] as? Double {
            updatedState.weight = weight
        }
        if let targetReps = args["targetReps"] as? Int {
            updatedState.targetReps = targetReps
        }
        if let completedExercises = args["completedExercises"] as? Int {
            updatedState.completedExercises = completedExercises
        }

        print("📝 [WorkoutSession] Target state: mode=\(updatedState.mode), exercise=\(updatedState.exerciseName), set=\(updatedState.currentSet)/\(updatedState.totalSets)")

        if useRecreateWorkaround {
            // WORKAROUND: End current activity and create a new one
            print("🔄 [WorkoutSession] Using RECREATE workaround (end + create new)")

            Task {
                // 1. End the current activity immediately
                print("🛑 [WorkoutSession] Ending current activity: \(activity.id)")
                await activity.end(dismissalPolicy: .immediate)

                // 2. Small delay to ensure iOS processes the end
                try? await Task.sleep(nanoseconds: 50_000_000) // 50ms

                // 3. Create a new activity with EXERCISE state
                print("🆕 [WorkoutSession] Creating new activity in EXERCISE mode")
                do {
                    let newActivity = try Activity<WorkoutSessionAttributes>.request(
                        attributes: activity.attributes,
                        content: ActivityContent(state: updatedState, staleDate: nil),
                        pushType: nil
                    )

                    self.currentActivity = newActivity
                    print("✅ [WorkoutSession] New activity created: \(newActivity.id)")
                    print("   - Mode: \(newActivity.content.state.mode)")
                    result(true)
                } catch {
                    print("❌ [WorkoutSession] Failed to create new activity: \(error)")
                    result(FlutterError(code: "RECREATE_FAILED", message: error.localizedDescription, details: nil))
                }
            }
        } else {
            // Original approach: just update (doesn't work reliably)
            Task {
                print("📤 [WorkoutSession] Calling activity.update()...")
                print("   - Activity ID: \(activity.id)")
                print("   - Sending mode: \(updatedState.mode)")

                await activity.update(
                    ActivityContent(state: updatedState, staleDate: nil)
                )

                // Small delay to allow iOS to propagate the update
                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms

                // Verify the update
                let updatedActivities = Activity<WorkoutSessionAttributes>.activities
                print("🔍 [WorkoutSession] After update - found \(updatedActivities.count) activities")

                if let updatedActivity = updatedActivities.first {
                    print("✅ [WorkoutSession] activity.update() completed")
                    print("   - New mode in content: \(updatedActivity.content.state.mode)")

                    if updatedActivity.content.state.mode == .exercise {
                        print("   ✅ MODE SUCCESSFULLY CHANGED TO EXERCISE!")
                    } else {
                        print("   ❌ MODE STILL \(updatedActivity.content.state.mode) - UPDATE FAILED!")
                    }
                }

                self.currentActivity = activity
                result(true)
            }
        }
    }

    // MARK: - Transition to RPE

    private func transitionToRPE(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let activity = currentActivity else {
            result(FlutterError(code: "NO_ACTIVITY", message: "No active workout session", details: nil))
            return
        }

        let currentState = activity.content.state

        var updatedState = currentState
        updatedState.mode = .rpe
        updatedState.restStartDate = nil
        updatedState.restEndDate = nil
        updatedState.selectedRPE = nil
        updatedState.isPaused = false  // Reset pause state
        updatedState.pausedRemainingSeconds = nil
        updatedState.lastUpdated = Date()

        Task {
            await activity.update(
                ActivityContent(state: updatedState, staleDate: nil)
            )

            Logger.shared.debug("🔄 WorkoutSession transitioned to RPE mode", category: .general)
            result(true)
        }
    }

    // MARK: - Update Selected RPE

    private func updateSelectedRPE(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let activity = currentActivity else {
            result(FlutterError(code: "NO_ACTIVITY", message: "No active workout session", details: nil))
            return
        }

        guard let args = arguments,
              let rpe = args["rpe"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing rpe value", details: nil))
            return
        }

        let currentState = activity.content.state

        var updatedState = currentState
        updatedState.selectedRPE = rpe
        updatedState.lastUpdated = Date()

        Task {
            await activity.update(
                ActivityContent(state: updatedState, staleDate: nil)
            )

            Logger.shared.debug("🎯 WorkoutSession selectedRPE updated to \(rpe)", category: .general)
            result(true)
        }
    }

    // MARK: - Extend Rest Timer

    private func extendRestTimer(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let activity = currentActivity else {
            result(FlutterError(code: "NO_ACTIVITY", message: "No active workout session", details: nil))
            return
        }

        guard let args = arguments,
              let additionalSeconds = args["additionalSeconds"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing additionalSeconds", details: nil))
            return
        }

        let currentState = activity.content.state

        // Only extend if we're in rest mode and have valid dates
        guard currentState.mode == .rest,
              let currentEndDate = currentState.restEndDate else {
            result(FlutterError(code: "NOT_IN_REST", message: "Not in rest mode", details: nil))
            return
        }

        // Calculate new end date
        let newEndDate = currentEndDate.addingTimeInterval(TimeInterval(additionalSeconds))
        let newTotalSeconds = currentState.restTotalSeconds + additionalSeconds

        var updatedState = currentState
        updatedState.restEndDate = newEndDate
        updatedState.restTotalSeconds = newTotalSeconds
        updatedState.lastUpdated = Date()

        Task {
            await activity.update(
                ActivityContent(
                    state: updatedState,
                    staleDate: newEndDate.addingTimeInterval(10)
                )
            )

            Logger.shared.debug("⏰ WorkoutSession rest extended by \(additionalSeconds)s (new total: \(newTotalSeconds)s)", category: .general)
            result(true)
        }
    }

    // MARK: - Pause Rest Timer

    /// Pause the rest timer on the Live Activity
    /// Stores the remaining time and updates the UI to show paused state
    private func pauseRestTimer(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        print("⏸️ [WorkoutSession] pauseRestTimer called")

        guard let activity = currentActivity else {
            print("❌ [WorkoutSession] No activity found for pause")
            result(FlutterError(code: "NO_ACTIVITY", message: "No active workout session", details: nil))
            return
        }

        guard let args = arguments,
              let remainingSeconds = args["remainingSeconds"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing remainingSeconds", details: nil))
            return
        }

        let currentState = activity.content.state

        // Only pause if we're in rest mode and not already paused
        guard currentState.mode == .rest else {
            print("⚠️ [WorkoutSession] Cannot pause - not in rest mode (mode=\(currentState.mode))")
            result(FlutterError(code: "NOT_IN_REST", message: "Not in rest mode", details: nil))
            return
        }

        if currentState.isPaused {
            print("⚠️ [WorkoutSession] Already paused")
            result(true)
            return
        }

        var updatedState = currentState
        updatedState.isPaused = true
        updatedState.pausedRemainingSeconds = remainingSeconds
        updatedState.lastUpdated = Date()

        print("⏸️ [WorkoutSession] Pausing with \(remainingSeconds)s remaining")

        Task {
            await activity.update(
                ActivityContent(
                    state: updatedState,
                    staleDate: nil  // No stale date when paused
                )
            )

            print("✅ [WorkoutSession] Rest timer paused successfully")
            result(true)
        }
    }

    // MARK: - Resume Rest Timer

    /// Resume the rest timer on the Live Activity
    /// Recalculates the end date based on remaining time
    private func resumeRestTimer(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        print("▶️ [WorkoutSession] resumeRestTimer called")

        guard let activity = currentActivity else {
            print("❌ [WorkoutSession] No activity found for resume")
            result(FlutterError(code: "NO_ACTIVITY", message: "No active workout session", details: nil))
            return
        }

        guard let args = arguments,
              let remainingSeconds = args["remainingSeconds"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing remainingSeconds", details: nil))
            return
        }

        let currentState = activity.content.state

        // Only resume if we're paused
        guard currentState.isPaused else {
            print("⚠️ [WorkoutSession] Not paused, nothing to resume")
            result(true)
            return
        }

        // Calculate new dates based on remaining time
        let now = Date()
        let newEndDate = now.addingTimeInterval(TimeInterval(remainingSeconds))

        var updatedState = currentState
        updatedState.isPaused = false
        updatedState.pausedRemainingSeconds = nil
        updatedState.restStartDate = now
        updatedState.restEndDate = newEndDate
        updatedState.lastUpdated = now

        print("▶️ [WorkoutSession] Resuming with \(remainingSeconds)s remaining, new endDate: \(newEndDate)")

        Task {
            await activity.update(
                ActivityContent(
                    state: updatedState,
                    staleDate: newEndDate.addingTimeInterval(10)
                )
            )

            print("✅ [WorkoutSession] Rest timer resumed successfully")
            result(true)
        }
    }

    // MARK: - Set Current Rest Duration

    /// Stores the current exercise's rest duration in shared UserDefaults
    /// This allows AppIntents to read the correct duration when transitioning to REST mode
    private func setCurrentRestDuration(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let duration = args["duration"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing duration", details: nil))
            return
        }

        let userDefaults = UserDefaults(suiteName: sharedSuiteName)
        userDefaults?.set(duration, forKey: "current_exercise_rest_duration")
        userDefaults?.synchronize()

        Logger.shared.debug("📝 Stored current rest duration: \(duration)s", category: .general)
        result(true)
    }

    // MARK: - Set RPE Tracking Enabled

    /// Stores the RPE tracking setting in shared UserDefaults
    /// This allows AppIntents to know whether to show RPE mode or go directly to REST
    private func setRpeTrackingEnabled(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let enabled = args["enabled"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing enabled flag", details: nil))
            return
        }

        let userDefaults = UserDefaults(suiteName: sharedSuiteName)
        userDefaults?.set(enabled, forKey: "rpe_tracking_enabled")
        userDefaults?.synchronize()

        print("📝 [WorkoutSession] Stored RPE tracking enabled: \(enabled)")
        result(true)
    }

    // MARK: - Check Pending Events

    /// Checks UserDefaults for any pending Live Activity events that weren't processed
    /// This is called when the app resumes from background to catch events that were
    /// sent while the app was suspended.
    ///
    /// FIX: When app is suspended, Darwin notifications may not wake the callback.
    /// This method is called on app resume to process any missed events.
    private func checkPendingEvents(result: @escaping FlutterResult) {
        guard let userDefaults = UserDefaults(suiteName: sharedSuiteName),
              let eventData = userDefaults.dictionary(forKey: eventKey) else {
            Logger.shared.debug("📭 No pending workout events found", category: .general)
            result(nil)
            return
        }

        Logger.shared.debug("📬 Found pending workout event: \(eventData["eventType"] ?? "unknown")", category: .general)

        // Forward to Flutter
        DispatchQueue.main.async { [weak self] in
            self?.methodChannel?.invokeMethod("onWorkoutSessionEvent", arguments: eventData)
        }

        // Clear the event after forwarding
        userDefaults.removeObject(forKey: eventKey)
        userDefaults.synchronize()

        // Return the event data so Flutter knows what was found
        result(eventData)
    }

    // MARK: - End Workout Session

    private func endWorkoutSession(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let activity = currentActivity else {
            result(true) // No activity to end
            return
        }

        let dismissPolicy = (arguments?["dismissPolicy"] as? String) ?? "immediate"

        Task {
            let policy: ActivityUIDismissalPolicy
            switch dismissPolicy {
            case "after_5s":
                policy = .after(Date().addingTimeInterval(5))
            case "after_30s":
                policy = .after(Date().addingTimeInterval(30))
            default:
                policy = .immediate
            }

            await activity.end(
                ActivityContent(state: activity.content.state, staleDate: nil),
                dismissalPolicy: policy
            )

            self.currentActivity = nil
            Logger.shared.debug("✅ WorkoutSession Live Activity ended", category: .general)
            result(true)
        }
    }

    // MARK: - Status Methods

    private func isWorkoutSessionActive(result: @escaping FlutterResult) {
        result(currentActivity != nil)
    }

    private func getWorkoutSessionState(result: @escaping FlutterResult) {
        guard let activity = currentActivity else {
            result(nil)
            return
        }

        let state = activity.content.state
        let stateDict: [String: Any] = [
            "mode": state.mode.rawValue,
            "exerciseName": state.exerciseName,
            "currentSet": state.currentSet,
            "totalSets": state.totalSets,
            "weight": state.weight,
            "targetReps": state.targetReps,
            "completedExercises": state.completedExercises,
            "totalExercises": state.totalExercises,
            "workoutStartDate": state.workoutStartDate.timeIntervalSince1970 * 1000,
            "restRemainingSeconds": state.restRemainingSeconds,
            "selectedRPE": state.selectedRPE as Any,
            "rpeEnabled": state.rpeEnabled
        ]

        result(stateDict)
    }

    // MARK: - Darwin Notification Observer

    private func setupDarwinNotificationObserver() {
        let notificationName = "com.gymbro.workoutSession.event" as CFString

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            { _, observer, _, _, _ in
                guard let observer = observer else { return }
                let manager = Unmanaged<WorkoutSessionManager>.fromOpaque(observer).takeUnretainedValue()
                manager.handleDarwinNotification()
            },
            notificationName,
            nil,
            .deliverImmediately
        )

        Logger.shared.debug("✅ Darwin notification observer setup for workout events", category: .general)
    }

    private func removeDarwinNotificationObserver() {
        CFNotificationCenterRemoveEveryObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque()
        )
    }

    @objc private func handleDarwinNotification() {
        print("🔔 [WorkoutSession] Darwin notification received!")

        // Read event from UserDefaults
        guard let userDefaults = UserDefaults(suiteName: sharedSuiteName) else {
            print("❌ [WorkoutSession] Failed to access shared UserDefaults")
            return
        }

        guard let eventData = userDefaults.dictionary(forKey: eventKey) else {
            print("❌ [WorkoutSession] No event data found in UserDefaults for key: \(eventKey)")
            return
        }

        print("📨 [WorkoutSession] Event data found: \(eventData)")

        // Forward event to Flutter
        DispatchQueue.main.async { [weak self] in
            guard let channel = self?.methodChannel else {
                print("❌ [WorkoutSession] MethodChannel is nil!")
                return
            }
            print("📤 [WorkoutSession] Invoking onWorkoutSessionEvent on Flutter")
            channel.invokeMethod("onWorkoutSessionEvent", arguments: eventData)
        }

        print("📨 [WorkoutSession] Forwarded workout event to Flutter: \(eventData["eventType"] ?? "unknown")")

        // Clear the event
        userDefaults.removeObject(forKey: eventKey)
        userDefaults.synchronize()
    }

    // MARK: - Helpers

    private func endAllExistingSessions() async {
        let activities = Activity<WorkoutSessionAttributes>.activities

        for activity in activities {
            await activity.end(dismissalPolicy: .immediate)
        }

        currentActivity = nil

        if !activities.isEmpty {
            Logger.shared.debug("🧹 Ended \(activities.count) existing WorkoutSession activities", category: .general)
        }
    }
}

// MARK: - iOS 16 Fallback
/// For iOS 16.1-16.4, provide a stub that doesn't do anything
/// The app will use the existing timer-based Live Activities instead
class WorkoutSessionManagerFallback: NSObject {
    static let shared = WorkoutSessionManagerFallback()

    func setupMethodChannel(with binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.gymbro.timer/workout_session",
            binaryMessenger: binaryMessenger
        )

        channel.setMethodCallHandler { (call, result) in
            // Return not supported for all methods
            result(FlutterError(
                code: "NOT_SUPPORTED",
                message: "WorkoutSession Live Activity requires iOS 17+",
                details: nil
            ))
        }

        Logger.shared.debug("⚠️ WorkoutSessionManager: iOS 17+ required, using fallback", category: .general)
    }
}
