//
//  ContentView.swift
//  FitLogWatch Watch App
//
//  Watch Companion - Shows workout support when iPhone workout is active
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

// MARK: - Waiting View (No Active Workout) - Minimal Design

struct WaitingView: View {
    @EnvironmentObject var connectivity: ConnectivityManager

    // Localized strings (from Flutter app)
    private var isItalian: Bool { connectivity.appLocale == "it" }
    private var connectedText: String { isItalian ? "Connesso" : "Connected" }
    private var waitingText: String { isItalian ? "In attesa..." : "Waiting..." }
    private var startWorkoutText: String { isItalian ? "Inizia un allenamento\nsu iPhone" : "Start a workout on\nyour iPhone" }

    var body: some View {
        VStack(spacing: 12) {
            // Connection status
            HStack(spacing: 6) {
                Circle()
                    .fill(connectivity.isReachable ? Color.green : Color.orange)
                    .frame(width: 6, height: 6)
                    .accessibilityHidden(true)
                Text(connectivity.isReachable ? connectedText : waitingText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(isItalian ? "Stato connessione: \(connectivity.isReachable ? connectedText : waitingText)" : "Connection status: \(connectivity.isReachable ? connectedText : waitingText)")

            Spacer()

            // Main icon - clean, no effects
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 40, weight: .regular))
                .foregroundColor(.blue)
                .accessibilityHidden(true)

            Text("FitLog")
                .font(.system(size: 17, weight: .semibold))
                .accessibilityAddTraits(.isHeader)

            Text(startWorkoutText)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            // Heart rate display (if available)
            if connectivity.currentHeartRate > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .accessibilityHidden(true)

                    Text("\(Int(connectivity.currentHeartRate))")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))

                    Text("BPM")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel(isItalian ? "Frequenza cardiaca: \(Int(connectivity.currentHeartRate)) battiti per minuto" : "Heart rate: \(Int(connectivity.currentHeartRate)) beats per minute")
            }
        }
        .padding()
    }
}

// MARK: - Workout Companion View (Active Workout)

struct WorkoutCompanionView: View {
    @EnvironmentObject var connectivity: ConnectivityManager
    @EnvironmentObject var workoutManager: WorkoutManager
    // 🆕 NEW 4-TAB STRUCTURE:
    // Tab 0: AdvancedInfoView (TUT, HR zone, form cues, exercise details)
    // Tab 1: SimplifiedSetView (DEFAULT - simple set logging for beginners)
    // Tab 2: RestTimerView (rest timer with Quick Add Time)
    // Tab 3: StatsView (HR, calories, duration, end workout)
    @State private var selectedTab = 1  // DEFAULT: SimplifiedSetView (Tab 1)
    @State private var tabSwitchTask: Task<Void, Never>?

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 0: Advanced Info (TUT, HR zone, form cues) - for power users
            AdvancedInfoView()
                .environmentObject(connectivity)
                .environmentObject(workoutManager)
                .tag(0)

            // Tab 1: Simplified Set View (DEFAULT) - for beginners
            SimplifiedSetView()
                .environmentObject(connectivity)
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

// MARK: - Simplified Set View (Tab 1 - DEFAULT for beginners)
// 🎯 Persona: Marco (principiante), Roberto (busy professional)
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

            // Set indicator: "Set 2/4"
            Text("\(setText) \(connectivity.currentSetNumber)/\(connectivity.totalSets)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)

            // Weight × Reps (LARGE, TAPPABLE to edit)
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Text(formatWeight(connectivity.targetWeight))
                        .font(.system(size: 36, weight: .bold))
                    Text("×")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("\(connectivity.targetReps)")
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
            .accessibilityLabel(isItalian ? "\(formatWeight(connectivity.targetWeight)) chili per \(connectivity.targetReps) ripetizioni" : "\(formatWeight(connectivity.targetWeight)) kg for \(connectivity.targetReps) reps")
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

// MARK: - Advanced Info View (Tab 0 - For power users)
// 🎯 Persona: Luca (powerlifter), users who want detailed info
// Shows: TUT, HR zone, form cues, exercise details with Quick Edit

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

// MARK: - Set Picker Sheet View

struct SetPickerSheetView: View {
    let totalSets: Int
    let currentSet: Int
    let locale: String
    let onSelect: (Int) -> Void
    let onCancel: () -> Void

    @State private var selectedSet: Int

    init(totalSets: Int, currentSet: Int, locale: String, onSelect: @escaping (Int) -> Void, onCancel: @escaping () -> Void) {
        self.totalSets = totalSets
        self.currentSet = currentSet
        self.locale = locale
        self.onSelect = onSelect
        self.onCancel = onCancel
        // Initialize state with current set value
        _selectedSet = State(initialValue: currentSet)
    }

    private var isItalian: Bool { locale == "it" }
    private var titleText: String { isItalian ? "Seleziona Serie" : "Select Set" }
    private var selectText: String { isItalian ? "Vai" : "Go" }
    private var cancelText: String { isItalian ? "Annulla" : "Cancel" }

    var body: some View {
        VStack(spacing: 10) {
            Text(titleText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)

            // Set picker with Crown
            Picker(titleText, selection: $selectedSet) {
                ForEach(1...totalSets, id: \.self) { setNum in
                    Text("\(isItalian ? "Serie" : "Set") \(setNum)")
                        .tag(setNum)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 80)

            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text(cancelText)
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.bordered)
                .tint(.gray)

                Button(action: {
                    WKInterfaceDevice.current().play(.click)
                    onSelect(selectedSet)
                }) {
                    Text(selectText)
                        .font(.system(size: 12, weight: .bold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
        .padding()
    }
}

// MARK: - Exercise Picker Sheet View

struct ExercisePickerSheetView: View {
    let exerciseNames: [String]
    let currentIndex: Int
    let locale: String
    let onSelect: (Int) -> Void
    let onCancel: () -> Void

    @State private var selectedIndex: Int = 0

    private var isItalian: Bool { locale == "it" }
    private var titleText: String { isItalian ? "Vai a Esercizio" : "Go to Exercise" }
    private var selectText: String { isItalian ? "Vai" : "Go" }
    private var cancelText: String { isItalian ? "Annulla" : "Cancel" }

    var body: some View {
        VStack(spacing: 8) {
            Text(titleText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)

            // Exercise picker with Crown
            Picker(titleText, selection: $selectedIndex) {
                ForEach(0..<exerciseNames.count, id: \.self) { index in
                    Text(exerciseNames[index])
                        .font(.system(size: 11))
                        .lineLimit(2)
                        .tag(index)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 90)

            // Current position indicator
            Text("\(selectedIndex + 1)/\(exerciseNames.count)")
                .font(.system(size: 10))
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text(cancelText)
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.bordered)
                .tint(.gray)

                Button(action: {
                    WKInterfaceDevice.current().play(.click)
                    onSelect(selectedIndex)
                }) {
                    Text(selectText)
                        .font(.system(size: 11, weight: .bold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .onAppear {
            selectedIndex = currentIndex
        }
    }
}

// MARK: - Quick Edit Sheet View (for AdvancedInfoView)

struct QuickEditSheetView: View {
    @EnvironmentObject var connectivity: ConnectivityManager
    @Environment(\.dismiss) var dismiss

    // Configuration: whether to show copy buttons (only in AdvancedInfoView, not in SimplifiedSetView)
    var showCopyButtons: Bool = true

    @State private var editingWeight: Double = 0
    @State private var editingReps: Int = 1
    @State private var editingField: EditField = .weight
    @State private var crownValue: Double = 0
    @FocusState private var isFocused: Bool

    enum EditField {
        case weight
        case reps
    }

    private var isItalian: Bool { connectivity.appLocale == "it" }
    private var weightLabel: String { isItalian ? "Peso" : "Weight" }
    private var repsLabel: String { isItalian ? "Reps" : "Reps" }
    private var saveText: String { isItalian ? "Salva" : "Save" }
    private var cancelText: String { isItalian ? "Annulla" : "Cancel" }
    private var copyAllText: String { isItalian ? "Copia in tutti" : "Copy to all" }
    private var copyPrevText: String { isItalian ? "Copia precedente" : "Copy previous" }

    // Can copy from previous only if not on first set
    private var canCopyFromPrevious: Bool { connectivity.currentSetNumber > 1 }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Weight and Reps in compact row
                HStack(spacing: 12) {
                    // Weight section
                    VStack(spacing: 2) {
                        Text(weightLabel)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)

                        Button(action: {
                            editingField = .weight
                            crownValue = editingWeight
                        }) {
                            Text("\(formatWeight(editingWeight))")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(editingField == .weight ? .blue : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(editingField == .weight ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    // Reps section
                    VStack(spacing: 2) {
                        Text(repsLabel)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)

                        Button(action: {
                            editingField = .reps
                            crownValue = Double(editingReps)
                        }) {
                            Text("\(editingReps)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(editingField == .reps ? .blue : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(editingField == .reps ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Crown instructions
                Text(isItalian ? "🔄 Corona per regolare" : "🔄 Crown to adjust")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)

                Divider()

                // Copy buttons (only shown in AdvancedInfoView)
                if showCopyButtons {
                    VStack(spacing: 6) {
                        // Copy to all sets
                        Button(action: {
                            WKInterfaceDevice.current().play(.click)
                            connectivity.copyToAllSets(weight: editingWeight, reps: editingReps)
                            WKInterfaceDevice.current().play(.success)
                            dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 10))
                                Text(copyAllText)
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)

                        // Copy from previous (only if not first set)
                        if canCopyFromPrevious {
                            Button(action: {
                                WKInterfaceDevice.current().play(.click)
                                connectivity.copyFromPreviousSet()
                                WKInterfaceDevice.current().play(.success)
                                dismiss()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.left.doc")
                                        .font(.system(size: 10))
                                    Text(copyPrevText)
                                        .font(.system(size: 11, weight: .medium))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 30)
                            }
                            .buttonStyle(.bordered)
                            .tint(.purple)
                        }
                    }

                    Divider()
                }

                // Save/Cancel buttons
                HStack(spacing: 8) {
                    Button(cancelText) {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                    .font(.system(size: 11))

                    Button(saveText) {
                        connectivity.sendUpdateSetTarget(weight: editingWeight, reps: editingReps)
                        WKInterfaceDevice.current().play(.success)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .font(.system(size: 11, weight: .bold))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .scrollDisabled(true)  // Disable scroll to prevent flash when using Crown
        .focusable()
        .focused($isFocused)
        .digitalCrownRotation(
            $crownValue,
            from: editingField == .weight ? 0 : 1,
            through: editingField == .weight ? 500 : 100,
            by: editingField == .weight ? 0.25 : 1,  // 0.25kg steps for weight
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onAppear {
            editingWeight = connectivity.targetWeight
            editingReps = connectivity.targetReps
            crownValue = editingWeight
            isFocused = true
        }
        .onChange(of: crownValue) { _, newValue in
            if editingField == .weight {
                editingWeight = max(0, newValue)
            } else {
                editingReps = max(1, Int(newValue))
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

// MARK: - Effort Picker View (Hybrid: Tappable Circles + Digital Crown)

struct EffortPickerView: View {
    let effortScale: String  // "rpe" or "rir"
    let locale: String       // "en" or "it" from Flutter
    let onSelect: (Int) -> Void
    let onSkip: () -> Void

    // Selected value index (0-4 maps to values array)
    // Default: RPE 8 (index 2) or RIR 2 (index 2) - moderate effort
    @State private var selectedIndex: Int = 2
    @State private var crownValue: Double = 2.0  // For Digital Crown
    @FocusState private var isFocused: Bool

    // Auto-close timeout (50 seconds of inactivity)
    @State private var autoCloseTimer: Timer?
    private let autoCloseDelay: TimeInterval = 50.0

    // Localized strings
    private var isItalian: Bool { locale == "it" }
    private var skipText: String { isItalian ? "Salta" : "Skip" }
    private var confirmText: String { isItalian ? "Conferma" : "Confirm" }
    private var crownHintText: String { isItalian ? "Ruota corona" : "Turn crown" }

    // Accessibility labels
    private var scaleAccessibilityLabel: String {
        isItalian ? "Scala di sforzo \(effortScale.uppercased())" : "\(effortScale.uppercased()) effort scale"
    }

    // RPE: 6-10, RIR: 0-4
    private var values: [Int] {
        effortScale == "rpe" ? [6, 7, 8, 9, 10] : [0, 1, 2, 3, 4]
    }

    private var selectedValue: Int {
        values[selectedIndex]
    }

    var body: some View {
        VStack(spacing: 6) {
            // Header with scale name
            Text(effortScale.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.top, 4)
                .accessibilityAddTraits(.isHeader)

            // Large value display
            Text("\(selectedValue)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(colorForValue(selectedValue))
                .animation(.easeOut(duration: 0.15), value: selectedValue)
                .accessibilityLabel("\(selectedValue)")

            // Effort description
            Text(descriptionForValue(selectedValue))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .frame(height: 14)
                .accessibilityLabel(descriptionForValue(selectedValue))

            // Tappable circles row
            HStack(spacing: 8) {
                ForEach(Array(values.enumerated()), id: \.element) { index, value in
                    EffortCircleButton(
                        value: value,
                        isSelected: index == selectedIndex,
                        color: colorForValue(value),
                        onTap: {
                            selectIndex(index)
                            // Auto-confirm on tap for faster UX
                            confirmSelection()
                        }
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)

            // Visual progress indicator (non-interactive, shows position)
            GeometryReader { geometry in
                let totalWidth = geometry.size.width - 32
                let segmentWidth = totalWidth / CGFloat(values.count)
                let indicatorX = 16 + segmentWidth * CGFloat(selectedIndex) + segmentWidth / 2

                ZStack(alignment: .leading) {
                    // Background track with gradient
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: values.map { colorForValue($0).opacity(0.3) },
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 6)

                    // Position indicator
                    Circle()
                        .fill(colorForValue(selectedValue))
                        .frame(width: 14, height: 14)
                        .shadow(color: colorForValue(selectedValue).opacity(0.5), radius: 4)
                        .position(x: indicatorX, y: 3)
                        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selectedIndex)
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 14)

            // Crown hint
            HStack(spacing: 4) {
                Image(systemName: "digitalcrown.horizontal.arrow.clockwise")
                    .font(.system(size: 10))
                    .accessibilityHidden(true)
                Text(crownHintText)
                    .font(.system(size: 10))
            }
            .foregroundColor(.secondary.opacity(0.6))
            .padding(.top, 2)
            .accessibilityHidden(true)

            // Action buttons - full width, stacked for better touch targets
            VStack(spacing: 6) {
                // Confirm button (primary action - larger)
                Button(action: {
                    confirmSelection()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                        Text(confirmText)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(colorForValue(selectedValue))
                .accessibilityLabel(isItalian ? "Conferma sforzo \(selectedValue), \(descriptionForValue(selectedValue))" : "Confirm effort \(selectedValue), \(descriptionForValue(selectedValue))")
                .accessibilityHint(isItalian ? "Tocca due volte per confermare il livello di sforzo" : "Double tap to confirm effort level")

                // Skip button (secondary action - smaller)
                Button(action: {
                    WKInterfaceDevice.current().play(.click)
                    onSkip()
                }) {
                    Text(skipText)
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .accessibilityLabel(isItalian ? "Salta valutazione sforzo" : "Skip effort rating")
                .accessibilityHint(isItalian ? "Tocca due volte per saltare la valutazione" : "Double tap to skip rating")
            }
            .padding(.horizontal, 12)
            .padding(.top, 2)
        }
        .padding(.vertical, 4)
        .focusable(true)
        .focused($isFocused)
        .digitalCrownRotation(
            $crownValue,
            from: 0,
            through: Double(values.count - 1),
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, newValue in
            let newIndex = Int(newValue.rounded())
            if newIndex != selectedIndex && newIndex >= 0 && newIndex < values.count {
                selectedIndex = newIndex
                resetAutoCloseTimer()  // Reset timer on interaction
            }
        }
        .onAppear {
            isFocused = true
            // Sync crown with selected index
            crownValue = Double(selectedIndex)
            // Start auto-close timer
            startAutoCloseTimer()
        }
        .onDisappear {
            // Clean up timer
            autoCloseTimer?.invalidate()
            autoCloseTimer = nil
        }
        // Accessibility
        .accessibilityElement(children: .contain)
        .accessibilityLabel(scaleAccessibilityLabel)
        .accessibilityHint(isItalian ? "Seleziona il livello di sforzo" : "Select effort level")
    }

    // MARK: - Timer Methods

    private func startAutoCloseTimer() {
        autoCloseTimer?.invalidate()
        autoCloseTimer = Timer.scheduledTimer(withTimeInterval: autoCloseDelay, repeats: false) { _ in
            // Auto-skip after timeout
            WKInterfaceDevice.current().play(.click)
            onSkip()
        }
    }

    private func resetAutoCloseTimer() {
        startAutoCloseTimer()
    }

    // MARK: - Helper Methods

    private func selectIndex(_ index: Int) {
        guard index >= 0 && index < values.count else { return }
        WKInterfaceDevice.current().play(.click)
        selectedIndex = index
        crownValue = Double(index)
        resetAutoCloseTimer()  // Reset timer on interaction
    }

    private func confirmSelection() {
        autoCloseTimer?.invalidate()  // Cancel timer on confirm
        WKInterfaceDevice.current().play(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onSelect(selectedValue)
        }
    }

    private func colorForValue(_ value: Int) -> Color {
        if effortScale == "rpe" {
            switch value {
            case 6: return .green
            case 7: return Color(red: 0.5, green: 0.8, blue: 0.2)  // Light green
            case 8: return .yellow
            case 9: return .orange
            case 10: return .red
            default: return .blue
            }
        } else {
            // RIR: 0 = max effort (red), 4 = easy (green)
            switch value {
            case 0: return .red
            case 1: return .orange
            case 2: return .yellow
            case 3: return Color(red: 0.5, green: 0.8, blue: 0.2)
            case 4: return .green
            default: return .blue
            }
        }
    }

    private func descriptionForValue(_ value: Int) -> String {
        if effortScale == "rpe" {
            if isItalian {
                switch value {
                case 6: return "Molto leggero"
                case 7: return "Leggero"
                case 8: return "Moderato"
                case 9: return "Difficile"
                case 10: return "Massimale"
                default: return ""
                }
            } else {
                switch value {
                case 6: return "Very light"
                case 7: return "Light"
                case 8: return "Moderate"
                case 9: return "Hard"
                case 10: return "Maximum"
                default: return ""
                }
            }
        } else {
            // RIR descriptions
            if isItalian {
                switch value {
                case 0: return "Nessuna rep"
                case 1: return "1 rep rimasta"
                case 2: return "2 rep rimaste"
                case 3: return "3 rep rimaste"
                case 4: return "4+ rep rimaste"
                default: return ""
                }
            } else {
                switch value {
                case 0: return "No reps left"
                case 1: return "1 rep left"
                case 2: return "2 reps left"
                case 3: return "3 reps left"
                case 4: return "4+ reps left"
                default: return ""
                }
            }
        }
    }
}

// MARK: - Effort Circle Button Component

struct EffortCircleButton: View {
    let value: Int
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background circle
                Circle()
                    .fill(isSelected ? color : color.opacity(0.25))
                    .frame(width: 36, height: 36)

                // Selection ring
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 36, height: 36)
                }

                // Value text
                Text("\(value)")
                    .font(.system(size: 14, weight: isSelected ? .bold : .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : color)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
        .accessibilityLabel("\(value)")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Form Cues Sheet View

struct FormCuesSheetView: View {
    let exerciseName: String
    let formCues: String
    let locale: String
    let tut: String?  // ✅ Add TUT parameter
    let onDismiss: () -> Void

    private var isItalian: Bool { locale == "it" }
    private var titleText: String { isItalian ? "Note Tecniche" : "Form Cues" }
    private var doneText: String { isItalian ? "Fatto" : "Done" }

    // ✅ Parse TUT into readable format (e.g., "3-1-2-0" → steps)
    private var tutSteps: [(label: String, value: String)]? {
        guard let tut = tut, !tut.isEmpty else { return nil }
        let parts = tut.split(separator: "-").map { String($0) }
        guard parts.count == 4 else { return nil }

        if isItalian {
            return [
                ("Eccentrica", "\(parts[0])s"),
                ("Pausa bassa", "\(parts[1])s"),
                ("Concentrica", "\(parts[2])s"),
                ("Pausa alta", "\(parts[3])s")
            ]
        } else {
            return [
                ("Eccentric", "\(parts[0])s"),
                ("Pause (bottom)", "\(parts[1])s"),
                ("Concentric", "\(parts[2])s"),
                ("Pause (top)", "\(parts[3])s")
            ]
        }
    }

    // ✅ Parse form cues into steps with proper spacing
    private var formattedCues: [String] {
        // Split by common patterns: numbered lists, bullet points, or newlines
        let lines = formCues
            .replacingOccurrences(of: "\\n", with: "\n")
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return lines
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Header with pin icon
                HStack(spacing: 6) {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                        .accessibilityHidden(true)
                    Text(titleText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                .accessibilityAddTraits(.isHeader)

                // Exercise name
                Text(exerciseName)
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                // ✅ TUT Section (if available)
                if let steps = tutSteps {
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.system(size: 10))
                            Text("TUT: \(tut ?? "")")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.blue)

                        HStack(spacing: 8) {
                            ForEach(Array(steps.enumerated()), id: \.offset) { _, step in
                                VStack(spacing: 1) {
                                    Text(step.value)
                                        .font(.system(size: 12, weight: .bold))
                                    Text(step.label)
                                        .font(.system(size: 8))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .padding(.horizontal, 8)
                }

                Divider()
                    .padding(.horizontal, 20)
                    .accessibilityHidden(true)

                // ✅ Form cues content - properly formatted with spacing
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(formattedCues.enumerated()), id: \.offset) { index, line in
                        if index > 0 {
                            Spacer().frame(height: 10)  // ✅ Space before each step
                        }
                        Text(line)
                            .font(.system(size: 13, weight: .regular))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)  // ✅ Don't truncate
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
                .padding(.horizontal, 8)

                // Done button
                Button(action: {
                    WKInterfaceDevice.current().play(.click)
                    onDismiss()
                }) {
                    Text(doneText)
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .accessibilityLabel(isItalian ? "Chiudi" : "Close")
            }
            .padding(.vertical, 8)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(isItalian ? "Promemoria sulla forma per \(exerciseName)" : "Form cues for \(exerciseName)")
    }
}

// MARK: - Edit Reps Sheet View (For rectifying completed sets)
// ✅ Redesigned: Horizontal scrolling to select which set to edit
// +/- buttons on sides of number for better fit on small Watch screen

struct EditRepsSheetView: View {
    let setsCompleted: Int           // Total sets completed so far
    let initialReps: Int             // Target reps (starting value for last set)
    let setsActualReps: [Int?]       // ✅ NEW: Actual reps for each completed set (nil = use target)
    let locale: String
    let onConfirm: (Int, Int) -> Void  // (setIndex, newReps) - 0-indexed
    let onCancel: () -> Void

    @State private var selectedSetIndex: Int  // 0-indexed, which completed set to edit
    @State private var editedReps: Int
    @State private var crownValue: Double
    @FocusState private var isFocused: Bool

    // Localized strings
    private var isItalian: Bool { locale == "it" }
    private var titleText: String { isItalian ? "Modifica Serie" : "Edit Set" }
    private var setLabel: String { isItalian ? "Serie" : "Set" }
    private var confirmText: String { isItalian ? "Conferma" : "Confirm" }
    private var cancelText: String { isItalian ? "Annulla" : "Cancel" }
    private var repsText: String { isItalian ? "rip" : "reps" }

    /// Get actual reps for a specific set index (0-indexed)
    private func repsForSet(_ index: Int) -> Int {
        // If we have actualReps for this set, use it
        if index < setsActualReps.count, let actualReps = setsActualReps[index] {
            return actualReps
        }
        // Fallback to initialReps (target)
        return initialReps
    }

    init(setsCompleted: Int, initialReps: Int, setsActualReps: [Int?], locale: String, onConfirm: @escaping (Int, Int) -> Void, onCancel: @escaping () -> Void) {
        self.setsCompleted = max(1, setsCompleted)
        self.initialReps = initialReps
        self.setsActualReps = setsActualReps
        self.locale = locale
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        // Default to editing the LAST completed set (most recent)
        let lastSetIndex = max(0, setsCompleted - 1)
        _selectedSetIndex = State(initialValue: lastSetIndex)
        // ✅ FIX: Use actual reps of the last set (if available)
        let lastSetReps = lastSetIndex < setsActualReps.count ? (setsActualReps[lastSetIndex] ?? initialReps) : initialReps
        _editedReps = State(initialValue: max(1, lastSetReps))
        _crownValue = State(initialValue: Double(max(1, lastSetReps)))
    }

    var body: some View {
        VStack(spacing: 6) {
            // Header with set selector
            Text(titleText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.top, 4)
                .accessibilityAddTraits(.isHeader)

            // Horizontal set selector (swipe between completed sets)
            if setsCompleted > 1 {
                setSelector
            } else {
                // Single set - no selector needed
                Text("\(setLabel) 1")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
            }

            // Main edit area: [-] NUMBER [+]
            HStack(spacing: 12) {
                // Minus button (left side)
                Button(action: decrementReps) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(editedReps > 1 ? .blue : .gray.opacity(0.4))
                }
                .buttonStyle(.plain)
                .disabled(editedReps <= 1)
                .accessibilityLabel(isItalian ? "Diminuisci" : "Decrease")

                // Reps display (center)
                VStack(spacing: 0) {
                    Text("\(editedReps)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                        .animation(.easeOut(duration: 0.1), value: editedReps)

                    Text(repsText)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(minWidth: 60)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(isItalian ? "\(editedReps) ripetizioni" : "\(editedReps) reps")
                .accessibilityValue("\(editedReps)")

                // Plus button (right side)
                Button(action: incrementReps) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(editedReps < 99 ? .blue : .gray.opacity(0.4))
                }
                .buttonStyle(.plain)
                .disabled(editedReps >= 99)
                .accessibilityLabel(isItalian ? "Aumenta" : "Increase")
            }
            .padding(.vertical, 4)

            // Action buttons (compact)
            HStack(spacing: 20) {
                // Cancel button
                Button(action: {
                    WKInterfaceDevice.current().play(.click)
                    onCancel()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 50, height: 34)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .accessibilityLabel(cancelText)

                // Confirm button
                Button(action: {
                    WKInterfaceDevice.current().play(.success)
                    onConfirm(selectedSetIndex, editedReps)
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 50, height: 34)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .accessibilityLabel(isItalian ? "Conferma \(editedReps) ripetizioni per serie \(selectedSetIndex + 1)" : "Confirm \(editedReps) reps for set \(selectedSetIndex + 1)")
            }
            .padding(.bottom, 4)
        }
        .focusable(true)
        .focused($isFocused)
        .digitalCrownRotation(
            $crownValue,
            from: 1,
            through: 99,
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, newValue in
            let newReps = Int(newValue.rounded())
            if newReps != editedReps && newReps >= 1 && newReps <= 99 {
                editedReps = newReps
            }
        }
        // ✅ NEW: Update reps when user changes selected set
        .onChange(of: selectedSetIndex) { _, newIndex in
            let newReps = repsForSet(newIndex)
            editedReps = max(1, newReps)
            crownValue = Double(editedReps)
        }
        .onAppear {
            isFocused = true
        }
    }

    // MARK: - Set Selector (horizontal paging)
    private var setSelector: some View {
        HStack(spacing: 8) {
            // Left arrow (if not first set)
            Button(action: {
                if selectedSetIndex > 0 {
                    WKInterfaceDevice.current().play(.click)
                    selectedSetIndex -= 1
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(selectedSetIndex > 0 ? .blue : .gray.opacity(0.3))
            }
            .buttonStyle(.plain)
            .disabled(selectedSetIndex == 0)
            .frame(width: 30)

            // Set indicator
            Text("\(setLabel) \(selectedSetIndex + 1)")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.blue)
                .frame(minWidth: 70)

            // Right arrow (if not last set)
            Button(action: {
                if selectedSetIndex < setsCompleted - 1 {
                    WKInterfaceDevice.current().play(.click)
                    selectedSetIndex += 1
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(selectedSetIndex < setsCompleted - 1 ? .blue : .gray.opacity(0.3))
            }
            .buttonStyle(.plain)
            .disabled(selectedSetIndex == setsCompleted - 1)
            .frame(width: 30)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isItalian ? "Serie \(selectedSetIndex + 1) di \(setsCompleted)" : "Set \(selectedSetIndex + 1) of \(setsCompleted)")
        .accessibilityHint(isItalian ? "Usa le frecce per cambiare serie" : "Use arrows to change set")
    }

    // MARK: - Actions
    private func decrementReps() {
        if editedReps > 1 {
            editedReps -= 1
            crownValue = Double(editedReps)
            WKInterfaceDevice.current().play(.click)
        }
    }

    private func incrementReps() {
        if editedReps < 99 {
            editedReps += 1
            crownValue = Double(editedReps)
            WKInterfaceDevice.current().play(.click)
        }
    }
}

// MARK: - Rest Timer View - Coherent Design with Flutter App

// MARK: - Quick Add Time Picker View (for RestTimerView when timer is 00:00)
// 🎯 Allows user to start a new timer with Crown selection

struct QuickAddTimePickerView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var connectivity: ConnectivityManager

    // Time options in seconds (common rest periods)
    let timeOptions = [15, 30, 45, 60, 75, 90, 120, 150, 180, 240, 300]
    @State private var selectedIndex = 3  // Default: 60s
    @State private var crownValue: Double = 3
    @FocusState private var isFocused: Bool

    private var isItalian: Bool { connectivity.appLocale == "it" }
    private var titleText: String { isItalian ? "Aggiungi Tempo" : "Add Time" }
    private var startText: String { isItalian ? "Avvia" : "Start" }
    private var cancelText: String { isItalian ? "Annulla" : "Cancel" }

    var body: some View {
        VStack(spacing: 12) {
            Text(titleText)
                .font(.system(size: 14, weight: .semibold))

            // Time display (large)
            Text(formatTime(timeOptions[selectedIndex]))
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(.blue)
                .accessibilityLabel(isItalian ? "\(timeOptions[selectedIndex]) secondi" : "\(timeOptions[selectedIndex]) seconds")

            // Crown hint
            Text(isItalian ? "Usa Corona per regolare" : "Use Crown to adjust")
                .font(.system(size: 9))
                .foregroundColor(.secondary)

            // Action buttons
            HStack(spacing: 12) {
                Button(cancelText) {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                .tint(.secondary)

                Button(startText) {
                    connectivity.startNewTimer(duration: timeOptions[selectedIndex])
                    WKInterfaceDevice.current().play(.start)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding()
        .focusable()
        .focused($isFocused)
        .digitalCrownRotation(
            $crownValue,
            from: 0,
            through: Double(timeOptions.count - 1),
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onAppear {
            isFocused = true
        }
        .onChange(of: crownValue) { _, newValue in
            selectedIndex = min(timeOptions.count - 1, max(0, Int(newValue.rounded())))
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        if seconds < 60 {
            return "+\(seconds)s"
        } else {
            let min = seconds / 60
            let sec = seconds % 60
            return sec > 0 ? "+\(min)m\(sec)s" : "+\(min)m"
        }
    }
}

// MARK: - Rest Timer View (Tab 2)

struct RestTimerView: View {
    @EnvironmentObject var connectivity: ConnectivityManager
    @State private var showQuickAddTime = false

    // Localized strings (from Flutter app)
    private var isItalian: Bool { connectivity.appLocale == "it" }
    private var skipText: String { isItalian ? "Salta" : "Skip" }
    private var readyText: String { isItalian ? "Pronto!" : "Ready!" }
    private var restText: String { isItalian ? "Riposo" : "Rest" }
    private var nextSetText: String { isItalian ? "Prossima serie" : "Next set" }
    private var repsText: String { isItalian ? "rip" : "reps" }
    private var tapToAddTimeText: String { isItalian ? "Tocca per aggiungere tempo" : "Tap to add time" }

    var body: some View {
        VStack(spacing: 8) {
            Spacer()

            // 🔥 SUPERSET: Show context during rest (Orange theme for consistency with Flutter app)
            if connectivity.isSuperset {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.orange)
                        .accessibilityHidden(true)

                    Text(connectivity.supersetName ?? "Superset")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.orange)
                        .lineLimit(1)

                    if connectivity.totalSupersetRounds > 1 {
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(.orange.opacity(0.6))
                        Text("R\(connectivity.supersetRound)/\(connectivity.totalSupersetRounds)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.orange.opacity(0.8))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.orange.opacity(0.12))
                )
                .accessibilityLabel(isItalian ? "Superset: \(connectivity.supersetName ?? "Superset"), Round \(connectivity.supersetRound) di \(connectivity.totalSupersetRounds)" : "Superset: \(connectivity.supersetName ?? "Superset"), Round \(connectivity.supersetRound) of \(connectivity.totalSupersetRounds)")
            }

            // Rest label with pause indicator
            HStack(spacing: 6) {
                if connectivity.isTimerPaused {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.yellow)
                        .accessibilityHidden(true)
                }
                Text(restText.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(connectivity.isTimerPaused ? (isItalian ? "Riposo in pausa" : "Rest paused") : restText)

            // Time display (no animation = battery savings)
            // ✅ Tappable when timer is at 00:00 to add more time
            Text(formatTime(connectivity.restTimeRemaining))
                .font(.system(size: 52, weight: .bold))
                .monospacedDigit()
                .foregroundColor(timerTextColor)
                .accessibilityLabel(isItalian ? "Tempo rimanente: \(formatTime(connectivity.restTimeRemaining))" : "Time remaining: \(formatTime(connectivity.restTimeRemaining))")
                .onTapGesture {
                    if connectivity.restTimeRemaining == 0 {
                        WKInterfaceDevice.current().play(.click)
                        showQuickAddTime = true
                    }
                }

            // Next set info (read-only display)
            // Note: Weight/reps editing moved to ExerciseControlView for cleaner UX
            nextSetInfoView

            Spacer()

            // Skip button OR Ready message
            if connectivity.restTimeRemaining > 0 && !connectivity.isTimerPaused {
                Button(action: {
                    connectivity.sendSkipRest()
                    WKInterfaceDevice.current().play(.click)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 11))
                        Text(skipText)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .padding(.horizontal, 20)
                .accessibilityLabel(isItalian ? "Salta riposo" : "Skip rest")
                .accessibilityHint(isItalian ? "Tocca due volte per terminare il riposo e iniziare la serie successiva" : "Double tap to end rest and start next set")
            } else if connectivity.restTimeRemaining == 0 {
                // 🆕 Tappable "Ready!" area to add more time
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .accessibilityHidden(true)
                        Text(readyText)
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.green)

                    // Hint text for tap to add time
                    Text(tapToAddTimeText)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .onTapGesture {
                    WKInterfaceDevice.current().play(.click)
                    showQuickAddTime = true
                }
                .accessibilityLabel(isItalian ? "Pronto per la prossima serie" : "Ready for next set")
                .accessibilityHint(isItalian ? "Tocca per aggiungere altro tempo di riposo" : "Tap to add more rest time")
            }

            Spacer()
                .frame(height: 4)
        }
        .padding(.horizontal, 8)
        .onChange(of: connectivity.restTimeRemaining) { _, newValue in
            // Haptic feedback only at timer end (3-2-1 handled by ConnectivityManager)
            if newValue == 0 {
                WKInterfaceDevice.current().play(.success)
            }
        }
        .sheet(isPresented: $showQuickAddTime) {
            QuickAddTimePickerView(isPresented: $showQuickAddTime)
                .environmentObject(connectivity)
        }
    }

    // MARK: - Next Set Info View (Read-only)

    private var nextSetInfoView: some View {
        VStack(spacing: 4) {
            Text(nextSetText.uppercased())
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .tracking(1)

            if connectivity.targetWeight > 0 {
                HStack(spacing: 6) {
                    Text("\(formatWeight(connectivity.targetWeight)) kg")
                        .font(.system(size: 16, weight: .bold))
                    Text("×")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("\(connectivity.targetReps) \(repsText)")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(timerColor)
            } else {
                Text("—")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }

            // Set number
            Text("\(connectivity.currentSetNumber)/\(connectivity.totalSets)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(timerColor.opacity(0.15))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(connectivity.targetWeight > 0 ? (isItalian ? "Prossima serie: \(formatWeight(connectivity.targetWeight)) chilogrammi per \(connectivity.targetReps) ripetizioni. Serie \(connectivity.currentSetNumber) di \(connectivity.totalSets)" : "Next set: \(formatWeight(connectivity.targetWeight)) kilograms for \(connectivity.targetReps) reps. Set \(connectivity.currentSetNumber) of \(connectivity.totalSets)") : (isItalian ? "Nessun obiettivo impostato" : "No target set"))
    }

    // MARK: - Computed Properties

    private var timerColor: Color {
        if connectivity.isTimerPaused { return .yellow }
        if connectivity.restTimeRemaining <= 10 { return .orange }
        if connectivity.restTimeRemaining <= 30 { return .blue }
        return .green
    }

    private var timerTextColor: Color {
        if connectivity.isTimerPaused { return .yellow }
        if connectivity.restTimeRemaining <= 10 { return .orange }
        return .primary
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.1f", weight)
        }
    }
}

// MARK: - Stats View - Minimal Design with End Workout Button

struct StatsView: View {
    @EnvironmentObject var connectivity: ConnectivityManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingEndOptions = false

    // Localized strings (from Flutter app)
    private var isItalian: Bool { connectivity.appLocale == "it" }
    private var endWorkoutText: String { isItalian ? "Termina" : "End" }
    private var confirmEndText: String { isItalian ? "Terminare allenamento?" : "End workout?" }
    private var cancelText: String { isItalian ? "Annulla" : "Cancel" }
    private var saveText: String { isItalian ? "Salva" : "Save" }
    private var discardText: String { isItalian ? "Scarta" : "Discard" }
    private var kcalLabel: String { "kcal" }
    private var timeLabel: String { isItalian ? "tempo" : "time" }
    private var setsLabel: String { isItalian ? "serie" : "sets" }

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
            .accessibilityLabel(isItalian ? "Frequenza cardiaca: \(Int(workoutManager.heartRate)) battiti per minuto" : "Heart rate: \(Int(workoutManager.heartRate)) beats per minute")

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
                .accessibilityLabel(isItalian ? "Zona di frequenza cardiaca: \(workoutManager.currentHeartRateZone.rawValue)" : "Heart rate zone: \(workoutManager.currentHeartRateZone.rawValue)")

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
                .accessibilityLabel(isItalian ? "\(Int(workoutManager.activeCalories)) chilocalorie" : "\(Int(workoutManager.activeCalories)) kilocalories")

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
                .accessibilityLabel(isItalian ? "Durata allenamento" : "Workout duration")

                Divider()
                    .frame(height: 30)
                    .accessibilityHidden(true)

                // Sets
                StatItem(
                    value: "\(connectivity.setsCompleted)",
                    label: setsLabel
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel(isItalian ? "\(connectivity.setsCompleted) serie completate" : "\(connectivity.setsCompleted) sets completed")
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
            .accessibilityLabel(isItalian ? "Termina allenamento" : "End workout")
            .accessibilityHint(isItalian ? "Tocca due volte per terminare e salvare o scartare l'allenamento" : "Double tap to end and save or discard workout")
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
