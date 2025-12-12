//
//  NotificationManager.swift
//  FitLogWatch Watch App
//
//  Manages local notifications on Apple Watch
//  Used to alert user when workout starts on iPhone
//

import Foundation
import UserNotifications
import WatchKit

/// Manages local notifications for the Watch app
/// Note: This is NOT an ObservableObject since we don't need to observe notification state in UI
@MainActor
final class NotificationManager {

    static let shared = NotificationManager()

    private(set) var isAuthorized = false

    private init() {
        checkAuthorization()
    }

    // MARK: - Authorization

    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            Task { @MainActor in
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    // MARK: - Show Workout Notification

    /// Show notification when workout starts on iPhone
    /// Uses localized messages based on ConnectivityManager's appLocale
    func showWorkoutStartedNotification(exerciseName: String) {
        // Get locale from ConnectivityManager
        let isItalian = ConnectivityManager.shared.appLocale == "it"

        let content = UNMutableNotificationContent()
        content.title = isItalian ? "Allenamento iniziato!" : "Workout Started!"
        content.body = isItalian
            ? "Usa il tuo Apple Watch per un'esperienza completa"
            : "Use your Apple Watch for the full experience"
        content.sound = .default
        content.categoryIdentifier = "WORKOUT_STARTED"

        // Immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "workout_started_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                // Trigger haptic on success
                Task { @MainActor in
                    WKInterfaceDevice.current().play(.notification)
                }
            }
        }
    }

    /// Show notification when set is completed
    func showSetCompletedNotification(setNumber: Int, exerciseName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Set \(setNumber) Complete"
        content.body = exerciseName
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "set_completed_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { _ in }
    }

    /// Clear all pending notifications
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

// MARK: - Notification Delegate Helper

/// Handles notification presentation and tap responses
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // User tapped notification - app is already opening
        completionHandler()
    }
}
