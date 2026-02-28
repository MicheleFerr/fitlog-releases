//
//  StatsView.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Stats view (Tab 3) with HR, calories, duration, end workout
//

import SwiftUI

// MARK: - Stats View - Minimal Design with End Workout Button

struct StatsView: View {
    @EnvironmentObject var connectivity: ConnectivityManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingEndOptions = false

    private var locale: String { connectivity.appLocale }
    private var endWorkoutText: String { WatchStrings.end(locale) }
    private var confirmEndText: String { WatchStrings.confirmEnd(locale) }
    private var cancelText: String { WatchStrings.cancel(locale) }
    private var saveText: String { WatchStrings.save(locale) }
    private var discardText: String { WatchStrings.discard(locale) }
    private var kcalLabel: String { "kcal" }
    private var timeLabel: String { WatchStrings.time(locale) }
    private var setsLabel: String { WatchStrings.sets(locale) }

    var body: some View {
        VStack(spacing: 10) {
            // Heart Rate - Main focus (SF Pro, not rounded, for consistency)
            VStack(spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .accessibilityHidden(true)

                    Text("\(Int(workoutManager.heartRate))")
                        .font(.system(size: 32, weight: .bold))
                        .monospacedDigit()
                }

                Text("BPM")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(
                WatchStrings.localized(
                    locale,
                    it: "Frequenza cardiaca: \(Int(workoutManager.heartRate)) battiti per minuto",
                    en: "Heart rate: \(Int(workoutManager.heartRate)) beats per minute"
                )
            )

            // Heart rate zone badge
            Text(workoutManager.currentHeartRateZone.rawValue)
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(workoutManager.currentHeartRateZone.color.opacity(0.2))
                )
                .foregroundColor(workoutManager.currentHeartRateZone.color)
                .accessibilityLabel(
                    WatchStrings.localized(
                        locale,
                        it: "Zona di frequenza cardiaca: \(workoutManager.currentHeartRateZone.rawValue)",
                        en: "Heart rate zone: \(workoutManager.currentHeartRateZone.rawValue)"
                    )
                )

            Divider()
                .padding(.horizontal)
                .accessibilityHidden(true)

            // Stats row (using SF Pro, not rounded)
            HStack(spacing: 0) {
                // Calories
                StatItem(
                    value: "\(Int(workoutManager.activeCalories))",
                    label: kcalLabel
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    WatchStrings.localized(
                        locale,
                        it: "\(Int(workoutManager.activeCalories)) chilocalorie",
                        en: "\(Int(workoutManager.activeCalories)) kilocalories"
                    )
                )

                Divider()
                    .frame(height: 30)
                    .accessibilityHidden(true)

                // Duration - Native timer (battery efficient, no polling)
                VStack(spacing: 2) {
                    if let startDate = workoutManager.workoutStartDate {
                        Text(startDate, style: .timer)
                            .font(.system(size: 15, weight: .semibold))
                            .monospacedDigit()
                    } else {
                        Text("0:00")
                            .font(.system(size: 15, weight: .semibold))
                            .monospacedDigit()
                    }
                    Text(timeLabel)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(WatchStrings.localized(locale, it: "Durata allenamento", en: "Workout duration"))

                Divider()
                    .frame(height: 30)
                    .accessibilityHidden(true)

                // Sets
                StatItem(
                    value: "\(connectivity.setsCompleted)",
                    label: setsLabel
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    WatchStrings.localized(
                        locale,
                        it: "\(connectivity.setsCompleted) serie completate",
                        en: "\(connectivity.setsCompleted) sets completed"
                    )
                )
            }

            // End Workout Button
            Button(action: {
                WKInterfaceDevice.current().play(.click)
                showingEndOptions = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 10))
                    Text(endWorkoutText)
                        .font(.system(size: 13, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 36)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .accessibilityLabel(WatchStrings.endWorkout(locale))
            .accessibilityHint(
                WatchStrings.localized(
                    locale,
                    it: "Tocca due volte per terminare e salvare o scartare l'allenamento",
                    en: "Double tap to end and save or discard workout"
                )
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        // Save/Discard confirmation dialog
        .confirmationDialog(confirmEndText, isPresented: $showingEndOptions, titleVisibility: .visible) {
            // Save button (primary action) - SAVES to HealthKit
            Button(saveText) {
                WKInterfaceDevice.current().play(.success)
                connectivity.sendEndWorkout(
                    save: true,
                    duration: workoutManager.elapsedTime,
                    calories: workoutManager.activeCalories
                )
                // ✅ Save workout to HealthKit
                Task {
                    try? await workoutManager.endWorkout()
                }
            }
            // Discard button (destructive) - does NOT save to HealthKit
            Button(discardText, role: .destructive) {
                WKInterfaceDevice.current().play(.click)
                connectivity.sendEndWorkout(
                    save: false,
                    duration: workoutManager.elapsedTime,
                    calories: workoutManager.activeCalories
                )
                // ✅ Discard workout WITHOUT saving to HealthKit
                Task {
                    try? await workoutManager.discardWorkout()
                }
            }
            Button(cancelText, role: .cancel) { }
        }
    }
}

// MARK: - Stat Item Component

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .monospacedDigit()

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
