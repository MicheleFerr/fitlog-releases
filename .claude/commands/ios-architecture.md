# iOS Native Architecture - FitLog Pro

## Struttura

```
ios/
├── Runner/
│   ├── Managers/              # 25 file Swift
│   │   ├── UnifiedTimerCoordinator.swift   # Coordinamento timer
│   │   ├── BackgroundAudioManager.swift    # Audio background + mutex
│   │   ├── DirectNotificationManager.swift # Notifiche locali
│   │   ├── AudioSessionManager.swift       # Sessione audio iOS
│   │   ├── BackgroundTaskManager.swift     # Background tasks
│   │   ├── WatchConnectivityManager.swift  # watchOS communication
│   │   ├── WorkoutSessionManager.swift     # Gestione sessione workout
│   │   ├── WorkoutSessionAttributes.swift  # ActivityKit attributes
│   │   ├── TimerSoundFix.swift             # Backup audio path
│   │   ├── ErrorRecoveryManager.swift      # Recovery errori
│   │   └── ... (15 altri)
│   ├── LiveActivityHandler.swift  # Entry point Live Activities + Platform Channel
│   ├── AppDelegate.swift          # App lifecycle
│   └── SceneDelegate.swift        # Scene lifecycle
├── FitLogWatch Watch App/     # watchOS companion (folder references, no pbxproj per file)
├── GymBroTimerWidget/         # Widget Extension (Live Activities UI)
└── Runner.xcodeproj/
```

## Audio Architecture (CRITICA)

Timer completion ha 4 path audio paralleli:
1. **Dispatch timer** - AVAudioPlayer diretto
2. **TimerSoundFix** - Backup path se il primo fallisce
3. **UNNotification** - Notifica locale con suono
4. **willPresent handler** - DirectNotificationManager intercetta notifica in foreground

### Pattern Mutex (lezione appresa)

```swift
// BackgroundAudioManager.wasAudioPlayedRecently(withinSeconds:)
// API thread-safe per dedup cross-manager
```

**REGOLA**: "Double sound is better than no sound" era SBAGLIATO. Causa doppio suono che infastidisce l'utente. Usare mutex con fallback esplicito:
- `willPresent` handler NON deve passare `.sound` se chiama `playNotificationAudio()`
- `handlePlayCompletionSound()` deve verificare `wasAudioPlayedRecently()` prima di `TimerSoundFix`
- `cancelAllTimerNotifications()` dopo ogni play riuscito in `playCompletionSound()`

## NON TOCCARE (auto-generati)

- `lib/shared/presentation/l10n/generated/`
- `.dart_tool/`, `build/`, `firebase_options.dart`

## Modificare con cautela

- `ios/Runner/Managers/` - Richiede conoscenza audio/timer architecture
- `ios/FitLogWatch Watch App/` - watchOS, folder references
- `ios/GymBroTimerWidget/` - Live Activities widget extension
