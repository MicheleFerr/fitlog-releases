# iOS Background Audio & Timer Sound - Research Document

**Progetto**: FitLog Pro
**Data Creazione**: 26 Novembre 2025
**Ultima Modifica**: 26 Novembre 2025
**Autore**: Claude Code Research
**Versione**: 1.0

> **Nota**: Questa ricerca è stata condotta il 26 Novembre 2025 per risolvere l'errore OSStatus -50 che si verifica durante la configurazione dell'audio session in FitLog Pro.

---

## Executive Summary

Questo documento analizza le strategie utilizzate dalle app iOS per implementare timer con audio in background, con focus specifico su:
- Silent audio loop per mantenere l'app attiva
- Suoni del timer che si sovrappongono alla musica (ducking)
- Risoluzione dell'errore OSStatus -50

**Problema principale**: L'opzione `.duckOthers` combinata con `.mixWithOthers` in un singolo `setCategory()` causa errore -50 su iOS in determinati momenti (cold start, dopo interruzioni).

---

## Indice

1. [Architettura Attuale FitLog Pro](#1-architettura-attuale-fitlog-pro)
2. [Analisi dell'Errore -50](#2-analisi-dellerrore--50)
3. [Strategie Utilizzate da Altre App](#3-strategie-utilizzate-da-altre-app)
4. [Soluzioni Tecniche dalla Community](#4-soluzioni-tecniche-dalla-community)
5. [Alternative al Silent Loop](#5-alternative-al-silent-loop)
6. [Raccomandazioni](#6-raccomandazioni)
7. [Fonti](#7-fonti)

---

## 1. Architettura Attuale FitLog Pro

### 1.1 Come Funziona il Timer in Background

```
┌─────────────────────────────────────────────────────────────────┐
│                    BACKGROUND AUDIO SYSTEM                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  COMPONENTE 1: SILENT AUDIO LOOP                                │
│  ─────────────────────────────────                              │
│  File: silence.mp3/caf (loop infinito)                          │
│  Scopo: Mantenere AVAudioSession ATTIVA in background           │
│  Opzione: .mixWithOthers (non interrompe Spotify)               │
│                                                                  │
│  COMPONENTE 2: TIMER COMPLETION SOUND                           │
│  ─────────────────────────────────────                          │
│  File: timer_complete.caf, YehBuddie.caf, etc.                  │
│  Scopo: Notificare l'utente che il rest timer è finito          │
│  Opzione: .duckOthers (abbassa volume Spotify temporaneamente)  │
│                                                                  │
│  CONFLITTO: Combinare entrambe le opzioni → Errore -50          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 File Coinvolti

| File | Ruolo | Stato |
|------|-------|-------|
| `SceneDelegate.swift` (legacy) | Configura audio session | ✅ ATTIVO - Ha bug -50 |
| `AudioSessionManager.swift` | Nuovo manager con fix | ❌ DISABILITATO |
| `AudioSessionManager_Simplified.swift` | Versione semplificata | ❌ NON USATO |
| `BackgroundAudioManager.swift` | Gestisce silent loop | ✅ ATTIVO |
| `TimerSoundFix.swift` | Suoni con AudioServices | ✅ ATTIVO |
| `FeatureFlags.swift` | Toggle per manager | `useNewAudioManager = false` |

### 1.3 Il Codice Problematico

```swift
// SceneDelegate.swift - Legacy code con bug
private func legacyConfigureBackgroundAudio() {
    do {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default, options: [
            .mixWithOthers,      // ← Necessario per silent loop
            .duckOthers,         // ← Necessario per timer sound
            .allowBluetooth,     // ← Può causare conflitti
            .allowBluetoothA2DP
        ])
        try audioSession.setActive(true)
    } catch {
        // Errore -50 avviene qui
    }
}
```

---

## 2. Analisi dell'Errore -50

### 2.1 Cos'è OSStatus -50?

- **Codice**: `-50` (paramErr)
- **Significato**: Parametri incompatibili passati a CoreAudio
- **Documentazione Apple**: "Some of the arguments given to setCategory were incorrect"

### 2.2 Cause Documentate

| Causa | Descrizione | Fonte |
|-------|-------------|-------|
| **longFormAudio conflict** | `.longFormAudio` policy è incompatibile con `.mixWithOthers` e `.duckOthers` | Apple Developer Forums |
| **Bluetooth option conflict** | `.allowBluetooth` può causare conflitti con alcune categorie | Stack Overflow |
| **Thread sbagliato** | Chiamare `setCategory()` da thread non-main | Community |
| **Mancata deattivazione** | Non chiamare `setActive(false)` prima di cambiare categoria | Stack Overflow |
| **Timing** | Chiamare durante interruzione audio (telefonate, Siri) | Esperienza |

### 2.3 Quando Avviene in FitLog Pro

```
Scenario 1: Cold Start
─────────────────────
App Launch → configureForLaunch() → setCategory() → ERROR -50
Causa: CoreAudio non pronto, stato inconsistente

Scenario 2: Post-Interruzione
─────────────────────────────
Telefonata → App torna in foreground → reactivate() → ERROR -50
Causa: Audio session in stato "interrupted", richiede deactivate prima

Scenario 3: Background → Foreground
───────────────────────────────────
Background (silent loop) → Foreground → transitionToForeground() → ERROR -50
Causa: Conflitto tra configurazione background e foreground
```

---

## 3. Strategie Utilizzate da Altre App

### 3.1 Tabella Comparativa

| App | Strategia | Silent Loop | Ducking | Background |
|-----|-----------|-------------|---------|------------|
| **Seconds Interval Timer** | Audio over music | ✅ Sì | ✅ Sì | ✅ Funziona |
| **Intervals Pro** | Audio + Haptic | ✅ Sì | ✅ Sì | ✅ Funziona |
| **Timer Plus** | Voice guidance | ✅ Sì | ? | ✅ Funziona |
| **Apple Timer** | AlarmKit (iOS 16+) | ❌ No | N/A | ✅ Nativo |
| **Pomodoro apps** | Local Notification | ❌ No | N/A | ⚠️ Limitato |

### 3.2 Seconds Interval Timer

**Citazione dalla documentazione:**
> "Seconds will play its alerts over the top [of your music]. You can simply listen to your favourite music player in the background and Seconds will play its alerts over the top."

**Implementazione probabile:**
- Usa `.playback` category con `.mixWithOthers`
- Alerts suonano con ducking temporaneo
- Silent loop per mantenere background execution

### 3.3 Intervals Pro

**Citazione:**
> "Runs in the background so you can leave your phone in your pocket. Spoken, audio, and haptic alerts."

**Implementazione probabile:**
- Combina audio alerts con haptic feedback
- Voice alerts per workout guidance
- Background audio mode abilitato

### 3.4 Interval Timer (Float Tech)

**Nota interessante:**
> "Fixed issue where background music volume would lower when workout started"

Questo indica che hanno avuto lo **stesso problema di ducking** e lo hanno risolto. Probabilmente:
- Configurano ducking SOLO quando serve suonare
- Non usano ducking per il silent loop

---

## 4. Soluzioni Tecniche dalla Community

### 4.1 Pattern Two-Stage (Raccomandato)

**Fonte**: Apple Developer Forums, Stack Overflow

```swift
// STEP 1: Deattiva sempre prima
try? session.setActive(false, options: .notifyOthersOnDeactivation)

// STEP 2: Configura SENZA duckOthers
try session.setCategory(.playback, mode: .default, options: [
    .mixWithOthers,
    .allowBluetooth,
    .allowBluetoothA2DP
])

// STEP 3: Attiva
try session.setActive(true, options: [])

// STEP 4: DOPO attivazione, aggiungi duckOthers
try session.setCategory(.playback, mode: .default, options: [
    .mixWithOthers,
    .duckOthers,  // Aggiunto DOPO attivazione
    .allowBluetooth,
    .allowBluetoothA2DP
])
```

**Perché funziona**: CoreAudio gestisce meglio l'aggiunta di `.duckOthers` quando la sessione è già attiva.

### 4.2 Pattern Ambient → Playback Switch

**Fonte**: Stack Overflow

```swift
// Durante silent loop (non interrompe nulla)
try session.setCategory(.ambient)

// Quando serve suonare il timer:
try session.setActive(false)
try session.setCategory(.playback, options: [.duckOthers])
try session.setActive(true)

// Play sound...

// Torna ad ambient
try session.setActive(false)
try session.setCategory(.ambient)
try session.setActive(true)
```

**Pro**: Separazione netta tra silent loop e timer sound
**Contro**: Può interrompere il silent loop momentaneamente

### 4.3 AudioServicesPlaySystemSound

**Fonte**: Stack Overflow, Apple Documentation

```swift
// Preload del suono
var soundID: SystemSoundID = 0
let url = Bundle.main.url(forResource: "timer_complete", withExtension: "caf")!
AudioServicesCreateSystemSoundID(url as CFURL, &soundID)

// Play (funziona anche in background!)
AudioServicesPlaySystemSound(soundID)

// Con vibrazione
AudioServicesPlayAlertSound(soundID)
```

**Pro**:
- Funziona in background con UIBackgroundModes audio
- Non richiede riconfigurazione della sessione
- Basso consumo CPU

**Contro**:
- Non puoi controllare il volume
- Limitato a suoni brevi

### 4.4 Evitare .allowBluetooth

**Fonte**: Apple Developer Forums

```swift
// PROBLEMA: .allowBluetooth può causare conflitti
try session.setCategory(.playback, options: [
    .mixWithOthers,
    .allowBluetooth,  // ← Rimuovere se non necessario
])

// SOLUZIONE: Usa solo .allowBluetoothA2DP per cuffie
try session.setCategory(.playback, options: [
    .mixWithOthers,
    .allowBluetoothA2DP  // ← Solo high-quality Bluetooth
])
```

---

## 5. Alternative al Silent Loop

### 5.1 Local Notifications

**Documentazione Apple**: UNNotificationSound

```swift
let content = UNMutableNotificationContent()
content.title = "Timer Complete!"
content.sound = UNNotificationSound(named: UNNotificationSoundName("timer_complete.caf"))

let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
let request = UNNotificationRequest(identifier: "timer", content: content, trigger: trigger)
```

**Limitazioni:**
- Suono massimo: 30 secondi
- Non preciso al secondo esatto
- Se l'utente dismisses il banner, il suono si interrompe

**Quando usarlo**: Come fallback se l'app viene sospesa

### 5.2 AlarmKit (iOS 18+)

**Documentazione**: nilcoalescing.com

```swift
import AlarmKit

// Schedula un timer con alarm
let alarm = AlarmScheduler()
try await alarm.schedule(
    for: Date().addingTimeInterval(60),
    alert: .init(title: "Rest Complete!", sound: .default)
)
```

**Pro:**
- Funziona anche con Focus attivo
- Nativo Apple, altamente affidabile
- Supporta Live Activities automaticamente

**Contro:**
- Solo iOS 18+
- Richiede permesso esplicito dell'utente

### 5.3 Push Notifications (Server-Side)

Per massima affidabilità, alcune app usano push notifications:

```
App → Server: "Timer 60 seconds"
Server waits 60 seconds
Server → APNS → iPhone: Push with sound
```

**Pro**: Funziona sempre, anche con app killed
**Contro**: Richiede backend server, latenza network

---

## 6. Raccomandazioni

### 6.1 Soluzione Raccomandata per FitLog Pro

#### Opzione A: Fix Minimo (Basso Rischio)

Modificare il legacy code in `SceneDelegate.swift` per rimuovere `.duckOthers` dalla configurazione iniziale:

```swift
private func legacyConfigureBackgroundAudio() {
    do {
        let audioSession = AVAudioSession.sharedInstance()

        // STEP 1: Deattiva prima
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)

        // STEP 2: Configura SENZA duckOthers per silent loop
        try audioSession.setCategory(.playback, mode: .default, options: [
            .mixWithOthers,      // Per silent loop
            .allowBluetoothA2DP  // Solo A2DP, non allowBluetooth
        ])

        try audioSession.setActive(true)
    } catch {
        Logger.shared.log(.error, "Audio configuration failed: \(error)")
    }
}
```

**Rischio**: Basso - non tocca il silent loop
**Impatto**: Il ducking non funzionerà per default, ma il timer suonerà

#### Opzione B: AudioServicesPlaySystemSound per Timer

Usare `AudioServicesPlaySystemSound` per i suoni del timer invece di AVAudioPlayer:

```swift
// In TimerSoundFix.swift - già parzialmente implementato
func playTimerSound(_ soundName: String) {
    guard let soundID = preloadedSounds[soundName] else { return }
    AudioServicesPlayAlertSound(soundID)  // Include vibrazione
}
```

**Pro**: Non richiede riconfigurazione della sessione
**Contro**: Nessun controllo volume

#### Opzione C: Two-Stage Approach (Medio Rischio)

Implementare il pattern two-stage nel legacy code:

```swift
private func legacyConfigureBackgroundAudio() {
    DispatchQueue.global(qos: .userInteractive).async {
        // Step 1: Deactivate
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        Thread.sleep(forTimeInterval: 0.01)

        DispatchQueue.main.async {
            do {
                let session = AVAudioSession.sharedInstance()

                // Step 2: Activate WITHOUT duckOthers
                try session.setCategory(.playback, mode: .default, options: [
                    .mixWithOthers,
                    .allowBluetoothA2DP
                ])
                try session.setActive(true)

                // Step 3: NOW add duckOthers
                try session.setCategory(.playback, mode: .default, options: [
                    .mixWithOthers,
                    .duckOthers,
                    .allowBluetoothA2DP
                ])
            } catch {
                // Fallback senza duckOthers
            }
        }
    }
}
```

### 6.2 Matrice Decisionale

| Criterio | Opzione A | Opzione B | Opzione C |
|----------|-----------|-----------|-----------|
| Rischio rottura | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Ducking funziona | ❌ | ❌ | ✅ |
| Timer suona | ✅ | ✅ | ✅ |
| Effort implementazione | 15 min | 30 min | 1 ora |
| Silent loop stabile | ✅ | ✅ | ⚠️ |

### 6.3 Raccomandazione Finale

**Implementare Opzione A + B insieme:**

1. **Opzione A**: Rimuovi `.duckOthers` dalla configurazione iniziale per eliminare errore -50
2. **Opzione B**: Usa `AudioServicesPlaySystemSound` per i suoni del timer

Questo approccio:
- ✅ Elimina l'errore -50
- ✅ Mantiene il silent loop stabile
- ✅ Timer suona sempre (anche in background)
- ❌ Perde il ducking (Spotify non abbassa volume durante beep)

Se il ducking è **essenziale**, implementare Opzione C con attenzione.

---

## 7. Fonti

### Documentazione Apple
- [AVAudioSession.Category](https://developer.apple.com/documentation/avfaudio/avaudiosession/category)
- [UNNotificationSound](https://developer.apple.com/documentation/usernotifications/unnotificationsound)
- [AlarmKit](https://developer.apple.com/documentation/alarmkit)

### Community & Forum
- [Apple Developer Forums: mixWithOthers/duckOthers](https://developer.apple.com/forums/thread/738278)
- [Stack Overflow: AVAudioSession doesn't respect mixWithOthers](https://stackoverflow.com/questions/50425401/avaudiosession-doesnt-respect-mixwithothers)
- [Stack Overflow: Background timer audio](https://stackoverflow.com/questions/40875485/play-a-sound-on-my-backgrounded-app-when-the-phone-is-in-silent-mode)
- [Stack Overflow: AudioServicesPlaySystemSound background](https://stackoverflow.com/questions/22817490/ios-play-short-sounds-in-the-background-every-2-minutes)

### Blog & Tutorial
- [Mux: Background audio handling with iOS AVPlayer](https://www.mux.com/blog/background-audio-handling-with-ios-avplayer)
- [Igor Kulman: Correctly playing audio in iOS apps](https://blog.kulman.sk/correctly-playing-audio-in-ios-apps/)
- [nilcoalescing: Countdown Timer with AlarmKit](https://nilcoalescing.com/blog/CountdownTimerWithAlarmKit/)
- [Pietro Messineo: Refresh Live Activities in background](https://medium.com/@pietromessineo/refresh-live-activities-in-background-every-second-is-possible-a9fecf34783a)

### App Reference
- [Seconds Interval Timer](https://www.intervaltimer.com/)
- [Intervals Pro](https://intervalspro.com/)
- [Timer Plus](https://apps.apple.com/us/app/timer-plus-workouts-timer/id1279716547)

---

## Appendice A: Codice di Test

### Test Audio Session Configuration

```swift
func testAudioSessionConfiguration() {
    let session = AVAudioSession.sharedInstance()

    print("=== Audio Session Test ===")
    print("Category: \(session.category.rawValue)")
    print("Options: \(session.categoryOptions.rawValue)")
    print("Mode: \(session.mode.rawValue)")
    print("Other audio playing: \(session.isOtherAudioPlaying)")
    print("Output volume: \(session.outputVolume)")

    // Test option compatibility
    let testOptions: [(String, AVAudioSession.CategoryOptions)] = [
        ("mixWithOthers only", [.mixWithOthers]),
        ("duckOthers only", [.duckOthers]),
        ("mix + duck", [.mixWithOthers, .duckOthers]),
        ("mix + duck + bluetooth", [.mixWithOthers, .duckOthers, .allowBluetooth]),
        ("mix + duck + A2DP", [.mixWithOthers, .duckOthers, .allowBluetoothA2DP]),
    ]

    for (name, options) in testOptions {
        do {
            try session.setActive(false)
            try session.setCategory(.playback, options: options)
            try session.setActive(true)
            print("✅ \(name): SUCCESS")
        } catch {
            print("❌ \(name): FAILED - \(error)")
        }
    }
}
```

---

## Appendice B: Glossario

| Termine | Definizione |
|---------|-------------|
| **Silent Loop** | File audio silenzioso in loop per mantenere l'app attiva in background |
| **Ducking** | Riduzione temporanea del volume di altri audio quando il nostro suona |
| **OSStatus -50** | Errore "paramErr" di CoreAudio per parametri incompatibili |
| **AVAudioSession** | API Apple per gestire la sessione audio dell'app |
| **Background Mode** | Capacità dell'app di eseguire codice quando non in foreground |
| **Live Activity** | Widget dinamico su Lock Screen e Dynamic Island (iOS 16+) |
| **AlarmKit** | Framework Apple per timer/allarmi affidabili (iOS 18+) |

---

**Documento generato automaticamente da Claude Code Research**
**Ultimo aggiornamento**: 2025-11-26
