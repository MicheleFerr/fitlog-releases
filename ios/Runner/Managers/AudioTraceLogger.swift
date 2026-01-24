//
//  AudioTraceLogger.swift
//  Runner
//
//  Created for distributed tracing of audio playback paths
//  Tracks race conditions between AVAudioPlayer, Notifications, and Live Activities
//

import Foundation

/// Thread-safe distributed tracing logger for audio playback debugging
/// Assigns unique trace IDs to each timer and tracks all audio playback paths
final class AudioTraceLogger {

    // MARK: - Singleton
    static let shared = AudioTraceLogger()

    // MARK: - Properties
    private let traceQueue = DispatchQueue(label: "com.gymbro.audio.trace", qos: .userInitiated)
    private var activeTraces: [String: TraceContext] = [:]
    private var traceHistory: [TraceEvent] = []
    private let maxHistorySize = 100
    private var lastTraceId: String?

    // MARK: - Models

    struct TraceContext {
        let traceId: String
        let startTime: Date
        var duration: TimeInterval
        var soundName: String
        var skipNotification: Bool
        var events: [TraceEvent] = []

        var formattedDuration: String {
            if duration < 60 {
                return String(format: "%.1fs", duration)
            } else {
                let minutes = Int(duration / 60)
                let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
                return "\(minutes)m \(seconds)s"
            }
        }
    }

    struct TraceEvent {
        let traceId: String
        let timestamp: Date
        let path: AudioPath
        let action: Action
        let metadata: [String: Any]

        enum AudioPath: String {
            case silentLoop = "SILENT-LOOP"
            case dispatchTimer = "DISPATCH-TIMER"
            case notification = "NOTIFICATION"
            case liveActivity = "LIVE-ACTIVITY"
            case audioPlayer = "AUDIO-PLAYER"
            case deduplication = "DEDUPLICATION"
        }

        enum Action: String {
            case scheduled = "SCHEDULED"
            case started = "STARTED"
            case completed = "COMPLETED"
            case cancelled = "CANCELLED"
            case played = "PLAYED"
            case skipped = "SKIPPED"
            case blocked = "BLOCKED"
        }

        var timeOffset: String {
            let elapsed = Date().timeIntervalSince(timestamp)
            if elapsed < 1 {
                return String(format: "+%.0fms", elapsed * 1000)
            } else {
                return String(format: "+%.1fs", elapsed)
            }
        }
    }

    // MARK: - Initialization

    private init() {
        Logger.shared.log(.info, "🔬 AudioTraceLogger initialized - distributed tracing ACTIVE", category: .audioSession)
    }

    // MARK: - Public API

    /// Generate new trace ID for timer
    func startTrace(duration: TimeInterval, soundName: String, skipNotification: Bool) -> String {
        let traceId = generateTraceId()

        traceQueue.sync {
            let context = TraceContext(
                traceId: traceId,
                startTime: Date(),
                duration: duration,
                soundName: soundName,
                skipNotification: skipNotification
            )
            activeTraces[traceId] = context
            lastTraceId = traceId
        }

        Logger.shared.log(.info, """
            🆔 [TRACE-START] New trace:
            - Trace ID: \(traceId)
            - Duration: \(duration)s
            - Sound: \(soundName)
            - Skip notification: \(skipNotification)
            - Expected completion: \(Date().addingTimeInterval(duration))
            """, category: .audioSession)

        return traceId
    }

    /// Log event for specific trace
    func logEvent(traceId: String, path: TraceEvent.AudioPath, action: TraceEvent.Action, metadata: [String: Any] = [:]) {
        let event = TraceEvent(
            traceId: traceId,
            timestamp: Date(),
            path: path,
            action: action,
            metadata: metadata
        )

        traceQueue.sync {
            // Add to trace context
            activeTraces[traceId]?.events.append(event)

            // Add to global history
            traceHistory.append(event)
            if traceHistory.count > maxHistorySize {
                traceHistory.removeFirst()
            }
        }

        // Log to console with clear formatting
        let metadataStr = metadata.isEmpty ? "" : " | \(formatMetadata(metadata))"
        Logger.shared.log(.info, """
            🔬 [\(traceId.prefix(8))] [\(path.rawValue)] \(action.rawValue)\(metadataStr)
            """, category: .audioSession)
    }

    /// End trace and generate summary
    func endTrace(traceId: String, finalAction: TraceEvent.Action) {
        traceQueue.sync {
            guard let context = activeTraces.removeValue(forKey: traceId) else {
                Logger.shared.log(.warning, "⚠️ Trace \(traceId) not found - already ended?", category: .audioSession)
                return
            }

            let elapsed = Date().timeIntervalSince(context.startTime)
            let summary = generateTraceSummary(context: context, finalAction: finalAction, elapsed: elapsed)

            Logger.shared.log(.info, summary, category: .audioSession)
        }
    }

    /// Detect race conditions in active traces
    func detectRaceConditions() -> [String] {
        return traceQueue.sync {
            var warnings: [String] = []

            for (traceId, context) in activeTraces {
                let paths = Set(context.events.map { $0.path })

                // Check for multiple audio paths active simultaneously
                if paths.contains(.silentLoop) && paths.contains(.notification) {
                    warnings.append("⚠️ [\(traceId.prefix(8))] RACE: Silent loop + Notification both active")
                }

                if paths.contains(.audioPlayer) && paths.contains(.notification) {
                    warnings.append("⚠️ [\(traceId.prefix(8))] RACE: AVAudioPlayer + Notification both active")
                }

                // Check for duplicate plays
                let playEvents = context.events.filter { $0.action == .played }
                if playEvents.count > 1 {
                    warnings.append("⚠️ [\(traceId.prefix(8))] DUPLICATE: Audio played \(playEvents.count) times")
                }
            }

            return warnings
        }
    }

    /// Get diagnostic report for debugging
    func getDiagnosticReport() -> String {
        return traceQueue.sync {
            var report = """

            ════════════════════════════════════════════════════════════
            📊 AUDIO TRACE DIAGNOSTIC REPORT
            ════════════════════════════════════════════════════════════

            Active Traces: \(activeTraces.count)
            History Size: \(traceHistory.count) events
            Time: \(Date())

            """

            if !activeTraces.isEmpty {
                report += "\n🔴 ACTIVE TRACES:\n"
                for (traceId, context) in activeTraces.sorted(by: { $0.value.startTime < $1.value.startTime }) {
                    let elapsed = Date().timeIntervalSince(context.startTime)
                    let remaining = max(0, context.duration - elapsed)

                    report += """

                    ┌─ [\(traceId.prefix(8))]
                    │  Started: \(context.startTime)
                    │  Duration: \(context.formattedDuration)
                    │  Elapsed: \(String(format: "%.1fs", elapsed))
                    │  Remaining: \(String(format: "%.1fs", remaining))
                    │  Sound: \(context.soundName)
                    │  Skip notification: \(context.skipNotification)
                    │  Events: \(context.events.count)
                    """

                    if !context.events.isEmpty {
                        report += "\n│  Timeline:"
                        for event in context.events {
                            let offset = event.timestamp.timeIntervalSince(context.startTime)
                            report += "\n│    [\(String(format: "+%.1fs", offset))] \(event.path.rawValue) → \(event.action.rawValue)"
                        }
                    }
                    report += "\n└─"
                }
            }

            // Detect race conditions
            let warnings = detectRaceConditions()
            if !warnings.isEmpty {
                report += "\n\n⚠️ DETECTED ISSUES:\n"
                for warning in warnings {
                    report += "  \(warning)\n"
                }
            }

            // Recent history
            if !traceHistory.isEmpty {
                report += "\n\n📜 RECENT HISTORY (last 10 events):\n"
                let recentEvents = Array(traceHistory.suffix(10))
                for event in recentEvents {
                    report += "  [\(event.traceId.prefix(8))] \(event.path.rawValue) → \(event.action.rawValue) at \(event.timestamp)\n"
                }
            }

            report += "\n════════════════════════════════════════════════════════════\n"
            return report
        }
    }

    /// Get the last created trace ID (for AudioDebugTestHandler)
    func getLastTraceId() -> String? {
        return traceQueue.sync {
            return lastTraceId
        }
    }

    // MARK: - Private Helpers

    private func generateTraceId() -> String {
        return UUID().uuidString
    }

    private func formatMetadata(_ metadata: [String: Any]) -> String {
        return metadata.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
    }

    private func generateTraceSummary(context: TraceContext, finalAction: TraceEvent.Action, elapsed: TimeInterval) -> String {
        let paths = Set(context.events.map { $0.path })
        let actions = context.events.map { $0.action }

        let playCount = actions.filter { $0 == .played }.count
        let cancelCount = actions.filter { $0 == .cancelled }.count

        var summary = """

        ══════════════════════════════════════════════════════════
        🎬 TRACE SUMMARY [\(context.traceId.prefix(8))]
        ══════════════════════════════════════════════════════════
        Duration: \(context.formattedDuration)
        Elapsed: \(String(format: "%.1fs", elapsed))
        Sound: \(context.soundName)
        Skip notification: \(context.skipNotification)
        Final action: \(finalAction.rawValue)

        Active paths: \(paths.map { $0.rawValue }.joined(separator: ", "))
        Total events: \(context.events.count)
        Audio played: \(playCount) time(s)
        Cancellations: \(cancelCount)

        """

        // Timeline
        if !context.events.isEmpty {
            summary += "\nTimeline:\n"
            for event in context.events {
                let offset = event.timestamp.timeIntervalSince(context.startTime)
                summary += "  [\(String(format: "+%.1fs", offset))] \(event.path.rawValue) → \(event.action.rawValue)\n"
            }
        }

        // Warnings
        if playCount > 1 {
            summary += "\n⚠️ WARNING: Audio played \(playCount) times (expected 1)\n"
        }
        if playCount == 0 && finalAction != .cancelled {
            summary += "\n⚠️ WARNING: Audio did NOT play (expected 1)\n"
        }
        if paths.count > 2 {
            summary += "\n⚠️ WARNING: \(paths.count) concurrent audio paths (expected 1-2)\n"
        }

        summary += "══════════════════════════════════════════════════════════\n"

        return summary
    }
}
