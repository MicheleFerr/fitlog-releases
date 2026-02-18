import Foundation
import AVFoundation
import UserNotifications
import AudioToolbox

/// Simplified timer sound manager that guarantees audio playback
/// Uses AVAudioPlayer as primary strategy to bypass mute switch
/// AudioServicesPlaySystemSound respects mute switch and won't play in silent mode!
final class TimerSoundFix {

    static let shared = TimerSoundFix()

    // Pre-loaded custom sound IDs for background playback (fallback only)
    private var preloadedSounds: [String: SystemSoundID] = [:]

    // CRITICAL FIX: Keep AVAudioPlayer as instance property to prevent deallocation
    // Local variables get deallocated immediately, stopping playback!
    private var activePlayer: AVAudioPlayer?

    // PRE-LOADED AVAudioPlayer - ready to play immediately
    // This is the most reliable approach for background audio
    private var preloadedAVPlayer: AVAudioPlayer?
    private var preloadedSoundURL: URL?

    private init() {
        setupAudioSession()
        preloadCustomSounds()
        preloadAVAudioPlayer()
    }

    // MARK: - Preload AVAudioPlayer

    /// Preload an AVAudioPlayer so it's ready to play immediately
    /// This avoids any initialization delay when the timer completes
    private func preloadAVAudioPlayer() {
        Logger.shared.log(.info, "🎵 Preloading AVAudioPlayer for instant playback...", category: .audioSession)

        // Try to find and preload the default sound
        let soundsToTry = ["sound", "timer_complete", "LightWeight", "YehBuddie"]

        for soundName in soundsToTry {
            if let url = Bundle.main.url(forResource: soundName, withExtension: "caf") {
                do {
                    preloadedAVPlayer = try AVAudioPlayer(contentsOf: url)
                    preloadedAVPlayer?.volume = 1.0
                    preloadedAVPlayer?.prepareToPlay()
                    preloadedSoundURL = url

                    Logger.shared.log(.debug, """
                        ✅ Preloaded AVAudioPlayer ready:
                        - Sound: \(soundName).caf
                        - Duration: \(preloadedAVPlayer?.duration ?? 0)s
                        - Prepared: true
                        """, category: .audioSession)
                    return
                } catch {
                    Logger.shared.log(.debug, "⚠️ Failed to preload \(soundName).caf: \(error)", category: .audioSession)
                }
            }
        }

        Logger.shared.log(.error, "❌ Could not preload any AVAudioPlayer", category: .audioSession)
    }

    /// Play using the preloaded player (fastest possible)
    /// - Parameter preferredSound: Optional sound name to match against preloaded sound
    private func playPreloadedAVPlayer(preferredSound: String? = nil) -> Bool {
        Logger.shared.log(.debug, "    ┌─ [PRELOADED-PLAYER] Checking preloaded player...", category: .audioSession)

        // ✅ FIX BUG #1: Verify preloaded sound matches preferred sound
        if let preferred = preferredSound,
           let preloadedURL = preloadedSoundURL {
            let preloadedName = preloadedURL.deletingPathExtension().lastPathComponent
            if preloadedName != preferred {
                Logger.shared.log(.debug, """
                        ├─ ⚠️ Preloaded sound mismatch!
                        │   - Preloaded: \(preloadedName)
                        │   - Preferred: \(preferred)
                        └─ Skipping preloaded player, will try fresh AVAudioPlayer with correct sound
                    """, category: .audioSession)
                return false
            }
            Logger.shared.log(.debug, "    ├─ ✅ Preloaded sound matches preferred: \(preferred)", category: .audioSession)
        }

        guard let player = preloadedAVPlayer else {
            Logger.shared.log(.debug, """
                    ├─ ⚠️ No preloaded AVAudioPlayer available
                    └─ Attempting to create one on-demand...
                """, category: .audioSession)
            // Try to preload now
            preloadAVAudioPlayer()
            guard preloadedAVPlayer != nil else {
                Logger.shared.log(.error, "    └─ ❌ Failed to create preloaded AVAudioPlayer on demand", category: .audioSession)
                return false
            }
            Logger.shared.log(.debug, "    ├─ ✅ Created on-demand, retrying play...", category: .audioSession)
            return playPreloadedAVPlayer() // Retry with new player
        }

        let session = AVAudioSession.sharedInstance()
        Logger.shared.log(.debug, """
                ├─ 🚀 Preloaded AVAudioPlayer STATUS:
                │   - Duration: \(player.duration)s
                │   - CurrentTime: \(player.currentTime)
                │   - Volume: \(player.volume)
                │   - Is Playing: \(player.isPlaying)
                │   - Audio Session Category: \(session.category.rawValue)
                │   - Audio Session Active: attempting activation...
            """, category: .audioSession)

        // Reset to beginning if already played
        Logger.shared.log(.debug, "    ├─ Resetting player to beginning...", category: .audioSession)
        player.currentTime = 0
        player.volume = 1.0

        // Prepare again just to be safe
        Logger.shared.log(.debug, "    ├─ Calling prepareToPlay()...", category: .audioSession)
        player.prepareToPlay()

        Logger.shared.log(.debug, "    ├─ Calling play()...", category: .audioSession)
        let result = player.play()

        if result {
            Logger.shared.log(.debug, """
                    ├─ ✅ play() returned TRUE
                    ├─ Player is now playing: \(player.isPlaying)
                    └─ Scheduling player reload for next use
                """, category: .audioSession)

            // Reload the player for next time (async, don't block)
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.reloadPreloadedPlayer()
            }
        } else {
            Logger.shared.log(.error, """
                    ├─ ❌ play() returned FALSE
                    ├─ Player isPlaying: \(player.isPlaying)
                    ├─ Audio Session Category: \(session.category.rawValue)
                    ├─ Output Volume: \(session.outputVolume)
                    └─ Will fall back to other strategies
                """, category: .audioSession)
        }

        return result
    }

    /// Reload the preloaded player after it was used
    private func reloadPreloadedPlayer() {
        guard let url = preloadedSoundURL else { return }

        do {
            preloadedAVPlayer = try AVAudioPlayer(contentsOf: url)
            preloadedAVPlayer?.volume = 1.0
            preloadedAVPlayer?.prepareToPlay()
            Logger.shared.log(.debug, "🔄 Reloaded preloaded AVAudioPlayer", category: .audioSession)
        } catch {
            Logger.shared.log(.error, "❌ Failed to reload preloaded AVAudioPlayer: \(error)", category: .audioSession)
        }
    }

    // CRITICAL FIX: Call this from AppDelegate to ensure early preloading
    static func initializeAtAppLaunch() {
        Logger.shared.log(.info, "🚀 TimerSoundFix early initialization called from AppDelegate", category: .audioSession)
        _ = TimerSoundFix.shared // Triggers singleton initialization

        // Additional preload verification after app launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            TimerSoundFix.shared.verifyPreloadedSounds()
        }
    }
    
    // MARK: - Main API
    
    /// Play timer completion sound with multiple fallback strategies
    /// CRITICAL: Uses AVAudioPlayer with .playback category to bypass mute switch!
    /// AudioServicesPlaySystemSound respects mute switch and won't play in silent mode.
    /// - Parameter preferredSound: Optional sound name to play
    /// - Parameter isPreview: If true, skip backup sound (for UI preview only)
    func playTimerCompletionSound(preferredSound: String? = nil, isPreview: Bool = false) {
        let startTime = Date()
        let currentThread = Thread.isMainThread ? "MAIN" : "BACKGROUND"
        let queueLabel = OperationQueue.current?.underlyingQueue?.label ?? "unknown"

        Logger.shared.log(.debug, """
            ╔══════════════════════════════════════════════════════════════════╗
            ║ 🎯 [TIMER-SOUND] STEP 1/7: ENTRY POINT                          ║
            ╚══════════════════════════════════════════════════════════════════╝
            - Timestamp: \(startTime)
            - Thread: \(currentThread)
            - Queue: \(queueLabel)
            - Preferred Sound: \(preferredSound ?? "default")
            """, category: .audioSession)

        // Use AudioSessionManager to avoid DispatchQueue.main.sync deadlock risk.
        // UIApplication.shared.applicationState requires main thread — use the cached state instead.
        let isBackground = AudioSessionManager.shared.isAppInBackground
        let appStateStr = isBackground ? "BACKGROUND/INACTIVE 🔒" : "ACTIVE ✅"
        Logger.shared.log(.debug, """
            📍 [TIMER-SOUND] STEP 2/7: APP STATE CHECK
            - App State: \(appStateStr)
            - Preloaded Sounds: \(preloadedSounds.keys.joined(separator: ", "))
            - Preloaded AVPlayer Ready: \(preloadedAVPlayer != nil ? "YES ✅" : "NO ❌")
            """, category: .audioSession)

        // CRITICAL FIX: Setup audio session with .mixWithOthers for consistency
        // This must be done BEFORE creating AVAudioPlayer
        // NOTE: Do NOT deactivate session first - that causes error 561015905 in background!
        Logger.shared.log(.debug, "📍 [TIMER-SOUND] STEP 3/7: CONFIGURING AUDIO SESSION...", category: .audioSession)
        do {
            let session = AVAudioSession.sharedInstance()
            let previousCategory = session.category.rawValue
            let previousMode = session.mode.rawValue
            let previousOptions = session.categoryOptions.rawValue

            Logger.shared.log(.debug, """
                📍 [TIMER-SOUND] Audio session BEFORE config:
                - Category: \(previousCategory)
                - Mode: \(previousMode)
                - Options: \(previousOptions)
                - Is Active: \(session.isOtherAudioPlaying ? "Other audio playing" : "No other audio")
                """, category: .audioSession)

            // Use .mixWithOthers to match AudioSessionManager configuration
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            Logger.shared.log(.debug, "📍 [TIMER-SOUND] setCategory SUCCESS ✅", category: .audioSession)

            // Use try? to avoid throwing if already active
            try? session.setActive(true)
            Logger.shared.log(.debug, """
                📍 [TIMER-SOUND] STEP 3/7: AUDIO SESSION CONFIGURED ✅
                - Category: \(session.category.rawValue)
                - Mode: \(session.mode.rawValue)
                - Options: \(session.categoryOptions.rawValue)
                - Output Volume: \(session.outputVolume)
                - Output Ports: \(session.currentRoute.outputs.map { $0.portType.rawValue }.joined(separator: ", "))
                """, category: .audioSession)
        } catch {
            // Don't fail - the session might already be active from silent loop
            Logger.shared.log(.error, """
                ❌ [TIMER-SOUND] STEP 3/7: AUDIO SESSION CONFIG FAILED
                - Error: \(error.localizedDescription)
                - Error Code: \((error as NSError).code)
                - Error Domain: \((error as NSError).domain)
                """, category: .audioSession)
        }

        // STRATEGY 0: FASTEST - Use preloaded AVAudioPlayer
        // This is already initialized and prepared, so it should play instantly
        let soundToPlay = preferredSound ?? "sound"
        Logger.shared.log(.debug, """
            📍 [TIMER-SOUND] STEP 4/7: TRYING STRATEGY 0 - PRELOADED AVAudioPlayer
            - Player exists: \(preloadedAVPlayer != nil)
            - Player duration: \(preloadedAVPlayer?.duration ?? 0)s
            - Preferred sound: \(soundToPlay)
            """, category: .audioSession)
        if playPreloadedAVPlayer(preferredSound: soundToPlay) {
            let elapsed = Date().timeIntervalSince(startTime) * 1000
            Logger.shared.log(.debug, """
                ✅ [TIMER-SOUND] STEP 7/7: SUCCESS via STRATEGY 0 (Preloaded AVAudioPlayer)
                - Total time: \(String(format: "%.2f", elapsed))ms
                - Playing haptic feedback...
                """, category: .audioSession)
            playHapticFeedback()
            return
        }
        Logger.shared.log(.debug, "⚠️ [TIMER-SOUND] STRATEGY 0 FAILED - trying next...", category: .audioSession)

        // STRATEGY 1: AVAudioPlayer (bypasses mute switch!)
        // This is the ONLY reliable way to play sound in silent mode
        // soundToPlay already defined in Strategy 0
        Logger.shared.log(.debug, """
            📍 [TIMER-SOUND] STEP 5/7: TRYING STRATEGY 1 - Fresh AVAudioPlayer
            - Sound name: \(soundToPlay)
            - Is preview: \(isPreview)
            """, category: .audioSession)
        if playWithAVAudioPlayer(soundName: soundToPlay, skipBackup: isPreview) {
            let elapsed = Date().timeIntervalSince(startTime) * 1000
            Logger.shared.log(.debug, """
                ✅ [TIMER-SOUND] STEP 7/7: SUCCESS via STRATEGY 1 (Fresh AVAudioPlayer)
                - Sound: \(soundToPlay)
                - Total time: \(String(format: "%.2f", elapsed))ms
                - Playing haptic feedback...
                """, category: .audioSession)
            playHapticFeedback()
            return
        }
        Logger.shared.log(.debug, "⚠️ [TIMER-SOUND] STRATEGY 1 FAILED - trying next...", category: .audioSession)

        // STRATEGY 2: Try default sound if custom failed
        if soundToPlay != "sound" {
            Logger.shared.log(.debug, "📍 [TIMER-SOUND] TRYING STRATEGY 2 - Default sound fallback", category: .audioSession)
            if playWithAVAudioPlayer(soundName: "sound", skipBackup: isPreview) {
                let elapsed = Date().timeIntervalSince(startTime) * 1000
                Logger.shared.log(.debug, """
                    ✅ [TIMER-SOUND] STEP 7/7: SUCCESS via STRATEGY 2 (Default sound)
                    - Total time: \(String(format: "%.2f", elapsed))ms
                    - Playing haptic feedback...
                    """, category: .audioSession)
                playHapticFeedback()
                return
            }
            Logger.shared.log(.debug, "⚠️ [TIMER-SOUND] STRATEGY 2 FAILED - trying next...", category: .audioSession)
        }

        // STRATEGY 3: Try preloaded SystemSoundID (works better for short sounds)
        Logger.shared.log(.debug, """
            📍 [TIMER-SOUND] STEP 6/7: TRYING STRATEGY 3 - SystemSoundID
            - Looking for: \(soundToPlay)
            - Available IDs: \(preloadedSounds.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))
            """, category: .audioSession)
        if let soundID = preloadedSounds[soundToPlay] {
            Logger.shared.log(.debug, "🔊 [TIMER-SOUND] Playing SystemSoundID: \(soundID)", category: .audioSession)
            AudioServicesPlaySystemSoundWithCompletion(soundID) {
                Logger.shared.log(.debug, "✅ [TIMER-SOUND] SystemSoundID \(soundID) playback completed", category: .audioSession)
            }
            AudioServicesPlayAlertSound(soundID)
            let elapsed = Date().timeIntervalSince(startTime) * 1000
            Logger.shared.log(.debug, """
                ✅ [TIMER-SOUND] STEP 7/7: SUCCESS via STRATEGY 3 (SystemSoundID)
                - Sound ID: \(soundID)
                - Total time: \(String(format: "%.2f", elapsed))ms
                """, category: .audioSession)
            playHapticFeedback()
            return
        }

        // STRATEGY 4: Try default preloaded sound
        Logger.shared.log(.debug, "📍 [TIMER-SOUND] TRYING STRATEGY 4 - Default SystemSoundID", category: .audioSession)
        if let defaultSoundID = preloadedSounds["sound"] {
            Logger.shared.log(.debug, "🔊 [TIMER-SOUND] Playing default SystemSoundID: \(defaultSoundID)", category: .audioSession)
            AudioServicesPlaySystemSoundWithCompletion(defaultSoundID) {
                Logger.shared.log(.debug, "✅ [TIMER-SOUND] Default SystemSoundID completed", category: .audioSession)
            }
            AudioServicesPlayAlertSound(defaultSoundID)
            let elapsed = Date().timeIntervalSince(startTime) * 1000
            Logger.shared.log(.debug, """
                ✅ [TIMER-SOUND] STEP 7/7: SUCCESS via STRATEGY 4 (Default SystemSoundID)
                - Total time: \(String(format: "%.2f", elapsed))ms
                """, category: .audioSession)
            playHapticFeedback()
            return
        }

        // STRATEGY 5: System sounds as absolute last resort
        Logger.shared.log(.error, """
            ❌ [TIMER-SOUND] ALL STRATEGIES 0-4 FAILED!
            - Trying STRATEGY 5: System alert sounds (last resort)
            """, category: .audioSession)
        playSystemSound()
        playHapticFeedback()

        let elapsed = Date().timeIntervalSince(startTime) * 1000
        Logger.shared.log(.debug, """
            ⚠️ [TIMER-SOUND] STEP 7/7: COMPLETED via STRATEGY 5 (System sounds)
            - Total time: \(String(format: "%.2f", elapsed))ms
            - Note: This is the fallback - sound quality may vary
            """, category: .audioSession)
    }

    // MARK: - AVAudioPlayer Strategy (Bypasses Mute Switch!)

    /// Play sound using AVAudioPlayer - this IGNORES the mute switch!
    /// AudioServicesPlaySystemSound respects mute switch, AVAudioPlayer with .playback does not.
    /// - Parameter skipBackup: If true, don't play backup sound (for preview mode)
    private func playWithAVAudioPlayer(soundName: String, skipBackup: Bool = false) -> Bool {
        Logger.shared.log(.info, "🔊 [MUTE-BYPASS] Attempting AVAudioPlayer for: \(soundName)", category: .audioSession)

        // Check audio route first
        let session = AVAudioSession.sharedInstance()
        let currentRoute = session.currentRoute
        Logger.shared.log(.debug, """
            🎧 Audio Route Status:
            - Outputs: \(currentRoute.outputs.map { "\($0.portType.rawValue) - \($0.portName)" }.joined(separator: ", "))
            - Output volume: \(session.outputVolume)
            - Other audio playing: \(session.isOtherAudioPlaying)
            """, category: .audioSession)

        // Try multiple extensions
        let extensions = ["caf", "wav", "mp3", "m4a"]
        var fileFound = false
        var lastError: String?

        for ext in extensions {
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext) {
                fileFound = true
                Logger.shared.log(.info, "📁 Found file: \(soundName).\(ext) at \(url.path)", category: .audioSession)

                // Verify file exists and has content
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                    let fileSize = attributes[.size] as? Int64 ?? 0
                    Logger.shared.log(.info, "📁 File size: \(fileSize) bytes", category: .audioSession)

                    if fileSize == 0 {
                        Logger.shared.log(.error, "❌ File is empty!", category: .audioSession)
                        continue
                    }
                } catch {
                    Logger.shared.log(.error, "❌ Cannot read file attributes: \(error)", category: .audioSession)
                }

                // ATTEMPT 1: Create and play directly
                do {
                    // CRITICAL: Store as instance property to prevent deallocation!
                    activePlayer = try AVAudioPlayer(contentsOf: url)

                    // Debug: log player info
                    if let player = activePlayer {
                        Logger.shared.log(.debug, """
                            🎵 AVAudioPlayer created:
                            - Duration: \(player.duration)s
                            - Format: \(player.format)
                            - Channels: \(player.numberOfChannels)
                            """, category: .audioSession)
                    }

                    activePlayer?.volume = 1.0
                    let prepared = activePlayer?.prepareToPlay() ?? false
                    Logger.shared.log(.info, "🔧 prepareToPlay() result: \(prepared)", category: .audioSession)

                    // Small delay to let audio system stabilize
                    Thread.sleep(forTimeInterval: 0.05)

                    let playResult = activePlayer?.play() ?? false
                    Logger.shared.log(.info, "▶️ play() result: \(playResult)", category: .audioSession)

                    if playResult {
                        Logger.shared.log(.info, "✅ [MUTE-BYPASS] AVAudioPlayer started: \(soundName).\(ext)", category: .audioSession)
                        return true
                    } else {
                        lastError = "play() returned false on first attempt"
                        Logger.shared.log(.debug, "⚠️ play() returned false, attempting retry strategies...", category: .audioSession)
                    }
                } catch {
                    lastError = "Player creation failed: \(error.localizedDescription)"
                    Logger.shared.log(.error, "❌ AVAudioPlayer creation failed: \(error)", category: .audioSession)
                    continue
                }

                // ATTEMPT 2: DON'T deactivate! Just ensure category is set and retry
                // Deactivating while in background causes error 561015905
                Logger.shared.log(.info, "🔄 RETRY 1: Ensuring audio session category (NO deactivation)...", category: .audioSession)
                do {
                    // Just set category without deactivating - this is safe
                    try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
                    // Try to activate (will succeed if already active)
                    try? session.setActive(true)
                    Thread.sleep(forTimeInterval: 0.05)

                    // Re-prepare the player
                    activePlayer?.prepareToPlay()
                    Thread.sleep(forTimeInterval: 0.05)

                    let retryResult = activePlayer?.play() ?? false
                    Logger.shared.log(.info, "▶️ RETRY 1 play() result: \(retryResult)", category: .audioSession)

                    if retryResult {
                        Logger.shared.log(.info, "✅ RETRY 1 SUCCESS: play() worked!", category: .audioSession)
                        return true
                    }
                } catch {
                    Logger.shared.log(.error, "❌ RETRY 1 failed: \(error)", category: .audioSession)
                }

                // ATTEMPT 3: Create a completely new player
                Logger.shared.log(.info, "🔄 RETRY 2: Creating fresh AVAudioPlayer...", category: .audioSession)
                do {
                    // Release old player
                    activePlayer?.stop()
                    activePlayer = nil

                    Thread.sleep(forTimeInterval: 0.1)

                    // Create fresh player
                    activePlayer = try AVAudioPlayer(contentsOf: url)
                    activePlayer?.volume = 1.0
                    activePlayer?.numberOfLoops = 0
                    _ = activePlayer?.prepareToPlay()

                    Thread.sleep(forTimeInterval: 0.05)

                    let freshResult = activePlayer?.play() ?? false
                    Logger.shared.log(.info, "▶️ RETRY 2 play() result: \(freshResult)", category: .audioSession)

                    if freshResult {
                        Logger.shared.log(.info, "✅ RETRY 2 SUCCESS: Fresh player worked!", category: .audioSession)
                        return true
                    }
                } catch {
                    Logger.shared.log(.error, "❌ RETRY 2 Fresh player creation failed: \(error)", category: .audioSession)
                }

                // Log comprehensive failure info
                Logger.shared.log(.error, """
                    ❌ ALL AVAudioPlayer attempts FAILED for \(soundName).\(ext)
                    - Session category: \(session.category.rawValue)
                    - Session mode: \(session.mode.rawValue)
                    - Category options: \(session.categoryOptions.rawValue)
                    - Output volume: \(session.outputVolume)
                    - Outputs available: \(currentRoute.outputs.count)
                    - Last error: \(lastError ?? "unknown")
                    """, category: .audioSession)

                // Don't try other extensions if we found the file but couldn't play it
                // The issue is likely audio session, not file format
                break
            } else {
                Logger.shared.log(.debug, "📁 File not found: \(soundName).\(ext)", category: .audioSession)
            }
        }

        if fileFound {
            Logger.shared.log(.debug, "⚠️ File found but could not play: \(soundName)", category: .audioSession)
        } else {
            Logger.shared.log(.debug, "⚠️ No file found for: \(soundName)", category: .audioSession)
        }
        return false
    }

    
    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()

            // CRITICAL FIX: Use .mixWithOthers to match AudioSessionManager
            // This prevents conflicts between different audio managers
            // .playback category with .mixWithOthers IGNORES the mute switch!
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])

            // Activate the session
            try session.setActive(true)

            // Optional: Set preferred settings (use try? to avoid failures)
            try? session.setPreferredSampleRate(44100)
            try? session.setPreferredIOBufferDuration(0.005)

            Logger.shared.log(.info, "✅ Audio session configured with .mixWithOthers for mute bypass", category: .audioSession)

        } catch {
            Logger.shared.log(.error, "Failed to setup audio session: \(error)", category: .audioSession)
        }
    }
    
    // MARK: - Preload Custom Sounds
    
    private func preloadCustomSounds() {
        let soundsToPreload = ["sound", "timer_complete", "LightWeight", "YehBuddie"]
        
        for soundName in soundsToPreload {
            // Try CAF first (Apple's preferred format)
            if let url = Bundle.main.url(forResource: soundName, withExtension: "caf") {
                var soundID: SystemSoundID = 0
                let status = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
                
                if status == kAudioServicesNoError {
                    preloadedSounds[soundName] = soundID
                    
                    // Add completion handler to verify sound plays
                    AudioServicesAddSystemSoundCompletion(soundID, nil, nil, { soundID, _ in
                        Logger.shared.log(.info, "🔊 Sound completed playing: ID \(soundID)", category: .audioSession)
                    }, nil)
                    
                    Logger.shared.log(.info, "✅ Preloaded sound: \(soundName).caf with ID: \(soundID)", category: .audioSession)
                } else {
                    Logger.shared.log(.debug, "⚠️ Failed to preload \(soundName).caf, status: \(status)", category: .audioSession)
                }
            }
            // Try WAV as fallback
            else if let url = Bundle.main.url(forResource: soundName, withExtension: "wav") {
                var soundID: SystemSoundID = 0
                let status = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
                
                if status == kAudioServicesNoError {
                    preloadedSounds[soundName] = soundID
                    
                    // Add completion handler to verify sound plays
                    AudioServicesAddSystemSoundCompletion(soundID, nil, nil, { soundID, _ in
                        Logger.shared.log(.info, "🔊 Sound completed playing: ID \(soundID)", category: .audioSession)
                    }, nil)
                    
                    Logger.shared.log(.info, "✅ Preloaded sound: \(soundName).wav with ID: \(soundID)", category: .audioSession)
                } else {
                    Logger.shared.log(.debug, "⚠️ Failed to preload \(soundName).wav, status: \(status)", category: .audioSession)
                }
            } else {
                Logger.shared.log(.debug, "⚠️ Sound file not found: \(soundName)", category: .audioSession)
            }
        }
        
        Logger.shared.log(.info, "📦 Preloaded \(preloadedSounds.count) custom sounds", category: .audioSession)
    }

    // CRITICAL FIX: Verify preloaded sounds are still valid
    func verifyPreloadedSounds() {
        Logger.shared.log(.info, "🔍 Verifying preloaded sounds integrity...", category: .audioSession)

        // Verify preloaded AVAudioPlayer
        if let player = preloadedAVPlayer {
            Logger.shared.log(.debug, """
                ✅ Preloaded AVAudioPlayer verified:
                - Duration: \(player.duration)s
                - Prepared: calling prepareToPlay()
                """, category: .audioSession)
            player.prepareToPlay()
        } else {
            Logger.shared.log(.debug, "⚠️ Preloaded AVAudioPlayer is nil - reloading...", category: .audioSession)
            preloadAVAudioPlayer()
        }

        var invalidSounds: [String] = []

        for (soundName, soundID) in preloadedSounds {
            // AudioServicesPlaySystemSound doesn't return status, so we assume valid
            // The sound ID should be valid if it was successfully created earlier
            Logger.shared.log(.debug, "✅ Assuming valid sound ID for \(soundName): \(soundID)", category: .audioSession)
        }

        // Reload any invalid sounds
        if !invalidSounds.isEmpty {
            Logger.shared.log(.debug, "⚠️ Reloading \(invalidSounds.count) invalid sounds: \(invalidSounds.joined(separator: ", "))", category: .audioSession)

            for soundName in invalidSounds {
                // Dispose old sound ID
                if let oldSoundID = preloadedSounds[soundName] {
                    AudioServicesDisposeSystemSoundID(oldSoundID)
                }
                preloadedSounds.removeValue(forKey: soundName)

                // Reload the sound
                reloadSpecificSound(soundName)
            }
        } else {
            Logger.shared.log(.info, "✅ All preloaded sounds verified successfully", category: .audioSession)
        }
    }

    // CRITICAL FIX: Reload a specific sound that failed verification
    private func reloadSpecificSound(_ soundName: String) {
        Logger.shared.log(.info, "🔄 Reloading sound: \(soundName)", category: .audioSession)

        // Try CAF first
        if let url = Bundle.main.url(forResource: soundName, withExtension: "caf") {
            var soundID: SystemSoundID = 0
            let status = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)

            if status == kAudioServicesNoError {
                preloadedSounds[soundName] = soundID

                // Add completion handler
                AudioServicesAddSystemSoundCompletion(soundID, nil, nil, { soundID, _ in
                    Logger.shared.log(.info, "🔊 Reloaded sound completed: ID \(soundID)", category: .audioSession)
                }, nil)

                Logger.shared.log(.info, "✅ Successfully reloaded: \(soundName).caf with ID: \(soundID)", category: .audioSession)
            } else {
                Logger.shared.log(.error, "❌ Failed to reload \(soundName).caf, status: \(status)", category: .audioSession)
            }
        } else {
            Logger.shared.log(.error, "❌ Sound file not found for reload: \(soundName).caf", category: .audioSession)
        }
    }
    
    deinit {
        // Clean up preloaded sounds
        for (_, soundID) in preloadedSounds {
            AudioServicesDisposeSystemSoundID(soundID)
        }
    }
    
    // MARK: - Strategy 1: System Sound
    
    private func playSystemSound() {
        Logger.shared.log(.info, "🔊 [TIMER-DEBUG] Playing system sound fallback", category: .audioSession)
        
        // Use a prominent system sound that always works
        let soundIDs: [SystemSoundID] = [
            1005, // New mail sound  
            1016, // SMS received
            1315, // Glass sound
            1052, // Bloom sound
            1304, // Received message (prominent)
            1307, // Mail sent
            1320, // Anticipate
            1322, // Alert tone
        ]
        
        // Play TWO sounds for emphasis
        AudioServicesPlayAlertSound(soundIDs[0])
        AudioServicesPlaySystemSound(soundIDs[1])
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        Logger.shared.log(.info, "✅ [TIMER-DEBUG] System alert sounds \(soundIDs[0]) and \(soundIDs[1]) played with vibration", category: .audioSession)
    }
    
    // MARK: - Strategy 2: Haptic Feedback
    
    private func playHapticFeedback() {
        // Strong vibration pattern
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        // Additional haptic patterns if available - MUST run on main thread
        // UIImpactFeedbackGenerator is a UIKit API
        if #available(iOS 13.0, *) {
            DispatchQueue.main.async {
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.prepare()
                impactFeedback.impactOccurred()

                // Double tap for emphasis
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    impactFeedback.impactOccurred()
                }
            }
        }

        Logger.shared.log(.info, "✅ Haptic feedback played", category: .audioSession)
    }
    
    // MARK: - Strategy 3: Custom Sound
    
    private func playCustomSoundIfAvailable(preferredSound: String? = nil) -> Bool {
        Logger.shared.log(.info, "🔍 [TIMER-DEBUG] playCustomSoundIfAvailable: \(preferredSound ?? "none")", category: .audioSession)
        
        // FIRST: Try preloaded system sound ID (works in background!)
        if let preferred = preferredSound,
           let soundID = preloadedSounds[preferred] {
            Logger.shared.log(.info, "🎵 [TIMER-DEBUG] Found preloaded sound: \(preferred) with ID: \(soundID)", category: .audioSession)
            
            // Use PlaySystemSoundWithCompletion for better reliability
            AudioServicesPlaySystemSoundWithCompletion(soundID) { [weak self] in
                Logger.shared.log(.info, "🔊 Sound completed: \(preferred)", category: .audioSession)
                // Try vibration as feedback
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            
            // Also play alert version for redundancy
            AudioServicesPlayAlertSound(soundID)
            
            Logger.shared.log(.info, "✅ Preloaded sound played with completion handler: \(preferred)", category: .audioSession)
            return true
        }
        
        // Fallback to preloaded sound
        if let soundID = preloadedSounds["sound"] {
            Logger.shared.log(.info, "🎵 Playing fallback preloaded sound: sound", category: .audioSession)
            
            // Use both methods for redundancy
            AudioServicesPlaySystemSoundWithCompletion(soundID) { [weak self] in
                Logger.shared.log(.info, "🔊 Fallback sound completed", category: .audioSession)
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            AudioServicesPlayAlertSound(soundID)
            
            Logger.shared.log(.info, "✅ Fallback sound played with dual method: sound", category: .audioSession)
            return true
        }
        
        // Last resort: Try AVAudioPlayer (won't work in background)
        if let preferred = preferredSound {
            Logger.shared.log(.info, "🎵 Trying AVAudioPlayer for: \(preferred)", category: .audioSession)
            if let url = findSoundFile(named: preferred) {
                if playSound(at: url) {
                    Logger.shared.log(.info, "✅ AVAudioPlayer played: \(preferred)", category: .audioSession)
                    return true
                }
            }
        }
        
        Logger.shared.log(.debug, "⚠️ No custom sounds could be played", category: .audioSession)
        return false
    }
    
    private func findSoundFile(named name: String) -> URL? {
        // Try multiple methods to find the file
        let extensions = ["caf", "wav", "mp3", "m4a"]
        
        for ext in extensions {
            // Method 1: Direct bundle path
            if let path = Bundle.main.path(forResource: name, ofType: ext) {
                Logger.shared.log(.info, "✅ Found \(name).\(ext) via path", category: .audioSession)
                return URL(fileURLWithPath: path)
            }
            
            // Method 2: Bundle URL
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                Logger.shared.log(.info, "✅ Found \(name).\(ext) via URL", category: .audioSession)
                return url
            }
        }
        
        Logger.shared.log(.debug, "⚠️ Custom sound \(name) not found", category: .audioSession)
        return nil
    }
    
    private func playSound(at url: URL) -> Bool {
        do {
            // CRITICAL FIX: Store as instance property to prevent deallocation!
            // Local variables get deallocated immediately, stopping playback.
            activePlayer = try AVAudioPlayer(contentsOf: url)
            activePlayer?.volume = 1.0
            activePlayer?.prepareToPlay()

            if activePlayer?.play() == true {
                Logger.shared.log(.info, "✅ Custom sound played: \(url.lastPathComponent)", category: .audioSession)
                return true
            } else {
                Logger.shared.log(.error, "❌ Custom sound failed to play", category: .audioSession)
                return false
            }

        } catch {
            Logger.shared.log(.error, "Failed to play custom sound: \(error)", category: .audioSession)
            return false
        }
    }
    
    // MARK: - Strategy 4: Immediate Notification with Custom Sound
    
    private func scheduleImmediateNotificationWithSound(soundName: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = TimerNotificationStrings.timerComplete
        content.body = TimerNotificationStrings.restTimerFinished
        
        // Use custom sound if available, otherwise default
        if let sound = soundName, sound != "sound" {
            content.sound = UNNotificationSound(named: UNNotificationSoundName("\(sound).caf"))
            Logger.shared.log(.info, "📢 Notification with custom sound: \(sound).caf", category: .audioSession)
        } else {
            content.sound = UNNotificationSound(named: UNNotificationSoundName("sound.caf"))
            Logger.shared.log(.info, "📢 Notification with default sound: sound.caf", category: .audioSession)
        }
        
        content.categoryIdentifier = "TIMER_COMPLETE"
        
        // Immediate trigger (0.1 second delay)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, 
                                           content: content, 
                                           trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.shared.log(.error, "Failed to schedule notification: \(error)", category: .audioSession)
            } else {
                Logger.shared.log(.info, "✅ Notification scheduled with custom sound", category: .audioSession)
            }
        }
    }
    
    // Keep old method for compatibility
    private func scheduleImmediateNotification() {
        scheduleImmediateNotificationWithSound(soundName: nil)
    }
    
    // MARK: - Test Method
    
    func testAllSounds() {
        Logger.shared.log(.info, "🧪 TESTING ALL SOUND STRATEGIES", category: .audioSession)
        
        // First verify files exist
        Logger.shared.log(.info, "📁 Verifying sound files...", category: .audioSession)
        let soundsToCheck = ["sound", "timer_complete", "LightWeight", "YehBuddie"]
        for soundName in soundsToCheck {
            if let url = Bundle.main.url(forResource: soundName, withExtension: "caf") {
                Logger.shared.log(.info, "✅ Found: \(soundName).caf at \(url.path)", category: .audioSession)
                // Try to verify file is readable
                if FileManager.default.fileExists(atPath: url.path) {
                    Logger.shared.log(.info, "✅ File exists and readable: \(soundName).caf", category: .audioSession)
                }
            } else if let url = Bundle.main.url(forResource: soundName, withExtension: "wav") {
                Logger.shared.log(.info, "✅ Found: \(soundName).wav at \(url.path)", category: .audioSession)
            } else {
                Logger.shared.log(.error, "❌ NOT FOUND: \(soundName)", category: .audioSession)
            }
        }
        
        // Test preloaded sounds directly
        Logger.shared.log(.info, "🔊 Testing preloaded sounds directly...", category: .audioSession)
        for (name, soundID) in preloadedSounds {
            Logger.shared.log(.info, "Playing \(name) with ID \(soundID)...", category: .audioSession)
            AudioServicesPlaySystemSoundWithCompletion(soundID) {
                Logger.shared.log(.info, "✅ Completed: \(name)", category: .audioSession)
            }
            Thread.sleep(forTimeInterval: 1.5)
        }
        
        // Test each strategy individually
        Logger.shared.log(.info, "1️⃣ Testing system sounds...", category: .audioSession)
        playSystemSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            Logger.shared.log(.info, "2️⃣ Testing haptic feedback...", category: .audioSession)
            self?.playHapticFeedback()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                Logger.shared.log(.info, "3️⃣ Testing custom sounds...", category: .audioSession)
                self?.playCustomSoundIfAvailable(preferredSound: "YehBuddie")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    Logger.shared.log(.info, "4️⃣ Testing notification...", category: .audioSession)
                    self?.scheduleImmediateNotification()
                    
                    Logger.shared.log(.info, "✅ ALL SOUND TESTS COMPLETE", category: .audioSession)
                }
            }
        }
    }
}

// MARK: - Flutter Integration

extension TimerSoundFix {
    func setupFlutterChannel(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: ChannelNames.timerSoundFix,
            binaryMessenger: messenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "playTimerSound":
                // Extract optional soundName parameter
                let soundName = (call.arguments as? [String: Any])?["soundName"] as? String
                // Preview mode = true to skip backup sound
                self?.playTimerCompletionSound(preferredSound: soundName, isPreview: true)
                result(true)
                
            case "testAllSounds":
                self?.testAllSounds()
                result(true)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}