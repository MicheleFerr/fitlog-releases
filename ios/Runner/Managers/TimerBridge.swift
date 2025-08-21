import Foundation
import Flutter

/// Bridge tra Flutter timer e sistema nativo ottimizzato
final class TimerBridge {
    
    static let shared = TimerBridge()
    private var methodChannel: FlutterMethodChannel?
    
    private init() {}
    
    func setupChannel(with messenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(
            name: "com.gymbro.timer/audio",
            binaryMessenger: messenger
        )
        
        methodChannel?.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call, result: result)
        }
        
        Logger.shared.log(.info, "✅ TimerBridge channel configured", category: .general)
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "scheduleTimerSound":
            // Intercetta la richiesta di audio dal timer Flutter
            if let args = call.arguments as? [String: Any],
               let duration = args["duration"] as? Double {
                
                // Get the selected sound name from Flutter
                let soundName = args["soundName"] as? String ?? "timer_complete"
                
                Logger.shared.log(.info, "🎯 Flutter requested timer sound for \(duration)s with sound: \(soundName)", category: .audioSession)
                
                // USA IL NOSTRO SISTEMA OTTIMIZZATO con il suono selezionato
                BackgroundAudioManager.shared.scheduleTimerAudio(
                    duration: duration,
                    soundName: soundName
                )
                
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing duration", details: nil))
            }
            
        case "cancelTimerSound":
            Logger.shared.log(.info, "🎯 Flutter requested to cancel timer sound", category: .audioSession)
            BackgroundAudioManager.shared.cancelScheduledAudio()
            result(true)
            
        case "playSound":
            // Per playback immediato
            if let args = call.arguments as? [String: Any],
               let soundName = args["sound"] as? String {
                BackgroundAudioManager.shared.scheduleTimerAudio(
                    duration: 0.1, // Suona quasi subito
                    soundName: soundName
                )
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing sound name", details: nil))
            }
            
        case "testSounds":
            // Test all notification sounds
            Logger.shared.log(.info, "🧪 Flutter requested sound test", category: .audioSession)
            // TestNotificationSound.testSoundFiles() // TODO: Add file to Xcode project
            result(true)
            
        case "hasAudioPlayedRecently":
            // Check if audio was played recently to prevent double playback
            let seconds = (call.arguments as? [String: Any])?["seconds"] as? Double ?? 5.0
            let hasPlayed = BackgroundAudioManager.shared.hasAudioPlayedRecently(within: seconds)
            
            Logger.shared.log(.info, "🔍 Flutter checking if audio played recently: \(hasPlayed)", category: .audioSession)
            result(hasPlayed)
            
        case "getAudioPlaybackInfo":
            // Get last audio playback information
            let info = BackgroundAudioManager.shared.getLastAudioPlaybackInfo()
            let response: [String: Any?] = [
                "timestamp": info.timestamp?.timeIntervalSince1970,
                "soundName": info.soundName
            ]
            result(response)
            
        case "resetAudioTracking":
            // Reset audio tracking (e.g., when starting a new timer)
            BackgroundAudioManager.shared.resetAudioTracking()
            result(true)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}