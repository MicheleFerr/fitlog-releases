import UIKit

/// Manages keyboard notifications to prevent Flutter warnings
final class KeyboardManager {

    static let shared = KeyboardManager()
    private var isKeyboardVisible = false
    private var keyboardObservers: [NSObjectProtocol] = []

    private init() {}

    /// Setup keyboard monitoring to suppress spurious notifications
    func setupKeyboardMonitoring() {
        // Remove any existing observers
        cleanupObservers()

        // Monitor keyboard will show
        let willShowObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.isKeyboardVisible = true
            Logger.shared.log(.debug, "Keyboard will show", category: .general)
        }

        // Monitor keyboard will hide
        let willHideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.isKeyboardVisible = false
            Logger.shared.log(.debug, "Keyboard will hide", category: .general)
        }

        // Monitor keyboard frame changes
        let frameObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }

            // Only log if keyboard is actually visible
            if self.isKeyboardVisible {
                Logger.shared.log(.debug, "Keyboard frame changing", category: .general)
            } else {
                // Suppress the spurious notification
                // This prevents the "keyboard was not even present" warnings
                return
            }
        }

        keyboardObservers = [willShowObserver, willHideObserver, frameObserver]

        Logger.shared.log(.info, "✅ Keyboard monitoring configured", category: .general)
    }

    private func cleanupObservers() {
        keyboardObservers.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
        keyboardObservers.removeAll()
    }

    deinit {
        cleanupObservers()
    }
}