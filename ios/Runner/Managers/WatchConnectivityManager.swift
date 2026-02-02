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

    // ✅ FIX: Pending critical commands queue for background handling
    // When Flutter is in background, critical commands are saved here and processed on resume
    private static let pendingCommandsKey = "WatchConnectivity_PendingCommands"

    // ✅ Cache current workout state for Watch requests
    // Updated when workout starts/updates, cleared when workout ends
    // ✅ FIX: Now persisted to UserDefaults for crash recovery
    // Using computed properties with backing stores for proper persistence
    private var _currentWorkoutStateStorage: [String: Any]?
    private var _currentRestTimerStateStorage: [String: Any]?

    private var currentWorkoutState: [String: Any]? {
        get { _currentWorkoutStateStorage }
        set {
            _currentWorkoutStateStorage = newValue
            // Persist to UserDefaults for crash recovery
            if let state = newValue {
                // ✅ FIX: Sanitize to remove null values (not valid for property lists)
                let sanitized = sanitizeForPropertyList(state)
                UserDefaults.standard.set(sanitized, forKey: "WatchConnectivity_WorkoutState")
            } else {
                UserDefaults.standard.removeObject(forKey: "WatchConnectivity_WorkoutState")
            }
        }
    }
    private var currentRestTimerState: [String: Any]? {
        get { _currentRestTimerStateStorage }
        set {
            _currentRestTimerStateStorage = newValue
            // Persist to UserDefaults for crash recovery
            if let state = newValue {
                // ✅ FIX: Sanitize to remove null values (not valid for property lists)
                let sanitized = sanitizeForPropertyList(state)
                UserDefaults.standard.set(sanitized, forKey: "WatchConnectivity_RestTimerState")
            } else {
                UserDefaults.standard.removeObject(forKey: "WatchConnectivity_RestTimerState")
            }
        }
    }

    /// Sanitize a dictionary for property list storage
    /// Removes NSNull values and recursively sanitizes nested structures
    private func sanitizeForPropertyList(_ dict: [String: Any]) -> [String: Any] {
        var result = [String: Any]()
        for (key, value) in dict {
            if value is NSNull {
                // Skip null values - not valid for property lists
                continue
            } else if let nestedDict = value as? [String: Any] {
                result[key] = sanitizeForPropertyList(nestedDict)
            } else if let array = value as? [[String: Any]] {
                // Array of dictionaries (like allSets)
                result[key] = array.map { sanitizeForPropertyList($0) }
            } else if let array = value as? [Any] {
                // Generic array - filter out NSNull
                result[key] = array.compactMap { item -> Any? in
                    if item is NSNull { return nil }
                    if let dict = item as? [String: Any] {
                        return sanitizeForPropertyList(dict)
                    }
                    return item
                }
            } else {
                result[key] = value
            }
        }
        return result
    }

    // MARK: - Initialization
    private override init() {
        super.init()

        // ✅ FIX: Restore cached state from UserDefaults for crash recovery
        // This ensures Watch can get current workout state even after iPhone app restart
        restoreCachedState()

        // WatchConnectivityManager initialized
    }

    /// Restore cached workout/timer state from UserDefaults
    /// Called on init to recover state after app crash/kill
    private func restoreCachedState() {
        // Restore workout state
        if let savedWorkoutState = UserDefaults.standard.dictionary(forKey: "WatchConnectivity_WorkoutState") {
            // Check if workout is still active (not stale)
            if let isActive = savedWorkoutState["isActive"] as? Bool, isActive,
               let timestamp = savedWorkoutState["timestamp"] as? TimeInterval {
                let age = Date().timeIntervalSince1970 - timestamp
                let maxAge: TimeInterval = 4 * 60 * 60  // 4 hours max

                if age < maxAge {
                    // State is recent enough, restore it
                    // Use backing store directly to avoid triggering setter (which would re-save)
                    _currentWorkoutStateStorage = savedWorkoutState
                    Logger.shared.log(.info, "✅ Restored workout state from cache (age: \(Int(age))s)", category: .general)
                } else {
                    // Stale state, clear it
                    UserDefaults.standard.removeObject(forKey: "WatchConnectivity_WorkoutState")
                    Logger.shared.log(.info, "🧹 Cleared stale workout state (age: \(Int(age))s)", category: .general)
                }
            }
        }

        // Restore rest timer state (only if workout is active)
        if _currentWorkoutStateStorage != nil,
           let savedTimerState = UserDefaults.standard.dictionary(forKey: "WatchConnectivity_RestTimerState") {
            if let timestamp = savedTimerState["timestamp"] as? TimeInterval {
                let age = Date().timeIntervalSince1970 - timestamp
                let maxAge: TimeInterval = 10 * 60  // 10 minutes max for timer

                if age < maxAge {
                    _currentRestTimerStateStorage = savedTimerState
                    Logger.shared.log(.info, "✅ Restored timer state from cache (age: \(Int(age))s)", category: .general)
                } else {
                    UserDefaults.standard.removeObject(forKey: "WatchConnectivity_RestTimerState")
                }
            }
        }
    }

    // MARK: - Pending Commands Queue (Background Safety)

    /// Save a critical command to pending queue for processing when Flutter resumes
    /// Used when Watch sends commands while iPhone app is in background
    private func savePendingCommand(_ command: [String: Any]) {
        var pending = UserDefaults.standard.array(forKey: Self.pendingCommandsKey) as? [[String: Any]] ?? []
        pending.append(command)
        UserDefaults.standard.set(pending, forKey: Self.pendingCommandsKey)
        Logger.shared.log(.info, "📥 Saved pending command: \(command["type"] ?? "unknown")", category: .general)
    }

    /// Get all pending commands (for Flutter to process on resume)
    private func getPendingCommands() -> [[String: Any]] {
        return UserDefaults.standard.array(forKey: Self.pendingCommandsKey) as? [[String: Any]] ?? []
    }

    /// Clear all pending commands (after Flutter has processed them)
    private func clearPendingCommands() {
        UserDefaults.standard.removeObject(forKey: Self.pendingCommandsKey)
        Logger.shared.log(.info, "🧹 Cleared pending commands queue", category: .general)
    }

    /// Handle Flutter request to check pending commands
    private func handleCheckPendingCommands(result: @escaping FlutterResult) {
        let pending = getPendingCommands()
        Logger.shared.log(.info, "📤 Flutter checking pending commands: \(pending.count) found", category: .general)
        result(pending)
    }

    /// Handle Flutter request to clear pending commands
    private func handleClearPendingCommands(result: @escaping FlutterResult) {
        clearPendingCommands()
        result(true)
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
            handleNotifyWorkoutEnded(call.arguments, result: result)

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

        case "sendRestTimerExtended":
            handleSendRestTimerExtended(call.arguments, result: result)

        // ✅ FIX: Pending commands API for background safety
        case "checkPendingWatchCommands":
            handleCheckPendingCommands(result: result)

        case "clearPendingWatchCommands":
            handleClearPendingCommands(result: result)

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

        // ✅ FIX: Sanitize data to remove NSNull values before sending
        // This prevents WCErrorCodePayloadUnsupportedTypes errors
        let sanitizedData = sanitizeForPropertyList(data)

        guard let session = session, session.isReachable else {
            Logger.shared.log(.warning, "Watch not reachable, using background transfer", category: .general)

            // Use background transfer if not reachable
            session?.transferUserInfo(sanitizedData)
            result(["queued": true])
            return
        }

        session.sendMessage(sanitizedData, replyHandler: { response in
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
            // ✅ FIX: Sanitize data to remove NSNull values before sending
            // This prevents WCErrorCodePayloadUnsupportedTypes errors
            let sanitizedData = sanitizeForPropertyList(data)
            try session?.updateApplicationContext(sanitizedData)
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

    /// Build a workout message with consistent structure for both workoutStarted and workoutUpdate
    /// Centralizes message construction to avoid field duplication and ensure consistency
    /// - Parameters:
    ///   - data: Raw data from Flutter containing workout fields
    ///   - type: Message type ("workoutStarted" or "workoutUpdate")
    /// - Returns: Complete message dictionary ready to send to Watch (sanitized for property list)
    private func buildWorkoutMessage(from data: [String: Any], type: String) -> [String: Any] {
        var message: [String: Any] = ["type": type]

        // ✅ FIX: Sanitize input data from Flutter to remove NSNull values
        // This prevents WCErrorCodePayloadUnsupportedTypes errors
        let sanitizedData = sanitizeForPropertyList(data)

        // Merge sanitized data from Flutter - this ensures new fields are automatically included
        message.merge(sanitizedData) { _, new in new }

        // Set required fields with defaults if not present
        message["isActive"] = message["isActive"] ?? true
        message["timestamp"] = Date().timeIntervalSince1970

        // Ensure critical fields have defaults
        if message["exerciseName"] == nil { message["exerciseName"] = "Workout" }
        if message["currentSet"] == nil { message["currentSet"] = 1 }
        if message["totalSets"] == nil { message["totalSets"] = 1 }
        if message["targetWeight"] == nil { message["targetWeight"] = 0.0 }
        if message["targetReps"] == nil { message["targetReps"] = 0 }
        if message["setsCompleted"] == nil { message["setsCompleted"] = 0 }
        if message["setsCompletedInExercise"] == nil { message["setsCompletedInExercise"] = 0 }
        if message["lastCompletedReps"] == nil { message["lastCompletedReps"] = 0 }
        if message["rpeTrackingEnabled"] == nil { message["rpeTrackingEnabled"] = false }
        if message["effortScale"] == nil { message["effortScale"] = "rpe" }
        if message["locale"] == nil { message["locale"] = "en" }
        if message["formCues"] == nil { message["formCues"] = "" }
        if message["tut"] == nil { message["tut"] = "" }
        if message["workoutType"] == nil { message["workoutType"] = "strength" }
        if message["allSets"] == nil { message["allSets"] = [] as [[String: Any]] }

        // 🔄 Exercise navigation support for Watch
        if message["exerciseNames"] == nil { message["exerciseNames"] = [] as [String] }
        if message["currentExerciseIndex"] == nil { message["currentExerciseIndex"] = 0 }

        return message
    }

    /// Notify Watch that workout started on iPhone
    /// Uses BOTH sendMessage AND updateApplicationContext for maximum reliability
    private func handleNotifyWorkoutStarted(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let data = arguments as? [String: Any] else {
            Logger.shared.log(.error, "⌚ handleNotifyWorkoutStarted: Invalid arguments", category: .general)
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected workout data", details: nil))
            return
        }

        guard let session = session else {
            Logger.shared.log(.error, "⌚ handleNotifyWorkoutStarted: WCSession is nil", category: .general)
            result(FlutterError(code: "NOT_AVAILABLE", message: "WCSession not available", details: nil))
            return
        }

        // ✅ REFACTOR: Use centralized message builder to avoid field duplication
        let message = buildWorkoutMessage(from: data, type: "workoutStarted")

        // Log allSets count for debugging
        if let allSets = message["allSets"] as? [[String: Any]] {
            Logger.shared.log(.debug, "⌚ Sending \(allSets.count) sets to Watch for navigation", category: .general)
        }

        // 🔄 Log exercise navigation data
        if let exerciseNames = message["exerciseNames"] as? [String], !exerciseNames.isEmpty {
            let currentIdx = message["currentExerciseIndex"] as? Int ?? 0
            Logger.shared.log(.debug, "⌚ Sending \(exerciseNames.count) exercises to Watch, current index: \(currentIdx)", category: .general)
        }

        // Cache workout state for Watch requests
        currentWorkoutState = message

        // ============================================================
        // STRATEGY: Use BOTH methods for maximum reliability
        // 1. updateApplicationContext - guaranteed delivery when Watch app opens
        // 2. sendMessage - immediate delivery IF Watch app is in foreground
        // ============================================================

        // ALWAYS update application context first (reliable, persistent)
        // Merge with existing context to preserve restTimer and other data
        do {
            var currentContext = session.applicationContext
            currentContext["workout"] = message
            try session.updateApplicationContext(currentContext)
            Logger.shared.log(.debug, "⌚ updateApplicationContext succeeded", category: .general)
        } catch {
            Logger.shared.log(.error, "⌚ updateApplicationContext failed: \(error)", category: .general)
        }

        // ALSO try sendMessage for immediate delivery (only works if Watch app is in foreground)
        if session.isReachable {
            session.sendMessage(message, replyHandler: { _ in
                Logger.shared.log(.debug, "⌚ Watch replied to workoutStarted", category: .general)
            }) { error in
                // Expected if Watch app is in background - context update will deliver it
                Logger.shared.log(.debug, "⌚ sendMessage failed (Watch may be in background): \(error.localizedDescription)", category: .general)
            }
        }

        Logger.shared.log(.info, "🏋️ Notified Watch: workout started (dual delivery)", category: .general)
        result(true)
    }

    /// Notify Watch that workout ended
    /// CRITICAL: Must clear applicationContext to prevent stale state on Watch
    /// - Parameter arguments: Optional dict with "save" key (default true) to indicate if HKWorkoutSession should be saved
    private func handleNotifyWorkoutEnded(_ arguments: Any?, result: @escaping FlutterResult) {
        // ✅ Clear cached workout state
        currentWorkoutState = nil
        currentRestTimerState = nil

        // ✅ FIX: Extract save parameter (default true for backwards compatibility)
        let args = arguments as? [String: Any]
        let shouldSave = args?["save"] as? Bool ?? true

        guard let session = session else {
            result(true)
            return
        }

        let message: [String: Any] = [
            "type": "workoutEnded",
            "isActive": false,
            "save": shouldSave,  // ✅ FIX: Pass save flag to Watch
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

        // ✅ REFACTOR: Use centralized message builder to avoid field duplication
        let message = buildWorkoutMessage(from: data, type: "workoutUpdate")

        // Update cached workout state for Watch requests
        // Merge new data into existing state to keep full context
        if var existingState = currentWorkoutState {
            existingState.merge(message) { _, new in new }
            currentWorkoutState = existingState
        } else {
            currentWorkoutState = message
        }

        guard let session = session else {
            result(true)
            return
        }

        // Update applicationContext for Watch cache (ensures fast recovery on Watch reopen)
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

        guard let session = session else {
            result(true)
            return
        }

        // ✅ FIX: Also clear restTimer from applicationContext to prevent stale data
        do {
            var currentContext = session.applicationContext
            currentContext.removeValue(forKey: "restTimer")
            try session.updateApplicationContext(currentContext)
            Logger.shared.log(.debug, "⏱️ Cleared restTimer from applicationContext", category: .general)
        } catch {
            Logger.shared.log(.debug, "Failed to clear restTimer from context: \(error)", category: .general)
        }

        // Send immediate message if reachable
        if session.isReachable {
            let message: [String: Any] = [
                "type": "restTimerSkipped",
                "timestamp": Date().timeIntervalSince1970
            ]
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }

        result(true)
    }

    /// Notify Watch that rest timer was paused
    /// Uses BOTH applicationContext (reliable) and sendMessage (immediate)
    private func handleSendRestTimerPaused(_ arguments: Any?, result: @escaping FlutterResult) {
        let remainingTime = (arguments as? [String: Any])?["remainingTime"] as? Int ?? 0

        let message: [String: Any] = [
            "type": "restTimerPaused",
            "remainingTime": remainingTime,
            "timestamp": Date().timeIntervalSince1970
        ]

        // ✅ FIX: Update cached rest timer state with pause info
        if var timerState = currentRestTimerState {
            timerState["isPaused"] = true
            timerState["remainingTime"] = remainingTime
            timerState["timestamp"] = Date().timeIntervalSince1970
            currentRestTimerState = timerState
        }

        guard let session = session else {
            result(true)
            return
        }

        // ✅ FIX: ALWAYS update applicationContext for reliable delivery
        // This ensures Watch gets pause state even if it was in background
        do {
            var currentContext = session.applicationContext
            if var restTimer = currentContext["restTimer"] as? [String: Any] {
                restTimer["isPaused"] = true
                restTimer["remainingTime"] = remainingTime
                restTimer["timestamp"] = Date().timeIntervalSince1970
                currentContext["restTimer"] = restTimer
                try session.updateApplicationContext(currentContext)
                Logger.shared.log(.info, "✅ Rest timer paused saved to applicationContext", category: .general)
            }
        } catch {
            Logger.shared.log(.debug, "Context update failed: \(error)", category: .general)
        }

        // Also send immediate message if reachable
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }

        Logger.shared.log(.info, "⏸️ Sent rest timer paused to Watch: \(remainingTime)s remaining (dual delivery)", category: .general)
        result(true)
    }

    /// Notify Watch that rest timer was resumed
    /// Uses BOTH applicationContext (reliable) and sendMessage (immediate)
    private func handleSendRestTimerResumed(_ arguments: Any?, result: @escaping FlutterResult) {
        let remainingTime = (arguments as? [String: Any])?["remainingTime"] as? Int ?? 0

        let message: [String: Any] = [
            "type": "restTimerResumed",
            "remainingTime": remainingTime,
            "timestamp": Date().timeIntervalSince1970
        ]

        // ✅ FIX: Update cached rest timer state - clear pause flag
        if var timerState = currentRestTimerState {
            timerState["isPaused"] = false
            timerState["remainingTime"] = remainingTime
            // Update startTime for accurate elapsed calculation
            timerState["startTime"] = Date().timeIntervalSince1970
            timerState["duration"] = remainingTime
            timerState["timestamp"] = Date().timeIntervalSince1970
            currentRestTimerState = timerState
        }

        guard let session = session else {
            result(true)
            return
        }

        // ✅ FIX: ALWAYS update applicationContext for reliable delivery
        // This ensures Watch can resume timer even if it was in background
        do {
            var currentContext = session.applicationContext
            // Create new timer context with fresh startTime for accurate sync
            let newTimerContext: [String: Any] = [
                "duration": remainingTime,
                "startTime": Date().timeIntervalSince1970,
                "isPaused": false,
                "timestamp": Date().timeIntervalSince1970
            ]
            currentContext["restTimer"] = newTimerContext
            try session.updateApplicationContext(currentContext)
            Logger.shared.log(.info, "✅ Rest timer resumed saved to applicationContext", category: .general)
        } catch {
            Logger.shared.log(.debug, "Context update failed: \(error)", category: .general)
        }

        // Also send immediate message if reachable
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }

        Logger.shared.log(.info, "▶️ Sent rest timer resumed to Watch: \(remainingTime)s remaining (dual delivery)", category: .general)
        result(true)
    }

    /// Notify Watch that rest timer was extended (+30s from LA or app)
    private func handleSendRestTimerExtended(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let data = arguments as? [String: Any],
              let addedSeconds = data["addedSeconds"] as? Int,
              let newDuration = data["newDuration"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected addedSeconds and newDuration", details: nil))
            return
        }

        guard let session = session else {
            result(true)
            return
        }

        let message: [String: Any] = [
            "type": "restTimerExtended",
            "addedSeconds": addedSeconds,
            "newDuration": newDuration,
            "timestamp": Date().timeIntervalSince1970
        ]

        // Update cached rest timer state
        if var timerState = currentRestTimerState {
            timerState["duration"] = newDuration
            timerState["timestamp"] = Date().timeIntervalSince1970
            currentRestTimerState = timerState
        }

        // Update application context for persistent delivery
        // ✅ FIX: Update startTime to NOW with the NEW remaining duration
        // This ensures Watch calculates correct remaining time even if it receives context late
        do {
            var currentContext = session.applicationContext
            if var restTimer = currentContext["restTimer"] as? [String: Any] {
                let now = Date().timeIntervalSince1970

                // Calculate actual remaining time at this moment
                if let oldStartTime = restTimer["startTime"] as? TimeInterval,
                   let oldDuration = restTimer["duration"] as? Int {
                    let elapsed = Int(now - oldStartTime)
                    let oldRemaining = max(0, oldDuration - elapsed)
                    let newRemaining = oldRemaining + addedSeconds

                    // Reset timer base: startTime = NOW, duration = actual remaining
                    restTimer["startTime"] = now
                    restTimer["duration"] = newRemaining
                    Logger.shared.log(.debug, "⏱️ Timer extended: was \(oldRemaining)s + \(addedSeconds)s = \(newRemaining)s remaining", category: .general)
                } else {
                    // Fallback: just use newDuration with fresh startTime
                    restTimer["startTime"] = now
                    restTimer["duration"] = newDuration
                }

                restTimer["timestamp"] = now
                currentContext["restTimer"] = restTimer
            }
            try session.updateApplicationContext(currentContext)
            Logger.shared.log(.info, "✅ Rest timer extended saved to applicationContext", category: .general)
        } catch {
            Logger.shared.log(.debug, "Context update failed: \(error)", category: .general)
        }

        // Also send immediate message if reachable
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                Logger.shared.log(.debug, "Rest timer extended sendMessage failed: \(error)", category: .general)
            }
        }

        Logger.shared.log(.info, "⏱️ Notified Watch: rest timer extended +\(addedSeconds)s (total: \(newDuration)s)", category: .general)
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

        case "editCompletedSetReps":
            // ✅ Watch wants to edit reps of a SPECIFIC completed set (by index)
            let setIndex = message["setIndex"] as? Int ?? 0
            let reps = message["reps"] as? Int ?? 0
            Logger.shared.log(.info, "✏️ Edit completed set \(setIndex + 1) from Watch: \(reps) reps", category: .general)
            notifyFlutter(event: "onEditCompletedSetRepsFromWatch", data: message)

        case "uncompleteSet":
            // ✅ Watch wants to uncomplete (undo) a completed set
            let setIndex = message["setIndex"] as? Int ?? 0
            Logger.shared.log(.info, "↩️ Uncomplete set \(setIndex + 1) from Watch", category: .general)
            notifyFlutter(event: "onUncompleteSetFromWatch", data: message)

        case "workoutError":
            // ✅ FIX: Handle HKWorkoutSession errors from Watch
            // This is sent when HKWorkoutSession fails unexpectedly on Watch
            let errorMessage = message["message"] as? String ?? "Unknown error"
            Logger.shared.log(.error, "⚠️ Workout error from Watch: \(errorMessage)", category: .general)
            notifyFlutter(event: "onWorkoutErrorFromWatch", data: message)

        case "supersetRoundCompleted":
            // 🔥 SUPERSET: Handle round completion from Watch
            // Watch completes all exercises in a round at once with single RPE
            let roundNumber = message["roundNumber"] as? Int ?? 0
            let effort = message["effort"] as? Int
            let effortScale = message["effortScale"] as? String ?? "rpe"
            if let effort = effort {
                Logger.shared.log(.info, "🔥 Superset round \(roundNumber) completed from Watch with \(effortScale.uppercased()): \(effort)", category: .general)
            } else {
                Logger.shared.log(.info, "🔥 Superset round \(roundNumber) completed from Watch (no effort)", category: .general)
            }
            notifyFlutter(event: "onSupersetRoundCompletedFromWatch", data: message)

        // 🔥 DROPSET: Handle stage and completion from Watch
        case "dropsetStageCompleted":
            let stageIndex = message["stageIndex"] as? Int ?? 0
            let totalStages = message["totalStages"] as? Int ?? 0
            let actualReps = message["actualReps"] as? Int ?? 0
            let effort = message["effort"] as? Int
            let effortScale = message["effortScale"] as? String ?? "rpe"
            if let effort = effort {
                Logger.shared.log(.info, "🔥 Dropset stage \(stageIndex + 1)/\(totalStages) completed from Watch: \(actualReps) reps, \(effortScale.uppercased()): \(effort)", category: .general)
            } else {
                Logger.shared.log(.info, "🔥 Dropset stage \(stageIndex + 1)/\(totalStages) completed from Watch: \(actualReps) reps", category: .general)
            }
            notifyFlutter(event: "onDropsetStageCompletedFromWatch", data: message)

        case "dropsetCompleted":
            let totalStages = message["totalStages"] as? Int ?? 0
            let effort = message["effort"] as? Int
            let effortScale = message["effortScale"] as? String ?? "rpe"
            if let effort = effort {
                Logger.shared.log(.info, "🔥 Dropset completed from Watch (\(totalStages) stages) with \(effortScale.uppercased()): \(effort)", category: .general)
            } else {
                Logger.shared.log(.info, "🔥 Dropset completed from Watch (\(totalStages) stages)", category: .general)
            }
            notifyFlutter(event: "onDropsetCompletedFromWatch", data: message)

        // 🔥 REST-PAUSE: Handle set and completion from Watch
        case "restPauseSetCompleted":
            let setIndex = message["setIndex"] as? Int ?? 0
            let totalSets = message["totalSets"] as? Int ?? 0
            let actualReps = message["actualReps"] as? Int ?? 0
            let weight = message["weight"] as? Double ?? 0
            let effort = message["effort"] as? Int
            let effortScale = message["effortScale"] as? String ?? "rpe"
            if let effort = effort {
                Logger.shared.log(.info, "🔥 Rest-Pause set \(setIndex + 1)/\(totalSets) completed from Watch: \(weight)kg × \(actualReps), \(effortScale.uppercased()): \(effort)", category: .general)
            } else {
                Logger.shared.log(.info, "🔥 Rest-Pause set \(setIndex + 1)/\(totalSets) completed from Watch: \(weight)kg × \(actualReps)", category: .general)
            }
            notifyFlutter(event: "onRestPauseSetCompletedFromWatch", data: message)

        case "restPauseCompleted":
            let totalSets = message["totalSets"] as? Int ?? 0
            let weight = message["weight"] as? Double ?? 0
            let effort = message["effort"] as? Int
            let effortScale = message["effortScale"] as? String ?? "rpe"
            if let effort = effort {
                Logger.shared.log(.info, "🔥 Rest-Pause completed from Watch (\(totalSets) sets, \(weight)kg) with \(effortScale.uppercased()): \(effort)", category: .general)
            } else {
                Logger.shared.log(.info, "🔥 Rest-Pause completed from Watch (\(totalSets) sets, \(weight)kg)", category: .general)
            }
            notifyFlutter(event: "onRestPauseCompletedFromWatch", data: message)

        // MARK: - Navigation & Copy Actions from Watch
        case "jumpToExercise":
            let exerciseIndex = message["exerciseIndex"] as? Int ?? 0
            Logger.shared.log(.info, "↔️ Jump to exercise \(exerciseIndex) from Watch", category: .general)
            notifyFlutter(event: "onJumpToExerciseFromWatch", data: message)

        case "jumpToSet":
            let setNumber = message["setNumber"] as? Int ?? 1
            Logger.shared.log(.info, "↕️ Jump to set \(setNumber) from Watch", category: .general)
            notifyFlutter(event: "onJumpToSetFromWatch", data: message)

        case "copyToAllSets":
            let weight = message["weight"] as? Double ?? 0
            let reps = message["reps"] as? Int ?? 0
            Logger.shared.log(.info, "📄 Copy to all sets from Watch: \(weight)kg × \(reps)", category: .general)
            notifyFlutter(event: "onCopyToAllSetsFromWatch", data: message)

        case "copyFromPreviousSet":
            let currentSetNumber = message["currentSetNumber"] as? Int ?? 1
            Logger.shared.log(.info, "📋 Copy from previous set (current: \(currentSetNumber)) from Watch", category: .general)
            notifyFlutter(event: "onCopyFromPreviousSetFromWatch", data: message)

        case "startNewTimer":
            let duration = message["duration"] as? Int ?? 60
            Logger.shared.log(.info, "⏱️ Start new timer from Watch: \(duration)s", category: .general)
            notifyFlutter(event: "onStartNewTimerFromWatch", data: message)

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

        case "editCompletedSetReps":
            handleEditCompletedSetRepsFromWatch(message, replyHandler: replyHandler)

        case "uncompleteSet":
            handleUncompleteSetFromWatch(message, replyHandler: replyHandler)

        case "supersetRoundCompleted":
            handleSupersetRoundCompletedFromWatch(message, replyHandler: replyHandler)

        // 🔥 DROPSET
        case "dropsetStageCompleted":
            handleDropsetStageCompletedFromWatch(message, replyHandler: replyHandler)

        case "dropsetCompleted":
            handleDropsetCompletedFromWatch(message, replyHandler: replyHandler)

        // 🔥 REST-PAUSE
        case "restPauseSetCompleted":
            handleRestPauseSetCompletedFromWatch(message, replyHandler: replyHandler)

        case "restPauseCompleted":
            handleRestPauseCompletedFromWatch(message, replyHandler: replyHandler)

        // ⏱️ Timer from Watch
        case "startNewTimer":
            handleStartNewTimerFromWatch(message, replyHandler: replyHandler)

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

            // Include rest timer if active AND not expired
            // ✅ FIX: Check if timer has expired to prevent sending stale timer data
            // This fixes the bug where warmup sets received timer from previous working set
            if let timerState = currentRestTimerState,
               let startTime = timerState["startTime"] as? TimeInterval,
               let duration = timerState["duration"] as? Int {
                let now = Date().timeIntervalSince1970
                let expirationTime = startTime + Double(duration)

                if now < expirationTime {
                    // Timer is still active
                    response["restTimer"] = timerState
                    Logger.shared.log(.debug, "⏱️ Including active rest timer (\(Int(expirationTime - now))s remaining)", category: .general)
                } else {
                    // Timer has expired - clear the stale cache
                    currentRestTimerState = nil
                    Logger.shared.log(.debug, "⏱️ Rest timer expired, not including in response", category: .general)
                }
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
    /// ✅ FIX: Returns rest timer data in reply for immediate Watch sync
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
        // Flutter will then start the rest timer which updates currentRestTimerState
        notifyFlutter(event: "onSetCompletedFromWatch", data: message)

        // ✅ FIX: Wait briefly for Flutter to process and start timer,
        // then respond with timer data for immediate Watch sync.
        // This prevents the Watch from waiting for applicationContext (1-5s latency)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            var response: [String: Any] = ["success": true]

            // Include rest timer data if available (Flutter has started the timer)
            if let timerState = self?.currentRestTimerState {
                response["restTimer"] = timerState
                Logger.shared.log(.info, "⏱️ Including rest timer in setCompleted reply: \(timerState["duration"] ?? 0)s", category: .general)
            } else {
                Logger.shared.log(.debug, "⏱️ No rest timer to include in reply (last set or timer disabled)", category: .general)
            }

            replyHandler(response)
        }
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
    /// ✅ FIX: Save pending command BEFORE notifying Flutter to prevent data loss when app is in background
    private func handleEndWorkoutFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Logger.shared.log(.info, "🏁 End workout requested from Watch", category: .general)

        // ✅ FIX: Save as pending command FIRST (before Flutter notification)
        // This ensures the command is persisted even if Flutter engine is suspended
        // When Flutter resumes, it will check for pending commands and process them
        let pendingCommand: [String: Any] = [
            "type": "endWorkout",
            "save": message["save"] as? Bool ?? true,
            "timestamp": Date().timeIntervalSince1970
        ]
        savePendingCommand(pendingCommand)

        // Notify Flutter to end the workout (may or may not be received if app is in background)
        notifyFlutter(event: "onEndWorkoutFromWatch", data: message)

        // ✅ Clear workout state cache since workout is ending
        currentWorkoutState = nil
        currentRestTimerState = nil

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

    /// ✅ Handle edit SPECIFIC completed set reps from Watch (by index)
    private func handleEditCompletedSetRepsFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        let setIndex = message["setIndex"] as? Int ?? 0  // 0-indexed
        let reps = message["reps"] as? Int ?? 0
        Logger.shared.log(.info, "✏️ Edit completed set \(setIndex + 1) from Watch: \(reps) reps", category: .general)

        // Notify Flutter to update the specific completed set
        notifyFlutter(event: "onEditCompletedSetRepsFromWatch", data: message)
        replyHandler(["success": true])
    }

    /// Handle uncomplete set from Watch (undo a completed set)
    private func handleUncompleteSetFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        let setIndex = message["setIndex"] as? Int ?? 0  // 0-indexed
        Logger.shared.log(.info, "↩️ Uncomplete set \(setIndex + 1) from Watch", category: .general)

        // Notify Flutter to uncomplete the specific set
        notifyFlutter(event: "onUncompleteSetFromWatch", data: message)
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

    /// Handle start new timer request from Watch (when timer shows 00:00)
    private func handleStartNewTimerFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        let duration = message["duration"] as? Int ?? 60
        Logger.shared.log(.info, "⏱️ Start new timer from Watch: \(duration)s", category: .general)

        // Notify Flutter to start a new rest timer
        notifyFlutter(event: "onStartNewTimerFromWatch", data: message)
        replyHandler(["success": true])
    }

    /// 🔥 SUPERSET: Handle round completion from Watch
    /// Watch completes all exercises in a superset round at once with single RPE
    private func handleSupersetRoundCompletedFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        let roundNumber = message["roundNumber"] as? Int ?? 0
        let totalRounds = message["totalRounds"] as? Int ?? 0
        let exercises = message["exercises"] as? [String] ?? []
        let effort = message["effort"] as? Int
        let effortScale = message["effortScale"] as? String ?? "rpe"

        if let effort = effort {
            Logger.shared.log(.info, "🔥 Superset round \(roundNumber)/\(totalRounds) completed from Watch with \(effortScale.uppercased()): \(effort), exercises: \(exercises.count)", category: .general)
        } else {
            Logger.shared.log(.info, "🔥 Superset round \(roundNumber)/\(totalRounds) completed from Watch (no effort), exercises: \(exercises.count)", category: .general)
        }

        // Notify Flutter to complete all exercises in the round
        notifyFlutter(event: "onSupersetRoundCompletedFromWatch", data: message)
        replyHandler(["success": true])
    }

    // MARK: - 🔥 DROPSET Handlers

    /// Handle dropset stage completion from Watch
    /// Each stage in a dropset has its own weight and reps
    private func handleDropsetStageCompletedFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        let stageIndex = message["stageIndex"] as? Int ?? 0
        let totalStages = message["totalStages"] as? Int ?? 0
        let actualReps = message["actualReps"] as? Int ?? 0
        let effort = message["effort"] as? Int
        let effortScale = message["effortScale"] as? String ?? "rpe"

        if let effort = effort {
            Logger.shared.log(.info, "🔥 Dropset stage \(stageIndex + 1)/\(totalStages) completed from Watch: \(actualReps) reps, \(effortScale.uppercased()): \(effort)", category: .general)
        } else {
            Logger.shared.log(.info, "🔥 Dropset stage \(stageIndex + 1)/\(totalStages) completed from Watch: \(actualReps) reps", category: .general)
        }

        // Notify Flutter to complete the stage
        notifyFlutter(event: "onDropsetStageCompletedFromWatch", data: message)
        replyHandler(["success": true])
    }

    /// Handle entire dropset completion from Watch
    /// Called when all stages are completed
    private func handleDropsetCompletedFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        let totalStages = message["totalStages"] as? Int ?? 0
        let effort = message["effort"] as? Int
        let effortScale = message["effortScale"] as? String ?? "rpe"

        if let effort = effort {
            Logger.shared.log(.info, "🔥 Dropset completed from Watch (\(totalStages) stages) with \(effortScale.uppercased()): \(effort)", category: .general)
        } else {
            Logger.shared.log(.info, "🔥 Dropset completed from Watch (\(totalStages) stages)", category: .general)
        }

        // Notify Flutter that entire dropset is complete
        notifyFlutter(event: "onDropsetCompletedFromWatch", data: message)
        replyHandler(["success": true])
    }

    // MARK: - 🔥 REST-PAUSE Handlers

    /// Handle rest-pause set completion from Watch
    /// Rest-pause has multiple mini-sets with short rests between
    private func handleRestPauseSetCompletedFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        let setIndex = message["setIndex"] as? Int ?? 0
        let totalSets = message["totalSets"] as? Int ?? 0
        let actualReps = message["actualReps"] as? Int ?? 0
        let weight = message["weight"] as? Double ?? 0
        let effort = message["effort"] as? Int
        let effortScale = message["effortScale"] as? String ?? "rpe"

        if let effort = effort {
            Logger.shared.log(.info, "🔥 Rest-Pause set \(setIndex + 1)/\(totalSets) completed from Watch: \(weight)kg × \(actualReps), \(effortScale.uppercased()): \(effort)", category: .general)
        } else {
            Logger.shared.log(.info, "🔥 Rest-Pause set \(setIndex + 1)/\(totalSets) completed from Watch: \(weight)kg × \(actualReps)", category: .general)
        }

        // Notify Flutter to complete the rest-pause set
        notifyFlutter(event: "onRestPauseSetCompletedFromWatch", data: message)
        replyHandler(["success": true])
    }

    /// Handle entire rest-pause completion from Watch
    /// Called when all rest-pause mini-sets are completed
    private func handleRestPauseCompletedFromWatch(
        _ message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        let totalSets = message["totalSets"] as? Int ?? 0
        let weight = message["weight"] as? Double ?? 0
        let effort = message["effort"] as? Int
        let effortScale = message["effortScale"] as? String ?? "rpe"

        if let effort = effort {
            Logger.shared.log(.info, "🔥 Rest-Pause completed from Watch (\(totalSets) sets, \(weight)kg) with \(effortScale.uppercased()): \(effort)", category: .general)
        } else {
            Logger.shared.log(.info, "🔥 Rest-Pause completed from Watch (\(totalSets) sets, \(weight)kg)", category: .general)
        }

        // Notify Flutter that entire rest-pause is complete
        notifyFlutter(event: "onRestPauseCompletedFromWatch", data: message)
        replyHandler(["success": true])
    }
}

// MARK: - Public Methods

extension WatchConnectivityManager {

    /// Check if watch is available for communication
    func isWatchAvailable() -> Bool {
        guard let session = session else { return false }
        return session.isPaired && session.isWatchAppInstalled
    }
}
