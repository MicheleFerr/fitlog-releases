import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Workout Session Mode
/// Represents the current state of the workout session Live Activity
enum WorkoutSessionMode: String, Codable, Hashable {
    case exercise   // User should complete the current set
    case rest       // Rest timer countdown between sets
    case rpe        // RPE selection after completing a set
}

// MARK: - Workout Session Attributes
/// Unified Live Activity that persists throughout the entire workout
/// Transitions between exercise, rest, and RPE modes without flickering
@available(iOS 16.1, *)
struct WorkoutSessionAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {
        // Current mode
        var mode: WorkoutSessionMode

        // Exercise info
        var exerciseName: String
        var currentSet: Int
        var totalSets: Int
        var weight: Double
        var targetReps: Int

        // Workout timer (always running)
        var workoutStartDate: Date

        // Rest timer (only in .rest mode)
        var restStartDate: Date?
        var restEndDate: Date?
        var restTotalSeconds: Int

        // RPE data (only in .rpe mode)
        var selectedRPE: Int?
        var actualReps: Int?
        var rpeEnabled: Bool

        // Progress tracking
        var completedExercises: Int
        var totalExercises: Int

        // Last update timestamp
        var lastUpdated: Date

        // Pause state for rest timer
        var isPaused: Bool
        var pausedRemainingSeconds: Int?  // Time remaining when paused
    }

    // Static data (doesn't change during workout)
    var workoutId: String
    var workoutName: String
}

// MARK: - Content State Extensions
@available(iOS 16.1, *)
extension WorkoutSessionAttributes.ContentState {

    // MARK: - Workout Timer

    /// Elapsed workout time in seconds
    var workoutElapsedSeconds: TimeInterval {
        return Date().timeIntervalSince(workoutStartDate)
    }

    /// Formatted workout duration (HH:MM:SS or MM:SS)
    var formattedWorkoutDuration: String {
        let elapsed = Int(workoutElapsedSeconds)
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Rest Timer

    /// Remaining rest time in seconds
    var restRemainingSeconds: Int {
        guard let endDate = restEndDate, mode == .rest else {
            return 0
        }
        let remaining = endDate.timeIntervalSinceNow
        return max(0, Int(remaining))
    }

    /// Rest progress (0.0 to 1.0)
    var restProgress: Double {
        guard restTotalSeconds > 0, mode == .rest else { return 0.0 }
        let elapsed = restTotalSeconds - restRemainingSeconds
        return Double(elapsed) / Double(restTotalSeconds)
    }

    /// Check if rest timer completed
    var isRestComplete: Bool {
        return mode == .rest && restRemainingSeconds <= 0
    }

    /// Effective mode - handles auto-transition from REST to EXERCISE
    /// when rest timer expires (since iOS blocks background LA updates)
    var effectiveMode: WorkoutSessionMode {
        if isRestComplete {
            return .exercise
        }
        return mode
    }

    /// Formatted rest time (MM:SS)
    var formattedRestTime: String {
        let seconds = restRemainingSeconds
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    // MARK: - Colors

    /// Color based on rest urgency
    var restUrgencyColor: Color {
        let remaining = restRemainingSeconds
        if remaining <= 10 {
            return Color.red
        } else if remaining <= 30 {
            return Color.orange
        } else if remaining <= 60 {
            return Color(.systemOrange)
        } else {
            return Color(.systemBlue)
        }
    }

    /// Primary accent color based on mode
    var accentColor: Color {
        switch mode {
        case .exercise:
            return Color(.systemGreen)
        case .rest:
            return restUrgencyColor
        case .rpe:
            return Color(.systemOrange)
        }
    }

    // MARK: - Status Text

    /// Main status text based on mode
    var statusText: String {
        switch mode {
        case .exercise:
            return "Completa il Set"
        case .rest:
            if restRemainingSeconds <= 10 {
                return "Preparati! 💪"
            } else if restRemainingSeconds <= 30 {
                return "Quasi pronto..."
            } else {
                return "Riposo"
            }
        case .rpe:
            return "Come ti sei sentito?"
        }
    }

    /// Mode icon
    var modeIcon: String {
        switch mode {
        case .exercise:
            return "dumbbell.fill"
        case .rest:
            return "timer"
        case .rpe:
            return "star.fill"
        }
    }

    // MARK: - Set Info

    /// Set info string (e.g., "Set 2/4")
    var setInfo: String {
        return "Set \(currentSet)/\(totalSets)"
    }

    /// Weight and reps string (e.g., "80kg × 10")
    var weightRepsInfo: String {
        let weightStr = weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
        return "\(weightStr)kg × \(targetReps)"
    }

    /// Exercise progress string (e.g., "3/8 esercizi")
    var exerciseProgressInfo: String {
        return "\(completedExercises)/\(totalExercises) esercizi"
    }

    // MARK: - RPE Helpers

    /// RPE color based on value
    func rpeColor(for rpe: Int) -> Color {
        switch rpe {
        case 5...6:
            return Color.green
        case 7...8:
            return Color.orange
        case 9...10:
            return Color.red
        default:
            return Color.gray
        }
    }

    /// RPE description
    var rpeDescription: String {
        guard let rpe = selectedRPE else { return "" }
        switch rpe {
        case 5: return "Molto Facile"
        case 6: return "Facile"
        case 7: return "Moderato"
        case 8: return "Difficile"
        case 9: return "Molto Difficile"
        case 10: return "Massimo Sforzo"
        default: return ""
        }
    }
}

// MARK: - Widget Localization Strings
extension WidgetStrings {
    struct WorkoutSession {
        static let completeSet = "Completa il Set"
        static let rest = "Riposo"
        static let rpe = "RPE"
        static let done = "Fatto"
        static let skip = "Salta"
        static let confirm = "Conferma"
        static let workout = "Allenamento"
        static let set = "Set"
        static let exercises = "esercizi"
    }
}
