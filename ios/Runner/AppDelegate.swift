import Flutter
import UIKit
import AVFoundation
import BackgroundTasks
import UserNotifications

/// Refactored AppDelegate using modular manager pattern
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
        GeneratedPluginRegistrant.register(with: self)
        
        // Initialize managers based on feature flags
        initializeManagers()
        
        // Setup Flutter integration
        setupFlutterIntegration()
        
        // Setup notification categories BEFORE checking permissions
        setupNotificationCategories()
        
        // Set notification delegate for foreground notifications
        UNUserNotificationCenter.current().delegate = self
        
        // Check permissions
        PermissionManager.shared.checkAllPermissions()
        
        // CRITICAL: Ensure notification permissions for timer audio
        ensureNotificationPermissions()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        
        Logger.shared.log(.info, "App became active", category: .general)
        
        if FeatureFlags.useNewAudioManager {
            AudioSessionManager.shared.reactivate()
        }
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
        guard let controller = window?.rootViewController as? FlutterViewController else {
            Logger.shared.log(.error, "Failed to get FlutterViewController")
            return
        }
        
        // Setup Optimized Timer Manager (Tier 1 optimization)
        OptimizedTimerManager.shared.setupFlutterChannel(with: controller.binaryMessenger)
        
        // Setup Background Audio Manager (fixes timer audio >15s)
        BackgroundAudioManager.shared.setupFlutterChannel(with: controller.binaryMessenger)
        
        // Setup Timer Bridge per intercettare richieste audio da Flutter
        TimerBridge.shared.setupChannel(with: controller.binaryMessenger)
        
        // Setup Timer Sound Fix for guaranteed audio playback
        TimerSoundFix.shared.setupFlutterChannel(with: controller.binaryMessenger)
        
        // Setup Live Activity handler (already modular)
        LiveActivityHandler.shared.setupMethodChannel(with: controller.binaryMessenger)
        
        // Setup feature flag channel for Flutter
        setupFeatureFlagChannel(with: controller.binaryMessenger)
        
        Logger.shared.log(.info, "Flutter integration setup completed")
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
    
    // MARK: - Legacy Implementations (for gradual migration)
    
    private func legacySetupAudioSession() {
        // Original audio session setup code (simplified)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
            try audioSession.setActive(true)
            print("Legacy audio session configured")
        } catch {
            print("Legacy audio session setup failed: \(error)")
        }
    }
    
    private func legacyConfigureBackgroundAudio() {
        // Original background audio configuration
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            print("Legacy background audio configured")
        } catch {
            print("Legacy background audio configuration failed: \(error)")
        }
    }
    
    private func legacyConfigureForegroundAudio() {
        // Original foreground audio configuration
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
            try audioSession.setActive(true)
            print("Legacy foreground audio configured")
        } catch {
            print("Legacy foreground audio configuration failed: \(error)")
        }
    }
    
    private func legacyRegisterBackgroundTasks() {
        // Original background task registration
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: "com.gymbro.timer.refresh",
                using: nil
            ) { task in
                print("Legacy background task executed")
                task.setTaskCompleted(success: true)
            }
        }
    }
    
    private func legacyScheduleBackgroundTasks() {
        // Original background task scheduling
        if #available(iOS 13.0, *) {
            let request = BGAppRefreshTaskRequest(identifier: "com.gymbro.timer.refresh")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
            
            do {
                try BGTaskScheduler.shared.submit(request)
                print("Legacy background task scheduled")
            } catch {
                print("Legacy background task scheduling failed: \(error)")
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
            BackgroundAudioManager.shared.scheduleTimerAudio(duration: 60, soundName: "timer_complete")
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