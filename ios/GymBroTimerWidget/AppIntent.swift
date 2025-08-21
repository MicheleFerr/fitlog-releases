//
//  AppIntent.swift
//  GymBroTimerWidget
//
//  Created by Michele on 31/07/25.
//

import WidgetKit
import AppIntents
import UIKit
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

@available(iOS 16.0, *)
struct AddTimeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Add Time" }
    static var description: IntentDescription { "Add 30 seconds to the rest timer" }
    
    func perform() async throws -> some IntentResult {
        // Find the current activity and update it directly
        if let activity = Activity<GymBroTimerAttributes>.activities.first {
            let currentState = activity.content.state
            let newRemainingSeconds = currentState.remainingSeconds + 30
            let newTotalSeconds = max(currentState.totalSeconds, newRemainingSeconds)
            
            let updatedState = GymBroTimerAttributes.ContentState(
                remainingSeconds: newRemainingSeconds,
                totalSeconds: newTotalSeconds,
                isRunning: currentState.isRunning,
                currentSet: currentState.currentSet,
                totalSets: currentState.totalSets,
                lastUpdated: Date()
            )
            
            // Update Live Activity
            await activity.update(
                ActivityContent<GymBroTimerAttributes.ContentState>(
                    state: updatedState,
                    staleDate: nil as Date?
                )
            )
            
            // 🔥 NUOVO: Salva evento per Flutter tramite UserDefaults condivisi
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
            userDefaults?.synchronize()
        }
        return .result()
    }
}

@available(iOS 16.0, *)
struct PauseResumeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Pause/Resume" }
    static var description: IntentDescription { "Pause or resume the rest timer" }
    
    func perform() async throws -> some IntentResult {
        // Find the current activity and toggle pause/resume
        if let activity = Activity<GymBroTimerAttributes>.activities.first {
            let currentState = activity.content.state
            let newIsRunning = !currentState.isRunning
            
            let updatedState = GymBroTimerAttributes.ContentState(
                remainingSeconds: currentState.remainingSeconds,
                totalSeconds: currentState.totalSeconds,
                isRunning: newIsRunning,
                currentSet: currentState.currentSet,
                totalSets: currentState.totalSets,
                lastUpdated: Date()
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
            userDefaults?.synchronize()
        }
        return .result()
    }
}

@available(iOS 16.0, *)
struct SkipTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Skip Timer" }
    static var description: IntentDescription { "Skip the current rest timer" }
    
    func perform() async throws -> some IntentResult {
        // Find the current activity and skip timer
        if let activity = Activity<GymBroTimerAttributes>.activities.first {
            let currentState = activity.content.state
            
            let updatedState = GymBroTimerAttributes.ContentState(
                remainingSeconds: 0,
                totalSeconds: currentState.totalSeconds,
                isRunning: false,
                currentSet: currentState.currentSet,
                totalSets: currentState.totalSets,
                lastUpdated: Date()
            )
            
            await activity.update(
                ActivityContent<GymBroTimerAttributes.ContentState>(
                    state: updatedState,
                    staleDate: nil as Date?
                )
            )
            
            // 🔥 NUEVO: Salva evento per Flutter tramite UserDefaults condivisi
            let userDefaults = UserDefaults(suiteName: "group.com.michele.gymbro.flutter")
            let eventData: [String: Any] = [
                "remainingSeconds": 0,
                "totalSeconds": currentState.totalSeconds,
                "isRunning": false,
                "currentSet": currentState.currentSet,
                "totalSets": currentState.totalSets,
                "lastUpdated": Date().timeIntervalSince1970 * 1000,
                "activityId": activity.id,
                "eventType": "skip"
            ]
            userDefaults?.set(eventData, forKey: "timer_event")
            userDefaults?.synchronize()
        }
        return .result()
    }
}

@available(iOS 16.0, *)
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
                lastUpdated: Date()
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
            userDefaults?.synchronize()
        }
        return .result()
    }
}

// Helper extension for accessing Live Activity Handler
@available(iOS 16.0, *)
extension LiveActivityIntent {
    // This extension provides access to shared LiveActivityHandler methods
    // from within App Intents
}
