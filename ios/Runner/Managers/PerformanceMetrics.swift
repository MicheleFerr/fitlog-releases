import Foundation

/// ✅ FIX #7: Performance Metrics Enhancement
/// Tracks timing and success rates for critical timer operations
final class PerformanceMetrics {

    // MARK: - Singleton

    static let shared = PerformanceMetrics()

    // MARK: - Metric Types

    struct Metric {
        let operation: String
        let duration: TimeInterval
        let success: Bool
        let timestamp: Date
        let metadata: [String: Any]?

        init(
            operation: String,
            duration: TimeInterval,
            success: Bool,
            timestamp: Date = Date(),
            metadata: [String: Any]? = nil
        ) {
            self.operation = operation
            self.duration = duration
            self.success = success
            self.timestamp = timestamp
            self.metadata = metadata
        }
    }

    struct AggregatedMetrics {
        let operation: String
        let count: Int
        let successRate: Double
        let avgDuration: TimeInterval
        let minDuration: TimeInterval
        let maxDuration: TimeInterval
        let p95Duration: TimeInterval
    }

    // MARK: - Properties

    private var metrics: [String: [Metric]] = [:]
    private let metricsQueue = DispatchQueue(label: "com.gymbro.performance.metrics", qos: .utility)

    /// Maximum metrics to keep per operation (prevent memory growth)
    private let maxMetricsPerOperation = 100

    /// Metrics retention period (old metrics are auto-cleaned)
    private let retentionPeriod: TimeInterval = 3600 // 1 hour

    // MARK: - Initialization

    private init() {
        // Start periodic cleanup
        startPeriodicCleanup()
    }

    // MARK: - Public Methods

    /// Measure the duration and success of an operation
    /// - Parameters:
    ///   - operation: Name of the operation (e.g., "audio_session_config")
    ///   - metadata: Optional metadata to attach to the metric
    ///   - block: The operation to measure
    /// - Returns: The result of the block
    func measure<T>(
        operation: String,
        metadata: [String: Any]? = nil,
        _ block: () throws -> T
    ) rethrows -> T {
        let start = Date()
        var success = true
        var error: Error?

        let result: T
        do {
            result = try block()
        } catch {
            success = false
            error = error
            throw error
        }

        let duration = Date().timeIntervalSince(start)

        // Record metric
        recordMetric(
            operation: operation,
            duration: duration,
            success: success,
            metadata: metadata
        )

        // Log if slow or failed
        if !success {
            Logger.shared.log(
                .warning,
                "❌ [FIX-7] \(operation) failed in \(String(format: "%.3f", duration))s",
                category: .performance
            )
        } else if duration > 0.5 {
            Logger.shared.log(
                .warning,
                "⚠️ [FIX-7] \(operation) slow: \(String(format: "%.3f", duration))s",
                category: .performance
            )
        } else {
            Logger.shared.log(
                .debug,
                "✅ [FIX-7] \(operation) completed in \(String(format: "%.3f", duration))s",
                category: .performance
            )
        }

        return result
    }

    /// Record a metric manually (for async operations)
    func recordMetric(
        operation: String,
        duration: TimeInterval,
        success: Bool,
        metadata: [String: Any]? = nil
    ) {
        let metric = Metric(
            operation: operation,
            duration: duration,
            success: success,
            metadata: metadata
        )

        metricsQueue.async {
            var operationMetrics = self.metrics[operation, default: []]
            operationMetrics.append(metric)

            // Keep only recent metrics
            if operationMetrics.count > self.maxMetricsPerOperation {
                operationMetrics.removeFirst(operationMetrics.count - self.maxMetricsPerOperation)
            }

            self.metrics[operation] = operationMetrics
        }
    }

    /// Get aggregated metrics for an operation
    func getMetrics(for operation: String) -> AggregatedMetrics? {
        return metricsQueue.sync {
            guard let operationMetrics = metrics[operation], !operationMetrics.isEmpty else {
                return nil
            }

            let successCount = operationMetrics.filter { $0.success }.count
            let successRate = Double(successCount) / Double(operationMetrics.count)

            let durations = operationMetrics.map { $0.duration }.sorted()
            let avgDuration = durations.reduce(0, +) / Double(durations.count)
            let minDuration = durations.first ?? 0
            let maxDuration = durations.last ?? 0

            // Calculate p95 (95th percentile)
            let p95Index = Int(Double(durations.count) * 0.95)
            let p95Duration = durations.indices.contains(p95Index) ? durations[p95Index] : maxDuration

            return AggregatedMetrics(
                operation: operation,
                count: operationMetrics.count,
                successRate: successRate,
                avgDuration: avgDuration,
                minDuration: minDuration,
                maxDuration: maxDuration,
                p95Duration: p95Duration
            )
        }
    }

    /// Get all tracked operations
    func getAllOperations() -> [String] {
        return metricsQueue.sync {
            return Array(metrics.keys)
        }
    }

    /// Get summary of all metrics
    func getSummary() -> [String: AggregatedMetrics] {
        return metricsQueue.sync {
            var summary: [String: AggregatedMetrics] = [:]

            for operation in metrics.keys {
                if let aggregated = getMetrics(for: operation) {
                    summary[operation] = aggregated
                }
            }

            return summary
        }
    }

    /// Print a formatted report of all metrics
    func printReport() {
        let summary = getSummary()

        Logger.shared.log(.info, """

            📊 [FIX-7] Performance Metrics Report
            ====================================
            """, category: .performance)

        for (operation, metrics) in summary.sorted(by: { $0.key < $1.key }) {
            Logger.shared.log(.info, """

                Operation: \(operation)
                  - Count: \(metrics.count)
                  - Success Rate: \(String(format: "%.1f", metrics.successRate * 100))%
                  - Avg Duration: \(String(format: "%.3f", metrics.avgDuration))s
                  - Min/Max: \(String(format: "%.3f", metrics.minDuration))s / \(String(format: "%.3f", metrics.maxDuration))s
                  - P95: \(String(format: "%.3f", metrics.p95Duration))s
                """, category: .performance)
        }

        Logger.shared.log(.info, "====================================\n", category: .performance)
    }

    /// Clear all metrics
    func clearAll() {
        metricsQueue.async {
            self.metrics.removeAll()
            Logger.shared.log(.info, "📊 [FIX-7] All metrics cleared", category: .performance)
        }
    }

    /// Clear metrics for a specific operation
    func clear(operation: String) {
        metricsQueue.async {
            self.metrics.removeValue(forKey: operation)
            Logger.shared.log(.info, "📊 [FIX-7] Metrics cleared for: \(operation)", category: .performance)
        }
    }

    // MARK: - Private Methods

    private func startPeriodicCleanup() {
        // Clean up old metrics every 10 minutes
        Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { [weak self] _ in
            self?.cleanupOldMetrics()
        }
    }

    private func cleanupOldMetrics() {
        metricsQueue.async {
            let cutoff = Date().addingTimeInterval(-self.retentionPeriod)

            for (operation, operationMetrics) in self.metrics {
                let filtered = operationMetrics.filter { $0.timestamp >= cutoff }
                if filtered.isEmpty {
                    self.metrics.removeValue(forKey: operation)
                } else {
                    self.metrics[operation] = filtered
                }
            }

            Logger.shared.log(.debug, "📊 [FIX-7] Old metrics cleaned up", category: .performance)
        }
    }
}

// MARK: - Convenience Extensions

extension PerformanceMetrics {

    /// Common operation names as constants to avoid typos
    enum Operation {
        static let audioSessionConfig = "audio_session_config"
        static let audioSessionTransition = "audio_session_transition"
        static let audioSessionCleanup = "audio_session_cleanup"
        static let notificationSend = "notification_send"
        static let notificationDelivery = "notification_delivery"
        static let liveActivityStart = "live_activity_start"
        static let liveActivityUpdate = "live_activity_update"
        static let liveActivityEnd = "live_activity_end"
        static let timerStart = "timer_start"
        static let timerCompletion = "timer_completion"
        static let validation = "validation"
    }
}
