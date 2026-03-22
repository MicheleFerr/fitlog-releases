import AudioToolbox
import AVFoundation
import Flutter
import Foundation
import UIKit

/// Foreground-only timer sound playback.
/// Uses a single AVAudioPlayer path with a music-friendly session configuration.
final class TimerSoundFix: NSObject {
    static let shared = TimerSoundFix()

    private var activePlayer: AVAudioPlayer?
    private var activePlayerURL: URL?

    private override init() {
        super.init()
        registerAudioSessionObservers()
    }

    @discardableResult
    func playTimerCompletionSound(preferredSound: String? = nil, isPreview: Bool = false) -> Bool {
        if Thread.isMainThread {
            return playTimerCompletionSoundOnMain(preferredSound: preferredSound, isPreview: isPreview)
        }

        var played = false
        DispatchQueue.main.sync {
            played = self.playTimerCompletionSoundOnMain(preferredSound: preferredSound, isPreview: isPreview)
        }
        return played
    }

    private func playTimerCompletionSoundOnMain(preferredSound: String?, isPreview: Bool) -> Bool {
        let resolvedName = normalizedSoundName(preferredSound)
        logAudioSessionSnapshot(
            context: "play request",
            preferredSound: preferredSound,
            resolvedName: resolvedName,
            soundURL: nil,
            player: nil
        )

        guard let soundURL = resolvedSoundURL(for: resolvedName) else {
            Logger.shared.log(
                .warning,
                """
                ⚠️ Timer sound not found: \(resolvedName)
                resolution:
                \(RestTimerNotificationSupport.debugResolutionTrace(for: resolvedName))
                """,
                category: .audioSession
            )
            return false
        }

        do {
            let session = AVAudioSession.sharedInstance()
            Logger.shared.log(
                .debug,
                "🔊 [TIMER-AUDIO] Applying AVAudioSession category=.playback options=.mixWithOthers for \(soundURL.lastPathComponent)",
                category: .audioSession
            )
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            logAudioSessionSnapshot(
                context: "after session activation",
                preferredSound: preferredSound,
                resolvedName: resolvedName,
                soundURL: soundURL,
                player: nil
            )

            activePlayer?.stop()
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.delegate = self
            let prepared = player.prepareToPlay()
            player.volume = 1.0
            activePlayer = player
            activePlayerURL = soundURL

            Logger.shared.log(
                .debug,
                """
                [TIMER-AUDIO] Player prepared
                prepared=\(prepared)
                duration=\(player.duration)
                volume=\(player.volume)
                numberOfChannels=\(player.numberOfChannels)
                deviceCurrentTime=\(player.deviceCurrentTime)
                url=\(soundURL.path)
                """,
                category: .audioSession
            )

            let played = player.play()
            if !played {
                Logger.shared.log(.warning, "⚠️ AVAudioPlayer refused to play \(soundURL.lastPathComponent), trying SystemSound fallback", category: .audioSession)
                return playViaSystemSound(soundURL: soundURL)
            } else {
                Logger.shared.log(
                    .debug,
                    """
                    [TIMER-AUDIO] Player started successfully
                    file=\(soundURL.lastPathComponent)
                    currentTime=\(player.currentTime)
                    isPlaying=\(player.isPlaying)
                    thread=\(Thread.isMainThread ? "main" : "background")
                    """,
                    category: .audioSession
                )
            }
            return played
        } catch {
            Logger.shared.log(.error, "❌ Failed to play timer sound \(resolvedName) via AVAudioPlayer: \(error.localizedDescription)", category: .audioSession)

            // Fallback: use AudioServicesPlayAlertSound which works on locked screen
            // without requiring an active AVAudioSession
            let played = playViaSystemSound(soundURL: soundURL)
            if played {
                Logger.shared.log(.debug, "✅ [TIMER-AUDIO] Fallback: played via AudioServicesPlayAlertSound", category: .audioSession)
                return true
            }

            logAudioSessionSnapshot(
                context: "play failure (AVAudioPlayer + SystemSound)",
                preferredSound: preferredSound,
                resolvedName: resolvedName,
                soundURL: soundURL,
                player: activePlayer
            )
            return false
        }
    }

    /// Fallback audio playback using AudioServicesPlayAlertSound.
    /// This API works even when the screen is locked because it doesn't
    /// require an active AVAudioSession — it goes through the system sound
    /// daemon directly. Alert sound also triggers vibration on silent mode.
    private func playViaSystemSound(soundURL: URL) -> Bool {
        var soundID: SystemSoundID = 0
        let status = AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
        guard status == kAudioServicesNoError else {
            Logger.shared.log(
                .warning,
                "⚠️ [TIMER-AUDIO] AudioServicesCreateSystemSoundID failed: \(status) for \(soundURL.lastPathComponent)",
                category: .audioSession
            )
            return false
        }

        // Play as alert sound (respects vibrate-on-silent setting)
        AudioServicesPlayAlertSound(soundID)

        // Dispose after playback completes (estimated 3s max for short sound files)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            AudioServicesDisposeSystemSoundID(soundID)
        }

        return true
    }

    func testAllSounds() {
        let soundNames = ["timer_complete", "sound", "LightWeight", "YehBuddie"]
        for soundName in soundNames {
            _ = playTimerCompletionSound(preferredSound: soundName, isPreview: true)
        }
    }

    private func normalizedSoundName(_ soundName: String?) -> String {
        let trimmed = soundName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.isEmpty {
            return "timer_complete"
        }

        let url = URL(fileURLWithPath: trimmed)
        return url.deletingPathExtension().lastPathComponent
    }

    private func resolvedSoundURL(for soundName: String) -> URL? {
        let candidateNames = [soundName, "timer_complete", "sound"]

        for candidate in candidateNames {
            if let cafURL = Bundle.main.url(forResource: candidate, withExtension: "caf") {
                return cafURL
            }

            if let wavURL = Bundle.main.url(forResource: candidate, withExtension: "wav") {
                return wavURL
            }
        }

        return nil
    }

    private func cleanupPlayer() {
        logAudioSessionSnapshot(
            context: "cleanup player",
            preferredSound: nil,
            resolvedName: nil,
            soundURL: activePlayerURL,
            player: activePlayer
        )
        activePlayer = nil
        activePlayerURL = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            Logger.shared.log(.warning, "⚠️ Failed to deactivate timer audio session: \(error.localizedDescription)", category: .audioSession)
        }
    }

    func logAudioSessionSnapshot(
        context: String,
        preferredSound: String? = nil,
        resolvedName: String? = nil,
        soundURL: URL? = nil,
        player: AVAudioPlayer? = nil
    ) {
        let loggerBlock = {
            let session = AVAudioSession.sharedInstance()
            let inputs = session.currentRoute.inputs.map { "\($0.portType.rawValue):\($0.portName)" }
            let outputs = session.currentRoute.outputs.map { "\($0.portType.rawValue):\($0.portName)" }
            let playerDescription: String

            if let player {
                playerDescription = "url=\(self.activePlayerURL?.lastPathComponent ?? "nil") isPlaying=\(player.isPlaying) currentTime=\(player.currentTime) duration=\(player.duration)"
            } else {
                playerDescription = "nil"
            }

            Logger.shared.log(
                .debug,
                """
                [TIMER-AUDIO] Snapshot \(context)
                appState=\(self.debugApplicationState())
                thread=\(Thread.isMainThread ? "main" : "background")
                preferredSound=\(preferredSound ?? "nil")
                resolvedName=\(resolvedName ?? "nil")
                soundURL=\(soundURL?.path ?? "nil")
                category=\(session.category.rawValue)
                mode=\(session.mode.rawValue)
                categoryOptions=\(self.describeCategoryOptions(session.categoryOptions))
                outputVolume=\(session.outputVolume)
                otherAudioPlaying=\(session.isOtherAudioPlaying)
                secondaryAudioShouldBeSilencedHint=\(session.secondaryAudioShouldBeSilencedHint)
                sampleRate=\(session.sampleRate)
                ioBufferDuration=\(session.ioBufferDuration)
                inputs=\(inputs.isEmpty ? "[]" : inputs.joined(separator: ", "))
                outputs=\(outputs.isEmpty ? "[]" : outputs.joined(separator: ", "))
                player=\(playerDescription)
                resolution:
                \(RestTimerNotificationSupport.debugResolutionTrace(for: resolvedName ?? preferredSound ?? RestTimerNotificationSupport.defaultSoundName))
                """,
                category: .audioSession
            )
        }

        if Thread.isMainThread {
            loggerBlock()
        } else {
            DispatchQueue.main.async(execute: loggerBlock)
        }
    }

    private func registerAudioSessionObservers() {
        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(handleAudioSessionRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(handleMediaServicesReset(_:)),
            name: AVAudioSession.mediaServicesWereResetNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(handleMediaServicesLost(_:)),
            name: AVAudioSession.mediaServicesWereLostNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(handleSilenceHint(_:)),
            name: AVAudioSession.silenceSecondaryAudioHintNotification,
            object: nil
        )
        Logger.shared.log(.debug, "🔊 [TIMER-AUDIO] Registered AVAudioSession observers", category: .audioSession)
    }

    @objc
    private func handleAudioSessionInterruption(_ notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt ?? 0
        let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
        let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
        Logger.shared.log(
            .debug,
            "[TIMER-AUDIO] Interruption type=\(String(describing: type)) options=\(describeInterruptionOptions(options)) userInfo=\(userInfo)",
            category: .audioSession
        )
        logAudioSessionSnapshot(context: "interruption")
    }

    @objc
    private func handleAudioSessionRouteChange(_ notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt ?? 0
        let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
        Logger.shared.log(
            .debug,
            "[TIMER-AUDIO] Route change reason=\(String(describing: reason)) userInfo=\(userInfo)",
            category: .audioSession
        )
        logAudioSessionSnapshot(context: "route change")
    }

    @objc
    private func handleMediaServicesReset(_ notification: Notification) {
        Logger.shared.log(.warning, "⚠️ [TIMER-AUDIO] Media services were reset", category: .audioSession)
        logAudioSessionSnapshot(context: "media services reset")
    }

    @objc
    private func handleMediaServicesLost(_ notification: Notification) {
        Logger.shared.log(.warning, "⚠️ [TIMER-AUDIO] Media services were lost", category: .audioSession)
        logAudioSessionSnapshot(context: "media services lost")
    }

    @objc
    private func handleSilenceHint(_ notification: Notification) {
        Logger.shared.log(
            .debug,
            "[TIMER-AUDIO] Secondary audio silence hint userInfo=\(notification.userInfo ?? [:])",
            category: .audioSession
        )
        logAudioSessionSnapshot(context: "secondary audio silence hint")
    }

    private func describeCategoryOptions(_ options: AVAudioSession.CategoryOptions) -> String {
        let known: [(AVAudioSession.CategoryOptions, String)] = [
            (.mixWithOthers, "mixWithOthers"),
            (.duckOthers, "duckOthers"),
            (.interruptSpokenAudioAndMixWithOthers, "interruptSpokenAudioAndMixWithOthers"),
            (.allowBluetooth, "allowBluetooth"),
            (.allowBluetoothA2DP, "allowBluetoothA2DP"),
            (.defaultToSpeaker, "defaultToSpeaker"),
            (.allowAirPlay, "allowAirPlay"),
            (.overrideMutedMicrophoneInterruption, "overrideMutedMicrophoneInterruption"),
        ]

        let enabled = known.compactMap { option, name in
            options.contains(option) ? name : nil
        }

        return enabled.isEmpty ? "[]" : enabled.joined(separator: ", ")
    }

    private func describeInterruptionOptions(_ options: AVAudioSession.InterruptionOptions) -> String {
        if options.isEmpty {
            return "[]"
        }

        var values: [String] = []
        if options.contains(.shouldResume) {
            values.append("shouldResume")
        }
        return values.joined(separator: ", ")
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

extension TimerSoundFix {
    func setupFlutterChannel(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: ChannelNames.timerSoundFix,
            binaryMessenger: messenger
        )

        channel.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "playTimerSound":
                let soundName = (call.arguments as? [String: Any])?["soundName"] as? String
                result(self?.playTimerCompletionSound(preferredSound: soundName, isPreview: true) ?? false)

            case "testAllSounds":
                self?.testAllSounds()
                result(true)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}

extension TimerSoundFix: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        cleanupPlayer()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error {
            Logger.shared.log(.error, "❌ Timer sound decode error: \(error.localizedDescription)", category: .audioSession)
        }
        cleanupPlayer()
    }
}
