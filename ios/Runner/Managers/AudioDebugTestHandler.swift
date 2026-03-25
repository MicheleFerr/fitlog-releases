/// 🔬 Audio Debug Test Handler
/// Handles platform channel communication for automated audio debug tests
/// using the same one-shot foreground audio / notification-owned paths as production.

import Flutter
import UIKit

#if DEBUG
class AudioDebugTestHandler: NSObject {
    static let shared = AudioDebugTestHandler()

    private struct AudioDebugTest {
        let testId: String
        let liveActivityEnabled: Bool
        let notificationOwned: Bool
        let completionWorkItem: DispatchWorkItem
    }

    private var channel: FlutterMethodChannel?
    private var activeTests: [String: AudioDebugTest] = [:]

    func setup(binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: ChannelNames.audioDebug,
            binaryMessenger: binaryMessenger
        )

        channel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call: call, result: result)
        }
    }

    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startAudioTest":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                return
            }
            startAudioTest(args: args, result: result)

        case "cancelTest":
            guard let args = call.arguments as? [String: Any],
                  let testId = args["testId"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing testId", details: nil))
                return
            }
            cancelTest(testId: testId, result: result)

        case "requestBackgroundMode":
            requestBackgroundMode(result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startAudioTest(args: [String: Any], result: @escaping FlutterResult) {
        guard let testId = args["testId"] as? String,
              let duration = args["duration"] as? Int,
              let appStateStr = args["appState"] as? String,
              let liveActivityEnabled = args["liveActivityEnabled"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing required parameters", details: nil))
            return
        }

        let soundName = args["soundName"] as? String ?? "YehBuddie"
        let normalizedAppState = appStateStr.lowercased()
        let notificationOwned = normalizedAppState.contains("background") || normalizedAppState.contains("lock")

        if liveActivityEnabled {
            startDebugLiveActivity(testId: testId, duration: duration, soundName: soundName)
        }

        if notificationOwned {
            _ = DirectNotificationManager.shared.scheduleRestTimerCompletion(
                duration: TimeInterval(duration),
                soundName: soundName,
                title: "Audio Test",
                body: "Debug timer completion"
            )
        }

        let completionWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }

            let actualSounds: Int
            if notificationOwned {
                actualSounds = 1
            } else {
                let played = TimerSoundFix.shared.playTimerCompletionSound(
                    preferredSound: soundName,
                    isPreview: true
                )
                actualSounds = played ? 1 : 0
            }

            self.finishTest(testId: testId, actualSounds: actualSounds)
        }

        activeTests[testId] = AudioDebugTest(
            testId: testId,
            liveActivityEnabled: liveActivityEnabled,
            notificationOwned: notificationOwned,
            completionWorkItem: completionWorkItem
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration) + 1.0, execute: completionWorkItem)
        result(testId)
    }

    private func startDebugLiveActivity(testId: String, duration: Int, soundName: String) {
        guard #available(iOS 16.1, *) else {
            return
        }

        let liveActivityArgs: [String: Any] = [
            "exerciseName": "Audio Test \(testId)",
            "timerType": "rest",
            "totalSeconds": duration,
            "remainingSeconds": duration,
            "isRunning": true,
            "currentSet": 1,
            "totalSets": 1,
            "lastUpdated": Int64(Date().timeIntervalSince1970 * 1000),
            "soundName": soundName
        ]

        LiveActivityHandler.shared.startLiveActivityDirectly(liveActivityArgs) { _ in }
    }

    private func finishTest(testId: String, actualSounds: Int) {
        guard let test = activeTests.removeValue(forKey: testId) else {
            return
        }

        if test.liveActivityEnabled, #available(iOS 16.1, *) {
            LiveActivityHandler.shared.endAllActiveLiveActivitiesDirectly { _ in }
        }

        channel?.invokeMethod("onAudioTestCompleted", arguments: [
            "testId": testId,
            "actualSounds": actualSounds,
            "traceId": testId,
            "success": actualSounds > 0
        ])
    }

    private func cancelTest(testId: String, result: @escaping FlutterResult) {
        guard let test = activeTests.removeValue(forKey: testId) else {
            result(FlutterError(code: "TEST_NOT_FOUND", message: "Test \(testId) not active", details: nil))
            return
        }

        test.completionWorkItem.cancel()

        if test.notificationOwned {
            DirectNotificationManager.shared.cancelRestTimerCompletion()
        }

        if test.liveActivityEnabled, #available(iOS 16.1, *) {
            LiveActivityHandler.shared.endAllActiveLiveActivitiesDirectly { _ in }
        }

        result(nil)
    }

    private func requestBackgroundMode(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = scene.windows.first?.rootViewController {
                let alert = UIAlertController(
                    title: "Put App in Background",
                    message: "Please press the Home button to put the app in background for this test.",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .default))
                rootViewController.present(alert, animated: true)
            }
        }

        result(nil)
    }
}
#endif
