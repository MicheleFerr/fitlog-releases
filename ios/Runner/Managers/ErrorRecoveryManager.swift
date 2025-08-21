import Foundation
import UIKit
import AVFoundation

/// Centralized error handling and recovery strategies
final class ErrorRecoveryManager {
    
    // MARK: - Error Context
    
    enum ErrorContext {
        case audioSession
        case backgroundTask
        case liveActivity
        case network
        case database
        case general
        
        var displayName: String {
            switch self {
            case .audioSession: return "Audio System"
            case .backgroundTask: return "Background Processing"
            case .liveActivity: return "Live Activity"
            case .network: return "Network Connection"
            case .database: return "Data Storage"
            case .general: return "System"
            }
        }
    }
    
    // MARK: - Recovery Strategy
    
    enum RecoveryStrategy {
        case retry(attempts: Int, delay: TimeInterval)
        case fallback(handler: () -> Void)
        case ignore
        case alert(message: String)
        case log
        
        var debugDescription: String {
            switch self {
            case .retry(let attempts, let delay):
                return "Retry \(attempts) times with \(delay)s delay"
            case .fallback:
                return "Execute fallback handler"
            case .ignore:
                return "Ignore error"
            case .alert(let message):
                return "Show alert: \(message)"
            case .log:
                return "Log error only"
            }
        }
    }
    
    // MARK: - Error Record
    
    private struct ErrorRecord {
        let error: Error
        let context: ErrorContext
        let timestamp: Date
        let recovered: Bool
    }
    
    // MARK: - Properties
    
    static let shared = ErrorRecoveryManager()
    
    private var errorHistory: [ErrorRecord] = []
    private let historyQueue = DispatchQueue(label: "com.gymbro.error.history")
    private let maxHistorySize = 100
    
    // Retry tracking
    private var retryAttempts: [String: Int] = [:]
    private let retryQueue = DispatchQueue(label: "com.gymbro.error.retry")
    
    // MARK: - Initialization
    
    private init() {
        Logger.shared.log(.info, "ErrorRecoveryManager initialized")
    }
    
    // MARK: - Public Methods
    
    func handle(
        _ error: Error,
        context: ErrorContext,
        strategy: RecoveryStrategy,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        // Log error details
        logError(error, context: context, file: file, function: function, line: line)
        
        // Record error
        recordError(error, context: context)
        
        // Execute recovery strategy
        executeStrategy(strategy, for: error, context: context)
    }
    
    // MARK: - Private Methods - Logging
    
    private func logError(
        _ error: Error,
        context: ErrorContext,
        file: String,
        function: String,
        line: Int
    ) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let nsError = error as NSError
        
        let errorDetails = """
            Error in \(context.displayName):
            - Description: \(error.localizedDescription)
            - Code: \(nsError.code)
            - Domain: \(nsError.domain)
            - Location: \(fileName):\(line) in \(function)
            - UserInfo: \(nsError.userInfo)
            """
        
        Logger.shared.log(.error, errorDetails)
    }
    
    // MARK: - Private Methods - Recording
    
    private func recordError(_ error: Error, context: ErrorContext) {
        historyQueue.async { [weak self] in
            guard let self = self else { return }
            
            let record = ErrorRecord(
                error: error,
                context: context,
                timestamp: Date(),
                recovered: false
            )
            
            self.errorHistory.append(record)
            
            // Trim history if needed
            if self.errorHistory.count > self.maxHistorySize {
                self.errorHistory.removeFirst(self.errorHistory.count - self.maxHistorySize)
            }
        }
    }
    
    // MARK: - Private Methods - Strategy Execution
    
    private func executeStrategy(
        _ strategy: RecoveryStrategy,
        for error: Error,
        context: ErrorContext
    ) {
        Logger.shared.log(.info, "Executing recovery strategy: \(strategy.debugDescription)")
        
        switch strategy {
        case .retry(let maxAttempts, let delay):
            executeRetryStrategy(
                maxAttempts: maxAttempts,
                delay: delay,
                error: error,
                context: context
            )
            
        case .fallback(let handler):
            executeFallbackStrategy(handler: handler)
            
        case .ignore:
            Logger.shared.log(.debug, "Ignoring error as per strategy")
            
        case .alert(let message):
            executeAlertStrategy(message: message, context: context)
            
        case .log:
            // Already logged above
            break
        }
    }
    
    private func executeRetryStrategy(
        maxAttempts: Int,
        delay: TimeInterval,
        error: Error,
        context: ErrorContext
    ) {
        let retryKey = "\(context)_\(error.localizedDescription)"
        
        retryQueue.async { [weak self] in
            guard let self = self else { return }
            
            let currentAttempts = self.retryAttempts[retryKey] ?? 0
            
            if currentAttempts < maxAttempts {
                self.retryAttempts[retryKey] = currentAttempts + 1
                
                Logger.shared.log(
                    .info,
                    "Retry attempt \(currentAttempts + 1)/\(maxAttempts) for \(context.displayName)"
                )
                
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                    // Trigger retry based on context
                    self.triggerRetry(for: context)
                }
            } else {
                Logger.shared.log(
                    .error,
                    "Max retry attempts reached for \(context.displayName)"
                )
                
                // Clear retry counter
                self.retryAttempts[retryKey] = nil
                
                // Show user alert if critical
                if context == .audioSession || context == .backgroundTask {
                    self.executeAlertStrategy(
                        message: "Unable to configure \(context.displayName). Please restart the app.",
                        context: context
                    )
                }
            }
        }
    }
    
    private func executeFallbackStrategy(handler: @escaping () -> Void) {
        DispatchQueue.main.async {
            handler()
            Logger.shared.log(.info, "Fallback handler executed")
        }
    }
    
    private func executeAlertStrategy(message: String, context: ErrorContext) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                Logger.shared.log(.error, "No root view controller for error alert")
                return
            }
            
            let alert = UIAlertController(
                title: "\(context.displayName) Error",
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                Logger.shared.log(.info, "User acknowledged error alert")
            })
            
            // Add retry option for certain contexts
            if context == .audioSession || context == .backgroundTask {
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                    self.triggerRetry(for: context)
                })
            }
            
            rootViewController.present(alert, animated: true)
        }
    }
    
    private func triggerRetry(for context: ErrorContext) {
        switch context {
        case .audioSession:
            AudioSessionManager.shared.reactivate()
            
        case .backgroundTask:
            if #available(iOS 13.0, *) {
                BackgroundTaskManager.shared.scheduleAppRefresh()
            }
            
        case .liveActivity:
            // LiveActivityHandler will handle its own retries
            Logger.shared.log(.debug, "Live Activity retry triggered")
            
        default:
            Logger.shared.log(.warning, "No retry handler for context: \(context)")
        }
    }
    
    // MARK: - Metrics & Debugging
    
    func getErrorMetrics() -> [String: Any] {
        return historyQueue.sync {
            let errorsByContext = Dictionary(grouping: errorHistory) { $0.context }
                .mapValues { $0.count }
            
            let recentErrors = errorHistory
                .filter { Date().timeIntervalSince($0.timestamp) < 3600 } // Last hour
                .count
            
            let recoveryRate = errorHistory.isEmpty ? 0.0 :
                Double(errorHistory.filter { $0.recovered }.count) / Double(errorHistory.count)
            
            return [
                "totalErrors": errorHistory.count,
                "recentErrors": recentErrors,
                "errorsByContext": errorsByContext,
                "recoveryRate": recoveryRate,
                "activeRetries": retryAttempts.count
            ]
        }
    }
    
    func clearErrorHistory() {
        historyQueue.async { [weak self] in
            self?.errorHistory.removeAll()
            self?.retryAttempts.removeAll()
            Logger.shared.log(.info, "Error history cleared")
        }
    }
    
    func getRecentErrors(limit: Int = 10) -> [(context: ErrorContext, description: String, timestamp: Date)] {
        return historyQueue.sync {
            errorHistory
                .suffix(limit)
                .map { (
                    context: $0.context,
                    description: $0.error.localizedDescription,
                    timestamp: $0.timestamp
                )}
        }
    }
}

// MARK: - Common Error Extensions

extension Error {
    /// Determine appropriate recovery strategy based on error type
    var suggestedRecoveryStrategy: ErrorRecoveryManager.RecoveryStrategy {
        let nsError = self as NSError
        
        switch nsError.domain {
        case "AVAudioSessionErrorDomain":
            // Audio errors should retry
            return .retry(attempts: 3, delay: 1.0)
            
        case "BGTaskSchedulerErrorDomain":
            // Background task errors depend on code
            if nsError.code == 3 { // Unavailable
                return .alert(message: "Background App Refresh is disabled. Enable it in Settings for timer to work in background.")
            }
            return .retry(attempts: 2, delay: 2.0)
            
        case NSURLErrorDomain:
            // Network errors should retry with longer delay
            return .retry(attempts: 3, delay: 5.0)
            
        default:
            // Default to logging
            return .log
        }
    }
}