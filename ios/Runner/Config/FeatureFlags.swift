import Foundation

/// Feature flags for safe rollout of new implementations
final class FeatureFlags {
    
    // MARK: - Flag Keys
    
    private enum FlagKey: String, CaseIterable {
        case useNewAudioManager = "com.gymbro.feature.newAudioManager"
        case useNewBackgroundTaskManager = "com.gymbro.feature.newBackgroundTaskManager"
        case useEnhancedLogging = "com.gymbro.feature.enhancedLogging"
        case useErrorRecovery = "com.gymbro.feature.errorRecovery"
        case showDebugInfo = "com.gymbro.feature.showDebugInfo"
        // REMOVED: useOptimizedTimer - optimization is now always active
        
        var defaultValue: Bool {
            switch self {
            case .useNewAudioManager:
                #if DEBUG
                return false  // ⚠️ DISABLED: OSStatus -50 errors persist, using legacy audio manager
                #else
                return false  // ⚠️ DISABLED: CoreAudio SessionCore failures, reverting to legacy
                #endif
                
            case .useNewBackgroundTaskManager:
                #if DEBUG
                return true
                #else
                return false
                #endif
                
            case .useEnhancedLogging:
                #if DEBUG
                return true
                #else
                return false
                #endif
                
            case .useErrorRecovery:
                return true  // Always enabled for safety

            case .showDebugInfo:
                #if DEBUG
                return true
                #else
                return false
                #endif
            }
        }
        
        var description: String {
            switch self {
            case .useNewAudioManager:
                return "New Audio Session Manager"
            case .useNewBackgroundTaskManager:
                return "New Background Task Manager"
            case .useEnhancedLogging:
                return "Enhanced Logging System"
            case .useErrorRecovery:
                return "Error Recovery System"
            case .showDebugInfo:
                return "Show Debug Information"
            }
        }
    }
    
    // MARK: - Properties
    
    static let shared = FeatureFlags()
    
    private let userDefaults = UserDefaults.standard
    private var overrides: [FlagKey: Bool] = [:]
    
    // Remote configuration support
    private var remoteFlags: [String: Bool] = [:]
    private var hasLoadedRemoteFlags = false
    
    // MARK: - Initialization
    
    private init() {
        loadPersistedOverrides()
        Logger.shared.log(.info, "FeatureFlags initialized")
    }
    
    // MARK: - Public Accessors
    
    static var useNewAudioManager: Bool {
        return shared.isEnabled(.useNewAudioManager)
    }
    
    static var useNewBackgroundTaskManager: Bool {
        return shared.isEnabled(.useNewBackgroundTaskManager)
    }
    
    static var useEnhancedLogging: Bool {
        return shared.isEnabled(.useEnhancedLogging)
    }
    
    static var useErrorRecovery: Bool {
        return shared.isEnabled(.useErrorRecovery)
    }
    
    static var showDebugInfo: Bool {
        return shared.isEnabled(.showDebugInfo)
    }

    // REMOVED: useOptimizedTimer accessor - feature is now permanently enabled

    // MARK: - Flag Management
    
    private func isEnabled(_ flag: FlagKey) -> Bool {
        // Priority order:
        // 1. Local override (for testing)
        // 2. Remote configuration
        // 3. Default value
        
        if let override = overrides[flag] {
            return override
        }
        
        if hasLoadedRemoteFlags, let remoteValue = remoteFlags[flag.rawValue] {
            return remoteValue
        }
        
        return flag.defaultValue
    }
    
    // MARK: - Override Management (for testing)
    
    func setOverride(_ enabled: Bool, for flagKey: String) {
        guard let flag = FlagKey(rawValue: flagKey) else {
            Logger.shared.log(.warning, "Invalid feature flag key: \(flagKey)")
            return
        }
        
        overrides[flag] = enabled
        savePersistedOverrides()
        
        Logger.shared.log(.info, "Feature flag override set: \(flag.description) = \(enabled)")
    }
    
    func clearOverride(for flagKey: String) {
        guard let flag = FlagKey(rawValue: flagKey) else {
            return
        }
        
        overrides[flag] = nil
        savePersistedOverrides()
        
        Logger.shared.log(.info, "Feature flag override cleared: \(flag.description)")
    }
    
    func clearAllOverrides() {
        overrides.removeAll()
        savePersistedOverrides()
        
        Logger.shared.log(.info, "All feature flag overrides cleared")
    }
    
    // MARK: - Remote Configuration
    
    func updateRemoteFlags(_ flags: [String: Bool]) {
        remoteFlags = flags
        hasLoadedRemoteFlags = true
        
        Logger.shared.log(.info, "Remote feature flags updated: \(flags.count) flags")
    }
    
    // MARK: - Persistence
    
    private func loadPersistedOverrides() {
        if let data = userDefaults.data(forKey: "com.gymbro.featureFlags.overrides"),
           let decoded = try? JSONDecoder().decode([String: Bool].self, from: data) {
            
            // Convert string keys back to FlagKey enum
            for (key, value) in decoded {
                if let flag = FlagKey(rawValue: key) {
                    overrides[flag] = value
                }
            }
            
            Logger.shared.log(.debug, "Loaded \(overrides.count) feature flag overrides")
        }
    }
    
    private func savePersistedOverrides() {
        // Convert FlagKey enum to string for persistence
        let stringKeyedOverrides = overrides.reduce(into: [String: Bool]()) { result, pair in
            result[pair.key.rawValue] = pair.value
        }
        
        if let data = try? JSONEncoder().encode(stringKeyedOverrides) {
            userDefaults.set(data, forKey: "com.gymbro.featureFlags.overrides")
        }
    }
    
    // MARK: - Debug & Monitoring
    
    func getAllFlags() -> [String: Bool] {
        var allFlags: [String: Bool] = [:]
        
        for flag in FlagKey.allCases {
            allFlags[flag.rawValue] = isEnabled(flag)
        }
        
        return allFlags
    }
    
    func getDebugInfo() -> String {
        var info = "=== Feature Flags Status ===\n"
        
        for flag in FlagKey.allCases {
            let status = isEnabled(flag) ? "✅ Enabled" : "❌ Disabled"
            let source: String
            
            if overrides[flag] != nil {
                source = "(Override)"
            } else if hasLoadedRemoteFlags && remoteFlags[flag.rawValue] != nil {
                source = "(Remote)"
            } else {
                source = "(Default)"
            }
            
            info += "\(flag.description): \(status) \(source)\n"
        }
        
        return info
    }
    
    // MARK: - A/B Testing Support
    
    func getUserBucket() -> String {
        // Generate or retrieve a stable user bucket for A/B testing
        let bucketKey = "com.gymbro.featureFlags.userBucket"
        
        if let bucket = userDefaults.string(forKey: bucketKey) {
            return bucket
        }
        
        // Generate new bucket (simple percentage-based)
        let randomValue = Int.random(in: 0..<100)
        let bucket: String
        
        if randomValue < 5 {
            bucket = "5percent"
        } else if randomValue < 25 {
            bucket = "25percent"
        } else if randomValue < 50 {
            bucket = "50percent"
        } else {
            bucket = "control"
        }
        
        userDefaults.set(bucket, forKey: bucketKey)
        Logger.shared.log(.info, "User assigned to A/B test bucket: \(bucket)")
        
        return bucket
    }
}

// MARK: - Convenience Extensions

extension FeatureFlags {
    /// Enable gradual rollout based on user bucket
    func shouldEnableForRollout(percentage: Int) -> Bool {
        let bucket = getUserBucket()
        
        switch bucket {
        case "5percent":
            return percentage >= 5
        case "25percent":
            return percentage >= 25
        case "50percent":
            return percentage >= 50
        default:
            return percentage >= 100
        }
    }
}