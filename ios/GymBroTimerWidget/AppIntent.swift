//
//  AppIntent.swift
//  GymBroTimerWidget
//
//  Created by Michele on 31/07/25.
//

import WidgetKit
import AppIntents
import ActivityKit
import Foundation
import UserNotifications

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}

// MARK: - Live Activity Interactive Intents

@available(iOS 16.1, *)
struct AddTimeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Add Time" }
    static var description: IntentDescription { "Add 30 seconds to the rest timer" }
    
    func perform() async throws -> some IntentResult {
        // Find the current activity and update it directly
        if let activity = Activity<GymBroTimerAttributes>.activities.first {
            let currentState = activity.content.state
            let newRemainingSeconds = currentState.remainingSeconds + 30
            let newTotalSeconds = max(currentState.totalSeconds, newRemainingSeconds)

            // ✅ CRITICAL FIX: Recalculate startDate and endDate for native iOS timer
            let now = Date()
            let newEndDate: Date?
            let newStartDate: Date?

            if currentState.isRunning {
                // Timer is running - calculate new end time from now
                newEndDate = now.addingTimeInterval(TimeInterval(newRemainingSeconds))
                // Calculate when timer originally started (adjusted for new total)
                newStartDate = now.addingTimeInterval(-TimeInterval(newTotalSeconds - newRemainingSeconds))
            } else {
                // Timer is paused - keep dates nil
                newEndDate = nil
                newStartDate = nil
            }

            let updatedState = GymBroTimerAttributes.ContentState(
                remainingSeconds: newRemainingSeconds,
                totalSeconds: newTotalSeconds,
                isRunning: currentState.isRunning,
                currentSet: currentState.currentSet,
                totalSets: currentState.totalSets,
                lastUpdated: Date(),
                endDate: newEndDate,
                startDate: newStartDate
            )
            
            // Update Live Activity
            await activity.update(
                ActivityContent<GymBroTimerAttributes.ContentState>(
                    state: updatedState,
                    staleDate: nil as Date?
                )
            )
            
            // Salva evento per Flutter tramite UserDefaults condivisi
            let userDefaults = UserDefaults(suiteName: "group.com.michele.gymbro.flutter")
            let eventData: [String: Any] = [
                "remainingSeconds": newRemainingSeconds,
                "totalSeconds": newTotalSeconds,
                "isRunning": currentState.isRunning,
                "currentSet": currentState.currentSet,
                "totalSets": currentState.totalSets,
                "lastUpdated": Date().timeIntervalSince1970 * 1000,
                "activityId": activity.id,
                "eventType": "add_time"
            ]
            userDefaults?.set(eventData, forKey: "timer_event")

            // FIX C4: Cancel the original scheduled notification and reschedule it for the
            // new end time. Without this, the notification fires at the OLD time (before the
            // extended timer ends), causing a premature sound alert to the user.
            if currentState.isRunning {
                await rescheduleTimerNotification(
                    remainingSeconds: newRemainingSeconds,
                    userDefaults: userDefaults
                )
            }
        }
        return .result()
    }
}

@available(iOS 16.1, *)
struct PauseResumeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Pause/Resume" }
    static var description: IntentDescription { "Pause or resume the rest timer" }
    
    func perform() async throws -> some IntentResult {
        // Find the current activity and toggle pause/resume
        if let activity = Activity<GymBroTimerAttributes>.activities.first {
            let currentState = activity.content.state
            let newIsRunning = !currentState.isRunning

            // ✅ CRITICAL FIX: Recalculate startDate and endDate when toggling pause/resume
            let now = Date()
            let newEndDate: Date?
            let newStartDate: Date?

            if newIsRunning {
                // Resuming timer - calculate new end time from now
                newEndDate = now.addingTimeInterval(TimeInterval(currentState.remainingSeconds))
                // Calculate when timer started (for progress calculation)
                newStartDate = now.addingTimeInterval(-TimeInterval(currentState.totalSeconds - currentState.remainingSeconds))
            } else {
                // Pausing timer - clear dates to stop native iOS countdown
                newEndDate = nil
                newStartDate = nil
            }

            let updatedState = GymBroTimerAttributes.ContentState(
                remainingSeconds: currentState.remainingSeconds,
                totalSeconds: currentState.totalSeconds,
                isRunning: newIsRunning,
                currentSet: currentState.currentSet,
                totalSets: currentState.totalSets,
                lastUpdated: Date(),
                endDate: newEndDate,
                startDate: newStartDate
            )
            
            await activity.update(
                ActivityContent<GymBroTimerAttributes.ContentState>(
                    state: updatedState,
                    staleDate: nil as Date?
                )
            )
            
            // 🔥 NUOVO: Salva evento per Flutter tramite UserDefaults condivisi
            let userDefaults = UserDefaults(suiteName: "group.com.michele.gymbro.flutter")
            let eventData: [String: Any] = [
                "remainingSeconds": currentState.remainingSeconds,
                "totalSeconds": currentState.totalSeconds,
                "isRunning": newIsRunning,
                "currentSet": currentState.currentSet,
                "totalSets": currentState.totalSets,
                "lastUpdated": Date().timeIntervalSince1970 * 1000,
                "activityId": activity.id,
                "eventType": "pause_resume"
            ]
            userDefaults?.set(eventData, forKey: "timer_event")

        }
        return .result()
    }
}

@available(iOS 16.1, *)
struct SkipTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Skip Timer" }
    static var description: IntentDescription { "Skip the current rest timer" }

    func perform() async throws -> some IntentResult {
        // Find the current activity and skip timer
        if let activity = Activity<GymBroTimerAttributes>.activities.first {
            let currentState = activity.content.state

            // CRITICAL FIX: Update state to show timer is skipped
            // Audio cancellation will be handled by the main app when it receives this event
            let updatedState = GymBroTimerAttributes.ContentState(
                remainingSeconds: 0,
                totalSeconds: currentState.totalSeconds,
                isRunning: false,
                currentSet: currentState.currentSet,
                totalSets: currentState.totalSets,
                lastUpdated: Date(),
                endDate: nil,  // ✅ Clear timer dates when skipped
                startDate: nil
            )

            await activity.update(
                ActivityContent<GymBroTimerAttributes.ContentState>(
                    state: updatedState,
                    staleDate: nil as Date?
                )
            )

            // 🔥 CRITICAL: Signal skip to main app via UserDefaults
            // The main app will cancel background audio when it detects this event
            let userDefaults = UserDefaults(suiteName: "group.com.michele.gymbro.flutter")
            let eventData: [String: Any] = [
                "remainingSeconds": 0,
                "totalSeconds": currentState.totalSeconds,
                "isRunning": false,
                "currentSet": currentState.currentSet,
                "totalSets": currentState.totalSets,
                "lastUpdated": Date().timeIntervalSince1970 * 1000,
                "activityId": activity.id,
                "eventType": "skip",
                "audioSkipped": true  // Flag to indicate audio should not play
            ]
            userDefaults?.set(eventData, forKey: "timer_event")

            // MEDIO-8 FIX: End the Live Activity immediately after skip.
            // Previously the activity was updated to remainingSeconds=0 but never
            // ended — it lingered on the lock screen indefinitely.
            // Using .immediate since the user explicitly dismissed the rest timer.
            await activity.end(dismissalPolicy: .immediate)
        }
        return .result()
    }
}

@available(iOS 16.1, *)
struct CompleteSetIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Complete Set" }
    static var description: IntentDescription { "Mark the current set as complete" }
    
    func perform() async throws -> some IntentResult {
        // Find the current activity and advance to next set
        if let activity = Activity<GymBroTimerAttributes>.activities.first {
            let currentState = activity.content.state
            let nextSet = min(currentState.currentSet + 1, currentState.totalSets)
            
            let updatedState = GymBroTimerAttributes.ContentState(
                remainingSeconds: currentState.remainingSeconds,
                totalSeconds: currentState.totalSeconds,
                isRunning: currentState.isRunning,
                currentSet: nextSet,
                totalSets: currentState.totalSets,
                lastUpdated: Date(),
                endDate: currentState.endDate,  // ✅ Preserve timer dates when advancing set
                startDate: currentState.startDate
            )
            
            await activity.update(
                ActivityContent<GymBroTimerAttributes.ContentState>(
                    state: updatedState,
                    staleDate: nil as Date?
                )
            )
            
            // 🔥 NUOVO: Salva evento per Flutter tramite UserDefaults condivisi
            let userDefaults = UserDefaults(suiteName: "group.com.michele.gymbro.flutter")
            let eventData: [String: Any] = [
                "remainingSeconds": currentState.remainingSeconds,
                "totalSeconds": currentState.totalSeconds,
                "isRunning": currentState.isRunning,
                "currentSet": nextSet,
                "totalSets": currentState.totalSets,
                "lastUpdated": Date().timeIntervalSince1970 * 1000,
                "activityId": activity.id,
                "eventType": "complete_set"
            ]
            userDefaults?.set(eventData, forKey: "timer_event")

        }
        return .result()
    }
}

// Helper extension for accessing Live Activity Handler
@available(iOS 16.1, *)
extension LiveActivityIntent {
    // This extension provides access to shared LiveActivityHandler methods
    // from within App Intents
}

// MARK: - FIX C4: Notification Rescheduling Helper

/// Cancels the existing timer completion notification and schedules a new one
/// for the updated remaining seconds. Called from AddTimeIntent to prevent
/// the old notification from firing before the extended timer ends.
@available(iOS 16.1, *)
private func rescheduleTimerNotification(
    remainingSeconds: Int,
    userDefaults: UserDefaults?
) async {
    let center = UNUserNotificationCenter.current()

    // 1. Cancel all pending timer notifications (by category, catches both
    //    app-scheduled and intent-scheduled notifications)
    let pendingRequests = await center.pendingNotificationRequests()
    let timerIds = pendingRequests
        .filter { $0.content.categoryIdentifier == "TIMER_COMPLETE" }
        .map { $0.identifier }

    if !timerIds.isEmpty {
        center.removePendingNotificationRequests(withIdentifiers: timerIds)
    }

    // 2. Read preferred sound from shared UserDefaults (same key used by main app)
    let soundName = userDefaults?.string(forKey: "timer_notification_sound") ?? "sound"
    let soundFileName = "\(soundName).caf"

    // 3. Schedule new notification at the updated end time
    let content = UNMutableNotificationContent()
    content.title = "⏱️ Rest Complete"
    content.body = "Time to start your next set!"
    content.categoryIdentifier = "TIMER_COMPLETE"
    content.sound = UNNotificationSound(named: UNNotificationSoundName(soundFileName))
    content.userInfo = [
        "type": "rest_timer_completion",
        "source": "add_time_intent",
        "scheduledAt": Date().timeIntervalSince1970
    ]

    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: TimeInterval(max(1, remainingSeconds)),
        repeats: false
    )

    let request = UNNotificationRequest(
        identifier: "com.gymbro.rest_timer_completion",
        content: content,
        trigger: trigger
    )

    do {
        try await center.add(request)
    } catch {
        // Non-fatal: Flutter will handle completion state even if notification fails
    }
}
