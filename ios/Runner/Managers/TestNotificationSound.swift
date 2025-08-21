import Foundation
import UserNotifications

/// Test per verificare se i file audio sono accessibili per le notifiche
final class TestNotificationSound {
    
    static func testSoundFiles() {
        Logger.shared.log(.info, "🧪 === TESTING NOTIFICATION SOUND FILES ===", category: .audioSession)
        
        let soundsToTest = ["YehBuddie", "LightWeight", "timer_complete"]
        
        for soundName in soundsToTest {
            // Test .caf files
            if let cafPath = Bundle.main.path(forResource: soundName, ofType: "caf") {
                Logger.shared.log(.info, "✅ Found \(soundName).caf at: \(cafPath)", category: .audioSession)
                
                // Check if file exists
                if FileManager.default.fileExists(atPath: cafPath) {
                    Logger.shared.log(.info, "✅ File exists and readable: \(soundName).caf", category: .audioSession)
                    
                    // Get file size
                    if let attrs = try? FileManager.default.attributesOfItem(atPath: cafPath),
                       let fileSize = attrs[FileAttributeKey.size] as? Int {
                        Logger.shared.log(.info, "📊 File size: \(fileSize) bytes", category: .audioSession)
                    }
                } else {
                    Logger.shared.log(.error, "❌ File NOT accessible: \(soundName).caf", category: .audioSession)
                }
                
                // Test immediate notification with this sound
                scheduleTestNotification(soundName: "\(soundName).caf", delay: 2.0)
                
            } else {
                Logger.shared.log(.warning, "⚠️ NOT FOUND: \(soundName).caf", category: .audioSession)
            }
            
            // Test .wav files
            if let wavPath = Bundle.main.path(forResource: soundName, ofType: "wav") {
                Logger.shared.log(.info, "✅ Found \(soundName).wav at: \(wavPath)", category: .audioSession)
            }
        }
        
        Logger.shared.log(.info, "🧪 === TEST COMPLETE ===", category: .audioSession)
    }
    
    private static func scheduleTestNotification(soundName: String, delay: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "🧪 Sound Test: \(soundName)"
        content.body = "Testing if this sound plays"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(soundName))
        content.categoryIdentifier = "TIMER_COMPLETE"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-\(soundName)-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.shared.log(.error, "❌ Failed to schedule test notification: \(error)", category: .audioSession)
            } else {
                Logger.shared.log(.info, "✅ Test notification scheduled with sound: \(soundName)", category: .audioSession)
            }
        }
    }
}