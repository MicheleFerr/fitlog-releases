//
//  FitLogWatchApp.swift
//  FitLogWatch Watch App
//
//  Created by Michele on 08/12/25.
//

import SwiftUI
import UserNotifications
import HealthKit

/// Map string workout type from iPhone to WorkoutManager.WorkoutType
/// Used to sync HKWorkoutSession type with Flutter app
private func mapWorkoutType(_ typeString: String) -> WorkoutManager.WorkoutType {
    switch typeString.lowercased() {
    case "hiit":
        return .hiit
    case "functional":
        return .functionalTraining
    case "strength", "strengthtraining":
        return .strengthTraining
    default:
        // Default to strength training for unknown types
        return .strengthTraining
    }
}

@main
struct FitLogWatch_Watch_AppApp: App {
    @StateObject private var connectivityManager = ConnectivityManager.shared
    @StateObject private var workoutManager = WorkoutManager()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Setup notification delegate for handling notification taps
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivityManager)
                .environmentObject(workoutManager)
                .task {
                    // Request notification permission on first launch
                    await NotificationManager.shared.requestAuthorization()

                    // ⌚ BUG FIX #5: Improved workout recovery on app restart
                    // Attempt to recover active workout session if app crashed
                    do {
                        try await workoutManager.recoverWorkoutSessionIfNeeded()

                        // If HKWorkoutSession was recovered, sync ConnectivityManager state
                        if workoutManager.isWorkoutActive {
                            print("⌚ [APP] HKWorkoutSession recovered - syncing with iPhone")
                            // Use unified sync to prevent race conditions
                            connectivityManager.syncWorkoutStateFromiPhone()
                        }
                    } catch {
                        // Recovery failed - silent failure is acceptable
                        // User can manually restart workout if needed
                        print("Workout recovery failed: \(error.localizedDescription)")
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        // Resync rest timer when app returns to foreground
                        // This handles watchOS timer suspension during background
                        print("⌚ [APP] ScenePhase -> active, resyncing timer and workout state")
                        connectivityManager.resyncTimerOnForeground()

                        // ✅ UNIFIED SYNC for fast foreground recovery (race-condition safe)
                        connectivityManager.syncWorkoutStateFromiPhone()

                        // ✅ BUG FIX #6: Restart HKWorkoutSession if needed
                        // When app returns to foreground, watchOS might have killed the
                        // HKWorkoutSession to save battery. The .onChange handler won't
                        // fire if isWorkoutActive is already true (no change).
                        // We need to explicitly check and restart the session.
                        Task {
                            // Small delay to allow sync to complete
                            try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5s

                            // If iPhone says workout is active but HKWorkoutSession is not running
                            if connectivityManager.isWorkoutActive &&
                               workoutManager.workoutState != .running &&
                               workoutManager.workoutState != .paused {
                                print("⌚ [APP] 🔄 Foreground recovery: iPhone workout active but HKWorkoutSession not running")
                                print("⌚ [APP] 🔄 Current HKWorkoutSession state: \(workoutManager.workoutState.rawValue)")

                                // 🧹 Clean up stale session if exists
                                if workoutManager.hasSessionInstance {
                                    print("⌚ [APP] 🧹 Cleaning stale session before foreground restart")
                                    await workoutManager.forceResetSession()
                                }

                                do {
                                    let workoutType = mapWorkoutType(connectivityManager.workoutType)
                                    print("⌚ [APP] 🔄 Restarting HKWorkoutSession with type: \(workoutType.rawValue)")
                                    try await workoutManager.startWorkout(type: workoutType, isCompanion: true)
                                    print("⌚ [APP] ✅ HKWorkoutSession restarted successfully on foreground")
                                } catch {
                                    print("⌚ [APP] ❌ Failed to restart HKWorkoutSession on foreground: \(error.localizedDescription)")
                                    let nsError = error as NSError
                                    print("⌚ [APP] Error domain: \(nsError.domain), code: \(nsError.code)")
                                }
                            }
                        }
                    }
                }
                // ⌚ BUG FIX #4: Auto-start HKWorkoutSession when iPhone workout starts
                // This ensures always-on display works even if Watch app was in background
                // HKWorkoutSession keeps the app in foreground and enables always-on display
                .onChange(of: connectivityManager.isWorkoutActive) { oldValue, newValue in
                    if newValue && !oldValue {
                        // Workout just became active - start HKWorkoutSession
                        // HKWorkoutSession keeps screen on and enables always-on display
                        print("⌚ [APP] Workout became active - starting HKWorkoutSession for always-on display")
                        Task {
                            // ✅ FIX: Check for ANY active session (running OR paused)
                            // Only skip if session is truly active and healthy
                            if workoutManager.workoutState == .running || workoutManager.workoutState == .paused {
                                print("⌚ [APP] HKWorkoutSession already active (state: \(workoutManager.workoutState.rawValue)), skipping start")
                                return
                            }

                            // 🧹 CRITICAL FIX: Force cleanup of stale sessions before starting new one
                            // This prevents "Unable to transition from Ended state" errors
                            // that occur when previous workout didn't clean up properly
                            if workoutManager.hasSessionInstance {
                                print("⌚ [APP] 🧹 Detected stale HKWorkoutSession (state: \(workoutManager.workoutState.rawValue))")
                                print("⌚ [APP] 🧹 Cleaning up before starting new session...")
                                await workoutManager.forceResetSession()
                            }

                            do {
                                // ✅ FIX: Use workout type from iPhone instead of hardcoding
                                let workoutType = mapWorkoutType(connectivityManager.workoutType)
                                print("⌚ [APP] Starting HKWorkoutSession with type: \(workoutType.rawValue)")

                                // isCompanion: true - haptic already played by ConnectivityManager
                                try await workoutManager.startWorkout(type: workoutType, isCompanion: true)
                                print("⌚ [APP] ✅ HKWorkoutSession started successfully (always-on display enabled)")
                            } catch {
                                print("⌚ [APP] ❌ Failed to start HKWorkoutSession: \(error.localizedDescription)")
                                // Log the full error for debugging
                                let nsError = error as NSError
                                print("⌚ [APP] Error domain: \(nsError.domain), code: \(nsError.code)")
                            }
                        }
                    } else if !newValue && oldValue {
                        // Workout just ended - end HKWorkoutSession
                        // ✅ FIX: Check shouldSaveWorkoutToHealthKit flag from iPhone
                        let shouldSave = connectivityManager.shouldSaveWorkoutToHealthKit
                        print("⌚ [APP] Workout ended - ending HKWorkoutSession (save: \(shouldSave))")
                        Task {
                            // ✅ FIX: Check workout STATE not just isWorkoutActive flag
                            // Only end if session is actually running or paused
                            guard workoutManager.workoutState == .running || workoutManager.workoutState == .paused else {
                                print("⌚ [APP] HKWorkoutSession not running (state: \(workoutManager.workoutState.rawValue)), skipping end")
                                return
                            }
                            do {
                                // ✅ FIX: Use shouldSave flag to determine if we save or discard
                                // - true: User tapped "End Workout" on iPhone → save to HealthKit
                                // - false: User tapped "Discard" on iPhone → don't save
                                if shouldSave {
                                    try await workoutManager.endWorkout()
                                    print("⌚ [APP] ✅ HKWorkoutSession ended and SAVED to HealthKit")
                                } else {
                                    try await workoutManager.discardWorkout()
                                    print("⌚ [APP] ✅ HKWorkoutSession DISCARDED (not saved to HealthKit)")
                                }
                            } catch {
                                print("⌚ [APP] ⚠️ Failed to end HKWorkoutSession: \(error.localizedDescription)")
                            }
                        }
                    }
                }
        }
    }
}
