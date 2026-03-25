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

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}

// MARK: - Live Activity Interactive Intents

@available(iOS 16.1, *)
public struct AddTimeIntent: LiveActivityIntent {
    public init() {}
    public static var title: LocalizedStringResource { "Add Time" }
    public static var description: IntentDescription { "Add 15 seconds to the rest timer" }

    public func perform() async throws -> some IntentResult {
        // Find the current activity and update it directly
        if let activity = Activity<GymBroTimerAttributes>.activities.first {
            let currentState = activity.content.state
            let newRemainingSeconds = currentState.remainingSeconds + 15
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
            
            // 🔧 FIX: Use shared event pipeline (Darwin notification + correct UserDefaults key)
            // Previously wrote to "timer_event" which nobody read. Now uses "workout_session_event"
            // key + Darwin notification, same as WorkoutSessionIntents.swift.
            saveEventToUserDefaults(
                eventType: .addTime,
                additionalData: [
                    "addedSeconds": 15,
                    "activityId": activity.id
                ]
            )

            // FIX C4: Cancel the original scheduled notification and reschedule it for the
            // new end time. Without this, the notification fires at the OLD time (before the
            // extended timer ends), causing a premature sound alert to the user.
            if currentState.isRunning {
                await rescheduleRestTimerNotification(
                    remainingSeconds: newRemainingSeconds,
                    exerciseName: "Set"
                )
            }
        }
        return .result()
    }
}

@available(iOS 16.1, *)
public struct PauseResumeIntent: LiveActivityIntent {
    public init() {}
    public static var title: LocalizedStringResource { "Pause/Resume" }
    public static var description: IntentDescription { "Pause or resume the rest timer" }

    public func perform() async throws -> some IntentResult {
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
            
            // 🔧 FIX: Use shared event pipeline (Darwin notification + correct UserDefaults key)
            saveEventToUserDefaults(
                eventType: .pauseResume,
                additionalData: [
                    "isPaused": !newIsRunning,
                    "remainingSeconds": currentState.remainingSeconds,
                    "activityId": activity.id
                ]
            )

            if newIsRunning {
                await rescheduleRestTimerNotification(
                    remainingSeconds: currentState.remainingSeconds,
                    exerciseName: "Set"
                )
            } else {
                await cancelRestTimerNotification()
            }

        }
        return .result()
    }
}

@available(iOS 16.1, *)
public struct SkipTimerIntent: LiveActivityIntent {
    public init() {}
    public static var title: LocalizedStringResource { "Skip Timer" }
    public static var description: IntentDescription { "Skip the current rest timer" }

    public func perform() async throws -> some IntentResult {
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

            // 🔧 FIX: Use shared event pipeline (Darwin notification + correct UserDefaults key)
            saveEventToUserDefaults(
                eventType: .skipRest,
                additionalData: [
                    "audioSkipped": true,
                    "activityId": activity.id
                ]
            )

            await cancelRestTimerNotification()

            // End the Live Activity immediately after skip.
            // The user explicitly dismissed the timer, so the UI should disappear now.
            await activity.end(
                ActivityContent(
                    state: updatedState,
                    staleDate: nil
                ),
                dismissalPolicy: .immediate
            )
        }
        return .result()
    }
}

@available(iOS 16.1, *)
public struct CompleteSetIntent: LiveActivityIntent {
    public init() {}
    public static var title: LocalizedStringResource { "Complete Set" }
    public static var description: IntentDescription { "Mark the current set as complete" }

    public func perform() async throws -> some IntentResult {
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
            
            // 🔧 FIX: Use shared event pipeline (Darwin notification + correct UserDefaults key)
            saveEventToUserDefaults(
                eventType: .completeSet,
                additionalData: [
                    "activityId": activity.id
                ]
            )

        }
        return .result()
    }
}
