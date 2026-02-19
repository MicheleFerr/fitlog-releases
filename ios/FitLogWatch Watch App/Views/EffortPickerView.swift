//
//  EffortPickerView.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Effort picker (RPE/RIR) with tappable circles + Digital Crown
//

import SwiftUI

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
