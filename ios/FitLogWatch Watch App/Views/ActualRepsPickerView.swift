//
//  ActualRepsPickerView.swift
//  FitLogWatch Watch App
//
//  Picker for actual reps performed after completing a set.
//  Shows target reps pre-filled with - / + buttons and Digital Crown support.
//  Used for all set types: fixed reps and rep range exercises.
//

import SwiftUI
import WatchKit

struct ActualRepsPickerView: View {
    let targetReps: Int       // Default starting value (pre-filled from exercise target)
    let minReps: Int?         // Rep range lower bound (nil if not a range)
    let maxReps: Int?         // Rep range upper bound (nil if not a range)
    let locale: String
    let onSelect: (Int) -> Void

    @State private var selectedReps: Int
    @State private var crownValue: Double
    @FocusState private var isFocused: Bool

    // Localized strings
    private var isItalian: Bool { locale == "it" }
    private var headerText: String { isItalian ? "Quante reps?" : "How many reps?" }
    private var confirmText: String { isItalian ? "Conferma" : "Confirm" }

    private var hasRepRange: Bool {
        if let min = minReps, let max = maxReps { return min != max }
        return false
    }

    private var minimumAllowedReps: Int {
        guard hasRepRange else { return 0 }
        return minReps ?? 0
    }

    private var maximumAllowedReps: Int {
        guard hasRepRange else { return Int(crownMaxValue) }
        return maxReps ?? Int(crownMaxValue)
    }

    private var contextText: String {
        if let min = minReps, let max = maxReps, min != max {
            return "\(min)-\(max)"
        }
        return "Target: \(targetReps)"
    }

    private var crownMaxValue: Double {
        if let maxR = maxReps, hasRepRange {
            return Double(maxR)
        }
        return Double(Swift.max(targetReps + 20, 40))
    }

    init(targetReps: Int, minReps: Int? = nil, maxReps: Int? = nil, locale: String, onSelect: @escaping (Int) -> Void) {
        self.targetReps = targetReps
        self.minReps = minReps
        self.maxReps = maxReps
        self.locale = locale
        self.onSelect = onSelect
        let hasRange = minReps != nil && maxReps != nil && minReps != maxReps
        let lowerBound = hasRange ? (minReps ?? 0) : 0
        let upperBound = hasRange ? (maxReps ?? max(1, targetReps)) : max(1, targetReps)
        let safeDefault = min(max(max(1, targetReps), lowerBound), upperBound)
        _selectedReps = State(initialValue: safeDefault)
        _crownValue = State(initialValue: Double(safeDefault))
    }

    var body: some View {
        VStack(spacing: 6) {
            // Header
            Text(headerText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.top, 4)

            // Context: range or target
            Text(contextText)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary.opacity(0.7))

            // - [number] + row
            HStack(spacing: 0) {
                // Minus button
                Button(action: {
                    guard selectedReps > minimumAllowedReps else { return }
                    WKInterfaceDevice.current().play(.click)
                    selectedReps -= 1
                    crownValue = Double(selectedReps)
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundColor(
                    selectedReps > minimumAllowedReps
                        ? .primary
                        : .secondary.opacity(0.3)
                )
                .disabled(selectedReps <= minimumAllowedReps)
                .accessibilityLabel(isItalian ? "Diminuisci" : "Decrease")

                Spacer()

                // Reps value
                Text("\(selectedReps)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(colorForReps(selectedReps))
                    .animation(.easeOut(duration: 0.1), value: selectedReps)
                    .monospacedDigit()
                    .accessibilityLabel("\(selectedReps) \(isItalian ? "ripetizioni" : "reps")")

                Spacer()

                // Plus button
                Button(action: {
                    guard selectedReps < maximumAllowedReps else { return }
                    WKInterfaceDevice.current().play(.click)
                    selectedReps += 1
                    crownValue = Double(selectedReps)
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundColor(
                    selectedReps < maximumAllowedReps
                        ? .primary
                        : .secondary.opacity(0.3)
                )
                .disabled(selectedReps >= maximumAllowedReps)
                .accessibilityLabel(isItalian ? "Aumenta" : "Increase")
            }
            .padding(.horizontal, 4)

            // "ripetizioni" label
            Text(isItalian ? "ripetizioni" : "reps")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)

            // Confirm button
            Button(action: {
                WKInterfaceDevice.current().play(.click)
                onSelect(selectedReps)
            }) {
                Text(confirmText)
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .padding(.horizontal, 16)
        }
        .focusable(true)
        .focused($isFocused)
        .digitalCrownRotation(
            $crownValue,
            from: Double(minimumAllowedReps),
            through: crownMaxValue,
            by: 1.0,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, newValue in
            let newReps = min(
                maximumAllowedReps,
                max(minimumAllowedReps, Int(newValue.rounded()))
            )
            if newReps != selectedReps {
                selectedReps = newReps
            }
        }
        .onAppear {
            isFocused = true
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(isItalian ? "Inserisci ripetizioni effettuate" : "Enter actual reps performed")
    }

    /// Color based on performance vs target
    private func colorForReps(_ reps: Int) -> Color {
        if hasRepRange, let min = minReps, let max = maxReps {
            if reps < min { return .orange }
            if reps > max { return .blue }
            let range = max - min
            guard range > 0 else { return .green }
            let position = Double(reps - min) / Double(range)
            if position <= 0.33 { return .orange }
            else if position <= 0.66 { return .blue }
            else { return .green }
        } else {
            // Fixed target: color relative to target
            if reps < targetReps { return .orange }   // Below target
            if reps == targetReps { return .green }   // On target
            return .blue                               // Above target
        }
    }
}
