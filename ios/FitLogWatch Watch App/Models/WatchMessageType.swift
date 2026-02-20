//
//  WatchMessageType.swift
//  FitLogWatch Watch App
//
//  P2-1 FIX: Centralized message type constants
//  Eliminates magic strings in Watch ↔ iPhone communication
//

import Foundation

/// All message types exchanged between Watch and iPhone
/// Use these constants instead of raw strings to prevent typos
enum WatchMessageType {

    // MARK: - iPhone → Watch (workout lifecycle)
    static let workoutStarted = "workoutStarted"
    static let workoutEnded = "workoutEnded"
    static let workoutUpdate = "workoutUpdate"

    // MARK: - iPhone → Watch (rest timer)
    static let restTimerStarted = "restTimerStarted"
    static let restTimerSkipped = "restTimerSkipped"
    static let restTimerPaused = "restTimerPaused"
    static let restTimerResumed = "restTimerResumed"
    static let restTimerExtended = "restTimerExtended"

    // MARK: - iPhone → Watch (data)
    static let templatesUpdate = "templatesUpdate"

    // MARK: - Watch → iPhone (set actions)
    static let setCompleted = "setCompleted"
    static let skipRest = "skipRest"
    static let endWorkout = "endWorkout"
    static let pauseWorkout = "pauseWorkout"
    static let setModification = "setModification"
    static let extendTimer = "extendTimer"
    static let editCompletedSetReps = "editCompletedSetReps"
    static let uncompleteSet = "uncompleteSet"
    static let startNewTimer = "startNewTimer"

    // MARK: - Watch → iPhone (health)
    static let healthMetrics = "healthMetrics"
    static let workoutError = "workoutError"

    // MARK: - Watch → iPhone (navigation)
    static let jumpToExercise = "jumpToExercise"
    static let jumpToSet = "jumpToSet"
    static let copyToAllSets = "copyToAllSets"
    static let copyFromPreviousSet = "copyFromPreviousSet"

    // MARK: - Watch → iPhone (advanced workouts)
    static let supersetRoundCompleted = "supersetRoundCompleted"
    static let dropsetStageCompleted = "dropsetStageCompleted"
    static let dropsetCompleted = "dropsetCompleted"
    static let restPauseSetCompleted = "restPauseSetCompleted"
    static let restPauseCompleted = "restPauseCompleted"

    // MARK: - Watch → iPhone (workout completion)
    static let workoutCompleted = "workoutCompleted"

    // MARK: - Watch → iPhone (requests)
    static let requestWorkoutState = "requestWorkoutState"
    static let requestTemplates = "requestTemplates"

    // MARK: - Recovery protocol (Phone crash recovery)
    static let requestFullWorkoutSnapshot = "requestFullWorkoutSnapshot"
    static let fullWorkoutSnapshot = "fullWorkoutSnapshot"
}
