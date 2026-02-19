import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Schedule Countdown Activity Attributes

/// Attributes for scheduled workout countdown Live Activity
/// Shows countdown to upcoming scheduled workout on lock screen
struct GymBroScheduleAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic data that changes during countdown
        var scheduledDate: Date           // When workout is scheduled
        var remainingMinutes: Int         // Minutes until workout
        var isStartingSoon: Bool          // True if < 30 min remaining
        var lastUpdated: Date
    }

    // Static data that doesn't change
    var workoutName: String               // Template name
    var workoutId: String                 // Template ID for deep linking
    var reminderTime: Date?               // Optional reminder time
}

// MARK: - Schedule Helper Extensions
extension GymBroScheduleAttributes.ContentState {

    /// Calculate actual remaining time from scheduledDate
    var actualRemainingMinutes: Int {
        let now = Date()
        let remaining = scheduledDate.timeIntervalSince(now) / 60.0
        return max(0, Int(remaining))
    }

    /// Check if countdown is complete
    var isTimeUp: Bool {
        return actualRemainingMinutes <= 0
    }

    /// Formatted remaining time string
    var formattedTimeRemaining: String {
        let minutes = actualRemainingMinutes
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(mins)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return WidgetStrings.Schedule.go
        }
    }

    /// Short formatted time for compact views
    var shortTimeRemaining: String {
        let minutes = actualRemainingMinutes
        if minutes >= 60 {
            return "\(minutes/60)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return WidgetStrings.Schedule.go
        }
    }

    /// Progress for visual indicator (1.0 = close to workout, 0.0 = far away)
    var countdownProgress: Double {
        // MEDIO-7 FIX: Use lastUpdated (state push time) as the activity's "start"
        // so the denominator reflects the actual tracking window rather than a
        // hardcoded 24h constant that made the bar nearly invisible for short windows.
        //
        // Progress = elapsed / total_window
        // elapsed = scheduledDate - now
        // total_window = scheduledDate - lastUpdated
        //
        // Clamped to a minimum of 30 min to avoid division issues when
        // lastUpdated ≈ scheduledDate (i.e. state updated right before workout).
        let minimumWindowSeconds: TimeInterval = 30.0 * 60.0 // 30 minutes
        let totalWindow = max(minimumWindowSeconds, scheduledDate.timeIntervalSince(lastUpdated))
        let remaining = max(0, scheduledDate.timeIntervalSinceNow)
        return min(1.0, max(0.0, remaining / totalWindow))
    }

    /// Color based on urgency
    var urgencyColor: Color {
        let minutes = actualRemainingMinutes
        if minutes <= 0 {
            return Color.green // Time to start!
        } else if minutes <= 5 {
            return Color.red // Very urgent
        } else if minutes <= 15 {
            return Color.orange // Getting close
        } else if minutes <= 30 {
            return Color(.systemOrange) // Attention
        } else if minutes <= 60 {
            return Color(.systemBlue) // Normal
        } else {
            return Color(.systemGray) // Plenty of time
        }
    }

    /// Status text for lock screen (localized)
    var statusText: String {
        let minutes = actualRemainingMinutes
        if minutes <= 0 {
            return WidgetStrings.Schedule.timeToWorkout
        } else if minutes <= 5 {
            return WidgetStrings.localized("schedule.getReady")
        } else if minutes <= 15 {
            return WidgetStrings.Schedule.startingSoon
        } else if minutes <= 30 {
            return WidgetStrings.localized("schedule.prepare")
        } else if minutes <= 60 {
            return WidgetStrings.localized("schedule.comingUp")
        } else {
            return WidgetStrings.Schedule.scheduledFor
        }
    }

    /// Icon name based on urgency
    var iconName: String {
        let minutes = actualRemainingMinutes
        if minutes <= 0 {
            return "figure.run"
        } else if minutes <= 15 {
            return "timer"
        } else {
            return "calendar.badge.clock"
        }
    }

    /// Scheduled time formatted for display
    var scheduledTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: scheduledDate)
    }
}
