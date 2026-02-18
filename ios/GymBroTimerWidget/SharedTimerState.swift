//
//  SharedTimerState.swift
//  GymBroTimerWidget
//
//  Created by Claude for GymBro TrackLog
//

import Foundation

struct TimerStateData: Codable {
    let remainingSeconds: Int
    let totalSeconds: Int
    let isRunning: Bool
    let currentSet: Int
    let totalSets: Int
    let lastUpdated: Date
    let activityId: String
    let eventType: String // "add_time", "pause_resume", "skip", "complete_set"
}

class SharedTimerState {
    private static let groupID = "group.com.michele.gymbro.flutter"
    private static let stateKey = "current_timer_state"
    private static let eventKey = "timer_event"
    private static let changeKey = "timer_last_change"
    
    static private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: groupID)
    }
    
    static func saveTimerState(_ state: TimerStateData) {
        guard let defaults = userDefaults else { return }
        
        if let encoded = try? JSONEncoder().encode(state) {
            defaults.set(encoded, forKey: stateKey)
            defaults.set(Date(), forKey: changeKey)
        }
    }

    static func getTimerState() -> TimerStateData? {
        guard let defaults = userDefaults,
              let data = defaults.data(forKey: stateKey) else { return nil }
        
        return try? JSONDecoder().decode(TimerStateData.self, from: data)
    }
    
    static func getLastChangeDate() -> Date? {
        return userDefaults?.object(forKey: changeKey) as? Date
    }
    
    static func clearTimerState() {
        userDefaults?.removeObject(forKey: stateKey)
        userDefaults?.removeObject(forKey: eventKey)
        userDefaults?.removeObject(forKey: changeKey)
    }

    // Salva evento per comunicazione con Flutter
    static func saveTimerEvent(_ event: TimerStateData) {
        guard let defaults = userDefaults else { return }
        
        if let encoded = try? JSONEncoder().encode(event) {
            defaults.set(encoded, forKey: eventKey)
        }
    }
    
    static func getAndClearTimerEvent() -> TimerStateData? {
        guard let defaults = userDefaults,
              let data = defaults.data(forKey: eventKey) else { return nil }
        
        // Rimuovi evento dopo lettura per evitare duplicati
        defaults.removeObject(forKey: eventKey)

        return try? JSONDecoder().decode(TimerStateData.self, from: data)
    }
}