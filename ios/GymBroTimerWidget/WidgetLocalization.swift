import Foundation
import SwiftUI

/// Localization helper for GymBro Timer Widget extension
///
/// Provides easy access to localized strings for Live Activities.
/// Uses the widget extension's bundle for string lookup.
enum WidgetStrings {

    // MARK: - Bundle Helper

    private static var bundle: Bundle {
        // Use the widget extension's bundle
        Bundle(for: BundleToken.self)
    }

    private class BundleToken {}

    /// Get localized string with optional arguments
    static func localized(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, bundle: bundle, comment: "")
        if args.isEmpty {
            return format
        }
        return String(format: format, arguments: args)
    }

    // MARK: - Timer Strings

    enum Timer {
        static var rest: String { localized("timer.rest") }
        static var reps: String { localized("timer.reps") }
        static var setCompleted: String { localized("timer.setCompleted") }
        static var rateSet: String { localized("timer.rateSet") }
        static var rpe: String { localized("timer.rpe") }
    }

    // MARK: - RPE Strings

    enum RPE {
        static var confirmed: String { localized("rpe.confirmed") }
        static var waiting: String { localized("rpe.waiting") }
        static var selectRpe: String { localized("rpe.selectRpe") }
    }

    // MARK: - Schedule Strings

    enum Schedule {
        static var go: String { localized("schedule.go") }
        static var start: String { localized("schedule.start") }
        static var left: String { localized("schedule.left") }
        static var remaining: String { localized("schedule.remaining") }
        static var tapToStart: String { localized("schedule.tapToStart") }
        static var scheduledFor: String { localized("schedule.scheduledFor") }
        static var startingSoon: String { localized("schedule.startingSoon") }
        static var timeToWorkout: String { localized("schedule.timeToWorkout") }

        static func inMinutes(_ minutes: Int) -> String {
            localized("schedule.inMinutes", minutes)
        }

        static func inHours(_ hours: Int, _ minutes: Int) -> String {
            localized("schedule.inHours", hours, minutes)
        }
    }

    // MARK: - Common Strings

    enum Common {
        static var set: String { localized("common.set") }
        static var at: String { localized("common.at") }
    }
}

// MARK: - SwiftUI Text Extension

extension Text {
    /// Create localized Text for widget
    init(widgetKey key: String) {
        self.init(WidgetStrings.localized(key))
    }
}
