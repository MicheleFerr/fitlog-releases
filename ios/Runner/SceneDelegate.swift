import UIKit
import Flutter

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var lastActiveTime: Date?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Create the Flutter engine
        let flutterEngine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine

        // Create window with Flutter view controller
        window = UIWindow(windowScene: windowScene)

        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        window?.rootViewController = flutterViewController
        window?.makeKeyAndVisible()

        Logger.shared.log(.info, "SceneDelegate: Scene connected", category: .general)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        Logger.shared.log(.info, "SceneDelegate: Scene disconnected", category: .general)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Prevent duplicate active events within 1 second
        let now = Date()
        if let lastTime = lastActiveTime, now.timeIntervalSince(lastTime) < 1.0 {
            return // Skip duplicate event
        }
        lastActiveTime = now

        Logger.shared.log(.info, "SceneDelegate: Scene became active", category: .general)

        // Reactivate audio session when scene becomes active
        if FeatureFlags.useNewAudioManager {
            AudioSessionManager.shared.reactivate()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        Logger.shared.log(.info, "SceneDelegate: Scene will resign active", category: .general)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        Logger.shared.log(.info, "SceneDelegate: Scene will enter foreground", category: .general)

        // Transition audio to foreground
        if FeatureFlags.useNewAudioManager {
            AudioSessionManager.shared.transitionToForeground()
        }

        // Cancel background tasks
        if FeatureFlags.useNewBackgroundTaskManager {
            if #available(iOS 13.0, *) {
                BackgroundTaskManager.shared.cancelAllTasks()
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        Logger.shared.log(.info, "SceneDelegate: Scene did enter background", category: .general)

        // Transition audio to background
        if FeatureFlags.useNewAudioManager {
            AudioSessionManager.shared.transitionToBackground()
        }

        // Schedule background tasks
        if FeatureFlags.useNewBackgroundTaskManager {
            if #available(iOS 13.0, *) {
                BackgroundTaskManager.shared.scheduleAppRefresh()
                BackgroundTaskManager.shared.scheduleProcessingTask()
            }
        }
    }
}