import UserNotifications
import UIKit

// Test script per verificare il suono custom delle notifiche
// Esegui in Swift Playgrounds o aggiungi temporaneamente al progetto

func testNotificationSound() {
    let center = UNUserNotificationCenter.current()
    
    // Richiedi permessi
    center.requestAuthorization(options: [.alert, .sound]) { granted, error in
        if granted {
            print("✅ Permessi concessi")
            
            // Crea notifica con suono custom
            let content = UNMutableNotificationContent()
            content.title = "Test Timer Complete"
            content.body = "Questo dovrebbe riprodurre timer_complete.caf"
            
            // USA IL SUONO CUSTOM
            content.sound = UNNotificationSound(named: UNNotificationSoundName("timer_complete.caf"))
            
            // Schedula tra 5 secondi
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "test-sound", content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("❌ Errore: \(error)")
                } else {
                    print("✅ Notifica schedulata - arriverà tra 5 secondi")
                    print("🔊 Suono: timer_complete.caf")
                }
            }
        }
    }
}

// Per testare:
// 1. Chiama questa funzione
// 2. Metti l'app in background entro 5 secondi
// 3. Dovresti sentire il suono custom timer_complete.caf
testNotificationSound()