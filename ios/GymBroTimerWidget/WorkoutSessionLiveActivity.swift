import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Workout Session Live Activity Widget
@available(iOS 17.0, *)
struct WorkoutSessionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutSessionAttributes.self) { context in
            // Lock Screen / Banner UI
            LockScreenWorkoutView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }

                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(context: context)
                }

            } compactLeading: {
                CompactLeadingView(context: context)

            } compactTrailing: {
                CompactTrailingView(context: context)

            } minimal: {
                MinimalView(context: context)
            }
            .widgetURL(URL(string: "gymbro://workout/\(context.attributes.workoutId)"))
            .keylineTint(context.state.accentColor)
        }
    }
}

// MARK: - Lock Screen View (Compact - max ~160pt height)
@available(iOS 17.0, *)
struct LockScreenWorkoutView: View {
    let context: ActivityViewContext<WorkoutSessionAttributes>

    var body: some View {
        VStack(spacing: 8) {
            // Uses effectiveMode for auto-transition when rest expires
            switch context.state.effectiveMode {
            case .exercise:
                ExerciseModeView(context: context)
            case .rest:
                RestModeView(context: context)
            case .rpe:
                RPEModeView(context: context)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .activityBackgroundTint(Color(.systemBackground))
    }
}

// MARK: - Exercise Mode View (Compact)
@available(iOS 17.0, *)
struct ExerciseModeView: View {
    let context: ActivityViewContext<WorkoutSessionAttributes>

    var body: some View {
        VStack(spacing: 6) {
            // Row 1: Exercise name + timer
            HStack {
                Text(context.state.exerciseName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)

                Spacer()

                Text(timerInterval: context.state.workoutStartDate...Date.distantFuture, countsDown: false)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.green)
            }

            // Row 2: Set + Weight/Reps info
            HStack {
                Text(context.state.setInfo)
                    .font(.subheadline)
                    .foregroundColor(.blue)

                Text("•")
                    .foregroundColor(.secondary)

                Text(context.state.weightRepsInfo)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Text(context.state.exerciseProgressInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Button - 44pt minimum
            Button(intent: WorkoutCompleteSetIntent()) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                    Text(WidgetStrings.WorkoutSession.done)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Rest Mode View (Compact)
@available(iOS 17.0, *)
struct RestModeView: View {
    let context: ActivityViewContext<WorkoutSessionAttributes>

    var body: some View {
        VStack(spacing: 6) {
            // Row 1: Timer + next set info
            HStack {
                // Check if paused - show static time instead of countdown
                if context.state.isPaused {
                    // Paused: show static remaining time with pause icon
                    HStack(spacing: 4) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 20))
                        Text(formatPausedTime(context.state.pausedRemainingSeconds ?? context.state.restRemainingSeconds))
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.orange)
                } else if let startDate = context.state.restStartDate,
                   let endDate = context.state.restEndDate {
                    // Running: show countdown timer
                    Text(timerInterval: startDate...endDate, countsDown: true)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(context.state.restUrgencyColor)
                }

                Spacer()

                // Next set info
                VStack(alignment: .trailing, spacing: 2) {
                    Text(context.state.isPaused
                         ? WidgetStrings.WorkoutSession.paused
                         : WidgetStrings.WorkoutSession.next)
                        .font(.caption2)
                        .foregroundColor(context.state.isPaused ? .orange : .secondary)
                    Text(context.state.setInfo)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            // Progress bar (hide when paused)
            if !context.state.isPaused,
               let startDate = context.state.restStartDate,
               let endDate = context.state.restEndDate {
                ProgressView(
                    timerInterval: startDate...endDate,
                    countsDown: true,
                    label: { EmptyView() },
                    currentValueLabel: { EmptyView() }
                )
                .progressViewStyle(LinearProgressViewStyle())
                .tint(context.state.restUrgencyColor)
            } else if context.state.isPaused {
                // Show static progress bar when paused
                let remaining = context.state.pausedRemainingSeconds ?? context.state.restRemainingSeconds
                let total = context.state.restTotalSeconds
                let progress = total > 0 ? Double(total - remaining) / Double(total) : 0.0
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(.orange)
            }

            // Row 2: Exercise name
            Text(context.state.exerciseName)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Buttons - 44pt minimum
            HStack(spacing: 8) {
                Button(intent: WorkoutSkipRestIntent()) {
                    HStack(spacing: 4) {
                        Image(systemName: "forward.fill")
                        Text(WidgetStrings.WorkoutSession.skip)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                Button(intent: WorkoutAddTimeIntent()) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("+30s")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
    }

    /// Format seconds as MM:SS for paused display
    private func formatPausedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - RPE Mode View (Compact)
@available(iOS 17.0, *)
struct RPEModeView: View {
    let context: ActivityViewContext<WorkoutSessionAttributes>

    var body: some View {
        VStack(spacing: 6) {
            // Row 1: Completed set + RPE badge
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)

                Text(context.state.exerciseName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text("•")
                    .foregroundColor(.secondary)

                Text(context.state.setInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if let rpe = context.state.selectedRPE {
                    Text("RPE \(rpe)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(context.state.rpeColor(for: rpe))
                }
            }

            // RPE selector - 44pt minimum tap targets
            HStack(spacing: 6) {
                ForEach([6, 7, 8, 9, 10], id: \.self) { rpe in
                    Button(intent: WorkoutSelectRPEIntent(rpeValue: rpe)) {
                        Text("\(rpe)")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(
                                context.state.selectedRPE == rpe
                                    ? context.state.rpeColor(for: rpe)
                                    : Color(.systemGray5)
                            )
                            .foregroundColor(
                                context.state.selectedRPE == rpe
                                    ? .white
                                    : .primary
                            )
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Confirm button
            Button(intent: WorkoutConfirmRPEIntent()) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                    Text(context.state.selectedRPE != nil
                         ? WidgetStrings.WorkoutSession.confirm
                         : WidgetStrings.WorkoutSession.skipRpe)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(context.state.selectedRPE != nil
                    ? context.state.rpeColor(for: context.state.selectedRPE ?? 7)
                    : Color(.systemGray4))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Dynamic Island Views

@available(iOS 17.0, *)
struct ExpandedLeadingView: View {
    let context: ActivityViewContext<WorkoutSessionAttributes>

    var body: some View {
        HStack {
            Image(systemName: context.state.modeIcon)
                .foregroundColor(context.state.accentColor)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(context.state.exerciseName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(context.state.setInfo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

@available(iOS 17.0, *)
struct ExpandedTrailingView: View {
    let context: ActivityViewContext<WorkoutSessionAttributes>

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            switch context.state.effectiveMode {
            case .exercise:
                Image(systemName: "hand.tap.fill")
                    .foregroundColor(.green)
                Text(WidgetStrings.WorkoutSession.tapDone)
                    .font(.caption2)
                    .foregroundColor(.secondary)

            case .rest:
                if context.state.isPaused {
                    // Paused: show static time
                    let remaining = context.state.pausedRemainingSeconds ?? context.state.restRemainingSeconds
                    HStack(spacing: 2) {
                        Image(systemName: "pause.fill")
                            .font(.caption)
                        Text(formatTime(remaining))
                            .font(.title2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                    .foregroundColor(.orange)
                } else if let startDate = context.state.restStartDate,
                   let endDate = context.state.restEndDate {
                    Text(timerInterval: startDate...endDate, countsDown: true)
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundColor(context.state.restUrgencyColor)
                }
                Text(context.state.isPaused
                     ? WidgetStrings.WorkoutSession.pause
                     : WidgetStrings.WorkoutSession.rest)
                    .font(.caption2)
                    .foregroundColor(context.state.isPaused ? .orange : .secondary)

            case .rpe:
                if let rpe = context.state.selectedRPE {
                    Text("RPE \(rpe)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(context.state.rpeColor(for: rpe))
                } else {
                    Text("RPE?")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

@available(iOS 17.0, *)
struct ExpandedCenterView: View {
    let context: ActivityViewContext<WorkoutSessionAttributes>

    var body: some View {
        // Workout duration timer
        Text(timerInterval: context.state.workoutStartDate...Date.distantFuture, countsDown: false)
            .font(.caption2)
            .foregroundColor(.secondary)
    }
}

@available(iOS 17.0, *)
struct ExpandedBottomView: View {
    let context: ActivityViewContext<WorkoutSessionAttributes>

    var body: some View {
        switch context.state.effectiveMode {
        case .exercise:
            // Complete set button
            Button(intent: WorkoutCompleteSetIntent()) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text(WidgetStrings.WorkoutSession.done)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)

        case .rest:
            // Progress bar
            if let startDate = context.state.restStartDate,
               let endDate = context.state.restEndDate {
                ProgressView(
                    timerInterval: startDate...endDate,
                    countsDown: true,
                    label: { EmptyView() },
                    currentValueLabel: { EmptyView() }
                )
                .progressViewStyle(LinearProgressViewStyle())
                .tint(context.state.restUrgencyColor)
                .scaleEffect(y: 2.0)
            }

        case .rpe:
            // RPE quick selector - 44pt minimum for accessibility
            HStack(spacing: 6) {
                ForEach([6, 7, 8, 9, 10], id: \.self) { rpe in
                    Button(intent: WorkoutSelectRPEIntent(rpeValue: rpe)) {
                        Text("\(rpe)")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 40, height: 36)
                            .background(
                                context.state.selectedRPE == rpe
                                    ? context.state.rpeColor(for: rpe)
                                    : Color(.systemGray5)
                            )
                            .foregroundColor(
                                context.state.selectedRPE == rpe ? .white : .primary
                            )
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

@available(iOS 17.0, *)
struct CompactLeadingView: View {
    let context: ActivityViewContext<WorkoutSessionAttributes>

    var body: some View {
        ZStack {
            Circle()
                .fill(context.state.accentColor.opacity(0.3))
                .frame(width: 22, height: 22)

            Image(systemName: context.state.modeIcon)
                .font(.system(size: 10))
                .foregroundColor(context.state.accentColor)
        }
    }
}

@available(iOS 17.0, *)
struct CompactTrailingView: View {
    let context: ActivityViewContext<WorkoutSessionAttributes>

    var body: some View {
        switch context.state.effectiveMode {
        case .exercise:
            Text("S\(context.state.currentSet)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)

        case .rest:
            if context.state.isPaused {
                // Show pause icon when paused
                Image(systemName: "pause.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.orange)
            } else if let startDate = context.state.restStartDate,
               let endDate = context.state.restEndDate {
                Text(timerInterval: startDate...endDate, countsDown: true)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(context.state.restUrgencyColor)
            }

        case .rpe:
            if let rpe = context.state.selectedRPE {
                Text("\(rpe)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(context.state.rpeColor(for: rpe))
            } else {
                Text("?")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.orange)
            }
        }
    }
}

@available(iOS 17.0, *)
struct MinimalView: View {
    let context: ActivityViewContext<WorkoutSessionAttributes>

    var body: some View {
        ZStack {
            Circle()
                .fill(context.state.accentColor)
                .frame(width: 12, height: 12)

            switch context.state.effectiveMode {
            case .exercise:
                Image(systemName: "checkmark")
                    .font(.system(size: 6, weight: .bold))
                    .foregroundColor(.white)
            case .rest:
                // Pulsing animation for rest
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
            case .rpe:
                Image(systemName: "star.fill")
                    .font(.system(size: 6))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview Provider
@available(iOS 17.0, *)
struct WorkoutSessionLiveActivity_Previews: PreviewProvider {
    static let attributes = WorkoutSessionAttributes(
        workoutId: "preview-123",
        workoutName: "Push Day"
    )

    static let exerciseState = WorkoutSessionAttributes.ContentState(
        mode: .exercise,
        exerciseName: "Panca Piana",
        currentSet: 2,
        totalSets: 4,
        weight: 80.0,
        targetReps: 10,
        workoutStartDate: Date().addingTimeInterval(-300),
        restStartDate: nil,
        restEndDate: nil,
        restTotalSeconds: 0,
        selectedRPE: nil,
        actualReps: nil,
        rpeEnabled: true,
        completedExercises: 1,
        totalExercises: 6,
        lastUpdated: Date(),
        isPaused: false,
        pausedRemainingSeconds: nil
    )

    static let restState = WorkoutSessionAttributes.ContentState(
        mode: .rest,
        exerciseName: "Panca Piana",
        currentSet: 3,
        totalSets: 4,
        weight: 80.0,
        targetReps: 10,
        workoutStartDate: Date().addingTimeInterval(-300),
        restStartDate: Date(),
        restEndDate: Date().addingTimeInterval(90),
        restTotalSeconds: 90,
        selectedRPE: nil,
        actualReps: nil,
        rpeEnabled: true,
        completedExercises: 1,
        totalExercises: 6,
        lastUpdated: Date(),
        isPaused: false,
        pausedRemainingSeconds: nil
    )

    static var previews: some View {
        Group {
            attributes
                .previewContext(exerciseState, viewKind: .content)
                .previewDisplayName("Exercise Mode")

            attributes
                .previewContext(restState, viewKind: .content)
                .previewDisplayName("Rest Mode")
        }
    }
}
