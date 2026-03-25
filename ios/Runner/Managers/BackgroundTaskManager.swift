import UIKit

/// Protocol for testability
protocol BackgroundTaskManaging {
    func registerTasks()
    func scheduleAppRefresh()
    func scheduleProcessingTask()
    func cancelAllTasks()
    func isBackgroundRefreshAvailable() -> Bool
}

/// The rest timer no longer relies on BGTaskScheduler.
/// This manager remains as a lightweight compatibility surface for other code.
final class BackgroundTaskManager: BackgroundTaskManaging {

    static let shared = BackgroundTaskManager()

    private init() {
        Logger.shared.log(.info, "BackgroundTaskManager initialized")
    }

    func registerTasks() {
        Logger.shared.log(
            .info,
            "Background task registration skipped: timer-specific BGTask usage has been removed",
            category: .backgroundTask
        )
    }

    func scheduleAppRefresh() {
        Logger.shared.log(
            .debug,
            "App refresh scheduling skipped: rest timer uses local notifications instead of BGTaskScheduler",
            category: .backgroundTask
        )
    }

    func scheduleProcessingTask() {
        Logger.shared.log(
            .debug,
            "Processing task scheduling skipped: rest timer uses local notifications instead of BGTaskScheduler",
            category: .backgroundTask
        )
    }

    func cancelAllTasks() {
        Logger.shared.log(.debug, "No timer-specific background tasks to cancel", category: .backgroundTask)
    }

    func isBackgroundRefreshAvailable() -> Bool {
        UIApplication.shared.backgroundRefreshStatus == .available
    }

    func getHealthMetrics() -> [String: Any] {
        [
            "backgroundRefreshAvailable": isBackgroundRefreshAvailable(),
            "scheduledTasksEnabled": false,
            "mode": "notification_owned_timer_completion"
        ]
    }
}
