import Foundation
import AdSupport
import AppTrackingTransparency
import UIKit

/// Manages advertising tracking and AdSupport framework
final class AdSupportManager {

    enum TrackingAuthorizationStatus: String {
        case authorized
        case denied
        case restricted
        case notDetermined
        case notSupported
    }

    static let shared = AdSupportManager()

    private var pendingAuthorizationObserver: NSObjectProtocol?

    private init() {}

    /// Request tracking authorization for iOS 14.5+
    func requestTrackingAuthorization(
        completion: @escaping (TrackingAuthorizationStatus) -> Void
    ) {
        if #available(iOS 14.5, *) {
            DispatchQueue.main.async {
                self.requestTrackingAuthorizationWhenActive(completion: completion)
            }
        } else {
            Logger.shared.log(
                .info,
                "ℹ️ Tracking authorization not required on iOS < 14.5",
                category: .permission
            )
            logIDFAStatus()
            completion(.notSupported)
        }
    }

    var trackingAuthorizationStatus: TrackingAuthorizationStatus {
        if #available(iOS 14.5, *) {
            return Self.map(ATTrackingManager.trackingAuthorizationStatus)
        }
        return .notSupported
    }

    private func requestTrackingAuthorizationWhenActive(
        completion: @escaping (TrackingAuthorizationStatus) -> Void
    ) {
        if #available(iOS 14.5, *) {
            if UIApplication.shared.applicationState == .active {
                ATTrackingManager.requestTrackingAuthorization { status in
                    let mappedStatus = Self.map(status)
                    self.logTrackingStatus(mappedStatus)

                    // Log IDFA status after the system prompt resolves.
                    self.logIDFAStatus()
                    completion(mappedStatus)
                }
                return
            }

            Logger.shared.log(
                .info,
                "⏳ Waiting for app to become active before showing ATT prompt",
                category: .permission
            )

            if let observer = pendingAuthorizationObserver {
                NotificationCenter.default.removeObserver(observer)
                pendingAuthorizationObserver = nil
            }
            pendingAuthorizationObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                if let observer = self.pendingAuthorizationObserver {
                    NotificationCenter.default.removeObserver(observer)
                    self.pendingAuthorizationObserver = nil
                }
                self.requestTrackingAuthorizationWhenActive(completion: completion)
            }
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

    private func logTrackingStatus(_ status: TrackingAuthorizationStatus) {
        switch status {
        case .authorized:
            Logger.shared.log(.info, "✅ Tracking authorized", category: .permission)
        case .denied:
            Logger.shared.log(.info, "❌ Tracking denied by user", category: .permission)
        case .restricted:
            Logger.shared.log(.info, "⚠️ Tracking restricted", category: .permission)
        case .notDetermined:
            Logger.shared.log(.info, "❓ Tracking not determined", category: .permission)
        case .notSupported:
            Logger.shared.log(.info, "ℹ️ Tracking authorization not supported", category: .permission)
        }
    }

    private static func map(
        _ status: ATTrackingManager.AuthorizationStatus
    ) -> TrackingAuthorizationStatus {
        switch status {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
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
