import Foundation
import UIKit

/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: Managers
 * 🎯 Feature: Battery Optimization for Silent Loop
 * 🔧 Type: Utility Manager
 * 🌍 Localization: N/A (system level)
 * 🎨 Theme: N/A (system level)
 * 📱 Platform: iOS Only
 * 
 * Dependencies:
 * - UIKit: Battery monitoring
 * - Foundation: Timer management
 */

/// Manages battery optimization strategies for silent audio loops
/// CRITICAL: Prevents excessive battery drain from background audio
final class BatteryOptimizationManager {
    
    // MARK: - Singleton
    static let shared = BatteryOptimizationManager()
    
    // MARK: - Configuration
    private struct Config {
        // Battery level thresholds
        static let criticalBatteryLevel: Float = 0.10  // 10%
        static let lowBatteryLevel: Float = 0.20       // 20%
        
        // Silent loop limits based on battery
        static let maxSilentLoopWhenLow: TimeInterval = 300      // 5 minutes
        static let maxSilentLoopWhenCritical: TimeInterval = 60  // 1 minute
        static let maxSilentLoopWhenNormal: TimeInterval = 3600  // 1 hour
        
        // Monitoring intervals
        static let batteryCheckInterval: TimeInterval = 60 // 1 minute
    }
    
    // MARK: - Properties
    private var batteryMonitoringTimer: Timer?
    private var silentLoopStartTime: Date?
    private var batteryOptimizationDelegate: BatteryOptimizationDelegate?
    
    // MARK: - Initialization
    private init() {
        setupBatteryMonitoring()
        Logger.shared.log(.info, "BatteryOptimizationManager initialized", category: .system)
    }
    
    deinit {
        stopBatteryMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Determines if silent loop should be allowed based on current battery state
    func shouldAllowSilentLoop(duration: TimeInterval) -> (allowed: Bool, maxDuration: TimeInterval, reason: String) {
        let batteryLevel = getBatteryLevel()
        let batteryState = getBatteryState()
        
        // Always allow if charging
        if batteryState == .charging || batteryState == .full {
            Logger.shared.log(.info, "🔋 Battery charging - silent loop allowed for full duration", category: .battery)
            return (true, duration, "Battery charging")
        }
        
        // Check battery level thresholds
        if batteryLevel <= Config.criticalBatteryLevel {
            let maxDuration = min(duration, Config.maxSilentLoopWhenCritical)
            Logger.shared.log(.warning, "🔋 Critical battery (\(Int(batteryLevel*100))%) - limiting silent loop to \(maxDuration)s", category: .battery)
            return (true, maxDuration, "Critical battery - limited to \(Int(maxDuration))s")
            
        } else if batteryLevel <= Config.lowBatteryLevel {
            let maxDuration = min(duration, Config.maxSilentLoopWhenLow)
            Logger.shared.log(.info, "🔋 Low battery (\(Int(batteryLevel*100))%) - limiting silent loop to \(maxDuration)s", category: .battery)
            return (true, maxDuration, "Low battery - limited to \(Int(maxDuration/60))m")
            
        } else {
            let maxDuration = min(duration, Config.maxSilentLoopWhenNormal)
            Logger.shared.log(.info, "🔋 Normal battery (\(Int(batteryLevel*100))%) - silent loop allowed", category: .battery)
            return (true, maxDuration, "Normal battery")
        }
    }
    
    /// Starts monitoring battery during silent loop
    func startSilentLoopMonitoring() {
        silentLoopStartTime = Date()
        startBatteryMonitoring()
        Logger.shared.log(.info, "🔋 Started battery monitoring for silent loop", category: .battery)
    }
    
    /// Stops monitoring battery
    func stopSilentLoopMonitoring() {
        silentLoopStartTime = nil
        stopBatteryMonitoring()
        Logger.shared.log(.info, "🔋 Stopped battery monitoring", category: .battery)
    }
    
    /// Sets delegate for battery optimization events
    func setDelegate(_ delegate: BatteryOptimizationDelegate) {
        batteryOptimizationDelegate = delegate
    }
    
    /// Gets current battery metrics for debugging
    func getBatteryMetrics() -> [String: Any] {
        let batteryLevel = getBatteryLevel()
        let batteryState = getBatteryState()
        
        return [
            "batteryLevel": batteryLevel,
            "batteryState": batteryStateString(batteryState),
            "isCharging": batteryState == .charging || batteryState == .full,
            "silentLoopRuntime": silentLoopStartTime != nil ? Date().timeIntervalSince(silentLoopStartTime!) : 0,
            "recommendedMaxDuration": getRecommendedMaxDuration()
        ]
    }
    
    // MARK: - Private Methods
    
    private func setupBatteryMonitoring() {
        // Enable battery monitoring
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // Register for battery level notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelChanged),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateChanged),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
    }
    
    private func startBatteryMonitoring() {
        // Stop existing timer
        batteryMonitoringTimer?.invalidate()
        
        // Start periodic monitoring
        batteryMonitoringTimer = Timer.scheduledTimer(withTimeInterval: Config.batteryCheckInterval, repeats: true) { [weak self] _ in
            self?.checkBatteryStatus()
        }
    }
    
    private func stopBatteryMonitoring() {
        batteryMonitoringTimer?.invalidate()
        batteryMonitoringTimer = nil
    }
    
    @objc private func batteryLevelChanged() {
        Logger.shared.log(.debug, "🔋 Battery level changed to \(Int(getBatteryLevel()*100))%", category: .battery)
        checkBatteryStatus()
    }
    
    @objc private func batteryStateChanged() {
        Logger.shared.log(.info, "🔋 Battery state changed to \(batteryStateString(getBatteryState()))", category: .battery)
        checkBatteryStatus()
    }
    
    private func checkBatteryStatus() {
        let batteryLevel = getBatteryLevel()
        let batteryState = getBatteryState()
        
        // Check for critical battery during silent loop
        if silentLoopStartTime != nil && batteryLevel <= Config.criticalBatteryLevel && batteryState != .charging {
            Logger.shared.log(.warning, "🔋 CRITICAL: Battery at \(Int(batteryLevel*100))% during silent loop", category: .battery)
            batteryOptimizationDelegate?.batteryLevelCritical()
        }
        
        // Check for low battery warning
        if silentLoopStartTime != nil && batteryLevel <= Config.lowBatteryLevel && batteryState != .charging {
            Logger.shared.log(.warning, "🔋 LOW: Battery at \(Int(batteryLevel*100))% during silent loop", category: .battery)
            batteryOptimizationDelegate?.batteryLevelLow()
        }
    }
    
    private func getBatteryLevel() -> Float {
        return UIDevice.current.batteryLevel
    }
    
    private func getBatteryState() -> UIDevice.BatteryState {
        return UIDevice.current.batteryState
    }
    
    private func batteryStateString(_ state: UIDevice.BatteryState) -> String {
        switch state {
        case .unknown: return "Unknown"
        case .unplugged: return "Unplugged"
        case .charging: return "Charging"
        case .full: return "Full"
        @unknown default: return "Unknown"
        }
    }
    
    private func getRecommendedMaxDuration() -> TimeInterval {
        let batteryLevel = getBatteryLevel()
        let batteryState = getBatteryState()
        
        if batteryState == .charging || batteryState == .full {
            return Config.maxSilentLoopWhenNormal
        } else if batteryLevel <= Config.criticalBatteryLevel {
            return Config.maxSilentLoopWhenCritical
        } else if batteryLevel <= Config.lowBatteryLevel {
            return Config.maxSilentLoopWhenLow
        } else {
            return Config.maxSilentLoopWhenNormal
        }
    }
}

// MARK: - Battery Optimization Delegate

protocol BatteryOptimizationDelegate: AnyObject {
    func batteryLevelCritical()
    func batteryLevelLow()
}

