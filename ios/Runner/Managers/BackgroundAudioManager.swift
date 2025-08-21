import Foundation
import AVFoundation
import UserNotifications
import UIKit
import AudioToolbox

/// Gestisce l'audio in background per timer lunghi usando strategie multiple
/// Versione semplificata che usa TimerSoundFix per audio garantito
final class BackgroundAudioManager {
    
    // MARK: - Singleton
    static let shared = BackgroundAudioManager()
    
    // MARK: - Properties
    private var audioPlayer: AVAudioPlayer?
    private var silentLoopPlayer: AVAudioPlayer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var silentLoopActive = false
    
    // Timer management
    private var timerCompletionHandler: (() -> Void)?
    private var timerWorkItem: DispatchWorkItem?
    
    // Strategia per timer lunghi
    private var scheduledNotification: String?
    
    // Audio playback tracking
    private var audioPlayedTimestamp: Date?
    private var lastCompletedSoundName: String?
    
    // MARK: - Configuration
    private struct Config {
        static let silentLoopFileName = "silent_loop"
        static let maxSilentLoopDuration: TimeInterval = 3600 // 1 hour max
        static let batteryCheckInterval: TimeInterval = 300 // 5 minutes
    }
    
    // MARK: - Initialization
    private init() {
        Logger.shared.log(.info, "BackgroundAudioManager initialized", category: .audioSession)
        setupSilentLoopPlayer()
    }
    
    deinit {
        stopSilentLoop()
        cancelScheduledAudio()
    }
    
    // MARK: - Timer Audio Scheduling
    
    /// Schedula l'audio per il timer con strategia basata sulla durata
    func scheduleTimerAudio(duration: TimeInterval, soundName: String = "timer_complete") {
        Logger.shared.log(.info, "🎯 Scheduling timer audio for \(duration)s with sound: \(soundName)", category: .audioSession)
        
        // Cancel any existing audio
        cancelScheduledAudio()
        
        // v2.12.0: Use iOS notifications with system sounds for reliability
        scheduleSmartNotification(after: duration, soundName: soundName)
        Logger.shared.log(.info, "🔔 iOS handling notifications with system sound", category: .audioSession)
        
        // BACKUP: Dispatch timer for when app is active
        if duration <= 30 {
            scheduleShortTimerAudio(duration: duration, soundName: soundName)
            Logger.shared.log(.info, "⚡ Dispatch timer added for foreground", category: .audioSession)
        } else {
            scheduleTimerWithoutSilentLoop(duration: duration, soundName: soundName)
            Logger.shared.log(.info, "⏱️ Long timer scheduled without silent loop", category: .audioSession)
        }
        
        Logger.shared.log(.info, "✅ Timer audio scheduled with smart notification strategy", category: .audioSession)
    }
    
    // Smart notification that adapts to sound preference
    private func scheduleSmartNotification(after delay: TimeInterval, soundName: String) {
        // v3.0.2: DISABLED - Flutter handles notifications to avoid duplicates
        // We only use system sounds from iOS native, not notifications
        Logger.shared.log(.info, "📵 iOS notification disabled - Flutter handles notifications", category: .audioSession)
        return
        
        /* DISABLED TO AVOID DUPLICATE NOTIFICATIONS
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ Rest Timer Complete"
        content.body = "Time to start your next set!"
        
        // v3.0.2 TEMP FIX: Disable custom sounds to prevent double audio
        // Always use default notification sound since system sounds handle the actual audio
        content.sound = .default
        Logger.shared.log(.info, "🔊 Using .default notification (system sounds handle audio)", category: .audioSession)
        
        // DISABLED TEMPORARILY - Custom sounds causing double audio
        // if soundName != "timer_complete" && !soundName.isEmpty {
        //     content.sound = UNNotificationSound(named: UNNotificationSoundName("\(soundName).caf"))
        //     Logger.shared.log(.info, "🎵 Using custom sound: \(soundName).caf", category: .audioSession)
        // }
        
        content.categoryIdentifier = "TIMER_COMPLETE"
        
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 1.0
        }
        
        content.threadIdentifier = "gym-timer"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let identifier = UUID().uuidString
        scheduledNotification = identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                Logger.shared.log(.error, "Failed to schedule notification: \(error)", category: .audioSession)
            } else {
                Logger.shared.log(.info, "✅ Smart notification scheduled for \(delay)s", category: .audioSession)
            }
        }
        */
    }
    
    // Backup critical notification for silent mode
    private func scheduleBackupCriticalNotification(after delay: TimeInterval) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ Rest Timer Complete"
        content.body = "Time to start your next set!"
        
        // v3.0.0: Backup notification uses system default to ensure it's heard
        content.sound = .default // Always use standard sound for backup reliability
        content.categoryIdentifier = "TIMER_COMPLETE"
        
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 1.0
        }
        
        content.threadIdentifier = "gym-timer-backup"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let identifier = "timer-backup-\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                Logger.shared.log(.error, "Failed to schedule backup notification: \(error)", category: .audioSession)
            } else {
                Logger.shared.log(.info, "✅ Backup critical notification scheduled (0.5s later)", category: .audioSession)
            }
        }
    }
    
    // MARK: - Strategia 1: Timer Brevi (≤30s)
    private func scheduleShortTimerAudio(duration: TimeInterval, soundName: String) {
        startBackgroundTask()
        
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + duration) { [weak self] in
            // v3.0.0: Play actual sounds, not just vibration!
            self?.playCompletionSound(soundName: soundName)
            self?.endBackgroundTask()
        }
        
        Logger.shared.log(.info, "Short timer scheduled with dispatch", category: .audioSession)
    }
    
    // MARK: - Strategia 2: Timer con Notifica (>30s)
    private func scheduleLongTimerAudio(duration: TimeInterval, soundName: String) {
        scheduleLocalNotification(after: duration, soundName: soundName)
        Logger.shared.log(.info, "Long timer scheduled with notification", category: .audioSession)
    }
    
    // MARK: - Legacy Local Notification (kept for compatibility)
    private func scheduleLocalNotification(after delay: TimeInterval, soundName: String) {
        // Now just calls the smart notification
        scheduleSmartNotification(after: delay, soundName: soundName)
    }
    
    // MARK: - Audio Playback
    private func playCompletionSound(soundName: String) {
        // Track when audio is played to prevent double playback
        audioPlayedTimestamp = Date()
        lastCompletedSoundName = soundName
        
        // v3.0.0: Restored system sounds that actually work!
        // Play system sounds that bypass silent mode
        AudioServicesPlayAlertSound(1005)  // New mail sound - always audible
        AudioServicesPlaySystemSound(1016) // SMS sound as backup
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) // Vibration feedback
        
        Logger.shared.log(.info, "✅ System sounds played (1005, 1016) with vibration", category: .audioSession)
        Logger.shared.log(.info, "📝 Audio playback tracked at \(audioPlayedTimestamp!)", category: .audioSession)
    }
    
    // MARK: - Audio Tracking
    func hasAudioPlayedRecently(within seconds: TimeInterval = 5) -> Bool {
        guard let timestamp = audioPlayedTimestamp else { return false }
        return Date().timeIntervalSince(timestamp) < seconds
    }
    
    func getLastAudioPlaybackInfo() -> (timestamp: Date?, soundName: String?) {
        return (audioPlayedTimestamp, lastCompletedSoundName)
    }
    
    func resetAudioTracking() {
        audioPlayedTimestamp = nil
        lastCompletedSoundName = nil
        Logger.shared.log(.info, "🔄 Audio tracking reset", category: .audioSession)
    }
    
    // MARK: - Background Task Management
    private func startBackgroundTask() {
        endBackgroundTask()
        
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            Logger.shared.log(.warning, "Background task expiring", category: .backgroundTask)
            self?.endBackgroundTask()
        }
        
        Logger.shared.log(.info, "Background task started", category: .backgroundTask)
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    // MARK: - Silent Loop Management
    
    private func setupSilentLoopPlayer() {
        // Try to find silent loop file
        var silentURL: URL?
        
        if let path = Bundle.main.path(forResource: Config.silentLoopFileName, ofType: "wav") {
            silentURL = URL(fileURLWithPath: path)
            Logger.shared.log(.info, "✅ Found silent loop file", category: .audioSession)
        } else {
            Logger.shared.log(.warning, "⚠️ Silent loop file not found", category: .audioSession)
            return
        }
        
        guard let audioURL = silentURL else { return }
        
        do {
            silentLoopPlayer = try AVAudioPlayer(contentsOf: audioURL)
            silentLoopPlayer?.numberOfLoops = -1
            silentLoopPlayer?.volume = 0.01
            
            if silentLoopPlayer?.prepareToPlay() == true {
                Logger.shared.log(.info, "✅ Silent loop player prepared", category: .audioSession)
            }
        } catch {
            Logger.shared.log(.error, "Failed to setup silent loop: \(error)", category: .audioSession)
        }
    }
    
    private func startSilentLoop(maxDuration: TimeInterval) {
        guard !silentLoopActive else {
            Logger.shared.log(.debug, "Silent loop already active", category: .audioSession)
            return
        }
        
        guard let player = silentLoopPlayer else {
            Logger.shared.log(.error, "Silent loop player not available", category: .audioSession)
            return
        }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            
            Logger.shared.log(.info, "Audio session configured for silent loop", category: .audioSession)
        } catch {
            Logger.shared.log(.error, "Failed to configure audio session: \(error)", category: .audioSession)
            return
        }
        
        // Ensure audio plays even in silent mode
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            Logger.shared.log(.error, "Failed to set audio session for silent loop: \(error)", category: .audioSession)
        }
        
        guard player.play() else {
            Logger.shared.log(.error, "Failed to start silent loop", category: .audioSession)
            return
        }
        
        silentLoopActive = true
        
        // FIX: Log the actual duration being set
        Logger.shared.log(.info, "🔇 Silent loop started with duration: \(maxDuration)s", category: .audioSession)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + maxDuration) { [weak self] in
            self?.stopSilentLoop()
            Logger.shared.log(.info, "Silent loop auto-stopped after \(maxDuration)s", category: .audioSession)
        }
    }
    
    private func stopSilentLoop() {
        guard silentLoopActive else { return }
        
        silentLoopPlayer?.stop()
        silentLoopActive = false
        
        Logger.shared.log(.info, "🔇 Silent loop stopped", category: .audioSession)
    }
    
    private func scheduleTimerWithSilentLoop(duration: TimeInterval, soundName: String) {
        timerWorkItem?.cancel()
        
        timerWorkItem = DispatchWorkItem { [weak self] in
            self?.stopSilentLoop()
            self?.playCompletionSound(soundName: soundName)
            self?.timerCompletionHandler?()
            
            Logger.shared.log(.info, "✅ Timer completed", category: .audioSession)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: timerWorkItem!)
        
        Logger.shared.log(.info, "Timer scheduled for \(duration)s", category: .audioSession)
    }
    
    // 🎵 MUSIC-FRIENDLY: Timer without silent loop
    private func scheduleTimerWithoutSilentLoop(duration: TimeInterval, soundName: String) {
        timerWorkItem?.cancel()
        
        timerWorkItem = DispatchWorkItem { [weak self] in
            // v3.0.1 FIX: Play system sounds for long timers too!
            // This ensures audio plays even for timers > 30s
            self?.playCompletionSound(soundName: soundName)
            
            // Notifications handle backup audio
            self?.timerCompletionHandler?()
            
            Logger.shared.log(.info, "✅ Timer completed - system sounds played + notification backup", category: .audioSession)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: timerWorkItem!)
        
        Logger.shared.log(.info, "Music-friendly timer scheduled for \(duration)s", category: .audioSession)
    }
    
    // MARK: - Cancellation
    func cancelScheduledAudio() {
        stopSilentLoop()
        timerWorkItem?.cancel()
        timerWorkItem = nil
        
        if let identifier = scheduledNotification {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            scheduledNotification = nil
        }
        
        audioPlayer?.stop()
        endBackgroundTask()
        
        Logger.shared.log(.info, "All scheduled audio cancelled", category: .audioSession)
    }
    
    // MARK: - Public Status Methods
    
    func isSilentLoopActive() -> Bool {
        return silentLoopActive
    }
    
    func setTimerCompletionHandler(_ handler: @escaping () -> Void) {
        timerCompletionHandler = handler
    }
    
    func getDebugStatus() -> [String: Any] {
        return [
            "silentLoopActive": silentLoopActive,
            "timerWorkItemActive": timerWorkItem != nil,
            "scheduledNotification": scheduledNotification != nil,
            "backgroundTaskActive": backgroundTask != .invalid
        ]
    }
}

// MARK: - Flutter Integration

extension BackgroundAudioManager {
    func setupFlutterChannel(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.gymbro.background_audio",
            binaryMessenger: messenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "scheduleTimerAudio":
                if let args = call.arguments as? [String: Any],
                   let duration = args["duration"] as? Double {
                    let soundName = args["soundName"] as? String ?? "timer_complete"
                    self?.scheduleTimerAudio(duration: duration, soundName: soundName)
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
                }
                
            case "cancelAudio":
                self?.cancelScheduledAudio()
                result(true)
                
            case "startSilentLoop":
                if let args = call.arguments as? [String: Any],
                   let maxDuration = args["maxDuration"] as? Double {
                    self?.startSilentLoop(maxDuration: maxDuration)
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
                }
                
            case "stopSilentLoop":
                self?.stopSilentLoop()
                result(true)
                
            case "isSilentLoopActive":
                result(self?.silentLoopActive ?? false)
                
            case "getDebugStatus":
                result(self?.getDebugStatus())
                
            case "requestPermission":
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                    if let error = error {
                        Logger.shared.log(.error, "Permission error: \(error)", category: .permission)
                    }
                    result(granted)
                }
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}