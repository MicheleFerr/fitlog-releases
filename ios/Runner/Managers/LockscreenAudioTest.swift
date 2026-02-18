import Foundation
import UserNotifications
import AVFoundation

#if DEBUG

/// Test utility to verify lockscreen audio functionality
final class LockscreenAudioTest {
    
    static let shared = LockscreenAudioTest()
    
    private init() {}
    
    /// Run comprehensive lockscreen audio test
    func runTest() {
        print("🧪 LOCKSCREEN AUDIO TEST STARTING...")
        print(String(repeating: "=", count: 50))
        
        // 1. Test audio session configuration
        testAudioSessionConfiguration()
        
        // 2. Test sound file availability
        testSoundFileAvailability()
        
        // 3. Test notification permissions
        testNotificationPermissions()
        
        // 4. Schedule test notification
        scheduleTestNotification()
        
        print(String(repeating: "=", count: 50))
        print("🧪 LOCKSCREEN AUDIO TEST COMPLETE")
        print("")
        print("📱 TO TEST:")
        print("1. Lock your device (press power button)")
        print("2. Wait 5 seconds")
        print("3. You should hear the timer sound")
        print("4. The notification should appear on lockscreen")
    }
    
    private func testAudioSessionConfiguration() {
        print("\n📊 Testing Audio Session Configuration...")
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            // ✅ MINIMAL configuration to avoid OSStatus -50
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            
            print("✅ Audio session configured for lockscreen")
            print("   Category: \(session.category.rawValue)")
            print("   Mode: \(session.mode.rawValue)")
            print("   Options: \(session.categoryOptions.rawValue)")
            print("   Is Active: true")
            
        } catch {
            print("❌ Failed to configure audio session: \(error)")
        }
    }
    
    private func testSoundFileAvailability() {
        print("\n🔊 Testing Sound Files...")
        
        let soundFiles = ["sound", "timer_complete", "LightWeight", "YehBuddie"]
        
        for soundName in soundFiles {
            if let path = Bundle.main.path(forResource: soundName, ofType: "caf") {
                let url = URL(fileURLWithPath: path)
                
                if FileManager.default.isReadableFile(atPath: path) {
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: path),
                       let fileSize = attributes[.size] as? Int64 {
                        print("✅ \(soundName).caf: \(fileSize) bytes")
                        
                        // Test creating notification sound
                        let _ = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
                        print("   ✓ Can create UNNotificationSound")
                    } else {
                        print("⚠️ \(soundName).caf: Cannot read attributes")
                    }
                } else {
                    print("❌ \(soundName).caf: Not readable")
                }
            } else {
                print("❌ \(soundName).caf: Not found in bundle")
            }
        }
    }
    
    private func testNotificationPermissions() {
        print("\n🔔 Testing Notification Permissions...")
        
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("   Authorization Status: \(self.authStatusString(settings.authorizationStatus))")
                print("   Sound Setting: \(self.settingString(settings.soundSetting))")
                print("   Alert Setting: \(self.settingString(settings.alertSetting))")
                print("   Lock Screen Setting: \(self.settingString(settings.lockScreenSetting))")
                
                if settings.authorizationStatus != .authorized {
                    print("⚠️ Notifications not authorized! Requesting permission...")
                    self.requestNotificationPermission()
                } else {
                    print("✅ Notifications authorized")
                }
            }
        }
    }
    
    private func scheduleTestNotification() {
        print("\n🚀 Scheduling Test Notification...")
        print("   Will fire in 5 seconds")
        print("   Lock your device now to test!")
        
        let content = UNMutableNotificationContent()
        content.title = "🧪 Lockscreen Audio Test"
        content.body = "If you hear this sound, lockscreen audio is working!"
        content.categoryIdentifier = "TEST"
        
        // CRITICAL: Use sound name WITHOUT extension for lockscreen
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "sound"))
        
        // iOS 15+ enhancements
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 1.0
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "lockscreen-test-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule test notification: \(error)")
            } else {
                print("✅ Test notification scheduled!")
                print("   Sound: sound.caf")
                print("   Fires in: 5 seconds")
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else {
                print("❌ Notification permission denied")
            }
            if let error = error {
                print("   Error: \(error)")
            }
        }
    }
    
    private func authStatusString(_ status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
    
    private func settingString(_ setting: UNNotificationSetting) -> String {
        switch setting {
        case .notSupported: return "Not Supported"
        case .disabled: return "Disabled"
        case .enabled: return "Enabled"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - Flutter Integration

extension LockscreenAudioTest {
    /// Call this from Flutter to run the test
    static func runTestFromFlutter() {
        DispatchQueue.main.async {
            LockscreenAudioTest.shared.runTest()
        }
    }
}

#endif // DEBUG
