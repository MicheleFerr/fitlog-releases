# 🔊 Fix Audio File Protection per Notifiche iOS

## Il Problema
I file audio `.caf` non suonano quando il device è locked perché:
1. Non sono inclusi correttamente nel bundle Xcode
2. Hanno il livello di protezione sbagliato (NSFileProtectionComplete)

## Soluzione Step-by-Step

### 1. Aggiungi i file audio a Xcode
```bash
1. Apri ios/Runner.xcworkspace in Xcode
2. Click destro su "Runner" nella sidebar
3. Seleziona "Add Files to Runner..."
4. Naviga a ios/Runner/ e seleziona:
   - timer_complete.caf
   - YehBuddie.caf
   - LightWeight.caf
5. Assicurati che:
   - ✅ "Copy items if needed" sia selezionato
   - ✅ "Add to targets: Runner" sia selezionato
6. Click "Add"
```

### 2. Configura la Protection Level
In Xcode:
```
1. Seleziona ogni file .caf nel progetto
2. Nel File Inspector (pannello destro)
3. Cerca "File Protection" o "Data Protection"
4. Cambia da "Complete" a "None"
```

### 3. Alternativa via Codice
Se non trovi l'opzione in Xcode, aggiungi questo in `AppDelegate.swift`:

```swift
private func configureAudioFileProtection() {
    let audioFiles = ["timer_complete.caf", "YehBuddie.caf", "LightWeight.caf"]
    
    for fileName in audioFiles {
        if let filePath = Bundle.main.path(forResource: fileName.replacingOccurrences(of: ".caf", with: ""), 
                                          ofType: "caf") {
            do {
                let fileURL = URL(fileURLWithPath: filePath)
                try (fileURL as NSURL).setResourceValue(
                    URLFileProtection.none,
                    forKey: .fileProtectionKey
                )
                Logger.shared.log(.info, "✅ Set protection none for \(fileName)")
            } catch {
                Logger.shared.log(.error, "❌ Failed to set protection for \(fileName): \(error)")
            }
        }
    }
}
```

Chiama questa funzione in `didFinishLaunchingWithOptions`.

## Test
1. Builda l'app su device reale
2. Avvia timer 30 secondi
3. Blocca il device (tasto power)
4. Aspetta che il timer finisca
5. **Deve suonare il custom sound anche con device locked!**

## Note Importanti
- **NSFileProtectionNone** è OK per file audio non sensibili
- NON usare per dati utente o informazioni private
- I file audio di sistema iOS usano sempre Protection None

## Verifica Funzionamento
```swift
// In BackgroundAudioManager.swift, aggiungi log:
if let path = Bundle.main.path(forResource: soundName, ofType: "caf") {
    let attributes = try? FileManager.default.attributesOfItem(atPath: path)
    let protection = attributes?[.protectionKey] as? FileProtectionType
    Logger.shared.log(.info, "File protection for \(soundName): \(protection?.rawValue ?? "unknown")")
}
```