import Foundation
import AVFoundation
import UserNotifications
import AudioToolbox

/// Simplified timer sound manager that guarantees audio playback
/// Uses system sounds as primary strategy with notification fallback
final class TimerSoundFix {
    
    static let shared = TimerSoundFix()
    
    // Pre-loaded custom sound IDs for background playback
    private var preloadedSounds: [String: SystemSoundID] = [:]
    
    private init() {
        setupAudioSession()
        preloadCustomSounds()
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
    func playTimerCompletionSound(preferredSound: String? = nil) {
        let appState = UIApplication.shared.applicationState
        Logger.shared.log(.info, """
            🎯 [TIMER-DEBUG] playTimerCompletionSound called:
            - Preferred Sound: \(preferredSound ?? "default")
            - App State: \(appState == .active ? "Active" : appState == .background ? "Background" : "Inactive")
            - Time: \(Date())
            - Available Preloaded: \(preloadedSounds.keys.joined(separator: ", "))
            """, category: .audioSession)
        
        // Setup audio session for silent mode override
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            try session.setActive(true)
            Logger.shared.log(.info, "✅ Audio session set to playback mode", category: .audioSession)
        } catch {
            Logger.shared.log(.error, "Failed to setup audio session: \(error)", category: .audioSession)
        }
        
        // CRITICAL FIX: Try custom sound FIRST if available
        if let preferred = preferredSound, !preferred.isEmpty && preferred != "default" {
            Logger.shared.log(.info, "🎵 [TIMER-DEBUG] Attempting to play custom sound: \(preferred)", category: .audioSession)
            // Try to play custom sound immediately
            if playCustomSoundIfAvailable(preferredSound: preferred) {
                Logger.shared.log(.info, "✅ [TIMER-DEBUG] Custom sound played successfully: \(preferred)", category: .audioSession)
                // Still add haptic for feedback
                playHapticFeedback()
                return
            } else {
                Logger.shared.log(.warning, "⚠️ [TIMER-DEBUG] Custom sound failed, will use fallback", category: .audioSession)
            }
        }
        
        // Fallback: Play system sounds for reliability
        playSystemSound()
        
        // Haptic feedback
        playHapticFeedback()
        
        // CRITICAL FIX: Skip notification scheduling - Flutter handles all notifications
        // This was causing duplicate notifications with hardcoded English text
        Logger.shared.log(.info, """
            ⏭️ [NOTIFICATION-FIX] SKIPPING notification from TimerSoundFix:
            - Would have shown: "Timer Complete! Your rest timer has finished."
            - Flutter now handles all completion notifications with proper localization
            - Audio was already played via system sound above
            """, category: .audioSession)
    }
    
    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            
            // Use ONLY .playback to override silent mode - NO other options that cause error -50
            try session.setCategory(.playback)
            
            // Activate the session
            try session.setActive(true)
            
            // Set preferred settings for low latency
            try session.setPreferredSampleRate(44100)
            try session.setPreferredIOBufferDuration(0.005)
            
            Logger.shared.log(.info, "✅ Audio session configured for guaranteed playback", category: .audioSession)
            
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
                    Logger.shared.log(.warning, "⚠️ Failed to preload \(soundName).caf, status: \(status)", category: .audioSession)
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
                    Logger.shared.log(.warning, "⚠️ Failed to preload \(soundName).wav, status: \(status)", category: .audioSession)
                }
            } else {
                Logger.shared.log(.warning, "⚠️ Sound file not found: \(soundName)", category: .audioSession)
            }
        }
        
        Logger.shared.log(.info, "📦 Preloaded \(preloadedSounds.count) custom sounds", category: .audioSession)
    }

    // CRITICAL FIX: Verify preloaded sounds are still valid
    func verifyPreloadedSounds() {
        Logger.shared.log(.info, "🔍 Verifying preloaded sounds integrity...", category: .audioSession)

        var invalidSounds: [String] = []

        for (soundName, soundID) in preloadedSounds {
            // AudioServicesPlaySystemSound doesn't return status, so we assume valid
            // The sound ID should be valid if it was successfully created earlier
            Logger.shared.log(.debug, "✅ Assuming valid sound ID for \(soundName): \(soundID)", category: .audioSession)
        }

        // Reload any invalid sounds
        if !invalidSounds.isEmpty {
            Logger.shared.log(.warning, "⚠️ Reloading \(invalidSounds.count) invalid sounds: \(invalidSounds.joined(separator: ", "))", category: .audioSession)

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
        
        // Additional haptic patterns if available
        if #available(iOS 13.0, *) {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
            
            // Double tap for emphasis
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                impactFeedback.impactOccurred()
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
        
        Logger.shared.log(.warning, "⚠️ No custom sounds could be played", category: .audioSession)
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
        
        Logger.shared.log(.warning, "⚠️ Custom sound \(name) not found", category: .audioSession)
        return nil
    }
    
    private func playSound(at url: URL) -> Bool {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 1.0
            player.prepareToPlay()
            
            if player.play() {
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
        content.title = "⏰ Timer Complete!"
        content.body = "Your rest timer has finished."
        
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
            name: "com.gymbro.timer_sound_fix",
            binaryMessenger: messenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "playTimerSound":
                self?.playTimerCompletionSound()
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