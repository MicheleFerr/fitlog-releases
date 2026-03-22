import Foundation
import UIKit
import UserNotifications

/// Single owner for timer completion notifications on iOS.
final class DirectNotificationManager: NSObject {
    static let shared = DirectNotificationManager()
    static let restTimerNotificationIdentifier = RestTimerNotificationSupport.notificationIdentifier
    static let timerCategoryIdentifier = RestTimerNotificationSupport.categoryIdentifier

    private let pendingNotificationPayloadKey = "DirectNotificationManager_PendingNotificationPayload"
    private let trackingQueue = DispatchQueue(label: "com.gymbro.notification.tracking", qos: .userInitiated)
    private var deliveredNotifications: [String: Date] = [:]
    private var scheduledNotifications: [String: Date] = [:]

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    @discardableResult
    func scheduleRestTimerCompletion(
        duration: TimeInterval,
        soundName: String,
        title: String,
        body: String
    ) -> String {
        Logger.shared.log(
            .debug,
            """
            [TIMER-NOTIFICATION] Scheduling rest timer completion
            duration=\(duration)
            title=\(title)
            body=\(body)
            soundName=\(soundName)
            appState=\(debugApplicationState())
            resolution:
            \(RestTimerNotificationSupport.debugResolutionTrace(for: soundName))
            """,
            category: .general
        )
        logRestTimerNotificationState(context: "before scheduleRestTimerCompletion")

        trackingQueue.sync {
            scheduledNotifications[Self.restTimerNotificationIdentifier] = Date()
        }

        let identifier = RestTimerNotificationSupport.scheduleCompletion(
            after: duration,
            soundName: soundName,
            title: title,
            body: body
        ) { error in
            if let error {
                Logger.shared.log(.error, "❌ Failed to schedule rest timer completion: \(error.localizedDescription)", category: .general)
            } else {
                Logger.shared.log(.debug, "✅ [TIMER-NOTIFICATION] scheduleRestTimerCompletion add request succeeded", category: .general)
            }

            self.logRestTimerNotificationState(context: "after scheduleRestTimerCompletion add")
        }

        return identifier
    }

    func cancelRestTimerCompletion() {
        Logger.shared.log(
            .debug,
            "🗑️ [TIMER-NOTIFICATION] Cancel rest timer completion request appState=\(debugApplicationState())",
            category: .general
        )
        logRestTimerNotificationState(context: "before cancelRestTimerCompletion")
        RestTimerNotificationSupport.cancelCompletion()

        trackingQueue.sync {
            _ = scheduledNotifications.removeValue(forKey: Self.restTimerNotificationIdentifier)
        }
        logRestTimerNotificationState(context: "after cancelRestTimerCompletion")
    }

    func isRestTimerCompletionPending(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let isPending = requests.contains { request in
                request.identifier == Self.restTimerNotificationIdentifier
            }
            completion(isPending)
        }
    }

    func sendTimerNotification(
        title: String,
        body: String,
        soundName: String = "sound",
        categoryIdentifier: String = DirectNotificationManager.timerCategoryIdentifier,
        delay: TimeInterval = 0,
        playSound: Bool = true
    ) {
        if delay > 0 {
            _ = scheduleGenericTimerNotification(
                after: delay,
                title: title,
                body: body,
                soundName: soundName,
                categoryIdentifier: categoryIdentifier,
                playSound: playSound
            )
            return
        }

        let identifier = UUID().uuidString
        let content = makeNotificationContent(
            title: title,
            body: body,
            soundName: soundName,
            categoryIdentifier: categoryIdentifier,
            playSound: playSound
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )

        trackingQueue.sync {
            scheduledNotifications[identifier] = Date()
        }

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                Logger.shared.log(.error, "❌ Failed to send immediate timer notification: \(error.localizedDescription)", category: .general)
            }
        }
    }

    @discardableResult
    func scheduleGenericTimerNotification(
        after seconds: TimeInterval,
        title: String,
        body: String,
        soundName: String = "sound",
        categoryIdentifier: String = DirectNotificationManager.timerCategoryIdentifier,
        playSound: Bool = true
    ) -> String {
        let identifier = UUID().uuidString
        let content = makeNotificationContent(
            title: title,
            body: body,
            soundName: soundName,
            categoryIdentifier: categoryIdentifier,
            playSound: playSound
        )
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, seconds),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        trackingQueue.sync {
            scheduledNotifications[identifier] = Date()
        }

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                Logger.shared.log(.error, "❌ Failed to schedule timer notification: \(error.localizedDescription)", category: .general)
            }
        }

        return identifier
    }

    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        trackingQueue.sync {
            _ = scheduledNotifications.removeValue(forKey: identifier)
        }
    }

    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        trackingQueue.sync {
            scheduledNotifications.removeAll()
        }
    }

    func cancelAllTimerNotifications() {
        cancelRestTimerCompletion()
    }

    func resetSkipFlag() {
        // No-op. Legacy compatibility only.
    }

    func wasNotificationDelivered(identifier: String) -> Bool {
        trackingQueue.sync {
            deliveredNotifications[identifier] != nil
        }
    }

    func cleanupOldTimerNotifications(olderThanSeconds seconds: TimeInterval) {
        let threshold = Date().addingTimeInterval(-seconds)
        trackingQueue.sync {
            deliveredNotifications = deliveredNotifications.filter { $0.value >= threshold }
            scheduledNotifications = scheduledNotifications.filter { $0.value >= threshold }
        }
    }

    func verifyAudioFile(_ soundName: String) -> Bool {
        let trimmed = soundName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        let normalized = RestTimerNotificationSupport.normalizedSoundName(trimmed)
        return RestTimerNotificationSupport.resolvedSoundFileName(for: normalized) != nil
    }

    func storePendingNotificationPayload(_ payload: String) {
        UserDefaults.standard.set(payload, forKey: pendingNotificationPayloadKey)
    }

    func consumePendingNotificationPayload() -> String? {
        let payload = UserDefaults.standard.string(forKey: pendingNotificationPayloadKey)
        UserDefaults.standard.removeObject(forKey: pendingNotificationPayloadKey)
        return payload
    }

    func clearPendingNotificationPayload() {
        UserDefaults.standard.removeObject(forKey: pendingNotificationPayloadKey)
    }

    private func makeNotificationContent(
        title: String,
        body: String,
        soundName: String,
        categoryIdentifier: String,
        playSound: Bool
    ) -> UNMutableNotificationContent {
        RestTimerNotificationSupport.makeContent(
            title: title,
            body: body,
            soundName: soundName,
            categoryIdentifier: categoryIdentifier,
            playSound: playSound
        )
    }

    func logRestTimerNotificationState(context: String) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            center.getPendingNotificationRequests { requests in
                center.getDeliveredNotifications { delivered in
                    let pendingSummary = requests
                        .filter { $0.identifier == Self.restTimerNotificationIdentifier }
                        .map { request in
                            let triggerDescription: String
                            if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                                triggerDescription = "timeInterval=\(trigger.timeInterval)s repeats=\(trigger.repeats)"
                            } else {
                                triggerDescription = String(describing: request.trigger)
                            }

                            return "id=\(request.identifier) sound=\(String(describing: request.content.sound)) category=\(request.content.categoryIdentifier) trigger=\(triggerDescription)"
                        }

                    let deliveredSummary = delivered
                        .filter { $0.request.identifier == Self.restTimerNotificationIdentifier }
                        .map { notification in
                            "id=\(notification.request.identifier) sound=\(String(describing: notification.request.content.sound)) date=\(notification.date)"
                        }

                    Logger.shared.log(
                        .debug,
                        """
                        [TIMER-NOTIFICATION] \(context)
                        appState=\(self.debugApplicationState())
                        authorization=\(settings.authorizationStatus.rawValue)
                        alertSetting=\(settings.alertSetting.rawValue)
                        soundSetting=\(settings.soundSetting.rawValue)
                        pendingCount=\(pendingSummary.count)
                        pending=\(pendingSummary.isEmpty ? "[]" : pendingSummary.joined(separator: " | "))
                        deliveredCount=\(deliveredSummary.count)
                        delivered=\(deliveredSummary.isEmpty ? "[]" : deliveredSummary.joined(separator: " | "))
                        """,
                        category: .general
                    )
                }
            }
        }
    }

    private func debugApplicationState() -> String {
        switch UIApplication.shared.applicationState {
        case .active:
            return "active"
        case .background:
            return "background"
        case .inactive:
            return "inactive"
        @unknown default:
            return "unknown"
        }
    }
}

extension DirectNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let identifier = notification.request.identifier
        trackingQueue.sync {
            deliveredNotifications[identifier] = Date()
        }

        Logger.shared.log(
            .debug,
            """
            [TIMER-NOTIFICATION] willPresent
            id=\(identifier)
            category=\(notification.request.content.categoryIdentifier)
            sound=\(String(describing: notification.request.content.sound))
            userInfo=\(notification.request.content.userInfo)
            appState=\(debugApplicationState())
            """,
            category: .general
        )

        let categoryIdentifier = notification.request.content.categoryIdentifier
        if categoryIdentifier == Self.timerCategoryIdentifier ||
            identifier == Self.restTimerNotificationIdentifier {
            completionHandler([.banner, .list, .badge, .sound])
            return
        }

        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let content = response.notification.request.content
        Logger.shared.log(
            .debug,
            """
            [TIMER-NOTIFICATION] didReceive
            id=\(response.notification.request.identifier)
            action=\(response.actionIdentifier)
            category=\(content.categoryIdentifier)
            sound=\(String(describing: content.sound))
            userInfo=\(content.userInfo)
            appState=\(debugApplicationState())
            """,
            category: .general
        )

        if content.categoryIdentifier == WatchConnectivityManager.watchWorkoutRescueCategory,
           response.actionIdentifier == UNNotificationDefaultActionIdentifier,
           let payload = content.userInfo[WatchConnectivityManager.notificationPayloadUserInfoKey] as? String {
            storePendingNotificationPayload(payload)

            DispatchQueue.main.async {
                FlutterChannelRegistry.shared.unified?.invokeMethod("nativeNotificationDeepLink", arguments: [
                    "payload": payload,
                ])
            }
        }

        completionHandler()
    }
}
