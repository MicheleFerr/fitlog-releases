//
//  ConnectivityManager.swift
//  FitLogWatch Watch App
//
//  Manages bidirectional communication between Watch and iPhone
//  Watch acts as COMPANION to iPhone workout (not standalone)
//

import Foundation
import WatchConnectivity
import WatchKit
import HealthKit
import Combine

/// Manages bidirectional communication between Watch and iPhone
@MainActor
class ConnectivityManager: NSObject, ObservableObject {

    static let shared = ConnectivityManager()

    // MARK: - Connection State
    @Published var isReachable = false
    @Published var isActivated = false

    // MARK: - Workout State (synced from iPhone)
    @Published var isWorkoutActive = false
    @Published var currentExerciseName = "No Exercise"
    @Published var currentSetNumber = 0
    @Published var totalSets = 0
    @Published var targetWeight: Double = 0
    @Published var targetReps = 0
    @Published var setsCompleted = 0
    @Published var formCues: String? = nil  // Persistent technique reminders
    @Published var tut: String? = nil  // ⌚ BUG FIX #3: Time Under Tension (e.g., "3-1-2-0")

    // MARK: - Workout Summary (shown after workout ends)
    @Published var showWorkoutSummary = false
    @Published var lastWorkoutSetsCompleted = 0
    @Published var lastWorkoutDuration: TimeInterval = 0
    @Published var lastWorkoutCalories: Double = 0
    @Published var lastWorkoutSaved = true

    // MARK: - Rest Timer (mirrors iPhone Live Activity)
    @Published var restTimeRemaining = 0
    @Published var restTimeDuration = 0
    @Published var shouldShowTimer = false
    @Published var shouldNavigateToExercise = false
    private var restTimer: Timer?
    private var restTimerStartTime: TimeInterval = 0
    private var isTimerSkipped = false
    @Published var isTimerPaused = false

    // MARK: - Heart Rate (from HealthKit on Watch)
    @Published var currentHeartRate: Double = 0

    // MARK: - RPE/RIR Settings (synced from iPhone)
    @Published var rpeTrackingEnabled = false
    @Published var effortScale = "rpe"

    // MARK: - Locale (synced from Flutter app)
    @Published var appLocale: String = "en"

    // MARK: - Templates
    @Published var receivedTemplates: [WorkoutTemplate] = []

    // MARK: - Private Properties
    private var session: WCSession?

    // MARK: - Rate Limiting (prevents message flooding)
    private var lastMessageTime: Date = .distantPast
    private let minimumMessageInterval: TimeInterval = 0.3  // 300ms between messages

    // MARK: - Message Queue & Retry Logic
    private var pendingMessages: [[String: Any]] = []
    private let maxPendingMessages = 20
    private let maxRetryCount = 3
    private var messageRetryCount: [String: Int] = [:]
    private let retryDelay: TimeInterval = 2.0

    // MARK: - Connection Monitoring
    private var lastReachabilityChange: Date = .distantPast
    private var reconnectionAttempts = 0
    private let maxReconnectionAttempts = 5

    override init() {
        super.init()

        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()

            // ✅ TWO-PHASE SYNC for fast startup:
            // Phase 1 (immediate): Show cached applicationContext for instant feedback
            // Phase 2 (after 0.5s): Request fresh state from iPhone for accuracy
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                // Phase 1: Immediate UI from cache
                self?.checkPendingApplicationContext()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                // Phase 2: Fresh state from iPhone (may update if different)
                self?.requestWorkoutState()
            }
        } else {
            print("⚠️ WCSession not supported on this device")
        }
    }

    // MARK: - Connection State Validation

    /// Validates that the WatchConnectivity session is ready for operations
    private func isSessionReady() -> Bool {
        guard let session = session else {
            print("❌ WCSession: Session not initialized")
            return false
        }

        guard session.activationState == .activated else {
            print("❌ WCSession: Not activated (state: \(session.activationState.rawValue))")
            return false
        }

        // On watchOS, isPaired and isWatchAppInstalled are unavailable
        // These properties only exist on iOS to check Watch status
        // On Watch, we can only check activationState and reachability

        return true
    }

    /// Check if session is ready for immediate delivery (reachable)
    private func canSendImmediate() -> Bool {
        guard isSessionReady() else { return false }
        return session?.isReachable == true
    }

    /// Check for pending application context that may have been sent while app was closed
    func checkPendingApplicationContext() {
        guard let session = session else { return }

        let context = session.receivedApplicationContext

        if !context.isEmpty {
            if let workoutData = context["workout"] as? [String: Any] {
                // Check timestamp to avoid showing stale workout state
                if let timestamp = workoutData["timestamp"] as? TimeInterval {
                    let age = Date().timeIntervalSince1970 - timestamp
                    let maxAge: TimeInterval = 2 * 60 * 60  // 2 hours
                    if age > maxAge {
                        return
                    }
                }

                // Check isActive flag FIRST - if false, don't show workout UI
                if let isActive = workoutData["isActive"] as? Bool, !isActive {
                    isWorkoutActive = false
                    return
                }

                if let type = workoutData["type"] as? String {
                    if type == "workoutStarted" {
                        if let isActive = workoutData["isActive"] as? Bool, isActive {
                            isWorkoutActive = true
                            handleWorkoutUpdate(workoutData)
                            WKInterfaceDevice.current().play(.start)
                        }
                    } else if type == "workoutEnded" {
                        isWorkoutActive = false
                    }
                }
            }
        }
    }

    // MARK: - Rate-Limited Message Sending

    /// Check if enough time has passed since last message (rate limiting)
    private func canSendMessage() -> Bool {
        let now = Date()
        return now.timeIntervalSince(lastMessageTime) >= minimumMessageInterval
    }

    /// Send message with automatic rate limiting and optimal delivery method
    /// - Parameters:
    ///   - data: Message payload
    ///   - critical: If true, uses transferUserInfo (guaranteed delivery). If false, uses sendMessage (faster but may fail)
    ///   - forceImmediate: Bypass rate limiting for critical user actions
    private func sendToiPhone(_ data: [String: Any], critical: Bool = false, forceImmediate: Bool = false) {
        // STEP 1: Validate session readiness
        guard isSessionReady() else {
            print("⚠️ WCSession not ready, queueing message: \(data["type"] ?? "unknown")")
            queuePendingMessage(data)
            return
        }

        guard let session = session else { return }

        // STEP 2: Rate limiting check (skip for critical immediate actions)
        if !forceImmediate && !canSendMessage() {
            print("⏸️ Rate limit: Skipping message \(data["type"] ?? "unknown")")
            return
        }

        lastMessageTime = Date()

        // STEP 3: Determine delivery method based on criticality and reachability
        if critical {
            // ✅ FIX: Critical messages need IMMEDIATE delivery for user feedback
            // Strategy: Try sendMessage first (immediate), ALSO queue via transferUserInfo (backup)
            if session.isReachable {
                // Try immediate delivery via sendMessage
                session.sendMessage(data, replyHandler: { response in
                    print("✅ Critical message delivered immediately: \(data["type"] ?? "unknown")")
                    Task { @MainActor in
                        self.clearRetryCount(for: data)
                    }
                }) { [weak self] error in
                    print("⚠️ sendMessage failed for critical (\(data["type"] ?? "unknown")): \(error.localizedDescription)")
                    // Fallback already queued via transferUserInfo below
                }
            }

            // ALSO queue via transferUserInfo for guaranteed delivery (backup)
            session.transferUserInfo(data)
            print("📦 Critical message also queued for backup: \(data["type"] ?? "unknown")")
            clearRetryCount(for: data)
        } else if session.isReachable {
            // Non-critical: try sendMessage first (faster), fallback to transferUserInfo
            session.sendMessage(data, replyHandler: { response in
                print("✅ Message delivered with response: \(data["type"] ?? "unknown")")
                Task { @MainActor in
                    self.clearRetryCount(for: data)
                }
            }) { [weak self] error in
                print("⚠️ sendMessage failed (\(data["type"] ?? "unknown")): \(error.localizedDescription)")
                self?.handleSendFailure(data, error: error, critical: false)
            }
        } else {
            // Not reachable: queue for later
            print("📤 Not reachable, queueing message: \(data["type"] ?? "unknown")")
            queuePendingMessage(data)
        }
    }

    // MARK: - Message Queue Management

    /// Queue a message for delivery when connection becomes available
    private func queuePendingMessage(_ message: [String: Any]) {
        if pendingMessages.count >= maxPendingMessages {
            print("⚠️ Pending message queue full, dropping oldest message")
            pendingMessages.removeFirst()
        }

        var messageWithId = message
        messageWithId["_messageId"] = UUID().uuidString
        pendingMessages.append(messageWithId)

        print("📥 Queued message: \(message["type"] ?? "unknown") (queue size: \(pendingMessages.count))")
    }

    /// Process all pending messages when connection becomes available
    private func processPendingMessages() {
        guard !pendingMessages.isEmpty else { return }
        guard canSendImmediate() else { return }

        print("🔄 Processing \(pendingMessages.count) pending messages")

        let messagesToProcess = pendingMessages
        pendingMessages.removeAll()

        for message in messagesToProcess {
            // Remove internal tracking fields
            var cleanMessage = message
            cleanMessage.removeValue(forKey: "_messageId")

            // Retry with exponential backoff if needed
            retryMessage(cleanMessage)
        }
    }

    /// Retry a failed message with exponential backoff
    private func retryMessage(_ message: [String: Any]) {
        let messageType = message["type"] as? String ?? "unknown"
        let retryCount = messageRetryCount[messageType] ?? 0

        guard retryCount < maxRetryCount else {
            print("❌ Message exceeded max retries: \(messageType)")
            messageRetryCount.removeValue(forKey: messageType)
            return
        }

        let delay = retryDelay * pow(2.0, Double(retryCount))

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }

            print("🔄 Retry attempt \(retryCount + 1) for: \(messageType)")
            self.messageRetryCount[messageType] = retryCount + 1

            // Determine if message is critical based on type
            let criticalTypes = ["setCompleted", "endWorkout", "pauseWorkout", "workoutCompleted", "setModification"]
            let isCritical = criticalTypes.contains(messageType)

            self.sendToiPhone(message, critical: isCritical, forceImmediate: true)
        }
    }

    /// Handle message send failure with retry logic
    private func handleSendFailure(_ message: [String: Any], error: Error, critical: Bool) {
        let messageType = message["type"] as? String ?? "unknown"

        print("❌ Send failed for \(messageType): \(error.localizedDescription)")

        // Log specific error types for debugging
        let nsError = error as NSError
        switch nsError.code {
        case 7003:
            print("⚠️ Error 7003: Counterpart not reachable")
        case 7004:
            print("⚠️ Error 7004: Message payload too large")
        case 7005:
            print("⚠️ Error 7005: Session not activated")
        case 7007:
            print("⚠️ Error 7007: File not found")
        case 7009:
            print("⚠️ Error 7009: Insufficient space")
        default:
            print("⚠️ WCError code: \(nsError.code)")
        }

        // Fallback to guaranteed delivery for critical messages
        if critical, let session = session {
            do {
                session.transferUserInfo(message)
                print("✅ Fallback: Queued critical message via transferUserInfo")
            } catch {
                print("❌ Fallback failed, queueing for retry: \(error.localizedDescription)")
                queuePendingMessage(message)
            }
        } else {
            // Queue non-critical messages for retry
            queuePendingMessage(message)
        }
    }

    /// Clear retry count for successfully delivered message
    private func clearRetryCount(for message: [String: Any]) {
        if let messageType = message["type"] as? String {
            messageRetryCount.removeValue(forKey: messageType)
        }
    }

    /// Clear all pending messages and retry state
    private func clearPendingState() {
        pendingMessages.removeAll()
        messageRetryCount.removeAll()
        print("🧹 Cleared pending messages and retry state")
    }

    // MARK: - Send to iPhone

    /// Notify iPhone that set was completed from Watch
    func sendSetCompleted(effort: Int? = nil) {
        var data: [String: Any] = [
            "type": "setCompleted",
            "timestamp": Date().timeIntervalSince1970,
            "setNumber": currentSetNumber,
            "exerciseName": currentExerciseName
        ]

        if let effort = effort {
            data["effort"] = effort
            data["effortScale"] = effortScale
        }

        // Set completion is critical - must be delivered
        sendToiPhone(data, critical: true, forceImmediate: true)

        WKInterfaceDevice.current().play(.success)
        setsCompleted += 1
    }

    /// Notify iPhone to skip rest timer
    /// User-initiated immediate action with fallback to queue if not reachable
    func sendSkipRest() {
        let data: [String: Any] = [
            "type": "skipRest",
            "timestamp": Date().timeIntervalSince1970
        ]

        // Skip is user-initiated, immediate delivery preferred
        // Falls back to queue if session not ready (handled by sendToiPhone)
        sendToiPhone(data, critical: false, forceImmediate: true)

        // Update local state immediately for responsive UI
        restTimeRemaining = 0
        restTimer?.invalidate()
        restTimer = nil
    }

    /// Notify iPhone to pause/stop the current workout
    func sendPauseWorkout() {
        let data: [String: Any] = [
            "type": "pauseWorkout",
            "timestamp": Date().timeIntervalSince1970
        ]

        sendToiPhone(data, critical: true, forceImmediate: true)
        WKInterfaceDevice.current().play(.stop)
    }

    /// Notify iPhone to end/stop the current workout
    func sendEndWorkout(save: Bool = true, duration: TimeInterval = 0, calories: Double = 0) {
        let data: [String: Any] = [
            "type": "endWorkout",
            "save": save,
            "timestamp": Date().timeIntervalSince1970
        ]

        // End workout is CRITICAL - must be delivered
        sendToiPhone(data, critical: true, forceImmediate: true)

        // Store summary data BEFORE clearing workout state
        lastWorkoutSetsCompleted = setsCompleted
        lastWorkoutDuration = duration
        lastWorkoutCalories = calories
        lastWorkoutSaved = save

        // ✅ FIX: Complete cleanup of workout and timer state
        isWorkoutActive = false
        restTimer?.invalidate()
        restTimer = nil
        clearTimerState()  // Clear all timer-related state
        shouldShowTimer = false
        shouldNavigateToExercise = false

        showWorkoutSummary = true

        WKInterfaceDevice.current().play(save ? .success : .stop)
    }

    /// Dismiss the workout summary view
    func dismissWorkoutSummary() {
        showWorkoutSummary = false
    }

    /// Send real-time health metrics to iPhone (HR, calories)
    /// Rate-limited to avoid message flooding
    /// Uses applicationContext for "latest only" semantics (most efficient)
    func sendHealthMetrics(heartRate: Double, calories: Double, elapsedTime: TimeInterval) {
        guard isSessionReady() else { return }
        guard let session = session else { return }

        // Health metrics are NOT critical and should be rate-limited
        guard canSendMessage() else { return }

        lastMessageTime = Date()

        let data: [String: Any] = [
            "type": "healthMetrics",
            "heartRate": heartRate,
            "calories": calories,
            "elapsedTime": elapsedTime,
            "timestamp": Date().timeIntervalSince1970
        ]

        // ALWAYS use applicationContext for health metrics (latest only semantics)
        // This automatically replaces old data and is more efficient than queued delivery
        do {
            var currentContext = session.applicationContext
            currentContext["healthMetrics"] = data
            try session.updateApplicationContext(currentContext)
            print("✅ Updated health metrics context (HR: \(Int(heartRate)))")
        } catch {
            print("⚠️ Failed to update health metrics context: \(error.localizedDescription)")
        }
    }

    /// Update heart rate on connectivity manager (for display in WaitingView)
    func updateHeartRate(_ heartRate: Double) {
        self.currentHeartRate = heartRate
    }

    /// Send modified set data (weight/reps) to iPhone
    func sendSetModification(weight: Double, reps: Int) {
        let data: [String: Any] = [
            "type": "setModification",
            "weight": weight,
            "reps": reps,
            "timestamp": Date().timeIntervalSince1970
        ]

        // User-initiated modification - immediate delivery
        sendToiPhone(data, critical: true, forceImmediate: true)

        targetWeight = weight
        targetReps = reps

        WKInterfaceDevice.current().play(.success)
    }

    /// Send timer extension request to iPhone
    /// User-initiated immediate action with fallback to queue if not reachable
    func sendExtendTimer(seconds: Int) {
        let data: [String: Any] = [
            "type": "extendTimer",
            "seconds": seconds,
            "timestamp": Date().timeIntervalSince1970
        ]

        // Timer extension is user-initiated, immediate delivery preferred
        // Falls back to queue if session not ready (handled by sendToiPhone)
        sendToiPhone(data, critical: false, forceImmediate: true)

        // Update local state immediately for responsive UI
        restTimeRemaining += seconds
        restTimeDuration += seconds

        WKInterfaceDevice.current().play(.click)
    }

    /// Send completed workout to iPhone for sync
    func sendWorkoutCompleted(_ workout: HKWorkout) async {
        var calories: Double = 0
        if let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
           let statistics = workout.statistics(for: energyType),
           let sum = statistics.sumQuantity() {
            calories = sum.doubleValue(for: .kilocalorie())
        }

        let data: [String: Any] = [
            "type": "workoutCompleted",
            "duration": workout.duration,
            "calories": calories,
            "startDate": workout.startDate.timeIntervalSince1970,
            "endDate": workout.endDate.timeIntervalSince1970,
            "workoutType": workout.workoutActivityType.rawValue
        ]

        // Workout completion is CRITICAL - must be delivered
        sendToiPhone(data, critical: true, forceImmediate: true)
    }

    /// Request templates from iPhone
    func requestTemplates() async {
        guard canSendImmediate() else {
            print("⚠️ Cannot request templates: session not ready or not reachable")
            return
        }

        guard let session = session else { return }

        session.sendMessage(
            ["type": "requestTemplates"],
            replyHandler: { [weak self] response in
                Task { @MainActor in
                    if let templatesData = response["templates"] as? [[String: Any]] {
                        self?.parseTemplates(templatesData)
                        print("✅ Received \(templatesData.count) templates from iPhone")
                    }
                }
            },
            errorHandler: { error in
                print("❌ Failed to request templates: \(error.localizedDescription)")
            }
        )
    }

    /// Request current workout state from iPhone
    /// Called on app launch/foreground to sync with iPhone's active workout
    func requestWorkoutState() {
        print("📱 [WATCH] Requesting workout state from iPhone...")

        guard isSessionReady() else {
            print("⚠️ Cannot request workout state: session not ready")
            // Fall back to checking cached applicationContext
            checkPendingApplicationContext()
            return
        }

        guard let session = session else {
            checkPendingApplicationContext()
            return
        }

        // If not reachable, rely on applicationContext
        guard session.isReachable else {
            print("⚠️ iPhone not reachable, using cached applicationContext")
            checkPendingApplicationContext()
            return
        }

        session.sendMessage(
            ["type": "requestWorkoutState", "timestamp": Date().timeIntervalSince1970],
            replyHandler: { [weak self] response in
                Task { @MainActor in
                    guard let self = self else { return }

                    print("📱 [WATCH] Received workout state response: \(response)")

                    // Check if workout is active
                    if let isActive = response["isActive"] as? Bool {
                        if isActive {
                            self.isWorkoutActive = true
                            self.handleWorkoutUpdate(response)
                            print("✅ [WATCH] Workout state synced: ACTIVE")

                            // Check if there's an active rest timer
                            if let timerData = response["restTimer"] as? [String: Any] {
                                self.handleRestTimerFromContext(timerData)
                            }

                            WKInterfaceDevice.current().play(.start)
                        } else {
                            self.isWorkoutActive = false
                            print("✅ [WATCH] Workout state synced: INACTIVE")
                        }
                    } else {
                        // No workout active on iPhone
                        self.isWorkoutActive = false
                        print("✅ [WATCH] No active workout on iPhone")
                    }
                }
            },
            errorHandler: { [weak self] error in
                print("❌ [WATCH] Failed to request workout state: \(error.localizedDescription)")
                // Fall back to cached applicationContext
                Task { @MainActor in
                    self?.checkPendingApplicationContext()
                }
            }
        )
    }

    // MARK: - Rest Timer Management

    private func startRestTimer(duration: Int) {
        restTimeDuration = duration
        restTimeRemaining = duration
        isTimerSkipped = false

        // Save absolute start time for foreground resync
        if restTimerStartTime == 0 {
            restTimerStartTime = Date().timeIntervalSince1970
        }

        restTimer?.invalidate()

        // Use target-selector pattern (more efficient than Task { @MainActor })
        restTimer = Timer(timeInterval: 1, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        RunLoop.main.add(restTimer!, forMode: .common)
    }

    /// Resync timer when app returns to foreground
    /// Called from ScenePhase observer when app becomes active
    /// Recalculates remaining time based on absolute startTime to handle watchOS suspension
    func resyncTimerOnForeground() {
        // Only resync if we have an active timer context
        guard restTimerStartTime > 0, restTimeDuration > 0 else {
            return
        }

        // Don't resync if timer was skipped or completed
        guard !isTimerSkipped else {
            return
        }

        let now = Date().timeIntervalSince1970
        let elapsed = Int(now - restTimerStartTime)
        let remaining = max(0, restTimeDuration - elapsed)

        print("⏱️ [RESYNC] Timer resync on foreground: elapsed=\(elapsed)s, remaining=\(remaining)s")

        if remaining > 0 {
            // Timer still has time - restart with correct remaining
            restTimeRemaining = remaining
            restTimer?.invalidate()
            restTimer = Timer(timeInterval: 1, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
            RunLoop.main.add(restTimer!, forMode: .common)
        } else {
            // Timer expired while in background - trigger completion
            restTimeRemaining = 0
            restTimer?.invalidate()
            restTimer = nil
            restTimerStartTime = 0

            if !isTimerSkipped {
                WKInterfaceDevice.current().play(.notification)
                objectWillChange.send()
                shouldNavigateToExercise = true
            }
        }
    }

    /// Clear timer state (called when timer completes or is skipped)
    private func clearTimerState() {
        restTimerStartTime = 0
        restTimeDuration = 0
        restTimeRemaining = 0
        isTimerSkipped = false
        isTimerPaused = false  // ✅ FIX: Reset pause state to avoid stale UI
    }

    /// Timer tick handler - runs on main thread via RunLoop
    @objc private func timerTick() {
        if isTimerSkipped {
            restTimer?.invalidate()
            restTimer = nil
            clearTimerState()
            return
        }

        if restTimeRemaining > 0 {
            restTimeRemaining -= 1

            // Reduced haptics: only 3-2-1 countdown (battery savings)
            if [3, 2, 1].contains(restTimeRemaining) {
                WKInterfaceDevice.current().play(.click)
            }
        } else {
            restTimer?.invalidate()
            restTimer = nil
            clearTimerState()
            if !isTimerSkipped {
                WKInterfaceDevice.current().play(.notification)
                objectWillChange.send()
                shouldNavigateToExercise = true
            }
        }
    }

    // MARK: - Private Methods

    private func parseTemplates(_ templatesData: [[String: Any]]) {
        receivedTemplates = templatesData.compactMap { dict in
            guard let id = dict["id"] as? String,
                  let name = dict["name"] as? String else {
                return nil
            }

            return WorkoutTemplate(
                id: id,
                name: name,
                exercises: []
            )
        }
    }

    private func handleWorkoutUpdate(_ data: [String: Any]) {
        // ✅ FIX: DO NOT update isWorkoutActive here!
        // This function updates exercise DETAILS only.
        // isWorkoutActive should be managed explicitly by:
        // - sendEndWorkout() for local user action
        // - processIncomingMessage() for "workoutStarted"/"workoutEnded"
        // - didReceiveApplicationContext() for state sync
        // - requestWorkoutState() response handler
        //
        // Setting isWorkoutActive here causes race conditions where stale
        // applicationContext data can override local user action (discard).

        if let exercise = data["exerciseName"] as? String {
            currentExerciseName = exercise
        }

        if let setNum = data["currentSet"] as? Int {
            currentSetNumber = setNum
        }

        if let total = data["totalSets"] as? Int {
            totalSets = total
        }

        if let weight = data["targetWeight"] as? Double {
            targetWeight = weight
        }

        if let reps = data["targetReps"] as? Int {
            targetReps = reps
        }

        if let completed = data["setsCompleted"] as? Int {
            setsCompleted = completed
        }

        if let rpeEnabled = data["rpeTrackingEnabled"] as? Bool {
            rpeTrackingEnabled = rpeEnabled
        }

        if let scale = data["effortScale"] as? String {
            effortScale = scale
        }

        if let locale = data["locale"] as? String {
            appLocale = locale
        }

        // Form Cues (persistent technique reminders) - may be nil
        if let cues = data["formCues"] as? String {
            formCues = cues.isEmpty ? nil : cues
        } else {
            formCues = nil
        }

        // ⌚ BUG FIX #3: Time Under Tension (e.g., "3-1-2-0") - may be nil
        if let tutValue = data["tut"] as? String {
            tut = tutValue.isEmpty ? nil : tutValue
        } else {
            tut = nil
        }
    }

    private func handleRestTimerUpdate(_ data: [String: Any]) {
        if let duration = data["duration"] as? Int {
            startRestTimer(duration: duration)
        }
    }
}

// MARK: - WCSessionDelegate

extension ConnectivityManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            isReachable = session.isReachable
            isActivated = activationState == .activated

            if let error = error {
                print("❌ WCSession activation failed: \(error.localizedDescription)")
                reconnectionAttempts += 1

                // Retry activation if failed
                if reconnectionAttempts < maxReconnectionAttempts {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                        self?.attemptReconnection()
                    }
                }
            } else {
                print("✅ WCSession activated successfully (state: \(activationState.rawValue))")
                // Note: isPaired and isWatchAppInstalled are iOS-only properties
                reconnectionAttempts = 0

                // Process pending messages on successful activation
                if activationState == .activated && session.isReachable {
                    processPendingMessages()
                }
            }
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            let previousReachability = isReachable
            isReachable = session.isReachable

            let timeSinceLastChange = Date().timeIntervalSince(lastReachabilityChange)
            lastReachabilityChange = Date()

            print("🔄 Reachability changed: \(previousReachability) → \(session.isReachable)")
            print("⏱️ Time since last change: \(String(format: "%.1f", timeSinceLastChange))s")

            if session.isReachable {
                print("✅ Connection restored, processing pending messages")

                // Small delay to ensure connection is stable
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.processPendingMessages()
                }

                // ⌚ BUG FIX #5: Request workout state when connection is restored
                // This ensures we sync with iPhone if workout is active
                // Helps recover from disconnect state (showing only HR instead of workout)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                    guard let self = self else { return }
                    // First check cached context for immediate UI
                    self.checkPendingApplicationContext()
                    // Then request fresh state from iPhone
                    self.requestWorkoutState()
                    print("⌚ [RECOVERY] Requested workout state after connection restored")
                }
            } else {
                print("⚠️ Connection lost, messages will be queued")
            }
        }
    }

    /// Attempt to reactivate the WCSession
    private func attemptReconnection() {
        guard let session = session else { return }

        print("🔄 Attempting reconnection (attempt \(reconnectionAttempts)/\(maxReconnectionAttempts))")

        if session.activationState != .activated {
            session.activate()
        }
    }

    // Receive messages from iPhone WITHOUT reply handler
    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any]
    ) {
        processIncomingMessage(message)
    }

    // Receive messages from iPhone WITH reply handler
    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        processIncomingMessage(message)
        replyHandler(["success": true, "timestamp": Date().timeIntervalSince1970])
    }

    // Shared message processing logic
    private nonisolated func processIncomingMessage(_ message: [String : Any]) {
        Task { @MainActor in
            guard let type = message["type"] as? String else { return }

            switch type {
            case "workoutStarted":
                isWorkoutActive = true
                handleWorkoutUpdate(message)
                WKInterfaceDevice.current().play(.start)

            case "workoutEnded":
                // ✅ FIX: Complete cleanup of workout and timer state
                isWorkoutActive = false
                restTimer?.invalidate()
                restTimer = nil
                clearTimerState()
                shouldShowTimer = false
                shouldNavigateToExercise = false
                WKInterfaceDevice.current().play(.success)

            case "workoutUpdate":
                handleWorkoutUpdate(message)

            case "restTimerStarted":
                handleRestTimerUpdate(message)
                objectWillChange.send()
                shouldShowTimer = true

            case "restTimerSkipped":
                isTimerSkipped = true
                restTimer?.invalidate()
                restTimer = nil
                restTimeRemaining = 0

            case "restTimerPaused":
                isTimerPaused = true
                restTimer?.invalidate()
                restTimer = nil
                if let remaining = message["remainingTime"] as? Int {
                    restTimeRemaining = remaining
                }
                // Use .notification for more distinct pause feedback (Apple HIG best practice)
                WKInterfaceDevice.current().play(.notification)

            case "restTimerResumed":
                if let remaining = message["remainingTime"] as? Int, remaining > 0 {
                    isTimerPaused = false
                    isTimerSkipped = false
                    restTimeRemaining = remaining
                    startRestTimer(duration: remaining)
                }
                WKInterfaceDevice.current().play(.start)

            case "templatesUpdate":
                if let templates = message["templates"] as? [[String: Any]] {
                    parseTemplates(templates)
                }

            default:
                break
            }
        }
    }

    // Receive application context (state sync) - PRIMARY delivery method
    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {
        Task { @MainActor in
            // Sync workout state
            if let workoutData = applicationContext["workout"] as? [String: Any] {
                if let type = workoutData["type"] as? String {
                    if type == "workoutStarted" {
                        let exerciseName = workoutData["exerciseName"] as? String ?? "Workout"

                        if !isWorkoutActive {
                            NotificationManager.shared.showWorkoutStartedNotification(
                                exerciseName: exerciseName
                            )
                        }

                        isWorkoutActive = true
                        handleWorkoutUpdate(workoutData)
                        WKInterfaceDevice.current().play(.start)

                    } else if type == "workoutEnded" {
                        // ✅ FIX: Complete cleanup of workout and timer state
                        isWorkoutActive = false
                        restTimer?.invalidate()
                        restTimer = nil
                        clearTimerState()
                        shouldShowTimer = false
                        shouldNavigateToExercise = false
                        WKInterfaceDevice.current().play(.success)
                    }
                }

                if let isActive = workoutData["isActive"] as? Bool {
                    if isActive && !isWorkoutActive {
                        let exerciseName = workoutData["exerciseName"] as? String ?? "Workout"

                        NotificationManager.shared.showWorkoutStartedNotification(
                            exerciseName: exerciseName
                        )

                        isWorkoutActive = true
                        handleWorkoutUpdate(workoutData)
                        WKInterfaceDevice.current().play(.start)
                    } else if !isActive && isWorkoutActive {
                        // ✅ FIX: Complete cleanup of workout and timer state
                        isWorkoutActive = false
                        restTimer?.invalidate()
                        restTimer = nil
                        clearTimerState()
                        shouldShowTimer = false
                        shouldNavigateToExercise = false
                    }
                }
            }

            // Handle rest timer from applicationContext
            if let timerData = applicationContext["restTimer"] as? [String: Any] {
                handleRestTimerFromContext(timerData)
            }
        }
    }

    /// Handle rest timer from applicationContext with proper time sync
    private func handleRestTimerFromContext(_ data: [String: Any]) {
        // ✅ FIX: Only start timer if workout is active
        // This prevents timer from restarting after workout ends
        guard isWorkoutActive else {
            print("⏱️ [TIMER] Ignoring timer context - workout not active")
            return
        }

        guard let duration = data["duration"] as? Int,
              let startTime = data["startTime"] as? TimeInterval else {
            return
        }

        // ✅ BUG FIX #1: Prevent duplicate timer starts
        // If we already have a timer running with the same startTime, don't restart
        // This prevents race condition when checkPendingApplicationContext and requestWorkoutState
        // both try to start the timer in quick succession
        if restTimerStartTime == startTime && restTimer != nil {
            print("⏱️ [TIMER] Timer already running with same startTime, skipping duplicate start")
            return
        }

        let now = Date().timeIntervalSince1970
        let elapsed = Int(now - startTime)
        let remaining = max(0, duration - elapsed)

        if remaining > 0 {
            restTimerStartTime = startTime

            // Reuse the optimized startRestTimer (uses target-selector pattern)
            startRestTimer(duration: remaining)

            objectWillChange.send()
            shouldShowTimer = true
            print("⏱️ [TIMER] Started rest timer: \(remaining)s remaining (startTime: \(startTime))")
        } else {
            print("⏱️ [TIMER] Timer already expired (elapsed: \(elapsed)s), not starting")
        }
    }

    // Receive background transfers
    nonisolated func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String : Any] = [:]
    ) {
        Task { @MainActor in
            guard let type = userInfo["type"] as? String else { return }

            if type == "workoutUpdate" {
                handleWorkoutUpdate(userInfo)
            }
        }
    }
}

// MARK: - Models

struct WorkoutTemplate: Identifiable {
    let id: String
    let name: String
    let exercises: [String]
}
