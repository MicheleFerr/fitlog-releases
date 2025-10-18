import UIKit
import UserNotifications

/// Manages system permissions and user guidance
final class PermissionManager {
    
    // MARK: - Permission Status
    
    enum PermissionStatus {
        case authorized
        case denied
        case restricted
        case notDetermined
        case unknown
    }
    
    // MARK: - Properties
    
    static let shared = PermissionManager()
    
    private var hasShownBackgroundRefreshAlert = false
    private var hasShownNotificationAlert = false
    private let userDefaults = UserDefaults.standard
    
    // User defaults keys
    private enum UserDefaultsKey {
        static let hasShownBackgroundRefreshAlert = "com.gymbro.permission.backgroundRefreshAlertShown"
        static let hasShownNotificationAlert = "com.gymbro.permission.notificationAlertShown"
        static let lastPermissionCheckDate = "com.gymbro.permission.lastCheckDate"
    }
    
    // MARK: - Initialization
    
    private init() {
        loadPersistedState()
        Logger.shared.log(.info, "PermissionManager initialized", category: .permission)
    }
    
    // MARK: - Public Methods
    
    /// Check all critical permissions on app launch
    func checkAllPermissions() {
        checkBackgroundRefreshStatus()
        checkNotificationPermissions()
        checkLiveActivityPermissions()
        
        // Update last check date
        userDefaults.set(Date(), forKey: UserDefaultsKey.lastPermissionCheckDate)
    }
    
    /// Request background refresh permission guidance if needed
    func requestBackgroundRefreshIfNeeded() {
        let status = UIApplication.shared.backgroundRefreshStatus
        
        switch status {
        case .available:
            Logger.shared.log(.info, "✅ Background App Refresh available", category: .permission)
            
        case .denied:
            Logger.shared.log(.warning, "🚫 Background App Refresh denied by user", category: .permission)
            if !hasShownBackgroundRefreshAlert {
                showBackgroundRefreshAlert(
                    title: "Background Timer Disabled",
                    message: "Background App Refresh is disabled. Timers may not work correctly when the app is in background. Enable it in Settings for the best experience."
                )
                hasShownBackgroundRefreshAlert = true
                savePersistedState()
            }
            
        case .restricted:
            Logger.shared.log(.warning, "🔒 Background App Refresh restricted", category: .permission)
            showBackgroundRefreshAlert(
                title: "Background Timer Restricted",
                message: "Background App Refresh is restricted by device management. Contact your administrator."
            )
            
        @unknown default:
            Logger.shared.log(.warning, "❓ Unknown Background App Refresh status", category: .permission)
        }
    }
    
    /// Request notification permissions
    func requestNotificationPermissions(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { [weak self] granted, error in
            if let error = error {
                Logger.shared.log(
                    .error,
                    "Notification permission error: \(error.localizedDescription)",
                    category: .permission
                )
            }
            
            Logger.shared.log(
                granted ? .info : .warning,
                "Notification permission: \(granted ? "✅ Granted" : "❌ Denied")",
                category: .permission
            )
            
            if !granted && !(self?.hasShownNotificationAlert ?? false) {
                self?.showNotificationPermissionAlert()
                self?.hasShownNotificationAlert = true
                self?.savePersistedState()
            }
            
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    /// Get current status for a specific permission
    func getBackgroundRefreshStatus() -> PermissionStatus {
        switch UIApplication.shared.backgroundRefreshStatus {
        case .available:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .unknown
        }
    }
    
    func getNotificationStatus(completion: @escaping (PermissionStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: PermissionStatus
            
            switch settings.authorizationStatus {
            case .authorized:
                status = .authorized
            case .denied:
                status = .denied
            case .notDetermined:
                status = .notDetermined
            case .provisional:
                status = .authorized
            case .ephemeral:
                status = .authorized
            @unknown default:
                status = .unknown
            }
            
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func checkBackgroundRefreshStatus() {
        let status = getBackgroundRefreshStatus()
        
        Logger.shared.log(
            .info,
            "Background Refresh Status: \(statusDescription(status))",
            category: .permission
        )
        
        if status == .denied || status == .restricted {
            requestBackgroundRefreshIfNeeded()
        }
    }
    
    private func checkNotificationPermissions() {
        getNotificationStatus { [weak self] status in
            Logger.shared.log(
                .info,
                "Notification Status: \(self?.statusDescription(status) ?? "Unknown")",
                category: .permission
            )
            
            if status == .notDetermined {
                // Don't auto-request, wait for appropriate moment
                Logger.shared.log(.debug, "Notifications not yet requested", category: .permission)
            }
        }
    }
    
    private func checkLiveActivityPermissions() {
        if #available(iOS 16.1, *) {
            // Live Activities don't require explicit permission,
            // but we check if they're enabled in Settings
            Logger.shared.log(
                .info,
                "Live Activities available on iOS 16.1+",
                category: .permission
            )
        } else {
            Logger.shared.log(
                .info,
                "Live Activities not available (iOS < 16.1)",
                category: .permission
            )
        }
    }
    
    // MARK: - Alert Presentation
    
    private func showBackgroundRefreshAlert(title: String, message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                Logger.shared.log(.error, "No root view controller for alert", category: .permission)
                return
            }
            
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { [weak self] _ in
                self?.openAppSettings()
            })
            
            alert.addAction(UIAlertAction(title: "Later", style: .cancel) { _ in
                Logger.shared.log(.info, "User deferred background refresh setup", category: .permission)
            })
            
            rootViewController.present(alert, animated: true)
        }
    }
    
    private func showNotificationPermissionAlert() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                return
            }
            
            let alert = UIAlertController(
                title: "Enable Notifications",
                message: "Get notified when your rest timer ends. Enable notifications in Settings.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { [weak self] _ in
                self?.openAppSettings()
            })
            
            alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))
            
            rootViewController.present(alert, animated: true)
        }
    }
    
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            Logger.shared.log(.error, "Failed to create settings URL", category: .permission)
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                Logger.shared.log(
                    success ? .info : .error,
                    "Opening settings: \(success ? "✅ Success" : "❌ Failed")",
                    category: .permission
                )
            }
        }
    }
    
    // MARK: - Persistence
    
    private func loadPersistedState() {
        hasShownBackgroundRefreshAlert = userDefaults.bool(
            forKey: UserDefaultsKey.hasShownBackgroundRefreshAlert
        )
        hasShownNotificationAlert = userDefaults.bool(
            forKey: UserDefaultsKey.hasShownNotificationAlert
        )
    }
    
    private func savePersistedState() {
        userDefaults.set(
            hasShownBackgroundRefreshAlert,
            forKey: UserDefaultsKey.hasShownBackgroundRefreshAlert
        )
        userDefaults.set(
            hasShownNotificationAlert,
            forKey: UserDefaultsKey.hasShownNotificationAlert
        )
    }
    
    // MARK: - Helpers
    
    private func statusDescription(_ status: PermissionStatus) -> String {
        switch status {
        case .authorized:
            return "✅ Authorized"
        case .denied:
            return "❌ Denied"
        case .restricted:
            return "🔒 Restricted"
        case .notDetermined:
            return "❓ Not Determined"
        case .unknown:
            return "⚠️ Unknown"
        }
    }
    
    // MARK: - Metrics
    
    func getPermissionMetrics() -> [String: Any] {
        var metrics: [String: Any] = [
            "backgroundRefresh": statusDescription(getBackgroundRefreshStatus()),
            "alertsShown": [
                "backgroundRefresh": hasShownBackgroundRefreshAlert,
                "notifications": hasShownNotificationAlert
            ]
        ]
        
        if let lastCheck = userDefaults.object(forKey: UserDefaultsKey.lastPermissionCheckDate) as? Date {
            metrics["lastCheckDate"] = ISO8601DateFormatter().string(from: lastCheck)
        }
        
        return metrics
    }
}