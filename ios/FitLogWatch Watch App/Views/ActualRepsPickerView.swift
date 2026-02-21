//
//  ActualRepsPickerView.swift
//  FitLogWatch Watch App
//
//  Crown-based picker for selecting actual reps performed within a rep range.
//  Shown after completing a set when the exercise uses a rep range (e.g., 8-12).
//

import SwiftUI

struct ActualRepsPickerView: View {
    let minReps: Int
    let maxReps: Int
    let locale: String
    let onSelect: (Int) -> Void

    @State private var selectedReps: Int
    @State private var crownValue: Double
    @FocusState private var isFocused: Bool

    // Localized strings
    private var isItalian: Bool { locale == "it" }
    private var headerText: String { isItalian ? "Quante reps?" : "How many reps?" }
    private var confirmText: String { isItalian ? "Conferma" : "Confirm" }
    private var rangeText: String { "\(minReps)-\(maxReps)" }

    init(minReps: Int, maxReps: Int, locale: String, onSelect: @escaping (Int) -> Void) {
        self.minReps = minReps
        self.maxReps = maxReps
        self.locale = locale
        self.onSelect = onSelect
        // Default to minReps (conservative)
        _selectedReps = State(initialValue: minReps)
        _crownValue = State(initialValue: Double(minReps))
    }

    var body: some View {
        VStack(spacing: 8) {
            // Header
            Text(headerText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.top, 4)

            // Range indicator
            Text(rangeText)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary.opacity(0.7))

            // Large reps display
            Text("\(selectedReps)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(colorForReps(selectedReps))
                .animation(.easeOut(duration: 0.15), value: selectedReps)
                .accessibilityLabel("\(selectedReps) reps")

            // Reps label
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
            from: Double(minReps),
            through: Double(maxReps),
            by: 1.0,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, newValue in
            let clamped = Int(newValue.rounded()).clamped(to: minReps...maxReps)
            if clamped != selectedReps {
                selectedReps = clamped
            }
        }
        .onAppear {
            isFocused = true
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(isItalian ? "Seleziona ripetizioni effettuate" : "Select actual reps performed")
    }

    /// Color based on where the reps fall in the range
    private func colorForReps(_ reps: Int) -> Color {
        let range = maxReps - minReps
        guard range > 0 else { return .blue }

        let position = Double(reps - minReps) / Double(range)
        if position <= 0.33 {
            return .orange  // Low end of range
        } else if position <= 0.66 {
            return .blue    // Mid range
        } else {
            return .green   // High end of range
        }
    }
}

// MARK: - Int clamping helper

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
