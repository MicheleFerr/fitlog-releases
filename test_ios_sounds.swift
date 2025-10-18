#!/usr/bin/swift
// Test script per verificare i suoni custom iOS in GymBro

import Foundation
import AVFoundation
import UserNotifications

print("🎵 iOS Custom Sound Test Script")
print("================================\n")

// Test 1: Verifica file audio
print("1️⃣ Verifica file audio nel bundle:")
let sounds = ["timer_complete", "LightWeight", "YehBuddie"]
for sound in sounds {
    if let path = Bundle.main.path(forResource: sound, ofType: "caf") {
        print("✅ \(sound).caf trovato: \(path)")
        
        // Verifica che sia leggibile
        let url = URL(fileURLWithPath: path)
        if FileManager.default.isReadableFile(atPath: path) {
            if let attributes = try? FileManager.default.attributesOfItem(atPath: path),
               let fileSize = attributes[.size] as? Int64 {
                print("   Dimensione: \(fileSize) bytes")
            }
        }
    } else {
        print("❌ \(sound).caf NON TROVATO!")
    }
}

// Test 2: Test AVAudioPlayer
print("\n2️⃣ Test AVAudioPlayer:")
for sound in sounds {
    if let url = Bundle.main.url(forResource: sound, withExtension: "caf") {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            print("✅ AVAudioPlayer può riprodurre: \(sound).caf")
        } catch {
            print("❌ AVAudioPlayer fallito per \(sound).caf: \(error)")
        }
    }
}

// Test 3: Test SystemSoundID
print("\n3️⃣ Test SystemSoundID:")
for sound in sounds {
    if let url = Bundle.main.url(forResource: sound, withExtension: "caf") {
        var soundID: SystemSoundID = 0
        let status = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        
        if status == kAudioServicesNoError {
            print("✅ SystemSoundID creato per \(sound).caf: ID=\(soundID)")
            AudioServicesDisposeSystemSoundID(soundID)
        } else {
            print("❌ SystemSoundID fallito per \(sound).caf: status=\(status)")
        }
    }
}

// Test 4: Test UNNotificationSound
print("\n4️⃣ Test UNNotificationSound:")
for sound in sounds {
    let soundName = UNNotificationSoundName(rawValue: "\(sound).caf")
    let notificationSound = UNNotificationSound(named: soundName)
    print("✅ UNNotificationSound creato per: \(sound).caf")
}

print("\n✅ Test completato!")
print("\n⚠️ Per testare completamente:")
print("1. Apri l'app GymBro")
print("2. Vai in Settings → Timer Sound")
print("3. Seleziona un suono custom (LightWeight o YehBuddie)")
print("4. Avvia un timer di 5 secondi")
print("5. Verifica che il suono custom venga riprodotto")