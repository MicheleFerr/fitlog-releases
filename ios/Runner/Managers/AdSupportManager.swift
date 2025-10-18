import Foundation
import AdSupport
import AppTrackingTransparency

/// Manages advertising tracking and AdSupport framework
final class AdSupportManager {

    static let shared = AdSupportManager()

    private init() {}

    /// Request tracking authorization for iOS 14.5+
    func requestTrackingAuthorization(completion: @escaping (Bool) -> Void) {
        if #available(iOS 14.5, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    Logger.shared.log(.info, "✅ Tracking authorized", category: .permission)
                    completion(true)

                case .denied:
                    Logger.shared.log(.info, "❌ Tracking denied by user", category: .permission)
                    completion(false)

                case .restricted:
                    Logger.shared.log(.info, "⚠️ Tracking restricted", category: .permission)
                    completion(false)

                case .notDetermined:
                    Logger.shared.log(.info, "❓ Tracking not determined", category: .permission)
                    completion(false)

                @unknown default:
                    Logger.shared.log(.warning, "Unknown tracking status", category: .permission)
                    completion(false)
                }

                // Log IDFA status for Firebase Analytics
                self.logIDFAStatus()
            }
        } else {
            // iOS < 14.5 - tracking is automatically allowed
            Logger.shared.log(.info, "✅ Tracking available (iOS < 14.5)", category: .permission)
            logIDFAStatus()
            completion(true)
        }
    }

    /// Check if advertising tracking is enabled
    var isAdvertisingTrackingEnabled: Bool {
        if #available(iOS 14.5, *) {
            return ATTrackingManager.trackingAuthorizationStatus == .authorized
        } else {
            return ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        }
    }

    /// Get advertising identifier if available
    var advertisingIdentifier: String? {
        guard isAdvertisingTrackingEnabled else { return nil }
        let idfa = ASIdentifierManager.shared().advertisingIdentifier
        return idfa.uuidString == "00000000-0000-0000-0000-000000000000" ? nil : idfa.uuidString
    }

    private func logIDFAStatus() {
        Logger.shared.log(.debug, """
            📊 AdSupport Status:
            - Tracking Enabled: \(isAdvertisingTrackingEnabled ? "✅" : "❌")
            - IDFA Available: \(advertisingIdentifier != nil ? "✅" : "❌")
            - Firebase Analytics: \(isAdvertisingTrackingEnabled ? "Full features" : "Limited features")
            """, category: .permission)
    }
}