import Foundation
import Network
import NetworkExtension

/// Manages network configuration and connectivity monitoring
final class NetworkConfiguration {

    static let shared = NetworkConfiguration()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.gymbro.network.monitor")

    private init() {
        setupNetworkMonitoring()
        configureURLSession()
    }

    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                Logger.shared.log(.debug, "✅ Network connected", category: .general)

                // Check for IPv6 support
                let supportsIPv4 = path.supportsIPv4
                let supportsIPv6 = path.supportsIPv6

                if supportsIPv6 && !supportsIPv4 {
                    Logger.shared.log(.warning, "⚠️ Only IPv6 available, may experience connectivity issues", category: .general)
                }

            } else {
                Logger.shared.log(.warning, "❌ Network disconnected", category: .general)
            }
        }

        monitor.start(queue: queue)
    }

    private func configureURLSession() {
        // Configure default URL session to prefer IPv4 when available
        let config = URLSessionConfiguration.default

        // Increase timeouts for poor connections
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60

        // Allow cellular access
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true

        // Note: HTTP/3 configuration is handled automatically by the system

        // Configure TCP to be more resilient
        config.multipathServiceType = .handover
        config.waitsForConnectivity = true

        URLSessionConfiguration.default.timeoutIntervalForRequest = 30
        URLSessionConfiguration.default.timeoutIntervalForResource = 60
    }

    /// Force IPv4 for problematic connections
    static func preferIPv4ForFirebase() {
        // This helps with Firebase connectivity issues on IPv6-only networks
        if #available(iOS 14.0, *) {
            // Set DNS over HTTPS to use Google's DNS which handles IPv4/IPv6 better
            let dnsSettings = NEDNSOverHTTPSSettings(servers: ["8.8.8.8", "8.8.4.4"])
            dnsSettings.serverURL = URL(string: "https://dns.google/dns-query")

            let dnsConfig = NEDNSSettingsManager.shared()
            dnsConfig.dnsSettings = dnsSettings

            dnsConfig.saveToPreferences { error in
                if let error = error {
                    Logger.shared.log(.debug, "DNS configuration skipped: \(error.localizedDescription)", category: .general)
                }
            }
        }
    }
}