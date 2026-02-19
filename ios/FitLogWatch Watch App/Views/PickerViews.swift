//
//  PickerViews.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Set picker and exercise picker sheet views
//

import SwiftUI

// MARK: - Set Picker Sheet View

struct SetPickerSheetView: View {
    let totalSets: Int
    let currentSet: Int
    let locale: String
    let allSetsTargets: [(weight: Double, reps: Int, actualReps: Int?, isCompleted: Bool, isWarmup: Bool)]
    let onSelect: (Int) -> Void
    let onCancel: () -> Void

    @State private var selectedSet: Int

    init(totalSets: Int, currentSet: Int, locale: String, allSetsTargets: [(weight: Double, reps: Int, actualReps: Int?, isCompleted: Bool, isWarmup: Bool)] = [], onSelect: @escaping (Int) -> Void, onCancel: @escaping () -> Void) {
        self.totalSets = totalSets
        self.currentSet = currentSet
        self.locale = locale
        self.allSetsTargets = allSetsTargets
        self.onSelect = onSelect
        self.onCancel = onCancel
        // Initialize state with current set value
        _selectedSet = State(initialValue: currentSet)
    }

    private var isItalian: Bool { locale == "it" }
    private var titleText: String { isItalian ? "Seleziona Serie" : "Select Set" }
    private var selectText: String { isItalian ? "Vai" : "Go" }
    private var cancelText: String { isItalian ? "Annulla" : "Cancel" }

    /// Label for a set number: "W" prefix for warmup, normal number otherwise
    private func setLabel(for setNum: Int) -> String {
        let idx = setNum - 1
        if idx >= 0 && idx < allSetsTargets.count && allSetsTargets[idx].isWarmup {
            return "W\(setNum)"
        }
        return "\(isItalian ? "Serie" : "Set") \(setNum)"
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(titleText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)

            // Set picker with Crown
            Picker(titleText, selection: $selectedSet) {
                ForEach(1...totalSets, id: \.self) { setNum in
                    Text(setLabel(for: setNum))
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
