import Flutter
import Foundation
import UIKit

/// Unified coordinator for timer-related native iOS operations.
final class UnifiedTimerCoordinator {
    static let shared = UnifiedTimerCoordinator()

    private var unifiedChannel: FlutterMethodChannel?
    private let channelName = ChannelNames.unified
    private let liveActivityHandler = LiveActivityHandler.shared
    private let coordinationQueue = DispatchQueue(label: "com.gymbro.timer.coordination")
    private var activeBackgroundTasks: [String: UIBackgroundTaskIdentifier] = [:]
    private var lastAudioTriggerTime: Date?

    private init() {}

    func setupChannel(with messenger: FlutterBinaryMessenger) {
        unifiedChannel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: messenger
        )

        unifiedChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        MetronomeManager.shared.setChannel(unifiedChannel)

        if #available(iOS 16.1, *) {
            liveActivityHandler.setupMethodChannel(with: messenger)
        }
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let mainResult: FlutterResult = { value in
            DispatchQueue.main.async {
                result(value)
            }
        }

        coordinationQueue.async { [weak self] in
            guard let self else {
                mainResult(FlutterError(code: "DISPOSED", message: "Coordinator disposed", details: nil))
                return
            }

            switch call.method {
            case "startTimer", "pauseTimer", "resumeTimer":
                mainResult(true)

            case "stopTimer":
                self.handleStopTimer(result: mainResult)

            case "scheduleCompletion":
                self.handleScheduleCompletion(call.arguments, result: mainResult)

            case "cancelScheduledCompletion":
                self.handleCancelScheduledCompletion(result: mainResult)

            case "playCompletionSound":
                self.handlePlayCompletionSound(call.arguments, result: mainResult)

            case "setPreferredTimerSound":
                self.handleSetPreferredTimerSound(call.arguments, result: mainResult)

            case "sendNotification", "sendEmergencyNotification":
                self.handleSendNotification(call.arguments, result: mainResult)

            case "wasNotificationDelivered":
                self.handleWasNotificationDelivered(call.arguments, result: mainResult)

            case "wasScheduledCompletionDelivered":
                self.handleWasScheduledCompletionDelivered(result: mainResult)

            case "consumePendingNotificationPayload":
                mainResult(DirectNotificationManager.shared.consumePendingNotificationPayload())

            case "clearPendingNotificationPayload":
                DirectNotificationManager.shared.clearPendingNotificationPayload()
                mainResult(true)

            case "getLocalTimeZone":
                mainResult(TimeZone.current.identifier)

            case "startLiveActivity":
                self.handleStartLiveActivity(call.arguments, result: mainResult)

            case "updateLiveActivity":
                self.handleUpdateLiveActivity(call.arguments, result: mainResult)

            case "endLiveActivity":
                self.handleEndLiveActivity(call.arguments, result: mainResult)

            case "endAllActiveLiveActivities":
                self.handleEndAllActiveLiveActivities(result: mainResult)

            case "getActiveLiveActivities":
                self.handleGetActiveLiveActivities(result: mainResult)

            case "cleanupLiveActivitiesForAppTermination":
                self.handleCleanupLiveActivitiesForAppTermination(result: mainResult)

            case "getTimerState":
                mainResult([
                    "isActive": false,
                    "lastAudioTrigger": self.lastAudioTriggerTime?.timeIntervalSince1970 ?? 0,
                ])

            case "getMetrics":
                mainResult([
                    "lastAudioTrigger": self.lastAudioTriggerTime?.timeIntervalSince1970 ?? 0,
                    "restTimerNotificationIdentifier": DirectNotificationManager.restTimerNotificationIdentifier,
                ])

            case "beginBackgroundTask":
                self.handleBeginBackgroundTask(call.arguments, result: result)

            case "endBackgroundTask":
                self.handleEndBackgroundTask(call.arguments, result: mainResult)

            case "startMetronome":
                self.handleStartMetronome(call.arguments, result: mainResult)

            case "stopMetronome":
                self.handleStopMetronome(result: mainResult)

            default:
                mainResult(FlutterMethodNotImplemented)
            }
        }
    }

    private func handleStopTimer(result: @escaping FlutterResult) {
        Logger.shared.log(
            .debug,
            "🛑 [TIMER-COORDINATOR] stopTimer appState=\(debugApplicationState())",
            category: .general
        )
        DirectNotificationManager.shared.cancelRestTimerCompletion()
        result(true)
    }

    private func handleScheduleCompletion(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let duration = args["duration"] as? Double else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing duration", details: nil))
            return
        }

        let soundName = args["soundName"] as? String ?? "timer_complete"
        let title = args["title"] as? String ?? "Timer Complete"
        let body = args["body"] as? String ?? "Your timer has finished."

        Logger.shared.log(
            .debug,
            """
            [TIMER-COORDINATOR] scheduleCompletion
            duration=\(duration)
            soundName=\(soundName)
            title=\(title)
            body=\(body)
            appState=\(debugApplicationState())
            thread=\(Thread.isMainThread ? "main" : "background")
            """,
            category: .general
        )
        DirectNotificationManager.shared.logRestTimerNotificationState(context: "coordinator before scheduleCompletion")

        let identifier = DirectNotificationManager.shared.scheduleRestTimerCompletion(
            duration: duration,
            soundName: soundName,
            title: title,
            body: body
        )
        Logger.shared.log(
            .debug,
            "✅ [TIMER-COORDINATOR] scheduleCompletion returned identifier=\(identifier)",
            category: .general
        )
        result(identifier)
    }

    private func handleCancelScheduledCompletion(result: @escaping FlutterResult) {
        Logger.shared.log(
            .debug,
            "🗑️ [TIMER-COORDINATOR] cancelScheduledCompletion appState=\(debugApplicationState())",
            category: .general
        )
        DirectNotificationManager.shared.cancelRestTimerCompletion()
        result(true)
    }

    private func handlePlayCompletionSound(_ arguments: Any?, result: @escaping FlutterResult) {
        let soundName = (arguments as? [String: Any])?["soundName"] as? String
        Logger.shared.log(
            .debug,
            """
            [TIMER-COORDINATOR] playCompletionSound
            soundName=\(soundName ?? "nil")
            appState=\(debugApplicationState())
            thread=\(Thread.isMainThread ? "main" : "background")
            """,
            category: .general
        )
        TimerSoundFix.shared.logAudioSessionSnapshot(
            context: "coordinator before playCompletionSound",
            preferredSound: soundName,
            resolvedName: soundName
        )
        let played = TimerSoundFix.shared.playTimerCompletionSound(preferredSound: soundName)
        if played {
            lastAudioTriggerTime = Date()
        }
        Logger.shared.log(
            .debug,
            "🔊 [TIMER-COORDINATOR] playCompletionSound result=\(played)",
            category: .general
        )
        TimerSoundFix.shared.logAudioSessionSnapshot(
            context: "coordinator after playCompletionSound",
            preferredSound: soundName,
            resolvedName: soundName
        )
        result(played)
    }

    private func handleSetPreferredTimerSound(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
            return
        }

        let soundName = RestTimerNotificationSupport.normalizedSoundName(args["soundName"] as? String)
        let userDefaults = UserDefaults(suiteName: RestTimerNotificationSupport.sharedSuiteName)
        userDefaults?.set(soundName, forKey: RestTimerNotificationSupport.preferredSoundKey)
        Logger.shared.log(
            .debug,
            "🎛️ [TIMER-COORDINATOR] setPreferredTimerSound soundName=\(soundName) appState=\(debugApplicationState())",
            category: .general
        )
        result(soundName)
    }

    private func handleSendNotification(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let title = args["title"] as? String,
              let body = args["body"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing notification title or body", details: nil))
            return
        }

        let soundName = args["sound"] as? String ?? "timer_complete"
        let playSound = args["playSound"] as? Bool ?? true
        let categoryIdentifier = args["categoryIdentifier"] as? String ?? DirectNotificationManager.timerCategoryIdentifier
        let delay = args["delaySeconds"] as? Double ?? 0

        DirectNotificationManager.shared.sendTimerNotification(
            title: title,
            body: body,
            soundName: soundName,
            categoryIdentifier: categoryIdentifier,
            delay: delay,
            playSound: playSound
        )

        result(true)
    }

    private func handleWasNotificationDelivered(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let identifier = args["identifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing notification identifier", details: nil))
            return
        }

        result(DirectNotificationManager.shared.wasNotificationDelivered(identifier: identifier))
    }

    private func handleWasScheduledCompletionDelivered(result: @escaping FlutterResult) {
        let delivered = DirectNotificationManager.shared.wasNotificationDelivered(
            identifier: DirectNotificationManager.restTimerNotificationIdentifier
        )
        Logger.shared.log(
            .debug,
            "📬 [TIMER-COORDINATOR] wasScheduledCompletionDelivered=\(delivered)",
            category: .general
        )
        result(delivered)
    }

    private func handleStartLiveActivity(_ arguments: Any?, result: @escaping FlutterResult) {
        if #available(iOS 16.1, *) {
            liveActivityHandler.startLiveActivityDirectly(arguments as? [String: Any], result: result)
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Live Activities require iOS 16.1 or later", details: nil))
        }
    }

    private func handleUpdateLiveActivity(_ arguments: Any?, result: @escaping FlutterResult) {
        if #available(iOS 16.1, *) {
            liveActivityHandler.updateLiveActivityDirectly(arguments as? [String: Any], result: result)
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Live Activities require iOS 16.1 or later", details: nil))
        }
    }

    private func handleEndLiveActivity(_ arguments: Any?, result: @escaping FlutterResult) {
        if #available(iOS 16.1, *) {
            liveActivityHandler.endLiveActivityDirectly(arguments as? [String: Any], result: result)
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Live Activities require iOS 16.1 or later", details: nil))
        }
    }

    private func handleEndAllActiveLiveActivities(result: @escaping FlutterResult) {
        if #available(iOS 16.1, *) {
            liveActivityHandler.endAllActiveLiveActivitiesDirectly(result: result)
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Live Activities require iOS 16.1 or later", details: nil))
        }
    }

    private func handleGetActiveLiveActivities(result: @escaping FlutterResult) {
        if #available(iOS 16.1, *) {
            liveActivityHandler.getActiveLiveActivitiesDirectly(result: result)
        } else {
            result([:])
        }
    }

    private func handleCleanupLiveActivitiesForAppTermination(result: @escaping FlutterResult) {
        if #available(iOS 16.1, *) {
            Task {
                await liveActivityHandler.endAllActivitiesForAppTermination()
                result(true)
            }
        } else {
            result(true)
        }
    }

    private func handleStartMetronome(_ arguments: Any?, result: @escaping FlutterResult) {
        let args = arguments as? [String: Any]
        let soundEnabled = args?["soundEnabled"] as? Bool ?? true
        let hapticEnabled = args?["hapticEnabled"] as? Bool ?? true
        MetronomeManager.shared.start(soundEnabled: soundEnabled, hapticEnabled: hapticEnabled)
        result(true)
    }

    private func handleStopMetronome(result: @escaping FlutterResult) {
        result(MetronomeManager.shared.stop())
    }

    private func handleBeginBackgroundTask(_ arguments: Any?, result: @escaping FlutterResult) {
        let taskName = (arguments as? [String: Any])?["name"] as? String ?? "default_task"
        let taskId = UUID().uuidString

        DispatchQueue.main.async { [weak self] in
            guard let self else {
                result(FlutterError(code: "DISPOSED", message: "Coordinator disposed", details: nil))
                return
            }

            let identifier = UIApplication.shared.beginBackgroundTask(withName: taskName) { [weak self] in
                self?.endBackgroundTask(taskId: taskId)
            }

            if identifier == .invalid {
                result(FlutterError(code: "TASK_FAILED", message: "Could not begin background task", details: nil))
                return
            }

            self.activeBackgroundTasks[taskId] = identifier
            result(taskId)
        }
    }

    private func handleEndBackgroundTask(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let taskId = args["taskId"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing taskId", details: nil))
            return
        }

        endBackgroundTask(taskId: taskId)
        result(true)
    }

    private func endBackgroundTask(taskId: String) {
        guard let identifier = activeBackgroundTasks.removeValue(forKey: taskId) else {
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.endBackgroundTask(identifier)
        }
    }

    private func debugApplicationState() -> String {
        switch UIApplication.shared.applicationState {
        case .active:
            return "active"
        case .background:
            return "background"
        case .inactive:
            return "inactive"
        @unknown default:
            return "unknown"
        }
    }
}
