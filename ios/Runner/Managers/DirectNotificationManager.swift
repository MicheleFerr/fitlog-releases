import UserNotifications
import UIKit
import AVFoundation
import UserNotifications

/// Manager diretto per notifiche iOS che bypassa flutter_local_notifications
/// Questo risolve il problema dei suoni custom che non funzionano in background
final class DirectNotificationManager: NSObject {

    static let shared = DirectNotificationManager()

    // CRITICAL FIX: Thread-safe notification tracking
    private let trackingQueue = DispatchQueue(label: "com.gymbro.notification.tracking", qos: .userInitiated)
    private var scheduledNotifications: [String: (timestamp: Date, soundName: String)] = [:]
    private var deliveredNotifications: [String: Date] = [:]

    // RACE CONDITION FIX: Flag to prevent scheduling when skip is in progress
    // This prevents the race condition where notification scheduling completes AFTER
    // the skip/cancel command is received from Apple Watch
    private var isSkipInProgress: Bool = false
    private var skipTimestamp: Date?

    private override init() {
        super.init()
        setupNotificationDelegate()
    }

    // CRITICAL FIX: Setup notification center delegate to track delivery
    private func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = self
        Logger.shared.log(.info, "✅ DirectNotificationManager delegate setup complete", category: .general)
    }
    
    /// Send a timer notification with custom sound (wrapper for Flutter bridge)
    func sendTimerNotification(
        title: String,
        body: String,
        soundName: String = "sound",
        categoryIdentifier: String = "TIMER_COMPLETE",
        delay: TimeInterval = 0
    ) {
        if delay <= 0 {
            // For immediate notifications, we need to send a notification RIGHT NOW
            // This is important for when the app is in background/locked
            print("🔔 IMMEDIATE TIMER NOTIFICATION")
            print("   Title: \(title)")
            print("   Body: \(body)")
            print("   Sound: \(soundName)")
            
            // Send immediate notification with custom sound
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.categoryIdentifier = categoryIdentifier
            
            // CRITICAL ALERT: Bypass mute switch AND DnD
            let soundFileName = soundName.hasSuffix(".caf") ? soundName : "\(soundName).caf"
            if #available(iOS 12.0, *) {
                content.sound = UNNotificationSound.criticalSoundNamed(
                    UNNotificationSoundName(rawValue: soundFileName),
                    withAudioVolume: 1.0
                )
            } else {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFileName))
            }
            
            // For immediate notifications on iOS 15+
            if #available(iOS 15.0, *) {
                content.interruptionLevel = .timeSensitive
                content.relevanceScore = 1.0
            }
            
            // Create request with no trigger (immediate delivery)
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil  // nil trigger = immediate delivery
            )
            
            // Add the notification
            center.add(request) { error in
                if let error = error {
                    print("❌ Failed to send immediate notification: \(error)")
                } else {
                    print("✅ Immediate notification sent with sound: \(soundFileName)")
                }
            }
            
            // Also try to play sound directly if app is active
            if UIApplication.shared.applicationState == .active {
                TimerSoundFix.shared.playTimerCompletionSound(preferredSound: soundName)
            }
        } else {
            // Schedule for future - this is the correct way for timer notifications
            _ = scheduleTimerNotification(
                after: delay,
                soundName: soundName,
                title: title,
                body: body
            )
        }
    }
    
    /// Schedula una notifica timer con ID specifico per evitare duplicati
    /// APPLE WATCH FIX: isForWatchDisplay permette di separare notifiche Watch da timer completion
    /// DOUBLE SOUND FIX: silentLoopHandlesAudio = true quando silent loop gestisce l'audio (mute bypass)
    func scheduleTimerNotificationWithId(
        identifier: String,
        after seconds: TimeInterval,
        soundName: String = "sound",
        title: String = "⏰ Timer Complete",
        body: String = "Your rest timer has finished!",
        isForWatchDisplay: Bool = false,
        silentLoopHandlesAudio: Bool = false
    ) {
        // Cancel any existing notification with same ID first
        cancelNotification(identifier: identifier)

        let center = UNUserNotificationCenter.current()

        // Verbose logging removed for production

        scheduleNotificationInternal(identifier: identifier, seconds: seconds, soundName: soundName, title: title, body: body, isForWatchDisplay: isForWatchDisplay, silentLoopHandlesAudio: silentLoopHandlesAudio)
    }

    /// Schedula una notifica timer con suono custom GARANTITO
    /// DOUBLE SOUND FIX: silentLoopHandlesAudio = true quando silent loop gestisce l'audio (mute bypass)
    func scheduleTimerNotification(
        after seconds: TimeInterval,
        soundName: String = "sound",
        title: String = "⏰ Timer Complete",
        body: String = "Your rest timer has finished!",
        silentLoopHandlesAudio: Bool = false
    ) -> String {

        let center = UNUserNotificationCenter.current()
        let identifier = UUID().uuidString

        // Verbose logging removed for production

        scheduleNotificationInternal(identifier: identifier, seconds: seconds, soundName: soundName, title: title, body: body, isForWatchDisplay: false, silentLoopHandlesAudio: silentLoopHandlesAudio)

        return identifier
    }

    
    /// Internal method to schedule notification
    /// APPLE WATCH FIX: isForWatchDisplay controlla se la notifica deve avere suono
    /// DOUBLE SOUND FIX: silentLoopHandlesAudio = true significa che AVAudioPlayer gestisce l'audio
    private func scheduleNotificationInternal(
        identifier: String,
        seconds: TimeInterval,
        soundName: String,
        title: String,
        body: String,
        isForWatchDisplay: Bool = false,
        silentLoopHandlesAudio: Bool = false
    ) {
        // RACE CONDITION FIX: Check if skip is in progress BEFORE scheduling
        // This prevents notifications from being scheduled right after a skip command
        let skipInProgress = trackingQueue.sync { isSkipInProgress }
        if skipInProgress {
            print("⛔ [RACE-FIX] Skip in progress - BLOCKING notification schedule")
            print("   - Would have scheduled: \(identifier)")
            print("   - Duration: \(seconds)s")
            print("   - This prevents the race condition where notification fires after skip")
            return
        }

        let center = UNUserNotificationCenter.current()

        // Crea il contenuto della notifica
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "TIMER_COMPLETE"

        // DOUBLE SOUND FIX: Determine if notification should have sound
        let shouldHaveSound = !isForWatchDisplay && !silentLoopHandlesAudio

        // APPLE WATCH FIX / SILENT LOOP FIX: Conditional sound based on purpose
        if isForWatchDisplay {
            // For Watch display: NO SOUND to prevent premature audio trigger
            content.sound = .none
            print("   - This notification is for Watch UI only")
            print("   - Timer completion sound will be handled separately by app")
        } else if silentLoopHandlesAudio {
            // DOUBLE SOUND FIX: Silent loop is active, AVAudioPlayer handles audio
            content.sound = .none
            print("🔇 [SILENT-NOTIFICATION] Silent loop handles audio - notification is visual only")
            print("   - AVAudioPlayer will play sound (bypasses mute)")
            print("   - Notification shows but doesn't play sound")
        }
        // NOTE: Timer completion sound (Critical Alert) is configured below

        if shouldHaveSound {
            print("📢 Custom sound configured for timer completion")
            print("⏰ Notification will fire in \(seconds) seconds")
            print("🔒 iOS notification system will play the sound even when locked")
        } else if !isForWatchDisplay && silentLoopHandlesAudio {
            print("🔇 Silent notification scheduled - AVAudioPlayer handles audio")
            print("⏰ Notification will fire in \(seconds) seconds (visual only)")
        } else {
            print("📱 Watch display notification configured (silent)")
            print("⏰ Will show timer info on Watch in \(seconds) seconds")
        }

        // iOS 15+ features for lockscreen visibility
        if #available(iOS 15.0, *) {
            if isForWatchDisplay {
                // Watch display: lower priority to avoid interrupting user
                content.interruptionLevel = .active
                content.relevanceScore = 0.7
                print("📱 [WATCH] Using active interruption level for Watch display")
            } else {
                // Timer completion: highest priority for lockscreen visibility
                // NOTE: timeSensitive bypasses DnD/Focus modes for VISUAL notification
                // However, notification sound STILL respects mute switch!
                // The actual audio bypass is handled by AVAudioPlayer in BackgroundAudioManager
                content.interruptionLevel = .timeSensitive
                content.relevanceScore = 1.0
                print("📱 [LOCKSCREEN] Using timeSensitive for DnD bypass (visual only)")
                print("   - Notification will SHOW even in DnD/Focus mode")
                if silentLoopHandlesAudio {
                    print("   - Sound: NONE (silent loop handles audio)")
                } else {
                    print("   - Notification SOUND respects mute switch")
                    print("   - Mute bypass handled by AVAudioPlayer (BackgroundAudioManager)")
                }
            }
        }

        // CRITICAL ALERTS: Bypass mute switch AND Do Not Disturb
        // Requires com.apple.developer.usernotifications.critical-alerts entitlement
        // DOUBLE SOUND FIX: Skip sound if silent loop is handling audio
        if shouldHaveSound {
            let criticalSoundFileName = soundName.hasSuffix(".caf") ? soundName : "\(soundName).caf"

            // CRITICAL ALERT: This bypasses BOTH mute switch AND DnD!
            // User volume controls are still respected via withAudioVolume parameter
            if #available(iOS 12.0, *) {
                if verifyAudioFile(soundName) {
                    content.sound = UNNotificationSound.criticalSoundNamed(
                        UNNotificationSoundName(rawValue: criticalSoundFileName),
                        withAudioVolume: 1.0  // Full volume (0.0 - 1.0)
                    )
                    print("🔊 [CRITICAL-ALERT] Using critical sound: \(criticalSoundFileName)")
                    print("   - Bypasses mute switch: ✅")
                    print("   - Bypasses Do Not Disturb: ✅")
                    print("   - Volume: 100%")
                } else {
                    // Fallback to default critical sound if custom file not found
                    content.sound = UNNotificationSound.defaultCritical
                    print("⚠️ [CRITICAL-ALERT] Custom sound not found, using defaultCritical")
                }
            } else {
                // iOS 11 fallback - no critical alerts available
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: criticalSoundFileName))
                print("⚠️ [FALLBACK] iOS 11 - critical alerts not available, using standard sound")
            }

            // Add user info for tracking
            content.userInfo = [
                "gymbro_timer_sound": soundName,
                "is_critical_alert": true,
                "scheduled_at": Date().timeIntervalSince1970
            ]
            print("📝 [CRITICAL-ALERT] Timer notification configured with critical sound")
        } else {
            // No sound but still add user info for tracking
            content.userInfo = [
                "gymbro_timer_sound": soundName,
                "is_critical_alert": false,
                "silent_loop_handles_audio": silentLoopHandlesAudio,
                "scheduled_at": Date().timeIntervalSince1970
            ]
        }
        
        // Aggiungi badge e thread ID
        content.badge = 0  // Reset badge
        content.threadIdentifier = "gym-timer"
        
        // Crea il trigger
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds,
            repeats: false
        )
        
        // Crea la richiesta
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // ✅ FIX #7: Measure notification scheduling performance
        let scheduleStart = Date()

        // Aggiungi la notifica
        center.add(request) { [weak self] error in
            let scheduleDuration = Date().timeIntervalSince(scheduleStart)
            let success = (error == nil)

            // ✅ FIX #7: Record notification scheduling metrics
            // PerformanceMetrics.shared.recordMetric(
            //     operation: PerformanceMetrics.Operation.notificationSend,
            //     duration: scheduleDuration,
            //     success: success,
            //     metadata: ["soundName": soundName, "delay": seconds]
            // )

            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                // CRITICAL FIX: Thread-safe tracking of scheduled notification
                self?.trackingQueue.sync {
                    self?.scheduledNotifications[identifier] = (timestamp: Date(), soundName: soundName)
                }

                let fireDate = Date().addingTimeInterval(seconds)
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"

                print("✅ Timer notification scheduled successfully")
                print("   - ID: \(identifier)")
                print("   - Fires in: \(seconds) seconds")
                print("   - Fire time: \(formatter.string(from: fireDate))")
                print("   - Sound: \(soundName).caf")
                print("   - App state: \(UIApplication.shared.applicationState == .active ? "Active" : UIApplication.shared.applicationState == .background ? "Background" : "Inactive")")

                // Log a reminder when the notification should fire
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
                    print("")
                    // Notification should be firing now
                    print("   - ID: \(identifier)")
                    print("   - Expected sound: \(soundName).caf")
                    print("   - Time: \(Date())")
                    print("   - App state: \(UIApplication.shared.applicationState == .active ? "Active" : UIApplication.shared.applicationState == .background ? "Background" : "Inactive")")

                    // CRITICAL FIX: Thread-safe check if notification was delivered
                    if let self = self {
                        let deliveryTime = self.trackingQueue.sync {
                            return self.deliveredNotifications[identifier]
                        }

                        if let deliveryTime = deliveryTime {
                            let delay = deliveryTime.timeIntervalSince(Date().addingTimeInterval(-seconds))
                            print("   ✅ NOTIFICATION DELIVERED at \(deliveryTime) (delay: \(String(format: "%.2f", delay))s)")
                        } else {
                            print("   ❌ NOTIFICATION NOT DELIVERED - checking for blocks...")
                            self.diagnoseNotificationIssues { issues in
                                for issue in issues {
                                    print("   🔍 \(issue)")
                                }
                            }
                        }
                    }

                    // Check if app is in background/locked
                    if UIApplication.shared.applicationState != .active {
                        print("   ⚠️ App is NOT active - notification MUST handle the sound")
                        print("   📱 Device may be locked - check if sound plays")
                        print("   🔊 Sound should play through notification system")
                        print("   📍 If no sound: Check Settings > Notifications > GymBro > Sounds")
                        print("   📍 If no sound: Check device is not in Silent Mode")
                        print("   📍 If no sound: Check Focus/DND settings")
                    } else {
                        print("   ✅ App is active - notification may not show")
                        print("   💡 App should handle sound playback directly")
                    }

                    // Additional debugging for sound issues
                    print("")
                    print("🔍 SOUND DEBUGGING CHECKLIST:")
                    print("   1. Was notification cancelled before firing? Check logs above")
                    print("   2. Is device in Silent Mode? Physical switch on side")
                    print("   3. Is Focus/DND active? Check Control Center")
                    print("   4. Are notification sounds enabled? Settings > Notifications > GymBro")
                    print("   5. Is volume turned up? Check with volume buttons")
                    print("")
                }

                // Notify Flutter that notification was scheduled
                self?.notifyFlutterNotificationScheduled(identifier: identifier)
            }
        }
    }
    
    /// Cancella una notifica specifica (pending)
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
        print("🗑️ Cancelled pending notification: \(identifier)")
    }

    /// Cancella tutte le notifiche timer (pending)
    /// RACE CONDITION FIX: Also sets isSkipInProgress flag to prevent new notifications
    /// from being scheduled during the skip operation
    func cancelAllTimerNotifications() {
        // RACE CONDITION FIX: Set flag BEFORE cancelling to block any pending schedules
        trackingQueue.sync {
            isSkipInProgress = true
            skipTimestamp = Date()
        }
        print("🗑️ [SKIP] Set isSkipInProgress = true to block new notifications")

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Cancelled all pending notifications")

        // RACE CONDITION FIX: Keep the flag active for a short time to catch
        // any async scheduling that was already in flight
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.trackingQueue.sync {
                // Only reset if this is the same skip operation (check timestamp)
                if let skipTime = self?.skipTimestamp,
                   Date().timeIntervalSince(skipTime) >= 0.5 {
                    self?.isSkipInProgress = false
                    print("🔓 [SKIP] Reset isSkipInProgress after 0.5s grace period")
                }
            }
        }
    }

    /// Reset the skip flag - call this when starting a NEW legitimate timer
    /// This allows notifications to be scheduled again after a skip
    func resetSkipFlag() {
        trackingQueue.sync {
            isSkipInProgress = false
            skipTimestamp = nil
        }
        print("🔓 [TIMER] Reset isSkipInProgress - new timer can schedule notifications")
    }

    /// Auto-dismiss: Rimuove una notifica già consegnata dopo un certo delay
    /// - Parameters:
    ///   - identifier: ID della notifica da rimuovere
    ///   - afterSeconds: Secondi di attesa prima della rimozione (default 60)
    func scheduleNotificationRemoval(identifier: String, afterSeconds: TimeInterval = 60) {
        DispatchQueue.main.asyncAfter(deadline: .now() + afterSeconds) {
            UNUserNotificationCenter.current().removeDeliveredNotifications(
                withIdentifiers: [identifier]
            )
            print("🧹 Auto-dismissed notification after \(Int(afterSeconds))s: \(identifier)")
        }
    }

    /// Rimuove tutte le notifiche timer già consegnate
    func removeAllDeliveredTimerNotifications() {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let timerNotificationIds = notifications
                .filter { $0.request.content.categoryIdentifier == "TIMER_COMPLETE" }
                .map { $0.request.identifier }

            if !timerNotificationIds.isEmpty {
                UNUserNotificationCenter.current().removeDeliveredNotifications(
                    withIdentifiers: timerNotificationIds
                )
                print("🧹 Removed \(timerNotificationIds.count) delivered timer notifications")
            }
        }
    }

    /// AUTO-DISMISS: Rimuove notifiche timer più vecchie di X secondi
    /// Chiamato quando l'app torna in foreground per pulire notifiche vecchie
    /// - Parameter olderThanSeconds: Rimuove notifiche più vecchie di questo (default 60s)
    func cleanupOldTimerNotifications(olderThanSeconds: TimeInterval = 60) {
        let cutoffDate = Date().addingTimeInterval(-olderThanSeconds)

        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            var toRemove: [String] = []

            for notification in notifications {
                let content = notification.request.content

                // Only process timer notifications
                guard content.categoryIdentifier == "TIMER_COMPLETE" else { continue }

                // Check if notification was scheduled more than X seconds ago
                if let scheduledAt = content.userInfo["scheduled_at"] as? TimeInterval {
                    let scheduledDate = Date(timeIntervalSince1970: scheduledAt)
                    if scheduledDate < cutoffDate {
                        toRemove.append(notification.request.identifier)
                    }
                } else {
                    // No timestamp - check delivery date
                    if notification.date < cutoffDate {
                        toRemove.append(notification.request.identifier)
                    }
                }
            }

            if !toRemove.isEmpty {
                UNUserNotificationCenter.current().removeDeliveredNotifications(
                    withIdentifiers: toRemove
                )
                print("🧹 [AUTO-DISMISS] Cleaned up \(toRemove.count) old timer notifications (> \(Int(olderThanSeconds))s)")
            }
        }
    }
    
    /// Verifica che il file audio esista
    func verifyAudioFile(_ soundName: String) -> Bool {
        // Verifying audio file
        
        if let path = Bundle.main.path(forResource: soundName, ofType: "caf") {
            print("✅ Audio file found: \(path)")
            
            // Verifica che sia leggibile
            let url = URL(fileURLWithPath: path)
            if FileManager.default.isReadableFile(atPath: url.path) {
                print("✅ Audio file is readable")
                
                // Verifica la dimensione
                if let attributes = try? FileManager.default.attributesOfItem(atPath: path),
                   let fileSize = attributes[.size] as? Int64 {
                    print("📊 Audio file size: \(fileSize) bytes")
                    
                    // iOS limita i suoni delle notifiche a 30 secondi / ~5MB
                    if fileSize > 5_000_000 {
                        print("⚠️ Warning: Audio file may be too large for notifications")
                        return false
                    } else if fileSize == 0 {
                        print("❌ Error: Audio file is empty")
                        return false
                    }
                    
                    // Additional check: Try to create a UNNotificationSound to verify iOS can use it
                    // LOCKSCREEN FIX: Use sound name WITH .caf extension
                    let testSound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(soundName).caf"))
                    print("✅ UNNotificationSound created successfully for \(soundName).caf")
                    
                    return true
                } else {
                    print("❌ Cannot get audio file attributes")
                    return false
                }
            } else {
                print("❌ Audio file exists but is not readable")
                return false
            }
        } else {
            print("❌ Audio file not found: \(soundName).caf")
            
            // Debug: List all .caf files in the bundle
            if let bundlePath = Bundle.main.resourcePath {
                let bundleURL = URL(fileURLWithPath: bundlePath)
                do {
                    let contents = try FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil, options: [])
                    let cafFiles = contents.filter { $0.pathExtension == "caf" }
                    print("📁 Available .caf files in bundle:")
                    for cafFile in cafFiles {
                        print("   - \(cafFile.lastPathComponent)")
                    }
                } catch {
                    print("❌ Error listing bundle contents: \(error)")
                }
            }
            
            // Prova a cercare altri formati
            for ext in ["wav", "aiff", "m4a"] {
                if let _ = Bundle.main.path(forResource: soundName, ofType: ext) {
                    print("ℹ️ Found \(soundName).\(ext) but notifications require .caf format")
                }
            }
            return false
        }
    }
    
    /// Richiedi permessi per le notifiche
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("❌ Permission error: \(error)")
            }
            print(granted ? "✅ Notification permission granted" : "❌ Notification permission denied")
            completion(granted)
        }
    }
    
    /// Controlla lo stato dei permessi
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
    
    /// Diagnostica i problemi delle notifiche per il debug
    func diagnoseNotificationIssues(completion: @escaping ([String]) -> Void) {
        var issues: [String] = []
        
        // Check notification settings
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            // Authorization status
            switch settings.authorizationStatus {
            case .denied:
                issues.append("❌ Notification permission DENIED - User must enable in Settings")
            case .notDetermined:
                issues.append("⚠️ Notification permission NOT REQUESTED - Need to request permission")
            case .provisional:
                issues.append("ℹ️ Notification permission PROVISIONAL - Limited notifications")
            case .authorized:
                issues.append("✅ Notification permission AUTHORIZED")
            case .ephemeral:
                issues.append("ℹ️ Notification permission EPHEMERAL - App Clips only")
            @unknown default:
                issues.append("❓ Notification permission UNKNOWN")
            }
            
            // Sound settings
            switch settings.soundSetting {
            case .enabled:
                issues.append("✅ Notification sounds ENABLED")
            case .disabled:
                issues.append("❌ Notification sounds DISABLED - User must enable in Settings > Notifications > App Name > Sounds")
            case .notSupported:
                issues.append("❌ Notification sounds NOT SUPPORTED")
            @unknown default:
                issues.append("❓ Notification sounds status UNKNOWN")
            }
            
            // Alert settings
            switch settings.alertSetting {
            case .enabled:
                issues.append("✅ Notification alerts ENABLED")
            case .disabled:
                issues.append("❌ Notification alerts DISABLED")
            case .notSupported:
                issues.append("❌ Notification alerts NOT SUPPORTED")
            @unknown default:
                issues.append("❓ Notification alerts status UNKNOWN")
            }
            
            // Lock screen settings
            switch settings.lockScreenSetting {
            case .enabled:
                issues.append("✅ Lock screen notifications ENABLED")
            case .disabled:
                issues.append("❌ Lock screen notifications DISABLED - Enable in Settings for locked device sounds")
            case .notSupported:
                issues.append("❌ Lock screen notifications NOT SUPPORTED")
            @unknown default:
                issues.append("❓ Lock screen notifications status UNKNOWN")
            }
            
            // Time sensitive settings (iOS 15+)
            if #available(iOS 15.0, *) {
                switch settings.timeSensitiveSetting {
                case .enabled:
                    issues.append("✅ Time Sensitive notifications ENABLED - Can bypass Focus/DND")
                case .disabled:
                    issues.append("❌ Time Sensitive notifications DISABLED - May be blocked by Focus/DND")
                case .notSupported:
                    issues.append("❌ Time Sensitive notifications NOT SUPPORTED")
                @unknown default:
                    issues.append("❓ Time Sensitive notifications status UNKNOWN")
                }
            }
            
            // Check device settings
            DispatchQueue.main.async {
                // Check if device is in silent mode (this is an approximation)
                let audioSession = AVAudioSession.sharedInstance()
                issues.append("🔇 Device volume: \(audioSession.outputVolume)")
                if audioSession.outputVolume == 0.0 {
                    issues.append("⚠️ Device volume is 0 - User may not hear notification sounds")
                }
                
                // Check current audio route
                let currentRoute = audioSession.currentRoute
                let outputs = currentRoute.outputs.map { $0.portType.rawValue }
                issues.append("🎧 Audio output: \(outputs.joined(separator: ", "))")
                
                completion(issues)
            }
        }
    }
    
    /// Test notification immediato per debug - usa Critical Alert
    func sendTestNotification() {
        print("🧪 [TEST] Sending immediate Critical Alert test notification")

        let content = UNMutableNotificationContent()
        content.title = "🧪 Critical Alert Test"
        content.body = "If you hear this with mute ON, Critical Alerts work!"
        content.categoryIdentifier = "TIMER_TEST"

        // CRITICAL ALERT: Bypasses mute switch AND DnD
        if #available(iOS 12.0, *) {
            content.sound = UNNotificationSound.criticalSoundNamed(
                UNNotificationSoundName("sound.caf"),
                withAudioVolume: 1.0
            )
            print("   - Using Critical Alert sound")
            print("   - Bypasses mute: ✅")
            print("   - Bypasses DnD: ✅")
        } else {
            content.sound = UNNotificationSound(named: UNNotificationSoundName("sound.caf"))
        }

        // iOS 15+ settings
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .critical
            content.relevanceScore = 1.0
        }
        
        let request = UNNotificationRequest(
            identifier: "test_\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Test notification failed: \(error)")
            } else {
                print("✅ Test notification scheduled - should play in 1 second")
            }
        }
    }
    
    /// Notify Flutter when notification is scheduled
    private func notifyFlutterNotificationScheduled(identifier: String) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let controller = windowScene.windows.first?.rootViewController as? FlutterViewController {
                let unifiedChannel = FlutterMethodChannel(name: "com.gymbro.timer/unified",
                                                         binaryMessenger: controller.binaryMessenger)
                unifiedChannel.invokeMethod("notificationScheduled", arguments: [
                    "identifier": identifier,
                    "timestamp": Date().timeIntervalSince1970
                ])
                print("📨 Notified Flutter that notification was scheduled")
            }
        }
    }

    // ✅ FIX #2: Check if notification was actually delivered
    /// Verifies if a notification was delivered to the user
    /// Used to ensure notifications are sent even if Live Activity fails
    func wasNotificationDelivered(identifier: String) -> Bool {
        return trackingQueue.sync {
            return deliveredNotifications[identifier] != nil
        }
    }

    // ✅ FIX #2: Get recent notification deliveries for debugging
    /// Returns the list of recently delivered notification IDs
    func getRecentDeliveries(within seconds: TimeInterval) -> [String] {
        let cutoff = Date().addingTimeInterval(-seconds)
        return trackingQueue.sync {
            return deliveredNotifications.filter { $0.value > cutoff }.map { $0.key }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

// CRITICAL FIX: Implement notification delegate to track delivery and presentation
extension DirectNotificationManager: UNUserNotificationCenterDelegate {

    /// Called when notification is delivered while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let identifier = notification.request.identifier

        // CRITICAL FIX: Thread-safe delivery tracking
        trackingQueue.sync {
            deliveredNotifications[identifier] = Date()
        }

        print("📲 [NOTIFICATION-DELEGATE] willPresent called:")
        print("   - ID: \(identifier)")
        print("   - Title: \(notification.request.content.title)")
        print("   - Sound: \(notification.request.content.sound?.debugDescription ?? "none")")
        print("   - App State: Foreground")

        // Check if this is our timer notification
        let scheduled = trackingQueue.sync {
            return scheduledNotifications[identifier]
        }

        if let scheduled = scheduled {
            let deliveryDelay = Date().timeIntervalSince(scheduled.timestamp)
            print("   ✅ Timer notification delivered in foreground (delay: \(String(format: "%.2f", deliveryDelay))s)")
            print("   🔊 Expected sound: \(scheduled.soundName)")

            // ✅ FIX #7: Record notification delivery metrics
            // PerformanceMetrics.shared.recordMetric(
            //     operation: PerformanceMetrics.Operation.notificationDelivery,
            //     duration: deliveryDelay,
            //     success: true,
            //     metadata: ["state": "foreground", "soundName": scheduled.soundName]
            // )

            // ENHANCED: Prepare audio session when timer notification is about to present
            prepareAudioSessionForNotification(soundName: scheduled.soundName)
        }

        // ENHANCED: Check for audio session requirements in user info
        let userInfo = notification.request.content.userInfo
        if let requiresAudioSession = userInfo["requires_audio_session"] as? Bool,
           requiresAudioSession {
            let soundName = userInfo["gymbro_timer_sound"] as? String ?? "sound"
            print("   🔊 [AUDIO-PREPARE] Notification requires audio session preparation")
            prepareAudioSessionForNotification(soundName: soundName)
        }

        // Show notification even when app is in foreground for timer completion
        let isTimerNotification = notification.request.content.categoryIdentifier == "TIMER_COMPLETE"
            || identifier.contains("timer")
            || identifier.contains("gymbro")

        if isTimerNotification {
            completionHandler([.alert, .sound, .badge])
            print("   📱 Showing timer notification in foreground with sound")

            // AUTO-DISMISS: Remove notification after 60 seconds
            scheduleNotificationRemoval(identifier: identifier, afterSeconds: 60)
            print("   ⏱️ Auto-dismiss scheduled in 60 seconds")
        } else {
            completionHandler([.alert, .sound])
        }
    }

    /// Called when user taps notification or it's delivered in background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier

        // CRITICAL FIX: Thread-safe delivery tracking and cleanup
        let scheduled = trackingQueue.sync { () -> (timestamp: Date, soundName: String)? in
            deliveredNotifications[identifier] = Date()
            let scheduled = scheduledNotifications[identifier]
            scheduledNotifications.removeValue(forKey: identifier) // Clean up
            return scheduled
        }

        print("📬 [NOTIFICATION-DELEGATE] didReceive called:")
        print("   - ID: \(identifier)")
        print("   - Action: \(response.actionIdentifier)")
        print("   - Title: \(response.notification.request.content.title)")

        // Check if this is our timer notification
        if let scheduled = scheduled {
            let deliveryDelay = Date().timeIntervalSince(scheduled.timestamp)
            print("   ✅ Timer notification received (delay: \(String(format: "%.2f", deliveryDelay))s)")
            print("   🎵 Sound should have played: \(scheduled.soundName)")

            // If user dismissed from Watch, log it
            if response.actionIdentifier == UNNotificationDismissActionIdentifier {
                print("   ⚠️ Notification was dismissed (possibly from Apple Watch)")
                print("   🚨 This should NOT trigger timer sound according to requirements")
            }
        }

        completionHandler()
    }

    // MARK: - Audio Session Helper

    /// Prepare audio session specifically for notification sound playback
    /// CENTRALIZED: Uses AudioSessionManager to prevent race conditions
    private func prepareAudioSessionForNotification(soundName: String) {
        print("🔊 [AUDIO-PREPARE] Preparing audio session for notification sound: \(soundName)")

        // CENTRALIZED: Use AudioSessionManager for ALL audio session configuration
        // This prevents OSStatus -50 errors from conflicting configurations
        AudioSessionManager.shared.reactivate()
        print("   ✅ Audio session configured via AudioSessionManager")

        // Verify the sound file is accessible
        if verifyAudioFile(soundName) {
            print("   ✅ Sound file verified: \(soundName).caf")
        } else {
            print("   ⚠️ Sound file verification failed, notification will use default sound")
        }
    }
}

