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
                if connectivity.isSuperset || connectivity.isDropset || connectivity.isRestPause {
                    // Redirect advanced exercise types back to iPhone app
                    AdvancedExercisePhoneRedirectView()
                        .environmentObject(connectivity)
                } else {
                    // iPhone workout is active - show companion controls
                    WorkoutCompanionView()
                        .environmentObject(connectivity)
                        .environmentObject(workoutManager)
                }
            } else {
                // No active workout - show waiting screen
                WaitingView()
                    .environmentObject(connectivity)
            }
        }
    }
}

// MARK: - Phone Redirect View (Advanced Exercise Types)

private struct AdvancedExercisePhoneRedirectView: View {
    @EnvironmentObject var connectivity: ConnectivityManager

    private var isItalian: Bool { connectivity.appLocale == "it" }

    private var currentExerciseType: String {
        if connectivity.isSuperset { return "Superset" }
        if connectivity.isDropset { return "Dropset" }
        if connectivity.isRestPause { return "Rest-Pause" }
        return isItalian ? "Esercizio avanzato" : "Advanced exercise"
    }

    private var titleText: String {
        isItalian ? "Continua su iPhone" : "Continue on iPhone"
    }

    private var detailText: String {
        if isItalian {
            return "\(currentExerciseType) va gestito dall'app iPhone."
        }
        return "\(currentExerciseType) must be managed in the iPhone app."
    }

    private var hintText: String {
        isItalian
            ? "Apri FitLog su iPhone per continuare l'allenamento."
            : "Open FitLog on iPhone to continue your workout."
    }

    private var refreshText: String {
        isItalian ? "Aggiorna" : "Refresh"
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Circle()
                    .fill(connectivity.isReachable ? Color.green : Color.orange)
                    .frame(width: 6, height: 6)
                    .accessibilityHidden(true)
                Text(connectivity.isReachable ? WatchStrings.connected(connectivity.appLocale) : WatchStrings.waiting(connectivity.appLocale))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "iphone")
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(.blue)
                .accessibilityHidden(true)

            Text(titleText)
                .font(.system(size: 17, weight: .semibold))
                .multilineTextAlignment(.center)

            Text(detailText)
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            Text(hintText)
                .font(.system(size: 11))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Spacer()

            Button(refreshText) {
                connectivity.syncWorkoutStateFromiPhone(skipCache: true)
            }
            .buttonStyle(.bordered)
        }
        .padding()
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
