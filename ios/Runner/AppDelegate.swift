import Flutter
import UIKit
import AVFoundation
import BackgroundTasks
import UserNotifications
import FirebaseCore
// import workmanager // Not needed - using flutter_background_service instead

/// Refactored AppDelegate using modular manager pattern
/// Traditional lifecycle (without UIScene)
@main
@objc class AppDelegate: FlutterAppDelegate {

    // MARK: - Properties

    private var backgroundTaskManager: BackgroundTaskManaging {
        if #available(iOS 13.0, *) {
            return BackgroundTaskManager.shared
        } else {
            return BackgroundTaskManagerLegacy.shared
        }
    }

    // MARK: - Application Lifecycle

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure network before Firebase to avoid IPv6 issues
        NetworkConfiguration.shared
        NetworkConfiguration.preferIPv4ForFirebase()

        // Call super FIRST to set up Flutter engine (traditional lifecycle)
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Firebase initialization is handled by Flutter's firebase_core plugin
        // via Firebase.initializeApp() in main.dart - don't call FirebaseApp.configure() here
        Logger.shared.log(.info, "✅ Flutter engine initialized", category: .general)

        // Setup Flutter integration (channels, plugins)
        setupFlutterIntegration()

        // Initialize managers based on feature flags (non-Flutter related)
        initializeManagers()

        // Setup keyboard monitoring to prevent warnings
        KeyboardManager.shared.setupKeyboardMonitoring()

        // Setup notification categories BEFORE checking permissions
        setupNotificationCategories()

        // Set notification delegate for foreground notifications
        UNUserNotificationCenter.current().delegate = self

        // Check permissions
        PermissionManager.shared.checkAllPermissions()

        // CRITICAL: Ensure notification permissions for timer audio
        ensureNotificationPermissions()

        return result
    }

    // MARK: - Background/Foreground Transitions
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        super.applicationDidEnterBackground(application)
        
        Logger.shared.log(.info, "App entering background", category: .general)
        
        if FeatureFlags.useNewAudioManager {
            AudioSessionManager.shared.transitionToBackground()
        } else {
            // Legacy implementation
            legacyConfigureBackgroundAudio()
        }
        
        if FeatureFlags.useNewBackgroundTaskManager {
            backgroundTaskManager.scheduleAppRefresh()
            backgroundTaskManager.scheduleProcessingTask()
        } else {
            // Legacy implementation
            legacyScheduleBackgroundTasks()
        }
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        super.applicationWillEnterForeground(application)
        
        Logger.shared.log(.info, "App entering foreground", category: .general)
        
        if FeatureFlags.useNewAudioManager {
            AudioSessionManager.shared.transitionToForeground()
        } else {
            // Legacy implementation
            legacyConfigureForegroundAudio()
        }
        
        if FeatureFlags.useNewBackgroundTaskManager {
            backgroundTaskManager.cancelAllTasks()
        }
    }
    
    private var lastActiveTime: Date?

    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)

        // Prevent duplicate active events within 1 second
        let now = Date()
        if let lastTime = lastActiveTime, now.timeIntervalSince(lastTime) < 1.0 {
            return // Skip duplicate event
        }
        lastActiveTime = now

        Logger.shared.log(.info, "App became active", category: .general)

        if FeatureFlags.useNewAudioManager {
            AudioSessionManager.shared.reactivate()
        } else {
            // Legacy: Reactivate audio session for timer sounds
            legacyReactivateAudioSession()
        }

        // AUTO-DISMISS: Clean up timer notifications older than 60 seconds
        DirectNotificationManager.shared.cleanupOldTimerNotifications(olderThanSeconds: 60)
    }
    
    // MARK: - Notification Categories Setup
    
    private func setupNotificationCategories() {
        // Register ALL timer notification categories used by Flutter
        let timerCompleteCategory = UNNotificationCategory(
            identifier: "TIMER_COMPLETE",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction, .allowInCarPlay, .hiddenPreviewsShowTitle]
        )
        
        // Category for background notifications (used by notification_service.dart)
        let timerBackgroundCategory = UNNotificationCategory(
            identifier: "TIMER_COMPLETE_BACKGROUND",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction, .allowInCarPlay, .hiddenPreviewsShowTitle]
        )
        
        // Category for foreground notifications (used by notification_service.dart)
        let timerForegroundCategory = UNNotificationCategory(
            identifier: "TIMER_COMPLETE_FOREGROUND",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction, .allowInCarPlay, .hiddenPreviewsShowTitle]
        )
        
        // Category for fallback notifications
        let timerFallbackCategory = UNNotificationCategory(
            identifier: "TIMER_COMPLETE_FALLBACK",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction, .allowInCarPlay, .hiddenPreviewsShowTitle]
        )
        
        // Register ALL categories
        UNUserNotificationCenter.current().setNotificationCategories([
            timerCompleteCategory,
            timerBackgroundCategory,
            timerForegroundCategory,
            timerFallbackCategory
        ])
        
        Logger.shared.log(.info, "✅ All notification categories registered: TIMER_COMPLETE, TIMER_COMPLETE_BACKGROUND, TIMER_COMPLETE_FOREGROUND, TIMER_COMPLETE_FALLBACK", category: .general)
    }
    
    private func ensureNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                Logger.shared.log(.info, "✅ Notifications authorized", category: .permission)
                self.logNotificationPermissionDetails(settings)
                
            case .denied:
                Logger.shared.log(.error, "❌ Notifications denied - timer audio won't work!", category: .permission)
                
            case .notDetermined:
                Logger.shared.log(.info, "📱 Requesting notification permissions...", category: .permission)
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        Logger.shared.log(.info, "✅ Notification permissions granted", category: .permission)
                    } else {
                        Logger.shared.log(.error, "❌ Notification permissions denied: \(error?.localizedDescription ?? "Unknown")", category: .permission)
                    }
                }
                
            case .provisional:
                Logger.shared.log(.warning, "⚠️ Provisional notifications - requesting full permissions", category: .permission)
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    Logger.shared.log(.info, "Full permissions result: \(granted)", category: .permission)
                }
                
            case .ephemeral:
                Logger.shared.log(.warning, "⚠️ Ephemeral notifications - limited functionality", category: .permission)
                
            @unknown default:
                Logger.shared.log(.warning, "⚠️ Unknown notification status", category: .permission)
            }
        }
    }
    
    private func logNotificationPermissionDetails(_ settings: UNNotificationSettings) {
        Logger.shared.log(.debug, """
            📱 Notification Permission Details:
            - Sound Enabled: \(settings.soundSetting == .enabled ? "✅" : "❌")
            - Alert Enabled: \(settings.alertSetting == .enabled ? "✅" : "❌")
            - Badge Enabled: \(settings.badgeSetting == .enabled ? "✅" : "❌")
            - Notification Center: \(settings.notificationCenterSetting == .enabled ? "✅" : "❌")
            - Lock Screen: \(settings.lockScreenSetting == .enabled ? "✅" : "❌")
            - Alert Style: \(settings.alertStyle.rawValue)
            """, category: .permission)
        
        if settings.soundSetting != .enabled {
            Logger.shared.log(.error, "🔇 SOUND DISABLED - Timer audio won't play!", category: .permission)
        }
    }
    
    // MARK: - Private Methods - Initialization
    
    private func initializeManagers() {
        // Configure logging
        if FeatureFlags.useEnhancedLogging {
            Logger.shared.configure(
                minimumLevel: .debug,
                consoleLogging: true,
                fileLogging: false
            )
        }
        
        // Initialize audio session
        if FeatureFlags.useNewAudioManager {
            AudioSessionManager.shared.configureForLaunch()
        } else {
            legacySetupAudioSession()
        }
        
        // Register background tasks
        if FeatureFlags.useNewBackgroundTaskManager {
            backgroundTaskManager.registerTasks()
        } else {
            legacyRegisterBackgroundTasks()
        }
        
        Logger.shared.log(.info, "Managers initialized with feature flags")
        
        // Log feature flag status in debug
        #if DEBUG
        print(FeatureFlags.shared.getDebugInfo())
        #endif
    }
    
    private func setupFlutterIntegration() {
        // Use window.rootViewController (traditional lifecycle without UIScene)
        guard let controller = window?.rootViewController as? FlutterViewController else {
            Logger.shared.log(.error, "❌ FlutterViewController not available for Flutter integration", category: .general)
            return
        }
        let messenger = controller.binaryMessenger

        // Register plugins explicitly
        GeneratedPluginRegistrant.register(with: self)

        // UnifiedTimerCoordinator now coordinates ALL timer operations
        UnifiedTimerCoordinator.shared.setupChannel(with: messenger)

        // Setup feature flag channel for Flutter
        setupFeatureFlagChannel(with: messenger)

        // Setup notification channel for custom sounds
        setupNotificationChannel(with: messenger)

        // Setup notification delegate
        NotificationDelegate.shared.setupWithMessenger(messenger)

        // Setup HealthKit Activity channel for Activity Rings with real goals
        if #available(iOS 9.3, *) {
            HealthKitActivityManager.shared.setupChannel(with: messenger)
        }

        // Setup WatchConnectivity for Apple Watch companion app
        WatchConnectivityManager.shared.setupChannel(with: messenger)

        Logger.shared.log(.info, "✅ Flutter integration setup completed", category: .general)
    }

    private func setupFeatureFlagChannel(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.gymbro.feature_flags",
            binaryMessenger: messenger
        )
        
        channel.setMethodCallHandler { (call, result) in
            switch call.method {
            case "getFeatureFlags":
                result(FeatureFlags.shared.getAllFlags())
                
            case "setFeatureFlag":
                if let args = call.arguments as? [String: Any],
                   let flagKey = args["key"] as? String,
                   let enabled = args["enabled"] as? Bool {
                    FeatureFlags.shared.setOverride(enabled, for: flagKey)
                    result(true)
                } else {
                    result(FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing key or enabled parameter",
                        details: nil
                    ))
                }
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func setupNotificationChannel(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.gymbro/notifications",
            binaryMessenger: messenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "sendNotification":
                if let args = call.arguments as? [String: Any],
                   let title = args["title"] as? String,
                   let body = args["body"] as? String {
                    
                    let soundName = args["sound"] as? String ?? "sound"
                    let categoryIdentifier = args["categoryIdentifier"] as? String ?? "TIMER_COMPLETE"
                    let isBackground = args["isBackground"] as? Bool ?? false
                    
                    Logger.shared.log(.info, "📱 Native notification requested: \(title), sound: \(soundName)", category: .general)
                    
                    // Use DirectNotificationManager for immediate notifications with custom sounds
                    DirectNotificationManager.shared.sendTimerNotification(
                        title: title,
                        body: body,
                        soundName: soundName,
                        categoryIdentifier: categoryIdentifier,
                        delay: 0  // Immediate
                    )
                    
                    result(nil)
                } else {
                    result(FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing title or body",
                        details: nil
                    ))
                }
                
            case "testLockscreenAudio":
                // Run the lockscreen audio test
                LockscreenAudioTest.runTestFromFlutter()
                result(true)
                
            case "scheduleNotification":
                if let args = call.arguments as? [String: Any],
                   let title = args["title"] as? String,
                   let body = args["body"] as? String,
                   let delaySeconds = args["delaySeconds"] as? Int {
                    
                    let soundName = args["sound"] as? String ?? "sound"
                    let categoryIdentifier = args["categoryIdentifier"] as? String ?? "TIMER_COMPLETE"
                    let notificationId = args["notificationId"] as? Int ?? 100
                    
                    Logger.shared.log(.info, "⏰ Scheduled notification requested: \(title), delay: \(delaySeconds)s, sound: \(soundName)", category: .general)
                    
                    // Use DirectNotificationManager for scheduled notifications
                    DirectNotificationManager.shared.sendTimerNotification(
                        title: title,
                        body: body,
                        soundName: soundName,
                        categoryIdentifier: categoryIdentifier,
                        delay: TimeInterval(delaySeconds)
                    )
                    
                    result(nil)
                } else {
                    result(FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing required parameters",
                        details: nil
                    ))
                }
                
            case "cancelNotification":
                if let args = call.arguments as? [String: Any],
                   let notificationId = args["notificationId"] as? Int {
                    
                    Logger.shared.log(.info, "🚫 Cancel notification requested: ID \(notificationId)", category: .general)
                    
                    // Cancel pending notifications with this identifier
                    UNUserNotificationCenter.current().removePendingNotificationRequests(
                        withIdentifiers: [String(notificationId)]
                    )
                    
                    result(nil)
                } else {
                    result(FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing notificationId",
                        details: nil
                    ))
                }
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        Logger.shared.log(.info, "✅ Notification channel setup completed", category: .general)
    }
    
    // MARK: - Legacy Implementations (for gradual migration)
    
    private func legacySetupAudioSession() {
        // ✅ MINIMAL audio session - only .mixWithOthers to avoid OSStatus -50
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            Logger.shared.log(.info, "Audio session configured", category: .audioSession)
        } catch {
            Logger.shared.log(.error, "Audio session setup failed: \(error)", category: .audioSession)
        }
    }

    private func legacyConfigureBackgroundAudio() {
        // ✅ MINIMAL audio session - only .mixWithOthers
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            Logger.shared.log(.info, "Background audio configured", category: .audioSession)
        } catch {
            Logger.shared.log(.error, "Background audio configuration failed: \(error)", category: .audioSession)
        }
    }

    private func legacyConfigureForegroundAudio() {
        // ✅ MINIMAL audio session - only .mixWithOthers
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            Logger.shared.log(.info, "Foreground audio configured", category: .audioSession)
        } catch {
            Logger.shared.log(.error, "Foreground audio configuration failed: \(error)", category: .audioSession)
        }
    }

    private func legacyReactivateAudioSession() {
        // ✅ MINIMAL audio session - only .mixWithOthers
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            Logger.shared.log(.info, "Legacy audio session reactivated", category: .audioSession)
        } catch {
            Logger.shared.log(.error, "Legacy audio reactivation failed: \(error)", category: .audioSession)
        }
    }

    private func legacyRegisterBackgroundTasks() {
        // Modern background task registration
        if #available(iOS 13.0, *) {
            // Register com.gymbro.timer.refresh
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: "com.gymbro.timer.refresh",
                using: nil
            ) { task in
                Logger.shared.log(.debug, "Background task executed: com.gymbro.timer.refresh", category: .backgroundTask)
                task.setTaskCompleted(success: true)
            }

            // Register dev.flutter.background.refresh (required by flutter_background_service)
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: "dev.flutter.background.refresh",
                using: nil
            ) { task in
                Logger.shared.log(.debug, "Background task executed: dev.flutter.background.refresh", category: .backgroundTask)
                task.setTaskCompleted(success: true)
            }
            Logger.shared.log(.info, "Background tasks registered", category: .backgroundTask)
        }
    }

    private func legacyScheduleBackgroundTasks() {
        // Modern background task scheduling
        if #available(iOS 13.0, *) {
            // Check if background refresh is available first
            let status = UIApplication.shared.backgroundRefreshStatus
            guard status == .available else {
                if status == .denied {
                    Logger.shared.log(.warning, "Background App Refresh disabled by user", category: .backgroundTask)
                } else if status == .restricted {
                    Logger.shared.log(.warning, "Background App Refresh restricted", category: .backgroundTask)
                }
                return
            }

            // Schedule com.gymbro.timer.refresh
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "com.gymbro.timer.refresh")
            let gymbroRequest = BGAppRefreshTaskRequest(identifier: "com.gymbro.timer.refresh")
            gymbroRequest.earliestBeginDate = Date(timeIntervalSinceNow: 60)

            do {
                try BGTaskScheduler.shared.submit(gymbroRequest)
                Logger.shared.log(.debug, "Background task scheduled: com.gymbro.timer.refresh", category: .backgroundTask)
            } catch let error as NSError {
                switch error.code {
                case 1:
                    Logger.shared.log(.error, "Task identifier not in Info.plist", category: .backgroundTask)
                case 2:
                    Logger.shared.log(.warning, "Too many pending background tasks", category: .backgroundTask)
                case 3:
                    Logger.shared.log(.warning, "Background App Refresh unavailable", category: .backgroundTask)
                default:
                    Logger.shared.log(.error, "Background task scheduling failed: \(error)", category: .backgroundTask)
                }
            }

            // Schedule dev.flutter.background.refresh (for flutter_background_service)
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "dev.flutter.background.refresh")
            let flutterRequest = BGAppRefreshTaskRequest(identifier: "dev.flutter.background.refresh")
            flutterRequest.earliestBeginDate = Date(timeIntervalSinceNow: 60)

            do {
                try BGTaskScheduler.shared.submit(flutterRequest)
                Logger.shared.log(.debug, "Background task scheduled: dev.flutter.background.refresh", category: .backgroundTask)
            } catch let error as NSError {
                switch error.code {
                case 1, 2, 3:
                    break // Already logged above
                default:
                    Logger.shared.log(.error, "Background task scheduling failed: \(error)", category: .backgroundTask)
                }
            }
        }
    }
    
    // MARK: - Debug & Monitoring
    
    #if DEBUG
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Shake to show debug menu
            showDebugMenu()
        }
    }
    
    private func showDebugMenu() {
        guard let rootViewController = window?.rootViewController else { return }
        
        let alert = UIAlertController(
            title: "Debug Menu",
            message: FeatureFlags.shared.getDebugInfo(),
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Toggle Audio Manager", style: .default) { _ in
            let current = FeatureFlags.useNewAudioManager
            FeatureFlags.shared.setOverride(!current, for: "com.gymbro.feature.newAudioManager")
        })
        
        alert.addAction(UIAlertAction(title: "Toggle Background Manager", style: .default) { _ in
            let current = FeatureFlags.useNewBackgroundTaskManager
            FeatureFlags.shared.setOverride(!current, for: "com.gymbro.feature.newBackgroundTaskManager")
        })
        
        alert.addAction(UIAlertAction(title: "Toggle Optimized Timer", style: .default) { _ in
            let current = FeatureFlags.useOptimizedTimer
            FeatureFlags.shared.setOverride(!current, for: "com.gymbro.feature.optimizedTimer")
            Logger.shared.log(.info, "Optimized Timer toggled to: \(!current)")
        })
        
        alert.addAction(UIAlertAction(title: "Show Metrics", style: .default) { _ in
            self.showMetrics()
        })
        
        alert.addAction(UIAlertAction(title: "Silent Loop Debug", style: .default) { _ in
            self.showSilentLoopDebug()
        })
        
        alert.addAction(UIAlertAction(title: "Export Logs", style: .default) { _ in
            if let logURL = Logger.shared.exportLogs() {
                let activityVC = UIActivityViewController(
                    activityItems: [logURL],
                    applicationActivities: nil
                )
                rootViewController.present(activityVC, animated: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        rootViewController.present(alert, animated: true)
    }
    
    private func showMetrics() {
        let metrics = """
        === System Metrics ===
        
        Audio Session:
        \(AudioSessionManager.shared.validateConfiguration() ? "✅ Valid" : "❌ Invalid")
        
        Background Tasks:
        \(backgroundTaskManager.getHealthMetrics())
        
        Permissions:
        \(PermissionManager.shared.getPermissionMetrics())
        
        Errors:
        \(ErrorRecoveryManager.shared.getErrorMetrics())
        
        Logging:
        \(Logger.shared.getMetrics())
        """
        
        guard let rootViewController = window?.rootViewController else { return }
        
        let alert = UIAlertController(
            title: "System Metrics",
            message: metrics,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        rootViewController.present(alert, animated: true)
    }
    
    private func showSilentLoopDebug() {
        let silentLoopStatus = BackgroundAudioManager.shared.getDebugStatus()
        let audioSessionValid = AudioSessionManager.shared.validateConfiguration()
        
        let debugInfo = """
        === Silent Audio Loop Debug ===
        
        Silent Loop Active: \(silentLoopStatus["silentLoopActive"] ?? false)
        Battery Level: \(String(format: "%.0f%%", (silentLoopStatus["batteryLevel"] as? Double ?? 0) * 100))
        Battery State: \(silentLoopStatus["batteryState"] ?? "Unknown")
        Silent Loop Runtime: \(silentLoopStatus["silentLoopRuntime"] ?? 0)s
        
        Audio Session: \(audioSessionValid ? "✅ Valid" : "❌ Invalid")
        
        Timer Work Item: \(silentLoopStatus["timerWorkItemActive"] ?? false)
        Scheduled Notification: \(silentLoopStatus["scheduledNotification"] ?? false)
        Background Task: \(silentLoopStatus["backgroundTaskActive"] ?? false)
        
        Recommended Max Duration: \(silentLoopStatus["recommendedMaxDuration"] ?? 0)s
        """
        
        guard let rootViewController = window?.rootViewController else { return }
        
        let alert = UIAlertController(
            title: "Silent Loop Debug",
            message: debugInfo,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Test Silent Loop", style: .default) { _ in
            BackgroundAudioManager.shared.scheduleTimerAudio(duration: 60, soundName: "sound")
            Logger.shared.log(.info, "DEBUG: Started 60s test silent loop")
        })
        
        alert.addAction(UIAlertAction(title: "Stop Silent Loop", style: .destructive) { _ in
            BackgroundAudioManager.shared.cancelScheduledAudio()
            Logger.shared.log(.info, "DEBUG: Stopped silent loop")
        })
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        
        rootViewController.present(alert, animated: true)
    }
    #endif
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate {

    // Handle notifications when app is in foreground
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let categoryIdentifier = notification.request.content.categoryIdentifier
        
        if categoryIdentifier == "TIMER_COMPLETE" {
            // Timer completion - show banner and play sound even in foreground
            Logger.shared.log(.info, "⏰ Timer completion notification received in foreground", category: .general)

            // CRITICAL FIX: Notify Flutter that audio has been played via iOS notification
            if let controller = window?.rootViewController as? FlutterViewController {
                let unifiedChannel = FlutterMethodChannel(name: "com.gymbro.timer/unified",
                                                         binaryMessenger: controller.binaryMessenger)
                unifiedChannel.invokeMethod("timerAudioPlayedByiOS", arguments: [
                    "timestamp": Date().timeIntervalSince1970,
                    "source": "notification"
                ])
                Logger.shared.log(.info, "✅ Notified Flutter that audio was played by iOS notification", category: .general)
            } else {
                Logger.shared.log(.warning, "⚠️ Could not notify Flutter - no FlutterViewController available", category: .general)
            }

            completionHandler([.banner, .sound, .badge])
        } else {
            // Other notifications
            completionHandler([.banner, .sound])
        }
    }

    // Handle notification tap actions
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        if categoryIdentifier == "TIMER_COMPLETE" {
            Logger.shared.log(.info, "⏰ Timer notification tapped by user", category: .general)
            // Could navigate to workout screen or perform other actions
        }
        
        completionHandler()
    }
}
