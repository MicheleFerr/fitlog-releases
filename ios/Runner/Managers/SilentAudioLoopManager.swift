import Foundation
import AVFoundation
import UIKit

/// Gestisce un loop audio silenzioso per mantenere l'app attiva in background
/// Strategia usata con successo in passato per garantire timer affidabili
final class SilentAudioLoopManager {
    
    // MARK: - Singleton
    static let shared = SilentAudioLoopManager()
    
    // MARK: - Properties
    private var silentAudioPlayer: AVAudioPlayer?
    private var isLoopActive = false
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    // MARK: - Initialization
    private init() {
        Logger.shared.log(.info, "🔇 SilentAudioLoopManager initialized", category: .audioSession)
        setupSilentAudioPlayer()
    }
    
    // MARK: - Setup
    private func setupSilentAudioPlayer() {
        // Create silent audio data (1 second of silence)
        let sampleRate = 44100.0
        let duration = 1.0
        let frameCount = Int(sampleRate * duration)
        let bytesPerFrame = 2 // 16-bit audio
        let dataSize = frameCount * bytesPerFrame
        
        // Create silent audio data (all zeros)
        let silentData = Data(count: dataSize)
        
        // Create WAV header
        var wavHeader = Data()
        
        // RIFF header
        wavHeader.append(contentsOf: "RIFF".utf8)
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt32(dataSize + 36).littleEndian) { Data($0) })
        wavHeader.append(contentsOf: "WAVE".utf8)
        
        // fmt chunk
        wavHeader.append(contentsOf: "fmt ".utf8)
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) }) // PCM
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) }) // Mono
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) })
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate * 2).littleEndian) { Data($0) })
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt16(2).littleEndian) { Data($0) })
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt16(16).littleEndian) { Data($0) })
        
        // data chunk
        wavHeader.append(contentsOf: "data".utf8)
        wavHeader.append(contentsOf: withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Data($0) })
        
        // Combine header and silent data
        var completeData = wavHeader
        completeData.append(silentData)
        
        do {
            silentAudioPlayer = try AVAudioPlayer(data: completeData)
            silentAudioPlayer?.numberOfLoops = -1 // Loop infinito
            silentAudioPlayer?.volume = 0.0001 // Volume quasi zero
            silentAudioPlayer?.prepareToPlay()
            
            Logger.shared.log(.info, "✅ Silent audio player prepared", category: .audioSession)
        } catch {
            Logger.shared.log(.error, "Failed to create silent audio player: \(error)", category: .audioSession)
        }
    }
    
    // MARK: - Public Methods
    
    /// Start silent audio loop to keep app active
    func startSilentLoop(forTimerDuration duration: TimeInterval) {
        guard !isLoopActive else {
            Logger.shared.log(.info, "Silent loop already active", category: .audioSession)
            return
        }
        
        Logger.shared.log(.info, "🔇 Starting silent audio loop for \(duration)s timer", category: .audioSession)
        
        // Configure audio session for background playback
        configureAudioSession()
        
        // Start background task
        startBackgroundTask()
        
        // Start silent audio playback
        silentAudioPlayer?.play()
        isLoopActive = true
        
        // Schedule automatic stop after timer duration
        DispatchQueue.global().asyncAfter(deadline: .now() + duration + 1) { [weak self] in
            self?.stopSilentLoop()
        }
        
        Logger.shared.log(.info, "✅ Silent loop started - app will stay active in background", category: .audioSession)
    }
    
    /// Stop silent audio loop
    func stopSilentLoop() {
        guard isLoopActive else { return }
        
        Logger.shared.log(.info, "🔇 Stopping silent audio loop", category: .audioSession)
        
        silentAudioPlayer?.stop()
        isLoopActive = false
        
        endBackgroundTask()
        
        Logger.shared.log(.info, "✅ Silent loop stopped", category: .audioSession)
    }
    
    /// Check if silent loop is currently active
    func isActive() -> Bool {
        return isLoopActive
    }
    
    // MARK: - Audio Session Configuration
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            
            // Configure for background playback
            try session.setCategory(.playback, 
                                   mode: .default, 
                                   options: [.mixWithOthers, .allowBluetooth, .allowAirPlay])
            
            try session.setActive(true)
            
            Logger.shared.log(.info, "✅ Audio session configured for silent loop", category: .audioSession)
        } catch {
            Logger.shared.log(.error, "Failed to configure audio session: \(error)", category: .audioSession)
        }
    }
    
    // MARK: - Background Task Management
    private func startBackgroundTask() {
        endBackgroundTask() // Clean up any existing task
        
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            Logger.shared.log(.warning, "Background task expiring during silent loop", category: .backgroundTask)
            self?.endBackgroundTask()
        }
        
        if backgroundTask != .invalid {
            Logger.shared.log(.info, "Background task started for silent loop", category: .backgroundTask)
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
            Logger.shared.log(.info, "Background task ended", category: .backgroundTask)
        }
    }
}

// MARK: - Flutter Integration
extension SilentAudioLoopManager {
    /// Handle Flutter method calls for silent loop
    func handleFlutterCall(method: String, arguments: Any?) -> Any? {
        switch method {
        case "startSilentLoop":
            if let args = arguments as? [String: Any],
               let duration = args["duration"] as? Double {
                startSilentLoop(forTimerDuration: duration)
                return true
            }
            return false
            
        case "stopSilentLoop":
            stopSilentLoop()
            return true
            
        case "isSilentLoopActive":
            return isActive()
            
        default:
            return nil
        }
    }
}