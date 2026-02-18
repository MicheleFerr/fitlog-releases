import UserNotifications
import Flutter

/// Delegate per gestire le notifiche e prevenire doppi suoni
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationDelegate()
    private var flutterChannel: FlutterMethodChannel?
    
    private override init() {
        super.init()
    }
    
    func setupWithMessenger(_ messenger: FlutterBinaryMessenger) {
        flutterChannel = FlutterMethodChannel(
            name: ChannelNames.unified,
            binaryMessenger: messenger
        )
        
        // Note: delegate is managed by DirectNotificationManager (sole delegate)
        // This class provides a Flutter channel bridge only
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Called when a notification is about to be presented while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("📱 Notification will present in foreground")
        
        // Check if this is a timer notification
        if notification.request.content.categoryIdentifier == "TIMER_COMPLETE" {
            print("⏰ Timer notification detected in foreground")
            
            // Notify Flutter that notification was shown
            notifyFlutterNotificationShown(notification: notification)
            
            // In foreground: show banner but NO sound (Flutter will handle it)
            // This prevents double sound when app is active
            completionHandler([.banner, .list])
        } else {
            // Other notifications: show normally
            completionHandler([.banner, .sound, .list])
        }
    }
    
    /// Called when user interacts with a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("📱 User interacted with notification: \(response.actionIdentifier)")
        
        if response.notification.request.content.categoryIdentifier == "TIMER_COMPLETE" {
            // User tapped on timer notification
            notifyFlutterNotificationTapped(notification: response.notification)
        }
        
        completionHandler()
    }
    
    // MARK: - Private Methods
    
    private func notifyFlutterNotificationShown(notification: UNNotification) {
        flutterChannel?.invokeMethod("notificationShown", arguments: [
            "identifier": notification.request.identifier,
            "timestamp": Date().timeIntervalSince1970,
            "inForeground": UIApplication.shared.applicationState == .active
        ])
        print("📨 Notified Flutter that notification was shown")
    }
    
    private func notifyFlutterNotificationTapped(notification: UNNotification) {
        flutterChannel?.invokeMethod("notificationTapped", arguments: [
            "identifier": notification.request.identifier,
            "timestamp": Date().timeIntervalSince1970
        ])
        print("📨 Notified Flutter that notification was tapped")
    }
}