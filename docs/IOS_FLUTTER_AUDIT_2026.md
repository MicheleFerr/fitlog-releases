# 🔍 iOS/Flutter Communication Audit 2026

**Data**: 2026-02-18 | **Analizzato da**: Team 5 agenti paralleli
**Scope**: 29 file Swift + 12 file Dart | **Status**: ✅ P0 + P1 Completati

---

## 📋 Indice

1. [Riepilogo Esecutivo](#riepilogo-esecutivo)
2. [P0 - Bug Critici](#p0---bug-critici-fix-immediato)
3. [P1 - Bug Alti](#p1---bug-alti-fix-prossima-release)
4. [P2 - Tech Debt](#p2---tech-debt-alto)
5. [P3 - Best Practices](#p3---best-practices-da-aggiornare)
6. [Punti Positivi](#punti-positivi)
7. [Piano di Azione](#piano-di-azione)
8. [Checklist Progresso](#checklist-progresso)

---

## Riepilogo Esecutivo

Il sistema di comunicazione Flutter/Dart ↔ Swift iOS è **funzionante in produzione** ma presenta pattern che possono causare **crash sporadici**, comportamento imprevedibile delle notifiche e difficoltà di manutenzione. Trovati **4 bug critici P0**, **6 bug alti P1**, e ~830 righe di codice test/debug in produzione.

L'integrazione HealthKit/WatchConnectivity è la parte meglio implementata. Il sistema di notifiche è quello con il rischio più alto per l'UX.

| Dominio | Bug Critici | Bug Alti | Tech Debt | Stato |
|---------|-------------|----------|-----------|-------|
| Platform Channels | 1 | 1 | 5 | 🟡 |
| Timer & Live Activities | 2 | 2 | 5 | 🔴 |
| Audio & Background | 3 | 1 | 6 | 🔴 |
| HealthKit & Watch | 0 | 2 | 6 | 🟢 |
| Notifications | 2 | 2 | 8 | 🔴 |

---

## P0 - Bug Critici (Fix Immediato)

### P0-1: FlutterResult chiamato da thread non-main (CRASH POTENZIALE)

**Pattern ricorrente in 3 domini — rischio crash sporadico in produzione**

| File | Righe | Descrizione |
|------|-------|-------------|
| `LiveActivityHandler.swift` | 167, 428, 902, 990 | `result()` dentro `Task {}` su thread cooperativo |
| `UnifiedTimerCoordinator.swift` | 71 | `result()` da `coordinationQueue` concurrent |

**Causa**: Flutter engine non è thread-safe per i callback `FlutterResult`. Chiamarli da thread non-main è undefined behavior.

**Fix**:
```swift
// ❌ Prima
result(true)

// ✅ Dopo — opzione 1 (async context)
await MainActor.run { result(true) }

// ✅ Dopo — opzione 2 (sync context)
DispatchQueue.main.async { result(true) }
```

**Riferimento Apple**: [Flutter iOS Platform Channels - Threading](https://docs.flutter.dev/platform-integration/platform-channels#channels-and-platform-threading)

---

### P0-2: 3 Delegati UNUserNotificationCenterDelegate in conflitto (SUONI MANCANTI)

**Causa comportamento imprevedibile delle notifiche — suono presente o assente dipende dal timing**

| File | Riga | Assegnazione |
|------|------|--------------|
| `AppDelegate.swift` | 54 | `UNUserNotificationCenter.current().delegate = self` |
| `DirectNotificationManager.swift` | 29 | `UNUserNotificationCenter.current().delegate = self` |
| `NotificationDelegate.swift` | 21 | `UNUserNotificationCenter.current().delegate = self` |

**Problema**: I tre `willPresent` handler hanno opzioni **diverse**:
- `AppDelegate`: `[.banner, .sound, .badge]`
- `NotificationDelegate`: `[.banner, .list]` ← **suono mancante!**
- `DirectNotificationManager`: `[.alert, .sound, .badge]`

L'ultimo che esegue vince, e l'ordine dipende dall'inizializzazione lazy dei singleton.

**Fix**: Un solo delegato — `DirectNotificationManager` ha la logica più completa. Rimuovere le assegnazioni da `AppDelegate.swift:54` e `NotificationDelegate.swift:21`.

```swift
// AppDelegate.swift — RIMUOVERE la riga:
UNUserNotificationCenter.current().delegate = self  // ❌

// NotificationDelegate.swift — NON impostare più come delegate diretto
// Comunicare tramite notifiche o delegation pattern
```

---

### P0-3: Deadlock `DispatchQueue.main.sync` da background thread

| File | Righe | Rischio |
|------|-------|---------|
| `BackgroundAudioManager.swift` | 125, 334, 539 | Deadlock se main è bloccato |
| `TimerSoundFix.swift` | 203 | Deadlock se main è bloccato |
| `DirectNotificationManager.swift` | 846 | `semaphore.wait()` su main thread |
| `NotificationPermissionHelper.swift` | 81 | `semaphore.wait()` su main thread |

**Fix**:
```swift
// ❌ Prima — deadlock se chiamato da main
let state = DispatchQueue.main.sync { UIApplication.shared.applicationState }

// ✅ Dopo — cattura stato in anticipo o usa async
DispatchQueue.main.async { [weak self] in
    let state = UIApplication.shared.applicationState
    self?.handleState(state)
}
```

Per i `semaphore.wait()`, convertire in callback asincrono:
```swift
// ❌ Prima
let semaphore = DispatchSemaphore(value: 0)
UNUserNotificationCenter.current().getNotificationSettings { settings in
    semaphore.signal()
}
semaphore.wait()  // Deadlock su main thread!

// ✅ Dopo — async/await
let settings = await UNUserNotificationCenter.current().notificationSettings()
```

---

### P0-4: URL construction errata per `silent_loop.caf` (AUDIO MAI FUNZIONANTE)

**File**: `UnifiedTimerCoordinator.swift:595-596`

```swift
// ❌ Prima — URL(string:) rompe path con spazi/caratteri speciali nel sandbox iOS
let silentAudioURL = URL(string: "file://\(silentAudioPath)")  // nil se path ha spazi!

// ✅ Dopo — URL(fileURLWithPath:) gestisce correttamente tutti i path
let silentAudioURL = URL(fileURLWithPath: silentAudioPath)
// Nota: URL(fileURLWithPath:) non è failable, rimuovere il guard let
```

**Impatto**: Il silent audio loop per background non viene mai caricato → timer in background non funziona.

---

## P1 - Bug Alti (Fix prossima release)

### P1-1: Race condition su proprietà mutabili in UnifiedTimerCoordinator

**File**: `UnifiedTimerCoordinator.swift:21-30`

Proprietà `lastAudioTriggerTime`, `pendingCompletions`, `audioSessionActive`, `activeBackgroundTasks` lette/scritte da main thread e `coordinationQueue` concurrent senza barrier su tutti gli accessi.

**Fix**: Rendere la queue serial o aggiungere barrier su tutti gli accessi read/write alle proprietà condivise.

---

### P1-2: Race condition su `silentLoopActive` in BackgroundAudioManager

**File**: `BackgroundAudioManager.swift:548, 628, 864, 1000, 1069, 1076`

`silentLoopActive` viene letto e scritto sia dentro che fuori `stateQueue`. Possibile data corruption in sessioni lunghe.

**Fix**: Tutti gli accessi a `silentLoopActive` devono passare per `stateQueue.sync`.

---

### P1-3: `@available(iOS 16.0)` errato per LiveActivityIntent (serve 16.1+)

**File**: `AppIntent.swift` — intents legacy: `PauseResumeIntent`, `AddTimeIntent`, `SkipTimerIntent`, `CompleteSetIntent`

ActivityKit richiede iOS 16.1. Potenziale crash su iOS 16.0 esatto.

**Fix**: Cambiare `@available(iOS 16.0, *)` → `@available(iOS 16.1, *)` per tutti gli intents Legacy.

---

### P1-4: `WorkoutSessionAttributes` disponibile da iOS 16.1 ma views richiedono iOS 17.0

**File**: `WorkoutSessionAttributes.swift:17`

Incoerenza: gli Attributes dichiarati disponibili da iOS 16.1 non possono essere usati senza le view che richiedono iOS 17.0.

**Fix**: `@available(iOS 16.1, *)` → `@available(iOS 17.0, *)` su `WorkoutSessionAttributes`.

---

### P1-5: `activationDidCompleteWith` imposta `isSessionActivated = true` anche se fallisce

**File**: `WatchConnectivityManager.swift:934-941`

```swift
// ❌ Prima — ignora lo stato di attivazione
func session(_ session: WCSession, activationDidCompleteWith ...) {
    isSessionActivated = true  // Sempre true!
}

// ✅ Dopo
func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    isSessionActivated = activationState == .activated
}
```

**Impatto**: Messaggi Watch silenziosamente persi se sessione non attivata.

---

### P1-6: BGTaskScheduler.register() saltato se background refresh disabilitato

**File**: `BackgroundTaskManager.swift:52-61`

Apple richiede che `BGTaskScheduler.register()` venga chiamato **sempre** prima del return di `applicationDidFinishLaunching`. Il check di disponibilità va fatto solo al momento dello scheduling, non della registrazione.

```swift
// ❌ Prima — registrazione saltata se refresh disabilitato
func registerTasks() {
    guard isBackgroundRefreshAvailable() else { return }
    BGTaskScheduler.shared.register(...)
}

// ✅ Dopo — registrare sempre
func registerTasks() {
    BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.gymbro.timer.refresh", ...) { task in
        // Il check di disponibilità va qui, al momento dell'esecuzione
    }
}
```

---

### P1-7: Deadlock potenziale in `logNotificationDiagnostics`

**File**: `DirectNotificationManager.swift:846-856`

`DispatchQueue.main.sync` con `semaphore.wait()` internamente. Se chiamato dal main thread → deadlock.

---

### P1-8: Delay fisso 300ms per sync Watch→iPhone

**File**: `WatchConnectivityManager.swift:1407`

```swift
// ❌ Delay fisso — non funziona su device lenti o app in background
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { ... }
```

**Fix**: Pattern callback/observer per attendere che Flutter aggiorni `currentRestTimerState`.

---

## P2 - Tech Debt Alto

### TD-1: ~830 righe di codice test/debug in produzione

| File | Righe | Tipo |
|------|-------|------|
| `BackgroundAudioManager.swift` | 1301-1617 | Test suite (`testTimerAudioSystem`, `testCriticalFixes`, ecc.) |
| `AudioDebugTestHandler.swift` | Tutto (301 righe) | Debug handler via platform channel |
| `LockscreenAudioTest.swift` | Tutto (194 righe) | Test lockscreen audio |
| `AudioTraceLogger.swift` | Tutto (323 righe) | Trace logger in memoria (100 eventi max) |
| `notification_service.dart` | 724-1104 | `testAudioFiles()`, `testProductionAudio()`, ecc. |

**Fix**: Wrappare in `#if DEBUG` / `kDebugMode` o spostare in target di test separato.

---

### TD-2: Magic strings per channel names (rischio refactoring)

`"com.gymbro.timer/unified"` appare in **5+ file Swift** e **2+ file Dart** hardcoded.

**Fix**:
```swift
// iOS — creare ChannelNames.swift
enum ChannelNames {
    static let unified        = "com.gymbro.timer/unified"
    static let liveActivity   = "com.gymbro.timer/live_activity"
    static let workoutSession = "com.gymbro.timer/workout_session"
    static let notifications  = "com.gymbro/notifications"
    static let watchConnectivity = "com.gymbro/watch_connectivity"
    static let healthkitActivity = "com.gymbro/healthkit_activity"
    static let featureFlags   = "com.gymbro.feature_flags"
    static let timerSoundFix  = "com.gymbro.timer_sound_fix"
}
```

```dart
// Dart — creare platform_channels.dart
class PlatformChannels {
  static const unified          = 'com.gymbro.timer/unified';
  static const liveActivity     = 'com.gymbro.timer/live_activity';
  static const workoutSession   = 'com.gymbro.timer/workout_session';
  static const notifications    = 'com.gymbro/notifications';
  static const watchConnectivity = 'com.gymbro/watch_connectivity';
  static const healthkitActivity = 'com.gymbro/healthkit_activity';
}
```

---

### TD-3: Doppio sistema Live Activities (manutenzione doppia)

Coesistono due sistemi paralleli:
- **Legacy**: `GymBroTimerAttributes` + `GymBroTimerWidgetLiveActivity` (iOS 16.1+)
- **Nuovo**: `WorkoutSessionAttributes` + `WorkoutSessionLiveActivity` (iOS 17.0+)

Con logica duplicata in Intents, Views, Attributes, Darwin notifications.

#### Piano di dismissione sistema LA legacy

**Trigger**: Quando il deploy target sale a **iOS 17.0** (attualmente iOS 16.0).

**File da rimuovere** (sistema legacy):

| File | Tipo | Righe |
|------|------|-------|
| `ios/GymBroTimerWidget/GymBroTimerAttributes.swift` | Attributes legacy | ~50 |
| `ios/GymBroTimerWidget/GymBroTimerWidgetLiveActivity.swift` | View legacy | ~200 |
| `ios/GymBroTimerWidget/AppIntent.swift` | Intents legacy (Pause/Resume/Skip) | ~150 |

**File da modificare**:

| File | Azione |
|------|--------|
| `ios/GymBroTimerWidget/GymBroTimerWidgetBundle.swift` | Rimuovere `GymBroTimerWidgetLiveActivity` dal bundle |
| `ios/GymBroTimerWidget/SharedTimerState.swift` | Rimuovere ref a `GymBroTimerAttributes` |
| `ios/Runner/LiveActivityHandler.swift` | Rimuovere tutti i metodi `startLegacy*`, `updateLegacy*`, `endLegacy*`; rimuovere `@available(iOS 16.1)` guard |

**File da mantenere** (sistema nuovo):

| File | Tipo |
|------|------|
| `ios/GymBroTimerWidget/WorkoutSessionAttributes.swift` | Attributes iOS 17+ |
| `ios/GymBroTimerWidget/WorkoutSessionLiveActivity.swift` | View iOS 17+ |
| `ios/GymBroTimerWidget/WorkoutSessionIntents.swift` | Intents iOS 17+ (con Darwin notifications) |
| `ios/Runner/Managers/WorkoutSessionManager.swift` | Manager sessione |

**Dipendenze da aggiornare**:
- `LiveActivityHandler`: Rimuovere branching `if #available(iOS 17.0)` → usare solo path nuovo
- `AppDelegate`: Rimuovere registrazione intents legacy
- BP-7 (Darwin notifications intents legacy): diventa obsoleto con dismissione

**Stima effort**: ~4h (rimozione + testing + verifica LA su device)

**Prerequisiti**: iOS 17.0+ adoption rate > 95% (attualmente ~92% a Feb 2026).

---

### TD-4: `BGTaskManagerLegacy` con API deprecated iOS 12

**File**: `BackgroundTaskManager.swift:389-400`

`UIApplication.setMinimumBackgroundFetchInterval` deprecato in iOS 13. Il deploy target è iOS 16+ (Live Activities). Codice morto.

**Fix**: Rimuovere `BackgroundTaskManagerLegacy` completamente.

---

### TD-5: Logging eccessivo — `.warning` usato per info di debug

**File**: Tutti i Managers, particolarmente `TimerSoundFix.swift` e `BackgroundAudioManager.swift`

Centinaia di righe di log multi-line con emoji e box ASCII al livello `.warning`. Impatto I/O e rumore nei log di produzione.

**Fix**: Usare `.debug` per log informativi, riservare `.warning` per situazioni reali. Wrappare in `#if DEBUG`.

---

### TD-6: `scheduleSmartNotification` in BackgroundAudioManager è dead code

**File**: `BackgroundAudioManager.swift:239-280`

Il metodo configura l'audio session poi stampa "SKIPPING native notification - Flutter handles it" e non schedula nulla. Salva un fake `notificationId = "skipped_flutter_handles_it"` che `cancelScheduledAudio()` poi tenta di cancellare inutilmente.

**Fix**: Rimuovere il metodo o documentarlo chiaramente come no-op.

---

### TD-7: `UserDefaults.synchronize()` deprecated (iOS 12)

Chiamate da rimuovere:
- `SharedTimerState.swift` (5 occorrenze)
- `WorkoutSessionIntents.swift` (5 occorrenze)
- `WorkoutSessionManager.swift` (4 occorrenze)
- `WorkoutManager.swift` (1 occorrenza)

iOS sincronizza automaticamente. Chiamare `synchronize()` può causare performance degradation.

---

### TD-8: FlutterMethodChannel ricreato ad ogni notifica in foreground

**File**: `AppDelegate.swift:707-708`, `DirectNotificationManager.swift:623`, `BackgroundAudioManager.swift:759, 1056`

Ogni notifica foreground crea una nuova istanza `FlutterMethodChannel` invece di riusare quella esistente.

**Fix**: Creare un singleton `FlutterChannelRegistry` o passare il riferimento dal `UnifiedTimerCoordinator`.

---

## P3 - Best Practices da Aggiornare

### BP-1: `perform()` degli AppIntent senza `@MainActor`

**File**: `AppIntent.swift` — tutti gli intents legacy (righe 29, 95, 159, 210)

Apple raccomanda `@MainActor` su `perform()` quando si accede a shared state o UI-related APIs.

```swift
// ❌ Prima
func perform() async throws -> some IntentResult { ... }

// ✅ Dopo
@MainActor
func perform() async throws -> some IntentResult { ... }
```

---

### BP-2: `async/await` mancante per HKHealthStore queries

**File**: `HealthKitActivityManager.swift:68-76, 98-129`

Usa ancora callback pattern. Da iOS 15, `HKHealthStore` ha le API async.

```swift
// ❌ Prima (callback)
healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in ... }

// ✅ Dopo (async/await — iOS 15+)
try await healthStore.requestAuthorization(toShare: nil, read: readTypes)
```

---

### BP-3: `@Observable` macro non usata (watchOS 10+)

**File**: `ConnectivityManager.swift` (Watch App)

Usa `ObservableObject/@Published`. Per watchOS 10+, la macro `@Observable` offre updates granulari più efficienti.

```swift
// ❌ Prima
class ConnectivityManager: ObservableObject {
    @Published var isConnected = false
}

// ✅ Dopo (watchOS 10+)
@Observable
class ConnectivityManager {
    var isConnected = false
}
```

---

### BP-4: Swift 6 readiness — migrazione ad `actor` pattern

I singleton con stato mutable protetti da `DispatchQueue` manuale (`stateQueue.sync`) funzionano in Swift 5.x ma causeranno warning/errori con Swift 6 strict concurrency.

**File candidati per migrazione**: `AudioSessionManager`, `LiveActivityHandler`, `DirectNotificationManager`

```swift
// ✅ Pattern futuro Swift 6
actor AudioSessionManager {
    static let shared = AudioSessionManager()
    private var currentState: AudioState = .uninitialized
    // Niente più stateQueue.sync — actor gestisce l'isolation
}
```

**Nota**: Non urgente, preparatorio per Swift 6.

---

### BP-5: `InterruptionLevel.critical` senza entitlement Apple

**File**: `notification_service.dart:873-874`

`InterruptionLevel.critical` richiede un entitlement specifico Apple (com.apple.developer.usernotifications.critical-alerts). Senza di esso viene silenziosamente ignorato, ma potrebbe causare rejection App Store se Apple lo rileva.

**Fix**: Usare `.timeSensitive` (sufficiente per timer fitness) nel fallback Dart.

---

### BP-6: Limite 64 notifiche pending non verificato

**File**: `DirectNotificationManager.swift`

iOS limita a 64 le notifiche pending. In sessioni di workout lunghe con molti timer e add_time, il limite potrebbe essere raggiunto silenziosamente.

**Fix**:
```swift
func scheduleNotification(...) async {
    let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
    if pending.count >= 60 {  // Buffer di sicurezza
        // Cancellare le più vecchie prima di aggiungerne nuove
        await cleanupOldTimerNotifications()
    }
    // ... schedule
}
```

---

### BP-7: Intents GymBroTimer legacy non inviano Darwin notification a Flutter

**File**: `AppIntent.swift` — intents legacy

I nuovi intents in `WorkoutSessionIntents.swift` inviano Darwin notification per notificare Flutter. I vecchi intents in `AppIntent.swift` non lo fanno → Flutter non riceve eventi dal vecchio timer Live Activity.

**Fix**: Aggiungere Darwin notification post negli intents legacy, o dismettere il vecchio sistema (TD-3).

---

### BP-8: `AVAudioSessionRouteChangeNotification` non gestita

**File**: `AudioSessionManager.swift`

Quando l'utente connette/disconnette cuffie o AirPods durante un workout, l'audio session può diventare invalida senza che l'app lo sappia.

**Fix**:
```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleRouteChange),
    name: AVAudioSession.routeChangeNotification,
    object: nil
)

@objc private func handleRouteChange(notification: Notification) {
    guard let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
          let routeChangeReason = AVAudioSession.RouteChangeReason(rawValue: reason) else { return }

    switch routeChangeReason {
    case .oldDeviceUnavailable:
        // Riconfigurare audio session
        reconfigureAudioSession()
    default:
        break
    }
}
```

---

## Punti Positivi

L'audit ha identificato molte implementazioni eccellenti:

### Platform Channels
- Channel names **perfettamente consistenti** tra Dart e Swift (case-sensitive)
- `[weak self]` usato correttamente nella maggior parte degli handler critici
- Thread-safety per Live Activity state con `activityQueue` e get/set sincronizzati
- Validazione robusta parametri timer (`validateTimerState()`) prima di ogni operazione
- Error handling completo con `FlutterError` specifici (DISABLED, INVALID_ARGUMENTS, ecc.)
- Smart throttling per update Live Activities con regole Watch-specific
- Retry mechanism per visibility restrictions con delay e fallback

### Timer & Live Activities
- `Text(timerInterval:countsDown:)` nativo iOS — timer continua anche senza aggiornamenti
- `effectiveMode` pattern: transizione automatica REST→EXERCISE quando timer scade
- Doppio scheduling notifiche (Intent + app) funziona anche con app terminata
- Darwin Notification Center per IPC cross-process widget-app

### Audio & Background
- OSStatus -50 risolto: `.duckOthers + .mixWithOthers` eliminato, solo `.mixWithOthers`
- State machine AudioSessionManager con stati (uninitialized/foreground/background/transitioning)
- Background task identifiers registrati in Info.plist con `audio`, `fetch`, `processing`
- Expiration handler sempre impostato, `setTaskCompleted()` in tutti i path
- Deduplication audio thread-safe (threshold 2 secondi)

### HealthKit & Watch
- Pattern dual-delivery: `updateApplicationContext` + `sendMessage` per tutti gli stati workout
- `NSNull` sanitization robusta (`sanitizeForPropertyList()`) per payload WatchConnectivity
- Crash recovery con UserDefaults (ripristino sessione con check stale data a 4 ore)
- Rate limiting Watch (300ms tra messaggi) + retry con exponential backoff
- `HKWorkoutSession` + `HKLiveWorkoutBuilder` pattern corretto per watchOS
- Pending commands queue per comandi Watch critici quando app iPhone è in background
- PrivacyInfo.xcprivacy completo con Health, Fitness e Required Reason APIs

### Notifications
- Race condition handling con `isSkipInProgress` + `trackingQueue`
- Auto-dismiss notifiche vecchie su `applicationDidBecomeActive`
- Notification categories con `allowInCarPlay`, `hiddenPreviewsShowTitle`
- Sound file verification con check esistenza, leggibilità e dimensione

---

## Piano di Azione

### Sprint 1 — P0 Fix (entro questa settimana)

| # | Task | File | Effort |
|---|------|------|--------|
| ☐ | Fix `FlutterResult` su main thread | `LiveActivityHandler.swift`, `UnifiedTimerCoordinator.swift` | 2h |
| ☐ | Consolidare delegato notifiche unico | `AppDelegate.swift`, `NotificationDelegate.swift` | 1h |
| ☐ | Fix deadlock `main.sync` → `main.async` | `BackgroundAudioManager.swift`, `TimerSoundFix.swift`, `DirectNotificationManager.swift`, `NotificationPermissionHelper.swift` | 2h |
| ☐ | Fix URL `silent_loop.caf` | `UnifiedTimerCoordinator.swift:595` | 5 min |

### Sprint 2 — P1 Fix (prossime 2 settimane)

| # | Task | File | Effort |
|---|------|------|--------|
| ☐ | Fix race condition proprietà `UnifiedTimerCoordinator` | `UnifiedTimerCoordinator.swift` | 2h |
| ☐ | Fix race condition `silentLoopActive` | `BackgroundAudioManager.swift` | 1h |
| ☐ | Fix `@available` iOS 16.0→16.1 per LiveActivityIntent | `AppIntent.swift` | 15 min |
| ☐ | Fix `WorkoutSessionAttributes` iOS 16.1→17.0 | `WorkoutSessionAttributes.swift` | 5 min |
| ☐ | Fix `WCSession` activation state check | `WatchConnectivityManager.swift:934` | 15 min |
| ☐ | Fix `BGTaskScheduler.register()` incondizionale | `BackgroundTaskManager.swift` | 30 min |
| ☐ | Fix deadlock `logNotificationDiagnostics` | `DirectNotificationManager.swift:846` | 30 min |
| ☐ | Sostituire delay fisso 300ms Watch→iPhone | `WatchConnectivityManager.swift:1407` | 2h |

### Backlog — P2 (next sprint)

| # | Task | Effort |
|---|------|--------|
| ☐ | Wrappare codice test/debug in `#if DEBUG` (~830 righe) | 3h |
| ☐ | Creare `ChannelNames.swift` + `PlatformChannels` Dart | 2h |
| ☐ | Rimuovere `BGTaskManagerLegacy` (codice morto iOS 12) | 30 min |
| ☐ | Rimuovere `scheduleSmartNotification` (dead code) | 15 min |
| ☐ | Rimuovere tutte le chiamate `UserDefaults.synchronize()` | 30 min |
| ☐ | Fix logging — `.warning` → `.debug` per log informativi | 1h |

### Backlog — P3 (quando si alza deploy target)

| # | Task | Quando |
|---|------|--------|
| ☐ | Aggiungere `@MainActor` a `perform()` intents legacy | Subito (semplice) |
| ☐ | Migrare HealthKit a `async/await` | Prima di iOS 18 |
| ☐ | Migrare Watch a `@Observable` macro | Con watchOS 11 target |
| ☐ | Valutare `actor` per AudioSessionManager, LiveActivityHandler | Prima di Swift 6 |
| ☐ | Dismettere sistema Live Activities legacy (GymBroTimerAttributes) | Quando target ≥ iOS 17 |
| ☐ | Aggiungere `AVAudioSessionRouteChangeNotification` handler | Con prossima release audio |
| ☐ | Check limite 64 notifiche pending | Con prossima release |
| ☐ | Usare `InterruptionLevel.timeSensitive` invece di `.critical` | Subito |

---

## Checklist Progresso

> Aggiornare questa sezione man mano che i fix vengono applicati.

### P0 — Critici
- [x] P0-1: FlutterResult su main thread (`LiveActivityHandler.swift`, `UnifiedTimerCoordinator.swift`) ✅
- [x] P0-2: Delegato notifiche unico (rimuovere da `AppDelegate` e `NotificationDelegate`) ✅
- [x] P0-3: Deadlock `DispatchQueue.main.sync` (4 file) ✅
- [x] P0-4: URL `silent_loop.caf` → `URL(fileURLWithPath:)` ✅

### P1 — Alti
- [x] P1-1: Race condition `UnifiedTimerCoordinator` proprietà mutabili ✅
- [x] P1-2: Race condition `silentLoopActive` fuori da `stateQueue` ✅
- [x] P1-3: `@available(iOS 16.0)` → `@available(iOS 16.1)` intents legacy ✅
- [x] P1-4: `WorkoutSessionAttributes` `@available` iOS 16.1 → 17.0 ✅
- [x] P1-5: `WCSession activationDidCompleteWith` check stato ✅
- [x] P1-6: `BGTaskScheduler.register()` incondizionale ✅
- [x] P1-7: Deadlock `logNotificationDiagnostics` ✅ (fixato in P0-3)
- [x] P1-8: Delay fisso 300ms Watch→iPhone → callback ✅

### P2 — Tech Debt
- [x] TD-1: Codice test/debug in `#if DEBUG` (~830 righe) ✅
- [x] TD-2: `ChannelNames.swift` + `PlatformChannels` Dart ✅
- [x] TD-3: Piano dismissione sistema LA legacy (documentato sopra) ✅
- [x] TD-4: Rimuovere `BGTaskManagerLegacy` ✅
- [x] TD-5: Logging `.warning` → `.debug` ✅
- [x] TD-6: Rimuovere `scheduleSmartNotification` dead code ✅
- [x] TD-7: Rimuovere `UserDefaults.synchronize()` (deprecato) ✅
- [x] TD-8: Singleton `FlutterChannelRegistry` ✅

### P3 — Best Practices
- [ ] BP-1: `@MainActor` su `perform()` intents legacy
- [ ] BP-2: Async/await HealthKitActivityManager
- [ ] BP-3: `@Observable` Watch ConnectivityManager
- [ ] BP-4: Swift 6 actor readiness (backlog)
- [ ] BP-5: `InterruptionLevel.critical` → `.timeSensitive`
- [ ] BP-6: Check limite 64 notifiche pending
- [ ] BP-7: Darwin notification negli intents legacy
- [ ] BP-8: `AVAudioSessionRouteChangeNotification` handler

---

### AUDIO-FIX — Timer Sound Not Playing (2026-02-18)

> Fix per il bug: timer non emette NESSUN suono alla scadenza (foreground, background, lockscreen).
> Solo vibrazione funziona. Mute switch OFF, volume 100%, Focus/DND disabilitato.

- [x] AF-1: Rimosso `cancelAllTimerNotifications()` da `playCompletionSound()` — cancellava la notifica di backup dopo che `AVAudioPlayer.play()` ritornava `true` (ma non udibile con schermo bloccato) ✅
- [x] AF-2: Audio session configuration sincrona in foreground path — `reactivate()` era async, player creato prima che la sessione fosse configurata ✅
- [x] AF-3: Sostituito `objc_setAssociatedObject` con array `activePlayers` in `DirectNotificationManager` — il precedente approccio sovrascriveva il player precedente via ARC ✅
- [x] AF-4: Ripristinato `scheduleBackupNotification()` rimosso come dead code in TD-6 — era l'unico backup per timer >30s in background ✅
- [x] AF-5: Rimosso `willPresent`/`didReceive` override da `AppDelegate` — `DirectNotificationManager` è l'unico delegate ✅
- [x] AF-6: Aggiunto `.duckOthers` switch prima del suono di completamento + restore `.mixWithOthers` dopo — per rendere il suono udibile sopra altra musica ✅
- [x] AF-7: Aggiunti `ChannelNames.swift` e `FlutterChannelRegistry.swift` al progetto Xcode (erano su disco ma non nel target) ✅

**File modificati**: `BackgroundAudioManager.swift`, `DirectNotificationManager.swift`, `AppDelegate.swift`, `project.pbxproj`
**Build**: ✅ Compilazione verificata | **Analyze**: ✅ Nessun nuovo warning

### AUDIO-MUTEX — Multiple Sounds on Timer Completion (2026-02-19)

> Fix per il bug: timer emette MULTIPLI suoni alla scadenza invece di uno solo.
> Causa: i fix AUDIO-FIX hanno ripristinato 3+ path audio indipendenti che si attivano contemporaneamente.

**Root Cause Analysis** — 4 path audio simultanei in foreground:
1. `playCompletionSound()` → AVAudioPlayer (dispatch timer)
2. `TimerSoundFix.playTimerCompletionSound()` (chiamato SEMPRE come "backup" anche se #1 ha successo)
3. Backup notification → `willPresent` → `playNotificationAudio()` (AVAudioPlayer manuale)
4. Backup notification → `willPresent` → `.sound` nel completionHandler (suono notifica iOS)

**Fix applicati**:
- [x] AM-1: Rimosso `.sound` dal completionHandler in `willPresent` per notifiche timer — `playNotificationAudio()` già gestisce l'audio, `.sound` causava double-sound ✅
- [x] AM-2: `willPresent` ora verifica `BackgroundAudioManager.wasAudioPlayedRecently()` — se il suono è già stato emesso dal dispatch timer, la notifica mostra solo banner (no audio) ✅
- [x] AM-3: `TimerSoundFix` chiamato SOLO quando AVAudioPlayer fallisce — precedente "belt-and-suspenders" causava double-sound ✅
- [x] AM-4: `cancelAllTimerNotifications()` chiamato dopo ogni play riuscito — previene backup notification dal suonare dopo il primario ✅
- [x] AM-5: Aggiunto `wasAudioPlayedRecently(withinSeconds:)` a `BackgroundAudioManager` — API pubblica thread-safe per deduplication cross-manager ✅
- [x] AM-6: `UnifiedTimerCoordinator.handlePlayCompletionSound()` ora verifica `wasAudioPlayedRecently()` — il Dart ticker e il dispatch timer iOS scattano contemporaneamente, AM-6 previene il doppio suono ✅

**Architettura risultante — esattamente 1 suono**:
```
Timer Expire
├─ Foreground + Silent Loop → AVAudioPlayer (primary) → cancel backup notification
├─ Foreground senza Silent Loop → AVAudioPlayer (primary) → cancel backup notification
├─ Background + Silent Loop → AVAudioPlayer (primary) → cancel backup notification
├─ Background senza Silent Loop → TimerSoundFix (primary) → cancel backup notification
└─ App Suspended/Killed → Backup UNNotification con suono (unico path attivo)

willPresent handler (foreground only):
├─ Se audio già played (< 3s) → banner only, NO sound
└─ Se NO audio recente → playNotificationAudio() come fallback
```

**File modificati**: `BackgroundAudioManager.swift`, `DirectNotificationManager.swift`, `UnifiedTimerCoordinator.swift`

**Status**: P0 ✅ | P1 ✅ | P2 ✅ | AUDIO-FIX ✅ | AUDIO-MUTEX ✅ | **Prossimo step**: P3 — Best Practices (backlog, bassa priorità).

**Riferimenti Apple**:
- [ActivityKit (iOS 16.1+)](https://developer.apple.com/documentation/activitykit)
- [Flutter Platform Channels Threading](https://docs.flutter.dev/platform-integration/platform-channels#channels-and-platform-threading)
- [BGTaskScheduler](https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler)
- [UNUserNotificationCenterDelegate](https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate)
- [WatchConnectivity Programming Guide](https://developer.apple.com/documentation/watchconnectivity)
- [AVAudioSession Configuration](https://developer.apple.com/documentation/avfaudio/avaudiosession)
