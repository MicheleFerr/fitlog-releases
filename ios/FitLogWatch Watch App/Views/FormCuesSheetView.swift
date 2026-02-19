//
//  FormCuesSheetView.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Form cues / technique notes sheet with TUT breakdown
//

import SwiftUI

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
