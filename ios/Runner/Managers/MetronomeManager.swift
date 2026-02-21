import Foundation
import AVFoundation
import AudioToolbox
import Flutter

/// MetronomeManager: Native iOS metronome for the TUT (Time Under Tension) feature.
///
/// Provides a precise 1-second tick using DispatchSourceTimer on a .userInteractive
/// serial queue. Optionally plays `metronome_tick.caf` and fires haptic feedback on
/// each tick. Each tick invokes the Flutter method `metronomeTick` with the current
/// elapsed-seconds count so the Dart layer can drive the TUT phase display.
///
/// Audio session config mirrors TimerSoundFix and UnifiedTimerCoordinator:
/// .playback + .mixWithOthers to bypass the mute switch without interrupting
/// background music.
final class MetronomeManager {

    // MARK: - Singleton

    static let shared = MetronomeManager()

    // MARK: - Private State

    /// Serial queue used for all state mutations and timer callbacks.
    /// QoS .userInteractive ensures the tick fires within the scheduling deadline.
    private let queue = DispatchQueue(label: "com.gymbro.metronome", qos: .userInteractive)

    private var timer: DispatchSourceTimer?
    private var player: AVAudioPlayer?
    private var elapsedSeconds: Int = 0
    private var isRunning: Bool = false
    private var soundEnabled: Bool = true
    private var hapticEnabled: Bool = true

    /// Weak reference to the Flutter channel — set by UnifiedTimerCoordinator
    /// after channel setup so MetronomeManager never owns the channel lifecycle.
    private weak var flutterChannel: FlutterMethodChannel?

    // MARK: - Initialization

    private init() {
        preloadSound()
    }

    // MARK: - Public API

    /// Inject the Flutter method channel used to send `metronomeTick` callbacks.
    /// Called once from UnifiedTimerCoordinator.setupChannel(with:).
    func setChannel(_ channel: FlutterMethodChannel?) {
        queue.async { [weak self] in
            self?.flutterChannel = channel
        }
    }

    /// Start the metronome.
    ///
    /// - Parameters:
    ///   - soundEnabled: When `true`, plays `metronome_tick.caf` on each tick.
    ///   - hapticEnabled: When `true`, triggers a UIImpactFeedbackGenerator .light on each tick.
    func start(soundEnabled: Bool, hapticEnabled: Bool) {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard !self.isRunning else {
                Logger.shared.log(.debug, "[Metronome] start() called while already running — ignored", category: .audioSession)
                return
            }

            self.soundEnabled = soundEnabled
            self.hapticEnabled = hapticEnabled
            self.elapsedSeconds = 0
            self.isRunning = true

            self.configureAudioSession()

            let timer = DispatchSource.makeTimerSource(flags: [], queue: self.queue)
            // Fire immediately on the first second, then every 1 second.
            timer.schedule(deadline: .now() + 1.0, repeating: 1.0, leeway: .milliseconds(20))
            timer.setEventHandler { [weak self] in
                self?.tick()
            }
            self.timer = timer
            timer.resume()

            Logger.shared.log(.info, "[Metronome] Started — sound: \(soundEnabled), haptic: \(hapticEnabled)", category: .audioSession)
        }
    }

    /// Stop the metronome.
    ///
    /// - Returns: The total elapsed seconds since `start()` was called.
    ///   Because this crosses the serial queue boundary the value is captured
    ///   synchronously via `queue.sync` so the caller receives the final count.
    @discardableResult
    func stop() -> Int {
        // queue.sync from *outside* the queue is safe here because `stop()` is
        // only called from the Flutter method-call handler which runs on
        // coordinationQueue (a different serial queue from com.gymbro.metronome).
        return queue.sync {
            guard self.isRunning else {
                Logger.shared.log(.debug, "[Metronome] stop() called while not running", category: .audioSession)
                return self.elapsedSeconds
            }

            self.timer?.cancel()
            self.timer = nil
            self.isRunning = false

            let elapsed = self.elapsedSeconds
            Logger.shared.log(.info, "[Metronome] Stopped — elapsed: \(elapsed)s", category: .audioSession)
            return elapsed
        }
    }

    // MARK: - Internal Tick (always on `queue`)

    /// Called by the DispatchSourceTimer every second.
    /// Plays sound, fires haptic, and notifies Flutter.
    private func tick() {
        elapsedSeconds += 1
        let current = elapsedSeconds

        // Play tick sound on the queue itself — AVAudioPlayer is thread-safe for play/stop.
        if soundEnabled {
            playTick()
        }

        // Haptic must run on the main thread.
        if hapticEnabled {
            DispatchQueue.main.async {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }

        // Notify Flutter on the main thread (Flutter requirement).
        let channel = flutterChannel
        DispatchQueue.main.async {
            channel?.invokeMethod("metronomeTick", arguments: current)
        }
    }

    // MARK: - Sound Playback

    private func playTick() {
        guard let player = player else {
            Logger.shared.log(.debug, "[Metronome] tick player not available", category: .audioSession)
            return
        }
        // Rewind and play without reinitialising the player to minimise latency.
        player.currentTime = 0
        player.play()
    }

    // MARK: - Preload

    /// Pre-load `metronome_tick.caf` so the first tick has no initialisation delay.
    private func preloadSound() {
        guard let url = Bundle.main.url(forResource: "metronome_tick", withExtension: "caf") else {
            Logger.shared.log(.warning, "[Metronome] metronome_tick.caf not found in bundle", category: .audioSession)
            return
        }

        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.volume = 1.0
            p.prepareToPlay()
            player = p
            Logger.shared.log(.info, "[Metronome] metronome_tick.caf preloaded (duration: \(p.duration)s)", category: .audioSession)
        } catch {
            Logger.shared.log(.error, "[Metronome] Failed to preload metronome_tick.caf: \(error)", category: .audioSession)
        }
    }

    // MARK: - Audio Session

    /// Configure the audio session to play the tick even when the device is muted.
    /// Uses .playback + .mixWithOthers — consistent with UnifiedTimerCoordinator and
    /// TimerSoundFix to avoid OSStatus -50 from conflicting options.
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            Logger.shared.log(.debug, "[Metronome] Audio session configured (.playback + .mixWithOthers)", category: .audioSession)
        } catch {
            Logger.shared.log(.error, "[Metronome] Audio session configuration failed: \(error)", category: .audioSession)
        }
    }
}
