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

                    // Attempt to recover active workout session if app crashed
                    do {
                        try await workoutManager.recoverWorkoutSessionIfNeeded()
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
                        print("⌚ [APP] ScenePhase -> active, resyncing timer")
                        connectivityManager.resyncTimerOnForeground()

                        // Also check for pending workout state from iPhone
                        connectivityManager.checkPendingApplicationContext()
                    }
                }
        }
    }
}
