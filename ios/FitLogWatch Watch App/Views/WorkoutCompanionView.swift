//
//  WorkoutCompanionView.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Main workout companion with 4-tab structure
//

import SwiftUI

// MARK: - Workout Companion View (Active Workout)

struct WorkoutCompanionView: View {
    @EnvironmentObject var connectivity: ConnectivityManager
    @EnvironmentObject var workoutManager: WorkoutManager
    // 🆕 NEW 3-TAB STRUCTURE (simplified UX):
    // Tab 1: ExerciseControlView (superset/dropset/rest-pause) OR SimplifiedSetView (DEFAULT - set singoli)
    // Tab 2: RestTimerView (rest timer with Quick Add Time)
    // Tab 3: StatsView (HR, calories, duration, end workout)
    @State private var selectedTab = 1  // DEFAULT: Tab 1
    @State private var tabSwitchTask: Task<Void, Never>?

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Set view - ExerciseControlView per superset/dropset/rest-pause,
            // SimplifiedSetView per set normali (beginner-friendly)
            Group {
                if connectivity.isSuperset || connectivity.isDropset || connectivity.isRestPause {
                    ExerciseControlView()
                        .environmentObject(connectivity)
                        .environmentObject(workoutManager)
                } else {
                    SimplifiedSetView()
                        .environmentObject(connectivity)
                        .environmentObject(workoutManager)
                }
            }
            .tag(1)

            // Tab 2: Rest Timer (mirrors Live Activity)
            RestTimerView()
                .environmentObject(connectivity)
                .tag(2)

            // Tab 3: Heart Rate & Stats
            StatsView()
                .environmentObject(connectivity)
                .environmentObject(workoutManager)
                .tag(3)
        }
        .tabViewStyle(.verticalPage)
        .onAppear {
            // ⌚ NOTE: HKWorkoutSession is now auto-started at app level (FitLogWatchApp.swift)
            // when connectivity.isWorkoutActive becomes true. This ensures the session
            // starts even if Watch app was in background when iPhone workout started.
            // See BUG FIX #4 in FitLogWatchApp.swift

            // Check if timer should be showing on appear
            if connectivity.shouldShowTimer && selectedTab != 2 {
                withAnimation {
                    selectedTab = 2  // Timer is now Tab 2
                }
                resetTimerFlagTask()
            }
        }
        .onDisappear {
            // Cancel any pending tab switch tasks
            tabSwitchTask?.cancel()
            tabSwitchTask = nil

            // ✅ DO NOT auto-save workout here!
            // User must explicitly choose "Save" or "Discard" in the confirmation dialog.
            // If app is closed during workout, session can be recovered via recoverWorkoutSessionIfNeeded()
        }
        // Auto-navigate to timer tab when timer starts
        .onChange(of: connectivity.shouldShowTimer) { _, shouldShow in
            if shouldShow && selectedTab != 2 {
                withAnimation {
                    selectedTab = 2  // Timer is now Tab 2
                }
                resetTimerFlagTask()
            }
        }
        // Also monitor restTimeRemaining directly for more reliable navigation
        .onChange(of: connectivity.restTimeRemaining) { oldValue, newValue in
            if oldValue == 0 && newValue > 0 && selectedTab != 2 {
                withAnimation {
                    selectedTab = 2  // Timer is now Tab 2
                }
            }
        }
        // Auto-navigate to simplified set view when timer ends
        .onChange(of: connectivity.shouldNavigateToExercise) { _, shouldNavigate in
            if shouldNavigate && selectedTab != 1 {
                withAnimation {
                    selectedTab = 1  // SimplifiedSetView is Tab 1 (DEFAULT)
                }
                resetExerciseFlagTask()
            }
        }
    }

    // MARK: - Helper Methods

    private func resetTimerFlagTask() {
        tabSwitchTask?.cancel()
        tabSwitchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds
            if !Task.isCancelled {
                connectivity.shouldShowTimer = false
            }
        }
    }

    private func resetExerciseFlagTask() {
        tabSwitchTask?.cancel()
        tabSwitchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds
            if !Task.isCancelled {
                connectivity.shouldNavigateToExercise = false
            }
        }
    }
}
