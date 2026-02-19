//
//  WorkoutSummaryView.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Post-workout summary screen
//

import SwiftUI

// MARK: - Workout Summary View (Post-Workout)

struct WorkoutSummaryView: View {
    @EnvironmentObject var connectivity: ConnectivityManager

    // Localized strings
    private var isItalian: Bool { connectivity.appLocale == "it" }
    private var completedText: String { isItalian ? "Completato!" : "Completed!" }
    private var discardedText: String { isItalian ? "Scartato" : "Discarded" }
    private var savedText: String { isItalian ? "Salvato" : "Saved" }
    private var setsLabel: String { isItalian ? "Serie" : "Sets" }
    private var timeLabel: String { isItalian ? "Tempo" : "Time" }
    private var caloriesLabel: String { "kcal" }
    private var doneText: String { isItalian ? "Fatto" : "Done" }
    private var checkPhoneText: String { isItalian ? "Controlla iPhone" : "Check iPhone" }

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            // Status icon and text
            VStack(spacing: 8) {
                Image(systemName: connectivity.lastWorkoutSaved ? "checkmark.circle.fill" : "trash.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(connectivity.lastWorkoutSaved ? .green : .orange)
                    .accessibilityHidden(true)

                Text(connectivity.lastWorkoutSaved ? completedText : discardedText)
                    .font(.system(size: 18, weight: .bold))
                    .accessibilityAddTraits(.isHeader)

                Text(connectivity.lastWorkoutSaved ? savedText : "")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(connectivity.lastWorkoutSaved ? (isItalian ? "Allenamento completato e salvato" : "Workout completed and saved") : (isItalian ? "Allenamento scartato" : "Workout discarded"))

            // Stats summary (only if saved)
            if connectivity.lastWorkoutSaved {
                HStack(spacing: 0) {
                    // Sets
                    VStack(spacing: 2) {
                        Text("\(connectivity.lastWorkoutSetsCompleted)")
                            .font(.system(size: 20, weight: .bold))
                            .monospacedDigit()
                        Text(setsLabel)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(isItalian ? "\(connectivity.lastWorkoutSetsCompleted) serie" : "\(connectivity.lastWorkoutSetsCompleted) sets")

                    Divider()
                        .frame(height: 30)
                        .accessibilityHidden(true)

                    // Duration
                    VStack(spacing: 2) {
                        Text(formatDuration(connectivity.lastWorkoutDuration))
                            .font(.system(size: 20, weight: .bold))
                            .monospacedDigit()
                        Text(timeLabel)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(isItalian ? "Durata: \(formatDuration(connectivity.lastWorkoutDuration))" : "Duration: \(formatDuration(connectivity.lastWorkoutDuration))")

                    Divider()
                        .frame(height: 30)
                        .accessibilityHidden(true)

                    // Calories
                    VStack(spacing: 2) {
                        Text("\(Int(connectivity.lastWorkoutCalories))")
                            .font(.system(size: 20, weight: .bold))
                            .monospacedDigit()
                        Text(caloriesLabel)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(isItalian ? "\(Int(connectivity.lastWorkoutCalories)) chilocalorie" : "\(Int(connectivity.lastWorkoutCalories)) kilocalories")
                }
                .padding(.horizontal, 8)
            }

            Spacer()

            // Hint to check iPhone
            Text(checkPhoneText)
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            // Done button
            Button(action: {
                WKInterfaceDevice.current().play(.click)
                connectivity.dismissWorkoutSummary()
            }) {
                Text(doneText)
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(.horizontal, 20)
            .accessibilityLabel(isItalian ? "Fatto, chiudi riepilogo" : "Done, dismiss summary")
            .accessibilityHint(isItalian ? "Tocca due volte per tornare alla schermata di attesa" : "Double tap to return to waiting screen")
        }
        .padding(.vertical, 8)
        // Auto-dismiss after 30 seconds - uses .task for automatic cancellation
        .task {
            try? await Task.sleep(nanoseconds: 30_000_000_000)  // 30 seconds
            if !Task.isCancelled && connectivity.showWorkoutSummary {
                connectivity.dismissWorkoutSummary()
            }
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
