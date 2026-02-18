import Foundation
import UserNotifications

/// Helper per verificare e richiedere permessi notifiche
final class NotificationPermissionHelper {
    
    static let shared = NotificationPermissionHelper()
    
    private init() {}
    
    /// Verifica e richiede permessi per notifiche con audio
    func ensureNotificationPermissions(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        // Check current authorization status
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                Logger.shared.log(.info, "✅ Notifications authorized", category: .permission)
                
                // Check specific permissions
                self.logPermissionDetails(settings)
                completion(true)
                
            case .denied:
                Logger.shared.log(.error, "❌ Notifications denied - timer audio won't work!", category: .permission)
                completion(false)
                
            case .notDetermined:
                Logger.shared.log(.info, "📱 Requesting notification permissions...", category: .permission)
                
                // Request authorization with all options needed for timer
                // Note: .criticalAlert requires special entitlement from Apple
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        Logger.shared.log(.info, "✅ Notification permissions granted", category: .permission)
                    } else {
                        Logger.shared.log(.error, "❌ Notification permissions denied: \(error?.localizedDescription ?? "Unknown")", category: .permission)
                    }
                    completion(granted)
                }
                
            case .provisional:
                Logger.shared.log(.warning, "⚠️ Provisional notifications - requesting full permissions", category: .permission)
                
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    completion(granted)
                }
                
            case .ephemeral:
                Logger.shared.log(.warning, "⚠️ Ephemeral notifications - limited functionality", category: .permission)
                completion(false)
                
            @unknown default:
                Logger.shared.log(.warning, "⚠️ Unknown notification status", category: .permission)
                completion(false)
            }
        }
    }
    
    private func logPermissionDetails(_ settings: UNNotificationSettings) {
        Logger.shared.log(.debug, """
            📱 Notification Permission Details:
            - Sound Enabled: \(settings.soundSetting == .enabled ? "✅" : "❌")
            - Alert Enabled: \(settings.alertSetting == .enabled ? "✅" : "❌")
            - Badge Enabled: \(settings.badgeSetting == .enabled ? "✅" : "❌")
            - Critical Alert: \(settings.criticalAlertSetting == .enabled ? "✅" : "⚠️")
            - Notification Center: \(settings.notificationCenterSetting == .enabled ? "✅" : "❌")
            - Lock Screen: \(settings.lockScreenSetting == .enabled ? "✅" : "❌")
            - Alert Style: \(settings.alertStyle.rawValue)
            """, category: .permission)
        
        if settings.soundSetting != .enabled {
            Logger.shared.log(.error, "🔇 SOUND DISABLED - Timer audio won't play!", category: .permission)
        }
    }
    
    /// Verifica se possiamo riprodurre suoni critici (async — no deadlock risk)
    func canPlayCriticalAlerts() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.criticalAlertSetting == .enabled
    }
}