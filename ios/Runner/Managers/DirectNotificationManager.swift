import UserNotifications
import UIKit
import AVFoundation

// AUDIO-FIX: Removed objc_setAssociatedObject — used activePlayers array instead

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

    // ✅ AUDIO-FIX: Array of active players to prevent ARC deallocation during playback.
    // objc_setAssociatedObject was overwriting previous player, killing it mid-playback.
    private var activePlayers: [AVAudioPlayer] = []

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
    /// - Parameters:
    ///   - title: Notification title
    ///   - body: Notification body text
    ///   - soundName: Sound file name (without .caf extension)
    ///   - categoryIdentifier: iOS notification category
    ///   - delay: Delay before sending (0 = immediate, >0 = scheduled)
    /// - Note: Delegates to helper methods for cleaner implementation
    func sendTimerNotification(
        title: String,
        body: String,
        soundName: String = "sound",
        categoryIdentifier: String = "TIMER_COMPLETE",
        delay: TimeInterval = 0
    ) {
        if delay <= 0 {
            // Immediate notification path (trigger: nil)
            logNotificationDiagnostics(title: title, body: body, soundName: soundName)

            let content = createNotificationContent(
                title: title,
                body: body,
                soundName: soundName,
                categoryIdentifier: categoryIdentifier,
                isForWatchDisplay: false,
                silentLoopHandlesAudio: false
            )

            sendImmediateNotification(content: content, fallbackSoundName: soundName)
        } else {
            // Scheduled notification path (TimeIntervalTrigger)
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

        print("🔔 [scheduleTimerNotification] ENTRY:")
        print("   - delay: \(seconds)s")
        print("   - sound: \(soundName)")
        print("   - silentLoopHandlesAudio: \(silentLoopHandlesAudio)")
        print("   - identifier: \(identifier)")

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
        print("🔍 [scheduleNotificationInternal] isSkipInProgress check: \(skipInProgress)")
        if skipInProgress {
            print("⛔ [RACE-FIX] Skip in progress - BLOCKING notification schedule")
            print("   - Would have scheduled: \(identifier)")
            print("   - Duration: \(seconds)s")
            print("   - This prevents the race condition where notification fires after skip")
            return
        }
        print("✅ [scheduleNotificationInternal] Proceeding with notification scheduling")

        let center = UNUserNotificationCenter.current()

        // Create notification content using extracted helper method
        // This consolidates ~100 lines of content creation logic
        let shouldHaveSound = !isForWatchDisplay && !silentLoopHandlesAudio

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

        let content = createNotificationContent(
            title: title,
            body: body,
            soundName: soundName,
            categoryIdentifier: "TIMER_COMPLETE",
            isForWatchDisplay: isForWatchDisplay,
            silentLoopHandlesAudio: silentLoopHandlesAudio
        )

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
                print("❌ [scheduleNotificationInternal] Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ [scheduleNotificationInternal] Notification SUCCESSFULLY scheduled!")
                print("   - ID: \(identifier)")
                print("   - Sound: \(soundName)")
                print("   - Fires in: \(seconds)s")
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

    /// Cancella tutte le notifiche pending (simple version)
    /// Use this when you're about to schedule a new notification immediately after
    /// This does NOT set the skip flag, so new notifications can still be scheduled
    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Cancelled all pending notifications (simple cancel, no skip flag)")
    }

    /// Cancella tutte le notifiche timer (pending) + blocks new notifications
    /// RACE CONDITION FIX: Also sets isSkipInProgress flag to prevent new notifications
    /// from being scheduled during the skip operation
    func cancelAllTimerNotifications() {
        // RACE CONDITION FIX: Set flag BEFORE cancelling to block any pending schedules.
        // FIX C8: Use async write to avoid blocking the calling thread.
        trackingQueue.async { [weak self] in
            self?.isSkipInProgress = true
            self?.skipTimestamp = Date()
        }
        print("🗑️ [SKIP] Set isSkipInProgress = true to block new notifications")

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Cancelled all pending notifications")

        // RACE CONDITION FIX: Keep the flag active for a short time to catch
        // any async scheduling that was already in flight
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            // FIX C8: Use async write inside asyncAfter to avoid blocking.
            self?.trackingQueue.async { [weak self] in
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
        // FIX C8: Use async write to avoid blocking the calling thread.
        trackingQueue.async { [weak self] in
            self?.isSkipInProgress = false
            self?.skipTimestamp = nil
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
        print("🧪 [TEST] Sending test notification (regular sound)")

        let content = UNMutableNotificationContent()
        content.title = "🧪 Timer Sound Test"
        content.body = "If you hear this, notification sounds are working!"
        content.categoryIdentifier = "TIMER_TEST"

        // Regular notification sound (Critical Alert entitlement pending)
        content.sound = UNNotificationSound(named: UNNotificationSoundName("sound.caf"))
        print("   - Using regular notification sound")
        print("   - Critical Alert: ⏳ pending Apple approval")
        print("   - Sound respects mute switch")

        // iOS 15+ settings - use timeSensitive (not critical, requires entitlement)
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
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
            FlutterChannelRegistry.shared.unified?.invokeMethod("notificationScheduled", arguments: [
                "identifier": identifier,
                "timestamp": Date().timeIntervalSince1970
            ])
            print("📨 Notified Flutter that notification was scheduled")
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

    // MARK: - Notification Content Creation Helpers

    /// Creates a UNMutableNotificationContent configured for timer notifications
    /// - Parameters:
    ///   - title: Notification title
    ///   - body: Notification body text
    ///   - soundName: Name of sound file (without .caf extension)
    ///   - categoryIdentifier: iOS notification category (default: "TIMER_COMPLETE")
    ///   - isForWatchDisplay: If true, notification is silent (for Watch UI only)
    ///   - silentLoopHandlesAudio: If true, AVAudioPlayer handles audio (notification is visual)
    /// - Returns: Configured UNMutableNotificationContent ready for use
    private func createNotificationContent(
        title: String,
        body: String,
        soundName: String,
        categoryIdentifier: String = "TIMER_COMPLETE",
        isForWatchDisplay: Bool = false,
        silentLoopHandlesAudio: Bool = false
    ) -> UNMutableNotificationContent {
        var content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = categoryIdentifier
        content.badge = 0
        content.threadIdentifier = "gym-timer"

        configureSoundForNotification(
            content: &content,
            soundName: soundName,
            shouldHaveSound: !isForWatchDisplay && !silentLoopHandlesAudio,
            silentLoopHandlesAudio: silentLoopHandlesAudio
        )

        configureIOSFeaturesForNotification(
            content: &content,
            isForWatchDisplay: isForWatchDisplay
        )

        return content
    }

    /// Configures sound settings for notification content
    /// - Parameters:
    ///   - content: Notification content to configure (modified in-place via inout)
    ///   - soundName: Name of sound file to use
    ///   - shouldHaveSound: Whether notification should play sound
    ///   - silentLoopHandlesAudio: Whether silent loop is handling audio
    /// - Note: Modifies content.sound and content.userInfo in-place
    private func configureSoundForNotification(
        content: inout UNMutableNotificationContent,
        soundName: String,
        shouldHaveSound: Bool,
        silentLoopHandlesAudio: Bool
    ) {
        if shouldHaveSound {
            let soundFileName = soundName.hasSuffix(".caf") ? soundName : "\(soundName).caf"

            if verifyAudioFile(soundName) {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFileName))
                print("🔊 [NOTIFICATION-SOUND] Using regular notification sound: \(soundFileName)")
                print("   - Critical Alert entitlement: ⏳ PENDING Apple approval")
                print("   - Fallback: Using regular sound (respects mute switch)")
                print("   - Sound will play if device is NOT muted")
            } else {
                content.sound = .default
                print("⚠️ [NOTIFICATION-SOUND] Custom sound not found, using system default")
            }

            content.userInfo = [
                "gymbro_timer_sound": soundName,
                "is_critical_alert": false,
                "scheduled_at": Date().timeIntervalSince1970
            ]
            print("📝 [NOTIFICATION] Timer notification configured with regular sound (Critical Alert pending)")
        } else {
            content.sound = .none
            content.userInfo = [
                "gymbro_timer_sound": soundName,
                "is_critical_alert": false,
                "silent_loop_handles_audio": silentLoopHandlesAudio,
                "scheduled_at": Date().timeIntervalSince1970
            ]

            if silentLoopHandlesAudio {
                print("🔇 [SILENT-NOTIFICATION] Silent loop handles audio - notification is visual only")
                print("   - AVAudioPlayer will play sound (bypasses mute)")
                print("   - Notification shows but doesn't play sound")
            } else {
                print("📱 [WATCH] This notification is for Watch UI only")
                print("   - Timer completion sound will be handled separately by app")
            }
        }
    }

    /// Configures iOS 15+ features for notification content
    /// - Parameters:
    ///   - content: Notification content to configure (modified in-place via inout)
    ///   - isForWatchDisplay: Whether this is for Watch UI (affects interruption level)
    /// - Note: Modifies content.interruptionLevel and content.relevanceScore on iOS 15+
    private func configureIOSFeaturesForNotification(
        content: inout UNMutableNotificationContent,
        isForWatchDisplay: Bool
    ) {
        if #available(iOS 15.0, *) {
            if isForWatchDisplay {
                content.interruptionLevel = .active
                content.relevanceScore = 0.7
                print("📱 [WATCH] Using active interruption level for Watch display")
            } else {
                content.interruptionLevel = .timeSensitive
                content.relevanceScore = 1.0
                print("📱 [LOCKSCREEN] Using timeSensitive for DnD bypass (visual only)")
                print("   - Notification will SHOW even in DnD/Focus mode")
                print("   - Notification SOUND respects mute switch")
                print("   - Mute bypass handled by AVAudioPlayer (BackgroundAudioManager)")
            }
        }
    }

    // MARK: - Notification Sending Helpers

    /// Sends an immediate notification (trigger: nil for instant delivery)
    /// - Parameters:
    ///   - content: Configured notification content
    ///   - fallbackSoundName: Sound to play via AVAudioPlayer if notification fails
    /// - Note: Falls back to AVAudioPlayer on notification error (with [weak self] to prevent retain cycles)
    private func sendImmediateNotification(
        content: UNMutableNotificationContent,
        fallbackSoundName: String = "sound"
    ) {
        let center = UNUserNotificationCenter.current()
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil  // nil trigger = immediate delivery
        )

        center.add(request) { [weak self] error in
            if let error = error {
                print("❌ Failed to send immediate notification: \(error)")
                print("🔊 [BACKUP] Notification failed - using AVAudioPlayer as fallback")
                TimerSoundFix.shared.playTimerCompletionSound(preferredSound: fallbackSoundName)
            } else {
                print("✅ Immediate notification sent with sound: \(content.sound?.debugDescription ?? "none")")
                print("   - trigger: nil ensures delivery")
                print("   - Backup AVAudioPlayer NOT needed (notification handles audio)")
            }
        }
    }

    // MARK: - Diagnostic Helpers

    /// Verifies sound file exists in bundle and logs diagnostic info
    /// - Parameter soundName: Name of sound file (with or without .caf extension)
    /// - Returns: True if sound file exists and is valid
    private func verifyAndLogSoundFile(_ soundName: String) -> Bool {
        let soundFileName = soundName.hasSuffix(".caf") ? soundName : "\(soundName).caf"
        let soundFileBase = soundName.replacingOccurrences(of: ".caf", with: "")

        if let path = Bundle.main.path(forResource: soundFileBase, ofType: "caf") {
            print("✅ Sound file FOUND: \(path)")
            if let attrs = try? FileManager.default.attributesOfItem(atPath: path),
               let size = attrs[.size] as? Int64 {
                print("   - File size: \(size) bytes")
            }
            return true
        } else {
            print("❌ Sound file NOT FOUND: \(soundFileName)")
            print("   - Searching for: \(soundFileBase).caf")
            return false
        }
    }

    /// Logs comprehensive diagnostics for notification sending (async — no deadlock risk)
    private func logNotificationDiagnostics(
        title: String,
        body: String,
        soundName: String
    ) {
        let isBackground = AudioSessionManager.shared.isAppInBackground
        print("🔔 ============================================")
        print("🔔 IMMEDIATE TIMER NOTIFICATION - DIAGNOSTIC")
        print("🔔 ============================================")
        print("   Title: \(title)")
        print("   Body: \(body)")
        print("   Sound: \(soundName)")
        print("   App State: \(isBackground ? "BACKGROUND/INACTIVE" : "ACTIVE")")

        // Async settings check — avoids DispatchQueue.main.sync deadlock
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            print("📊 NOTIFICATION SETTINGS:")
            print("   - Authorization: \(settings.authorizationStatus.rawValue) (\(authStatusString(settings.authorizationStatus)))")
            print("   - Sound Setting: \(settings.soundSetting.rawValue) (\(settings.soundSetting == .enabled ? "✅ ENABLED" : "❌ DISABLED"))")
            print("   - Alert Setting: \(settings.alertSetting.rawValue) (\(settings.alertSetting == .enabled ? "✅ ENABLED" : "❌ DISABLED"))")

            if #available(iOS 15.0, *) {
                print("   - Time Sensitive: \(settings.timeSensitiveSetting.rawValue) (\(settings.timeSensitiveSetting == .enabled ? "✅ ENABLED" : "❌ DISABLED"))")
            }
        }

        let session = AVAudioSession.sharedInstance()
        print("📊 AUDIO STATUS:")
        print("   - Output Volume: \(session.outputVolume) (\(session.outputVolume > 0.1 ? "✅ OK" : "⚠️ LOW"))")
        print("   - Audio Route: \(session.currentRoute.outputs.map { $0.portType.rawValue }.joined(separator: ", "))")

        _ = verifyAndLogSoundFile(soundName)
    }

    // MARK: - Helper Functions

    /// Convert authorization status to readable string
    private func authStatusString(_ status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "NOT_DETERMINED"
        case .denied: return "❌ DENIED"
        case .authorized: return "✅ AUTHORIZED"
        case .provisional: return "PROVISIONAL"
        case .ephemeral: return "EPHEMERAL"
        @unknown default: return "UNKNOWN"
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
            let soundName = scheduled?.soundName ?? "sound"

            // ✅ AUDIO-MUTEX: Check if BackgroundAudioManager already played sound recently.
            // This prevents double-sound when both the dispatch timer (playCompletionSound)
            // and the backup notification fire close together in foreground.
            let audioAlreadyPlayed = BackgroundAudioManager.shared.wasAudioPlayedRecently(withinSeconds: 3.0)

            if audioAlreadyPlayed {
                print("   🔇 [AUDIO-MUTEX] Audio already played by BackgroundAudioManager — suppressing notification sound")
                // Still show banner but NO sound (audio already handled)
                completionHandler([.banner, .list, .badge])
            } else {
                // Backup notification arrived but primary audio didn't play —
                // this is the fallback path (e.g., app just came to foreground)
                print("   🔊 [AUDIO-MUTEX] No recent audio — playing notification sound as fallback")

                // 1. Vibrate
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                print("   📳 Vibration triggered")

                // 2. Play sound via AVAudioPlayer
                playNotificationAudio(soundName: soundName)

                // Notify Flutter that audio is being played via iOS notification
                FlutterChannelRegistry.shared.unified?.invokeMethod("timerAudioPlayedByiOS", arguments: [
                    "timestamp": Date().timeIntervalSince1970,
                    "source": "notification"
                ])

                // Do NOT pass .sound — playNotificationAudio() handles audio.
                completionHandler([.banner, .list, .badge])
            }
            print("   📱 Timer notification presented in foreground")

            // AUTO-DISMISS: Remove notification after 60 seconds
            scheduleNotificationRemoval(identifier: identifier, afterSeconds: 60)
            print("   ⏱️ Auto-dismiss scheduled in 60 seconds")
        } else {
            completionHandler([.banner, .list, .sound])
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
    // ✅ AUDIO-FIX: Play sound via AVAudioPlayer with proper lifecycle management.
    // Uses activePlayers array instead of objc_setAssociatedObject to prevent
    // ARC from killing a player while it's still playing.
    private func playNotificationAudio(soundName: String) {
        // Configure audio session synchronously BEFORE creating player
        do {
            let session = AVAudioSession.sharedInstance()
            if session.category != .playback || !session.categoryOptions.contains(.mixWithOthers) {
                try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            }
            try session.setActive(true, options: [])
        } catch {
            print("   ⚠️ Audio session config failed: \(error) — attempting playback anyway")
        }

        for ext in ["caf", "wav"] {
            if let soundURL = Bundle.main.url(forResource: soundName, withExtension: ext) {
                do {
                    let player = try AVAudioPlayer(contentsOf: soundURL)
                    player.volume = 1.0
                    player.prepareToPlay()
                    if player.play() {
                        // Keep player alive in array (not objc_setAssociatedObject)
                        activePlayers.append(player)
                        print("   🔊 Sound playing via AVAudioPlayer: \(soundName).\(ext)")

                        // Cleanup finished players after this one completes
                        let duration = player.duration
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.5) { [weak self] in
                            self?.activePlayers.removeAll { !$0.isPlaying }
                        }
                        return
                    }
                } catch {
                    print("   ❌ Failed to play sound: \(error)")
                }
            }
        }
        print("   ⚠️ Sound file not found: \(soundName)")
    }

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

