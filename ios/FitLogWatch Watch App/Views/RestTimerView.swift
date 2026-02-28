//
//  RestTimerView.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Rest timer (Tab 2) + Quick Add Time picker
//

import SwiftUI

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

    private var locale: String { connectivity.appLocale }
    private var titleText: String { WatchStrings.addTime(locale) }
    private var startText: String { WatchStrings.start(locale) }
    private var cancelText: String { WatchStrings.cancel(locale) }

    var body: some View {
        VStack(spacing: 12) {
            Text(titleText)
                .font(.system(size: 14, weight: .semibold))

            // Time display (large)
            Text(formatTime(timeOptions[selectedIndex]))
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(.blue)
                .accessibilityLabel(
                    WatchStrings.localized(
                        locale,
                        it: "\(timeOptions[selectedIndex]) secondi",
                        en: "\(timeOptions[selectedIndex]) seconds"
                    )
                )

            // Crown hint
            Text(WatchStrings.localized(locale, it: "Usa corona per regolare", en: "Use crown to adjust"))
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

    private var locale: String { connectivity.appLocale }
    private var skipText: String { WatchStrings.skip(locale) }
    private var readyText: String { WatchStrings.ready(locale) }
    private var restText: String { WatchStrings.rest(locale) }
    private var nextSetText: String { WatchStrings.nextSet(locale) }
    private var repsText: String { WatchStrings.reps(locale) }
    private var tapToAddTimeText: String { WatchStrings.tapToAddTime(locale) }
    private var resumeText: String { WatchStrings.resume(locale) }

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
                .accessibilityLabel(
                    WatchStrings.localized(
                        locale,
                        it: "Superset: \(connectivity.supersetName ?? "Superset"), Round \(connectivity.supersetRound) di \(connectivity.totalSupersetRounds)",
                        en: "Superset: \(connectivity.supersetName ?? "Superset"), Round \(connectivity.supersetRound) of \(connectivity.totalSupersetRounds)"
                    )
                )
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
            .accessibilityLabel(connectivity.isTimerPaused ? WatchStrings.localized(locale, it: "Riposo in pausa", en: "Rest paused") : restText)

            // Time display (no animation = battery savings)
            // ✅ Tappable when timer is at 00:00 to add more time
            Text(formatTime(connectivity.restTimeRemaining))
                .font(.system(size: 52, weight: .bold))
                .monospacedDigit()
                .foregroundColor(timerTextColor)
                .accessibilityLabel(
                    WatchStrings.localized(
                        locale,
                        it: "Tempo rimanente: \(formatTime(connectivity.restTimeRemaining))",
                        en: "Time remaining: \(formatTime(connectivity.restTimeRemaining))"
                    )
                )
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

            // Actions area
            if connectivity.restTimeRemaining > 0 {
                if connectivity.isTimerPaused {
                    VStack(spacing: 6) {
                        Button(action: {
                            connectivity.startNewTimer(duration: connectivity.restTimeRemaining)
                            WKInterfaceDevice.current().play(.start)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 11))
                                Text(resumeText)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .accessibilityLabel(resumeText)
                        .accessibilityHint(
                            WatchStrings.localized(
                                locale,
                                it: "Tocca due volte per riprendere il timer di recupero",
                                en: "Double tap to resume the rest timer"
                            )
                        )

                        Button(action: {
                            connectivity.sendSkipRest()
                            WKInterfaceDevice.current().play(.click)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 11))
                                Text(skipText)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                        }
                        .buttonStyle(.bordered)
                        .tint(.secondary)
                        .accessibilityLabel(WatchStrings.skipRest(locale))
                        .accessibilityHint(
                            WatchStrings.localized(
                                locale,
                                it: "Tocca due volte per terminare il riposo e iniziare la serie successiva",
                                en: "Double tap to end rest and start next set"
                            )
                        )
                    }
                    .padding(.horizontal, 20)
                } else {
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
                    .accessibilityLabel(WatchStrings.skipRest(locale))
                    .accessibilityHint(
                        WatchStrings.localized(
                            locale,
                            it: "Tocca due volte per terminare il riposo e iniziare la serie successiva",
                            en: "Double tap to end rest and start next set"
                        )
                    )
                }
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
                .accessibilityLabel(WatchStrings.localized(locale, it: "Pronto per la prossima serie", en: "Ready for next set"))
                .accessibilityHint(WatchStrings.localized(locale, it: "Tocca per aggiungere altro tempo di riposo", en: "Tap to add more rest time"))
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
                    // ⌚ Show rep range if available
                    Text("\(connectivity.repsDisplay) \(repsText)")
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
        .accessibilityLabel(
            connectivity.targetWeight > 0
                ? WatchStrings.localized(
                    locale,
                    it: "Prossima serie: \(formatWeight(connectivity.targetWeight)) chilogrammi per \(connectivity.repsDisplay) ripetizioni. Serie \(connectivity.currentSetNumber) di \(connectivity.totalSets)",
                    en: "Next set: \(formatWeight(connectivity.targetWeight)) kilograms for \(connectivity.repsDisplay) reps. Set \(connectivity.currentSetNumber) of \(connectivity.totalSets)"
                )
                : WatchStrings.localized(locale, it: "Nessun obiettivo impostato", en: "No target set")
        )
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
