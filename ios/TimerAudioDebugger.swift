import Foundation
import UserNotifications
import UIKit
import AVFoundation

/// Helper per diagnosticare problemi audio timer in modalità lockscreen
final class TimerAudioDebugger {
    
    static let shared = TimerAudioDebugger()
    
    private init() {}
    
    /// Test completo per verificare perché l'audio non funziona in modalità lockscreen
    func performCompleteAudioDiagnostic() {
        print("")
        print("🔍 =================== TIMER AUDIO DIAGNOSTIC ===================")
        print("🕐 Test Time: \(Date())")
        print("")
        
        // 1. Check notification permissions
        checkNotificationPermissions()
        
        // 2. Check audio files
        checkAudioFiles()
        
        // 3. Check device settings
        checkDeviceSettings()
        
        // 4. Test notification
        scheduleTestNotification()
        
        // 5. Test direct audio playback
        testDirectAudioPlayback()
        
        print("===============================================================")
        print("")
    }
    
    // MARK: - Individual Tests
    
    private func checkNotificationPermissions() {
        print("1️⃣ CHECKING NOTIFICATION PERMISSIONS...")
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("   📋 Authorization Status: \(settings.authorizationStatus.description)")
                print("   🔊 Sound Setting: \(settings.soundSetting.description)")
                print("   🚨 Alert Setting: \(settings.alertSetting.description)")
                print("   🔒 Lock Screen Setting: \(settings.lockScreenSetting.description)")
                
                if #available(iOS 15.0, *) {
                    print("   ⏰ Time Sensitive Setting: \(settings.timeSensitiveSetting.description)")
                }
                
                // Provide recommendations
                if settings.authorizationStatus != .authorized {
                    print("   ❌ ISSUE: Notification permission not granted")
                    print("   💡 SOLUTION: Enable notifications in Settings > Notifications > GymBro")
                }
                
                if settings.soundSetting != .enabled {
                    print("   ❌ ISSUE: Notification sounds disabled")
                    print("   💡 SOLUTION: Enable sounds in Settings > Notifications > GymBro > Sounds")
                }
                
                if settings.lockScreenSetting != .enabled {
                    print("   ❌ ISSUE: Lock screen notifications disabled")
                    print("   💡 SOLUTION: Enable lock screen in Settings > Notifications > GymBro > Lock Screen")
                }
                
                print("")
            }
        }
    }
    
    private func checkAudioFiles() {
        print("2️⃣ CHECKING AUDIO FILES IN BUNDLE...")
        
        let soundNames = ["sound", "timer_complete", "LightWeight", "YehBuddie"]
        let extensions = ["caf", "wav", "mp3", "m4a"]
        
        for soundName in soundNames {
            var foundFile = false
            
            for ext in extensions {
                if let path = Bundle.main.path(forResource: soundName, ofType: ext) {
                    let url = URL(fileURLWithPath: path)
                    
                    do {
                        let attributes = try FileManager.default.attributesOfItem(atPath: path)
                        let fileSize = attributes[.size] as? Int64 ?? 0
                        
                        print("   ✅ Found: \(soundName).\(ext)")
                        print("      📍 Path: \(path)")
                        print("      📊 Size: \(fileSize) bytes")
                        
                        // Check if suitable for notifications (max 30 seconds / ~5MB)
                        if fileSize > 5_000_000 {
                            print("      ⚠️ WARNING: File may be too large for notifications")
                        }
                        
                        if fileSize == 0 {
                            print("      ❌ ERROR: File is empty")
                        }
                        
                        foundFile = true
                        break
                        
                    } catch {
                        print("   ❌ Error reading \(soundName).\(ext): \(error)")
                    }
                }
            }
            
            if !foundFile {
                print("   ❌ NOT FOUND: \(soundName) (checked .caf, .wav, .mp3, .m4a)")
                print("   💡 SOLUTION: Add \(soundName).caf to your app bundle")
            }
        }
        
        print("")
    }
    
    private func checkDeviceSettings() {
        print("3️⃣ CHECKING DEVICE SETTINGS...")
        
        // Check audio session
        let audioSession = AVAudioSession.sharedInstance()
        print("   🔇 Output Volume: \(audioSession.outputVolume)")
        print("   📱 Audio Route: \(audioSession.currentRoute.outputs.map { $0.portType.rawValue }.joined(separator: ", "))")
        print("   🎵 Category: \(audioSession.category.rawValue)")
        
        if audioSession.outputVolume == 0.0 {
            print("   ⚠️ WARNING: Device volume is 0")
            print("   💡 SOLUTION: Increase volume with physical buttons")
        }
        
        // Check app state
        let appState = UIApplication.shared.applicationState
        print("   📱 App State: \(appState.description)")
        
        // Check for common issues
        print("   📋 COMMON LOCKSCREEN AUDIO ISSUES:")
        print("      1. Silent switch is ON (check physical switch)")
        print("      2. Focus/Do Not Disturb is active (check Control Center)")
        print("      3. Notification sounds disabled in Settings > Notifications")
        print("      4. App-specific notification settings disabled")
        print("      5. Time Sensitive notifications not allowed")
        
        print("")
    }
    
    private func scheduleTestNotification() {
        print("4️⃣ SCHEDULING TEST NOTIFICATION...")
        print("   🔔 Test notification will fire in 5 seconds")
        print("   📱 LOCK YOUR DEVICE NOW to test lockscreen audio")
        print("   🎧 Expected: You should hear 'sound.caf' when locked")
        
        let content = UNMutableNotificationContent()
        content.title = "🧪 Timer Audio Test"
        content.body = "If you hear this sound, lockscreen audio is working!"
        content.categoryIdentifier = "TIMER_AUDIO_TEST"
        
        // Use standard timer sound
        content.sound = UNNotificationSound(named: UNNotificationSoundName("sound.caf"))
        
        // Critical settings for lockscreen
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 1.0
            print("   ⏰ Using timeSensitive interruption level")
        }
        
        // Try critical alert for maximum reliability
        if #available(iOS 12.0, *) {
            content.sound = UNNotificationSound.criticalSoundNamed(
                UNNotificationSoundName("sound.caf"),
                withAudioVolume: 1.0
            )
            print("   🚨 Using critical alert with max volume")
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "audio_test_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("   ❌ Failed to schedule test notification: \(error)")
            } else {
                print("   ✅ Test notification scheduled successfully")
                
                // Countdown for user
                for i in (1...5).reversed() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(5 - i)) {
                        if i == 1 {
                            print("   🚨 NOTIFICATION SHOULD FIRE NOW! (Lock device to test)")
                        } else {
                            print("   ⏰ \(i-1) seconds until notification...")
                        }
                    }
                }
            }
        }
        
        print("")
    }
    
    private func testDirectAudioPlayback() {
        print("5️⃣ TESTING DIRECT AUDIO PLAYBACK...")
        print("   🎵 Playing sound directly (should work if app is active)")
        
        // Test TimerSoundFix
        TimerSoundFix.shared.playTimerCompletionSound(preferredSound: "sound")
        
        print("   ✅ Direct playback triggered")
        print("   📝 NOTE: Direct playback only works when app is active")
        print("   📝 For lockscreen audio, notifications must handle the sound")
        print("")
    }
    
    // MARK: - Recommendations
    
    func printRecommendations() {
        print("💡 LOCKSCREEN AUDIO TROUBLESHOOTING GUIDE:")
        print("")
        print("   USER SETTINGS TO CHECK:")
        print("   1. Settings > Notifications > GymBro > Allow Notifications = ON")
        print("   2. Settings > Notifications > GymBro > Sounds = ON")
        print("   3. Settings > Notifications > GymBro > Lock Screen = ON")
        print("   4. Settings > Notifications > GymBro > Time Sensitive = ON")
        print("   5. Control Center > Focus = OFF (or allow GymBro in Focus settings)")
        print("   6. Physical silent switch = OFF")
        print("   7. Volume buttons = Turn up volume")
        print("")
        print("   DEVELOPER FIXES:")
        print("   1. Ensure sound.caf is in app bundle")
        print("   2. Use UNNotificationSound.criticalSoundNamed() for critical alerts")
        print("   3. Set content.interruptionLevel = .timeSensitive")
        print("   4. Request .criticalAlert permission if needed")
        print("   5. Keep audio session active during timer")
        print("")
        print("   TESTING STEPS:")
        print("   1. Start timer with 10+ seconds")
        print("   2. Lock device immediately")
        print("   3. Wait for timer completion")
        print("   4. Check if sound plays on locked screen")
        print("")
    }
}

// MARK: - Extensions for Better Logging

extension UNAuthorizationStatus {
    var description: String {
        switch self {
        case .authorized: return "✅ Authorized"
        case .denied: return "❌ Denied"
        case .notDetermined: return "❓ Not Determined"
        case .provisional: return "⚠️ Provisional"
        case .ephemeral: return "📱 Ephemeral (App Clip)"
        @unknown default: return "❓ Unknown"
        }
    }
}

extension UNNotificationSetting {
    var description: String {
        switch self {
        case .enabled: return "✅ Enabled"
        case .disabled: return "❌ Disabled"
        case .notSupported: return "❌ Not Supported"
        @unknown default: return "❓ Unknown"
        }
    }
}

extension UIApplication.State {
    var description: String {
        switch self {
        case .active: return "✅ Active"
        case .background: return "🔄 Background"
        case .inactive: return "⏸️ Inactive"
        @unknown default: return "❓ Unknown"
        }
    }
}

// MARK: - Flutter Integration

extension TimerAudioDebugger {
    func setupFlutterChannel(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.gymbro.timer_audio_debugger",
            binaryMessenger: messenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "performDiagnostic":
                self?.performCompleteAudioDiagnostic()
                result(true)
                
            case "printRecommendations":
                self?.printRecommendations()
                result(true)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}