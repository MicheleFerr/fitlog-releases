import Flutter

/// Singleton registry for FlutterMethodChannel instances.
/// Avoids recreating channels on every notification/event — reuses cached instances.
///
/// Usage:
///   FlutterChannelRegistry.shared.setup(with: messenger)
///   FlutterChannelRegistry.shared.unified?.invokeMethod("foo", arguments: nil)
final class FlutterChannelRegistry {

    static let shared = FlutterChannelRegistry()

    // FIX #13: NSLock protects concurrent read/write access to channels and messenger.
    // Without this, simultaneous calls from different threads can corrupt the dictionary
    // or produce a crash (Swift dictionaries are not thread-safe).
    private let lock = NSLock()
    private var messenger: FlutterBinaryMessenger?
    private var channels: [String: FlutterMethodChannel] = [:]

    private init() {}

    // MARK: - Setup

    /// Must be called once during app startup with the Flutter binary messenger.
    func setup(with messenger: FlutterBinaryMessenger) {
        lock.lock()
        self.messenger = messenger
        lock.unlock()
        Logger.shared.log(.info, "FlutterChannelRegistry: messenger registered")
    }

    // MARK: - Channel Access

    /// Returns (or creates) a cached FlutterMethodChannel for the given name.
    func channel(for name: String) -> FlutterMethodChannel? {
        lock.lock()
        defer { lock.unlock() }

        guard let messenger = messenger else {
            Logger.shared.log(.warning, "FlutterChannelRegistry: messenger not set, cannot create channel \(name)")
            return nil
        }

        if let cached = channels[name] {
            return cached
        }

        let channel = FlutterMethodChannel(name: name, binaryMessenger: messenger)
        channels[name] = channel
        return channel
    }

    // MARK: - Convenience Accessors

    var unified: FlutterMethodChannel? { channel(for: ChannelNames.unified) }
}
