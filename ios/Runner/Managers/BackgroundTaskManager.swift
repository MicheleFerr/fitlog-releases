import BackgroundTasks
import UIKit

/// Protocol for testability
protocol BackgroundTaskManaging {
    func registerTasks()
    func scheduleAppRefresh()
    func scheduleProcessingTask()
    func cancelAllTasks()
    func isBackgroundRefreshAvailable() -> Bool
}

/// Manages BGTaskScheduler with retry logic and health checks
@available(iOS 13.0, *)
final class BackgroundTaskManager: BackgroundTaskManaging {
    
    // MARK: - Constants
    
    private enum TaskIdentifier {
        static let appRefresh = "com.gymbro.timer.refresh"
        static let processing = "com.gymbro.timer.processing"
    }
    
    private enum Configuration {
        static let maxRetryAttempts = 3
        static let retryDelay: TimeInterval = 2.0
        static let appRefreshInterval: TimeInterval = 60.0  // 1 minute
        static let processingInterval: TimeInterval = 300.0 // 5 minutes
    }
    
    // MARK: - Properties
    
    static let shared = BackgroundTaskManager()
    
    private var registrationAttempts = 0
    private var lastScheduleAttempt: Date?
    private let scheduler = BGTaskScheduler.shared
    private let queue = DispatchQueue(label: "com.gymbro.background.tasks", qos: .background)
    
    // Health monitoring
    private var successfulTaskCompletions = 0
    private var failedTaskAttempts = 0
    
    // MARK: - Initialization
    
    private init() {
        Logger.shared.log(.info, "BackgroundTaskManager initialized")
    }
    
    // MARK: - Public Methods
    
    func registerTasks() {
        guard isBackgroundRefreshAvailable() else {
            Logger.shared.log(.warning, "Background refresh not available, skipping registration")
            PermissionManager.shared.requestBackgroundRefreshIfNeeded()
            return
        }
        
        registerAppRefreshTask()
        registerProcessingTask()
    }
    
    func scheduleAppRefresh() {
        queue.async { [weak self] in
            self?.scheduleTaskWithRetry(
                identifier: TaskIdentifier.appRefresh,
                interval: Configuration.appRefreshInterval,
                taskType: .appRefresh
            )
        }
    }
    
    func scheduleProcessingTask() {
        queue.async { [weak self] in
            self?.scheduleTaskWithRetry(
                identifier: TaskIdentifier.processing,
                interval: Configuration.processingInterval,
                taskType: .processing
            )
        }
    }
    
    func cancelAllTasks() {
        scheduler.cancelAllTaskRequests()
        Logger.shared.log(.info, "All background tasks cancelled")
    }
    
    func isBackgroundRefreshAvailable() -> Bool {
        let status = UIApplication.shared.backgroundRefreshStatus
        
        switch status {
        case .available:
            return true
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: - Private Methods - Registration
    
    private func registerAppRefreshTask() {
        let success = scheduler.register(
            forTaskWithIdentifier: TaskIdentifier.appRefresh,
            using: nil
        ) { [weak self] task in
            self?.handleAppRefreshTask(task as! BGAppRefreshTask)
        }
        
        Logger.shared.log(
            success ? .info : .error,
            "App refresh task registration: \(success ? "✅ Success" : "❌ Failed")"
        )
    }
    
    private func registerProcessingTask() {
        let success = scheduler.register(
            forTaskWithIdentifier: TaskIdentifier.processing,
            using: nil
        ) { [weak self] task in
            self?.handleProcessingTask(task as! BGProcessingTask)
        }
        
        Logger.shared.log(
            success ? .info : .error,
            "Processing task registration: \(success ? "✅ Success" : "❌ Failed")"
        )
    }
    
    // MARK: - Private Methods - Task Handlers
    
    private func handleAppRefreshTask(_ task: BGAppRefreshTask) {
        Logger.shared.log(.info, "🔄 Executing app refresh task")
        
        // Set expiration handler
        task.expirationHandler = { [weak self] in
            Logger.shared.log(.warning, "App refresh task expired")
            self?.failedTaskAttempts += 1
            task.setTaskCompleted(success: false)
        }
        
        // Schedule next refresh
        scheduleAppRefresh()
        
        // Perform work
        queue.async { [weak self] in
            // Reactivate audio session if needed
            AudioSessionManager.shared.reactivate()
            
            // ENHANCED: Check and restart silent loop if needed for active timers
            self?.maintainSilentLoopIfNeeded()
            
            // Mark completion
            self?.successfulTaskCompletions += 1
            task.setTaskCompleted(success: true)
            
            Logger.shared.log(.info, "✅ App refresh task completed successfully")
        }
    }
    
    private func handleProcessingTask(_ task: BGProcessingTask) {
        Logger.shared.log(.info, "🔄 Executing background processing task")
        
        // Set expiration handler
        task.expirationHandler = { [weak self] in
            Logger.shared.log(.warning, "Processing task expired")
            self?.failedTaskAttempts += 1
            task.setTaskCompleted(success: false)
        }
        
        // Schedule next processing
        scheduleProcessingTask()
        
        // Perform work
        queue.async { [weak self] in
            // Configure audio for background if needed
            AudioSessionManager.shared.transitionToBackground()
            
            // ENHANCED: Ensure silent loop system is operational
            self?.ensureSilentLoopSystem()
            
            // Validate configuration
            let isValid = AudioSessionManager.shared.validateConfiguration()
            
            // Mark completion
            if isValid {
                self?.successfulTaskCompletions += 1
                task.setTaskCompleted(success: true)
                Logger.shared.log(.info, "✅ Processing task completed successfully")
            } else {
                self?.failedTaskAttempts += 1
                task.setTaskCompleted(success: false)
                Logger.shared.log(.error, "❌ Processing task failed validation")
            }
        }
    }
    
    // MARK: - Private Methods - Scheduling with Retry
    
    private enum TaskType {
        case appRefresh
        case processing
    }
    
    private func scheduleTaskWithRetry(
        identifier: String,
        interval: TimeInterval,
        taskType: TaskType,
        attemptNumber: Int = 1
    ) {
        // Rate limiting
        if let lastAttempt = lastScheduleAttempt,
           Date().timeIntervalSince(lastAttempt) < 1.0 {
            Logger.shared.log(.debug, "Rate limiting task scheduling")
            return
        }
        
        lastScheduleAttempt = Date()
        
        // Create request based on type
        let request: BGTaskRequest
        
        switch taskType {
        case .appRefresh:
            request = BGAppRefreshTaskRequest(identifier: identifier)
        case .processing:
            request = BGProcessingTaskRequest(identifier: identifier)
        }
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: interval)
        
        do {
            try scheduler.submit(request)
            Logger.shared.log(.info, "✅ Task scheduled: \(identifier) for \(interval)s from now")
            
        } catch let error as NSError {
            handleSchedulingError(
                error,
                identifier: identifier,
                interval: interval,
                taskType: taskType,
                attemptNumber: attemptNumber
            )
        }
    }
    
    private func handleSchedulingError(
        _ error: NSError,
        identifier: String,
        interval: TimeInterval,
        taskType: TaskType,
        attemptNumber: Int
    ) {
        Logger.shared.log(.error, """
            ❌ Task scheduling failed:
            - Identifier: \(identifier)
            - Error code: \(error.code)
            - Description: \(error.localizedDescription)
            - Attempt: \(attemptNumber)/\(Configuration.maxRetryAttempts)
            """)
        
        // Handle specific error codes
        switch error.code {
        case 3: // BGTaskSchedulerErrorCodeUnavailable
            Logger.shared.log(.warning, "Background App Refresh disabled by user")
            PermissionManager.shared.requestBackgroundRefreshIfNeeded()
            
        case 1: // BGTaskSchedulerErrorCodeNotPermitted
            Logger.shared.log(.error, "Task identifier not in Info.plist")
            
        case 2: // BGTaskSchedulerErrorCodeTooManyPendingTaskRequests
            Logger.shared.log(.warning, "Too many pending tasks, clearing queue")
            cancelAllTasks()
            // Retry after clearing
            if attemptNumber <= Configuration.maxRetryAttempts {
                retryScheduling(
                    identifier: identifier,
                    interval: interval,
                    taskType: taskType,
                    attemptNumber: attemptNumber + 1
                )
            }
            
        default:
            // Generic retry for unknown errors
            if attemptNumber <= Configuration.maxRetryAttempts {
                retryScheduling(
                    identifier: identifier,
                    interval: interval,
                    taskType: taskType,
                    attemptNumber: attemptNumber + 1
                )
            } else {
                failedTaskAttempts += 1
                ErrorRecoveryManager.shared.handle(
                    error,
                    context: .backgroundTask,
                    strategy: .alert(message: "Background tasks unavailable. Timer may not work in background.")
                )
            }
        }
    }
    
    private func retryScheduling(
        identifier: String,
        interval: TimeInterval,
        taskType: TaskType,
        attemptNumber: Int
    ) {
        let delay = Configuration.retryDelay * Double(attemptNumber)
        
        Logger.shared.log(.info, "Retrying task scheduling in \(delay)s...")
        
        queue.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.scheduleTaskWithRetry(
                identifier: identifier,
                interval: interval,
                taskType: taskType,
                attemptNumber: attemptNumber
            )
        }
    }
    
    // MARK: - Debug & Monitoring
    
    func getHealthMetrics() -> [String: Any] {
        return [
            "backgroundRefreshAvailable": isBackgroundRefreshAvailable(),
            "successfulCompletions": successfulTaskCompletions,
            "failedAttempts": failedTaskAttempts,
            "successRate": successfulTaskCompletions > 0 ?
                Double(successfulTaskCompletions) / Double(successfulTaskCompletions + failedTaskAttempts) : 0.0,
            "silentLoopActive": BackgroundAudioManager.shared.isSilentLoopActive(),
            "audioSessionValid": AudioSessionManager.shared.validateConfiguration()
        ]
    }
    
    // MARK: - Silent Loop Integration
    
    /// Maintains silent loop for active timers during background refresh
    private func maintainSilentLoopIfNeeded() {
        // Check if there are active timers that need silent loop
        // This would typically check with a timer manager or state
        Logger.shared.log(.debug, "Checking silent loop maintenance needs")
        
        // For now, we'll let BackgroundAudioManager handle its own state
        // In a full implementation, you'd check timer state here
    }
    
    /// Ensures silent loop system is ready for background processing
    private func ensureSilentLoopSystem() {
        do {
            // Configure audio session for silent loop if needed
            try AudioSessionManager.shared.configureSilentLoopSession()
            Logger.shared.log(.info, "Silent loop system ensured during processing task")
        } catch {
            Logger.shared.log(.error, "Failed to ensure silent loop system: \(error)")
        }
    }
}

// MARK: - iOS 12 Fallback

final class BackgroundTaskManagerLegacy: BackgroundTaskManaging {
    
    static let shared = BackgroundTaskManagerLegacy()
    
    private init() {
        Logger.shared.log(.warning, "Using legacy background task manager (iOS < 13) - silent loop still available")
    }
    
    func registerTasks() {
        Logger.shared.log(.info, "Legacy: Using UIApplication background modes only")
    }
    
    func scheduleAppRefresh() {
        // Use UIApplication background task for iOS < 13
        UIApplication.shared.setMinimumBackgroundFetchInterval(
            UIApplication.backgroundFetchIntervalMinimum
        )
    }
    
    func scheduleProcessingTask() {
        // Not available in iOS < 13
        Logger.shared.log(.debug, "Processing tasks not available in iOS < 13")
    }
    
    func cancelAllTasks() {
        UIApplication.shared.setMinimumBackgroundFetchInterval(
            UIApplication.backgroundFetchIntervalNever
        )
    }
    
    func isBackgroundRefreshAvailable() -> Bool {
        return UIApplication.shared.backgroundRefreshStatus == .available
    }
}