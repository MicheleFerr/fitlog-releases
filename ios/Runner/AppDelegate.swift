import Flutter
import UIKit
import UserNotifications
import FirebaseCore
// import workmanager // Not needed - using flutter_background_service instead

/// Refactored AppDelegate using modular manager pattern
/// Traditional lifecycle (without UIScene)
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    // MARK: - Properties

    private var backgroundTaskManager: BackgroundTaskManaging {
        return BackgroundTaskManager.shared
    }
    private var hasConfiguredFlutterIntegration = false

    // MARK: - Application Lifecycle

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure network before Firebase to avoid IPv6 issues
        _ = NetworkConfiguration.shared
        NetworkConfiguration.preferIPv4ForFirebase()

        // Configure Firebase as early as possible so any Firebase access triggered
        // during app/bootstrap sees an initialized default app.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // Call super to set up Flutter engine (traditional lifecycle)
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        Logger.shared.log(.info, "✅ Native launch initialized, Firebase configured", category: .general)

        // Initialize managers based on feature flags (non-Flutter related)
        initializeManagers()

        // Setup keyboard monitoring to prevent warnings
        KeyboardManager.shared.setupKeyboardMonitoring()

        // Setup notification categories BEFORE checking permissions
        setupNotificationCategories()
        logTimerDiagnostics(context: "didFinishLaunchingWithOptions")

        // Note: UNUserNotificationCenter delegate is set by DirectNotificationManager (sole delegate)

        // Check permissions
        PermissionManager.shared.checkAllPermissions()

        // Do not stack the notification prompt on top of ATT during first launch.
        // Notification permissions are requested later from the Flutter flow.

        if let launchURL = launchOptions?[.url] as? URL {
            _ = storePendingDeepLinkIfNeeded(from: launchURL)
        }

        return result
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        setupFlutterIntegration(with: engineBridge.applicationRegistrar.messenger())
        Logger.shared.log(.info, "✅ Flutter plugins registered via implicit engine", category: .general)
    }

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        let handledByDeepLink = storePendingDeepLinkIfNeeded(from: url)
        let handledBySuper = super.application(app, open: url, options: options)
        return handledByDeepLink || handledBySuper
    }

    // MARK: - Background/Foreground Transitions
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        super.applicationDidEnterBackground(application)
        
        Logger.shared.log(.info, "App entering background", category: .general)
        logTimerDiagnostics(context: "applicationDidEnterBackground")
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        super.applicationWillEnterForeground(application)
        
        Logger.shared.log(.info, "App entering foreground", category: .general)
        logTimerDiagnostics(context: "applicationWillEnterForeground")
        backgroundTaskManager.cancelAllTasks()
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
        logTimerDiagnostics(context: "applicationDidBecomeActive")

        // AUTO-DISMISS: Clean up timer notifications older than 60 seconds
        DirectNotificationManager.shared.cleanupOldTimerNotifications(olderThanSeconds: 60)
    }

    // MARK: - Memory Warning

    override func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        super.applicationDidReceiveMemoryWarning(application)

        Logger.shared.log(.warning, "⚠️ Memory warning received — notifying Flutter and clearing caches", category: .general)

        // Notify Flutter to emergency-save workout and shed memory.
        FlutterChannelRegistry.shared.unified?.invokeMethod("onMemoryWarning", arguments: nil)

        // Clear native image caches
        URLCache.shared.removeAllCachedResponses()
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        super.applicationWillTerminate(application)

        Logger.shared.log(.info, "App will terminate - attempting Live Activity cleanup", category: .general)
        logTimerDiagnostics(context: "applicationWillTerminate")
        cleanupLiveActivitiesForTermination()
    }

    // MARK: - Notification Categories Setup
    
    private func setupNotificationCategories() {
        let timerCompleteCategory = UNNotificationCategory(
            identifier: RestTimerNotificationSupport.categoryIdentifier,
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction, .allowInCarPlay, .hiddenPreviewsShowTitle]
        )

        let watchWorkoutRescueCategory = UNNotificationCategory(
            identifier: WatchConnectivityManager.watchWorkoutRescueCategory,
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction, .allowInCarPlay, .hiddenPreviewsShowTitle]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            timerCompleteCategory,
            watchWorkoutRescueCategory
        ])
        
        Logger.shared.log(.info, "✅ Notification categories registered", category: .general)
    }

    private func cleanupLiveActivitiesForTermination() {
        guard #available(iOS 16.1, *) else {
            return
        }

        let group = DispatchGroup()
        group.enter()

        Task {
            await LiveActivityHandler.shared.endAllActivitiesForAppTermination()
            group.leave()
        }

        // Best-effort wait only. iOS does not guarantee termination callbacks,
        // but this short window reduces the chance of leaving a stale activity.
        _ = group.wait(timeout: .now() + 1.0)
    }

    private func logTimerDiagnostics(context: String) {
        Logger.shared.log(
            .debug,
            "🍎 [APP LIFECYCLE TRACE] \(context)",
            category: .general
        )
        DirectNotificationManager.shared.logRestTimerNotificationState(context: "AppDelegate \(context)")
        TimerSoundFix.shared.logAudioSessionSnapshot(context: "AppDelegate \(context)")
    }

    @discardableResult
    func storePendingDeepLinkIfNeeded(from url: URL) -> Bool {
        guard let payload = payloadForIncomingURL(url) else {
            return false
        }

        DirectNotificationManager.shared.storePendingNotificationPayload(payload)
        Logger.shared.log(
            .info,
            "🔗 Stored pending deep link payload from URL: \(url.absoluteString)",
            category: .general
        )
        return true
    }

    private func payloadForIncomingURL(_ url: URL) -> String? {
        guard let scheme = url.scheme?.lowercased(),
              ["gymbro", "fitlog"].contains(scheme),
              let deepLinkPath = deepLinkPath(for: url) else {
            return nil
        }

        return "deeplink:url:\(deepLinkPath)"
    }

    private func deepLinkPath(for url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        let host = components.host?.lowercased() ?? ""
        let pathComponents = components.path.split(separator: "/").map(String.init)
        let routeComponents = ([host] + pathComponents).filter { !$0.isEmpty }

        let routePath: String
        switch host {
        case "schedule":
            guard let templateId = pathComponents.first, !templateId.isEmpty else {
                return nil
            }
            routePath = "/workout/start/\(templateId)"
        case "workout":
            if pathComponents.first == "start", pathComponents.count >= 2 {
                routePath = "/workout/start/\(pathComponents[1])"
            } else {
                routePath = "/workout"
            }
        case "timer", "rpe":
            routePath = "/workout"
        case "open":
            routePath = "/"
        default:
            if routeComponents.count >= 3 &&
                routeComponents[0] == "workout" &&
                routeComponents[1] == "start" {
                routePath = "/workout/start/\(routeComponents[2])"
            } else if routeComponents.count >= 2 && routeComponents[0] == "schedule" {
                routePath = "/workout/start/\(routeComponents[1])"
            } else if routeComponents.first == "workout" ||
                routeComponents.first == "timer" ||
                routeComponents.first == "rpe" {
                routePath = "/workout"
            } else if routeComponents.first == "open" {
                routePath = "/"
            } else {
                return nil
            }
        }

        var queryItems = components.queryItems ?? []
        if !queryItems.contains(where: { $0.name == "source" }) {
            queryItems.append(URLQueryItem(name: "source", value: "live_activity"))
        }

        var deepLinkComponents = URLComponents()
        deepLinkComponents.path = routePath
        deepLinkComponents.queryItems = queryItems.isEmpty ? nil : queryItems
        return deepLinkComponents.string
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

        backgroundTaskManager.registerTasks()

        // Initialize MetronomeManager for TUT metronome
        _ = MetronomeManager.shared

        Logger.shared.log(.info, "Managers initialized with feature flags")
        
        // Log feature flag status in debug
        #if DEBUG
        print(FeatureFlags.shared.getDebugInfo())
        #endif
    }
    
    private func setupFlutterIntegration(with messenger: FlutterBinaryMessenger) {
        guard !hasConfiguredFlutterIntegration else {
            Logger.shared.log(.debug, "Flutter integration already configured", category: .general)
            return
        }
        hasConfiguredFlutterIntegration = true

        // Register the application-level messenger so native managers can
        // attach channels without relying on UIApplicationDelegate.window.
        FlutterChannelRegistry.shared.setup(with: messenger)

        // UnifiedTimerCoordinator now coordinates ALL timer operations
        UnifiedTimerCoordinator.shared.setupChannel(with: messenger)

        // Setup feature flag channel for Flutter
        setupFeatureFlagChannel(with: messenger)

        // Setup notification channel for custom sounds
        setupNotificationChannel(with: messenger)

        // Setup ATT channel for requesting tracking authorization before ads init
        setupTrackingAuthorizationChannel(with: messenger)

        // Setup app icon channel for default/pink icon switching (iOS only)
        setupAppIconChannel(with: messenger)

        // Setup HealthKit Activity channel for Activity Rings with real goals
        if #available(iOS 9.3, *) {
            HealthKitActivityManager.shared.setupChannel(with: messenger)
        }

        // Setup WatchConnectivity for Apple Watch companion app
        WatchConnectivityManager.shared.setupChannel(with: messenger)

        #if DEBUG
        // Setup AudioDebugTestHandler for timer audio debug tests
        AudioDebugTestHandler.shared.setup(binaryMessenger: messenger)
        #endif

        // Setup TimerSoundFix channel for sound preview in settings
        TimerSoundFix.shared.setupFlutterChannel(with: messenger)

        // Setup WorkoutSession Live Activity manager (iOS 17+)
        if #available(iOS 17.0, *) {
            WorkoutSessionManager.shared.setupMethodChannel(with: messenger)
        } else {
            WorkoutSessionManagerFallback.shared.setupMethodChannel(with: messenger)
        }

        Logger.shared.log(.info, "✅ Flutter integration setup completed", category: .general)
    }

    private func setupFeatureFlagChannel(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: ChannelNames.featureFlags,
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
            name: ChannelNames.notifications,
            binaryMessenger: messenger
        )
        
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "sendNotification":
                if let args = call.arguments as? [String: Any],
                   let title = args["title"] as? String,
                   let body = args["body"] as? String {
                    
                    let soundName = args["sound"] as? String ?? "sound"
                    let categoryIdentifier = args["categoryIdentifier"] as? String ?? RestTimerNotificationSupport.categoryIdentifier
                    let playSound = args["playSound"] as? Bool ?? true
                    
                    Logger.shared.log(.info, "📱 Native notification requested: \(title), sound: \(soundName)", category: .general)
                    
                    // Use DirectNotificationManager for immediate notifications with custom sounds
                    DirectNotificationManager.shared.sendTimerNotification(
                        title: title,
                        body: body,
                        soundName: soundName,
                        categoryIdentifier: categoryIdentifier,
                        delay: 0,  // Immediate
                        playSound: playSound
                    )
                    
                    result(nil)
                } else {
                    result(FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing title or body",
                        details: nil
                    ))
                }
                
            case "scheduleNotification":
                if let args = call.arguments as? [String: Any],
                   let title = args["title"] as? String,
                   let body = args["body"] as? String,
                   let delaySeconds = args["delaySeconds"] as? Int {
                    
                    let soundName = args["sound"] as? String ?? "sound"
                    let categoryIdentifier = args["categoryIdentifier"] as? String ?? RestTimerNotificationSupport.categoryIdentifier
                    
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

    private func setupTrackingAuthorizationChannel(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: ChannelNames.trackingAuthorization,
            binaryMessenger: messenger
        )

        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "getStatus":
                result(AdSupportManager.shared.trackingAuthorizationStatus.rawValue)

            case "requestAuthorization":
                AdSupportManager.shared.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        result(status.rawValue)
                    }
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        Logger.shared.log(
            .info,
            "✅ Tracking authorization channel setup completed",
            category: .general
        )
    }

    private func setupAppIconChannel(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: ChannelNames.appIcon,
            binaryMessenger: messenger
        )

        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "isSupported":
                if #available(iOS 10.3, *) {
                    result(UIApplication.shared.supportsAlternateIcons)
                } else {
                    result(false)
                }

            case "getCurrentIcon":
                if #available(iOS 10.3, *) {
                    result(UIApplication.shared.alternateIconName ?? "default")
                } else {
                    result("default")
                }

            case "setIcon":
                guard #available(iOS 10.3, *) else {
                    result(FlutterError(
                        code: "UNSUPPORTED_IOS_VERSION",
                        message: "Alternate app icons require iOS 10.3 or later",
                        details: nil
                    ))
                    return
                }

                guard UIApplication.shared.supportsAlternateIcons else {
                    result(FlutterError(
                        code: "UNSUPPORTED_DEVICE",
                        message: "Alternate app icons are not supported on this device",
                        details: nil
                    ))
                    return
                }

                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing arguments",
                        details: nil
                    ))
                    return
                }

                let iconNameArg = (args["iconName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                let normalizedIconName: String? = {
                    guard let iconNameArg, !iconNameArg.isEmpty, iconNameArg != "default" else {
                        return nil
                    }
                    return iconNameArg
                }()

                DispatchQueue.main.async {
                    UIApplication.shared.setAlternateIconName(normalizedIconName) { error in
                        if let error {
                            result(FlutterError(
                                code: "SET_ICON_FAILED",
                                message: error.localizedDescription,
                                details: nil
                            ))
                        } else {
                            result(true)
                        }
                    }
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        Logger.shared.log(.info, "✅ App icon channel setup completed", category: .general)
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
        
        alert.addAction(UIAlertAction(title: "Toggle Background Manager", style: .default) { _ in
            let current = FeatureFlags.useNewBackgroundTaskManager
            FeatureFlags.shared.setOverride(!current, for: "com.gymbro.feature.newBackgroundTaskManager")
        })
        
        alert.addAction(UIAlertAction(title: "Show Metrics", style: .default) { _ in
            self.showMetrics()
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
        
        Background Tasks:
        \(BackgroundTaskManager.shared.getHealthMetrics())
        
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
    #endif
}

// MARK: - UNUserNotificationCenterDelegate
// ✅ AUDIO-FIX: REMOVED willPresent and didReceive overrides from AppDelegate.
// DirectNotificationManager is the SOLE delegate for UNUserNotificationCenter.
// Having two classes implement willPresent caused non-deterministic delegate
// conflicts (P0-2 from IOS_FLUTTER_AUDIT_2026.md). All notification handling
// is now centralized in DirectNotificationManager.swift.
