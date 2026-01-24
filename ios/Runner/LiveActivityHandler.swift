import Foundation
import ActivityKit
import Flutter


// MARK: - Timer Notification Localization
/// Simple localization helper for timer notification strings
/// Supports IT and EN (default)
struct TimerNotificationStrings {
    static var timerComplete: String {
        if Locale.current.language.languageCode?.identifier == "it" {
            return "⏰ Timer Completato!"
        }
        return "⏰ Timer Complete"
    }

    static var restTimerFinished: String {
        if Locale.current.language.languageCode?.identifier == "it" {
            return "Il tuo timer è terminato"
        }
        return "Your timer has finished"
    }
}

@available(iOS 16.1, *)
class LiveActivityHandler: NSObject {
    static let shared = LiveActivityHandler()
    private var currentActivity: Activity<GymBroTimerAttributes>?
    // CRITICAL FIX: Thread-safe state management
    private let activityQueue = DispatchQueue(label: "com.gymbro.liveactivity.state", qos: .userInitiated)
    private var scheduledNotificationId: String?  // Track scheduled notification for cancellation

    // THREAD-SAFE: Protected state tracking - accessed via activityQueue
    private var _lastRunningState: Bool = false  // Track previous running state to detect resume
    private var lastRunningState: Bool {
        get { activityQueue.sync { _lastRunningState } }
        set { activityQueue.sync { _lastRunningState = newValue } }
    }

    private var completionLogWorkItem: DispatchWorkItem?  // Track scheduled completion log to prevent duplicates

    // OPTIMIZATION: Smart throttling for Live Activity updates
    private var _lastUpdateTime: Date?  // Track last update time for throttling
    private var lastUpdateTime: Date? {
        get { activityQueue.sync { _lastUpdateTime } }
        set { activityQueue.sync { _lastUpdateTime = newValue } }
    }
    private let updateThrottleInterval: TimeInterval = 5.0  // 5 seconds for timers >= 60s

    private override init() {
        super.init()
    }

    // MEMORY FIX: Ensure cleanup when handler is deallocated
    deinit {
        // Cancel any pending work items
        completionLogWorkItem?.cancel()

        // Cancel background audio
        BackgroundAudioManager.shared.cancelScheduledAudio()

        // Cancel any scheduled notifications
        if let notificationId = scheduledNotificationId {
            DirectNotificationManager.shared.cancelNotification(identifier: notificationId)
        }

        Logger.shared.debug("🧹 LiveActivityHandler deallocated - cleaned up resources", category: .general)
    }

    // MARK: - Public Methods for UnifiedTimerCoordinator
    
    /// Public method to start Live Activity (called from UnifiedTimerCoordinator)
    func startLiveActivityDirectly(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        Logger.shared.debug("LiveActivityHandler: startLiveActivityDirectly called", category: .general)
        
        // Check if Live Activities are supported
        if !ActivityAuthorizationInfo().areActivitiesEnabled {
            Logger.shared.log(.error, "❌ Live Activities are disabled in system settings", category: .general)
            result(FlutterError(code: "DISABLED", message: "Live Activities are disabled", details: nil))
            return
        }
        
        Logger.shared.debug("Live Activities are enabled, proceeding with startLiveActivity", category: .general)
        startLiveActivity(arguments, result: result)
    }
    
    /// Public method to update Live Activity (called from UnifiedTimerCoordinator)
    func updateLiveActivityDirectly(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        Logger.shared.log(.debug, "🔄 LiveActivityHandler: updateLiveActivityDirectly called", category: .general)
        updateLiveActivity(arguments, result: result)
    }
    
    /// Public method to end Live Activity (called from UnifiedTimerCoordinator)
    func endLiveActivityDirectly(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        Logger.shared.debug("LiveActivityHandler: endLiveActivityDirectly called", category: .general)

        // CRITICAL FIX: Clean up state before ending activity
        cleanupActivityState()

        endLiveActivity(arguments, result: result)
    }
    
    /// Public method to end ALL active Live Activities (called from UnifiedTimerCoordinator)
    /// This prevents timer stacking by ensuring all previous timers are cleaned up
    func endAllActiveLiveActivitiesDirectly(result: @escaping FlutterResult) {
        Logger.shared.debug("🧹 LiveActivityHandler: endAllActiveLiveActivitiesDirectly called", category: .general)

        // CRITICAL FIX: Clean up state before ending activities
        cleanupActivityState()

        // Get all active Live Activities
        let activities = Activity<GymBroTimerAttributes>.activities

        if activities.isEmpty {
            Logger.shared.debug("✅ No active Live Activities to end", category: .general)
            result(true)
            return
        }

        Logger.shared.debug("🔄 Found \(activities.count) active Live Activities to end", category: .general)

        // End all activities
        Task {
            for activity in activities {
                Logger.shared.debug("🏁 Ending Live Activity: \(activity.id)", category: .general)

                // Cancel background audio for this activity
                BackgroundAudioManager.shared.cancelScheduledAudio()

                // Create final content state
                let finalContentState = GymBroTimerAttributes.ContentState(
                    remainingSeconds: 0,
                    totalSeconds: activity.content.state.totalSeconds,
                    isRunning: false,
                    currentSet: activity.content.state.currentSet,
                    totalSets: activity.content.state.totalSets,
                    lastUpdated: Date(),
                    endDate: nil,
                    startDate: nil
                )

                // End immediately to prevent stacking
                await activity.end(
                    ActivityContent<GymBroTimerAttributes.ContentState>(
                        state: finalContentState,
                        staleDate: nil as Date?
                    ),
                    dismissalPolicy: .immediate
                )

                Logger.shared.debug("✅ Live Activity ended: \(activity.id)", category: .general)
            }

            // Clear current activity reference
            self.currentActivity = nil

            Logger.shared.debug("✅ All Live Activities ended successfully", category: .general)
            result(true)
        }
    }

    /// Public method to get active Live Activities (called from UnifiedTimerCoordinator)
    func getActiveLiveActivitiesDirectly(result: @escaping FlutterResult) {
        Logger.shared.log(.debug, "🔄 LiveActivityHandler: getActiveLiveActivitiesDirectly called", category: .general)
        getActiveLiveActivities(result: result)
    }
    
    func setupMethodChannel(with binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.gymbro.timer/live_activity",
            binaryMessenger: binaryMessenger
        )
        
        // ✅ Salva riferimento al channel per callbacks
        self.methodChannel = channel
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call, result: result)
        }
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startLiveActivity":
            startLiveActivity(call.arguments as? [String: Any], result: result)
        case "updateLiveActivity":
            updateLiveActivity(call.arguments as? [String: Any], result: result)
        case "endLiveActivity":
            endLiveActivity(call.arguments as? [String: Any], result: result)
        case "isLiveActivitySupported":
            isLiveActivitySupported(result: result)
        case "getActiveLiveActivities":
            getActiveLiveActivities(result: result)
        // ✅ RPE Interactive Live Activities
        case "showRPEInterface":
            showRPEInterface(call.arguments as? [String: Any], result: result)
        case "updateRPEInterface":
            updateRPEInterface(call.arguments as? [String: Any], result: result)
        case "confirmRPEAndCompleteSet":
            confirmRPEAndCompleteSet(call.arguments as? [String: Any], result: result)
        case "dismissRPEInterface":
            dismissRPEInterface(call.arguments as? [String: Any], result: result)
        // ✅ Schedule Countdown Live Activities
        case "startScheduleLiveActivity":
            startScheduleLiveActivity(call.arguments as? [String: Any], result: result)
        case "updateScheduleLiveActivity":
            updateScheduleLiveActivity(call.arguments as? [String: Any], result: result)
        case "endScheduleLiveActivity":
            endScheduleLiveActivity(call.arguments as? [String: Any], result: result)
        case "endAllScheduleLiveActivities":
            endAllScheduleLiveActivities(result: result)
        case "getActiveScheduleLiveActivities":
            getActiveScheduleLiveActivities(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startLiveActivity(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            result(FlutterError(code: "DISABLED", message: "Live Activities are disabled", details: nil))
            return
        }
        
        guard let args = arguments else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
            return
        }
        
        // CRITICAL FIX: Clean up must complete BEFORE creating new activity
        // This prevents race conditions and ensures single timer guarantee
        Task {
            do {
                await endAllActivities(keepCurrent: false)

                // Small delay to ensure cleanup is visible to user
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

                // Now safely create the new activity after cleanup
                await self.createNewLiveActivity(args, result: result)
            } catch {
                // ASYNC FIX: Ensure result is ALWAYS called, even on error
                Logger.shared.log(.error, "❌ Failed during Live Activity creation: \(error)", category: .general)
                await MainActor.run {
                    result(FlutterError(
                        code: "ASYNC_ERROR",
                        message: "Failed during Live Activity setup: \(error.localizedDescription)",
                        details: nil
                    ))
                }
            }
        }

        // Return early - creation continues in async task
        return
    }
    
    private func createNewLiveActivity(_ args: [String: Any], result: @escaping FlutterResult) async {
        // Extract parameters
        guard let exerciseName = args["exerciseName"] as? String,
              let timerType = args["timerType"] as? String,
              let totalSeconds = args["totalSeconds"] as? Int,
              let remainingSeconds = args["remainingSeconds"] as? Int,
              let isRunning = args["isRunning"] as? Bool,
              let currentSet = args["currentSet"] as? Int,
              let totalSets = args["totalSets"] as? Int,
              let lastUpdated = args["lastUpdated"] as? Int64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required parameters", details: nil))
            return
        }

        // CRITICAL FIX: Validate timer state before creating Live Activity
        let validationError = validateTimerState(
            exerciseName: exerciseName,
            timerType: timerType,
            totalSeconds: totalSeconds,
            remainingSeconds: remainingSeconds,
            isRunning: isRunning,
            currentSet: currentSet,
            totalSets: totalSets
        )

        if let error = validationError {
            Logger.shared.log(.error, "❌ Timer state validation failed: \(error)", category: .general)
            result(FlutterError(code: "INVALID_STATE", message: error, details: nil))
            return
        }

        Logger.shared.debug( "✅ Timer state validation passed", category: .general)
        
        let workoutName = args["workoutName"] as? String
        let soundName = args["soundName"] as? String ?? "sound"  // Get sound name from args
        
        // Create activity attributes
        let attributes = GymBroTimerAttributes(
            exerciseName: exerciseName,
            timerType: timerType,
            workoutName: workoutName
        )
        
        // ✅ Native iOS Timer: Precise startDate/endDate calculations
        let now = Date()
        
        // For native iOS timer to work correctly, we need precise timing
        let endDate = isRunning ? now.addingTimeInterval(TimeInterval(remainingSeconds)) : nil
        let startDate = isRunning ? now.addingTimeInterval(-TimeInterval(totalSeconds - remainingSeconds)) : nil
        
        // ✅ Longer staleDate for native timer (iOS handles updates internally)
        let staleDate = now.addingTimeInterval(TimeInterval(remainingSeconds + 10)) // Timer duration + buffer
        
        // Initialize state tracking for this new activity
        self.lastRunningState = isRunning
        
        // 🔔 CRITICAL FIX: Schedule notification IMMEDIATELY when timer starts
        // This ensures the notification will fire even if app is killed after 30 seconds
        // ALWAYS schedule notification if timer is running, regardless of remaining time
        if isRunning && remainingSeconds > 0 {
            Logger.shared.debug("Scheduling notification for timer completion with \(remainingSeconds)s remaining", category: .general)
            
            // APPLE WATCH FIX: Dual notification strategy
            // 1. Watch display notification (NO SOUND) - for UI info only
            // 2. Timer completion handled by BackgroundAudioManager for precise audio timing

            let baseId = "gymbro_timer_\(Date().timeIntervalSince1970)"
            let watchNotificationId = "watch_display_\(baseId)"

            // CRITICAL FIX: Don't schedule Apple Watch notification that conflicts with completion notification
            // The Apple Watch will receive the completion notification from Flutter
            // This prevents the "rest in progress" message from appearing when timer finishes
            Logger.shared.debug("""
                ⏭️ [WATCH-FIX] SKIPPING Apple Watch notification to prevent conflicts:
                - Would have shown: "Timer: \(remainingSeconds)s rest in progress..."
                - This was causing incorrect notification at completion
                - Apple Watch will receive proper completion notification from Flutter
                """, category: .general)
            
            // No notification scheduled - clear ID to prevent confusion
            self.scheduledNotificationId = nil
            Logger.shared.debug("""
                ✅ [WATCH-FIX] Clean notification strategy implemented:
                - No conflicting Apple Watch notification scheduled
                - Timer completion handled by Flutter with proper localization
                - Prevents "rest in progress" message at completion
                - Short timer warning: \(remainingSeconds <= 5 ? "YES - \(remainingSeconds)s" : "NO")
                """, category: .general)
            
            // Set up debug logging for when notification should fire (only once)
            // CRITICAL FIX: Thread-safe completion log management
            activityQueue.sync {
                completionLogWorkItem?.cancel()

                let workItem = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }  // Early return if deallocated

                    Logger.shared.debug("""
                        ⏰ [TIMER-DEBUG] LIVE ACTIVITY TIMER SHOULD BE COMPLETE NOW:
                        - Notification ID: \(watchNotificationId)
                        - Expected sound: \(soundName)
                        - Time: \(Date())
                        - App State: \(UIApplication.shared.applicationState == .active ? "Active" : UIApplication.shared.applicationState == .background ? "Background" : "Inactive")
                        """, category: .general)

                    // MEMORY FIX: Weak self in nested closure to prevent retain cycle
                    self.activityQueue.async { [weak self] in
                        self?.completionLogWorkItem = nil
                    }
                }

                completionLogWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(remainingSeconds), execute: workItem)
            }
        }
        
        let initialContentState = GymBroTimerAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            totalSeconds: totalSeconds,
            isRunning: isRunning,
            currentSet: currentSet,
            totalSets: totalSets,
            lastUpdated: Date(timeIntervalSince1970: Double(lastUpdated) / 1000.0),
            endDate: endDate,
            startDate: startDate
        )
        
        do {
            // Start the activity
            let activity = try Activity<GymBroTimerAttributes>.request(
                attributes: attributes,
                content: ActivityContent<GymBroTimerAttributes.ContentState>(
                    state: initialContentState,
                    staleDate: staleDate // ✅ React Native Method: Use staleDate for iOS
                ),
                pushType: nil
            )
            
            self.currentActivity = activity
            
            // APPLE WATCH FIX: BackgroundAudioManager handles REAL timer completion with sound
            if isRunning {
                // BackgroundAudioManager will handle the actual timer completion and audio playback
                // This ensures audio plays at EXACTLY 00:00, not when Watch notification is dismissed
                BackgroundAudioManager.shared.scheduleTimerAudio(
                    duration: TimeInterval(remainingSeconds),
                    soundName: soundName,
                    skipNotification: false  // Let BackgroundAudioManager handle its own notification for audio
                )

                Logger.shared.debug("""
                    🎵 [WATCH-FIX] BackgroundAudioManager handling timer completion:
                    - Timer duration: \(remainingSeconds)s
                    - Sound: \(soundName)
                    - Silent loop: ACTIVE (for timers > 30s)
                    - Will trigger audio at EXACTLY 00:00 (not on Watch dismissal)
                    - Watch notification is SILENT display only
                    """, category: .audioSession)
            }
            
            result(activity.id)
            
            Logger.shared.debug( "✅ Live Activity created successfully with ID: \(activity.id)", category: .general)
            
        } catch {
            // ✅ Enhanced error handling with diagnostic information
            let nsError = error as NSError
            let errorDescription = error.localizedDescription

            // Check for specific error conditions
            var errorCode = "START_FAILED"
            var errorMessage = "Failed to start Live Activity: \(errorDescription)"

            // ✅ Handle "visibility" error specifically (iOS 17+)
            // This error occurs when:
            // - The app hasn't been used recently (iOS requires recent app interaction)
            // - Live Activities are rate-limited
            // - The user has restricted Live Activity permissions in Settings
            if errorDescription.lowercased().contains("visibility") {
                errorCode = "VISIBILITY_RESTRICTED"
                errorMessage = """
                    Live Activity creation failed due to visibility restrictions.
                    This can happen when:
                    - The app hasn't been used recently
                    - iOS is rate-limiting Live Activities
                    - User has restricted permissions
                    Original error: \(errorDescription)
                    """

                Logger.shared.log(.warning, """
                    ⚠️ [VISIBILITY-ERROR] Live Activity visibility restriction detected:
                    - Error: \(errorDescription)
                    - NSError Code: \(nsError.code)
                    - NSError Domain: \(nsError.domain)
                    - This is often a temporary iOS restriction
                    - Timer will work but without Live Activity display
                    """, category: .general)
            } else {
                Logger.shared.log(.error, """
                    ❌ Failed to create Live Activity:
                    - Error: \(errorDescription)
                    - NSError Code: \(nsError.code)
                    - NSError Domain: \(nsError.domain)
                    """, category: .general)
            }

            result(FlutterError(
                code: errorCode,
                message: errorMessage,
                details: [
                    "nsErrorCode": nsError.code,
                    "nsErrorDomain": nsError.domain,
                    "areActivitiesEnabled": ActivityAuthorizationInfo().areActivitiesEnabled
                ]
            ))
        }
    }
    
    private func updateLiveActivity(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let activityId = args["activityId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing activityId", details: nil))
            return
        }
        
        // Find the activity by ID
        let activity = Activity<GymBroTimerAttributes>.activities.first { $0.id == activityId }
        
        guard let activity = activity else {
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "Activity not found", details: nil))
            return
        }
        
        // Extract update parameters
        guard let remainingSeconds = args["remainingSeconds"] as? Int,
              let totalSeconds = args["totalSeconds"] as? Int,
              let isRunning = args["isRunning"] as? Bool,
              let currentSet = args["currentSet"] as? Int,
              let totalSets = args["totalSets"] as? Int,
              let lastUpdated = args["lastUpdated"] as? Int64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required parameters", details: nil))
            return
        }

        // CRITICAL FIX: Handle timer completion case
        if remainingSeconds == 0 {
            Logger.shared.debug("""
                ⏰ [TIMER-COMPLETION] Timer completed - ending Live Activity instead of updating
                - Timer finished with 0 seconds remaining
                - Ending Live Activity to prevent validation errors
                - Activity ID: \(activityId)
                """, category: .general)

            // End the Live Activity instead of updating it
            activityQueue.async { [weak self] in
                Task {
                    let finalState = GymBroTimerAttributes.ContentState(
                        remainingSeconds: 0,
                        totalSeconds: totalSeconds,
                        isRunning: false,
                        currentSet: currentSet,
                        totalSets: totalSets,
                        lastUpdated: Date(timeIntervalSince1970: Double(lastUpdated) / 1000.0),
                        endDate: nil,
                        startDate: nil
                    )
                    await activity.end(
                        ActivityContent(
                            state: finalState,
                            staleDate: .now.addingTimeInterval(30)
                        ),
                        dismissalPolicy: .after(.now.addingTimeInterval(30))
                    )

                    // Clean up state
                    DispatchQueue.main.async {
                        self?.currentActivity = nil
                        self?.scheduledNotificationId = nil
                        Logger.shared.debug( "✅ Live Activity ended due to timer completion", category: .general)
                        result(["status": "completed_and_ended"])
                    }
                }
            }
            return
        }

        // CRITICAL FIX: Validate update parameters to prevent invalid states (only for non-completion updates)
        let validationError = validateTimerState(
            exerciseName: activity.attributes.exerciseName,
            timerType: activity.attributes.timerType,
            totalSeconds: totalSeconds,
            remainingSeconds: remainingSeconds,
            isRunning: isRunning,
            currentSet: currentSet,
            totalSets: totalSets
        )

        if let error = validationError {
            Logger.shared.log(.error, "❌ Live Activity update validation failed: \(error)", category: .general)
            result(FlutterError(code: "INVALID_UPDATE_STATE", message: error, details: nil))
            return
        }
        
        let soundName = args["soundName"] as? String ?? "sound"
        
        // Only log every 10 seconds to reduce spam
        if remainingSeconds % 10 == 0 || remainingSeconds <= 5 {
            Logger.shared.log(.debug, "🔄 Live Activity: \(remainingSeconds)s remaining", category: .general)
        }
        
        // 🔔 CRITICAL FIX: Only reschedule notification if timer state changes (pause/resume)
        // DO NOT reschedule on every update - this causes sound to not play on locked devices
        
        // Detect state transitions
        let wasRunning = self.lastRunningState
        let justResumed = !wasRunning && isRunning  // Transition from paused to running
        let justPaused = wasRunning && !isRunning   // Transition from running to paused

        // Update state tracker for next call
        self.lastRunningState = isRunning

        // Handle pause transition - cancel audio scheduling
        if justPaused {
            Logger.shared.debug("""
                ⏸️ [TIMER-DEBUG] Timer paused:
                - Cancelling background audio
                - Cancelling scheduled notifications
                """, category: .general)

            // Cancel background audio when paused
            BackgroundAudioManager.shared.cancelScheduledAudio()

            // Cancel notification if exists
            if let existingId = self.scheduledNotificationId {
                DirectNotificationManager.shared.cancelNotification(identifier: existingId)
                self.scheduledNotificationId = nil
            }
        }

        if isRunning && remainingSeconds > 0 {
            // Check if we need to schedule a new notification
            // Only schedule if:
            // 1. Timer was just resumed (transition from paused to running)
            // 2. No notification is currently scheduled (first start or after cancellation)

            let needsNewNotification = justResumed || self.scheduledNotificationId == nil

            if needsNewNotification {
                Logger.shared.debug("""
                    🔔 [TIMER-DEBUG] Scheduling notification and audio:
                    - Reason: \(justResumed ? "Timer resumed" : "First start (no existing notification)")
                    - Remaining: \(remainingSeconds)s
                    - Sound: \(soundName)
                    - Previous notification: \(self.scheduledNotificationId != nil ? "Will be replaced" : "None")
                    """, category: .general)

                // If we have an existing notification, cancel it first
                if let existingId = self.scheduledNotificationId {
                    DirectNotificationManager.shared.cancelNotification(identifier: existingId)
                    Logger.shared.debug( "🔄 Cancelled previous notification: \(existingId)", category: .general)
                }

                // CRITICAL FIX: Schedule audio through BackgroundAudioManager on FIRST START AND resume
                // This starts the silent loop which keeps the app alive in background
                // Without silent loop, iOS suspends the app and only notification plays (which respects mute!)
                // With silent loop, AVAudioPlayer plays which BYPASSES mute switch!
                if needsNewNotification {
                    BackgroundAudioManager.shared.scheduleTimerAudio(
                        duration: TimeInterval(remainingSeconds),
                        soundName: soundName,
                        skipNotification: true  // Skip notification here - we schedule it directly below with proper tracking
                    )
                    Logger.shared.debug("""
                        🎵 [MUTE-BYPASS] BackgroundAudioManager started for mute switch bypass:
                        - Reason: \(justResumed ? "Timer resumed" : "First start")
                        - Remaining: \(remainingSeconds)s
                        - Sound: \(soundName)
                        - Silent loop: Will keep app alive in background
                        - AVAudioPlayer: Will play sound (bypasses mute switch!)
                        - Notification: Scheduled separately below (for visual + backup)
                        """, category: .audioSession)
                }

                // FIX: Schedule iOS native notification for LOCKSCREEN AUDIO
                // Flutter can't send notifications when app is suspended - iOS notification is REQUIRED!
                Logger.shared.debug("""
                    🔔 [NOTIFICATION-FIX] Scheduling iOS native completion notification:
                    - This is REQUIRED for lockscreen audio when app is suspended
                    - Flutter cannot send notifications from background
                    - iOS notification sound plays even when device is locked
                    """, category: .general)

                // Schedule the notification with the timer sound
                // ✅ FIX: This is now a BACKUP notification with sound
                // Normal flow: Flutter cancels this and sends its own notification when timer completes
                // Fallback: If Flutter fails/crashes, this notification will fire WITH SOUND
                print("📢 [NOTIFICATION-SOURCE-B] 🔶 LiveActivityHandler BACKUP notification:")
                print("   - Source: iOS native (scheduled at timer START)")
                print("   - Fire in: \(remainingSeconds)s")
                print("   - Sound: \(soundName)")
                print("   - Timestamp: \(Date())")
                print("   - ⚠️ This should be CANCELLED by Flutter before it fires!")
                let notificationId = DirectNotificationManager.shared.scheduleTimerNotification(
                    after: TimeInterval(remainingSeconds),
                    soundName: soundName,
                    title: TimerNotificationStrings.timerComplete,
                    body: TimerNotificationStrings.restTimerFinished,
                    silentLoopHandlesAudio: false  // Has sound - backup if Flutter fails
                )
                self.scheduledNotificationId = notificationId

                Logger.shared.debug("""
                    ✅ [TIMER-DEBUG] Notification scheduled for lockscreen audio:
                    - Notification ID: \(notificationId)
                    - Timer duration: \(remainingSeconds)s
                    - Sound: \(soundName)
                    - Completion expected at: \(Date().addingTimeInterval(TimeInterval(remainingSeconds)))
                    """, category: .general)
            } else {
                // Notification already scheduled - DO NOT reschedule
                // This prevents the issue where frequent updates cancel the sound
                Logger.shared.log(.debug, """
                    ⏸️ [TIMER-DEBUG] Keeping existing notification (no reschedule needed):
                    - Existing ID: \(self.scheduledNotificationId ?? "unknown")
                    - Timer still running, notification will fire as scheduled
                    """, category: .general)
            }
            
            if remainingSeconds <= 5 {
                Logger.shared.debug( "   ⚠️ [TIMER-DEBUG] Short timer (\(remainingSeconds)s) - notification will fire soon", category: .general)
            }
            
            // Set up debug logging for when timer completes (only once, not every update)
            // Cancel any existing completion log to prevent duplicates
            completionLogWorkItem?.cancel()

            // Create new work item for completion log
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }  // Early return if deallocated

                Logger.shared.debug("""
                    ⏰ [TIMER-DEBUG] LIVE ACTIVITY UPDATE - Timer should be complete NOW:
                    - Notification ID: \(self.scheduledNotificationId ?? "none")
                    - Expected sound: \(soundName)
                    - Time: \(Date())
                    - App State: \(UIApplication.shared.applicationState == .active ? "Active" : UIApplication.shared.applicationState == .background ? "Background" : "Inactive")
                    """, category: .general)

                // MEMORY FIX: Weak self in nested closure to prevent retain cycle
                self.activityQueue.async { [weak self] in
                    self?.completionLogWorkItem = nil
                }
            }

            completionLogWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(remainingSeconds), execute: workItem)
            
        } else if justPaused, let notificationId = self.scheduledNotificationId {
            // Timer was just paused - cancel the notification
            // SAFETY FIX: Using optional binding instead of force unwrap
            Logger.shared.debug("""
                ⏸️ [TIMER-DEBUG] Timer paused - cancelling notification:
                - Cancelled ID: \(notificationId)
                - Remaining seconds when paused: \(remainingSeconds)
                """, category: .general)
            DirectNotificationManager.shared.cancelNotification(identifier: notificationId)
            self.scheduledNotificationId = nil
        } else if !isRunning {
            // Timer remains paused - no action needed
            Logger.shared.log(.debug, "⏸️ [TIMER-DEBUG] Timer remains paused - no notification changes", category: .general)
        }
        
        // Extract RPE data if present
        let isAwaitingRPE = args["isAwaitingRPE"] as? Bool ?? false
        let targetReps = args["targetReps"] as? Int
        let weight = args["weight"] as? Double
        let actualReps = args["actualReps"] as? Int
        let selectedRPE = args["selectedRPE"] as? Int
        
        // ✅ Native iOS Timer: Precise calculations for smooth countdown
        let now = Date()
        
        // Calculate precise dates for native timer
        let endDate: Date?
        let startDate: Date?
        
        if isRunning {
            // Timer is running - calculate end time from now
            endDate = now.addingTimeInterval(TimeInterval(remainingSeconds))
            // Calculate when timer originally started
            startDate = now.addingTimeInterval(-TimeInterval(totalSeconds - remainingSeconds))
            
            Logger.shared.log(.debug, "🔄 Timer Update - Native iOS Timer Dates:", category: .general)
            Logger.shared.log(.debug, "   Current time: \(now)", category: .general)
            Logger.shared.log(.debug, "   Start date: \(startDate?.description ?? "nil")", category: .general)
            Logger.shared.log(.debug, "   End date: \(endDate?.description ?? "nil")", category: .general)
            Logger.shared.log(.debug, "   Duration: \(totalSeconds)s, Remaining: \(remainingSeconds)s", category: .general)
        } else {
            // Timer is paused - don't use native timer
            endDate = nil
            startDate = nil
            Logger.shared.log(.debug, "🔄 Timer Paused - Using manual countdown", category: .general)
        }
        
        // Create updated content state with native timer
        let updatedContentState = GymBroTimerAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            totalSeconds: totalSeconds,
            isRunning: isRunning,
            currentSet: currentSet,
            totalSets: totalSets,
            lastUpdated: Date(timeIntervalSince1970: Double(lastUpdated) / 1000.0),
            endDate: endDate,
            startDate: startDate,
            isAwaitingRPE: isAwaitingRPE,
            targetReps: targetReps,
            weight: weight,
            actualReps: actualReps,
            selectedRPE: selectedRPE
        )

        // OPTIMIZATION: Smart throttling - check if update should be performed
        let isStateChange = justResumed || justPaused
        let shouldUpdate = shouldUpdateLiveActivity(
            remainingSeconds: remainingSeconds,
            isRunning: isRunning,
            isStateChange: isStateChange
        )

        // If throttled, return early without updating
        if !shouldUpdate {
            Logger.shared.log(.debug, """
                ⚡ [THROTTLE] Skipping Live Activity update to save battery
                - Remaining: \(remainingSeconds)s
                - Battery optimization active
                """, category: .general)
            result(["status": "throttled"])
            return
        }

        // Update is allowed - record this update time for next throttle check
        lastUpdateTime = Date()

        Task {
            // ✅ Native iOS Timer: Longer staleDate for timer-based Live Activities
            let staleDate = isRunning ?
                Date().addingTimeInterval(TimeInterval(remainingSeconds + 10)) : // Timer duration + buffer
                Date().addingTimeInterval(60) // 1 minute for paused state

            await activity.update(
                ActivityContent<GymBroTimerAttributes.ContentState>(
                    state: updatedContentState,
                    staleDate: staleDate
                )
            )

            // Only log every 15 seconds to reduce console spam
            if remainingSeconds % 15 == 0 || remainingSeconds <= 3 {
                Logger.shared.log(.debug, "✅ Live Activity updated (\(remainingSeconds)s)", category: .general)
            }
            result(true)
        }
    }
    
    private func endLiveActivity(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let activityId = args["activityId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing activityId", details: nil))
            return
        }

        // Cancel any pending completion log to prevent orphaned logs
        completionLogWorkItem?.cancel()
        completionLogWorkItem = nil

        let dismissalPolicy = args["dismissalPolicy"] as? String ?? "immediate"
        let cancelNotification = args["cancelNotification"] as? Bool ?? true  // Default to cancelling

        // 🔔 CRITICAL: Cancel scheduled notification AND background audio if timer is stopped manually
        // This prevents notification from firing if user stops timer before completion
        if cancelNotification {
            // Cancel notification
            if let notificationId = self.scheduledNotificationId {
                Logger.shared.debug( "🔕 Cancelling scheduled notification: \(notificationId)", category: .general)
                DirectNotificationManager.shared.cancelNotification(identifier: notificationId)
                self.scheduledNotificationId = nil
            }

            // CRITICAL FIX: Also cancel background audio
            BackgroundAudioManager.shared.cancelScheduledAudio()
            Logger.shared.debug( "🔕 Cancelled background audio for Live Activity", category: .general)
        }
        
        // Find the activity by ID
        let activity = Activity<GymBroTimerAttributes>.activities.first { $0.id == activityId }
        
        guard let activity = activity else {
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "Activity not found", details: nil))
            return
        }
        
        // Create final content state
        let finalContentState = GymBroTimerAttributes.ContentState(
            remainingSeconds: 0,
            totalSeconds: activity.content.state.totalSeconds,
            isRunning: false,
            currentSet: activity.content.state.currentSet,
            totalSets: activity.content.state.totalSets,
            lastUpdated: Date(),
            endDate: nil,
            startDate: nil
        )
        
        Task {
            // IMPROVED: Configurable dismissal policies for better UX
            let policy: ActivityUIDismissalPolicy
            switch dismissalPolicy {
            case "immediate":
                // Remove immediately
                policy = .immediate
            case "after_5s":
                // Remove after 5 seconds (good for completed timers)
                policy = .after(Date().addingTimeInterval(5))
            case "after_30s":
                // Remove after 30 seconds
                policy = .after(Date().addingTimeInterval(30))
            case "default":
                // System decides (usually ~4 hours)
                policy = .default
            default:
                // Default to 5 seconds for completed timers
                policy = .after(Date().addingTimeInterval(5))
            }
            
            Logger.shared.debug( "🏁 Ending Live Activity with policy: \(dismissalPolicy)", category: .general)
            
            await activity.end(
                ActivityContent<GymBroTimerAttributes.ContentState>(
                    state: finalContentState,
                    staleDate: nil as Date?
                ),
                dismissalPolicy: policy
            )
            
            if self.currentActivity?.id == activityId {
                self.currentActivity = nil
            }
            
            result(true)
        }
    }
    
    private func isLiveActivitySupported(result: @escaping FlutterResult) {
        result(ActivityAuthorizationInfo().areActivitiesEnabled)
    }
    
    private func getActiveLiveActivities(result: @escaping FlutterResult) {
        let activityIds = Activity<GymBroTimerAttributes>.activities.map { $0.id }
        result(activityIds)
    }
    
    // MARK: - Timer Completion Handler
    /// Called when timer completes naturally (not stopped manually)
    func handleTimerCompletion() {
        // Clear the scheduled notification ID since it fired
        if let notificationId = self.scheduledNotificationId {
            Logger.shared.debug( "✅ Timer completed - notification \(notificationId) should have fired", category: .general)
            self.scheduledNotificationId = nil
        }
    }
    
    // MARK: - End All Activities (for single timer architecture)
    private func endAllActivities(keepCurrent: Bool = false) async {
        Logger.shared.debug( "🧹 Ending all existing Live Activities (keepCurrent: \(keepCurrent))", category: .general)

        // CRITICAL FIX: Cancel background audio for ALL activities being ended
        // This prevents audio from playing when a new timer starts
        BackgroundAudioManager.shared.cancelScheduledAudio()
        Logger.shared.debug( "🔕 Cancelled background audio for all ending activities", category: .general)

        // Get all timer activities
        let activities = Activity<GymBroTimerAttributes>.activities
        Logger.shared.debug( "📱 Found \(activities.count) active timer activities", category: .general)

        for activity in activities {
            // Skip current activity if requested
            if keepCurrent && activity.id == currentActivity?.id {
                Logger.shared.debug( "⏭️ Skipping current activity: \(activity.id)", category: .general)
                continue
            }

            do {
                // End with immediate dismissal policy
                await activity.end(
                    ActivityContent(
                        state: activity.contentState,
                        staleDate: nil
                    ),
                    dismissalPolicy: .immediate
                )
                Logger.shared.debug( "✅ Ended activity: \(activity.id)", category: .general)

                // Clear current activity reference if this was it
                if activity.id == currentActivity?.id {
                    currentActivity = nil
                }
            } catch {
                Logger.shared.log(.error, "❌ Failed to end activity \(activity.id): \(error)", category: .general)
            }
        }
        
        // Also clean up any RPE activities
        let rpeActivities = Activity<GymBroRPEAttributes>.activities
        if !rpeActivities.isEmpty {
            Logger.shared.debug( "🧹 Cleaning up \(rpeActivities.count) RPE activities", category: .general)
            for activity in rpeActivities {
                do {
                    await activity.end(dismissalPolicy: .immediate)
                    if activity.id == currentRPEActivity?.id {
                        currentRPEActivity = nil
                    }
                } catch {
                    Logger.shared.log(.error, "❌ Failed to end RPE activity: \(error)", category: .general)
                }
            }
        }
    }
    
    // MARK: - ✅ RPE Interactive Live Activities Implementation
    private var currentRPEActivity: Activity<GymBroRPEAttributes>?
    private var methodChannel: FlutterMethodChannel?
    
    private func showRPEInterface(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            result(FlutterError(code: "DISABLED", message: "Live Activities are disabled", details: nil))
            return
        }
        
        guard let args = arguments else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
            return
        }
        
        // Extract RPE parameters
        guard let exerciseName = args["exerciseName"] as? String,
              let targetReps = args["targetReps"] as? Int,
              let weight = args["weight"] as? Double,
              let currentSet = args["currentSet"] as? Int,
              let totalSets = args["totalSets"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required RPE parameters", details: nil))
            return
        }
        
        let workoutName = args["workoutName"] as? String
        
        // Create RPE activity attributes  
        let attributes = GymBroRPEAttributes(
            exerciseName: exerciseName,
            targetReps: targetReps,
            weight: weight,
            currentSet: currentSet,
            totalSets: totalSets,
            workoutName: workoutName
        )
        
        // Create initial RPE content state
        let initialContentState = GymBroRPEAttributes.ContentState(
            repsCompleted: false,
            actualReps: targetReps, // Default
            selectedRPE: nil,
            notes: nil,
            isConfirmed: false,
            lastUpdated: Date()
        )
        
        do {
            // Start RPE Live Activity
            let activity = try Activity<GymBroRPEAttributes>.request(
                attributes: attributes,
                content: ActivityContent<GymBroRPEAttributes.ContentState>(
                    state: initialContentState,
                    staleDate: nil as Date?
                ),
                pushType: nil
            )
            
            self.currentRPEActivity = activity
            result(activity.id)
            
        } catch {
            // ✅ Enhanced error handling for RPE Live Activity
            let nsError = error as NSError
            let errorDescription = error.localizedDescription
            var errorCode = "RPE_START_FAILED"

            if errorDescription.lowercased().contains("visibility") {
                errorCode = "RPE_VISIBILITY_RESTRICTED"
                Logger.shared.log(.warning, "⚠️ [VISIBILITY-ERROR] RPE Live Activity visibility restriction: \(errorDescription)", category: .general)
            } else {
                Logger.shared.log(.error, "❌ Failed to start RPE Live Activity: \(errorDescription)", category: .general)
            }

            result(FlutterError(
                code: errorCode,
                message: "Failed to start RPE Live Activity: \(errorDescription)",
                details: [
                    "nsErrorCode": nsError.code,
                    "nsErrorDomain": nsError.domain
                ]
            ))
        }
    }

    private func updateRPEInterface(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let activityId = args["activityId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing activityId", details: nil))
            return
        }
        
        // Find RPE activity by ID
        let activity = Activity<GymBroRPEAttributes>.activities.first { $0.id == activityId }
        
        guard let activity = activity else {
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "RPE Activity not found", details: nil))
            return
        }
        
        // Extract update parameters
        let repsCompleted = args["repsCompleted"] as? Bool ?? false
        let actualReps = args["actualReps"] as? Int
        let selectedRPE = args["selectedRPE"] as? Int
        let notes = args["notes"] as? String
        
        // Create updated content state
        let updatedContentState = GymBroRPEAttributes.ContentState(
            repsCompleted: repsCompleted,
            actualReps: actualReps ?? activity.content.state.actualReps,
            selectedRPE: selectedRPE,
            notes: notes,
            isConfirmed: false,
            lastUpdated: Date()
        )
        
        Task {
            await activity.update(
                ActivityContent<GymBroRPEAttributes.ContentState>(
                    state: updatedContentState,
                    staleDate: nil as Date?
                )
            )
            result(true)
        }
    }
    
    private func confirmRPEAndCompleteSet(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let activityId = args["activityId"] as? String,
              let actualReps = args["actualReps"] as? Int,
              let rpe = args["rpe"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required confirmation parameters", details: nil))
            return
        }
        
        let notes = args["notes"] as? String
        
        // Find RPE activity by ID
        let activity = Activity<GymBroRPEAttributes>.activities.first { $0.id == activityId }
        
        guard let activity = activity else {
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "RPE Activity not found", details: nil))
            return
        }
        
        // Create final confirmed state
        let confirmedContentState = GymBroRPEAttributes.ContentState(
            repsCompleted: true,
            actualReps: actualReps,
            selectedRPE: rpe,
            notes: notes,
            isConfirmed: true,
            lastUpdated: Date()
        )
        
        Task {
            // Update with confirmed state
            await activity.update(
                ActivityContent<GymBroRPEAttributes.ContentState>(
                    state: confirmedContentState,
                    staleDate: nil as Date?
                )
            )
            
            // Send confirmation back to Flutter
            if let channel = self.methodChannel {
                await MainActor.run {
                    channel.invokeMethod("onRPEConfirmed", arguments: [
                        "actualReps": actualReps,
                        "rpe": rpe,
                        "notes": notes
                    ])
                }
            }
            
            // End activity after a brief display
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                Task {
                    await activity.end(
                        ActivityContent<GymBroRPEAttributes.ContentState>(
                            state: confirmedContentState,
                            staleDate: nil as Date?
                        ),
                        dismissalPolicy: .immediate
                    )
                    
                    if self.currentRPEActivity?.id == activityId {
                        self.currentRPEActivity = nil
                    }
                }
            }
            
            result(true)
        }
    }
    
    private func dismissRPEInterface(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let activityId = args["activityId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing activityId", details: nil))
            return
        }
        
        // Find RPE activity by ID
        let activity = Activity<GymBroRPEAttributes>.activities.first { $0.id == activityId }
        
        guard let activity = activity else {
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "RPE Activity not found", details: nil))
            return
        }
        
        Task {
            // Send cancellation back to Flutter
            if let channel = self.methodChannel {
                await MainActor.run {
                    channel.invokeMethod("onRPECancelled", arguments: nil)
                }
            }
            
            // End activity immediately
            await activity.end(
                ActivityContent<GymBroRPEAttributes.ContentState>(
                    state: activity.content.state,
                    staleDate: nil as Date?
                ),
                dismissalPolicy: .immediate
            )
            
            if self.currentRPEActivity?.id == activityId {
                self.currentRPEActivity = nil
            }
            
            result(true)
        }
    }

    // MARK: - Timer State Validation

    // CRITICAL FIX: Validate timer state to prevent invalid Live Activities
    private func validateTimerState(
        exerciseName: String,
        timerType: String,
        totalSeconds: Int,
        remainingSeconds: Int,
        isRunning: Bool,
        currentSet: Int,
        totalSets: Int
    ) -> String? {

        // Validate exercise name
        if exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Exercise name cannot be empty"
        }

        // Validate timer type
        let validTimerTypes = ["rest", "workout", "interval", "countdown"]
        if !validTimerTypes.contains(timerType.lowercased()) {
            return "Invalid timer type: \(timerType). Must be one of: \(validTimerTypes.joined(separator: ", "))"
        }

        // Validate timer durations
        if totalSeconds <= 0 {
            return "Total seconds must be positive, got: \(totalSeconds)"
        }

        if remainingSeconds < 0 {
            return "Remaining seconds cannot be negative, got: \(remainingSeconds)"
        }

        if remainingSeconds > totalSeconds {
            return "Remaining seconds (\(remainingSeconds)) cannot exceed total seconds (\(totalSeconds))"
        }

        // Validate running state logic
        if isRunning && remainingSeconds == 0 {
            return "Timer cannot be running with 0 remaining seconds"
        }

        if !isRunning && remainingSeconds == totalSeconds {
            Logger.shared.log(.warning, "⚠️ Timer not running but hasn't started yet - this is unusual but allowed", category: .general)
        }

        // Validate set numbers
        if currentSet <= 0 {
            return "Current set must be positive, got: \(currentSet)"
        }

        if totalSets <= 0 {
            return "Total sets must be positive, got: \(totalSets)"
        }

        if currentSet > totalSets {
            return "Current set (\(currentSet)) cannot exceed total sets (\(totalSets))"
        }

        // Validate timer duration limits
        let maxTimerDuration = 7200 // 2 hours max
        let minTimerDuration = 1    // 1 second min

        if totalSeconds > maxTimerDuration {
            return "Timer duration too long: \(totalSeconds)s. Maximum allowed: \(maxTimerDuration)s (2 hours)"
        }

        if totalSeconds < minTimerDuration {
            return "Timer duration too short: \(totalSeconds)s. Minimum allowed: \(minTimerDuration)s"
        }

        // Check for potential timing issues that could cause problems
        if isRunning && remainingSeconds <= 2 {
            Logger.shared.log(.warning, "⚠️ Timer starting with very little time remaining (\(remainingSeconds)s) - this may cause immediate completion", category: .general)
        }

        // All validation passed
        Logger.shared.log(.debug, """
            ✅ Timer state validation passed:
            - Exercise: \(exerciseName)
            - Type: \(timerType)
            - Duration: \(totalSeconds)s (remaining: \(remainingSeconds)s)
            - Running: \(isRunning)
            - Set: \(currentSet)/\(totalSets)
            """, category: .general)

        return nil // No error
    }

    // CRITICAL FIX: Thread-safe cleanup of orphaned activities
    private func cleanupOrphanedActivities() async {
        let allActivities = Activity<GymBroTimerAttributes>.activities

        Logger.shared.debug( "🧹 Cleaning up \(allActivities.count) existing Live Activities", category: .general)

        for activity in allActivities {
            // Check if activity is stale (older than 24 hours)
            let activityAge = Date().timeIntervalSince(activity.content.state.lastUpdated)
            let maxAge: TimeInterval = 24 * 60 * 60 // 24 hours

            if activityAge > maxAge {
                Logger.shared.log(.warning, "🗑️ Ending stale Live Activity (age: \(Int(activityAge/3600))h): \(activity.id)", category: .general)

                await activity.end(
                    ActivityContent<GymBroTimerAttributes.ContentState>(
                        state: activity.content.state,
                        staleDate: Date()
                    ),
                    dismissalPolicy: .immediate
                )
            } else {
                Logger.shared.log(.debug, "✅ Live Activity is recent (age: \(Int(activityAge/60))m): \(activity.id)", category: .general)
            }
        }

        Logger.shared.debug( "✅ Live Activity cleanup completed", category: .general)
    }

    // CRITICAL FIX: Thread-safe activity state cleanup
    private func cleanupActivityState() {
        activityQueue.sync {
            // Cancel any pending work items
            completionLogWorkItem?.cancel()
            completionLogWorkItem = nil

            // Clear notification tracking
            if let notificationId = scheduledNotificationId {
                DirectNotificationManager.shared.cancelNotification(identifier: notificationId)
                scheduledNotificationId = nil
            }

            // Reset state tracking (thread-safe via computed properties)
            _lastRunningState = false
            _lastUpdateTime = nil
        }
    }

    // MARK: - Live Activity Smart Throttling

    /// OPTIMIZATION: Determines if Live Activity should be updated based on smart throttling logic
    ///
    /// Throttling rules:
    /// 1. ALWAYS update on state changes (pause/resume) - immediate feedback critical
    /// 2. If remainingSeconds < 60: Update every second (user is watching closely)
    /// 3. If remainingSeconds >= 60: Throttle to every 5 seconds (battery optimization)
    ///
    /// This reduces battery drain by 50-80% for longer timers while maintaining
    /// smooth UX when user is actively watching the countdown.
    private func shouldUpdateLiveActivity(
        remainingSeconds: Int,
        isRunning: Bool,
        isStateChange: Bool
    ) -> Bool {
        // RULE 1: Always update on state changes (pause/resume)
        // User expects immediate feedback when they interact with the timer
        if isStateChange {
            Logger.shared.log(.debug, "✅ [THROTTLE] Update allowed: State change detected", category: .general)
            return true
        }

        // RULE 2: Always update when timer is at 0 (completion)
        if remainingSeconds == 0 {
            Logger.shared.log(.debug, "✅ [THROTTLE] Update allowed: Timer completion", category: .general)
            return true
        }

        // RULE 3: Under 60 seconds - update every second
        // User is likely watching the timer closely, wants smooth countdown
        if remainingSeconds < 60 {
            Logger.shared.log(.debug, """
                ✅ [THROTTLE] Update allowed: Timer < 60s (\(remainingSeconds)s)
                - User is likely watching, updating every second for smooth UX
                """, category: .general)
            return true
        }

        // RULE 4: Over 60 seconds - throttle to every 5 seconds for battery efficiency
        // User has likely put phone in standby or is doing other things
        if let lastUpdate = lastUpdateTime {
            let timeSinceLastUpdate = Date().timeIntervalSince(lastUpdate)

            if timeSinceLastUpdate < updateThrottleInterval {
                // Not enough time has passed, throttle this update
                Logger.shared.log(.debug, """
                    ⚡ [THROTTLE] Update throttled: Timer >= 60s (\(remainingSeconds)s)
                    - Time since last: \(String(format: "%.1f", timeSinceLastUpdate))s
                    - Threshold: \(updateThrottleInterval)s
                    - Battery optimization active
                    """, category: .general)
                return false
            }
        }

        // Enough time has passed OR this is the first update, allow it
        Logger.shared.log(.debug, """
            ✅ [THROTTLE] Update allowed: Timer >= 60s (\(remainingSeconds)s)
            - Throttle interval passed (\(updateThrottleInterval)s)
            - Battery-optimized update frequency
            """, category: .general)
        return true
    }

    // MARK: - ✅ Schedule Countdown Live Activities Implementation
    private var currentScheduleActivity: Activity<GymBroScheduleAttributes>?

    /// Start a schedule countdown Live Activity
    func startScheduleLiveActivity(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            result(FlutterError(code: "DISABLED", message: "Live Activities are disabled", details: nil))
            return
        }

        guard let args = arguments else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
            return
        }

        // Extract schedule parameters
        guard let workoutName = args["workoutName"] as? String,
              let workoutId = args["workoutId"] as? String,
              let scheduledTimestamp = args["scheduledTimestamp"] as? Int64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required schedule parameters", details: nil))
            return
        }

        let reminderTimestamp = args["reminderTimestamp"] as? Int64

        // Convert timestamps to dates
        let scheduledDate = Date(timeIntervalSince1970: Double(scheduledTimestamp) / 1000.0)
        let reminderTime = reminderTimestamp != nil ?
            Date(timeIntervalSince1970: Double(reminderTimestamp!) / 1000.0) : nil

        // Calculate remaining minutes
        let remainingMinutes = max(0, Int(scheduledDate.timeIntervalSinceNow / 60.0))
        let isStartingSoon = remainingMinutes <= 30

        Logger.shared.debug("""
            📅 [SCHEDULE-LA] Starting Schedule Live Activity:
            - Workout: \(workoutName)
            - Scheduled: \(scheduledDate)
            - Remaining: \(remainingMinutes) minutes
            - Starting soon: \(isStartingSoon)
            """, category: .general)

        // End any existing schedule activity first
        Task {
            if let existingActivity = currentScheduleActivity {
                await existingActivity.end(dismissalPolicy: .immediate)
                currentScheduleActivity = nil
                Logger.shared.debug("🧹 Ended existing schedule Live Activity", category: .general)
            }

            // Create schedule activity attributes
            let attributes = GymBroScheduleAttributes(
                workoutName: workoutName,
                workoutId: workoutId,
                reminderTime: reminderTime
            )

            // Create initial content state
            let initialContentState = GymBroScheduleAttributes.ContentState(
                scheduledDate: scheduledDate,
                remainingMinutes: remainingMinutes,
                isStartingSoon: isStartingSoon,
                lastUpdated: Date()
            )

            do {
                // Start the schedule activity
                let activity = try Activity<GymBroScheduleAttributes>.request(
                    attributes: attributes,
                    content: ActivityContent<GymBroScheduleAttributes.ContentState>(
                        state: initialContentState,
                        staleDate: scheduledDate.addingTimeInterval(300) // Stale 5 min after scheduled time
                    ),
                    pushType: nil
                )

                self.currentScheduleActivity = activity
                Logger.shared.debug("✅ Schedule Live Activity created: \(activity.id)", category: .general)
                result(activity.id)

            } catch {
                // ✅ Enhanced error handling for Schedule Live Activity
                let nsError = error as NSError
                let errorDescription = error.localizedDescription
                var errorCode = "SCHEDULE_LA_START_FAILED"

                if errorDescription.lowercased().contains("visibility") {
                    errorCode = "SCHEDULE_VISIBILITY_RESTRICTED"
                    Logger.shared.log(.warning, "⚠️ [VISIBILITY-ERROR] Schedule Live Activity visibility restriction: \(errorDescription)", category: .general)
                } else {
                    Logger.shared.log(.error, "❌ Failed to create Schedule Live Activity: \(errorDescription)", category: .general)
                }

                result(FlutterError(
                    code: errorCode,
                    message: "Failed to start Schedule Live Activity: \(errorDescription)",
                    details: [
                        "nsErrorCode": nsError.code,
                        "nsErrorDomain": nsError.domain
                    ]
                ))
            }
        }
    }

    /// Update a schedule countdown Live Activity
    func updateScheduleLiveActivity(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let activityId = args["activityId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing activityId", details: nil))
            return
        }

        // Find schedule activity by ID
        let activity = Activity<GymBroScheduleAttributes>.activities.first { $0.id == activityId }

        guard let activity = activity else {
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "Schedule Activity not found", details: nil))
            return
        }

        // Extract update parameters
        guard let scheduledTimestamp = args["scheduledTimestamp"] as? Int64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing scheduledTimestamp", details: nil))
            return
        }

        let scheduledDate = Date(timeIntervalSince1970: Double(scheduledTimestamp) / 1000.0)
        let remainingMinutes = max(0, Int(scheduledDate.timeIntervalSinceNow / 60.0))
        let isStartingSoon = remainingMinutes <= 30

        // Create updated content state
        let updatedContentState = GymBroScheduleAttributes.ContentState(
            scheduledDate: scheduledDate,
            remainingMinutes: remainingMinutes,
            isStartingSoon: isStartingSoon,
            lastUpdated: Date()
        )

        Task {
            await activity.update(
                ActivityContent<GymBroScheduleAttributes.ContentState>(
                    state: updatedContentState,
                    staleDate: scheduledDate.addingTimeInterval(300)
                )
            )

            Logger.shared.log(.debug, "✅ Schedule Live Activity updated: \(remainingMinutes)m remaining", category: .general)
            result(true)
        }
    }

    /// End a schedule countdown Live Activity
    func endScheduleLiveActivity(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let activityId = args["activityId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing activityId", details: nil))
            return
        }

        let dismissPolicy = args["dismissPolicy"] as? String ?? "immediate"

        // Find schedule activity by ID
        let activity = Activity<GymBroScheduleAttributes>.activities.first { $0.id == activityId }

        guard let activity = activity else {
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "Schedule Activity not found", details: nil))
            return
        }

        Task {
            let policy: ActivityUIDismissalPolicy
            switch dismissPolicy {
            case "immediate":
                policy = .immediate
            case "after_5s":
                policy = .after(Date().addingTimeInterval(5))
            case "after_30s":
                policy = .after(Date().addingTimeInterval(30))
            default:
                policy = .immediate
            }

            await activity.end(
                ActivityContent<GymBroScheduleAttributes.ContentState>(
                    state: activity.content.state,
                    staleDate: nil
                ),
                dismissalPolicy: policy
            )

            if self.currentScheduleActivity?.id == activityId {
                self.currentScheduleActivity = nil
            }

            Logger.shared.debug("✅ Schedule Live Activity ended: \(activityId)", category: .general)
            result(true)
        }
    }

    /// End all schedule Live Activities
    func endAllScheduleLiveActivities(result: @escaping FlutterResult) {
        Task {
            let activities = Activity<GymBroScheduleAttributes>.activities

            if activities.isEmpty {
                Logger.shared.debug("✅ No schedule Live Activities to end", category: .general)
                result(true)
                return
            }

            Logger.shared.debug("🧹 Ending \(activities.count) schedule Live Activities", category: .general)

            for activity in activities {
                await activity.end(dismissalPolicy: .immediate)
            }

            currentScheduleActivity = nil
            Logger.shared.debug("✅ All schedule Live Activities ended", category: .general)
            result(true)
        }
    }

    /// Get active schedule Live Activities
    func getActiveScheduleLiveActivities(result: @escaping FlutterResult) {
        let activityIds = Activity<GymBroScheduleAttributes>.activities.map { $0.id }
        result(activityIds)
    }
}