/// 🔬 Audio Debug Test Handler
/// Handles platform channel communication for automated audio debug tests
/// Bridges Flutter test UI with native iOS timer audio system

import Flutter
import UIKit

#if DEBUG
class AudioDebugTestHandler: NSObject {
    static let shared = AudioDebugTestHandler()

    private var channel: FlutterMethodChannel?
    private var activeTests: [String: AudioDebugTest] = [:]

    // MARK: - Setup

    func setup(binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: ChannelNames.audioDebug,
            binaryMessenger: binaryMessenger
        )

        channel?.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call: call, result: result)
        }

        print("[AudioDebugTestHandler] Platform channel registered")
    }

    // MARK: - Method Call Handling

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

    // MARK: - Start Audio Test

    private func startAudioTest(args: [String: Any], result: @escaping FlutterResult) {
        guard let testId = args["testId"] as? String,
              let duration = args["duration"] as? Int,
              let appStateStr = args["appState"] as? String,
              let liveActivityEnabled = args["liveActivityEnabled"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing required parameters", details: nil))
            return
        }

        print("[AudioDebugTestHandler] Starting test: \(testId)")
        print("[AudioDebugTestHandler] Duration: \(duration)s, AppState: \(appStateStr), LA: \(liveActivityEnabled)")

        // Crea test
        let test = AudioDebugTest(
            testId: testId,
            duration: duration,
            appState: appStateStr,
            liveActivityEnabled: liveActivityEnabled
        )

        activeTests[testId] = test

        // ✅ FIX: Se Live Activity è enabled, avviala e skippa notifiche
        let skipNotification = liveActivityEnabled

        if liveActivityEnabled {
            // Avvia Live Activity per il test
            print("[AudioDebugTestHandler] Starting Live Activity for test \(testId)")

            let laArgs: [String: Any] = [
                "exerciseName": "Audio Test \(testId)",
                "timerType": "rest",
                "totalSeconds": duration,
                "remainingSeconds": duration,
                "isRunning": true,
                "currentSet": 1,
                "totalSets": 1,
                "lastUpdated": Int64(Date().timeIntervalSince1970 * 1000),
                "soundName": "YehBuddie"
            ]

            LiveActivityHandler.shared.startLiveActivityDirectly(laArgs) { result in
                if case .failure(let error) = result as? Result<Void, Error> {
                    print("[AudioDebugTestHandler] ⚠️ Live Activity failed to start: \(error)")
                } else {
                    print("[AudioDebugTestHandler] ✅ Live Activity started successfully")
                }
            }
        }

        // Avvia timer audio tramite BackgroundAudioManager
        BackgroundAudioManager.shared.scheduleTimerAudio(
            duration: TimeInterval(duration),
            soundName: "YehBuddie",
            skipNotification: skipNotification
        )

        // Ottieni trace ID dal BackgroundAudioManager
        // NOTA: Assumiamo che currentTraceId sia accessibile
        let traceId = AudioTraceLogger.shared.getLastTraceId() ?? "unknown-\(testId)"
        test.traceId = traceId

        print("[AudioDebugTestHandler] Test \(testId) started with trace ID: \(traceId)")

        // Registra observer per audio completion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioCompleted(_:)),
            name: NSNotification.Name("TimerAudioCompleted"),
            object: nil
        )

        // Avvia timeout timer (durata test + 15s buffer)
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration + 15)) { [weak self] in
            self?.checkTestCompletion(testId: testId)
        }

        // Ritorna trace ID a Flutter
        result(traceId)
    }

    // MARK: - Audio Completion Handler

    @objc private func handleAudioCompleted(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let traceId = userInfo["traceId"] as? String,
              let soundCount = userInfo["soundCount"] as? Int else {
            print("[AudioDebugTestHandler] Invalid audio completion notification")
            return
        }

        print("[AudioDebugTestHandler] Audio completed: \(traceId), sounds: \(soundCount)")

        // Trova il test associato a questo trace ID
        if let testId = activeTests.first(where: { $0.value.traceId == traceId })?.key {
            completeTest(testId: testId, actualSounds: soundCount, traceId: traceId)
        }
    }

    private func completeTest(testId: String, actualSounds: Int, traceId: String) {
        guard let test = activeTests[testId] else {
            print("[AudioDebugTestHandler] Test \(testId) not found")
            return
        }

        print("[AudioDebugTestHandler] Completing test \(testId): \(actualSounds) sounds")

        // ✅ FIX BUG #2: Remove notification observer to prevent duplicate notifications on subsequent tests
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name("TimerAudioCompleted"),
            object: nil
        )
        print("[AudioDebugTestHandler] Removed notification observer for test \(testId)")

        // ✅ FIX BUG #6: End Live Activity to prevent zombie LA if it was started
        if test.liveActivityEnabled {
            LiveActivityHandler.shared.endAllActiveLiveActivitiesDirectly { _ in
                print("[AudioDebugTestHandler] Live Activity ended for completed test \(testId)")
            }
        }

        // Invia risultato a Flutter
        channel?.invokeMethod("onAudioTestCompleted", arguments: [
            "testId": testId,
            "actualSounds": actualSounds,
            "traceId": traceId,
            "success": true
        ])

        // Rimuovi test completato
        activeTests.removeValue(forKey: testId)

        print("[AudioDebugTestHandler] Test \(testId) completed and removed")
    }

    private func checkTestCompletion(testId: String) {
        // Se il test è ancora attivo dopo il timeout, consideralo fallito
        if let test = activeTests[testId] {
            print("[AudioDebugTestHandler] Test \(testId) timed out")

            // ✅ FIX BUG #2: Remove notification observer on timeout too
            NotificationCenter.default.removeObserver(
                self,
                name: NSNotification.Name("TimerAudioCompleted"),
                object: nil
            )
            print("[AudioDebugTestHandler] Removed notification observer for timed-out test \(testId)")

            // ✅ FIX BUG #6: End Live Activity if it was started
            if test.liveActivityEnabled {
                LiveActivityHandler.shared.endAllActiveLiveActivitiesDirectly { _ in
                    print("[AudioDebugTestHandler] Live Activity ended for timed-out test \(testId)")
                }
            }

            channel?.invokeMethod("onAudioTestCompleted", arguments: [
                "testId": testId,
                "actualSounds": 0,
                "traceId": test.traceId ?? "timeout",
                "success": false
            ])

            activeTests.removeValue(forKey: testId)
        }
    }

    // MARK: - Cancel Test

    private func cancelTest(testId: String, result: @escaping FlutterResult) {
        print("[AudioDebugTestHandler] Cancelling test: \(testId)")

        if let test = activeTests[testId] {
            // ✅ FIX BUG #4: Remove notification observer on cancel to prevent memory leak
            NotificationCenter.default.removeObserver(
                self,
                name: NSNotification.Name("TimerAudioCompleted"),
                object: nil
            )
            print("[AudioDebugTestHandler] Removed notification observer for cancelled test \(testId)")

            // ✅ FIX BUG #6: End Live Activity if it was started
            if test.liveActivityEnabled {
                LiveActivityHandler.shared.endAllActiveLiveActivitiesDirectly { _ in
                    print("[AudioDebugTestHandler] Live Activity ended for cancelled test \(testId)")
                }
            }

            // Cancella timer se possibile
            BackgroundAudioManager.shared.cancelScheduledAudio()

            activeTests.removeValue(forKey: testId)
            result(nil)
        } else {
            result(FlutterError(code: "TEST_NOT_FOUND", message: "Test \(testId) not active", details: nil))
        }
    }

    // MARK: - Request Background Mode

    private func requestBackgroundMode(result: @escaping FlutterResult) {
        print("[AudioDebugTestHandler] Background mode requested - User must manually background app")

        // Non possiamo forzare l'app in background programmaticamente su iOS
        // L'utente deve farlo manualmente premendo Home

        // Possiamo solo mostrare un alert
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

// MARK: - Test Model

private class AudioDebugTest {
    let testId: String
    let duration: Int
    let appState: String
    let liveActivityEnabled: Bool
    var traceId: String?

    init(testId: String, duration: Int, appState: String, liveActivityEnabled: Bool) {
        self.testId = testId
        self.duration = duration
        self.appState = appState
        self.liveActivityEnabled = liveActivityEnabled
    }
}
#endif
