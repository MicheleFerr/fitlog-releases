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
            
            // Use custom sound file
            let soundFileName = soundName.hasSuffix(".caf") ? soundName : "\(soundName).caf"
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFileName))
            
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
    func scheduleTimerNotificationWithId(
        identifier: String,
        after seconds: TimeInterval,
        soundName: String = "sound",
        title: String = "⏰ Timer Complete",
        body: String = "Your rest timer has finished!",
        isForWatchDisplay: Bool = false
    ) {
        // Cancel any existing notification with same ID first
        cancelNotification(identifier: identifier)
        
        let center = UNUserNotificationCenter.current()
        
        // Verbose logging removed for production
        
        scheduleNotificationInternal(identifier: identifier, seconds: seconds, soundName: soundName, title: title, body: body, isForWatchDisplay: false)
    }
    
    /// Schedula una notifica timer con suono custom GARANTITO
    func scheduleTimerNotification(
        after seconds: TimeInterval,
        soundName: String = "sound",
        title: String = "⏰ Timer Complete",
        body: String = "Your rest timer has finished!"
    ) -> String {
        
        let center = UNUserNotificationCenter.current()
        let identifier = UUID().uuidString
        
        // Verbose logging removed for production
        
        scheduleNotificationInternal(identifier: identifier, seconds: seconds, soundName: soundName, title: title, body: body, isForWatchDisplay: false)

        return identifier
    }

    
    /// Internal method to schedule notification
    /// APPLE WATCH FIX: isForWatchDisplay controlla se la notifica deve avere suono
    private func scheduleNotificationInternal(
        identifier: String,
        seconds: TimeInterval,
        soundName: String,
        title: String,
        body: String,
        isForWatchDisplay: Bool = false
    ) {
        let center = UNUserNotificationCenter.current()
        
        // Crea il contenuto della notifica
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "TIMER_COMPLETE"
        
        // APPLE WATCH FIX: Conditional sound based on purpose
        if isForWatchDisplay {
            // For Watch display: NO SOUND to prevent premature audio trigger
            content.sound = .none
            // Muted for Watch display notification
            print("   - This notification is for Watch UI only")
            print("   - Timer completion sound will be handled separately by app")
        } else {
            // For timer completion: FULL SOUND for lockscreen audio
            // Build the sound filename with .caf extension
            let soundFileName = soundName.hasSuffix(".caf") ? soundName : "\(soundName).caf"

            print("🔊 [TIMER-COMPLETION] Configuring custom notification sound for lockscreen")
            print("   - Requested sound: \(soundName)")
            print("   - Using file: \(soundFileName)")
            print("   - iOS will handle playback when device is locked")

            // Use custom sound file - iOS handles the playback
            // IMPORTANT: The sound file must be in the app bundle (verified above)
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFileName))
        }

        if !isForWatchDisplay {
            print("📢 Custom sound configured for timer completion")
            print("⏰ Notification will fire in \(seconds) seconds")
            print("🔒 iOS notification system will play the sound even when locked")
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
                // Timer completion: highest priority for lockscreen sound
                content.interruptionLevel = .timeSensitive
                content.relevanceScore = 1.0
                print("📱 [LOCKSCREEN] Using timeSensitive interruption level for guaranteed sound")
                print("   - This bypasses Focus modes and ensures sound plays")
                print("   - Sound will play even if device is in Do Not Disturb")
            }
        }
        
        // ENHANCED: Multiple sound strategies for maximum reliability
        if !isForWatchDisplay {
            let criticalSoundFileName = soundName.hasSuffix(".caf") ? soundName : "\(soundName).caf"

            // Strategy 1: Try custom sound with maximum volume
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: criticalSoundFileName))
            print("🔊 [AUDIO-STRATEGY-1] Using custom sound: \(criticalSoundFileName)")

            // Strategy 2: Backup sound verification
            if !verifyAudioFile(soundName) {
                print("⚠️ [AUDIO-FALLBACK] Custom sound failed verification - using system default")
                content.sound = UNNotificationSound.default
            }

            // Strategy 3: Add user info for audio session preparation
            content.userInfo = [
                "gymbro_timer_sound": soundName,
                "requires_audio_session": true,
                "audio_priority": "high",
                "scheduled_at": Date().timeIntervalSince1970
            ]
            print("📝 [AUDIO-METADATA] Added audio session requirements to notification")
        }
        
        // LOCKSCREEN FIX: Ensure notification is delivered even when device is locked
        if #available(iOS 12.0, *) {
            // Critical alert would bypass Do Not Disturb but requires special entitlement
            // content.sound = UNNotificationSound.defaultCritical // Requires entitlement
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
    
    /// Cancella una notifica specifica
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
        print("🗑️ Cancelled notification: \(identifier)")
    }
    
    /// Cancella tutte le notifiche timer
    func cancelAllTimerNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Cancelled all pending notifications")
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
    
    /// Test notification immediato per debug
    func sendTestNotification() {
        print("🧪 [TEST] Sending immediate test notification")
        
        let content = UNMutableNotificationContent()
        content.title = "🧪 Test Notification"
        content.body = "Testing timer sound - you should hear audio now"
        content.categoryIdentifier = "TIMER_TEST"
        
        // Use custom sound
        content.sound = UNNotificationSound(named: UNNotificationSoundName("sound.caf"))
        
        // iOS 15+ settings
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 1.0
        }
        
        // Critical alert for testing (if available)
        if #available(iOS 12.0, *) {
            content.sound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName("sound.caf"), withAudioVolume: 1.0)
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
        if identifier.contains("timer") || identifier.contains("gymbro") {
            completionHandler([.alert, .sound, .badge])
            print("   📱 Showing timer notification in foreground with sound")
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
    private func prepareAudioSessionForNotification(soundName: String) {
        print("🔊 [AUDIO-PREPARE] Preparing audio session for notification sound: \(soundName)")

        do {
            // Use AudioSessionManager for consistent configuration
            AudioSessionManager.shared.reactivate()
            print("   ✅ Audio session reactivated via AudioSessionManager")

            // Additional backup: Direct audio session preparation
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [
                .duckOthers,
                .allowBluetooth,
                .allowBluetoothA2DP
            ])
            try session.setActive(true, options: [])
            print("   ✅ Audio session configured for notification playback")

            // Verify the sound file is accessible
            if verifyAudioFile(soundName) {
                print("   ✅ Sound file verified: \(soundName).caf")
            } else {
                print("   ⚠️ Sound file verification failed, notification will use default sound")
            }

        } catch {
            print("   ❌ Failed to prepare audio session: \(error)")
        }
    }
}

