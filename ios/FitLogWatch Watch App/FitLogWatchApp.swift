//
//  FitLogWatchApp.swift
//  FitLogWatch Watch App
//
//  Created by Michele on 08/12/25.
//

import SwiftUI
import UserNotifications

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
                            // Request fresh workout state from iPhone to ensure UI is synced
                            connectivityManager.requestWorkoutState()
                            // Also check cached context immediately for faster UI
                            connectivityManager.checkPendingApplicationContext()
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

                        // ✅ TWO-PHASE SYNC for fast foreground recovery:
                        // Phase 1 (immediate): Show cached state for instant UI
                        connectivityManager.checkPendingApplicationContext()
                        // Phase 2 (after brief delay): Request fresh state from iPhone
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            connectivityManager.requestWorkoutState()
                        }
                    }
                }
                // ⌚ BUG FIX #4: Auto-start HKWorkoutSession when iPhone workout starts
                // This ensures always-on display works even if Watch app was in background
                // HKWorkoutSession keeps the app in foreground and enables always-on display
                .onChange(of: connectivityManager.isWorkoutActive) { oldValue, newValue in
                    if newValue && !oldValue {
                        // Workout just became active - start HKWorkoutSession
                        print("⌚ [APP] Workout became active - starting HKWorkoutSession for always-on display")
                        Task {
                            // Check if session is already running (prevent duplicates)
                            guard !workoutManager.isWorkoutActive else {
                                print("⌚ [APP] HKWorkoutSession already active, skipping start")
                                return
                            }
                            do {
                                try await workoutManager.startWorkout(type: .strengthTraining)
                                print("⌚ [APP] ✅ HKWorkoutSession started successfully")
                            } catch {
                                print("⌚ [APP] ⚠️ Failed to start HKWorkoutSession: \(error.localizedDescription)")
                            }
                        }
                    } else if !newValue && oldValue {
                        // Workout just ended - end HKWorkoutSession
                        print("⌚ [APP] Workout ended - ending HKWorkoutSession")
                        Task {
                            // Only end if session is actually running
                            guard workoutManager.isWorkoutActive else {
                                print("⌚ [APP] HKWorkoutSession already inactive, skipping end")
                                return
                            }
                            do {
                                // Discard the session (workout data is saved on iPhone, not Watch)
                                try await workoutManager.discardWorkout()
                                print("⌚ [APP] ✅ HKWorkoutSession ended successfully")
                            } catch {
                                print("⌚ [APP] ⚠️ Failed to end HKWorkoutSession: \(error.localizedDescription)")
                            }
                        }
                    }
                }
        }
    }
}
