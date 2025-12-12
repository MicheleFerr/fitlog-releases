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
    @State private var selectedTab = 0  // 0 = Exercise, 1 = Timer, 2 = Stats
    @State private var tabSwitchTask: Task<Void, Never>?

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 0: Current Exercise & Set Logging
            ExerciseControlView()
                .environmentObject(connectivity)
                .environmentObject(workoutManager)
                .tag(0)

            // Tab 1: Rest Timer (mirrors Live Activity)
            RestTimerView()
                .environmentObject(connectivity)
                .tag(1)

            // Tab 2: Heart Rate & Stats
            StatsView()
                .environmentObject(connectivity)
                .environmentObject(workoutManager)
                .tag(2)
        }
        .tabViewStyle(.verticalPage)
        .onAppear {
            // Start HealthKit workout session for heart rate
            Task {
                try? await workoutManager.startWorkout(type: .strengthTraining)
            }

            // Check if timer should be showing on appear
            if connectivity.shouldShowTimer && selectedTab != 1 {
                withAnimation {
                    selectedTab = 1
                }
                resetTimerFlagTask()
            }
        }
        .onDisappear {
            // Cancel any pending tab switch tasks
            tabSwitchTask?.cancel()
            tabSwitchTask = nil

            Task {
                try? await workoutManager.endWorkout()
            }
        }
        // Auto-navigate to timer tab when timer starts
        .onChange(of: connectivity.shouldShowTimer) { _, shouldShow in
            if shouldShow && selectedTab != 1 {
                withAnimation {
                    selectedTab = 1
                }
                resetTimerFlagTask()
            }
        }
        // Also monitor restTimeRemaining directly for more reliable navigation
        .onChange(of: connectivity.restTimeRemaining) { oldValue, newValue in
            if oldValue == 0 && newValue > 0 && selectedTab != 1 {
                withAnimation {
                    selectedTab = 1
                }
            }
        }
        // Auto-navigate to exercise tab when timer ends
        .onChange(of: connectivity.shouldNavigateToExercise) { _, shouldNavigate in
            if shouldNavigate && selectedTab != 0 {
                withAnimation {
                    selectedTab = 0
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

    // Localized strings (from Flutter app)
    private var isItalian: Bool { connectivity.appLocale == "it" }
    private var setText: String { isItalian ? "Serie" : "Set" }
    private var ofText: String { isItalian ? "di" : "of" }
    private var completeText: String { isItalian ? "Completo" : "Complete" }
    private var doneText: String { isItalian ? "Fatto!" : "Done!" }
    private var repsText: String { isItalian ? "rip" : "reps" }

    var body: some View {
        VStack(spacing: 10) {
            // Top bar with HR badge
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
            }
            .padding(.horizontal, 4)

            // Exercise name
            Text(connectivity.currentExerciseName)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(isItalian ? "Esercizio: \(connectivity.currentExerciseName)" : "Exercise: \(connectivity.currentExerciseName)")

            // Set counter
            HStack(spacing: 4) {
                Text(setText)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Text("\(connectivity.currentSetNumber)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text("\(ofText) \(connectivity.totalSets)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(isItalian ? "Serie \(connectivity.currentSetNumber) di \(connectivity.totalSets)" : "Set \(connectivity.currentSetNumber) of \(connectivity.totalSets)")

            // Target info
            if connectivity.targetWeight > 0 {
                HStack(spacing: 6) {
                    Text("\(String(format: "%.1f", connectivity.targetWeight)) kg")
                        .font(.system(size: 12, weight: .medium))
                    Text("×")
                        .foregroundColor(.secondary)
                    Text("\(connectivity.targetReps) \(repsText)")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.secondary)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(isItalian ? "Obiettivo: \(String(format: "%.1f", connectivity.targetWeight)) chilogrammi per \(connectivity.targetReps) ripetizioni" : "Target: \(String(format: "%.1f", connectivity.targetWeight)) kilograms for \(connectivity.targetReps) reps")
            }

            Spacer()

            // Complete Set Button
            Button(action: {
                WKInterfaceDevice.current().play(.click)
                if connectivity.rpeTrackingEnabled {
                    // Show effort picker
                    showingEffortPicker = true
                } else {
                    // Complete without effort
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
            .disabled(showingConfirmation)
            .accessibilityLabel(showingConfirmation ? (isItalian ? "Serie completata" : "Set completed") : (isItalian ? "Completa serie" : "Complete set"))
            .accessibilityHint(showingConfirmation ? "" : (isItalian ? "Tocca due volte per completare la serie corrente" : "Double tap to complete current set"))
        }
        .padding()
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

// MARK: - Rest Timer View - Coherent Design with Flutter App

struct RestTimerView: View {
    @EnvironmentObject var connectivity: ConnectivityManager

    // MARK: - Edit Mode State
    @State private var isEditingSet = false
    @State private var editingField: EditField? = nil  // nil = timer extend mode
    @State private var editedWeight: Double = 0
    @State private var editedReps: Int = 0
    @State private var crownValue: Double = 0
    @State private var crownAccumulator: Double = 0  // Accumulates small crown movements
    @FocusState private var isFocused: Bool

    // Crown thresholds for precise control
    private let weightCrownThreshold: Double = 2.5   // Crown units needed for 2.5kg change
    private let repsCrownThreshold: Double = 2.0     // Crown units needed for 1 rep change

    enum EditField {
        case weight, reps
    }

    // Localized strings (from Flutter app)
    private var isItalian: Bool { connectivity.appLocale == "it" }
    private var skipText: String { isItalian ? "Salta" : "Skip" }
    private var readyText: String { isItalian ? "Pronto!" : "Ready!" }
    private var restText: String { isItalian ? "Riposo" : "Rest" }
    private var nextSetText: String { isItalian ? "Prossima serie" : "Next set" }
    private var repsText: String { isItalian ? "rip" : "reps" }
    private var editHintText: String { isItalian ? "Tocca per modificare" : "Tap to edit" }
    private var confirmText: String { isItalian ? "Conferma" : "Confirm" }
    private var cancelText: String { isItalian ? "Annulla" : "Cancel" }

    var body: some View {
        VStack(spacing: 8) {
            Spacer()

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
            Text(formatTime(connectivity.restTimeRemaining))
                .font(.system(size: 52, weight: .bold))
                .monospacedDigit()
                .foregroundColor(timerTextColor)
                .accessibilityLabel(isItalian ? "Tempo rimanente: \(formatTime(connectivity.restTimeRemaining))" : "Time remaining: \(formatTime(connectivity.restTimeRemaining))")

            // Next set info - TAPPABLE for edit mode
            if isEditingSet {
                // EDIT MODE: Show editable fields
                editModeView
            } else {
                // NORMAL MODE: Tappable box
                normalSetInfoView
            }

            Spacer()

            // Skip button OR Ready message (hidden in edit mode)
            if !isEditingSet {
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
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .accessibilityHidden(true)
                        Text(readyText)
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.green)
                    .accessibilityLabel(isItalian ? "Pronto per la prossima serie" : "Ready for next set")
                }
            }

            Spacer()
                .frame(height: 4)
        }
        .padding(.horizontal, 8)
        .focusable(true)
        .focused($isFocused)
        .digitalCrownRotation(
            $crownValue,
            from: -1000,
            through: 1000,
            by: 0.1,  // Small increments for precise control
            sensitivity: .low,  // Slow, precise scrolling
            isContinuous: false,
            isHapticFeedbackEnabled: false  // We'll do custom haptics
        )
        .onChange(of: crownValue) { oldValue, newValue in
            handleCrownRotation(delta: newValue - oldValue)
        }
        .onChange(of: connectivity.restTimeRemaining) { _, newValue in
            // Haptic feedback only at timer end (3-2-1 handled by ConnectivityManager)
            if newValue == 0 {
                WKInterfaceDevice.current().play(.success)
            }
        }
        .onAppear {
            isFocused = true
            // Initialize edit values
            editedWeight = connectivity.targetWeight
            editedReps = connectivity.targetReps
        }
        .onDisappear {
            // Reset focus state to prevent memory leaks
            isFocused = false
        }
    }

    // MARK: - Normal Set Info View (Tappable)

    private var normalSetInfoView: some View {
        Button(action: {
            enterEditMode()
        }) {
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

                // Set number + edit hint
                HStack(spacing: 8) {
                    Text("\(connectivity.currentSetNumber)/\(connectivity.totalSets)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)

                    // Edit hint icon
                    Image(systemName: "pencil.circle")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.6))
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(timerColor.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(connectivity.targetWeight > 0 ? (isItalian ? "Prossima serie: \(formatWeight(connectivity.targetWeight)) chilogrammi per \(connectivity.targetReps) ripetizioni. Serie \(connectivity.currentSetNumber) di \(connectivity.totalSets)" : "Next set: \(formatWeight(connectivity.targetWeight)) kilograms for \(connectivity.targetReps) reps. Set \(connectivity.currentSetNumber) of \(connectivity.totalSets)") : (isItalian ? "Nessun obiettivo impostato" : "No target set"))
        .accessibilityHint(isItalian ? "Tocca due volte per modificare peso e ripetizioni" : "Double tap to edit weight and reps")
    }

    // MARK: - Edit Mode View

    private var editModeView: some View {
        VStack(spacing: 8) {
            // Field selector buttons
            HStack(spacing: 12) {
                // Weight button
                Button(action: {
                    selectField(.weight)
                }) {
                    VStack(spacing: 2) {
                        Text("\(formatWeight(editedWeight))")
                            .font(.system(size: 20, weight: .bold))
                            .monospacedDigit()
                        Text("kg")
                            .font(.system(size: 10))
                    }
                    .frame(width: 60, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(editingField == .weight ? Color.blue : Color.gray.opacity(0.3))
                    )
                    .foregroundColor(editingField == .weight ? .white : .primary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isItalian ? "Peso: \(formatWeight(editedWeight)) chilogrammi" : "Weight: \(formatWeight(editedWeight)) kilograms")
                .accessibilityHint(isItalian ? "Tocca per modificare il peso" : "Tap to edit weight")
                .accessibilityAddTraits(editingField == .weight ? .isSelected : [])

                Text("×")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)

                // Reps button
                Button(action: {
                    selectField(.reps)
                }) {
                    VStack(spacing: 2) {
                        Text("\(editedReps)")
                            .font(.system(size: 20, weight: .bold))
                            .monospacedDigit()
                        Text(repsText)
                            .font(.system(size: 10))
                    }
                    .frame(width: 60, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(editingField == .reps ? Color.blue : Color.gray.opacity(0.3))
                    )
                    .foregroundColor(editingField == .reps ? .white : .primary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isItalian ? "Ripetizioni: \(editedReps)" : "Reps: \(editedReps)")
                .accessibilityHint(isItalian ? "Tocca per modificare le ripetizioni" : "Tap to edit reps")
                .accessibilityAddTraits(editingField == .reps ? .isSelected : [])
            }

            // Crown hint
            if editingField != nil {
                HStack(spacing: 4) {
                    Image(systemName: "digitalcrown.horizontal.arrow.clockwise")
                        .font(.system(size: 10))
                    Text(isItalian ? "Ruota per modificare" : "Turn to adjust")
                        .font(.system(size: 10))
                }
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    cancelEdit()
                }) {
                    Text(cancelText)
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .accessibilityLabel(isItalian ? "Annulla modifiche" : "Cancel changes")
                .accessibilityHint(isItalian ? "Tocca per annullare e tornare al timer" : "Tap to cancel and return to timer")

                Button(action: {
                    confirmEdit()
                }) {
                    Text(confirmText)
                        .font(.system(size: 12, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .accessibilityLabel(isItalian ? "Conferma modifiche: \(formatWeight(editedWeight)) chilogrammi per \(editedReps) ripetizioni" : "Confirm changes: \(formatWeight(editedWeight)) kilograms for \(editedReps) reps")
                .accessibilityHint(isItalian ? "Tocca per salvare le modifiche" : "Tap to save changes")
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .contain)
    }

    // MARK: - Edit Mode Methods

    private func enterEditMode() {
        guard connectivity.targetWeight > 0 else { return }

        WKInterfaceDevice.current().play(.click)
        editedWeight = connectivity.targetWeight
        editedReps = connectivity.targetReps
        editingField = .weight  // Start with weight selected
        isEditingSet = true
        // Reset accumulator for fresh start
        crownAccumulator = 0
        crownValue = 0
    }

    private func selectField(_ field: EditField) {
        WKInterfaceDevice.current().play(.click)
        editingField = field
        // Reset crown and accumulator for fresh start
        crownValue = 0
        crownAccumulator = 0
    }

    private func cancelEdit() {
        WKInterfaceDevice.current().play(.click)
        isEditingSet = false
        editingField = nil
        crownAccumulator = 0
    }

    private func confirmEdit() {
        WKInterfaceDevice.current().play(.success)

        // Send update to Flutter
        connectivity.sendSetModification(weight: editedWeight, reps: editedReps)

        isEditingSet = false
        editingField = nil
        crownAccumulator = 0
    }

    // MARK: - Crown Handling

    private func handleCrownRotation(delta: Double) {
        // Crown only active in edit mode for weight/reps
        if isEditingSet && editingField != nil {
            handleEditCrownRotation(delta: delta)
        }
    }

    private func handleEditCrownRotation(delta: Double) {
        guard let field = editingField else { return }

        // Accumulate small crown movements
        crownAccumulator += delta

        switch field {
        case .weight:
            // Only change value when threshold is reached
            if abs(crownAccumulator) >= weightCrownThreshold {
                let direction = crownAccumulator > 0 ? 1.0 : -1.0
                let newWeight = editedWeight + (direction * 2.5)
                editedWeight = max(0, newWeight)

                // Haptic feedback on value change
                WKInterfaceDevice.current().play(.click)

                // Reset accumulator (keep remainder for smoother feel)
                crownAccumulator = crownAccumulator.truncatingRemainder(dividingBy: weightCrownThreshold)
            }

        case .reps:
            // Only change value when threshold is reached
            if abs(crownAccumulator) >= repsCrownThreshold {
                let direction = crownAccumulator > 0 ? 1 : -1
                let newReps = editedReps + direction
                editedReps = max(1, newReps)

                // Haptic feedback on value change
                WKInterfaceDevice.current().play(.click)

                // Reset accumulator (keep remainder for smoother feel)
                crownAccumulator = crownAccumulator.truncatingRemainder(dividingBy: repsCrownThreshold)
            }
        }
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
            // Save button (primary action)
            Button(saveText) {
                WKInterfaceDevice.current().play(.success)
                connectivity.sendEndWorkout(
                    save: true,
                    duration: workoutManager.elapsedTime,
                    calories: workoutManager.activeCalories
                )
            }
            // Discard button (destructive)
            Button(discardText, role: .destructive) {
                WKInterfaceDevice.current().play(.click)
                connectivity.sendEndWorkout(
                    save: false,
                    duration: workoutManager.elapsedTime,
                    calories: workoutManager.activeCalories
                )
            }
            Button(cancelText, role: .cancel) { }
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
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

#Preview {
    ContentView()
        .environmentObject(ConnectivityManager.shared)
}
