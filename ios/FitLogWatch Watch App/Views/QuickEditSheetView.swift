//
//  QuickEditSheetView.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Quick edit sheet for weight and reps with Digital Crown
//

import SwiftUI

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
