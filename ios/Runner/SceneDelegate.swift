import Flutter
import UIKit

final class SceneDelegate: FlutterSceneDelegate {
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        forwardIncomingURLContexts(connectionOptions.urlContexts)
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }

    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        forwardIncomingURLContexts(URLContexts)
        super.scene(scene, openURLContexts: URLContexts)
    }

    private func forwardIncomingURLContexts(_ urlContexts: Set<UIOpenURLContext>) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        for urlContext in urlContexts {
            _ = appDelegate.storePendingDeepLinkIfNeeded(from: urlContext.url)
        }
    }
}
