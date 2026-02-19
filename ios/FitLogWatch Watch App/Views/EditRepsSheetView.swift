//
//  EditRepsSheetView.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Edit completed set reps with horizontal set navigation
//

import SwiftUI

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
