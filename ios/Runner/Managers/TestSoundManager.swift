import Foundation
import UserNotifications
import AVFoundation

/// Test manager to verify custom sound functionality
final class TestSoundManager {
    
    static let shared = TestSoundManager()
    
    private init() {}
    
    /// Test all timer sounds by scheduling notifications
    func testAllTimerSounds() {
        print("🧪 Starting Timer Sound Test")
        print("=" * 50)
        
        // List of sounds to test
        let sounds = [
            "timer_complete",
            "LightWeight", 
            "YehBuddie"
        ]
        
        // First, verify all sound files exist
        print("\n📁 Verifying sound files in bundle:")
        for sound in sounds {
            verifySound(sound)
        }
        
        // Schedule test notifications with each sound
        print("\n🔔 Scheduling test notifications:")
        for (index, sound) in sounds.enumerated() {
            scheduleTestNotification(
                soundName: sound,
                delay: TimeInterval(5 + index * 3), // 5s, 8s, 11s
                title: "Test: \(sound)"
            )
        }
        
        print("\n✅ Test notifications scheduled!")
        print("You should hear:")
        print("  - timer_complete at 5 seconds")
        print("  - LightWeight at 8 seconds")
        print("  - YehBuddie at 11 seconds")
        print("=" * 50)
    }
    
    /// Verify a sound file exists in the bundle
    private func verifySound(_ soundName: String) {
        // Check .caf format (required for iOS notifications)
        if let cafPath = Bundle.main.path(forResource: soundName, ofType: "caf") {
            print("✅ Found \(soundName).caf at: \(cafPath)")
            
            // Check file size
            if let attributes = try? FileManager.default.attributesOfItem(atPath: cafPath),
               let fileSize = attributes[.size] as? Int64 {
                let sizeKB = Double(fileSize) / 1024.0
                print("   Size: \(String(format: "%.2f", sizeKB)) KB")
                
                if fileSize > 5_000_000 {
                    print("   ⚠️ WARNING: File may be too large for notifications (>5MB)")
                }
            }
            
            // Try to load as audio to verify format
            let url = URL(fileURLWithPath: cafPath)
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                print("   Duration: \(String(format: "%.2f", player.duration))s")
                if player.duration > 30 {
                    print("   ⚠️ WARNING: iOS limits notification sounds to 30 seconds")
                }
            } catch {
                print("   ❌ ERROR: Could not load as audio: \(error)")
            }
        } else {
            print("❌ NOT FOUND: \(soundName).caf")
            
            // Check for other formats
            for ext in ["wav", "mp3", "m4a", "aiff"] {
                if Bundle.main.path(forResource: soundName, ofType: ext) != nil {
                    print("   ℹ️ Found \(soundName).\(ext) but notifications require .caf format")
                }
            }
        }
    }
    
    /// Schedule a test notification with a specific sound
    private func scheduleTestNotification(soundName: String, delay: TimeInterval, title: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Testing custom sound: \(soundName)"
        content.categoryIdentifier = "SOUND_TEST"
        
        // Set the custom sound
        let soundFile = "\(soundName).caf"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFile))
        
        // iOS 15+ features
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 1.0
        }
        
        // Create trigger
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: delay,
            repeats: false
        )
        
        // Create request
        let identifier = "test-\(soundName)-\(UUID().uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Add the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule \(soundName): \(error)")
            } else {
                print("✅ Scheduled \(soundName) notification in \(Int(delay))s")
            }
        }
    }
    
    /// Clear all test notifications
    func clearTestNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let testIdentifiers = requests
                .filter { $0.identifier.hasPrefix("test-") }
                .map { $0.identifier }
            
            if !testIdentifiers.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(
                    withIdentifiers: testIdentifiers
                )
                print("🗑️ Cleared \(testIdentifiers.count) test notifications")
            }
        }
    }
    
    /// Request notification permissions if needed
    func ensurePermissions(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("✅ Notification permissions already granted")
                completion(true)
                
            case .notDetermined:
                print("📱 Requesting notification permissions...")
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .sound, .badge]
                ) { granted, error in
                    if let error = error {
                        print("❌ Permission error: \(error)")
                    }
                    print(granted ? "✅ Permissions granted" : "❌ Permissions denied")
                    completion(granted)
                }
                
            case .denied:
                print("❌ Notification permissions denied - please enable in Settings")
                completion(false)
                
            default:
                print("⚠️ Unknown permission status")
                completion(false)
            }
        }
    }
    
    /// Run complete sound test with permission check
    func runCompleteTest() {
        print("\n🚀 GymBro Timer Sound Test")
        print("=" * 50)
        
        // First ensure we have permissions
        ensurePermissions { [weak self] granted in
            guard granted else {
                print("❌ Cannot test without notification permissions")
                return
            }
            
            // Clear any old test notifications
            self?.clearTestNotifications()
            
            // Run the sound test
            self?.testAllTimerSounds()
        }
    }
}

// MARK: - Flutter Integration

extension TestSoundManager {
    func setupFlutterChannel(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: ChannelNames.soundTest,
            binaryMessenger: messenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "testSounds":
                self?.runCompleteTest()
                result(true)
                
            case "clearTests":
                self?.clearTestNotifications()
                result(true)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}