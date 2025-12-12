import Foundation
import HealthKit
import Flutter

/// Native HealthKit manager for Activity Rings data
/// Uses HKActivitySummaryQuery to get real move/exercise/stand goals
@available(iOS 9.3, *)
class HealthKitActivityManager: NSObject {

    static let shared = HealthKitActivityManager()

    private let healthStore = HKHealthStore()
    private var methodChannel: FlutterMethodChannel?

    // MARK: - Setup

    func setupChannel(with messenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(
            name: "com.gymbro/healthkit_activity",
            binaryMessenger: messenger
        )

        methodChannel?.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(FlutterError(code: "UNAVAILABLE", message: "Manager not available", details: nil))
                return
            }

            switch call.method {
            case "isHealthKitAvailable":
                result(HKHealthStore.isHealthDataAvailable())

            case "requestActivitySummaryPermission":
                self.requestActivitySummaryPermission(result: result)

            case "getActivitySummary":
                self.getActivitySummary(result: result)

            case "getActivitySummaryForDate":
                if let args = call.arguments as? [String: Any],
                   let timestamp = args["timestamp"] as? Double {
                    let date = Date(timeIntervalSince1970: timestamp / 1000)
                    self.getActivitySummary(for: date, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing timestamp", details: nil))
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        Logger.shared.log(.info, "✅ HealthKitActivityManager channel setup completed", category: .general)
    }

    // MARK: - Permission

    private func requestActivitySummaryPermission(result: @escaping FlutterResult) {
        guard HKHealthStore.isHealthDataAvailable() else {
            result(FlutterError(code: "UNAVAILABLE", message: "HealthKit not available on this device", details: nil))
            return
        }

        // We need to read activity summary type
        let activitySummaryType = HKActivitySummaryType.activitySummaryType()
        let readTypes: Set<HKObjectType> = [activitySummaryType]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(code: "PERMISSION_ERROR", message: error.localizedDescription, details: nil))
                } else {
                    result(success)
                }
            }
        }
    }

    // MARK: - Query Activity Summary

    private func getActivitySummary(result: @escaping FlutterResult) {
        getActivitySummary(for: Date(), result: result)
    }

    private func getActivitySummary(for date: Date, result: @escaping FlutterResult) {
        guard HKHealthStore.isHealthDataAvailable() else {
            result(FlutterError(code: "UNAVAILABLE", message: "HealthKit not available", details: nil))
            return
        }

        // Create predicate for the specific date
        let calendar = Calendar.autoupdatingCurrent
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        dateComponents.calendar = calendar

        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)

        let query = HKActivitySummaryQuery(predicate: predicate) { [weak self] query, summaries, error in
            DispatchQueue.main.async {
                if let error = error {
                    Logger.shared.log(.error, "❌ Activity Summary query error: \(error.localizedDescription)", category: .general)
                    result(FlutterError(code: "QUERY_ERROR", message: error.localizedDescription, details: nil))
                    return
                }

                guard let summary = summaries?.first else {
                    // No activity data for this date - return empty data with default goals
                    Logger.shared.log(.info, "ℹ️ No activity summary for date: \(date)", category: .general)
                    result([
                        "hasData": false,
                        "moveCalories": 0.0,
                        "moveGoal": 500.0,  // Default
                        "exerciseMinutes": 0,
                        "exerciseGoal": 30,  // Default
                        "standHours": 0,
                        "standGoal": 12,  // Default
                        "timestamp": date.timeIntervalSince1970 * 1000
                    ])
                    return
                }

                // Extract values and goals
                let data = self?.extractActivityData(from: summary, date: date) ?? [:]
                Logger.shared.log(.info, "✅ Activity Summary fetched: Move \(data["moveCalories"] ?? 0)/\(data["moveGoal"] ?? 0), Exercise \(data["exerciseMinutes"] ?? 0)/\(data["exerciseGoal"] ?? 0), Stand \(data["standHours"] ?? 0)/\(data["standGoal"] ?? 0)", category: .general)
                result(data)
            }
        }

        healthStore.execute(query)
    }

    private func extractActivityData(from summary: HKActivitySummary, date: Date) -> [String: Any] {
        // Units for conversion
        let energyUnit = HKUnit.kilocalorie()
        let minuteUnit = HKUnit.minute()
        let countUnit = HKUnit.count()

        // Current values
        let moveCalories = summary.activeEnergyBurned.doubleValue(for: energyUnit)
        let exerciseMinutes = Int(summary.appleExerciseTime.doubleValue(for: minuteUnit))
        let standHours = Int(summary.appleStandHours.doubleValue(for: countUnit))

        // Goals (the KEY data we need!)
        let moveGoal = summary.activeEnergyBurnedGoal.doubleValue(for: energyUnit)
        let exerciseGoal = Int(summary.appleExerciseTimeGoal.doubleValue(for: minuteUnit))
        let standGoal = Int(summary.appleStandHoursGoal.doubleValue(for: countUnit))

        return [
            "hasData": true,
            "moveCalories": moveCalories,
            "moveGoal": moveGoal,
            "exerciseMinutes": exerciseMinutes,
            "exerciseGoal": exerciseGoal,
            "standHours": standHours,
            "standGoal": standGoal,
            "timestamp": date.timeIntervalSince1970 * 1000
        ]
    }
}
