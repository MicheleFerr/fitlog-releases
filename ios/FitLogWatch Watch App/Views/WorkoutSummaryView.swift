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

    private var locale: String { connectivity.appLocale }
    private var completedText: String { WatchStrings.completed(locale) }
    private var discardedText: String { WatchStrings.discarded(locale) }
    private var savedText: String { WatchStrings.saved(locale) }
    private var setsLabel: String { WatchStrings.localized(locale, it: "Serie", en: "Sets") }
    private var timeLabel: String { WatchStrings.localized(locale, it: "Tempo", en: "Time") }
    private var caloriesLabel: String { "kcal" }
    private var doneText: String { WatchStrings.localized(locale, it: "Fatto", en: "Done") }
    private var checkPhoneText: String { WatchStrings.checkPhone(locale) }

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
            .accessibilityLabel(
                connectivity.lastWorkoutSaved
                    ? WatchStrings.localized(locale, it: "Allenamento completato e salvato", en: "Workout completed and saved")
                    : WatchStrings.localized(locale, it: "Allenamento scartato", en: "Workout discarded")
            )

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
                    .accessibilityLabel(
                        WatchStrings.localized(
                            locale,
                            it: "\(connectivity.lastWorkoutSetsCompleted) serie",
                            en: "\(connectivity.lastWorkoutSetsCompleted) sets"
                        )
                    )

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
                    .accessibilityLabel(
                        WatchStrings.localized(
                            locale,
                            it: "Durata: \(formatDuration(connectivity.lastWorkoutDuration))",
                            en: "Duration: \(formatDuration(connectivity.lastWorkoutDuration))"
                        )
                    )

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
                    .accessibilityLabel(
                        WatchStrings.localized(
                            locale,
                            it: "\(Int(connectivity.lastWorkoutCalories)) chilocalorie",
                            en: "\(Int(connectivity.lastWorkoutCalories)) kilocalories"
                        )
                    )
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
            .accessibilityLabel(WatchStrings.localized(locale, it: "Fatto, chiudi riepilogo", en: "Done, dismiss summary"))
            .accessibilityHint(
                WatchStrings.localized(
                    locale,
                    it: "Tocca due volte per tornare alla schermata di attesa",
                    en: "Double tap to return to waiting screen"
                )
            )
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
