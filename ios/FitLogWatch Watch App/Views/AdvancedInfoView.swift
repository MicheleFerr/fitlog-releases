//
//  AdvancedInfoView.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Tab 0 - For power users: TUT, HR zone, form cues, exercise details
//  🎯 Persona: Luca (powerlifter), users who want detailed info
//

import SwiftUI

// MARK: - Advanced Info View (Tab 0 - For power users)

struct AdvancedInfoView: View {
    @EnvironmentObject var connectivity: ConnectivityManager
    @State private var showingQuickEdit = false
    @State private var showingFormCues = false
    @State private var selectedSetIndex: Int = 0
    @State private var showingSetPicker = false
    @State private var showingExercisePicker = false

    // Localized strings
    private var isItalian: Bool { connectivity.appLocale == "it" }
    private var tutLabel: String { "TUT" }
    private var noTutText: String { "-" }
    private var setText: String { isItalian ? "Serie" : "Set" }
    private var quickEditText: String { isItalian ? "Modifica" : "Edit" }
    private var selectSetText: String { isItalian ? "Seleziona Serie" : "Select Set" }
    private var changeExerciseText: String { isItalian ? "Cambia esercizio" : "Change exercise" }

    // Can change exercise only if we have the list
    private var canChangeExercise: Bool { connectivity.exerciseNames.count > 1 }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Top bar: TUT on left, Info icon on right
                HStack {
                    // TUT Badge (top left)
                    HStack(spacing: 3) {
                        Image(systemName: "timer")
                            .font(.system(size: 10))
                        if let tut = connectivity.tut, !tut.isEmpty {
                            Text(tut)
                                .font(.system(size: 11, weight: .bold))
                        } else {
                            Text(noTutText)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.blue)
                    .accessibilityLabel(isItalian ? "Tempo sotto tensione: \(connectivity.tut ?? noTutText)" : "Time under tension: \(connectivity.tut ?? noTutText)")

                    Spacer()

                    // Info icon (top right) for notes
                    Button(action: {
                        if connectivity.formCues != nil {
                            WKInterfaceDevice.current().play(.click)
                            showingFormCues = true
                        }
                    }) {
                        Image(systemName: connectivity.formCues != nil ? "info.circle.fill" : "info.circle")
                            .font(.system(size: 18))
                            .foregroundColor(connectivity.formCues != nil ? .yellow : .secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(connectivity.formCues == nil)
                    .accessibilityLabel(isItalian ? "Note forma" : "Form notes")
                    .accessibilityHint(connectivity.formCues != nil ? (isItalian ? "Tocca per vedere le note" : "Tap to view notes") : (isItalian ? "Nessuna nota disponibile" : "No notes available"))
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)

                Divider()

                // Current Exercise Card (tappable to select set)
                Button(action: {
                    WKInterfaceDevice.current().play(.click)
                    showingSetPicker = true
                }) {
                    VStack(spacing: 6) {
                        // Exercise name
                        Text(connectivity.currentExerciseName)
                            .font(.system(size: 14, weight: .bold))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)

                        // Set progress
                        Text("\(setText) \(connectivity.currentSetNumber)/\(connectivity.totalSets)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)

                        // Weight × Reps
                        HStack(spacing: 4) {
                            Text(formatWeight(connectivity.targetWeight))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            Text("×")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Text("\(connectivity.targetReps)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                        }

                        // Hint to tap
                        Text(isItalian ? "tocca per selezionare serie" : "tap to select set")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isItalian ? "Esercizio: \(connectivity.currentExerciseName), Serie \(connectivity.currentSetNumber) di \(connectivity.totalSets)" : "Exercise: \(connectivity.currentExerciseName), Set \(connectivity.currentSetNumber) of \(connectivity.totalSets)")
                .accessibilityHint(isItalian ? "Tocca per selezionare una serie da modificare" : "Tap to select a set to edit")

                // ✅ Action buttons on same row to fit in one screen
                HStack(spacing: 6) {
                    // Quick Edit Button
                    Button(action: {
                        WKInterfaceDevice.current().play(.click)
                        showingQuickEdit = true
                    }) {
                        VStack(spacing: 2) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14))
                            Text(quickEditText)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .accessibilityLabel(quickEditText)
                    .accessibilityHint(isItalian ? "Modifica peso e ripetizioni" : "Edit weight and reps")

                    // Change Exercise Button (only if we have multiple exercises)
                    if canChangeExercise {
                        Button(action: {
                            WKInterfaceDevice.current().play(.click)
                            showingExercisePicker = true
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.system(size: 14))
                                Text("\(connectivity.currentExerciseIndex + 1)/\(connectivity.totalExercises)")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                        .accessibilityLabel(changeExerciseText)
                        .accessibilityHint(isItalian ? "Vai a un altro esercizio" : "Go to another exercise")
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .sheet(isPresented: $showingFormCues) {
            FormCuesSheetView(
                exerciseName: connectivity.currentExerciseName,
                formCues: connectivity.formCues ?? "",
                locale: connectivity.appLocale,
                tut: connectivity.tut,  // ✅ Pass TUT for detailed view
                onDismiss: { showingFormCues = false }
            )
        }
        .sheet(isPresented: $showingQuickEdit) {
            QuickEditSheetView(showCopyButtons: false)  // No copy buttons - too cluttered
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
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerSheetView(
                exerciseNames: connectivity.exerciseNames,
                currentIndex: connectivity.currentExerciseIndex,
                locale: connectivity.appLocale,
                onSelect: { exerciseIndex in
                    showingExercisePicker = false
                    connectivity.jumpToExercise(exerciseIndex)
                },
                onCancel: {
                    showingExercisePicker = false
                }
            )
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
