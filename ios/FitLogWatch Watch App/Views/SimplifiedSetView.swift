//
//  SimplifiedSetView.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Tab 1 (DEFAULT) - Simple set logging for beginners
//  🎯 Persona: Marco (principiante), Roberto (busy professional)
//

import SwiftUI

// MARK: - Simplified Set View (Tab 1 - DEFAULT for beginners)
// Minimal UI: Exercise name, Set X/Y, Weight×Reps, Complete button

struct SimplifiedSetView: View {
    @EnvironmentObject var connectivity: ConnectivityManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingEffortPicker = false
    @State private var showingConfirmation = false
    @State private var confirmationTask: Task<Void, Never>?
    @State private var showingQuickEdit = false  // 🆕 Tap-to-edit

    // Localized strings
    private var isItalian: Bool { connectivity.appLocale == "it" }
    private var setText: String { isItalian ? "Serie" : "Set" }
    private var doneText: String { isItalian ? "Fatto!" : "Done!" }
    private var tapToEditText: String { isItalian ? "tocca per modificare" : "tap to edit" }

    var body: some View {
        VStack(spacing: 6) {
            // Top bar: HR on left, exercise name always visible
            HStack {
                // Heart rate badge (top left)
                HStack(spacing: 3) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.red)
                    Text("\(Int(workoutManager.heartRate))")
                        .font(.system(size: 12, weight: .bold))
                        .monospacedDigit()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(isItalian ? "Frequenza cardiaca \(Int(workoutManager.heartRate))" : "Heart rate \(Int(workoutManager.heartRate))")

                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.top, 2)

            // Exercise name (always visible, compact)
            Text(connectivity.currentExerciseName)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)

            // Set indicator: "Set 2/4" or "Warmup" for warmup sets
            if connectivity.currentSetNumber - 1 >= 0 &&
               connectivity.currentSetNumber - 1 < connectivity.allSetsTargets.count &&
               connectivity.allSetsTargets[connectivity.currentSetNumber - 1].isWarmup {
                Text(isItalian ? "Riscaldamento" : "Warmup")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.orange)
            } else {
                Text("\(setText) \(connectivity.currentSetNumber)/\(connectivity.totalSets)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }

            // Weight × Reps (LARGE, TAPPABLE to edit)
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Text(formatWeight(connectivity.targetWeight))
                        .font(.system(size: 36, weight: .bold))
                    Text("×")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondary)
                    // ⌚ Show rep range if available
                    Text(connectivity.repsDisplay)
                        .font(.system(size: 36, weight: .bold))
                }

                // Hint text
                Text(tapToEditText)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            .onTapGesture {
                WKInterfaceDevice.current().play(.click)
                showingQuickEdit = true
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(isItalian ? "\(formatWeight(connectivity.targetWeight)) chili per \(connectivity.repsDisplay) ripetizioni" : "\(formatWeight(connectivity.targetWeight)) kg for \(connectivity.repsDisplay) reps")
            .accessibilityHint(isItalian ? "Tocca per modificare peso e ripetizioni" : "Tap to edit weight and reps")

            Spacer()

            // Complete set button (large, prominent)
            if showingConfirmation {
                // Confirmation state
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                    Text(doneText)
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.green)
                .accessibilityLabel(isItalian ? "Serie completata" : "Set completed")
            } else {
                Button(action: {
                    if connectivity.rpeTrackingEnabled {
                        showingEffortPicker = true
                    } else {
                        completeSet(effort: nil)
                    }
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isItalian ? "Completa serie" : "Complete set")
                .accessibilityHint(isItalian ? "Tocca due volte per completare la serie corrente" : "Double tap to complete current set")
            }

            Spacer()
                .frame(height: 8)
        }
        .padding(.horizontal, 8)
        .sheet(isPresented: $showingEffortPicker) {
            EffortPickerView(
                effortScale: connectivity.effortScale,
                locale: connectivity.appLocale,
                onSelect: { effort in
                    showingEffortPicker = false
                    completeSet(effort: effort)
                },
                onSkip: {
                    showingEffortPicker = false
                    completeSet(effort: nil)
                }
            )
        }
        .sheet(isPresented: $showingQuickEdit) {
            QuickEditSheetView(showCopyButtons: false)  // No copy buttons in simplified view
                .environmentObject(connectivity)
        }
    }

    // MARK: - Helper Methods

    private func completeSet(effort: Int?) {
        showConfirmation()
        connectivity.sendSetCompleted(effort: effort)
    }

    private func showConfirmation() {
        confirmationTask?.cancel()
        showingConfirmation = true
        WKInterfaceDevice.current().play(.success)

        confirmationTask = Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5 seconds
            if !Task.isCancelled {
                showingConfirmation = false
            }
        }
    }

    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.1f", weight)
        }
    }
}
