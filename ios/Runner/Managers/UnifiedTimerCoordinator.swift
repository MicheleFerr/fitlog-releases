import Foundation
import Foundation
import Flutter
import AVFoundation

/// PROBLEM #3 FIX: Unified coordinator for all timer-related iOS channels
/// This centralizes all timer communication to prevent race conditions and duplicates
final class UnifiedTimerCoordinator {
    
    // MARK: - Singleton
    static let shared = UnifiedTimerCoordinator()
    
    // MARK: - Properties
    private var unifiedChannel: FlutterMethodChannel?
    private let channelName = "com.gymbro.timer/unified"
    
    // Managers (only essential ones)
    private let backgroundAudio = BackgroundAudioManager.shared
    private let liveActivityHandler = LiveActivityHandler.shared
    
    // Coordination state
    private var lastAudioTriggerTime: Date?
    private var pendingCompletions: Set<String> = []
    private let coordinationQueue = DispatchQueue(label: "com.gymbro.timer.coordination", attributes: .concurrent)
    
    // Audio session keep-alive
    private var audioSessionActive = false
    private var silentAudioPlayer: AVAudioPlayer?

    // ✅ FIX #3: Background task tracking for emergency saves
    private var activeBackgroundTasks: [String: UIBackgroundTaskIdentifier] = [:]
    
    // MARK: - Initialization
    private init() {
        // UnifiedTimerCoordinator initialized
    }
    
    // MARK: - Flutter Channel Setup
    func setupChannel(with messenger: FlutterBinaryMessenger) {
        unifiedChannel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: messenger
        )
        
        unifiedChannel?.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call, result: result)
        }
        
        // Also setup legacy channels for backward compatibility
        setupLegacyChannels(with: messenger)
        
        // Unified timer channel configured
    }
    
    private func setupLegacyChannels(with messenger: FlutterBinaryMessenger) {
        // Setup ONLY essential channels - no duplicates
        backgroundAudio.setupFlutterChannel(with: messenger)
        
        // Setup LiveActivityHandler channel for iOS 16.1+
        if #available(iOS 16.1, *) {
            liveActivityHandler.setupMethodChannel(with: messenger)
            // LiveActivityHandler channel configured
        } else {
            // LiveActivityHandler skipped - requires iOS 16.1+
        }
        
        // Essential channels configured
    }
    
    // MARK: - Unified Method Handling
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        coordinationQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                result(FlutterError(code: "DISPOSED", message: "Coordinator disposed", details: nil))
                return
            }
            
            // Handle timer operations
            
            switch call.method {
            // Timer Control
            case "startTimer":
                self.handleStartTimer(call.arguments, result: result)
                
            case "pauseTimer":
                self.handlePauseTimer(result: result)
                
            case "resumeTimer":
                self.handleResumeTimer(call.arguments, result: result)
                
            case "stopTimer":
                self.handleStopTimer(result: result)
                
            // Audio Management (centralized to prevent duplicates)
            case "scheduleCompletion":
                self.handleScheduleCompletion(call.arguments, result: result)
                
            case "playCompletionSound":
                self.handlePlayCompletionSound(call.arguments, result: result)
                
            case "hasAudioPlayedRecently":
                self.handleHasAudioPlayedRecently(call.arguments, result: result)
                
            // Live Activity
            case "startLiveActivity":
                self.handleStartLiveActivity(call.arguments, result: result)
                
            case "updateLiveActivity":
                self.handleUpdateLiveActivity(call.arguments, result: result)
                
            case "endLiveActivity":
                self.handleEndLiveActivity(call.arguments, result: result)

            case "endAllActiveLiveActivities":
                self.handleEndAllActiveLiveActivities(result: result)

            case "getActiveLiveActivities":
                self.handleGetActiveLiveActivities(result: result)
                
            // State Query
            case "getTimerState":
                self.handleGetTimerState(result: result)
                
            case "getMetrics":
                self.handleGetMetrics(result: result)

            // CRITICAL FIX: Handle notification sending from Flutter
            case "sendNotification":
                self.handleSendNotification(call.arguments, result: result)

            // CRITICAL FIX: Cancel background audio when timer is skipped
            case "cancelBackgroundAudio":
                self.handleCancelBackgroundAudio(result: result)

            // ✅ FIX #2: Verify notification delivery
            case "wasNotificationDelivered":
                self.handleWasNotificationDelivered(call.arguments, result: result)

            // ✅ FIX #7: Print performance metrics report
            case "printPerformanceMetrics":
                self.handlePrintPerformanceMetrics(result: result)

            // ✅ FIX #3: Background task management for emergency saves
            case "beginBackgroundTask":
                self.handleBeginBackgroundTask(call.arguments, result: result)

            case "endBackgroundTask":
                self.handleEndBackgroundTask(call.arguments, result: result)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // MARK: - Timer Control Methods
    
    private func handleStartTimer(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let duration = args["duration"] as? Double,
              let exerciseName = args["exercise"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing duration or exercise", details: nil))
            return
        }

        // Clear any pending completions
        pendingCompletions.removeAll()

        // ✅ RACE CONDITION FIX: Reset skip flag when a NEW timer starts
        // This allows notifications to be scheduled for this new timer
        // (Previous skip should not block new timer's notifications)
        DirectNotificationManager.shared.resetSkipFlag()

        // CRITICAL: Activate audio session to prevent app suspension
        activateAudioSessionForTimer()

        // Direct timer implementation - no need for separate manager
        result(true)
    }
    
    private func handlePauseTimer(result: @escaping FlutterResult) {
        // Timer paused
        result(true)
    }
    
    private func handleResumeTimer(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let exerciseName = args["exercise"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing exercise name", details: nil))
            return
        }
        
        // Timer resumed
        result(true)
    }
    
    private func handleStopTimer(result: @escaping FlutterResult) {
        backgroundAudio.cancelScheduledAudio()
        pendingCompletions.removeAll()

        // ✅ CRITICAL FIX: Cancel all pending timer notifications
        // This prevents notifications from firing after timer is stopped/skipped
        DirectNotificationManager.shared.cancelAllTimerNotifications()

        // Deactivate audio session when timer stops
        deactivateAudioSession()

        // Timer stopped
        result(true)
    }

    private func handleCancelBackgroundAudio(result: @escaping FlutterResult) {
        // CRITICAL FIX: Cancel only the background audio without stopping the timer
        // This is used when the timer is skipped to prevent audio from playing
        backgroundAudio.cancelScheduledAudio()

        // ✅ CRITICAL FIX: Also cancel pending notifications when timer is skipped
        // This prevents the race condition where notification scheduling completes
        // after the skip command is received
        DirectNotificationManager.shared.cancelAllTimerNotifications()
        print("⏭️ [SKIP] Cancelled background audio AND pending notifications")

        // Background audio cancelled (skip)
        result(true)
    }

    // MARK: - Audio Coordination (CRITICAL for Problem #1)
    
    private func handleScheduleCompletion(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let duration = args["duration"] as? Double else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing duration", details: nil))
            return
        }

        let soundName = args["soundName"] as? String ?? "sound"
        let hasLiveActivity = args["hasLiveActivity"] as? Bool ?? false
        let completionId = UUID().uuidString

        // ✅ RACE CONDITION FIX: Reset skip flag when scheduling a new completion
        // This ensures a previous skip doesn't block this new timer's notification
        DirectNotificationManager.shared.resetSkipFlag()

        // ✅ FIX: Get app state on main thread to avoid Main Thread Checker warning
        let appState = DispatchQueue.main.sync {
            return UIApplication.shared.applicationState
        }
        
        // Track scheduling details
        
        // Track this completion to prevent duplicates
        pendingCompletions.insert(completionId)
        
        // CRITICAL: Activate audio session for timers > 30 seconds
        // This prevents iOS from suspending the app
        if duration > 30.0 && appState != .active {
            activateAudioSessionForTimer()
            // Audio session activated for long timer
        }
        
        // 🔔 CRITICAL: Determine if we should skip notification scheduling
        // If Live Activity is active, it has ALREADY scheduled a notification
        // We MUST skip to prevent duplicate notifications
        let shouldSkipNotification = hasLiveActivity
        
        if shouldSkipNotification {
            // Live Activity active - skip duplicate notification
            // Schedule through BackgroundAudioManager but SKIP notification
            backgroundAudio.scheduleTimerAudio(duration: duration, soundName: soundName, skipNotification: true)
        } else {
            // No Live Activity - schedule notification
            // Schedule through BackgroundAudioManager WITH notification
            backgroundAudio.scheduleTimerAudio(duration: duration, soundName: soundName, skipNotification: false)
        }
        
        // Clean up completion tracking after timer ends
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 5) { [weak self] in
            self?.pendingCompletions.remove(completionId)
        }
        
        // Completion scheduled successfully
        result(completionId)
    }
    
    private func handlePlayCompletionSound(_ arguments: Any?, result: @escaping FlutterResult) {
        // ✅ FIX: Get app state on main thread to avoid Main Thread Checker warning
        let appState = DispatchQueue.main.sync {
            return UIApplication.shared.applicationState
        }
        let soundName = (arguments as? [String: Any])?["soundName"] as? String ?? "sound"

        // ✅ FIX #1: Check if BackgroundAudioManager is already handling this
        if backgroundAudio.hasScheduledAudioForCompletion() {
            Logger.shared.log(.info, """
                ⏭️ [AUDIO-FIX] Skipping manual playback:
                - BackgroundAudioManager is active and will handle completion
                - Prevents duplicate audio playback
                - Timer will play sound automatically at 00:00
                """, category: .audioSession)

            result("skipped_scheduled_audio_active")
            return
        }

        // Check for recent playback to prevent duplicates
        if let lastTime = lastAudioTriggerTime,
           Date().timeIntervalSince(lastTime) < 3.0 {
            let timeSince = Date().timeIntervalSince(lastTime)
            Logger.shared.log(.warning, "⚠️ Audio already played \(timeSince)s ago, skipping duplicate", category: .audioSession)
            result("skipped_recent_playback")
            return
        }

        // Mark audio as triggered
        lastAudioTriggerTime = Date()

        // Use TimerSoundFix ONLY if BackgroundAudioManager not active
        TimerSoundFix.shared.playTimerCompletionSound(preferredSound: soundName)

        Logger.shared.log(.info, """
            🔊 [AUDIO-FIX] Manual playback executed:
            - BackgroundAudioManager not active
            - Playing via TimerSoundFix
            - Sound: \(soundName)
            """, category: .audioSession)

        result(true)
    }
    
    private func handleHasAudioPlayedRecently(_ arguments: Any?, result: @escaping FlutterResult) {
        let seconds = (arguments as? [String: Any])?["seconds"] as? Double ?? 3.0
        
        // Check both our tracking and BackgroundAudioManager
        var hasPlayed = false
        
        if let lastTime = lastAudioTriggerTime {
            hasPlayed = Date().timeIntervalSince(lastTime) < seconds
        }
        
        // Also check BackgroundAudioManager
        if !hasPlayed {
            hasPlayed = backgroundAudio.hasAudioPlayedRecently(within: seconds)
        }
        
        result(hasPlayed)
    }
    
    // MARK: - Live Activity Methods
    
    private func handleStartLiveActivity(_ arguments: Any?, result: @escaping FlutterResult) {
        // Live Activity start requested
        
        // Delegate to LiveActivityHandler with iOS 16.1+ check
        if #available(iOS 16.1, *) {
            // Forward the call to LiveActivityHandler using the public method
            liveActivityHandler.startLiveActivityDirectly(arguments as? [String: Any], result: result)
        } else {
            // Live Activities require iOS 16.1+
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Live Activities require iOS 16.1 or later", details: nil))
        }
    }
    
    private func handleUpdateLiveActivity(_ arguments: Any?, result: @escaping FlutterResult) {
        // Live Activity update
        
        if #available(iOS 16.1, *) {
            liveActivityHandler.updateLiveActivityDirectly(arguments as? [String: Any], result: result)
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Live Activities require iOS 16.1 or later", details: nil))
        }
    }
    
    private func handleEndLiveActivity(_ arguments: Any?, result: @escaping FlutterResult) {
        // Live Activity end

        if #available(iOS 16.1, *) {
            liveActivityHandler.endLiveActivityDirectly(arguments as? [String: Any], result: result)
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Live Activities require iOS 16.1 or later", details: nil))
        }
    }

    private func handleEndAllActiveLiveActivities(result: @escaping FlutterResult) {
        // End ALL Live Activities to prevent stacking

        if #available(iOS 16.1, *) {
            liveActivityHandler.endAllActiveLiveActivitiesDirectly(result: result)
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Live Activities require iOS 16.1 or later", details: nil))
        }
    }

    private func handleGetActiveLiveActivities(result: @escaping FlutterResult) {
        // Live Activity query
        
        if #available(iOS 16.1, *) {
            liveActivityHandler.getActiveLiveActivitiesDirectly(result: result)
        } else {
            result([:]) // Return empty dictionary for older iOS versions
        }
    }
    
    // MARK: - Notification Methods

    private func handleSendNotification(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let title = args["title"] as? String,
              let body = args["body"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing notification title or body", details: nil))
            return
        }

        let sound = args["sound"] as? String ?? "sound"
        let categoryIdentifier = args["categoryIdentifier"] as? String ?? "TIMER_COMPLETE"
        let isBackground = args["isBackground"] as? Bool ?? false
        let hasLiveActivity = args["hasLiveActivity"] as? Bool ?? false

        // CRITICAL: Check if we should skip notification due to Live Activity
        let shouldSkipNotification = hasLiveActivity

        if shouldSkipNotification {
            // Live Activity active - skip duplicate notification
            Logger.shared.log(.info, """
                ⏭️ [NOTIFICATION] SKIPPING completion notification:
                - Reason: Live Activity active (hasLiveActivity=true)
                - Live Activity will handle the notification
                - This prevents duplicate notifications
                """, category: .general)

            result("skipped_live_activity")
            return
        }

        // Use DirectNotificationManager for actual notification scheduling
        // ✅ DOUBLE SOUND FIX: When in background, silent loop handles audio via AVAudioPlayer
        // so notification should be silent to avoid double sound
        let notificationId = DirectNotificationManager.shared.scheduleTimerNotification(
            after: 0.1, // Immediate notification
            soundName: sound,
            title: title,
            body: body,
            silentLoopHandlesAudio: isBackground  // Background = silent loop playing sound
        )

        // Notification sent through iOS notification system
        Logger.shared.log(.info, """
            📱 [NOTIFICATION] Timer completion notification sent:
            - Title: \(title)
            - Body: \(body)
            - Sound: \(sound)
            - ID: \(notificationId)
            - Live Activity: \(hasLiveActivity ? "Active (coordinated)" : "None")
            - Localized via Flutter -> iOS bridge
            """, category: .general)

        result(notificationId)
    }

    // ✅ FIX #2: Verify if notification was delivered
    private func handleWasNotificationDelivered(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let identifier = args["identifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing notification identifier", details: nil))
            return
        }

        let wasDelivered = DirectNotificationManager.shared.wasNotificationDelivered(identifier: identifier)

        Logger.shared.log(.info, """
            🔍 [FIX-2] Notification delivery check:
            - ID: \(identifier)
            - Delivered: \(wasDelivered)
            """, category: .general)

        result(wasDelivered)
    }

    // ✅ FIX #7: Print performance metrics report
    private func handlePrintPerformanceMetrics(result: @escaping FlutterResult) {
        Logger.shared.log(.info, "📊 [FIX-7] Printing performance metrics report...", category: .performance)
        // PerformanceMetrics.shared.printReport()
        result(true)
    }

    // MARK: - State Query Methods

    private func handleGetTimerState(result: @escaping FlutterResult) {
        let state: [String: Any] = [
            "isActive": false, // Simplified - managed by Flutter
            "lastUpdate": Date().timeIntervalSince1970
        ]
        result(state)
    }
    
    private func handleGetMetrics(result: @escaping FlutterResult) {
        // ✅ FIX #7: Include performance metrics in response
        // let performanceSummary = PerformanceMetrics.shared.getSummary()
        var performanceData: [String: [String: Any]] = [:]

        // for (operation, aggregated) in performanceSummary {
        //     performanceData[operation] = [
        //         "count": aggregated.count,
        //         "successRate": aggregated.successRate,
        //         "avgDuration": aggregated.avgDuration,
        //         "minDuration": aggregated.minDuration,
        //         "maxDuration": aggregated.maxDuration,
        //         "p95Duration": aggregated.p95Duration
        //     ]
        // }

        let metrics: [String: Any] = [
            "backgroundAudio": backgroundAudio.getDebugStatus(),
            "pendingCompletions": pendingCompletions.count,
            "lastAudioTrigger": lastAudioTriggerTime?.timeIntervalSince1970 ?? 0,
            "unifiedChannelActive": unifiedChannel != nil,
            // ✅ FIX #7: Add performance metrics (disabled - PerformanceMetrics not in Xcode project)
            "performance": performanceData
        ]
        result(metrics)
    }
    
    // MARK: - Public Methods
    
    /// Check if audio should be played (prevents duplicates)
    func shouldPlayAudio() -> Bool {
        if let lastTime = lastAudioTriggerTime,
           Date().timeIntervalSince(lastTime) < 2.0 {
            return false
        }
        return true
    }
    
    /// Mark audio as played
    func markAudioPlayed() {
        lastAudioTriggerTime = Date()
    }
    
    // MARK: - Audio Session Keep-Alive Methods
    
    /// Activate audio session to prevent app suspension (public for LiveActivityHandler)
    func activateAudioSessionForBackground() {
        activateAudioSessionForTimer()
    }
    
    /// Activate audio session to prevent app suspension
    private func activateAudioSessionForTimer() {
        do {
            // ✅ MINIMAL config to avoid OSStatus -50
            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                           mode: .default,
                                                           options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioSessionActive = true
            
            Logger.shared.log(.info, """
                🎵 [AUDIO-SESSION] Activated for timer:
                - Category: playback (keeps app alive)
                - Options: mixWithOthers (doesn't interrupt music)
                - This prevents iOS from suspending the app
                - Bundle resources remain accessible
                """, category: .audioSession)
            
            // Play silent audio to maintain session (optional but more reliable)
            playSilentAudioInBackground()
            
        } catch {
            Logger.shared.log(.error, """
                ❌ [AUDIO-SESSION] Failed to activate: \(error)
                - Timer may not work when device is locked > 30s
                """, category: .audioSession)
        }
    }
    
    /// Play silent audio in background to keep audio session active
    private func playSilentAudioInBackground() {
        // Use the silent_loop.caf file from bundle
        guard let silentAudioPath = Bundle.main.path(forResource: "silent_loop", ofType: "caf"),
              let silentAudioURL = URL(string: "file://\(silentAudioPath)") else {
            Logger.shared.log(.warning, "⚠️ [AUDIO-SESSION] Could not find silent_loop.caf in bundle", category: .audioSession)
            return
        }
        
        do {
            silentAudioPlayer = try AVAudioPlayer(contentsOf: silentAudioURL)
            silentAudioPlayer?.numberOfLoops = -1 // Loop indefinitely
            silentAudioPlayer?.volume = 0.01 // Very low volume (almost silent)
            silentAudioPlayer?.play()
            
            Logger.shared.log(.info, """
                🔇 [AUDIO-SESSION] Silent loop playing:
                - File: silent_loop.caf (from bundle)
                - Keeps audio session active
                - Prevents iOS from suspending app
                - Volume: 0.01 (barely audible)
                - This ensures sound.caf can play when timer ends!
                """, category: .audioSession)
        } catch {
            Logger.shared.log(.error, "❌ [AUDIO-SESSION] Failed to play silent audio: \(error)", category: .audioSession)
        }
    }
    
    
    /// Deactivate audio session when timer completes
    private func deactivateAudioSession() {
        // Stop silent audio
        silentAudioPlayer?.stop()
        silentAudioPlayer = nil

        // Only deactivate if we activated it
        if audioSessionActive {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                audioSessionActive = false

                Logger.shared.log(.info, """
                    🔕 [AUDIO-SESSION] Deactivated:
                    - Timer completed/stopped
                    - Returning control to other apps
                    """, category: .audioSession)
            } catch {
                Logger.shared.log(.error, "❌ [AUDIO-SESSION] Failed to deactivate: \(error)", category: .audioSession)
            }
        }
    }

    // MARK: - ✅ FIX #3: Background Task Management

    /// Begin a background task to extend time for emergency operations
    /// iOS gives apps ~5 seconds by default, background task extends this to ~30 seconds
    private func handleBeginBackgroundTask(_ arguments: Any?, result: @escaping FlutterResult) {
        let taskName = (arguments as? [String: Any])?["name"] as? String ?? "default_task"
        let taskId = UUID().uuidString

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(FlutterError(code: "DISPOSED", message: "Coordinator disposed", details: nil))
                return
            }

            let identifier = UIApplication.shared.beginBackgroundTask(withName: taskName) { [weak self] in
                // Expiration handler - iOS is about to kill us
                Logger.shared.log(.warning, """
                    ⚠️ [BACKGROUND-TASK] Task expiring: \(taskName)
                    - iOS is about to terminate the task
                    - Ending task gracefully
                    """, category: .backgroundTask)

                self?.endBackgroundTask(taskId: taskId)
            }

            if identifier == .invalid {
                Logger.shared.log(.error, """
                    ❌ [BACKGROUND-TASK] Failed to begin task: \(taskName)
                    - iOS rejected the background task request
                    - This may happen if battery is critically low
                    """, category: .backgroundTask)
                result(FlutterError(code: "TASK_FAILED", message: "Could not begin background task", details: nil))
                return
            }

            // Store the task
            self.activeBackgroundTasks[taskId] = identifier

            Logger.shared.log(.info, """
                ✅ [BACKGROUND-TASK] Started: \(taskName)
                - Task ID: \(taskId)
                - iOS identifier: \(identifier.rawValue)
                - Extended time granted (~30 seconds)
                """, category: .backgroundTask)

            result(taskId)
        }
    }

    /// End a background task
    private func handleEndBackgroundTask(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let taskId = args["taskId"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing taskId", details: nil))
            return
        }

        endBackgroundTask(taskId: taskId)
        result(true)
    }

    /// Internal method to end a background task
    private func endBackgroundTask(taskId: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let identifier = self.activeBackgroundTasks.removeValue(forKey: taskId) else {
                Logger.shared.log(.warning, """
                    ⚠️ [BACKGROUND-TASK] Task not found: \(taskId)
                    - May have already expired or been ended
                    """, category: .backgroundTask)
                return
            }

            UIApplication.shared.endBackgroundTask(identifier)

            Logger.shared.log(.info, """
                ✅ [BACKGROUND-TASK] Ended: \(taskId)
                - iOS identifier: \(identifier.rawValue)
                - Task completed successfully
                """, category: .backgroundTask)
        }
    }
}