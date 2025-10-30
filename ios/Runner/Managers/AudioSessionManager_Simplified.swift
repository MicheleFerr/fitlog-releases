import AVFoundation
import UIKit

/// Simplified AudioSessionManager to fix error -50
/// This version ensures proper deactivation before any configuration changes
final class AudioSessionManager_Simplified: AudioSessionManaging {

    static let shared = AudioSessionManager_Simplified()
    private var session: AVAudioSession { AVAudioSession.sharedInstance() }

    private init() {
        Logger.shared.log(.info, "AudioSessionManager_Simplified initialized")
    }

    func configureForLaunch() {
        Logger.shared.log(.info, "[TIMER-DEBUG] configureForLaunch called")
        configureForegroundAudio()
    }

    func transitionToBackground() {
        Logger.shared.log(.info, "[TIMER-DEBUG] transitionToBackground called")
        configureBackgroundAudio()
    }

    func transitionToForeground() {
        Logger.shared.log(.info, "[TIMER-DEBUG] transitionToForeground called")
        configureForegroundAudio()
    }

    func validateConfiguration() -> Bool {
        return session.category == .playback
    }

    func reactivate() {
        Logger.shared.log(.info, "[TIMER-DEBUG] reactivate called")

        // CRITICAL: Always deactivate first, no matter what
        do {
            // Step 1: Force deactivate (ignore errors)
            try? session.setActive(false, options: .notifyOthersOnDeactivation)

            // Step 2: Wait a tiny bit for the deactivation to complete
            Thread.sleep(forTimeInterval: 0.01) // 10ms

            // Step 3: Configure WITHOUT .duckOthers first
            try session.setCategory(.playback, mode: .default, options: [
                .mixWithOthers,
                .allowBluetooth,
                .allowBluetoothA2DP
            ])

            // Step 4: Activate
            try session.setActive(true, options: [])

            // Step 5: NOW add .duckOthers after activation
            try session.setCategory(.playback, mode: .default, options: [
                .mixWithOthers,
                .duckOthers,  // Add this AFTER activation
                .allowBluetooth,
                .allowBluetoothA2DP
            ])

            Logger.shared.log(.info, "[TIMER-DEBUG] ✅ Audio session reactivated successfully")

        } catch {
            Logger.shared.log(.error, "[TIMER-DEBUG] ❌ Reactivation failed: \(error.localizedDescription)")

            // Fallback: Just try basic playback without ducking
            do {
                try? session.setActive(false, options: [])
                try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try session.setActive(true, options: [])
                Logger.shared.log(.info, "[TIMER-DEBUG] ✅ Fallback audio configuration applied")
            } catch {
                Logger.shared.log(.error, "[TIMER-DEBUG] ❌ Even fallback failed: \(error.localizedDescription)")
            }
        }
    }

    private func configureForegroundAudio() {
        do {
            // Always deactivate first
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
            Thread.sleep(forTimeInterval: 0.01)

            // Simple configuration without .duckOthers
            try session.setCategory(.playback, mode: .default, options: [
                .mixWithOthers,
                .allowBluetooth,
                .allowBluetoothA2DP
            ])

            try session.setActive(true, options: [])
            Logger.shared.log(.info, "✅ Foreground audio configured")

        } catch {
            Logger.shared.log(.error, "❌ Foreground audio configuration failed: \(error.localizedDescription)")
        }
    }

    private func configureBackgroundAudio() {
        do {
            // Always deactivate first
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
            Thread.sleep(forTimeInterval: 0.01)

            // Simple configuration for background
            try session.setCategory(.playback, mode: .default, options: [
                .mixWithOthers,
                .allowBluetooth,
                .allowBluetoothA2DP
            ])

            try session.setActive(true, options: [])
            Logger.shared.log(.info, "✅ Background audio configured")

        } catch {
            Logger.shared.log(.error, "❌ Background audio configuration failed: \(error.localizedDescription)")
        }
    }
}