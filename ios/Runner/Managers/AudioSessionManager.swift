import AVFoundation
import UIKit

/// Protocol for testability and dependency injection
protocol AudioSessionManaging {
    func configureForLaunch()
    func transitionToBackground()
    func transitionToForeground()
    func validateConfiguration() -> Bool
    func reactivate()
}

/// Manages AVAudioSession configuration with state machine for safe transitions
final class AudioSessionManager: AudioSessionManaging {
    
    // MARK: - State Management
    
    enum State: String {
        case uninitialized
        case foreground
        case background
        case transitioning
        
        var debugDescription: String {
            switch self {
            case .uninitialized: return "🔴 Uninitialized"
            case .foreground: return "🟢 Foreground"
            case .background: return "🔵 Background"
            case .transitioning: return "🟡 Transitioning"
            }
        }
    }
    
    // MARK: - Properties
    
    static let shared = AudioSessionManager()
    
    private var currentState: State = .uninitialized
    private let stateQueue = DispatchQueue(label: "com.gymbro.audio.state", qos: .userInitiated)
    private var session: AVAudioSession { AVAudioSession.sharedInstance() }
    
    // Configuration cache to avoid redundant setups
    private var lastConfiguredCategory: AVAudioSession.Category?
    private var lastConfiguredOptions: AVAudioSession.CategoryOptions?

    // ✅ FIX #4: Validation result caching to reduce overhead
    private var lastValidationResult: Bool?
    private var lastValidationTime: Date?
    private let validationCacheDuration: TimeInterval = 1.0  // Cache for 1 second

    // Throttle transitions to avoid rapid reconfiguration
    private var lastTransitionTime: Date?
    private let minimumTransitionInterval: TimeInterval = 0.5  // Minimum 500ms between transitions
    
    // MARK: - Initialization
    
    private init() {
        Logger.shared.log(.info, "AudioSessionManager initialized")
    }
    
    // MARK: - Public Methods
    
    func configureForLaunch() {
        stateQueue.sync {
            Logger.shared.log(.info, "[TIMER-DEBUG] configureForLaunch called, current state: \(currentState.debugDescription)")
            guard currentState == .uninitialized else {
                Logger.shared.log(.warning, "[TIMER-DEBUG] AudioSession already configured, state: \(currentState.debugDescription)")
                return
            }
            
            performTransition(to: .foreground)
        }
    }
    
    func transitionToBackground() {
        stateQueue.sync {
            guard currentState != .background else {
                Logger.shared.log(.debug, "Already in background state")
                return
            }
            
            performTransition(to: .background)
        }
    }
    
    func transitionToForeground() {
        stateQueue.sync {
            guard currentState != .foreground else {
                Logger.shared.log(.debug, "Already in foreground state")
                return
            }
            
            performTransition(to: .foreground)
        }
    }
    
    func validateConfiguration() -> Bool {
        // ✅ FIX #4: Use cached validation result if recent enough
        if let cachedResult = lastValidationResult,
           let cachedTime = lastValidationTime,
           Date().timeIntervalSince(cachedTime) < validationCacheDuration {
            return cachedResult
        }

        let isValid = session.category == .playback &&
                     (currentState == .background ?
                      session.categoryOptions.contains(.mixWithOthers) : true)

        // ENHANCED: Additional validation for silent loop compatibility
        let silentLoopReady = currentState == .background ?
            (session.categoryOptions.contains(.mixWithOthers) &&
             session.preferredIOBufferDuration <= 0.2) : true

        let overallValid = isValid && silentLoopReady

        // ✅ FIX #4: Cache the validation result
        lastValidationResult = overallValid
        lastValidationTime = Date()

        Logger.shared.log(
            overallValid ? .debug : .warning,
            "Audio configuration validation: \(overallValid ? "✅ Valid (silent loop ready)" : "❌ Invalid")"
        )

        return overallValid
    }
    
    func reactivate() {
        Logger.shared.log(.info, "[TIMER-DEBUG] reactivate called")

        // Configure on background queue to avoid UI blocking
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }

            do {
                // ✅ FIX: Do NOT deactivate first! That releases audio to other apps.
                // Just set category directly (safe to call even if already set)
                let currentCategory = self.session.category
                let currentOptions = self.session.categoryOptions

                if currentCategory != .playback || !currentOptions.contains(.mixWithOthers) {
                    Logger.shared.log(.info, "[TIMER-DEBUG] Reconfiguring (current: \(currentCategory.rawValue))")
                    try self.session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
                }

                // Activate (safe to call even if already active)
                try self.session.setActive(true, options: [])

                Logger.shared.log(.info, "[TIMER-DEBUG] ✅ Audio session reactivated successfully")

            } catch {
                Logger.shared.log(.error, "[TIMER-DEBUG] ❌ Reactivation failed: \(error.audioSessionErrorDescription)")

                // Last resort: just try to activate without changing category
                do {
                    try self.session.setActive(true, options: [])
                    Logger.shared.log(.info, "[TIMER-DEBUG] ✅ Fallback: session activated (kept existing category)")
                } catch {
                    Logger.shared.log(.error, "[TIMER-DEBUG] ❌ Even activation-only failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func performTransition(to targetState: State) {
        let previousState = currentState

        // Throttle rapid transitions
        if let lastTime = lastTransitionTime,
           Date().timeIntervalSince(lastTime) < minimumTransitionInterval {
            Logger.shared.log(.debug, "Throttling transition - too soon after last transition (\(Date().timeIntervalSince(lastTime))s)")
            return
        }

        currentState = .transitioning

        Logger.shared.log(.info, "[TIMER-DEBUG] Audio transition: \(previousState.debugDescription) → \(targetState.debugDescription)")

        do {
            switch targetState {
            case .foreground:
                try configureForegroundAudio()

            case .background:
                try configureBackgroundAudio()

            default:
                Logger.shared.log(.error, "Invalid transition to \(targetState)")
                currentState = previousState
                return
            }

            currentState = targetState
            lastTransitionTime = Date()

            // ✅ FIX #4: Invalidate validation cache when configuration changes
            lastValidationResult = nil
            lastValidationTime = nil

            Logger.shared.log(.info, "✅ Audio transition completed: \(targetState.debugDescription)")

        } catch {
            currentState = previousState
            Logger.shared.log(.error, "❌ Audio transition failed: \(error.audioSessionErrorDescription)")
            ErrorRecoveryManager.shared.handle(
                error,
                context: .audioSession,
                strategy: .fallback {
                    Logger.shared.log(.error, "Reverting to \(previousState.debugDescription)")
                }
            )
        }
    }
    
    private func configureForegroundAudio() throws {
        // ✅ FIX: MINIMAL configuration to fix OSStatus -50
        // Only use .mixWithOthers - other options can fail at app startup
        let targetOptions: AVAudioSession.CategoryOptions = [.mixWithOthers]

        // Check if already configured correctly
        if lastConfiguredCategory == .playback,
           lastConfiguredOptions == targetOptions,
           session.category == .playback {
            Logger.shared.log(.debug, "Foreground audio already configured, skipping")
            return
        }

        Logger.shared.log(.info, "Configuring foreground audio...")

        // ✅ FIX: Do NOT deactivate first! That releases audio to other apps.
        // Just set category directly - this is safe to call even if already set

        // Configure with minimal options
        try session.setCategory(.playback, mode: .default, options: targetOptions)
        try session.setActive(true, options: [])

        // Cache configuration
        lastConfiguredCategory = .playback
        lastConfiguredOptions = targetOptions

        Logger.shared.log(.info, "✅ Foreground audio configured successfully")
    }
    
    private func configureBackgroundAudio() throws {
        // ✅ FIX: MINIMAL configuration to fix OSStatus -50
        // Only use .mixWithOthers - safest option
        let targetOptions: AVAudioSession.CategoryOptions = [.mixWithOthers]

        // Check if already configured correctly
        if lastConfiguredCategory == .playback,
           lastConfiguredOptions == targetOptions,
           session.category == .playback {
            Logger.shared.log(.debug, "Background audio already configured, skipping")
            return
        }

        Logger.shared.log(.info, "Configuring background audio...")

        // ✅ FIX: Do NOT deactivate first! That releases audio to other apps.
        // Just set category directly - this is safe to call even if already set

        // Configure with minimal options
        try session.setCategory(.playback, mode: .default, options: targetOptions)

        // Buffer duration is optional - don't fail if not supported
        try? session.setPreferredIOBufferDuration(0.1)

        try session.setActive(true, options: [])

        // Cache configuration
        lastConfiguredCategory = .playback
        lastConfiguredOptions = targetOptions

        Logger.shared.log(.info, "✅ Background audio configured for lockscreen playback")
    }
    
    // MARK: - Debug Helpers
    
    func debugPrintCurrentState() {
        Logger.shared.log(.debug, """
            AudioSession Debug Info:
            - State: \(currentState.debugDescription)
            - Category: \(session.category.rawValue)
            - Mode: \(session.mode.rawValue)
            - Options: \(session.categoryOptions.rawValue)
            - Other audio playing: \(session.isOtherAudioPlaying)
            - Output volume: \(session.outputVolume)
            - Buffer duration: \(session.preferredIOBufferDuration)s
            - Silent loop compatible: \(session.categoryOptions.contains(.mixWithOthers) && session.preferredIOBufferDuration <= 0.2)
            """)
    }
    
    // MARK: - Silent Loop Support
    
    /// Configures audio session specifically for silent loop playback
    func configureSilentLoopSession() throws {
        Logger.shared.log(.info, "Configuring audio session for lockscreen audio support")

        // ✅ FIX: Do NOT deactivate first! That releases audio to other apps.
        // Instead, check if already configured correctly and just set category.

        let currentCategory = session.category
        let currentOptions = session.categoryOptions
        let needsReconfigure = currentCategory != .playback || !currentOptions.contains(.mixWithOthers)

        if needsReconfigure {
            Logger.shared.log(.info, "📱 Reconfiguring audio session (current: \(currentCategory.rawValue), options: \(currentOptions.rawValue))")

            // ✅ KEY FIX: Just set category WITHOUT deactivating first
            // This preserves our audio session ownership
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])

            // Optional preferences (ignore failures)
            try? session.setPreferredIOBufferDuration(0.1)
            try? session.setPreferredSampleRate(22050)
        } else {
            Logger.shared.log(.info, "📱 Audio session already configured correctly, skipping category change")
        }

        // Activate session (safe to call even if already active)
        try session.setActive(true, options: [])

        Logger.shared.log(.info, "✅ Audio session configured for lockscreen playback")
    }
    
    /// Restores normal audio session after silent loop
    func restoreFromSilentLoop() throws {
        Logger.shared.log(.info, "Restoring audio session from silent loop mode")

        // Reset to normal playback configuration
        try configureBackgroundAudio()

        Logger.shared.log(.info, "✅ Audio session restored from silent loop")
    }

    // ✅ FIX #3: Cleanup audio session when timer is skipped
    /// Properly deactivates and cleans up the audio session
    /// Used when timer is skipped to prevent resource leaks
    func cleanupForSkip() {
        stateQueue.sync {
            Logger.shared.log(.info, """
                🧹 [FIX-3] Cleaning up audio session for timer skip:
                - Current state: \(currentState.debugDescription)
                - Deactivating audio session
                - Clearing cached configuration
                """, category: .audioSession)

            // ✅ FIX #7: Track cleanup performance
            let startTime = Date()
            var cleanupSuccess = false

            do {
                // Deactivate audio session, notifying other apps
                try session.setActive(false, options: .notifyOthersOnDeactivation)

                // Clear cached configuration to force reconfiguration next time
                lastConfiguredCategory = nil
                lastConfiguredOptions = nil

                // ✅ FIX #4: Clear validation cache when cleaning up
                lastValidationResult = nil
                lastValidationTime = nil

                // Reset state
                currentState = .uninitialized

                cleanupSuccess = true
                Logger.shared.log(.info, "✅ [FIX-3] Audio session cleanup complete", category: .audioSession)
            } catch {
                Logger.shared.log(.error, """
                    ❌ [FIX-3] Audio session cleanup failed: \(error.audioSessionErrorDescription)
                    - Will attempt cleanup on next activation
                    """, category: .audioSession)

                // Force reset state even if deactivation failed
                lastConfiguredCategory = nil
                lastConfiguredOptions = nil
                lastValidationResult = nil
                lastValidationTime = nil
                currentState = .uninitialized
            }

            // ✅ FIX #7: Record cleanup metrics
            // let duration = Date().timeIntervalSince(startTime)
            // PerformanceMetrics.shared.recordMetric(
            //     operation: PerformanceMetrics.Operation.audioSessionCleanup,
            //     duration: duration,
            //     success: cleanupSuccess
            // )
        }
    }
}

// MARK: - Silent Loop Configuration Constants

extension AudioSessionManager {
    struct SilentLoopConfig {
        static let optimalBufferDuration: TimeInterval = 0.1
        static let optimalSampleRate: Double = 22050
        static let maxAllowedLatency: TimeInterval = 0.2
    }
}

// MARK: - Error Extension

extension Error {
    var audioSessionErrorDescription: String {
        if let nsError = self as NSError? {
            // Enhanced error descriptions for silent loop debugging
            let codeDescription: String
            switch nsError.code {
            case AVAudioSession.ErrorCode.cannotInterruptOthers.rawValue:
                codeDescription = "Cannot interrupt other audio (check mixWithOthers option)"
            // case AVAudioSession.ErrorCode.categoryNotAvailable.rawValue: // Not available in current SDK
            //     codeDescription = "Category not available (check background modes)"
            case AVAudioSession.ErrorCode.insufficientPriority.rawValue:
                codeDescription = "Insufficient priority (other app has audio focus)"
            default:
                codeDescription = nsError.localizedDescription
            }
            return "Audio Error [Code: \(nsError.code)] \(codeDescription)"
        }
        return localizedDescription
    }
}