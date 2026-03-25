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
    @State private var showingActualRepsPicker = false
    @State private var showingConfirmation = false
    @State private var confirmationTask: Task<Void, Never>?
    @State private var showingQuickEdit = false  // 🆕 Tap-to-edit
    @State private var showingSetPicker = false
    @State private var pendingActualReps: Int? = nil

    private var locale: String { connectivity.appLocale }
    private var setText: String { WatchStrings.setLabel(locale) }
    private var doneText: String { WatchStrings.done(locale) }
    private var tapToEditText: String { WatchStrings.tapToEdit(locale) }
    private var canEditTarget: Bool { connectivity.isWeightedMode }
    private var shouldAskActualReps: Bool {
        !connectivity.isTimeMode
    }

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
                .accessibilityLabel(
                    WatchStrings.localized(
                        locale,
                        it: "Frequenza cardiaca \(Int(workoutManager.heartRate))",
                        en: "Heart rate \(Int(workoutManager.heartRate))"
                    )
                )

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
            Button(action: {
                WKInterfaceDevice.current().play(.click)
                showingSetPicker = true
            }) {
                HStack(spacing: 4) {
                    if connectivity.currentSetNumber - 1 >= 0 &&
                        connectivity.currentSetNumber - 1 < connectivity.allSetsTargets.count &&
                        connectivity.allSetsTargets[connectivity.currentSetNumber - 1].isWarmup {
                        Text(WatchStrings.warmupLabel(locale))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.orange)
                    } else {
                        Text("\(setText) \(connectivity.currentSetNumber)/\(connectivity.totalSets)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.secondary.opacity(0.8))
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                WatchStrings.localized(
                    locale,
                    it: "Serie \(connectivity.currentSetNumber) di \(connectivity.totalSets)",
                    en: "Set \(connectivity.currentSetNumber) of \(connectivity.totalSets)"
                )
            )
            .accessibilityHint(
                WatchStrings.localized(
                    locale,
                    it: "Tocca per selezionare un'altra serie",
                    en: "Tap to select a different set"
                )
            )

            // Target (LARGE; editable only for weighted exercises)
            VStack(spacing: 2) {
                targetValueView

                if canEditTarget {
                    Text(tapToEditText)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                guard canEditTarget else { return }
                WKInterfaceDevice.current().play(.click)
                showingQuickEdit = true
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(targetAccessibilityLabel)
            .accessibilityHint(
                canEditTarget
                    ? WatchStrings.localized(
                        locale,
                        it: "Tocca per modificare peso e ripetizioni",
                        en: "Tap to edit weight and reps"
                    )
                    : ""
            )

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
                .accessibilityLabel(WatchStrings.localized(locale, it: "Serie completata", en: "Set completed"))
            } else {
                Button(action: {
                    if shouldAskActualReps {
                        pendingActualReps = nil
                        showingActualRepsPicker = true
                    } else if connectivity.rpeTrackingEnabled {
                        pendingActualReps = nil
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
                .accessibilityLabel(WatchStrings.completeSet(locale))
                .accessibilityHint(
                    WatchStrings.localized(
                        locale,
                        it: "Tocca due volte per completare la serie corrente",
                        en: "Double tap to complete current set"
                    )
                )
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
                    completeSet(effort: effort, actualReps: pendingActualReps)
                    pendingActualReps = nil
                },
                onSkip: {
                    showingEffortPicker = false
                    completeSet(effort: nil, actualReps: pendingActualReps)
                    pendingActualReps = nil
                }
            )
        }
        .sheet(isPresented: $showingActualRepsPicker) {
            ActualRepsPickerView(
                targetReps: connectivity.targetReps > 0
                    ? connectivity.targetReps
                    : (connectivity.minReps ?? connectivity.maxReps ?? 1),
                minReps: connectivity.minReps,
                maxReps: connectivity.maxReps,
                locale: connectivity.appLocale,
                onSelect: { reps in
                    showingActualRepsPicker = false
                    if connectivity.rpeTrackingEnabled {
                        pendingActualReps = reps
                        showingEffortPicker = true
                    } else {
                        completeSet(effort: nil, actualReps: reps)
                    }
                }
            )
        }
        .sheet(isPresented: $showingQuickEdit) {
            QuickEditSheetView(showCopyButtons: false)  // No copy buttons in simplified view
                .environmentObject(connectivity)
        }
        .sheet(isPresented: $showingSetPicker) {
            SetPickerSheetView(
                totalSets: connectivity.totalSets,
                currentSet: connectivity.currentSetNumber,
                locale: connectivity.appLocale,
                allSetsTargets: connectivity.allSetsTargets,
                onSelect: { setNumber in
                    showingSetPicker = false
                    connectivity.jumpToSet(setNumber)
                },
                onCancel: {
                    showingSetPicker = false
                }
            )
        }
    }

    // MARK: - Helper Methods

    private func completeSet(effort: Int?) {
        showConfirmation()
        connectivity.sendSetCompleted(effort: effort)
    }

    private func completeSet(effort: Int?, actualReps: Int?) {
        showConfirmation()
        connectivity.sendSetCompleted(effort: effort, actualReps: actualReps)
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

    @ViewBuilder
    private var targetValueView: some View {
        if !connectivity.hasDisplayTarget {
            Text("—")
                .font(.system(size: 36, weight: .medium))
                .foregroundColor(.secondary)
        } else if connectivity.isTimeMode {
            Text(formatDuration(connectivity.targetSeconds))
                .font(.system(size: 34, weight: .bold, design: .monospaced))
                .monospacedDigit()
        } else if connectivity.isRepsMode {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(connectivity.repsDisplay)
                    .font(.system(size: 36, weight: .bold))
                Text(WatchStrings.reps(locale))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        } else {
            HStack(spacing: 4) {
                Text(formatWeight(connectivity.targetWeight))
                    .font(.system(size: 36, weight: .bold))
                Text("×")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.secondary)
                Text(connectivity.repsDisplay)
                    .font(.system(size: 36, weight: .bold))
            }
        }
    }

    private var targetAccessibilityLabel: String {
        if !connectivity.hasDisplayTarget {
            return WatchStrings.localized(
                locale,
                it: "Nessun obiettivo impostato",
                en: "No target set"
            )
        }
        if connectivity.isTimeMode {
            return WatchStrings.localized(
                locale,
                it: "\(formatDuration(connectivity.targetSeconds)) durata target",
                en: "\(formatDuration(connectivity.targetSeconds)) target duration"
            )
        }
        if connectivity.isRepsMode {
            return WatchStrings.localized(
                locale,
                it: "\(connectivity.repsDisplay) ripetizioni",
                en: "\(connectivity.repsDisplay) reps"
            )
        }
        return WatchStrings.localized(
            locale,
            it: "\(formatWeight(connectivity.targetWeight)) chili per \(connectivity.repsDisplay) ripetizioni",
            en: "\(formatWeight(connectivity.targetWeight)) kg for \(connectivity.repsDisplay) reps"
        )
    }

    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 {
            return String(format: "%d:%02d", mins, secs)
        }
        return "\(secs)s"
    }

    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.1f", weight)
        }
    }
}
