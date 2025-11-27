import UIKit
import Flutter

/// SceneDelegate for UIScene lifecycle support
/// Must extend FlutterSceneDelegate for proper Flutter integration
@available(iOS 13.0, *)
class SceneDelegate: FlutterSceneDelegate {

    private var lastActiveTime: Date?

    // MARK: - Scene Lifecycle

    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Call super to let FlutterSceneDelegate handle Flutter setup
        super.scene(scene, willConnectTo: session, options: connectionOptions)

        Logger.shared.log(.info, "SceneDelegate: Scene connected", category: .general)
    }

    override func sceneDidDisconnect(_ scene: UIScene) {
        super.sceneDidDisconnect(scene)
        Logger.shared.log(.info, "SceneDelegate: Scene disconnected", category: .general)
    }

    override func sceneDidBecomeActive(_ scene: UIScene) {
        super.sceneDidBecomeActive(scene)

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

    override func sceneWillResignActive(_ scene: UIScene) {
        super.sceneWillResignActive(scene)
        Logger.shared.log(.info, "SceneDelegate: Scene will resign active", category: .general)
    }

    override func sceneWillEnterForeground(_ scene: UIScene) {
        super.sceneWillEnterForeground(scene)
        Logger.shared.log(.info, "SceneDelegate: Scene will enter foreground", category: .general)

        // Transition audio to foreground
        if FeatureFlags.useNewAudioManager {
            AudioSessionManager.shared.transitionToForeground()
        }

        // Cancel background tasks
        if FeatureFlags.useNewBackgroundTaskManager {
            BackgroundTaskManager.shared.cancelAllTasks()
        }
    }

    override func sceneDidEnterBackground(_ scene: UIScene) {
        super.sceneDidEnterBackground(scene)
        Logger.shared.log(.info, "SceneDelegate: Scene did enter background", category: .general)

        // Transition audio to background
        if FeatureFlags.useNewAudioManager {
            AudioSessionManager.shared.transitionToBackground()
        }

        // Schedule background tasks
        if FeatureFlags.useNewBackgroundTaskManager {
            BackgroundTaskManager.shared.scheduleAppRefresh()
            BackgroundTaskManager.shared.scheduleProcessingTask()
        }
    }
}
