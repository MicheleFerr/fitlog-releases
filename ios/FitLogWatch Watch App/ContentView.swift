//
//  ContentView.swift
//  FitLogWatch Watch App
//
//  Watch Companion - Shows workout support when iPhone workout is active
//  Views extracted to Views/ folder (P1-1 audit split)
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivity: ConnectivityManager
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        Group {
            if connectivity.showWorkoutSummary {
                // Show workout summary after ending
                WorkoutSummaryView()
                    .environmentObject(connectivity)
            } else if connectivity.isWorkoutActive {
                // iPhone workout is active - show companion controls
                WorkoutCompanionView()
                    .environmentObject(connectivity)
                    .environmentObject(workoutManager)
            } else {
                // No active workout - show waiting screen
                WaitingView()
                    .environmentObject(connectivity)
            }
        }
    }
}

// MARK: - Safe Array Subscript Extension

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ContentView()
        .environmentObject(ConnectivityManager.shared)
}
