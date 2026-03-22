import Foundation
import UserNotifications

/// Shared rest-timer notification policy used by the Runner app and widget intents.
enum RestTimerNotificationSupport {
    static let sharedSuiteName = "group.com.michele.gymbro.flutter"
    static let notificationIdentifier = "com.gymbro.rest_timer_completion"
    static let categoryIdentifier = "TIMER_COMPLETE"
    static let preferredSoundKey = "timer_notification_sound"
    static let defaultSoundName = "timer_complete"
    static let legacyFallbackSoundName = "sound"
    static let systemDefaultSoundLabel = "system_default"

    static func debugLog(_ message: @autoclosure () -> String) {
#if DEBUG
        print(message())
#endif
    }

    static func normalizedSoundName(_ rawValue: String?) -> String {
        let trimmed = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else {
            return defaultSoundName
        }

        let normalized = URL(fileURLWithPath: trimmed)
            .deletingPathExtension()
            .lastPathComponent
        return normalized.isEmpty ? defaultSoundName : normalized
    }

    static func preferredSoundName(from userDefaults: UserDefaults?) -> String {
        normalizedSoundName(userDefaults?.string(forKey: preferredSoundKey))
    }

    static func resolvedSoundFileName(for soundName: String, in bundle: Bundle = .main) -> String? {
        let normalized = normalizedSoundName(soundName)
        let candidates = [normalized, defaultSoundName, legacyFallbackSoundName]

        for candidate in candidates {
            if bundle.url(forResource: candidate, withExtension: "caf") != nil {
                return "\(candidate).caf"
            }

            if bundle.url(forResource: candidate, withExtension: "wav") != nil {
                return "\(candidate).wav"
            }
        }

        return nil
    }

    static func debugResolutionTrace(for soundName: String, in bundle: Bundle = .main) -> String {
        let normalized = normalizedSoundName(soundName)
        let candidates = [normalized, defaultSoundName, legacyFallbackSoundName]
        let candidateDescriptions = candidates.map { candidate in
            let cafExists = bundle.url(forResource: candidate, withExtension: "caf") != nil
            let wavExists = bundle.url(forResource: candidate, withExtension: "wav") != nil
            return "\(candidate)[caf=\(cafExists), wav=\(wavExists)]"
        }

        return """
        normalized=\(normalized)
        bundle=\(bundle.bundlePath)
        candidates=\(candidateDescriptions.joined(separator: ", "))
        """
    }

    static func makeContent(
        title: String,
        body: String,
        soundName: String,
        categoryIdentifier: String = categoryIdentifier,
        userInfo: [AnyHashable: Any] = [:],
        playSound: Bool = true,
        bundle: Bundle = .main
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = categoryIdentifier

        var mergedUserInfo = userInfo
        let normalized = normalizedSoundName(soundName)
        mergedUserInfo["gymbro_timer_sound"] = normalized
        content.userInfo = mergedUserInfo

        if playSound {
            if let resolvedFileName = resolvedSoundFileName(for: normalized, in: bundle) {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(resolvedFileName))
            } else {
                content.sound = .default
            }
        }

        // Ensure sound plays even when device is locked or in Focus mode
        content.interruptionLevel = .timeSensitive

        debugLog(
            """
            🔔 [REST TIMER SUPPORT] makeContent
            title=\(title)
            body=\(body)
            inputSoundName=\(soundName)
            normalizedSoundName=\(normalized)
            effectiveSoundStrategy=\("custom_or_fallback")
            resolvedNotificationSound=\(String(describing: content.sound))
            categoryIdentifier=\(categoryIdentifier)
            playSound=\(playSound)
            userInfo=\(mergedUserInfo)
            resolution:
            \(debugResolutionTrace(for: normalized, in: bundle))
            """
        )

        return content
    }

    @discardableResult
    static func scheduleCompletion(
        after duration: TimeInterval,
        soundName: String,
        title: String,
        body: String,
        userInfo: [AnyHashable: Any] = [:],
        bundle: Bundle = .main,
        completion: ((Error?) -> Void)? = nil
    ) -> String {
        debugLog(
            """
            🔔 [REST TIMER SUPPORT] scheduleCompletion
            duration=\(duration)
            title=\(title)
            body=\(body)
            soundName=\(soundName)
            effectiveSoundStrategy=\("custom_or_fallback")
            userInfo=\(userInfo)
            resolution:
            \(debugResolutionTrace(for: soundName, in: bundle))
            """
        )
        cancelCompletion(removeDelivered: true)

        let content = makeContent(
            title: title,
            body: body,
            soundName: soundName,
            categoryIdentifier: categoryIdentifier,
            userInfo: userInfo,
            playSound: true,
            bundle: bundle
        )
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, duration),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                debugLog("❌ [REST TIMER SUPPORT] add request failed: \(error.localizedDescription)")
            } else {
                debugLog("✅ [REST TIMER SUPPORT] add request succeeded for \(notificationIdentifier)")
            }
            completion?(error)
        }

        return notificationIdentifier
    }


    static func cancelCompletion(removeDelivered: Bool = true) {
        debugLog(
            "🗑️ [REST TIMER SUPPORT] cancelCompletion removeDelivered=\(removeDelivered) identifier=\(notificationIdentifier)"
        )
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])

        if removeDelivered {
            center.removeDeliveredNotifications(withIdentifiers: [notificationIdentifier])
        }
    }
}
