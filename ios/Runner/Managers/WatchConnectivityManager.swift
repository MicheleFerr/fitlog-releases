import Foundation
import WatchConnectivity
import Flutter

/// Manages bidirectional communication between iPhone and Apple Watch
/// Handles template sync, workout data transfer, and real-time state updates
final class WatchConnectivityManager: NSObject {

    // MARK: - Singleton
    static let shared = WatchConnectivityManager()

    // MARK: - Properties
    private var session: WCSession?
    private var methodChannel: FlutterMethodChannel?
    private let channelName = "com.gymbro/watch_connectivity"

    // State tracking
    private var isSessionActivated = false
    private let stateQueue = DispatchQueue(label: "com.gymbro.watch.state", attributes: .concurrent)

    // ✅ Cache current workout state for Watch requests
    // Updated when workout starts/updates, cleared when workout ends
    private var currentWorkoutState: [String: Any]?
    private var currentRestTimerState: [String: Any]?

    // MARK: - Initialization
    private override init() {
        super.init()

        // WatchConnectivityManager initialized
    }

    // MARK: - Flutter Channel Setup
    func setupChannel(with messenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: messenger
        )

        methodChannel?.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call, result: result)
        }

        // Activate WCSession if supported
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()

            // 🔍 DEBUG: Print detailed status on activation
            print("⌚ [WATCH DEBUG] ========================================")
            print("⌚ [WATCH DEBUG] WCSession.isSupported: true")
            print("⌚ [WATCH DEBUG] Activating session...")
            print("⌚ [WATCH DEBUG] ========================================")

            Logger.shared.log(.info, "WatchConnectivity session activated", category: .general)
        } else {
            print("⌚ [WATCH DEBUG] ❌ WCSession NOT SUPPORTED on this device")
            Logger.shared.log(.warning, "WatchConnectivity not supported on this device", category: .general)
        }

        // WatchConnectivityManager channel configured
    }

    // MARK: - Method Call Handling
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Logger.shared.log(.debug, "Watch method: \(call.method)", category: .general)

        switch call.method {
        // Legacy API (for existing Dart code)
        case "checkWatchStatus":
            handleCheckWatchStatus(result: result)

        case "sendTemplatesToWatch":
            handleSendTemplatesToWatch(call.arguments, result: result)

        case "openWatchSettings":
            handleOpenWatchSettings(result: result)

        // New API (for future use)
        case "isWatchPaired":
            handleIsWatchPaired(result: result)

        case "isWatchAppInstalled":
            handleIsWatchAppInstalled(result: result)

        case "isWatchReachable":
            handleIsWatchReachable(result: result)

        case "sendTemplates":
            handleSendTemplates(call.arguments, result: result)

        case "sendMessage":
            handleSendMessage(call.arguments, result: result)

        case "updateApplicationContext":
            handleUpdateApplicationContext(call.arguments, result: result)

        // Workout companion API
        case "notifyWorkoutStarted":
            handleNotifyWorkoutStarted(call.arguments, result: result)

        case "notifyWorkoutEnded":
            handleNotifyWorkoutEnded(result: result)

        case "sendWorkoutUpdate":
            handleSendWorkoutUpdate(call.arguments, result: result)

        case "sendRestTimerStarted":
            handleSendRestTimerStarted(call.arguments, result: result)

        case "sendRestTimerSkipped":
            handleSendRestTimerSkipped(result: result)

        case "sendRestTimerPaused":
            handleSendRestTimerPaused(call.arguments, result: result)

        case "sendRestTimerResumed":
            handleSendRestTimerResumed(call.arguments, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Legacy API (for existing Dart code)

    /// Handle checkWatchStatus - returns all status in one call
    private func handleCheckWatchStatus(result: @escaping FlutterResult) {
        let isPaired = session?.isPaired ?? false
        let isInstalled = session?.isWatchAppInstalled ?? false
        let isReachable = session?.isReachable ?? false

        result([
            "isPaired": isPaired,
            "isAppInstalled": isInstalled,
            "isReachable": isReachable
        ])

        Logger.shared.log(.info, "Watch status check: paired=\(isPaired), installed=\(isInstalled), reachable=\(isReachable)", category: .general)
    }

    /// Handle sendTemplatesToWatch - accepts templates dict with 'templates' key
    private func handleSendTemplatesToWatch(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let templates = args["templates"] as? [[String: Any]] else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Expected {templates: [[String: Any]]}",
                details: nil
            ))
            return
        }

        let data: [String: Any] = [
            "type": "templatesUpdate",
            "templates": templates,
            "timestamp": Date().timeIntervalSince1970
        ]

        // ✅ FIX: MERGE with existing context to preserve workout and timer state
        do {
            var currentContext = session?.applicationContext ?? [:]
            currentContext["templates"] = data
            try session?.updateApplicationContext(currentContext)
            Logger.shared.log(.info, "✅ Sent \(templates.count) templates to Watch (merged)", category: .general)
            result(true)
        } catch {
            Logger.shared.log(.error, "❌ Failed to send templates: \(error)", category: .general)
            result(FlutterError(
                code: "SEND_ERROR",
                message: error.localizedDescription,
                details: nil
            ))
        }
    }

    /// Handle openWatchSettings - opens iOS Watch app
    private func handleOpenWatchSettings(result: @escaping FlutterResult) {
        // Open iOS Watch app (com.apple.Bridge)
        if let url = URL(string: "bridge://") {
            UIApplication.shared.open(url, options: [:]) { success in
                result(success)
            }
        } else {
            result(false)
        }
    }

    // MARK: - Check Watch Status
    private func handleIsWatchPaired(result: @escaping FlutterResult) {
        let isPaired = session?.isPaired ?? false
        result(isPaired)

        Logger.shared.log(.info, "Watch paired: \(isPaired)", category: .general)
    }

    private func handleIsWatchAppInstalled(result: @escaping FlutterResult) {
        let isInstalled = session?.isWatchAppInstalled ?? false
        result(isInstalled)

        Logger.shared.log(.info, "Watch app installed: \(isInstalled)", category: .general)
    }

    private func handleIsWatchReachable(result: @escaping FlutterResult) {
        let isReachable = session?.isReachable ?? false
        result(isReachable)

        Logger.shared.log(.info, "Watch reachable: \(isReachable)", category: .general)
    }

    // MARK: - Send Templates to Watch
    private func handleSendTemplates(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let templates = arguments as? [[String: Any]] else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Templates must be an array of dictionaries",
                details: nil
            ))
            return
        }

        let data: [String: Any] = [
            "type": "templatesUpdate",
            "templates": templates,
            "timestamp": Date().timeIntervalSince1970
        ]

        // ✅ FIX: MERGE with existing context to preserve workout and timer state
        do {
            var currentContext = session?.applicationContext ?? [:]
            currentContext["templates"] = data
            try session?.updateApplicationContext(currentContext)
            Logger.shared.log(.info, "✅ Sent \(templates.count) templates to Watch (merged)", category: .general)
            result(true)
        } catch {
            Logger.shared.log(.error, "❌ Failed to send templates: \(error)", category: .general)
            result(FlutterError(
                code: "SEND_ERROR",
                message: error.localizedDescription,
                details: nil
            ))
        }
    }

    // MARK: - Send Message to Watch
    private func handleSendMessage(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let data = arguments as? [String: Any] else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Message must be a dictionary",
                details: nil
            ))
            return
        }

        guard let session = session, session.isReachable else {
            Logger.shared.log(.warning, "Watch not reachable, using background transfer", category: .general)

            // Use background transfer if not reachable
            session?.transferUserInfo(data)
            result(["queued": true])
            return
        }

        session.sendMessage(data, replyHandler: { response in
            Logger.shared.log(.info, "✅ Watch replied: \(response)", category: .general)
            result(response)
        }, errorHandler: { error in
            Logger.shared.log(.error, "❌ Watch message failed: \(error)", category: .general)
            result(FlutterError(
                code: "SEND_ERROR",
                message: error.localizedDescription,
                details: nil
            ))
        })
    }

    // MARK: - Update Application Context
    private func handleUpdateApplicationContext(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let data = arguments as? [String: Any] else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Context must be a dictionary",
                details: nil
            ))
            return
        }

        do {
            try session?.updateApplicationContext(data)
            Logger.shared.log(.info, "✅ Updated application context", category: .general)
            result(true)
        } catch {
            Logger.shared.log(.error, "❌ Failed to update context: \(error)", category: .general)
            result(FlutterError(
                code: "CONTEXT_ERROR",
                message: error.localizedDescription,
                details: nil
            ))
        }
    }

    // MARK: - Workout Companion API (iPhone → Watch)

    /// Notify Watch that workout started on iPhone
    /// Uses BOTH sendMessage AND updateApplicationContext for maximum reliability
    private func handleNotifyWorkoutStarted(_ arguments: Any?, result: @escaping FlutterResult) {
        // 🔍 DEBUG: Log entry point
        print("⌚ [DEBUG] handleNotifyWorkoutStarted called")

        guard let data = arguments as? [String: Any] else {
            print("⌚ [DEBUG] ❌ Invalid arguments: \(String(describing: arguments))")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected workout data", details: nil))
            return
        }

        print("⌚ [DEBUG] Data received: \(data)")

        guard let session = session else {
            print("⌚ [DEBUG] ❌ WCSession is nil")
            result(FlutterError(code: "NOT_AVAILABLE", message: "WCSession not available", details: nil))
            return
        }

        // 🔍 DEBUG: Log session state
        print("⌚ [DEBUG] WCSession state:")
        print("   - isPaired: \(session.isPaired)")
        print("   - isWatchAppInstalled: \(session.isWatchAppInstalled)")
        print("   - isReachable: \(session.isReachable)")
        print("   - activationState: \(session.activationState.rawValue)")

        let message: [String: Any] = [
            "type": "workoutStarted",
            "isActive": true,
            "exerciseName": data["exerciseName"] as? String ?? "Workout",
            "currentSet": data["currentSet"] as? Int ?? 1,
            "totalSets": data["totalSets"] as? Int ?? 1,
            "targetWeight": data["targetWeight"] as? Double ?? 0,
            "targetReps": data["targetReps"] as? Int ?? 0,
            "setsCompleted": data["setsCompleted"] as? Int ?? 0,
            // RPE/RIR settings for effort tracking on Watch
            "rpeTrackingEnabled": data["rpeTrackingEnabled"] as? Bool ?? false,
            "effortScale": data["effortScale"] as? String ?? "rpe",
            // Locale for Watch UI strings (from Flutter app)
            "locale": data["locale"] as? String ?? "en",
            // ⌚ BUG FIX #3: Time Under Tension (e.g., "3-1-2-0")
            "tut": data["tut"] as? String ?? "",
            "timestamp": Date().timeIntervalSince1970
        ]

        // ✅ Cache workout state for Watch requests
        currentWorkoutState = message

        print("⌚ [DEBUG] Message to send: \(message)")

        // ============================================================
        // STRATEGY: Use BOTH methods for maximum reliability
        // 1. updateApplicationContext - guaranteed delivery when Watch app opens
        // 2. sendMessage - immediate delivery IF Watch app is in foreground
        // ============================================================

        // ALWAYS update application context first (reliable, persistent)
        // ✅ FIX: MERGE with existing context to preserve restTimer and other data
        do {
            var currentContext = session.applicationContext
            currentContext["workout"] = message
            try session.updateApplicationContext(currentContext)
            print("⌚ [DEBUG] ✅ updateApplicationContext succeeded (guaranteed delivery)")
        } catch {
            print("⌚ [DEBUG] ❌ updateApplicationContext failed: \(error)")
        }

        // ALSO try sendMessage for immediate delivery (only works if Watch app is in foreground)
        if session.isReachable {
            print("⌚ [DEBUG] ✅ Watch IS reachable - also sending via sendMessage for immediate delivery")
            session.sendMessage(message, replyHandler: { reply in
                print("⌚ [DEBUG] Watch replied: \(reply)")
            }) { error in
                print("⌚ [DEBUG] ⚠️ sendMessage failed (Watch app may be in background): \(error)")
                // This is expected if Watch app is in background - context update will deliver it
            }
        } else {
            print("⌚ [DEBUG] ⚠️ Watch NOT reachable - relying on applicationContext")
        }

        Logger.shared.log(.info, "🏋️ Notified Watch: workout started (dual delivery)", category: .general)
        result(true)
    }

    /// Notify Watch that workout ended
    /// CRITICAL: Must clear applicationContext to prevent stale state on Watch
    private func handleNotifyWorkoutEnded(result: @escaping FlutterResult) {
        // ✅ Clear cached workout state
        currentWorkoutState = nil
        currentRestTimerState = nil

        guard let session = session else {
            result(true)
            return
        }

        let message: [String: Any] = [
            "type": "workoutEnded",
            "isActive": false,
            "timestamp": Date().timeIntervalSince1970
        ]

        // ✅ FIX: MERGE with existing context to preserve restTimer and other data
        // Update workout state to inactive, but preserve other context keys
        do {
            var currentContext = session.applicationContext
            currentContext["workout"] = message
            // Clear restTimer when workout ends (no longer relevant)
            currentContext.removeValue(forKey: "restTimer")
            try session.updateApplicationContext(currentContext)
            Logger.shared.log(.info, "✅ Updated workout state in applicationContext (workout ended)", category: .general)
        } catch {
            Logger.shared.log(.error, "❌ Failed to update context: \(error)", category: .general)
        }

        // Also send immediate message if reachable for faster UI update
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                Logger.shared.log(.error, "❌ Failed to notify Watch: \(error)", category: .general)
            }
        }

        Logger.shared.log(.info, "🏁 Notified Watch: workout ended (context cleared)", category: .general)
        result(true)
    }

    /// Send workout update (exercise/set changed)
    private func handleSendWorkoutUpdate(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let data = arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected update data", details: nil))
            return
        }

        var message: [String: Any] = ["type": "workoutUpdate"]
        message.merge(data) { _, new in new }
        message["timestamp"] = Date().timeIntervalSince1970

        // Always include RPE settings in updates (Watch needs them for set completion)
        if message["rpeTrackingEnabled"] == nil {
            message["rpeTrackingEnabled"] = data["rpeTrackingEnabled"] as? Bool ?? false
        }
        if message["effortScale"] == nil {
            message["effortScale"] = data["effortScale"] as? String ?? "rpe"
        }
        // Locale for Watch UI strings (from Flutter app)
        if message["locale"] == nil {
            message["locale"] = data["locale"] as? String ?? "en"
        }
        // ⌚ BUG FIX #3: Time Under Tension (e.g., "3-1-2-0")
        if message["tut"] == nil {
            message["tut"] = data["tut"] as? String ?? ""
        }

        // ✅ Update cached workout state for Watch requests
        // Merge new data into existing state to keep full context
        if var existingState = currentWorkoutState {
            existingState.merge(message) { _, new in new }
            existingState["isActive"] = true  // Ensure active flag is set
            currentWorkoutState = existingState
        } else {
            // No existing state, create new with isActive
            message["isActive"] = true
            currentWorkoutState = message
        }

        guard let session = session else {
            result(true)
            return
        }

        // ✅ ALSO update applicationContext for Watch cache (ensures fast recovery on Watch reopen)
        do {
            var currentContext = session.applicationContext
            currentContext["workout"] = currentWorkoutState
            try session.updateApplicationContext(currentContext)
        } catch {
            // Silent fail - sendMessage below will still work if reachable
        }

        // Send immediate update if reachable
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                Logger.shared.log(.debug, "Watch update failed: \(error)", category: .general)
            }
        }

        result(true)
    }

    /// Notify Watch that rest timer started
    /// Uses BOTH applicationContext (reliable) and sendMessage (immediate)
    private func handleSendRestTimerStarted(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let data = arguments as? [String: Any],
              let duration = data["duration"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected duration", details: nil))
            return
        }

        guard let session = session else {
            result(true)
            return
        }

        let startTime = Date().timeIntervalSince1970
        let message: [String: Any] = [
            "type": "restTimerStarted",
            "duration": duration,
            "startTime": startTime,  // For sync: Watch can calculate elapsed time
            "timestamp": startTime
        ]

        // ✅ Cache rest timer state for Watch requests
        currentRestTimerState = message

        // ✅ FIX: MERGE with existing context to preserve workout state
        // This ensures Watch gets the timer even if app was in background
        // AND preserves the workout active state
        do {
            var currentContext = session.applicationContext
            currentContext["restTimer"] = message
            try session.updateApplicationContext(currentContext)
            Logger.shared.log(.info, "✅ Rest timer saved to applicationContext (merged)", category: .general)
        } catch {
            Logger.shared.log(.debug, "Context update failed: \(error)", category: .general)
        }

        // Also send immediate message if reachable for instant UI update
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                Logger.shared.log(.debug, "Rest timer sendMessage failed: \(error)", category: .general)
            }
        }

        Logger.shared.log(.info, "⏱️ Notified Watch: rest timer \(duration)s (dual delivery)", category: .general)
        result(true)
    }

    /// Notify Watch that rest was skipped
    private func handleSendRestTimerSkipped(result: @escaping FlutterResult) {
        // ✅ Clear rest timer cache when skipped
        currentRestTimerState = nil

        guard let session = session, session.isReachable else {
            result(true)
            return
        }

        let message: [String: Any] = [
            "type": "restTimerSkipped",
            "timestamp": Date().timeIntervalSince1970
        ]

        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        result(true)
    }

    /// Notify Watch that rest timer was paused
    private func handleSendRestTimerPaused(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let session = session, session.isReachable else {
            result(true)
            return
        }

        let remainingTime = (arguments as? [String: Any])?["remainingTime"] as? Int ?? 0

        let message: [String: Any] = [
            "type": "restTimerPaused",
            "remainingTime": remainingTime,
            "timestamp": Date().timeIntervalSince1970
        ]

        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        Logger.shared.log(.info, "⏸️ Sent rest timer paused to Watch: \(remainingTime)s remaining", category: .general)
        result(true)
    }

    /// Notify Watch that rest timer was resumed
    private func handleSendRestTimerResumed(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let session = session, session.isReachable else {
            result(true)
            return
        }

        let remainingTime = (arguments as? [String: Any])?["remainingTime"] as? Int ?? 0

        let message: [String: Any] = [
            "type": "restTimerResumed",
            "remainingTime": remainingTime,
            "timestamp": Date().timeIntervalSince1970
        ]

        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        Logger.shared.log(.info, "▶️ Sent rest timer resumed to Watch: \(remainingTime)s remaining", category: .general)
        result(true)
    }

    // MARK: - Notify Flutter
    private func notifyFlutter(event: String, data: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.methodChannel?.invokeMethod(event, arguments: data)
            Logger.shared.log(.debug, "📱 Notified Flutter: \(event)", category: .general)
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        stateQueue.async(flags: .barrier) { [weak self] in
            self?.isSessionActivated = true
        }

        // 🔍 DEBUG: Print full session status
        print("⌚ [WATCH DEBUG] ========================================")
        print("⌚ [WATCH DEBUG] activationDidCompleteWith called")
        print("⌚ [WATCH DEBUG] activationState: \(activationState.rawValue) (0=notActivated, 1=inactive, 2=activated)")
        print("⌚ [WATCH DEBUG] isPaired: \(session.isPaired)")
        print("⌚ [WATCH DEBUG] isWatchAppInstalled: \(session.isWatchAppInstalled)")
        print("⌚ [WATCH DEBUG] isReachable: \(session.isReachable)")
        if let error = error {
            print("⌚ [WATCH DEBUG] ❌ ERROR: \(error.localizedDescription)")
        }
        print("⌚ [WATCH DEBUG] ========================================")

        if let error = error {
            Logger.shared.log(.error, "❌ WCSession activation failed: \(error)", category: .general)
        } else {
            Logger.shared.log(.info, "✅ WCSession activated: \(activationState.rawValue)", category: .general)
        }

        // Notify Flutter about watch state
        notifyFlutter(event: "onWatchStateChanged", data: [
            "isPaired": session.isPaired,
            "isWatchAppInstalled": session.isWatchAppInstalled,
            "isReachable": session.isReachable,
            "activationState": activationState.rawValue
        ])
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        Logger.shared.log(.info, "WCSession became inactive", category: .general)
    }

    func sessionDidDeactivate(_ session: WCSession) {
        Logger.shared.log(.info, "WCSession deactivated - reactivating for watch switching", category: .general)

        // Reactivate session for watch switching support
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        Logger.shared.log(.info, "📡 Watch reachability changed: \(session.isReachable)", category: .general)

        // Notify Flutter about reachability change
        notifyFlutter(event: "onWatchStateChanged", data: [
            "isReachable": session.isReachable,
            "isPaired": session.isPaired,
            "isWatchAppInstalled": session.isWatchAppInstalled
        ])
    }

    // MARK: - Receive Messages from Watch

    /// Handle immediate messages from Watch WITHOUT reply handler
    /// This is called when Watch sends with replyHandler: nil
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any]
    ) {
        guard let type = message["type"] as? String else {
            Logger.shared.log(.warning, "⚠️ Received message without type (no reply)", category: .general)
            return
        }

        Logger.shared.log(.info, "📩 Received Watch message (no reply): \(type)", category: .general)

        switch type {
        case "setCompleted":
            // Extract effort value if present (RPE 6-10 or RIR 0-4)
            let effort = message["effort"] as? Int
            let effortScale = message["effortScale"] as? String ?? "rpe"
            if let effort = effort {
                Logger.shared.log(.info, "✅ Set completed from Watch with \(effortScale.uppercased()): \(effort)", category: .general)
            } else {
                Logger.shared.log(.info, "✅ Set completed from Watch (no effort)", category: .general)
            }
            notifyFlutter(event: "onSetCompletedFromWatch", data: message)

        case "skipRest":
            Logger.shared.log(.info, "⏭️ Rest skipped from Watch (no reply handler)", category: .general)
            notifyFlutter(event: "onSkipRestFromWatch", data: message)

        case "healthMetrics":
            // Real-time HR/calories from Watch
            Logger.shared.log(.debug, "❤️ Health metrics from Watch: HR=\(message["heartRate"] ?? 0)", category: .general)
            notifyFlutter(event: "onHealthMetricsFromWatch", data: message)

        case "endWorkout":
            // Watch requested to end the workout
            Logger.shared.log(.info, "🏁 End workout requested from Watch (no reply handler)", category: .general)
            notifyFlutter(event: "onEndWorkoutFromWatch", data: message)

        case "pauseWorkout":
            // Watch requested to pause the workout
            Logger.shared.log(.info, "⏸️ Pause workout requested from Watch (no reply handler)", category: .general)
            notifyFlutter(event: "onPauseWorkoutFromWatch", data: message)

        case "setModification":
            // Watch modified the next set (weight/reps) via Digital Crown
            Logger.shared.log(.info, "✏️ Set modification from Watch: weight=\(message["weight"] ?? 0), reps=\(message["reps"] ?? 0)", category: .general)
            notifyFlutter(event: "onSetModificationFromWatch", data: message)

        case "extendTimer":
            // Watch requested to extend the rest timer
            Logger.shared.log(.info, "⏱️ Timer extension from Watch: +\(message["seconds"] ?? 0)s", category: .general)
            notifyFlutter(event: "onExtendTimerFromWatch", data: message)

        default:
            Logger.shared.log(.warning, "⚠️ Unknown message type (no reply): \(type)", category: .general)
        }
    }

    /// Handle immediate messages from Watch WITH reply handler
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        guard let type = message["type"] as? String else {
            Logger.shared.log(.warning, "⚠️ Received message without type", category: .general)
            replyHandler(["error": "Missing type"])
            return
        }

        Logger.shared.log(.info, "📩 Received Watch message: \(type)", category: .general)

        switch type {
        case "workoutCompleted":
            handleWorkoutCompleted(message, replyHandler: replyHandler)

        case "setLogged":
            handleSetLogged(message, replyHandler: replyHandler)

        case "requestTemplates":
            handleTemplatesRequest(message, replyHandler: replyHandler)

        case "requestWorkoutState":
            handleWorkoutStateRequest(message, replyHandler: replyHandler)

        case "workoutPaused":
            handleWorkoutPaused(message, replyHandler: replyHandler)

        case "workoutResumed":
            handleWorkoutResumed(message, replyHandler: replyHandler)

        case "setCompleted":
            handleSetCompletedFromWatch(message, replyHandler: replyHandler)

        case "skipRest":
            handleSkipRestFromWatch(message, replyHandler: replyHandler)

        case "endWorkout":
            handleEndWorkoutFromWatch(message, replyHandler: replyHandler)

        case "pauseWorkout":
            handlePauseWorkoutFromWatch(message, replyHandler: replyHandler)

        case "setModification":
            handleSetModificationFromWatch(message, replyHandler: replyHandler)

        case "extendTimer":
            handleExtendTimerFromWatch(message, replyHandler: replyHandler)

        default:
            Logger.shared.log(.warning, "⚠️ Unknown message type: \(type)", category: .general)
            replyHandler(["error": "Unknown message type"])
        }
    }

    /// Handle application context updates from Watch
    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {
        Logger.shared.log(.info, "📦 Received application context from Watch", category: .general)

        // Check for health metrics in the context
        if let healthMetrics = applicationContext["healthMetrics"] as? [String: Any] {
            Logger.shared.log(.info, "❤️ Health metrics from applicationContext: HR=\(healthMetrics["heartRate"] ?? 0)", category: .general)
            notifyFlutter(event: "onHealthMetricsFromWatch", data: healthMetrics)
        }

        // Forward full context to Flutter
        notifyFlutter(event: "onApplicationContextReceived", data: applicationContext)
    }

    /// Handle background transfers from Watch
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String : Any] = [:]
    ) {
        Logger.shared.log(.info, "📦 Received background transfer from Watch", category: .general)

        // Forward to Flutter
        notifyFlutter(event: "onBackgroundDataReceived", data: userInfo)
    }

    // MARK: - Message Handlers

    private func handleWorkoutCompleted(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Logger.shared.log(.info, "🏋️ Workout completed on Watch", category: .general)

        // Notify Flutter about completed workout
        notifyFlutter(event: "onWorkoutReceived", data: message)

        replyHandler(["success": true, "timestamp": Date().timeIntervalSince1970])
    }

    private func handleSetLogged(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Logger.shared.log(.info, "💪 Set logged on Watch", category: .general)

        // Notify Flutter about logged set
        notifyFlutter(event: "onSetLogged", data: message)

        replyHandler(["success": true])
    }

    private func handleTemplatesRequest(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Logger.shared.log(.info, "📋 Watch requested templates", category: .general)

        // Notify Flutter to send templates
        notifyFlutter(event: "onTemplatesRequested", data: [:])

        // Reply will be sent separately via sendTemplates
        replyHandler(["pending": true])
    }

    /// Handle workout state request from Watch
    /// Returns cached workout state immediately for fast response
    private func handleWorkoutStateRequest(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Logger.shared.log(.info, "📱 Watch requested workout state", category: .general)

        // Check if we have a cached workout state
        if let workoutState = currentWorkoutState {
            // We have an active workout - send current state
            var response = workoutState
            response["timestamp"] = Date().timeIntervalSince1970

            // Include rest timer if active
            if let timerState = currentRestTimerState {
                response["restTimer"] = timerState
            }

            Logger.shared.log(.info, "✅ Sending workout state to Watch: isActive=true, exercise=\(response["exerciseName"] ?? "unknown")", category: .general)
            replyHandler(response)
        } else {
            // No active workout
            Logger.shared.log(.info, "✅ Sending workout state to Watch: isActive=false (no active workout)", category: .general)
            replyHandler([
                "isActive": false,
                "timestamp": Date().timeIntervalSince1970
            ])
        }

        // Also notify Flutter in case it needs to update anything
        notifyFlutter(event: "onWorkoutStateRequested", data: message)
    }

    private func handleWorkoutPaused(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Logger.shared.log(.info, "⏸️ Workout paused on Watch", category: .general)

        notifyFlutter(event: "onWorkoutPaused", data: message)
        replyHandler(["success": true])
    }

    private func handleWorkoutResumed(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Logger.shared.log(.info, "▶️ Workout resumed on Watch", category: .general)

        notifyFlutter(event: "onWorkoutResumed", data: message)
        replyHandler(["success": true])
    }

    /// Handle set completion from Watch companion
    private func handleSetCompletedFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        // Extract effort value if present (RPE 6-10 or RIR 0-4)
        let effort = message["effort"] as? Int
        let effortScale = message["effortScale"] as? String ?? "rpe"
        if let effort = effort {
            Logger.shared.log(.info, "✅ Set completed from Watch with \(effortScale.uppercased()): \(effort)", category: .general)
        } else {
            Logger.shared.log(.info, "✅ Set completed from Watch (no effort)", category: .general)
        }

        // Notify Flutter to complete the current set
        notifyFlutter(event: "onSetCompletedFromWatch", data: message)
        replyHandler(["success": true])
    }

    /// Handle skip rest from Watch companion
    private func handleSkipRestFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Logger.shared.log(.info, "⏭️ Rest skipped from Watch", category: .general)

        // Notify Flutter to skip the rest timer
        notifyFlutter(event: "onSkipRestFromWatch", data: message)
        replyHandler(["success": true])
    }

    /// Handle end workout request from Watch companion
    private func handleEndWorkoutFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Logger.shared.log(.info, "🏁 End workout requested from Watch", category: .general)

        // Notify Flutter to end the workout
        notifyFlutter(event: "onEndWorkoutFromWatch", data: message)
        replyHandler(["success": true])
    }

    /// Handle pause workout request from Watch companion
    private func handlePauseWorkoutFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Logger.shared.log(.info, "⏸️ Pause workout requested from Watch", category: .general)

        // Notify Flutter to pause the workout
        notifyFlutter(event: "onPauseWorkoutFromWatch", data: message)
        replyHandler(["success": true])
    }

    /// Handle set modification from Watch (weight/reps edited via Digital Crown)
    private func handleSetModificationFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        let weight = message["weight"] as? Double ?? 0
        let reps = message["reps"] as? Int ?? 0
        Logger.shared.log(.info, "✏️ Set modification from Watch: \(weight)kg × \(reps) reps", category: .general)

        // Notify Flutter to update the next set
        notifyFlutter(event: "onSetModificationFromWatch", data: message)
        replyHandler(["success": true])
    }

    /// Handle timer extension from Watch (Digital Crown to add time)
    private func handleExtendTimerFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        let seconds = message["seconds"] as? Int ?? 0
        Logger.shared.log(.info, "⏱️ Timer extension from Watch: +\(seconds)s", category: .general)

        // Notify Flutter to extend the rest timer
        notifyFlutter(event: "onExtendTimerFromWatch", data: message)
        replyHandler(["success": true])
    }
}

// MARK: - Public Methods

extension WatchConnectivityManager {

    /// Send workout data to Watch (e.g., when starting workout on iPhone)
    func sendWorkoutToWatch(workoutData: [String: Any]) {
        guard let session = session else {
            Logger.shared.log(.error, "❌ WCSession not initialized", category: .general)
            return
        }

        let data: [String: Any] = [
            "type": "workoutStarted",
            "workout": workoutData,
            "timestamp": Date().timeIntervalSince1970
        ]

        if session.isReachable {
            session.sendMessage(data, replyHandler: nil) { error in
                Logger.shared.log(.error, "❌ Failed to send workout: \(error)", category: .general)
            }
        } else {
            // Use application context for background delivery
            // ✅ FIX: MERGE with existing context to preserve restTimer and other data
            do {
                var currentContext = session.applicationContext
                currentContext["workout"] = data
                try session.updateApplicationContext(currentContext)
                Logger.shared.log(.info, "📤 Queued workout for Watch (background, merged)", category: .general)
            } catch {
                Logger.shared.log(.error, "❌ Failed to queue workout: \(error)", category: .general)
            }
        }
    }

    /// Send real-time workout update to Watch
    func sendWorkoutUpdate(updateData: [String: Any]) {
        guard let session = session, session.isReachable else {
            return // Skip if not reachable
        }

        let data: [String: Any] = [
            "type": "workoutUpdate",
            "update": updateData,
            "timestamp": Date().timeIntervalSince1970
        ]

        session.sendMessage(data, replyHandler: nil) { error in
            Logger.shared.log(.debug, "Failed to send update: \(error)", category: .general)
        }
    }

    /// Check if watch is available for communication
    func isWatchAvailable() -> Bool {
        guard let session = session else { return false }
        return session.isPaired && session.isWatchAppInstalled
    }
}
