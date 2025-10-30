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

        // OPTIMIZATION: Deactivate in background to avoid UI blocking (~500ms improvement)
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }

            // ✅ FIX #3: CRITICAL - Always deactivate first (ignore errors) + add delay
            try? self.session.setActive(false, options: .notifyOthersOnDeactivation)
            Thread.sleep(forTimeInterval: 0.01)  // 10ms delay for CoreAudio to process
            Logger.shared.log(.debug, "[TIMER-DEBUG] Audio session deactivated with delay")

            // Configure on main queue for safety
            DispatchQueue.main.async {
                do {
                    // ✅ FIX #3: TWO-STAGE APPROACH - Activate WITHOUT .duckOthers first
                    // This avoids OSStatus -50 when combining options
                    try self.session.setCategory(.playback, mode: .default, options: [
                        .mixWithOthers,
                        .allowBluetooth,
                        .allowBluetoothA2DP
                    ])

                    // Activate with high priority
                    try self.session.setActive(true, options: [])
                    Logger.shared.log(.debug, "[TIMER-DEBUG] Audio session activated (stage 1)")

                    // ✅ FIX #3: NOW add .duckOthers AFTER activation
                    try self.session.setCategory(.playback, mode: .default, options: [
                        .mixWithOthers,
                        .duckOthers,  // Add ducking AFTER activation
                        .allowBluetooth,
                        .allowBluetoothA2DP
                    ])

                    Logger.shared.log(.info, "[TIMER-DEBUG] ✅ Audio session reactivated with ducking (stage 2)")

                } catch {
                    Logger.shared.log(.error, "[TIMER-DEBUG] ❌ Reactivation failed: \(error.audioSessionErrorDescription)")

                    // ✅ FIX #3: Fallback to minimal configuration
                    do {
                        try? self.session.setActive(false, options: [])
                        try self.session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
                        try self.session.setActive(true, options: [])
                        Logger.shared.log(.info, "[TIMER-DEBUG] ✅ Fallback audio configuration applied")
                    } catch {
                        Logger.shared.log(.error, "[TIMER-DEBUG] ❌ Even fallback failed: \(error.localizedDescription)")
                    }
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
        // ✅ FIX #3: Simplified configuration to fix OSStatus -50
        // Removed .allowAirPlay which may cause conflicts
        let targetOptions: AVAudioSession.CategoryOptions = [
            .mixWithOthers,      // Allow mixing with Spotify and other audio
            .allowBluetooth,
            .allowBluetoothA2DP
        ]

        // Check if already configured correctly
        if lastConfiguredCategory == .playback,
           lastConfiguredOptions == targetOptions,
           session.category == .playback {
            Logger.shared.log(.debug, "Foreground audio already configured, skipping")
            return
        }

        Logger.shared.log(.info, "Configuring foreground audio...")

        // ✅ FIX #3: CRITICAL - Always deactivate first (ignore errors) + add delay
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
        Thread.sleep(forTimeInterval: 0.01)  // 10ms delay for CoreAudio to process
        Logger.shared.log(.debug, "Audio session deactivated with delay")

        // Configure for foreground with simplified options
        try session.setCategory(.playback, mode: .default, options: targetOptions)

        // Activate with high priority
        try session.setActive(true, options: [])

        // Cache configuration
        lastConfiguredCategory = .playback
        lastConfiguredOptions = targetOptions

        Logger.shared.log(.info, "✅ Foreground audio configured successfully")
    }
    
    private func configureBackgroundAudio() throws {
        // ✅ FIX #3: Simplified configuration to fix OSStatus -50
        // Removed .allowAirPlay which may cause conflicts
        let targetOptions: AVAudioSession.CategoryOptions = [
            .mixWithOthers,     // Allow mixing with Spotify and other audio
            .allowBluetooth,    // Allow Bluetooth audio
            .allowBluetoothA2DP // Allow high-quality Bluetooth
        ]

        // Check if already configured correctly
        if lastConfiguredCategory == .playback,
           lastConfiguredOptions == targetOptions,
           session.category == .playback {
            Logger.shared.log(.debug, "Background audio already configured, skipping")
            return
        }

        Logger.shared.log(.info, "Configuring background audio...")

        // ✅ FIX #3: CRITICAL - Always deactivate first (ignore errors) + add delay
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
        Thread.sleep(forTimeInterval: 0.01)  // 10ms delay for CoreAudio to process
        Logger.shared.log(.debug, "Audio session deactivated with delay")

        // Configure for background silent track + completion sounds
        try session.setCategory(.playback, mode: .default, options: targetOptions)

        // ENHANCED: Set preferred buffer duration for efficient silent loop
        try session.setPreferredIOBufferDuration(0.1) // 100ms buffer for efficiency

        // Activate with high priority for lockscreen
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

        // ✅ FIX #3: CRITICAL - Deactivate first with delay to avoid OSStatus -50
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
        Thread.sleep(forTimeInterval: 0.01)  // 10ms delay for CoreAudio to process

        // ✅ FIX #3: Simplified configuration (removed .allowAirPlay)
        try session.setCategory(.playback, mode: .default, options: [
            .mixWithOthers,   // Don't interrupt Spotify or other audio
            .allowBluetooth,  // Allow Bluetooth
            .allowBluetoothA2DP // Allow high-quality Bluetooth
        ])

        // Set optimal buffer for battery efficiency
        try session.setPreferredIOBufferDuration(0.1)

        // Set low sample rate for efficiency (silent audio doesn't need high quality)
        try session.setPreferredSampleRate(22050) // Half of CD quality is enough

        // Activate session with high priority
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