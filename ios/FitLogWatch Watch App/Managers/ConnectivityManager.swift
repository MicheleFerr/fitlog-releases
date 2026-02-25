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
    /// ✅ FIX: When workout ends, indicates if HKWorkoutSession should be saved to HealthKit
    /// Set by iPhone when sending "workoutEnded" message (default true for backwards compatibility)
    @Published var shouldSaveWorkoutToHealthKit = true
    @Published var currentExerciseName = "No Exercise"
    @Published var currentSetNumber = 0
    @Published var totalSets = 0
    @Published var targetWeight: Double = 0
    @Published var targetReps = 0
    // ⌚ Rep range support (e.g., 8-12 reps)
    @Published var minReps: Int? = nil
    @Published var maxReps: Int? = nil
    @Published var setsCompleted = 0
    // ✅ FIX: Sets completed in CURRENT EXERCISE (for edit UI set selector)
    @Published var setsCompletedInExercise = 0
    // ✅ FIX: Actual reps of last completed set (for edit UI initial value)
    @Published var lastCompletedReps = 0
    @Published var formCues: String? = nil  // Persistent technique reminders
    @Published var tut: String? = nil  // ⌚ BUG FIX #3: Time Under Tension (e.g., "3-1-2-0")
    @Published var workoutType: String = "strength"  // ✅ FIX: Workout type for HKWorkoutSession

    // MARK: - Exercise Navigation (for jumping between exercises)
    @Published var exerciseNames: [String] = []  // All exercises in the workout
    @Published var currentExerciseIndex: Int = 0  // 0-indexed
    @Published var totalExercises: Int = 0

    // ✅ FIX: All sets' targets for current exercise (for navigation between sets)
    // Each element: (weight, reps, actualReps?, isCompleted, isWarmup, minReps?, maxReps?) indexed by setNumber - 1
    // actualReps is nil if set not completed, or the actual reps performed
    @Published var allSetsTargets: [(weight: Double, reps: Int, actualReps: Int?, isCompleted: Bool, isWarmup: Bool, minReps: Int?, maxReps: Int?)] = []

    // MARK: - 🔥 SUPERSET State (synced from iPhone)
    @Published var isSuperset = false
    @Published var supersetName: String? = nil
    @Published var supersetExercises: [String] = []
    @Published var currentExerciseInSuperset = 0  // 1-indexed
    @Published var totalExercisesInSuperset = 0
    @Published var supersetRound = 0  // 1-indexed
    @Published var totalSupersetRounds = 0

    // MARK: - 🔥 DROPSET State (synced from iPhone)
    @Published var isDropset = false
    @Published var dropsetStages: [(weight: Double, reps: Int, isCompleted: Bool)] = []
    @Published var currentDropsetStage = 0  // 0-indexed
    @Published var totalDropsetStages = 0

    // MARK: - 🔥 REST-PAUSE State (synced from iPhone)
    @Published var isRestPause = false
    @Published var restPauseWeight: Double = 0
    @Published var restPauseTargetReps = 0
    @Published var restPauseSets: [(reps: Int, restSeconds: Int, isCompleted: Bool)] = []
    @Published var currentRestPauseSet = 0  // 0-indexed
    @Published var totalRestPauseSets = 0

    // MARK: - Rep Range Computed Properties
    /// Whether current exercise uses a rep range (e.g., 8-12) instead of fixed reps
    var hasRepRange: Bool { minReps != nil && maxReps != nil && minReps != maxReps }
    /// Display string for reps: "8-12" for range, "\(targetReps)" for fixed
    var repsDisplay: String {
        if hasRepRange, let min = minReps, let max = maxReps {
            return "\(min)-\(max)"
        }
        return "\(targetReps)"
    }

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
    private var lastTimerExtendTimestamp: TimeInterval?  // ✅ Dedupe timer extensions
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

    // MARK: - P0-2 FIX: Serial Message Channel
    // Ensures messages from nonisolated WCSession delegates are processed in order
    private enum IncomingEvent: @unchecked Sendable {
        case message([String: Any])
        case applicationContext([String: Any])
    }
    // nonisolated(unsafe): AsyncStream.Continuation is thread-safe (Sendable),
    // safe to yield from nonisolated WCSession delegates
    private nonisolated(unsafe) var incomingContinuation: AsyncStream<IncomingEvent>.Continuation?

    // MARK: - Private Properties
    private var session: WCSession?

    // MARK: - Rate Limiting (prevents message flooding)
    // P2-12 FIX: Configurable rate limits per message category
    private var lastMessageTime: Date = .distantPast
    private let minimumMessageInterval: TimeInterval = 0.3  // Default 300ms
    private let healthMessageInterval: TimeInterval = 1.0   // Health updates: 1s (reduce noise)
    private var lastHealthMessageTime: Date = .distantPast

    /// Flag to prevent race conditions during sync operations
    private var isSyncingWorkoutState = false

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

    // MARK: - Haptic Feedback Debounce (prevents multiple sounds on workout start)
    private var lastWorkoutStartHaptic: Date = .distantPast
    private let hapticDebounceInterval: TimeInterval = 3.0  // 3 seconds cooldown

    /// Play workout start haptic with debounce to prevent multiple sounds
    /// Multiple code paths can trigger workout start (applicationContext, sendMessage, etc.)
    /// This ensures only ONE haptic is played within the debounce interval
    private func playWorkoutStartHapticIfNeeded() {
        let now = Date()
        guard now.timeIntervalSince(lastWorkoutStartHaptic) >= hapticDebounceInterval else {
            print("⏸️ [HAPTIC] Skipping workout start haptic (debounced)")
            return
        }
        lastWorkoutStartHaptic = now
        WKInterfaceDevice.current().play(.start)
        print("🔔 [HAPTIC] Playing workout start haptic")
    }

    // P2-7 FIX: Private init enforces singleton pattern
    private override init() {
        super.init()

        // P0-2 FIX: Setup serial message processing channel
        let (stream, continuation) = AsyncStream<IncomingEvent>.makeStream()
        self.incomingContinuation = continuation
        Task { @MainActor [weak self] in
            for await event in stream {
                guard let self = self else { break }
                switch event {
                case .message(let message):
                    self.handleIncomingMessage(message)
                case .applicationContext(let context):
                    self.handleIncomingApplicationContext(context)
                }
            }
        }

        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()

            // P2-10 FIX: Use Task instead of DispatchQueue.main.asyncAfter for Swift 6 compatibility
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(300))
                self?.syncWorkoutStateFromiPhone()
            }
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
                if let timestamp = workoutData.doubleValue(for: "timestamp") {
                    let age = Date().timeIntervalSince1970 - timestamp
                    let maxAge: TimeInterval = 2 * 60 * 60  // 2 hours
                    if age > maxAge {
                        return
                    }
                }

                // Check isActive flag FIRST - if false, don't show workout UI
                if let isActive = workoutData.boolValue(for: "isActive"), !isActive {
                    isWorkoutActive = false
                    return
                }

                if let type = workoutData.stringValue(for: "type") {
                    if type == "workoutStarted" {
                        if let isActive = workoutData.boolValue(for: "isActive"), isActive {
                            isWorkoutActive = true
                            handleWorkoutUpdate(workoutData)
                            playWorkoutStartHapticIfNeeded()
                        }
                    } else if type == "workoutEnded" {
                        isWorkoutActive = false
                    }
                }
            }
        }
    }

    /// Unified method to sync workout state from iPhone
    /// Prevents race conditions by coordinating cache check and fresh request
    /// - Parameter skipCache: If true, only requests fresh state from iPhone
    func syncWorkoutStateFromiPhone(skipCache: Bool = false) {
        // Prevent concurrent sync operations
        guard !isSyncingWorkoutState else {
            print("⌚ [SYNC] Sync already in progress, skipping")
            return
        }

        isSyncingWorkoutState = true
        print("⌚ [SYNC] Starting unified workout state sync...")

        // Phase 1: Show cached data immediately for fast UI (unless skipped)
        if !skipCache {
            checkPendingApplicationContext()
        }

        // Phase 2: Request fresh state from iPhone (async)
        // The requestWorkoutState will reset the flag when complete
        requestWorkoutStateInternal()
    }

    /// Internal method for requesting workout state (called by unified sync)
    private func requestWorkoutStateInternal() {
        guard isSessionReady() else {
            print("⚠️ Cannot request workout state: session not ready")
            isSyncingWorkoutState = false
            return
        }

        guard let session = session else {
            isSyncingWorkoutState = false
            return
        }

        // If not reachable, we already showed cached data, just reset flag
        guard session.isReachable else {
            print("⚠️ iPhone not reachable, relying on cached data")
            isSyncingWorkoutState = false
            return
        }

        session.sendMessage(
            ["type": WatchMessageType.requestWorkoutState, "timestamp": Date().timeIntervalSince1970],
            replyHandler: { [weak self] response in
                Task { @MainActor in
                    guard let self = self else { return }
                    defer { self.isSyncingWorkoutState = false }

                    print("📱 [WATCH] Received workout state response: \(response)")

                    if let isActive = response.boolValue(for: "isActive") {
                        if isActive {
                            self.isWorkoutActive = true
                            self.handleWorkoutUpdate(response)
                            if let timerData = response["restTimer"] as? [String: Any] {
                                self.handleRestTimerFromContext(timerData)
                            }
                            self.playWorkoutStartHapticIfNeeded()
                            print("✅ [WATCH] Workout state synced: ACTIVE")
                        } else {
                            self.isWorkoutActive = false
                            print("✅ [WATCH] Workout state synced: INACTIVE")
                        }
                    } else {
                        self.isWorkoutActive = false
                        print("✅ [WATCH] No active workout on iPhone")
                    }
                }
            },
            errorHandler: { [weak self] error in
                Task { @MainActor in
                    self?.isSyncingWorkoutState = false
                    print("❌ Failed to get workout state: \(error.localizedDescription)")
                }
            }
        )
    }

    // MARK: - Rate-Limited Message Sending

    /// Check if enough time has passed since last message (rate limiting)
    private func canSendMessage() -> Bool {
        let now = Date()
        return now.timeIntervalSince(lastMessageTime) >= minimumMessageInterval
    }

    /// Send message with automatic rate limiting and optimal delivery method
    ///
    /// **IMPORTANT SIMULATOR LIMITATION:**
    /// `transferUserInfo` does NOT work in the watchOS/iOS Simulator.
    /// Messages sent via transferUserInfo will appear to succeed but are never delivered.
    /// This is a known Apple limitation - FIFO queue is only functional on real devices.
    /// For testing, always use physical devices or rely on `sendMessage` (which works in simulator).
    /// Reference: https://developer.apple.com/forums/thread/697209
    ///
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
        let messageType = message.stringValue(for: "type") ?? "unknown"
        let retryCount = messageRetryCount[messageType] ?? 0

        guard retryCount < maxRetryCount else {
            print("❌ Message exceeded max retries: \(messageType)")
            messageRetryCount.removeValue(forKey: messageType)
            return
        }

        let delay = retryDelay * pow(2.0, Double(retryCount))

        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(Int(delay * 1000)))
            guard let self = self else { return }

            print("🔄 Retry attempt \(retryCount + 1) for: \(messageType)")
            self.messageRetryCount[messageType] = retryCount + 1

            let criticalTypes = ["setCompleted", "endWorkout", "pauseWorkout", "workoutCompleted", "setModification"]
            let isCritical = criticalTypes.contains(messageType)

            self.sendToiPhone(message, critical: isCritical, forceImmediate: true)
        }
    }

    /// Handle message send failure with retry logic
    private func handleSendFailure(_ message: [String: Any], error: Error, critical: Bool) {
        let messageType = message.stringValue(for: "type") ?? "unknown"

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
        if let messageType = message.stringValue(for: "type") {
            messageRetryCount.removeValue(forKey: messageType)
        }
    }

    // MARK: - Send to iPhone

    /// Flag to indicate timer shown optimistically (before iPhone confirmation)
    @Published var isOptimisticTimer = false

    /// Cached rest time for current exercise (from iPhone workout data)
    private var cachedExerciseRestTime: Int? = nil

    /// Update cached rest time when receiving workout data
    func updateCachedRestTime(_ restTime: Int?) {
        cachedExerciseRestTime = restTime
    }

    /// Notify iPhone that set was completed from Watch
    /// ✅ FIX: Uses sendMessage with replyHandler to receive rest timer immediately
    /// - actualReps: Optional actual reps performed (from rep range picker)
    func sendSetCompleted(effort: Int? = nil, actualReps: Int? = nil) {
        var data: [String: Any] = [
            "type": WatchMessageType.setCompleted,
            "timestamp": Date().timeIntervalSince1970,
            "setNumber": currentSetNumber,
            "exerciseName": currentExerciseName
        ]

        if let effort = effort {
            data["effort"] = effort
            data["effortScale"] = effortScale
        }

        if let actualReps = actualReps {
            data["actualReps"] = actualReps
        }

        // ✅ FIX: Show optimistic timer immediately while waiting for confirmation
        // This prevents the "no timer" gap while waiting for iPhone response
        // ✅ Skip timer for warmup sets (warmup → no rest needed)
        let setIndex = currentSetNumber - 1
        let isCurrentSetWarmup = setIndex >= 0 && setIndex < allSetsTargets.count && allSetsTargets[setIndex].isWarmup
        if isCurrentSetWarmup {
            print("⌚ [OPTIMISTIC] Skipping timer - warmup set")
        } else {
            showOptimisticTimerIfNeeded()
        }

        // ✅ FIX: Use sendMessage with replyHandler to receive rest timer in response
        // This eliminates the 1-5s latency of applicationContext
        guard let session = session, session.isReachable else {
            // Fallback: Not reachable, use standard sendToiPhone (applicationContext)
            print("⌚ [SYNC] iPhone not reachable, using applicationContext fallback")
            sendToiPhone(data, critical: true, forceImmediate: true)
            WKInterfaceDevice.current().play(.success)
            setsCompleted += 1
            setsCompletedInExercise += 1
            if currentSetNumber < totalSets {
                currentSetNumber += 1
            }
            return
        }

        session.sendMessage(data, replyHandler: { [weak self] response in
            Task { @MainActor in
                guard let self = self else { return }

                print("⌚ [SYNC] ✅ setCompleted reply received")

                // ✅ FIX: Check if response contains rest timer data
                if let timerData = response["restTimer"] as? [String: Any] {
                    print("⌚ [SYNC] 🕐 Rest timer in reply: \(timerData["duration"] ?? 0)s")
                    self.handleRestTimerFromContext(timerData)
                    self.isOptimisticTimer = false  // Confirmed by iPhone
                    self.shouldShowTimer = true
                } else {
                    // No timer in response (last set, or timer disabled)
                    print("⌚ [SYNC] No rest timer in reply (last set or disabled)")
                    self.isOptimisticTimer = false
                    // If we showed optimistic timer for non-last set, clear it
                    if self.currentSetNumber >= self.totalSets {
                        self.restTimer?.invalidate()
                        self.restTimer = nil
                        self.clearTimerState()
                        self.shouldShowTimer = false
                    }
                }
            }
        }) { [weak self] error in
            print("⌚ [SYNC] ⚠️ sendMessage failed: \(error.localizedDescription)")
            // Fallback: queue via transferUserInfo for guaranteed delivery
            self?.session?.transferUserInfo(data)
        }

        // Immediate feedback
        WKInterfaceDevice.current().play(.success)
        setsCompleted += 1
        setsCompletedInExercise += 1  // ✅ FIX: Also increment exercise-level counter for UI
        // ✅ FIX: Optimistic UI update - advance to next set (clamped to totalSets to avoid "Set 4 of 3" glitch)
        if currentSetNumber < totalSets {
            currentSetNumber += 1
        }
    }

    // MARK: - Optimistic Timer (Fix 2)

    /// Show optimistic timer immediately after set completion
    /// Uses the exercise's default rest time until iPhone confirms actual duration
    private func showOptimisticTimerIfNeeded() {
        // Don't show optimistic timer for last set
        guard currentSetNumber < totalSets else {
            print("⌚ [OPTIMISTIC] Last set - no timer needed")
            return
        }

        // Use cached rest time from current exercise (set by iPhone during workout sync)
        // Default to 90s if not available
        let optimisticDuration = cachedExerciseRestTime ?? 90

        print("⌚ [OPTIMISTIC] Showing optimistic timer: \(optimisticDuration)s")

        isOptimisticTimer = true
        restTimeDuration = optimisticDuration
        restTimeRemaining = optimisticDuration
        startRestTimer(duration: optimisticDuration)
        shouldShowTimer = true
    }

    /// 🔥 SUPERSET: Notify iPhone that entire superset round was completed
    /// All exercises in the round are marked as done at once, with a single RPE for the round
    func sendSupersetRoundCompleted(effort: Int? = nil) {
        var data: [String: Any] = [
            "type": WatchMessageType.supersetRoundCompleted,
            "timestamp": Date().timeIntervalSince1970,
            "supersetName": supersetName ?? "Superset",
            "roundNumber": supersetRound,
            "totalRounds": totalSupersetRounds,
            "exercises": supersetExercises
        ]

        if let effort = effort {
            data["effort"] = effort
            data["effortScale"] = effortScale
        }

        // Round completion is critical - must be delivered
        sendToiPhone(data, critical: true, forceImmediate: true)

        WKInterfaceDevice.current().play(.success)

        // Optimistic UI update - increment sets completed by number of exercises in round
        setsCompleted += totalExercisesInSuperset
        // Move to next round (iPhone will send actual state update)
        if supersetRound < totalSupersetRounds {
            supersetRound += 1
        }

        print("⌚ [SUPERSET] Round \(supersetRound) completed with RPE: \(effort ?? -1)")
    }

    /// 🔥 DROPSET: Notify iPhone that a dropset stage was completed
    /// Each stage has different weight, user completes stages in sequence
    func sendDropsetStageCompleted(stageIndex: Int, actualReps: Int, effort: Int? = nil) {
        var data: [String: Any] = [
            "type": WatchMessageType.dropsetStageCompleted,
            "timestamp": Date().timeIntervalSince1970,
            "exerciseName": currentExerciseName,
            "stageIndex": stageIndex,
            "totalStages": totalDropsetStages,
            "actualReps": actualReps
        ]

        if let effort = effort {
            data["effort"] = effort
            data["effortScale"] = effortScale
        }

        // Stage completion is critical
        sendToiPhone(data, critical: true, forceImmediate: true)

        WKInterfaceDevice.current().play(.success)
        setsCompleted += 1

        // Optimistic UI update
        if currentDropsetStage < totalDropsetStages - 1 {
            currentDropsetStage += 1
        }

        print("⌚ [DROPSET] Stage \(stageIndex + 1)/\(totalDropsetStages) completed with \(actualReps) reps, RPE: \(effort ?? -1)")
    }

    /// 🔥 DROPSET: Notify iPhone that entire dropset is completed
    /// - actualLastStageReps: Actual reps performed on the last stage (from reps picker)
    func sendDropsetCompleted(effort: Int? = nil, actualLastStageReps: Int? = nil) {
        var data: [String: Any] = [
            "type": WatchMessageType.dropsetCompleted,
            "timestamp": Date().timeIntervalSince1970,
            "exerciseName": currentExerciseName,
            "totalStages": totalDropsetStages
        ]

        if let reps = actualLastStageReps {
            data["actualReps"] = reps
        }

        if let effort = effort {
            data["effort"] = effort
            data["effortScale"] = effortScale
        }

        sendToiPhone(data, critical: true, forceImmediate: true)
        WKInterfaceDevice.current().play(.success)

        print("⌚ [DROPSET] Completed all \(totalDropsetStages) stages, last stage reps: \(actualLastStageReps ?? -1), RPE: \(effort ?? -1)")
    }

    /// 🔥 REST-PAUSE: Notify iPhone that a rest-pause set was completed
    func sendRestPauseSetCompleted(setIndex: Int, actualReps: Int, effort: Int? = nil) {
        var data: [String: Any] = [
            "type": WatchMessageType.restPauseSetCompleted,
            "timestamp": Date().timeIntervalSince1970,
            "exerciseName": currentExerciseName,
            "setIndex": setIndex,
            "totalSets": totalRestPauseSets,
            "actualReps": actualReps,
            "weight": restPauseWeight
        ]

        if let effort = effort {
            data["effort"] = effort
            data["effortScale"] = effortScale
        }

        sendToiPhone(data, critical: true, forceImmediate: true)

        WKInterfaceDevice.current().play(.success)
        setsCompleted += 1

        // Optimistic UI update
        if currentRestPauseSet < totalRestPauseSets - 1 {
            currentRestPauseSet += 1
        }

        print("⌚ [REST-PAUSE] Set \(setIndex + 1)/\(totalRestPauseSets) completed with \(actualReps) reps, RPE: \(effort ?? -1)")
    }

    /// 🔥 REST-PAUSE: Notify iPhone that entire rest-pause exercise is completed
    /// - actualLastSetReps: Actual reps performed on the last mini-set (from reps picker)
    func sendRestPauseCompleted(effort: Int? = nil, actualLastSetReps: Int? = nil) {
        var data: [String: Any] = [
            "type": WatchMessageType.restPauseCompleted,
            "timestamp": Date().timeIntervalSince1970,
            "exerciseName": currentExerciseName,
            "totalSets": totalRestPauseSets,
            "weight": restPauseWeight
        ]

        if let reps = actualLastSetReps {
            data["actualReps"] = reps
        }

        if let effort = effort {
            data["effort"] = effort
            data["effortScale"] = effortScale
        }

        sendToiPhone(data, critical: true, forceImmediate: true)
        WKInterfaceDevice.current().play(.success)

        print("⌚ [REST-PAUSE] Completed all \(totalRestPauseSets) sets with RPE: \(effort ?? -1)")
    }

    /// Update current set target (weight/reps) before completing
    /// Called when user edits target from Watch before marking set as done
    /// Uses "setModification" type which is already handled by iPhone
    func sendUpdateSetTarget(weight: Double, reps: Int) {
        var data: [String: Any] = [
            "type": WatchMessageType.setModification,  // Reuse existing message type
            "timestamp": Date().timeIntervalSince1970,
            "weight": weight,
            "reps": reps,
            "setNumber": currentSetNumber,
            "exerciseName": currentExerciseName
        ]

        // 🔥 SUPERSET: Add superset context for correct exercise targeting
        if isSuperset {
            data["isSuperset"] = true
            data["exerciseIndexInSuperset"] = currentExerciseInSuperset - 1  // Convert to 0-indexed
            print("⌚ [WATCH] Superset context: exerciseIndex=\(currentExerciseInSuperset - 1)")
        }

        // Target update is important - user explicitly edited it
        sendToiPhone(data, critical: true, forceImmediate: true)

        // ✅ Optimistic UI update - update local display immediately
        targetWeight = weight
        targetReps = reps

        // ✅ FIX: Also update allSetsTargets for views that use it (e.g., ExerciseControlView)
        // This ensures all screens show the updated values immediately, not just screens
        // that read targetWeight/targetReps directly
        let setIndex = currentSetNumber - 1 // 0-indexed
        if setIndex >= 0 && setIndex < allSetsTargets.count {
            let currentTarget = allSetsTargets[setIndex]
            allSetsTargets[setIndex] = (
                weight: weight,
                reps: reps,
                actualReps: currentTarget.actualReps,
                isCompleted: currentTarget.isCompleted,
                isWarmup: currentTarget.isWarmup,
                minReps: currentTarget.minReps,
                maxReps: currentTarget.maxReps
            )
            print("⌚ [WATCH] Updated allSetsTargets[\(setIndex)]: \(weight) kg × \(reps) reps")
        }

        print("⌚ [WATCH] Sent target update: \(weight) kg × \(reps) reps for set \(currentSetNumber)")
    }

    /// Notify iPhone to skip rest timer
    /// User-initiated immediate action with fallback to queue if not reachable
    func sendSkipRest() {
        let data: [String: Any] = [
            "type": WatchMessageType.skipRest,
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
            "type": WatchMessageType.pauseWorkout,
            "timestamp": Date().timeIntervalSince1970
        ]

        sendToiPhone(data, critical: true, forceImmediate: true)
        WKInterfaceDevice.current().play(.stop)

        // FIX: Pause the rest timer when workout is paused
        if restTimer != nil {
            isTimerPaused = true
            restTimer?.invalidate()
            restTimer = nil
        }
    }

    /// Notify iPhone to end/stop the current workout
    func sendEndWorkout(save: Bool = true, duration: TimeInterval = 0, calories: Double = 0) {
        let data: [String: Any] = [
            "type": WatchMessageType.endWorkout,
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
            "type": WatchMessageType.healthMetrics,
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

    /// Send modified set data (weight/reps) to iPhone - modifies TARGET for NEXT set
    func sendSetModification(weight: Double, reps: Int) {
        let data: [String: Any] = [
            "type": WatchMessageType.setModification,
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

    /// ✅ Edit reps of a SPECIFIC completed set (by index)
    /// - Parameters:
    ///   - setIndex: 0-indexed position of the set to edit (0 = first completed set)
    ///   - reps: The new reps value
    /// Called when user wants to correct the reps they actually did for any completed set
    func sendEditCompletedSetReps(setIndex: Int, reps: Int) {
        let data: [String: Any] = [
            "type": WatchMessageType.editCompletedSetReps,
            "setIndex": setIndex,  // 0-indexed
            "reps": reps,
            "timestamp": Date().timeIntervalSince1970
        ]

        print("⌚ [CONNECTIVITY] Sending edit set \(setIndex + 1): \(reps) reps")

        // Critical: This is a correction, must be delivered
        sendToiPhone(data, critical: true, forceImmediate: true)

        WKInterfaceDevice.current().play(.success)
    }

    /// Send uncomplete set request to iPhone
    /// - Parameter setIndex: The 0-indexed set to uncomplete (mark as not done)
    /// Called when user wants to undo a completed set
    func sendUncompleteSet(setIndex: Int) {
        let data: [String: Any] = [
            "type": WatchMessageType.uncompleteSet,
            "setIndex": setIndex,  // 0-indexed
            "timestamp": Date().timeIntervalSince1970
        ]

        print("⌚ [CONNECTIVITY] Sending uncomplete set \(setIndex + 1)")

        // Critical: This is a correction, must be delivered
        sendToiPhone(data, critical: true, forceImmediate: true)

        // Update local state immediately (optimistic UI)
        if setsCompletedInExercise > 0 {
            setsCompletedInExercise -= 1
        }
        // ✅ FIX: Go back to the undone set
        currentSetNumber = setIndex + 1

        WKInterfaceDevice.current().play(.click)
    }

    /// Send timer extension request to iPhone
    /// User-initiated immediate action with fallback to queue if not reachable
    func sendExtendTimer(seconds: Int) {
        let data: [String: Any] = [
            "type": WatchMessageType.extendTimer,
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

    /// Start a new rest timer from Watch
    /// 🆕 Used by QuickAddTimePickerView when timer shows 00:00 and user wants more rest
    /// - Parameter duration: Timer duration in seconds
    func startNewTimer(duration: Int) {
        let data: [String: Any] = [
            "type": WatchMessageType.startNewTimer,
            "duration": duration,
            "timestamp": Date().timeIntervalSince1970
        ]

        // Starting a timer is user-initiated, immediate delivery
        sendToiPhone(data, critical: false, forceImmediate: true)

        // Start local timer immediately for responsive UI
        // This mirrors the timer that will be started on iPhone
        isTimerPaused = false
        isTimerSkipped = false
        startRestTimer(duration: duration)
        shouldShowTimer = true

        print("⌚ [TIMER] Started new timer from Watch: \(duration)s")
    }

    /// Jump to a specific set number
    /// Sends request to iPhone to change the current set
    func jumpToSet(_ setNumber: Int) {
        let data: [String: Any] = [
            "type": WatchMessageType.jumpToSet,
            "setNumber": setNumber,
            "timestamp": Date().timeIntervalSince1970
        ]

        // User-initiated action, immediate delivery
        sendToiPhone(data, critical: false, forceImmediate: true)

        // Update local state immediately for responsive UI
        currentSetNumber = setNumber

        // ✅ FIX: Also update targetWeight/targetReps from allSetsTargets for immediate UI feedback
        let setIndex = setNumber - 1  // Convert 1-indexed to 0-indexed
        if setIndex >= 0 && setIndex < allSetsTargets.count {
            let setData = allSetsTargets[setIndex]
            targetWeight = setData.weight
            targetReps = setData.reps
            minReps = setData.minReps
            maxReps = setData.maxReps
            print("⌚ [SET] Jumped to set \(setNumber): \(setData.weight)kg × \(setData.reps) reps")
        } else {
            print("⌚ [SET] Jumped to set \(setNumber) (no local target data available)")
        }
    }

    /// Copy weight and reps to all sets of current exercise
    /// Sends request to iPhone to apply the same values to all sets
    func copyToAllSets(weight: Double, reps: Int) {
        let data: [String: Any] = [
            "type": WatchMessageType.copyToAllSets,
            "weight": weight,
            "reps": reps,
            "timestamp": Date().timeIntervalSince1970
        ]

        // User-initiated action, immediate delivery
        sendToiPhone(data, critical: false, forceImmediate: true)

        // Update local target for responsive UI
        targetWeight = weight
        targetReps = reps

        // ✅ FIX: Update ALL sets in allSetsTargets for immediate sync across screens
        for i in 0..<allSetsTargets.count {
            let currentTarget = allSetsTargets[i]
            allSetsTargets[i] = (
                weight: weight,
                reps: reps,
                actualReps: currentTarget.actualReps,
                isCompleted: currentTarget.isCompleted,
                isWarmup: currentTarget.isWarmup,
                minReps: currentTarget.minReps,
                maxReps: currentTarget.maxReps
            )
        }

        print("⌚ [SET] Copied weight \(weight) and reps \(reps) to all \(allSetsTargets.count) sets")
    }

    /// Copy weight and reps from the previous set
    /// Sends request to iPhone to copy values from set N-1
    func copyFromPreviousSet() {
        let data: [String: Any] = [
            "type": WatchMessageType.copyFromPreviousSet,
            "currentSetNumber": currentSetNumber,
            "timestamp": Date().timeIntervalSince1970
        ]

        // User-initiated action, immediate delivery
        sendToiPhone(data, critical: false, forceImmediate: true)

        // ✅ FIX: Optimistic local update - copy from previous set in allSetsTargets
        let previousSetIndex = currentSetNumber - 2  // 0-indexed: current is N-1, previous is N-2
        let currentSetIndex = currentSetNumber - 1   // 0-indexed
        if previousSetIndex >= 0 && previousSetIndex < allSetsTargets.count {
            let previousSet = allSetsTargets[previousSetIndex]
            targetWeight = previousSet.weight
            targetReps = previousSet.reps

            // Also update current set in allSetsTargets
            if currentSetIndex >= 0 && currentSetIndex < allSetsTargets.count {
                let currentTarget = allSetsTargets[currentSetIndex]
                allSetsTargets[currentSetIndex] = (
                    weight: previousSet.weight,
                    reps: previousSet.reps,
                    actualReps: currentTarget.actualReps,
                    isCompleted: currentTarget.isCompleted,
                    isWarmup: currentTarget.isWarmup,
                    minReps: currentTarget.minReps,
                    maxReps: currentTarget.maxReps
                )
            }
            print("⌚ [SET] Copied from previous set: \(previousSet.weight)kg × \(previousSet.reps) reps")
        } else {
            print("⌚ [SET] Requested copy from previous set (current: \(currentSetNumber)) - no local data")
        }
    }

    /// Jump to a specific exercise by index
    /// Sends request to iPhone to navigate to a different exercise
    func jumpToExercise(_ exerciseIndex: Int) {
        let data: [String: Any] = [
            "type": WatchMessageType.jumpToExercise,
            "exerciseIndex": exerciseIndex,
            "timestamp": Date().timeIntervalSince1970
        ]

        // User-initiated action, immediate delivery
        sendToiPhone(data, critical: false, forceImmediate: true)

        // Update local state for responsive UI
        currentExerciseIndex = exerciseIndex
        if exerciseIndex < exerciseNames.count {
            currentExerciseName = exerciseNames[exerciseIndex]
        }

        print("⌚ [EXERCISE] Jumped to exercise \(exerciseIndex) from Watch")
    }

    /// Send workout error notification to iPhone
    /// Used when HKWorkoutSession fails unexpectedly
    func sendWorkoutError(message: String) {
        let data: [String: Any] = [
            "type": WatchMessageType.workoutError,
            "message": message,
            "timestamp": Date().timeIntervalSince1970
        ]

        // Error notification is critical - try immediate delivery
        sendToiPhone(data, critical: true, forceImmediate: true)
        print("⌚ [CONNECTIVITY] Sent workout error to iPhone: \(message)")
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
            "type": WatchMessageType.workoutCompleted,
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
            ["type": WatchMessageType.requestTemplates],
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
    /// @deprecated Use syncWorkoutStateFromiPhone() instead for race-condition safe sync
    func requestWorkoutState() {
        print("⚠️ [WATCH] requestWorkoutState() called - redirecting to syncWorkoutStateFromiPhone()")
        syncWorkoutStateFromiPhone(skipCache: true)
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
            guard let id = dict.stringValue(for: "id"),
                  let name = dict.stringValue(for: "name") else {
                return nil
            }
            return WorkoutTemplate(id: id, name: name, exercises: [])
        }
    }

    // P1-4 FIX: Refactored with type-safe PayloadParsing helpers
    // Centralizes NSNumber coercion (Flutter sends numbers via WCSession as NSNumber)
    private func handleWorkoutUpdate(_ data: [String: Any]) {
        // Note: DO NOT update isWorkoutActive here — managed by message handlers only

        // Track if exercise changed to reset stale set targets
        let previousExercise = currentExerciseName
        if let exercise = data.stringValue(for: "exerciseName") {
            currentExerciseName = exercise
            if exercise != previousExercise {
                print("⌚ [WATCH] Exercise changed: '\(previousExercise)' → '\(exercise)'")
                allSetsTargets = []
            }
        }

        // Core exercise state
        if let v = data.intValue(for: "currentSet") { currentSetNumber = v }
        if let v = data.intValue(for: "totalSets") { totalSets = v }
        if let v = data.doubleValue(for: "targetWeight") { targetWeight = v }
        if let v = data.intValue(for: "targetReps") { targetReps = v }
        // ⌚ Rep range support
        minReps = data.intValue(for: "minReps")
        maxReps = data.intValue(for: "maxReps")
        if let v = data.intValue(for: "setsCompleted") { setsCompleted = v }
        if let v = data.intValue(for: "setsCompletedInExercise") { setsCompletedInExercise = v }
        if let v = data.intValue(for: "lastCompletedReps") { lastCompletedReps = v }

        // Settings
        if let v = data.boolValue(for: "rpeTrackingEnabled") { rpeTrackingEnabled = v }
        if let v = data.stringValue(for: "effortScale") { effortScale = v }
        if let v = data.stringValue(for: "locale") { appLocale = v }
        if let v = data.stringValue(for: "workoutType") { workoutType = v }

        // Optional strings (nil if empty)
        formCues = data.optionalString(for: "formCues")
        tut = data.optionalString(for: "tut")

        // Exercise navigation
        if let names = data.stringArray(for: "exerciseNames") {
            exerciseNames = names
            totalExercises = names.count
        }
        if let v = data.intValue(for: "currentExerciseIndex") { currentExerciseIndex = v }
        if let v = data.intValue(for: "totalExercises") { totalExercises = v }

        // All sets' targets (for set navigation)
        if let setsArray = data.dictArray(for: "allSets") {
            allSetsTargets = setsArray.compactMap { s in
                guard let weight = s.doubleValue(for: "weight"),
                      let reps = s.intValue(for: "reps") else {
                    print("⌚ [WATCH] ⚠️ Failed to parse set: \(s)")
                    return nil
                }
                return (
                    weight: weight,
                    reps: reps,
                    actualReps: s.intValue(for: "actualReps"),
                    isCompleted: s.boolValue(for: "isCompleted") ?? false,
                    isWarmup: s.boolValue(for: "isWarmup") ?? false,
                    minReps: s.intValue(for: "minReps"),
                    maxReps: s.intValue(for: "maxReps")
                )
            }
            let completed = allSetsTargets.filter { $0.isCompleted }.count
            print("⌚ [WATCH] Parsed \(allSetsTargets.count) sets (\(completed) completed)")
        } else if data["allSets"] != nil {
            print("⌚ [WATCH] ⚠️ allSets exists but couldn't parse")
        }

        // Superset state
        isSuperset = data.boolValue(for: "isSuperset") ?? false
        if isSuperset {
            supersetName = data.optionalString(for: "supersetName")
            if let ex = data.stringArray(for: "supersetExercises") { supersetExercises = ex }
            if let v = data.intValue(for: "currentExerciseInSuperset") { currentExerciseInSuperset = v }
            if let v = data.intValue(for: "totalExercisesInSuperset") { totalExercisesInSuperset = v }
            if let v = data.intValue(for: "supersetRound") { supersetRound = v }
            if let v = data.intValue(for: "totalSupersetRounds") { totalSupersetRounds = v }
            print("⌚ [WATCH] 🔥 SUPERSET: \(supersetName ?? "?") - Ex \(currentExerciseInSuperset)/\(totalExercisesInSuperset), R\(supersetRound)/\(totalSupersetRounds)")
        } else {
            supersetName = nil
            supersetExercises = []
            currentExerciseInSuperset = 0
            totalExercisesInSuperset = 0
            supersetRound = 0
            totalSupersetRounds = 0
        }

        // Cache rest time for optimistic timer
        if let restTime = data.intValue(for: "restTime"), restTime > 0 {
            updateCachedRestTime(restTime)
            print("⌚ [WATCH] Cached rest time: \(restTime)s")
        }

        // Dropset state
        isDropset = data.boolValue(for: "isDropset") ?? false
        if isDropset {
            if let stages = data.dictArray(for: "dropsetStages") {
                dropsetStages = stages.compactMap { s in
                    guard let weight = s.doubleValue(for: "weight"),
                          let reps = s.intValue(for: "reps") else { return nil }
                    return (weight: weight, reps: reps, isCompleted: s.boolValue(for: "isCompleted") ?? false)
                }
                totalDropsetStages = dropsetStages.count
            }
            if let v = data.intValue(for: "currentDropsetStage") { currentDropsetStage = v }
            print("⌚ [WATCH] 🔥 DROPSET: Stage \(currentDropsetStage + 1)/\(totalDropsetStages)")
        } else {
            dropsetStages = []
            currentDropsetStage = 0
            totalDropsetStages = 0
        }

        // Rest-pause state
        isRestPause = data.boolValue(for: "isRestPause") ?? false
        if isRestPause {
            if let v = data.doubleValue(for: "restPauseWeight") { restPauseWeight = v }
            if let v = data.intValue(for: "restPauseTargetReps") { restPauseTargetReps = v }
            if let sets = data.dictArray(for: "restPauseSets") {
                restPauseSets = sets.compactMap { s in
                    guard let reps = s.intValue(for: "reps") else { return nil }
                    return (
                        reps: reps,
                        restSeconds: s.intValue(for: "restSeconds") ?? 0,
                        isCompleted: s.boolValue(for: "isCompleted") ?? false
                    )
                }
                totalRestPauseSets = restPauseSets.count
            }
            if let v = data.intValue(for: "currentRestPauseSet") { currentRestPauseSet = v }
            print("⌚ [WATCH] 🔥 REST-PAUSE: \(restPauseWeight)kg ×\(restPauseTargetReps), Set \(currentRestPauseSet + 1)/\(totalRestPauseSets)")
        } else {
            restPauseWeight = 0
            restPauseTargetReps = 0
            restPauseSets = []
            currentRestPauseSet = 0
            totalRestPauseSets = 0
        }
    }

    private func handleRestTimerUpdate(_ data: [String: Any]) {
        if let duration = data.intValue(for: "duration") {
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
                    // P2-10 FIX: Use Task instead of DispatchQueue
                    Task { @MainActor [weak self] in
                        try? await Task.sleep(for: .seconds(3))
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

                // P2-10 FIX: Use Task instead of DispatchQueue
                Task { @MainActor [weak self] in
                    try? await Task.sleep(for: .milliseconds(500))
                    self?.processPendingMessages()
                }

                Task { @MainActor [weak self] in
                    try? await Task.sleep(for: .milliseconds(800))
                    self?.syncWorkoutStateFromiPhone()
                    print("⌚ [RECOVERY] Unified sync after connection restored")
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
        // P0-2 FIX: Route through serial channel for ordering guarantee
        incomingContinuation?.yield(.message(message))
    }

    // Receive messages from iPhone WITH reply handler
    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        // P0-2 FIX: Route through serial channel for ordering guarantee
        incomingContinuation?.yield(.message(message))
        replyHandler(["success": true, "timestamp": Date().timeIntervalSince1970])
    }

    // P0-2 FIX: @MainActor message handler called serially from AsyncStream
    private func handleIncomingMessage(_ message: [String : Any]) {
            guard let type = message.stringValue(for: "type") else { return }

            switch type {
            case WatchMessageType.workoutStarted:
                isWorkoutActive = true
                handleWorkoutUpdate(message)
                playWorkoutStartHapticIfNeeded()

            case WatchMessageType.workoutEnded:
                // ✅ FIX: Complete cleanup of workout and timer state
                // ✅ FIX: Read save flag to determine if HKWorkoutSession should be saved
                // Default to true for backwards compatibility
                shouldSaveWorkoutToHealthKit = message.boolValue(for: "save") ?? true
                isWorkoutActive = false
                restTimer?.invalidate()
                restTimer = nil
                clearTimerState()
                shouldShowTimer = false
                shouldNavigateToExercise = false
                WKInterfaceDevice.current().play(.success)

            case WatchMessageType.workoutPaused:
                // FIX: Pause rest timer when workout is paused from iPhone
                if restTimer != nil {
                    isTimerPaused = true
                    restTimer?.invalidate()
                    restTimer = nil
                }

            case WatchMessageType.workoutUpdate:
                handleWorkoutUpdate(message)

            case WatchMessageType.restTimerStarted:
                handleRestTimerUpdate(message)
                objectWillChange.send()
                shouldShowTimer = true

            case WatchMessageType.restTimerSkipped:
                isTimerSkipped = true
                restTimer?.invalidate()
                restTimer = nil
                restTimeRemaining = 0

            case WatchMessageType.restTimerPaused:
                isTimerPaused = true
                restTimer?.invalidate()
                restTimer = nil
                if let remaining = message.intValue(for: "remainingTime") {
                    restTimeRemaining = remaining
                }
                WKInterfaceDevice.current().play(.notification)

            case WatchMessageType.restTimerResumed:
                if let remaining = message.intValue(for: "remainingTime"), remaining > 0 {
                    isTimerPaused = false
                    isTimerSkipped = false
                    restTimeRemaining = remaining
                    startRestTimer(duration: remaining)
                }
                WKInterfaceDevice.current().play(.start)

            case WatchMessageType.restTimerExtended:
                let addedSeconds = message.intValue(for: "addedSeconds") ?? 30
                let timestamp = message.doubleValue(for: "timestamp") ?? Date().timeIntervalSince1970

                // Dedupe: Skip if we already processed this extension (within 2s window)
                if let lastExtend = lastTimerExtendTimestamp, abs(timestamp - lastExtend) < 2.0 {
                    print("⌚ [WATCH] Skipping duplicate timer extension")
                    break
                }
                lastTimerExtendTimestamp = timestamp

                let newRemainingFromIPhone = message.intValue(for: "newDuration") ?? (restTimeRemaining + addedSeconds)
                let oldRemaining = restTimeRemaining

                print("⌚ [WATCH] Rest timer extended: +\(addedSeconds)s (was \(oldRemaining)s, now \(newRemainingFromIPhone)s)")

                // Use iPhone's authoritative remaining time
                restTimeRemaining = newRemainingFromIPhone

                // Restart the timer with the extended duration if timer is running
                // (not paused and not skipped)
                if !isTimerPaused && !isTimerSkipped && restTimeRemaining > 0 {
                    restTimer?.invalidate()
                    startRestTimer(duration: restTimeRemaining)
                }

                // Haptic feedback to confirm extension
                WKInterfaceDevice.current().play(.click)

            case WatchMessageType.templatesUpdate:
                if let templates = message["templates"] as? [[String: Any]] {
                    parseTemplates(templates)
                }

            case WatchMessageType.requestFullWorkoutSnapshot:
                let snapshot = buildFullWorkoutSnapshot()
                sendToiPhone(snapshot, critical: true, forceImmediate: true)

            default:
                break
            }
    }

    /// Build a full snapshot of current Watch workout state for Phone crash recovery.
    /// Serializes all @Published workout properties into a dictionary that the Phone
    /// can use to merge with its stale Hive draft.
    private func buildFullWorkoutSnapshot() -> [String: Any] {
        var snapshot: [String: Any] = [
            "type": WatchMessageType.fullWorkoutSnapshot,
            "hasActiveWorkout": isWorkoutActive,
            "timestamp": Date().timeIntervalSince1970,
        ]

        guard isWorkoutActive else { return snapshot }

        snapshot["currentExerciseName"] = currentExerciseName
        snapshot["currentExerciseIndex"] = currentExerciseIndex
        snapshot["exerciseNames"] = exerciseNames
        snapshot["currentSetNumber"] = currentSetNumber
        snapshot["totalSets"] = totalSets
        snapshot["targetWeight"] = targetWeight
        snapshot["targetReps"] = targetReps
        snapshot["setsCompleted"] = setsCompleted
        snapshot["setsCompletedInExercise"] = setsCompletedInExercise

        // ⌚ Rep range support
        if let minReps = minReps { snapshot["minReps"] = minReps }
        if let maxReps = maxReps { snapshot["maxReps"] = maxReps }

        // Serialize allSetsTargets as array of dicts
        snapshot["allSetsTargets"] = allSetsTargets.map { set -> [String: Any] in
            var d: [String: Any] = [
                "weight": set.weight,
                "reps": set.reps,
                "isCompleted": set.isCompleted,
                "isWarmup": set.isWarmup,
            ]
            if let actualReps = set.actualReps {
                d["actualReps"] = actualReps
            }
            if let minReps = set.minReps {
                d["minReps"] = minReps
            }
            if let maxReps = set.maxReps {
                d["maxReps"] = maxReps
            }
            return d
        }

        // Health metrics
        snapshot["heartRate"] = currentHeartRate
        snapshot["calories"] = 0.0  // Calories tracked via HealthKit, not stored here
        snapshot["elapsedTime"] = 0.0  // Elapsed time tracked via HKWorkoutSession

        // Advanced workout modes
        snapshot["isSuperset"] = isSuperset
        snapshot["isDropset"] = isDropset
        snapshot["isRestPause"] = isRestPause

        // Rest timer state
        snapshot["restTimeRemaining"] = restTimeRemaining
        snapshot["restTimeDuration"] = restTimeDuration

        return snapshot
    }

    // Receive application context (state sync) - PRIMARY delivery method
    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {
        // P0-2 FIX: Route through serial channel for ordering guarantee
        incomingContinuation?.yield(.applicationContext(applicationContext))
    }

    // P0-2 FIX: @MainActor context handler called serially from AsyncStream
    private func handleIncomingApplicationContext(_ applicationContext: [String : Any]) {
            // Sync workout state
            if let workoutData = applicationContext["workout"] as? [String: Any] {
                if let type = workoutData.stringValue(for: "type") {
                    if type == "workoutStarted" {
                        let exerciseName = workoutData.stringValue(for: "exerciseName") ?? "Workout"

                        if !isWorkoutActive {
                            NotificationManager.shared.showWorkoutStartedNotification(
                                exerciseName: exerciseName
                            )
                        }

                        isWorkoutActive = true
                        handleWorkoutUpdate(workoutData)
                        playWorkoutStartHapticIfNeeded()

                    } else if type == "workoutEnded" {
                        shouldSaveWorkoutToHealthKit = workoutData.boolValue(for: "save") ?? true
                        isWorkoutActive = false
                        restTimer?.invalidate()
                        restTimer = nil
                        clearTimerState()
                        shouldShowTimer = false
                        shouldNavigateToExercise = false
                        WKInterfaceDevice.current().play(.success)
                    } else if type == "workoutUpdate" {
                        if isWorkoutActive {
                            handleWorkoutUpdate(workoutData)
                            print("⌚ [CONTEXT] workoutUpdate synced from iPhone")
                        }
                    }
                }

                if let isActive = workoutData.boolValue(for: "isActive") {
                    if isActive && !isWorkoutActive {
                        let exerciseName = workoutData.stringValue(for: "exerciseName") ?? "Workout"

                        NotificationManager.shared.showWorkoutStartedNotification(
                            exerciseName: exerciseName
                        )

                        isWorkoutActive = true
                        handleWorkoutUpdate(workoutData)
                        playWorkoutStartHapticIfNeeded()
                    } else if !isActive && isWorkoutActive {
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

    /// Handle rest timer from applicationContext with proper time sync
    private func handleRestTimerFromContext(_ data: [String: Any]) {
        // ✅ FIX: Only start timer if workout is active
        // This prevents timer from restarting after workout ends
        guard isWorkoutActive else {
            print("⏱️ [TIMER] Ignoring timer context - workout not active")
            return
        }

        guard let duration = data.intValue(for: "duration"),
              let startTime = data.doubleValue(for: "startTime") else {
            return
        }

        // Check if timer is paused (from applicationContext sync)
        if let isPaused = data.boolValue(for: "isPaused"), isPaused {
            let remainingTime = data.intValue(for: "remainingTime") ?? duration
            print("⏱️ [TIMER] Timer is PAUSED from applicationContext: \(remainingTime)s remaining")

            isTimerPaused = true
            restTimeRemaining = remainingTime
            restTimeDuration = duration
            restTimer?.invalidate()
            restTimer = nil

            objectWillChange.send()
            shouldShowTimer = true
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
            isTimerPaused = false  // ✅ Ensure paused flag is cleared

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
            guard let type = userInfo.stringValue(for: "type") else { return }

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
