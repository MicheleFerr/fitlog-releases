//
//  ExerciseControlView.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Main exercise control with set completion, superset/dropset/rest-pause support
//

import SwiftUI

// MARK: - Exercise Control View - Minimal Design

struct ExerciseControlView: View {
    @EnvironmentObject var connectivity: ConnectivityManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingEffortPicker = false
    @State private var showingConfirmation = false
    @State private var confirmationTask: Task<Void, Never>?
    @State private var showingFormCues = false
    @State private var showingEditReps = false  // ✅ Edit completed set reps

    // ✅ NEW: Track which set the user is currently viewing (1-indexed)
    // nil means viewing the current set (next to do)
    @State private var viewingSetNumber: Int? = nil

    // ✅ NEW: Inline edit target (weight/reps) before completing set
    @State private var isEditingTarget = false
    @State private var editingWeight: Double = 0
    @State private var editingReps: Int = 1
    @State private var editingField: TargetEditField = .weight
    @State private var crownValue: Double = 0
    @FocusState private var isTargetEditorFocused: Bool

    // 🔥 SUPERSET: Local navigation within round (1-indexed)
    // Allows user to navigate between exercises locally before completing the round
    @State private var localExerciseIndex: Int = 1

    // 🔥 SUPERSET AUTO-ADVANCE (Hevy pattern): Track confirmed exercises in current round
    // Set<Int> contains 1-indexed exercise numbers that have been confirmed
    @State private var confirmedExercisesInRound: Set<Int> = []

    enum TargetEditField {
        case weight
        case reps
    }

    // Localized strings (from Flutter app)
    private var isItalian: Bool { connectivity.appLocale == "it" }
    private var setText: String { isItalian ? "Serie" : "Set" }
    private var ofText: String { isItalian ? "di" : "of" }
    private var completeText: String { isItalian ? "Completo" : "Complete" }
    private var doneText: String { isItalian ? "Fatto!" : "Done!" }
    private var repsText: String { isItalian ? "rip" : "reps" }
    private var formCuesTitle: String { isItalian ? "Form Cues" : "Form Cues" }
    private var noFormCuesText: String { isItalian ? "Nessuna nota" : "No notes" }
    private var editLastSetText: String { isItalian ? "Modifica" : "Edit" }
    private var editTargetText: String { isItalian ? "Modifica target" : "Edit target" }
    private var confirmTargetText: String { isItalian ? "OK" : "OK" }
    private var cancelEditText: String { isItalian ? "Annulla" : "Cancel" }
    // 🔥 SUPERSET: New localized strings
    private var confirmExerciseText: String { isItalian ? "Conferma" : "Confirm" }
    private var completeRoundText: String { isItalian ? "Completa Round" : "Complete Round" }

    // 🔻 DROPSET: Localized strings
    private var stageText: String { isItalian ? "Stage" : "Stage" }
    private var nextText: String { isItalian ? "Prossimo" : "Next" }

    // 💪 REST-PAUSE: Localized strings
    private var restPauseSetText: String { isItalian ? "Set" : "Set" }

    // 🔻 DROPSET: Computed properties for sliding window

    /// Current dropset stage (1-indexed for display)
    private var currentDropsetStageDisplay: Int {
        connectivity.currentDropsetStage + 1
    }

    /// Visible stages for sliding window (max 3, centered on current)
    private var visibleDropsetStages: [(index: Int, weight: Double, reps: Int, isCompleted: Bool)] {
        let stages = connectivity.dropsetStages
        let current = connectivity.currentDropsetStage  // 0-indexed
        let total = stages.count

        guard total > 0 else { return [] }

        // Calculate window: show [previous, current, next] when possible
        let windowStart: Int
        let windowEnd: Int

        if total <= 3 {
            // Show all if 3 or fewer
            windowStart = 0
            windowEnd = total
        } else {
            // Sliding window: keep current visible with context
            windowStart = max(0, min(current - 1, total - 3))
            windowEnd = min(total, windowStart + 3)
        }

        return (windowStart..<windowEnd).map { i in
            (index: i, weight: stages[i].weight, reps: stages[i].reps, isCompleted: stages[i].isCompleted)
        }
    }

    /// Is current stage the last one?
    private var isLastDropsetStage: Bool {
        connectivity.currentDropsetStage >= connectivity.totalDropsetStages - 1
    }

    // 💪 REST-PAUSE: Computed properties for sliding window

    /// Current rest-pause set (1-indexed for display)
    private var currentRestPauseSetDisplay: Int {
        connectivity.currentRestPauseSet + 1
    }

    /// Visible rest-pause sets for sliding window (max 3, centered on current)
    private var visibleRestPauseSets: [(index: Int, reps: Int, restSeconds: Int, isCompleted: Bool)] {
        let sets = connectivity.restPauseSets
        let current = connectivity.currentRestPauseSet  // 0-indexed
        let total = sets.count

        guard total > 0 else { return [] }

        // Calculate window: show [previous, current, next] when possible
        let windowStart: Int
        let windowEnd: Int

        if total <= 3 {
            // Show all if 3 or fewer
            windowStart = 0
            windowEnd = total
        } else {
            // Sliding window: keep current visible with context
            windowStart = max(0, min(current - 1, total - 3))
            windowEnd = min(total, windowStart + 3)
        }

        return (windowStart..<windowEnd).map { i in
            (index: i, reps: sets[i].reps, restSeconds: sets[i].restSeconds, isCompleted: sets[i].isCompleted)
        }
    }

    /// Is current rest-pause set the last one?
    private var isLastRestPauseSet: Bool {
        connectivity.currentRestPauseSet >= connectivity.totalRestPauseSets - 1
    }

    // ✅ Computed: The set number being displayed (1-indexed)
    private var displayedSetNumber: Int {
        viewingSetNumber ?? connectivity.currentSetNumber
    }

    // ✅ Computed: Is the displayed set a completed one?
    private var isViewingCompletedSet: Bool {
        displayedSetNumber <= connectivity.setsCompletedInExercise
    }

    // ✅ Computed: Is viewing the current set (next to do)?
    private var isViewingCurrentSet: Bool {
        viewingSetNumber == nil || viewingSetNumber == connectivity.currentSetNumber
    }

    // ✅ Computed: Can navigate to previous set?
    private var canGoToPreviousSet: Bool {
        displayedSetNumber > 1
    }

    // ✅ Computed: Can navigate to next set?
    private var canGoToNextSet: Bool {
        displayedSetNumber < connectivity.totalSets
    }

    // 🔥 SUPERSET: Computed properties for round-based navigation

    /// Current exercise name in superset (uses local index for navigation)
    private var currentSupersetExerciseName: String {
        let index = localExerciseIndex - 1 // 0-indexed
        if index >= 0 && index < connectivity.supersetExercises.count {
            return connectivity.supersetExercises[index]
        }
        return connectivity.currentExerciseName
    }

    /// Is current exercise already confirmed in this round?
    private var isCurrentExerciseConfirmed: Bool {
        confirmedExercisesInRound.contains(localExerciseIndex)
    }

    /// Are ALL exercises confirmed in current round? (Hevy: shows "Complete Round" button)
    private var allExercisesConfirmedInRound: Bool {
        confirmedExercisesInRound.count >= connectivity.totalExercisesInSuperset
    }

    /// Compact superset header text: "SS Ex 1/3 • R1/3"
    private var compactSupersetHeader: String {
        let exPart = "SS Ex \(localExerciseIndex)/\(connectivity.totalExercisesInSuperset)"
        if connectivity.totalSupersetRounds > 1 {
            return "\(exPart) • R\(connectivity.supersetRound)/\(connectivity.totalSupersetRounds)"
        }
        return exPart
    }

    // ✅ FIX: Get weight for the displayed set (from allSetsTargets or fallback to current)
    private var displayedTargetWeight: Double {
        let setIndex = displayedSetNumber - 1 // 0-indexed
        if setIndex >= 0 && setIndex < connectivity.allSetsTargets.count {
            return connectivity.allSetsTargets[setIndex].weight
        }
        // Fallback to current set's target
        return connectivity.targetWeight
    }

    // ✅ FIX: Get reps for the displayed set (from allSetsTargets or fallback to current)
    private var displayedTargetReps: Int {
        let setIndex = displayedSetNumber - 1 // 0-indexed
        if setIndex >= 0 && setIndex < connectivity.allSetsTargets.count {
            return connectivity.allSetsTargets[setIndex].reps
        }
        // Fallback to current set's target
        return connectivity.targetReps
    }

    // MARK: - 🔥 Superset Header View
    /// Compact header showing superset name and round progress
    /// Design: Orange theme (matches Flutter app's secondaryOrange), glanceable info per Apple Watch HIG
    @ViewBuilder
    private var supersetHeaderView: some View {
        VStack(spacing: 2) {
            // Superset name with icon
            HStack(spacing: 4) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
                    .accessibilityHidden(true)

                Text(connectivity.supersetName ?? "Superset")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.orange)
                    .lineLimit(1)
            }

            // Round progress (only if multiple rounds)
            if connectivity.totalSupersetRounds > 1 {
                Text(isItalian ? "Round \(connectivity.supersetRound)/\(connectivity.totalSupersetRounds)" : "Round \(connectivity.supersetRound)/\(connectivity.totalSupersetRounds)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.orange.opacity(0.8))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.15))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isItalian ? "Superset: \(connectivity.supersetName ?? "Superset"), Round \(connectivity.supersetRound) di \(connectivity.totalSupersetRounds)" : "Superset: \(connectivity.supersetName ?? "Superset"), Round \(connectivity.supersetRound) of \(connectivity.totalSupersetRounds)")
    }

    var body: some View {
        VStack(spacing: 10) {
            // 🔥 SUPERSET: Compact header "SS Ex 1/3 • R1/3" - LEFT ALIGNED to avoid clock overlap
            if connectivity.isSuperset {
                Text(compactSupersetHeader)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)  // ✅ Left align to avoid clock
                    .padding(.leading, 4)
                    .accessibilityLabel(isItalian
                        ? "Superset: Esercizio \(localExerciseIndex) di \(connectivity.totalExercisesInSuperset), Round \(connectivity.supersetRound) di \(connectivity.totalSupersetRounds)"
                        : "Superset: Exercise \(localExerciseIndex) of \(connectivity.totalExercisesInSuperset), Round \(connectivity.supersetRound) of \(connectivity.totalSupersetRounds)")
            }

            // 🔻 DROPSET: Compact header "D3/5" - Purple theme
            if connectivity.isDropset {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.purple)
                        .accessibilityHidden(true)
                    Text("D\(currentDropsetStageDisplay)/\(connectivity.totalDropsetStages)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
                .accessibilityLabel(isItalian
                    ? "Dropset: Stage \(currentDropsetStageDisplay) di \(connectivity.totalDropsetStages)"
                    : "Dropset: Stage \(currentDropsetStageDisplay) of \(connectivity.totalDropsetStages)")
            }

            // 💪 REST-PAUSE: Compact header "RP 2/4" - Cyan theme
            if connectivity.isRestPause {
                HStack(spacing: 6) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.cyan)
                        .accessibilityHidden(true)
                    Text("RP \(currentRestPauseSetDisplay)/\(connectivity.totalRestPauseSets)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.cyan)
                    Text("• \(formatWeight(connectivity.restPauseWeight))kg")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.cyan.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
                .accessibilityLabel(isItalian
                    ? "Rest-Pause: Set \(currentRestPauseSetDisplay) di \(connectivity.totalRestPauseSets), \(formatWeight(connectivity.restPauseWeight)) chili"
                    : "Rest-Pause: Set \(currentRestPauseSetDisplay) of \(connectivity.totalRestPauseSets), \(formatWeight(connectivity.restPauseWeight)) kg")
            }

            // Top bar with HR badge, TUT badge, and Form Cues button
            HStack {
                // Heart Rate badge (top-left)
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.red)
                        .accessibilityHidden(true)
                    Text("\(Int(workoutManager.heartRate))")
                        .font(.system(size: 13, weight: .semibold))
                        .monospacedDigit()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.15))
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel(isItalian ? "Frequenza cardiaca: \(Int(workoutManager.heartRate)) battiti per minuto" : "Heart rate: \(Int(workoutManager.heartRate)) beats per minute")

                Spacer()

                // TUT badge (Time Under Tension) - show if available
                if let tut = connectivity.tut, !tut.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "timer")
                            .font(.system(size: 9))
                            .foregroundColor(.orange)
                            .accessibilityHidden(true)
                        Text(tut)
                            .font(.system(size: 11, weight: .medium))
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.15))
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(isItalian ? "Tempo sotto tensione: \(tut)" : "Time under tension: \(tut)")
                }

                // Form Cues button (top-right) - only show if has form cues
                if let formCues = connectivity.formCues, !formCues.isEmpty {
                    Button(action: {
                        WKInterfaceDevice.current().play(.click)
                        showingFormCues = true
                    }) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isItalian ? "Mostra note sulla forma" : "Show form cues")
                    .accessibilityHint(isItalian ? "Tocca per vedere i promemoria sulla tecnica" : "Tap to view technique reminders")
                }
            }
            .padding(.horizontal, 4)

            // Exercise name (for superset: uses local navigation index)
            Text(connectivity.isSuperset ? currentSupersetExerciseName : connectivity.currentExerciseName)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(isItalian
                    ? "Esercizio: \(connectivity.isSuperset ? currentSupersetExerciseName : connectivity.currentExerciseName)"
                    : "Exercise: \(connectivity.isSuperset ? currentSupersetExerciseName : connectivity.currentExerciseName)")

            // 🔥 SUPERSET: Exercise navigation with back/forward arrows (Hevy-like pattern)
            if connectivity.isSuperset {
                HStack(spacing: 8) {
                    // Previous exercise arrow
                    Button(action: {
                        WKInterfaceDevice.current().play(.click)
                        if localExerciseIndex > 1 {
                            localExerciseIndex -= 1
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(localExerciseIndex > 1 ? .orange : .gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(localExerciseIndex <= 1)
                    .accessibilityLabel(isItalian ? "Esercizio precedente" : "Previous exercise")

                    // Exercise progress dots - shows CONFIRMED state (Hevy pattern)
                    HStack(spacing: 6) {
                        ForEach(1...connectivity.totalExercisesInSuperset, id: \.self) { index in
                            let isConfirmed = confirmedExercisesInRound.contains(index)
                            let isCurrent = index == localExerciseIndex
                            Circle()
                                .fill(isConfirmed ? Color.green :
                                      isCurrent ? Color.orange : Color.gray.opacity(0.3))
                                .frame(width: isCurrent ? 10 : 8,
                                       height: isCurrent ? 10 : 8)
                                .overlay(
                                    // Checkmark for CONFIRMED exercises (not just visited)
                                    isConfirmed ?
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 6, weight: .bold))
                                        .foregroundColor(.white) : nil
                                )
                        }
                    }
                    .accessibilityLabel(isItalian
                        ? "Esercizio \(localExerciseIndex) di \(connectivity.totalExercisesInSuperset), \(confirmedExercisesInRound.count) confermati"
                        : "Exercise \(localExerciseIndex) of \(connectivity.totalExercisesInSuperset), \(confirmedExercisesInRound.count) confirmed")

                    // Next exercise arrow
                    Button(action: {
                        WKInterfaceDevice.current().play(.click)
                        if localExerciseIndex < connectivity.totalExercisesInSuperset {
                            localExerciseIndex += 1
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(localExerciseIndex < connectivity.totalExercisesInSuperset ? .orange : .gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(localExerciseIndex >= connectivity.totalExercisesInSuperset)
                    .accessibilityLabel(isItalian ? "Esercizio successivo" : "Next exercise")
                }
            }

            // 🔻 DROPSET: Sliding window stage list
            if connectivity.isDropset {
                VStack(spacing: 4) {
                    ForEach(visibleDropsetStages, id: \.index) { stage in
                        let isCurrent = stage.index == connectivity.currentDropsetStage
                        let stageNumber = stage.index + 1  // 1-indexed for display

                        HStack(spacing: 8) {
                            // Stage indicator (D1, D2, D3...)
                            Text("D\(stageNumber)")
                                .font(.system(size: isCurrent ? 14 : 11, weight: .bold, design: .rounded))
                                .foregroundColor(stage.isCompleted ? .green : (isCurrent ? .purple : .secondary))
                                .frame(width: 28, alignment: .leading)

                            // Weight × Reps
                            Text("\(formatWeight(stage.weight))kg × \(stage.reps)")
                                .font(.system(size: isCurrent ? 15 : 12, weight: isCurrent ? .semibold : .regular))
                                .foregroundColor(stage.isCompleted ? .green.opacity(0.7) : (isCurrent ? .primary : .secondary))

                            Spacer()

                            // Status indicator
                            if stage.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                            } else if isCurrent {
                                Circle()
                                    .fill(Color.purple)
                                    .frame(width: 8, height: 8)
                            } else {
                                Circle()
                                    .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, isCurrent ? 6 : 3)
                        .background(
                            isCurrent ?
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.purple.opacity(0.15)) : nil
                        )
                    }
                }
                .padding(.horizontal, 4)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(isItalian
                    ? "Stage \(currentDropsetStageDisplay) di \(connectivity.totalDropsetStages)"
                    : "Stage \(currentDropsetStageDisplay) of \(connectivity.totalDropsetStages)")
            }

            // 💪 REST-PAUSE: Sliding window set list
            if connectivity.isRestPause {
                VStack(spacing: 4) {
                    ForEach(visibleRestPauseSets, id: \.index) { set in
                        let isCurrent = set.index == connectivity.currentRestPauseSet
                        let setNumber = set.index + 1  // 1-indexed for display

                        HStack(spacing: 8) {
                            // Set indicator (S1, S2, S3...)
                            Text("S\(setNumber)")
                                .font(.system(size: isCurrent ? 14 : 11, weight: .bold, design: .rounded))
                                .foregroundColor(set.isCompleted ? .green : (isCurrent ? .cyan : .secondary))
                                .frame(width: 28, alignment: .leading)

                            // Target reps
                            Text("\(set.reps) \(repsText)")
                                .font(.system(size: isCurrent ? 15 : 12, weight: isCurrent ? .semibold : .regular))
                                .foregroundColor(set.isCompleted ? .green.opacity(0.7) : (isCurrent ? .primary : .secondary))

                            // Rest indicator (not for last set)
                            if set.index < connectivity.totalRestPauseSets - 1 {
                                Text("→ \(set.restSeconds)s")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary.opacity(0.7))
                            }

                            Spacer()

                            // Status indicator
                            if set.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                            } else if isCurrent {
                                Circle()
                                    .fill(Color.cyan)
                                    .frame(width: 8, height: 8)
                            } else {
                                Circle()
                                    .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, isCurrent ? 6 : 3)
                        .background(
                            isCurrent ?
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.cyan.opacity(0.15)) : nil
                        )
                    }
                }
                .padding(.horizontal, 4)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(isItalian
                    ? "Set \(currentRestPauseSetDisplay) di \(connectivity.totalRestPauseSets)"
                    : "Set \(currentRestPauseSetDisplay) of \(connectivity.totalRestPauseSets)")
            }

            // ✅ Set counter with navigation arrows - HIDDEN for supersets/dropsets/rest-pause
            if !connectivity.isSuperset && !connectivity.isDropset && !connectivity.isRestPause {
                HStack(spacing: 4) {
                    // Previous set arrow - larger tap target (44pt minimum per HIG)
                    Button(action: {
                        WKInterfaceDevice.current().play(.click)
                        if canGoToPreviousSet {
                            viewingSetNumber = displayedSetNumber - 1
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(canGoToPreviousSet ? .blue : .gray.opacity(0.3))
                            .frame(width: 44, height: 44)  // HIG minimum tap target
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!canGoToPreviousSet)
                    .accessibilityLabel(isItalian ? "Serie precedente" : "Previous set")

                    // Set number display
                    VStack(spacing: 0) {
                        HStack(spacing: 4) {
                            Text(setText)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text("\(displayedSetNumber)")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(isViewingCompletedSet ? .green : .primary)
                            Text("\(ofText) \(connectivity.totalSets)")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        // ✅ Completed indicator
                        if isViewingCompletedSet {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                        }
                    }

                    // Next set arrow - larger tap target (44pt minimum per HIG)
                    Button(action: {
                        WKInterfaceDevice.current().play(.click)
                        if canGoToNextSet {
                            viewingSetNumber = displayedSetNumber + 1
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(canGoToNextSet ? .blue : .gray.opacity(0.3))
                            .frame(width: 44, height: 44)  // HIG minimum tap target
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!canGoToNextSet)
                    .accessibilityLabel(isItalian ? "Serie successiva" : "Next set")
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(isItalian ? "Serie \(displayedSetNumber) di \(connectivity.totalSets)\(isViewingCompletedSet ? ", completata" : "")" : "Set \(displayedSetNumber) of \(connectivity.totalSets)\(isViewingCompletedSet ? ", completed" : "")")
            }

            // Target info (tappable to edit) - ✅ FIX: Use displayedTarget for correct set
            // HIDDEN for dropset/rest-pause (they show weight/reps inline in stage list)
            if displayedTargetWeight > 0 && !connectivity.isDropset && !connectivity.isRestPause {
                if isEditingTarget {
                    // ✅ EDIT MODE: Crown-controlled target editing
                    targetEditView
                } else {
                    // ✅ DISPLAY MODE: Tappable to enter edit mode
                    HStack(spacing: 6) {
                        Text("\(String(format: "%.1f", displayedTargetWeight)) kg")
                            .font(.system(size: 12, weight: .medium))
                        Text("×")
                            .foregroundColor(.secondary)
                        Text("\(displayedTargetReps) \(repsText)")
                            .font(.system(size: 12, weight: .medium))
                        // ✅ Pencil icon hint for edit (only for current set)
                        if isViewingCurrentSet {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue.opacity(0.7))
                        }
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .onTapGesture {
                        // ✅ Only allow editing current set's target
                        if isViewingCurrentSet {
                            enterTargetEditMode()
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(isItalian ? "Obiettivo: \(String(format: "%.1f", displayedTargetWeight)) chilogrammi per \(displayedTargetReps) ripetizioni\(isViewingCurrentSet ? ". Tocca per modificare" : "")" : "Target: \(String(format: "%.1f", displayedTargetWeight)) kilograms for \(displayedTargetReps) reps\(isViewingCurrentSet ? ". Tap to edit" : "")")
                    .accessibilityHint(isViewingCurrentSet ? (isItalian ? "Tocca per modificare peso o ripetizioni" : "Tap to edit weight or reps") : "")
                }
            }

            Spacer()

            // ✅ Buttons Row: Context-sensitive based on viewed set
            buttonsRow
        }
        // ✅ Reset viewing state when workout updates
        .onChange(of: connectivity.currentSetNumber) { _, _ in
            viewingSetNumber = nil
            // Also exit edit mode when set changes
            isEditingTarget = false
            isTargetEditorFocused = false
        }
        // ✅ FIX: Also reset when exercise changes (even if set number stays same)
        .onChange(of: connectivity.currentExerciseName) { _, _ in
            viewingSetNumber = nil
            // Also exit edit mode when exercise changes
            isEditingTarget = false
            isTargetEditorFocused = false
        }
        // 🔥 SUPERSET: Reset local state when round changes or superset mode changes
        .onChange(of: connectivity.supersetRound) { _, _ in
            localExerciseIndex = 1
            confirmedExercisesInRound.removeAll()  // Reset confirmations for new round
        }
        .onChange(of: connectivity.isSuperset) { _, newValue in
            if newValue {
                // Entering superset: reset to first exercise and clear confirmations
                localExerciseIndex = 1
                confirmedExercisesInRound.removeAll()
            }
        }
        .padding()
        .sheet(isPresented: $showingEffortPicker) {
            EffortPickerView(
                effortScale: connectivity.effortScale,
                locale: connectivity.appLocale,
                onSelect: { effort in
                    showingEffortPicker = false
                    // Handle based on exercise type
                    if connectivity.isSuperset {
                        completeSupersetRound(effort: effort)
                    } else if connectivity.isDropset {
                        // 🔻 DROPSET: Complete with effort
                        if isLastDropsetStage {
                            completeDropset(effort: effort)
                        } else {
                            completeDropsetStage(effort: effort)
                        }
                    } else if connectivity.isRestPause {
                        // 💪 REST-PAUSE: Complete with effort
                        if isLastRestPauseSet {
                            completeRestPause(effort: effort)
                        } else {
                            completeRestPauseSet(effort: effort)
                        }
                    } else {
                        completeSet(effort: effort)
                    }
                },
                onSkip: {
                    showingEffortPicker = false
                    // Handle based on exercise type
                    if connectivity.isSuperset {
                        completeSupersetRound(effort: nil)
                    } else if connectivity.isDropset {
                        // 🔻 DROPSET: Complete without effort
                        if isLastDropsetStage {
                            completeDropset(effort: nil)
                        } else {
                            completeDropsetStage(effort: nil)
                        }
                    } else if connectivity.isRestPause {
                        // 💪 REST-PAUSE: Complete without effort
                        if isLastRestPauseSet {
                            completeRestPause(effort: nil)
                        } else {
                            completeRestPauseSet(effort: nil)
                        }
                    } else {
                        completeSet(effort: nil)
                    }
                }
            )
        }
        .sheet(isPresented: $showingFormCues) {
            FormCuesSheetView(
                exerciseName: connectivity.currentExerciseName,
                formCues: connectivity.formCues ?? "",
                locale: connectivity.appLocale,
                tut: connectivity.tut,  // ✅ Pass TUT for detailed view
                onDismiss: {
                    showingFormCues = false
                }
            )
        }
        // ✅ Edit Completed Set Reps Sheet (with set navigation)
        .sheet(isPresented: $showingEditReps) {
            EditRepsSheetView(
                // ✅ FIX: Use sets completed in CURRENT EXERCISE (not total workout)
                setsCompleted: connectivity.setsCompletedInExercise,
                // ✅ FIX: Use actual reps of last completed set (not target reps)
                initialReps: connectivity.lastCompletedReps > 0 ? connectivity.lastCompletedReps : connectivity.targetReps,
                // ✅ NEW: Pass actual reps for each set (for navigation between sets)
                setsActualReps: connectivity.allSetsTargets.map { $0.actualReps },
                locale: connectivity.appLocale,
                onConfirm: { setIndex, newReps in
                    showingEditReps = false
                    // Send edit to iPhone with the specific set index (0-indexed)
                    connectivity.sendEditCompletedSetReps(setIndex: setIndex, reps: newReps)
                },
                onCancel: {
                    showingEditReps = false
                }
            )
        }
    }

    // MARK: - Buttons Row (extracted for readability)

    @ViewBuilder
    private var buttonsRow: some View {
        HStack(spacing: 8) {
            if isViewingCompletedSet {
                // ✅ VIEWING COMPLETED SET: Show Undo button
                Button(action: {
                    WKInterfaceDevice.current().play(.click)
                    // Uncomplete this set (0-indexed)
                    connectivity.sendUncompleteSet(setIndex: displayedSetNumber - 1)
                    // Reset to view current set
                    viewingSetNumber = nil
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.uturn.backward")
                        Text(isItalian ? "Annulla" : "Undo")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .accessibilityLabel(isItalian ? "Annulla serie completata" : "Undo completed set")
                .accessibilityHint(isItalian ? "Tocca per rimuovere il completamento di questa serie" : "Tap to uncomplete this set")

                // Edit button for completed set
                Button(action: {
                    WKInterfaceDevice.current().play(.click)
                    showingEditReps = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .frame(width: 44)
                .accessibilityLabel(isItalian ? "Modifica serie" : "Edit set")
            } else {
                // ✅ VIEWING CURRENT/FUTURE SET: Context-sensitive button
                // 🔥 SUPERSET AUTO-ADVANCE (Hevy pattern):
                // - "Conferma" button confirms current exercise and auto-advances
                // - "Completa Round" appears only when ALL exercises are confirmed
                if connectivity.isSuperset && allExercisesConfirmedInRound {
                    // ALL exercises confirmed → "Completa Round" button
                    Button(action: {
                        WKInterfaceDevice.current().play(.click)
                        if connectivity.rpeTrackingEnabled {
                            showingEffortPicker = true
                        } else {
                            completeSupersetRound(effort: nil)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: showingConfirmation ? "checkmark" : "checkmark.circle.fill")
                            Text(showingConfirmation ? doneText : completeRoundText)
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(showingConfirmation)
                    .accessibilityLabel(showingConfirmation ? (isItalian ? "Round completato" : "Round completed") : (isItalian ? "Completa round" : "Complete round"))
                } else if connectivity.isSuperset && !isCurrentExerciseConfirmed {
                    // Current exercise NOT confirmed → "Conferma" button (auto-advances)
                    Button(action: {
                        confirmCurrentExerciseAndAutoAdvance()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                            Text(confirmExerciseText)
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .accessibilityLabel(isItalian ? "Conferma esercizio e passa al prossimo" : "Confirm exercise and go to next")
                } else if connectivity.isSuperset && isCurrentExerciseConfirmed {
                    // Current exercise already confirmed, but not all done
                    // Show status and hint to navigate to unconfirmed exercise
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(isItalian ? "Confermato" : "Confirmed")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .accessibilityLabel(isItalian ? "Esercizio già confermato. Naviga agli altri esercizi." : "Exercise already confirmed. Navigate to other exercises.")

                // 🔻 DROPSET: Complete stage button
                } else if connectivity.isDropset {
                    Button(action: {
                        WKInterfaceDevice.current().play(.click)
                        if connectivity.rpeTrackingEnabled && isLastDropsetStage {
                            // Ask for RPE only on last stage
                            showingEffortPicker = true
                        } else if isLastDropsetStage {
                            completeDropset(effort: nil)
                        } else {
                            completeDropsetStage(effort: nil)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: showingConfirmation ? "checkmark" : "checkmark.circle.fill")
                            if showingConfirmation {
                                Text(doneText)
                            } else if isLastDropsetStage {
                                Text(isItalian ? "Completa Dropset" : "Complete Dropset")
                            } else {
                                Text(isItalian ? "Completa D\(currentDropsetStageDisplay)" : "Complete D\(currentDropsetStageDisplay)")
                            }
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isLastDropsetStage ? .green : .purple)
                    .disabled(showingConfirmation)
                    .accessibilityLabel(isLastDropsetStage
                        ? (isItalian ? "Completa dropset" : "Complete dropset")
                        : (isItalian ? "Completa stage \(currentDropsetStageDisplay)" : "Complete stage \(currentDropsetStageDisplay)"))

                // 💪 REST-PAUSE: Complete set button
                } else if connectivity.isRestPause {
                    Button(action: {
                        WKInterfaceDevice.current().play(.click)
                        if connectivity.rpeTrackingEnabled && isLastRestPauseSet {
                            // Ask for RPE only on last set
                            showingEffortPicker = true
                        } else if isLastRestPauseSet {
                            completeRestPause(effort: nil)
                        } else {
                            completeRestPauseSet(effort: nil)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: showingConfirmation ? "checkmark" : "checkmark.circle.fill")
                            if showingConfirmation {
                                Text(doneText)
                            } else if isLastRestPauseSet {
                                Text(isItalian ? "Completa RP" : "Complete RP")
                            } else {
                                Text(isItalian ? "Completa S\(currentRestPauseSetDisplay)" : "Complete S\(currentRestPauseSetDisplay)")
                            }
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isLastRestPauseSet ? .green : .cyan)
                    .disabled(showingConfirmation)
                    .accessibilityLabel(isLastRestPauseSet
                        ? (isItalian ? "Completa rest-pause" : "Complete rest-pause")
                        : (isItalian ? "Completa set \(currentRestPauseSetDisplay)" : "Complete set \(currentRestPauseSetDisplay)"))

                } else {
                    // Normal exercise: Standard Complete button
                    Button(action: {
                        WKInterfaceDevice.current().play(.click)
                        // Make sure we're completing the current set
                        viewingSetNumber = nil
                        if connectivity.rpeTrackingEnabled {
                            showingEffortPicker = true
                        } else {
                            completeSet(effort: nil)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: showingConfirmation ? "checkmark" : "checkmark.circle.fill")
                            Text(showingConfirmation ? doneText : completeText)
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(showingConfirmation || !isViewingCurrentSet)
                    .accessibilityLabel(showingConfirmation ? (isItalian ? "Serie completata" : "Set completed") : (isItalian ? "Completa serie" : "Complete set"))
                }

                // Edit button (only if there are completed sets, and NOT in superset mid-round)
                if connectivity.setsCompletedInExercise > 0 && !connectivity.isSuperset {
                    Button(action: {
                        WKInterfaceDevice.current().play(.click)
                        showingEditReps = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .frame(width: 44)
                    .accessibilityLabel(isItalian ? "Modifica serie" : "Edit set")
                }
            }
        }
    }

    // MARK: - Action Methods

    private func completeSet(effort: Int?) {
        WKInterfaceDevice.current().play(.success)
        connectivity.sendSetCompleted(effort: effort)
        showingConfirmation = true

        // Cancel any existing confirmation task
        confirmationTask?.cancel()

        // Reset confirmation state after delay with automatic cancellation
        confirmationTask = Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5 seconds
            if !Task.isCancelled {
                showingConfirmation = false
            }
        }
    }

    // 🔥 SUPERSET AUTO-ADVANCE (Hevy pattern): Confirm current exercise and auto-advance
    private func confirmCurrentExerciseAndAutoAdvance() {
        WKInterfaceDevice.current().play(.click)

        // Mark current exercise as confirmed
        confirmedExercisesInRound.insert(localExerciseIndex)

        // Auto-advance to next unconfirmed exercise (Hevy pattern)
        // Find the first unconfirmed exercise
        for i in 1...connectivity.totalExercisesInSuperset {
            if !confirmedExercisesInRound.contains(i) {
                localExerciseIndex = i
                return
            }
        }

        // All exercises confirmed - stay on current (will show "Completa Round")
        // Play success haptic to indicate all exercises are done
        WKInterfaceDevice.current().play(.success)
    }

    // 🔥 SUPERSET: Complete entire round at once
    private func completeSupersetRound(effort: Int?) {
        WKInterfaceDevice.current().play(.success)
        connectivity.sendSupersetRoundCompleted(effort: effort)
        showingConfirmation = true

        // Reset local exercise index AND confirmed exercises for next round
        localExerciseIndex = 1
        confirmedExercisesInRound.removeAll()

        // Cancel any existing confirmation task
        confirmationTask?.cancel()

        // Reset confirmation state after delay
        confirmationTask = Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5 seconds
            if !Task.isCancelled {
                showingConfirmation = false
            }
        }
    }

    // MARK: - Target Edit Mode

    /// Enter edit mode for current set target
    private func enterTargetEditMode() {
        WKInterfaceDevice.current().play(.click)
        editingWeight = connectivity.targetWeight
        editingReps = connectivity.targetReps
        editingField = .weight
        crownValue = connectivity.targetWeight
        isEditingTarget = true
        // Delay focus to allow view to appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTargetEditorFocused = true
        }
    }

    /// Confirm edited target and send to iPhone
    private func confirmTargetEdit() {
        WKInterfaceDevice.current().play(.success)
        isEditingTarget = false
        isTargetEditorFocused = false
        // Send updated target to iPhone
        connectivity.sendUpdateSetTarget(weight: editingWeight, reps: editingReps)
    }

    /// Cancel edit mode without saving
    private func cancelTargetEdit() {
        WKInterfaceDevice.current().play(.click)
        isEditingTarget = false
        isTargetEditorFocused = false
    }

    /// Switch between editing weight and reps
    private func toggleEditingField() {
        WKInterfaceDevice.current().play(.click)
        if editingField == .weight {
            editingField = .reps
            crownValue = Double(editingReps)
        } else {
            editingField = .weight
            crownValue = editingWeight
        }
    }

    /// Crown step for weight (0.5 kg increments)
    private var weightStep: Double { 0.5 }

    // MARK: - 🔻 DROPSET Functions

    /// Format weight for display (no decimals if integer)
    private func formatWeight(_ weight: Double) -> String {
        if weight == floor(weight) {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.1f", weight)
        }
    }

    /// Complete current dropset stage
    private func completeDropsetStage(effort: Int?) {
        let currentStage = connectivity.currentDropsetStage
        let stageData = connectivity.dropsetStages[safe: currentStage]
        let actualReps = stageData?.reps ?? 0

        WKInterfaceDevice.current().play(.success)
        connectivity.sendDropsetStageCompleted(
            stageIndex: currentStage,
            actualReps: actualReps,
            effort: effort
        )

        showingConfirmation = true

        // Cancel any existing confirmation task
        confirmationTask?.cancel()

        // Reset confirmation state after delay
        confirmationTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
            if !Task.isCancelled {
                showingConfirmation = false
            }
        }
    }

    /// Complete entire dropset (last stage)
    private func completeDropset(effort: Int?) {
        WKInterfaceDevice.current().play(.success)
        connectivity.sendDropsetCompleted(effort: effort)

        showingConfirmation = true

        // Cancel any existing confirmation task
        confirmationTask?.cancel()

        // Reset confirmation state after delay
        confirmationTask = Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5 seconds
            if !Task.isCancelled {
                showingConfirmation = false
            }
        }
    }

    // MARK: - 💪 REST-PAUSE Functions

    /// Complete current rest-pause set
    private func completeRestPauseSet(effort: Int?) {
        let currentSet = connectivity.currentRestPauseSet
        let setData = connectivity.restPauseSets[safe: currentSet]
        let actualReps = setData?.reps ?? 0

        WKInterfaceDevice.current().play(.success)
        connectivity.sendRestPauseSetCompleted(
            setIndex: currentSet,
            actualReps: actualReps,
            effort: effort
        )

        showingConfirmation = true

        // Cancel any existing confirmation task
        confirmationTask?.cancel()

        // Reset confirmation state after delay
        confirmationTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
            if !Task.isCancelled {
                showingConfirmation = false
            }
        }
    }

    /// Complete entire rest-pause (last set)
    private func completeRestPause(effort: Int?) {
        WKInterfaceDevice.current().play(.success)
        connectivity.sendRestPauseCompleted(effort: effort)

        showingConfirmation = true

        // Cancel any existing confirmation task
        confirmationTask?.cancel()

        // Reset confirmation state after delay
        confirmationTask = Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5 seconds
            if !Task.isCancelled {
                showingConfirmation = false
            }
        }
    }

    /// Inline target edit view with Digital Crown control
    @ViewBuilder
    private var targetEditView: some View {
        VStack(spacing: 6) {
            // Field selector: Weight | Reps
            HStack(spacing: 16) {
                // Weight field
                VStack(spacing: 2) {
                    Text("\(String(format: "%.1f", editingWeight))")
                        .font(.system(size: editingField == .weight ? 20 : 14, weight: .bold, design: .rounded))
                        .foregroundColor(editingField == .weight ? .blue : .secondary)
                        .monospacedDigit()
                    Text("kg")
                        .font(.system(size: 10))
                        .foregroundColor(editingField == .weight ? .blue : .secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(editingField == .weight ? Color.blue.opacity(0.2) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(editingField == .weight ? Color.blue : Color.clear, lineWidth: 2)
                        )
                )
                .onTapGesture {
                    if editingField != .weight {
                        toggleEditingField()
                    }
                }

                Text("×")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                // Reps field
                VStack(spacing: 2) {
                    Text("\(editingReps)")
                        .font(.system(size: editingField == .reps ? 20 : 14, weight: .bold, design: .rounded))
                        .foregroundColor(editingField == .reps ? .blue : .secondary)
                        .monospacedDigit()
                    Text(repsText)
                        .font(.system(size: 10))
                        .foregroundColor(editingField == .reps ? .blue : .secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(editingField == .reps ? Color.blue.opacity(0.2) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(editingField == .reps ? Color.blue : Color.clear, lineWidth: 2)
                        )
                )
                .onTapGesture {
                    if editingField != .reps {
                        toggleEditingField()
                    }
                }
            }

            // Crown hint
            HStack(spacing: 4) {
                Image(systemName: "digitalcrown.horizontal.arrow.counterclockwise")
                    .font(.system(size: 10))
                Text(isItalian ? "Ruota corona" : "Turn crown")
                    .font(.system(size: 10))
            }
            .foregroundColor(.secondary.opacity(0.7))

            // Action buttons
            HStack(spacing: 12) {
                Button(action: cancelTargetEdit) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.bordered)
                .tint(.gray)
                .frame(width: 44)
                .accessibilityLabel(cancelEditText)

                Button(action: confirmTargetEdit) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .frame(width: 44)
                .accessibilityLabel(confirmTargetText)
            }
        }
        .focusable(true)
        .focused($isTargetEditorFocused)
        .digitalCrownRotation(
            $crownValue,
            from: editingField == .weight ? 0.0 : 1.0,
            through: editingField == .weight ? 500.0 : 100.0,
            by: editingField == .weight ? weightStep : 1.0,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, newValue in
            if editingField == .weight {
                editingWeight = max(0, newValue)
            } else {
                editingReps = max(1, Int(newValue))
            }
        }
    }
}
