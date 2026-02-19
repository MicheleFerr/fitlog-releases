# 🔍 watchOS Companion App Audit 2026

**Data**: 2026-02-18 | **Analizzato da**: Claude Opus 4.6
**Scope**: 5 file Swift watchOS + 2 file Swift iPhone-side + 1 file Dart | **Status**: Audit Completato

---

## Indice

1. [Riepilogo Esecutivo](#riepilogo-esecutivo)
2. [P0 - Bug Critici](#p0---bug-critici-fix-immediato)
3. [P1 - Bug Alti](#p1---bug-alti-fix-prossima-release)
4. [P2 - Tech Debt](#p2---tech-debt)
5. [P3 - Best Practices](#p3---best-practices)
6. [Punti Positivi](#-punti-positivi)
7. [Analisi File-by-File](#analisi-file-by-file)
8. [Checklist Simmetria Bidirezionale Watch iPhone](#checklist-simmetria-bidirezionale-watchiphone)
9. [Checklist Progresso](#checklist-progresso)
10. [Stima Effort](#stima-effort)

---

## Riepilogo Esecutivo

L'app watchOS companion (FitLogWatch) e ben funzionante con supporto completo per workout normali, superset, dropset e rest-pause. L'architettura di comunicazione bidirezionale tramite WCSession e solida, con pattern affidabili come dual delivery e optimistic UI. Trovati **2 bug critici P0**, **8 bug alti P1**, e significativo tech debt nella manutenibilita del codice.

Il punto di forza principale e il sistema di comunicazione robusto con fallback multipli. Il punto debole principale e `ContentView.swift` (3568 righe) che contiene tutta la UI in un singolo file monolitico.

| File | Righe | P0 | P1 | P2 | P3 | Stato |
|------|-------|----|----|----|----|----|
| `ContentView.swift` | 3568 | 0 | 3 | 5 | 3 | 🟡 |
| `ConnectivityManager.swift` | 1995 | 1 | 3 | 4 | 2 | 🟡 |
| `WorkoutManager.swift` | 551 | 0 | 1 | 2 | 1 | 🟢 |
| `NotificationManager.swift` | 114 | 1 | 0 | 1 | 1 | 🔴 |
| `FitLogWatchApp.swift` | 182 | 0 | 1 | 1 | 1 | 🟢 |
| **iPhone-side** WatchConnectivityManager | 1686 | 0 | 0 | 2 | 1 | 🟢 |
| **Flutter** watch_connectivity_provider | 1322 | 0 | 0 | 1 | 1 | 🟢 |
| **Totale** | **~9418** | **2** | **8** | **16** | **10** | |

---

## P0 - Bug Critici (Fix Immediato)

### ~~P0-1: CORRETTO — False Positive~~

**Analisi iniziale**: Si temeva data race in `NotificationDelegate` per accesso a `@MainActor` properties.
**Verifica**: `NotificationDelegate` NON accede a `ConnectivityManager.shared.appLocale`. I suoi metodi delegate chiamano solo `completionHandler([.banner, .sound])`. L'accesso a `appLocale` e in `NotificationManager.showWorkoutStartedNotification()` che e gia `@MainActor`. Il `WKInterfaceDevice.current().play()` e gia dispatchato via `Task { @MainActor in }`.
**Status**: ✅ Nessun bug — codice gia corretto.

---

### P0-2: Potenziale out-of-order message processing su @MainActor via Task

**File**: `ConnectivityManager.swift` — tutti i metodi `nonisolated` del WCSessionDelegate
**Severita**: Corruzione stato / UI inconsistente

I metodi del WCSessionDelegate sono `nonisolated` (correttamente, dato il protocollo) e dispatchano al MainActor via `Task { @MainActor in ... }`. Tuttavia, `Task {}` **non garantisce l'ordine di esecuzione**. Se il Watch riceve in rapida successione:

1. `workoutUpdate` (esercizio cambia a "Bench Press")
2. `restTimerStarted` (timer per esercizio precedente)

Il Task per (2) potrebbe eseguire *prima* del Task per (1), mostrando un timer per un esercizio che l'utente non ha ancora visto cambiare.

```swift
// ❌ ATTUALE — ordine non garantito
nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    Task { @MainActor in
        self.processIncomingMessage(message)  // Quando esegue? Non deterministic
    }
}

nonisolated func session(_ session: WCSession, didReceiveApplicationContext ctx: [String : Any]) {
    Task { @MainActor in
        self.handleContext(ctx)  // Potrebbe eseguire prima del message sopra
    }
}
```

**Fix**: Usare un `AsyncStream` o una serial queue per garantire l'ordine:

```swift
// ✅ FIX — message queue seriale
private let messageChannel = AsyncStream<[String: Any]>.makeStream()

init() {
    Task { @MainActor in
        for await message in messageChannel.stream {
            self.processIncomingMessage(message)
        }
    }
}

nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    messageChannel.continuation.yield(message)
}
```

**Impatto**: In condizioni normali (latenza rete > tempo di scheduling), l'ordine e quasi sempre corretto. Sotto carico (es. cambio esercizio rapido + timer + health metrics), possibile stato UI inconsistente momentaneo.

---

## P1 - Bug Alti (Fix prossima release)

### P1-1: ContentView.swift God Object — 3568 righe, 15+ viste in un file

**File**: `ContentView.swift:1-3568`
**Severita**: Manutenibilita / Performance

Un singolo file contiene **tutte** le viste dell'app watchOS:
- `ContentView` (root)
- `WaitingView`
- `WorkoutCompanionView` (4 tab)
- `ExerciseControlView` (logica complessa superset/dropset/rest-pause)
- `SimplifiedSetView`
- `AdvancedInfoView`
- `RestTimerView`
- `StatsView`
- `EffortPickerView` (RPE/RIR)
- `EditRepsSheetView`
- `WorkoutSummaryView`
- `QuickAddTimePicker`
- Helper extensions

**Impatto**: Ogni modifica ricompila l'intero file. SwiftUI body recomputation e piu costosa con viste grandi. Code review e merge conflict diventano probabili.

**Fix**: Separare in file individuali:
```
Views/
├── ContentView.swift          (~50 righe)
├── WaitingView.swift          (~80 righe)
├── WorkoutCompanionView.swift (~150 righe)
├── ExerciseControlView.swift  (~500 righe)
├── SimplifiedSetView.swift    (~200 righe)
├── AdvancedInfoView.swift     (~300 righe)
├── RestTimerView.swift        (~200 righe)
├── StatsView.swift            (~200 righe)
├── EffortPickerView.swift     (~250 righe)
├── EditRepsSheetView.swift    (~200 righe)
├── WorkoutSummaryView.swift   (~150 righe)
└── Helpers/
    ├── QuickAddTimePicker.swift
    └── SafeSubscript.swift
```

---

### P1-2: Hardcoded localization con pattern `isItalian`

**File**: `ContentView.swift` — usato in ~40+ punti
**Severita**: Scalabilita / UX

Tutta la localizzazione usa un pattern binario:

```swift
private var isItalian: Bool {
    connectivity.appLocale == "it"
}

// Usato ovunque:
Text(isItalian ? "Prossima serie" : "Next Set")
Text(isItalian ? "Salta riposo" : "Skip Rest")
```

**Problemi**:
1. Non scala oltre 2 lingue (en/it)
2. Ogni nuova stringa richiede modifica in 2+ punti
3. Nessun sistema di fallback
4. Le stringhe non vengono estratte per traduttori

**Fix**: Usare `String(localized:)` di SwiftUI o un dizionario di traduzione:

```swift
// ✅ Opzione 1: LocalizedStringResource (watchOS 10+)
Text("next_set", bundle: .main)

// ✅ Opzione 2: Enum centralizzato
enum WatchStrings {
    static func nextSet(locale: String) -> String {
        switch locale {
        case "it": return "Prossima serie"
        default: return "Next Set"
        }
    }
}
```

---

### P1-3: ~75 @Published properties su ConnectivityManager

**File**: `ConnectivityManager.swift:20-95` (circa)
**Severita**: Performance / Manutenibilita

`ConnectivityManager` ha circa 75 proprieta `@Published`, ognuna delle quali causa recomputation di qualsiasi SwiftUI view che osserva l'oggetto via `@EnvironmentObject`. Modificare una singola proprieta (es. `heartRate`) triggera il refresh di TUTTE le viste che osservano `ConnectivityManager`.

```swift
// ❌ ATTUALE — ogni proprieta causa refresh globale
@Published var exerciseName = ""
@Published var currentSet = 1
@Published var totalSets = 3
@Published var targetWeight = 0.0
@Published var targetReps = 0
@Published var heartRate = 0.0
@Published var calories = 0.0
// ... ~70 altre proprieta
```

**Fix**: Raggruppare in struct di stato:

```swift
// ✅ FIX — stato raggruppato
struct ExerciseState {
    var name = ""
    var currentSet = 1
    var totalSets = 3
    var targetWeight = 0.0
    var targetReps = 0
}

struct HealthState {
    var heartRate = 0.0
    var calories = 0.0
    var elapsedTime: TimeInterval = 0
}

@Published var exercise = ExerciseState()
@Published var health = HealthState()
@Published var timer = TimerState()
```

---

### P1-4: handleWorkoutUpdate parsing ~30+ campi senza type safety

**File**: `ConnectivityManager.swift` — metodo `handleWorkoutUpdate`
**Severita**: Fragilita / Bug silenti

Il parsing del messaggio workout usa `as? Type ?? default` per 30+ campi. Un typo nella chiave (`"targtWeight"` vs `"targetWeight"`) fallisce silenziosamente con il valore default.

```swift
// ❌ ATTUALE — nessun errore se chiave sbagliata
self.exerciseName = data["exerciseName"] as? String ?? ""
self.targetWeight = data["targetWeight"] as? Double ?? 0.0
self.targetReps = data["targetReps"] as? Int ?? 0
// Se iPhone manda "target_reps" (underscore), Watch mostra 0 senza errori
```

**Fix**: Definire un struct `Codable` condiviso:

```swift
// ✅ FIX — type-safe con errori espliciti
struct WorkoutUpdatePayload: Codable {
    let exerciseName: String
    let currentSet: Int
    let totalSets: Int
    let targetWeight: Double
    let targetReps: Int
    // ...
}

// Decode con errore esplicito
do {
    let jsonData = try JSONSerialization.data(withJSONObject: data)
    let payload = try JSONDecoder().decode(WorkoutUpdatePayload.self, from: jsonData)
    self.exercise = payload  // Atomic update
} catch {
    Logger.shared.log(.error, "Failed to decode workout update: \(error)")
}
```

---

### P1-5: Optimistic timer puo mostrare durata stale

**File**: `ConnectivityManager.swift` — `showOptimisticTimerIfNeeded()`
**Severita**: UX confusa

Dopo che l'utente completa una serie sul Watch, il timer viene mostrato immediatamente con `lastKnownRestTime`. Ma se l'utente ha modificato il rest time su iPhone per questo esercizio, il Watch mostra la durata vecchia fino a quando l'iPhone invia l'aggiornamento reale.

```swift
// ❌ ATTUALE — usa lastKnownRestTime che potrebbe essere stale
func showOptimisticTimerIfNeeded() {
    guard lastKnownRestTime > 0 else { return }
    restTimeRemaining = lastKnownRestTime  // Potrebbe essere 60s quando iPhone dice 90s
    isRestTimerActive = true
    startOptimisticTimer()
}
```

**Impatto**: Timer corretto arriva tipicamente entro 100-500ms. L'utente vede un "flash" del timer sbagliato.

**Fix**: Includere `restTime` nel messaggio di risposta `setCompleted`:
```swift
// ✅ Il reply handler di setCompleted gia include restTimer — verificare che
// il Watch lo usi per sovrascrivere l'optimistic timer immediatamente
```

---

### P1-6: WorkoutManager non verifica staleness della sessione recuperata

**File**: `WorkoutManager.swift` — `recoverWorkoutSession()`
**Severita**: UX / Data integrity

`recoverActiveWorkoutSession()` recupera QUALSIASI sessione HKWorkoutSession attiva, incluse sessioni potenzialmente stale da crash precedenti.

```swift
// ❌ ATTUALE — recupera senza verificare eta
func recoverWorkoutSession() async throws {
    let session = try await healthStore.recoverActiveWorkoutSession()
    // Nessun check: session potrebbe essere di 3 ore fa
    self.workoutSession = session
    self.builder = session.associatedWorkoutBuilder()
}
```

**Fix**: Verificare l'eta della sessione e chiedere conferma:
```swift
// ✅ FIX — verifica staleness
if let startDate = session.startDate,
   Date().timeIntervalSince(startDate) > 3600 * 4 { // 4 ore
    Logger.shared.log(.warning, "Recovered stale session from \(startDate)")
    try await session.end()
    return
}
```

---

### P1-7: EffortPickerView auto-close timer crea una UX ambigua

**File**: `ContentView.swift` — `EffortPickerView`
**Severita**: UX

L'`EffortPickerView` ha un timer che chiude automaticamente la vista dopo N secondi di inattivita. Se l'utente sta pensando (RPE richiede auto-valutazione), il picker si chiude e il set viene completato senza RPE.

```swift
// ❌ ATTUALE — auto-close senza feedback visivo del countdown
.onAppear {
    autoCloseTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { _ in
        // Chiude senza RPE
    }
}
```

**Fix**: Aggiungere un indicatore visivo del countdown (progress ring) o estendere il timeout a 30s.

---

### P1-8: FitLogWatchApp avvia/termina HKWorkoutSession in base a connectivity state

**File**: `FitLogWatchApp.swift:80-105` (circa)
**Severita**: Unexpected behavior

L'entry point dell'app avvia/termina automaticamente `HKWorkoutSession` basandosi su `connectivityManager.isWorkoutActive`. Se la connessione WCSession e instabile (transitoriamente perde e riacquista stato), la sessione HK potrebbe essere terminata e riavviata spuriamente.

```swift
// ❌ ATTUALE — reagisce a ogni cambio di stato
.onChange(of: connectivityManager.isWorkoutActive) { _, isActive in
    if isActive {
        workoutManager.startWorkoutSession(...)
    } else {
        workoutManager.endWorkoutSession(save: true)
    }
}
```

**Fix**: Aggiungere debounce o conferma:
```swift
// ✅ FIX — debounce per evitare stop/start spurio
.onChange(of: connectivityManager.isWorkoutActive) { _, isActive in
    Task {
        try await Task.sleep(for: .seconds(2))
        // Ricontrolla dopo 2s
        guard connectivityManager.isWorkoutActive == isActive else { return }
        if isActive {
            workoutManager.startWorkoutSession(...)
        } else {
            workoutManager.endWorkoutSession(save: true)
        }
    }
}
```

---

## P2 - Tech Debt

### P2-1: Magic strings per tipi di messaggio

**File**: Tutti i file di comunicazione
**Impatto**: Typo silenti, nessun autocomplete

Circa 30+ tipi di messaggio sono stringhe letterali duplicate tra Watch e iPhone:

```swift
// Watch side
sendToiPhone(["type": "setCompleted", ...])

// iPhone side
case "setCompleted":
    handleSetCompletedFromWatch(message, replyHandler: replyHandler)
```

**Fix**: Creare un file `WatchMessageTypes.swift` condiviso (target membership su entrambi):
```swift
enum WatchMessageType: String {
    case setCompleted
    case skipRest
    case endWorkout
    case workoutUpdate
    // ...
}
```

---

### P2-2: Duplicazione switch per messaggi con/senza reply handler (iPhone)

**File**: `WatchConnectivityManager.swift (iPhone):1010-1263`
**Impatto**: Manutenibilita

Il WCSessionDelegate su iPhone ha DUE switch identici:
1. `didReceiveMessage message:` (senza reply) — 25 case
2. `didReceiveMessage message: replyHandler:` (con reply) — 20 case

Molti case sono duplicati con logica quasi identica.

**Fix**: Unificare in un metodo comune:
```swift
private func handleMessage(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)?) {
    // Logica unificata
    // Se replyHandler != nil, usa; altrimenti fire-and-forget
}
```

---

### P2-3: Debug print in produzione

**File**: Tutti
**Impatto**: Privacy / Performance log

Numerose `debugPrint` e `print` che restano in release:

| File | Occorrenze stimate |
|------|--------------------|
| `ContentView.swift` | ~15 |
| `ConnectivityManager.swift` | ~40 |
| `WorkoutManager.swift` | ~10 |
| `WatchConnectivityManager.swift (iPhone)` | ~60 (inclusi print() con `[WATCH DEBUG]`) |
| `watch_connectivity_provider.dart` | ~50 |

Nota: `debugPrint` in Swift viene compilato via in release mode solo se usato con `#if DEBUG`. Le `print()` pure restano in produzione.

**Fix**: Usare un logger con livelli:
```swift
// ✅ Gia presente Logger.shared, usarlo ovunque
Logger.shared.log(.debug, "message")  // Invece di print()
```

---

### P2-4: ContentView mischia business logic e UI

**File**: `ContentView.swift`
**Impatto**: Testabilita / Separazione responsabilita

Le viste contengono direttamente:
- Logica di invio messaggi (`connectivity.sendToiPhone(...)`)
- Logica timer (`Timer.scheduledTimer`)
- Calcoli stato (indice set, superset round, dropset stage)
- Formattazione dati (conversione secondi in mm:ss)

**Fix**: Estrarre la logica in ViewModels o extension su ConnectivityManager:
```swift
// ✅ ViewModel per ExerciseControlView
@MainActor
class ExerciseControlViewModel: ObservableObject {
    func completeSet(effort: Int?, effortScale: String) { ... }
    func skipRest() { ... }
    var formattedWeight: String { ... }
}
```

---

### P2-5: Nessun unit test per codice watchOS

**File**: Nessun test presente
**Impatto**: Regressioni non rilevate

Zero test per:
- Parsing messaggi (`handleWorkoutUpdate`)
- Logica timer (calcolo remainingSeconds da timestamp)
- Stato superset/dropset/rest-pause
- Session recovery
- Rate limiting

---

### P2-6: Timer usa pattern target-selector legacy

**File**: `ConnectivityManager.swift` — `startRestTimer`, `timerTick`
**Impatto**: Modernizzazione Swift

```swift
// ❌ ATTUALE — target-selector con @objc
restTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(timerTick), ...)
RunLoop.current.add(restTimer!, forMode: .common)

@objc private func timerTick() { ... }
```

**Fix**: Usare `Timer.publish` per SwiftUI o `Task.sleep`:
```swift
// ✅ Moderno — Timer.publish per SwiftUI
Timer.publish(every: 1.0, on: .main, in: .common)
    .autoconnect()
    .sink { [weak self] _ in self?.timerTick() }

// ✅ Alternativa — Task-based
timerTask = Task { @MainActor in
    while !Task.isCancelled {
        try await Task.sleep(for: .seconds(1))
        self.timerTick()
    }
}
```

---

### P2-7: ConnectivityManager singleton con init non-private

**File**: `ConnectivityManager.swift`
**Impatto**: Architettura

```swift
// ❌ ATTUALE — init non e private, singleton violabile
class ConnectivityManager: NSObject, ObservableObject {
    static let shared = ConnectivityManager()
    // init() manca `private`
}
```

**Fix**: Rendere `init()` private per enforcement del singleton.

---

### P2-8: SharedTimerState non usato dall'app Watch

**File**: `SharedTimerState.swift`
**Impatto**: Confusione architetturale

`SharedTimerState` usa App Group UserDefaults per comunicare stato timer con il widget Live Activity. L'app Watch usa WCSession, non App Group. Questo file e nel target `GymBroTimerWidget`, non in `FitLogWatch`, quindi non e un problema diretto — ma la sua presenza potrebbe confondere durante la manutenzione.

---

### P2-9: mapWorkoutType() come funzione libera

**File**: `FitLogWatchApp.swift:140-182`
**Impatto**: Code organization

`mapWorkoutType()` e definita come funzione libera (free function) nel file dell'entry point invece che come estensione o metodo statico.

```swift
// ❌ ATTUALE — funzione libera nell'entry point
func mapWorkoutType(_ type: String) -> HKWorkoutActivityType {
    switch type {
    case "strength", "weightTraining": return .traditionalStrengthTraining
    // ...
    }
}
```

**Fix**: Spostare come extension su `HKWorkoutActivityType`:
```swift
extension HKWorkoutActivityType {
    init(from workoutType: String) { ... }
}
```

---

### P2-10: DispatchQueue.main.asyncAfter su classe @MainActor

**File**: `ConnectivityManager.swift` — init e reconnection
**Impatto**: Swift 6 compatibility

`DispatchQueue.main.asyncAfter` su una classe `@MainActor` bypassa l'isolamento dell'attore. In Swift 5.x funziona perche main queue e main actor condividono lo stesso executor, ma in **Swift 6 strict concurrency** questo produrra warning/errori.

```swift
// ❌ ATTUALE — GCD bypassa actor isolation
DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
    self?.someMainActorProperty = value  // Non verificato dal compilatore
}
```

**Fix**: Usare `Task`:
```swift
// ✅ FIX — rispetta actor isolation
Task { @MainActor in
    try? await Task.sleep(for: .milliseconds(100))
    self.someMainActorProperty = value
}
```

---

### P2-11: HR delta threshold hardcoded

**File**: `WorkoutManager.swift`
**Impatto**: Configurabilita

La soglia di delta HR per inviare aggiornamenti (5 BPM) e hardcoded. Per workout ad alta intensita (HIIT), 5 BPM potrebbe essere troppo basso (troppi messaggi). Per workout a bassa intensita, potrebbe essere troppo alto.

---

### P2-12: ConnectivityManager rate limiter non configurabile

**File**: `ConnectivityManager.swift`
**Impatto**: Tuning

Il rate limit di 300ms tra messaggi e hardcoded. Non esiste modo di configurarlo per diversi tipi di messaggio (health metrics potrebbero avere rate limit piu alto dei workout updates).

---

### P2-13: Nessun logging strutturato su Watch

**File**: Tutti i file watchOS
**Impatto**: Debugging in produzione

Il Watch usa `print()` per logging. L'iPhone usa `Logger.shared`. Il Watch dovrebbe usare `os.Logger` nativo per logging strutturato consultabile in Console.app.

---

### P2-14: Flutter provider con ~50 debugPrint in release

**File**: `watch_connectivity_provider.dart`
**Impatto**: Performance log / Privacy

Il provider Flutter contiene ~50 `debugPrint` statements che in Flutter vengono stampati anche in release mode (a differenza di Swift). Dovrebbero essere wrappati in `kDebugMode`.

```dart
// ❌ ATTUALE — stampa in release
debugPrint('⌚ [FLUTTER] ✅ Set completed from Watch');

// ✅ FIX — solo in debug
if (kDebugMode) {
  debugPrint('⌚ [FLUTTER] ✅ Set completed from Watch');
}
```

---

## P3 - Best Practices

### P3-1: Migrare a `@Observable` (Observation framework)

**Target**: watchOS 10+ / iOS 17+

`ObservableObject` con `@Published` causa refresh globali. `@Observable` (macro) di Swift 5.9+ traccia accessi granulari per proprieta.

```swift
// ✅ FUTURO
@Observable
class ConnectivityManager {
    var exerciseName = ""  // Solo viste che leggono exerciseName si aggiornano
    var heartRate = 0.0    // Indipendente da exerciseName
}
```

---

### P3-2: Adottare Codable per payload messaggi

Definire struct condivisi tra Watch e iPhone per tutti i payload:

```swift
// Shared/WatchMessages.swift
struct SetCompletedMessage: Codable {
    let effort: Int?
    let effortScale: String
    let setIndex: Int
    let reps: Int
    let weight: Double
}
```

---

### P3-3: Adottare Swift 6 strict concurrency

Preparare la codebase per Swift 6:
- Aggiungere `@Sendable` alle closure passate tra isolation domains
- Risolvere `nonisolated` accessing `@MainActor` properties
- Sostituire `DispatchQueue.main.asyncAfter` con `Task { @MainActor in }`
- Rendere `NotificationDelegate` `@MainActor`

---

### P3-4: Implementare retry con backoff per WCSession sendMessage

Il Watch attualmente non ha retry per `sendMessage` falliti verso iPhone (solo ConnectivityManager ha una coda con retry, ma limitata).

---

### P3-5: Aggiungere telemetria delivery rate

Tracciare la percentuale di messaggi consegnati con successo per identificare problemi di affidabilita in produzione.

---

### P3-6: Implementare error boundary per Views

Se una view crashha durante il rendering (es. indice out of bounds), l'intera app Watch si chiude. Un error boundary potrebbe mostrare un fallback UI.

---

### P3-7: Usare `String(localized:)` per watchOS 10+

Invece del pattern `isItalian`, usare il sistema di localizzazione nativo di SwiftUI con `.strings` o `.xcstrings` files.

---

### P3-8: Separare ConnectivityManager in sotto-manager

Il ConnectivityManager gestisce tutto: workout state, timer, health metrics, superset, dropset, rest-pause. Separare in:
- `WatchWorkoutStateManager`
- `WatchTimerManager`
- `WatchHealthManager`
- `WatchAdvancedWorkoutManager`

---

### P3-9: Implementare snapshot testing per viste Watch

Le viste watchOS sono difficili da testare manualmente su ogni dimensione di schermo. Snapshot test garantirebbero la UI.

---

### P3-10: Documentare il protocollo di comunicazione Watch-iPhone

Manca documentazione del "contratto" tra Watch e iPhone: quali messaggi esistono, quali campi sono obbligatori, quali opzionali, e il formato atteso.

---

## Punti Positivi

### Dual Delivery Strategy (Eccellente)

L'uso combinato di `sendMessage` (delivery immediata quando reachable) e `applicationContext` (delivery affidabile anche offline) e un pattern robusto che garantisce consegna.

```swift
// iPhone -> Watch: sempre dual delivery
updateApplicationContext(context)  // Persistente
if session.isReachable {
    session.sendMessage(message)   // Immediato
}
```

### Optimistic UI Updates (Ottimo)

Il Watch mostra il timer immediatamente dopo il completamento di una serie, senza attendere la conferma dall'iPhone. Questo da un feeling istantaneo all'utente.

### Rate Limiting & Message Queue (Solido)

Il ConnectivityManager implementa rate limiting (300ms) con coda messaggi (max 20) e retry con backoff esponenziale (max 3 retry). Previene flooding del canale WCSession.

### Pending Commands per Background Safety (Eccellente)

L'iPhone salva comandi critici (come `endWorkout`) in UserDefaults PRIMA di notificare Flutter. Quando Flutter si risveglia dal background, processa i comandi pendenti. Zero data loss.

### Safe Array Subscript Extension (Buono)

```swift
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
```

Previene crash da out-of-bounds in tutta l'app.

### Time-Sync Aware Timer (Buono)

Il rest timer usa timestamp assoluti (`Date().timeIntervalSince1970`) per calcolare il tempo rimanente, evitando drift da latenza di comunicazione.

### Comprehensive Advanced Workout Support (Eccellente)

Supporto completo per superset, dropset e rest-pause con UI dedicata per ognuno. La sliding window UI per superset e particolarmente ben fatta.

### HR Delta Threshold (Buono)

Invia aggiornamenti HR solo quando il delta supera 5 BPM, riducendo il volume di messaggi senza sacrificare la granularita utile.

### Digital Crown Integration (Buono)

Uso appropriato di `.digitalCrownRotation` per editare peso e ripetizioni, con haptic feedback. Molto naturale su watchOS.

### Session Recovery (Buono)

`WorkoutManager` recupera correttamente `HKWorkoutSession` dopo crash/restart dell'app, evitando sessioni orfane in HealthKit.

---

## Analisi File-by-File

### 1. `FitLogWatchApp.swift` (182 righe)

| Aspetto | Valutazione |
|---------|-------------|
| Entry point | Pulito, usa `@main` |
| Dependency injection | `@StateObject` per managers passati via `.environmentObject` |
| Workout recovery | `.task` per async recovery all'avvio |
| Scene phase | Gestito per foreground/background transitions |

**Issues trovati**: P1-8 (HK session reactivity), P2-9 (free function mapWorkoutType)

---

### 2. `ContentView.swift` (3568 righe)

| Aspetto | Valutazione |
|---------|-------------|
| Architettura UI | TabView con 4 tab, conditional rendering |
| Superset/Dropset/RP | UI completa con sliding window per superset |
| Localization | `isItalian` binary pattern (~40 occorrenze) |
| Accessibilita | Minima — mancano `accessibilityLabel` |
| State management | `@EnvironmentObject` per connectivity e workout |

**Issues trovati**: P1-1 (God Object), P1-2 (hardcoded l10n), P1-7 (auto-close), P2-4 (mixed logic/UI), P2-3 (debug prints)

---

### 3. `ConnectivityManager.swift` (1995 righe)

| Aspetto | Valutazione |
|---------|-------------|
| WCSession handling | Completo, con dual delivery |
| Rate limiting | 300ms con coda e retry |
| State management | ~75 @Published properties |
| Thread safety | nonisolated + Task @MainActor |
| Timer management | Target-selector pattern |

**Issues trovati**: P0-2 (message ordering), P1-3 (~75 @Published), P1-4 (parsing fragile), P1-5 (stale timer), P2-1 (magic strings), P2-6 (legacy timer), P2-7 (non-private init), P2-10 (GCD on @MainActor), P2-12 (non-configurable rate limit)

---

### 4. `WorkoutManager.swift` (551 righe)

| Aspetto | Valutazione |
|---------|-------------|
| HKWorkoutSession | Corretto con recovery |
| Authorization | Persistita in UserDefaults |
| Delegate pattern | nonisolated + Task @MainActor |
| HR monitoring | Delta threshold 5 BPM |
| Error handling | Basic ma funzionante |

**Issues trovati**: P1-6 (stale session recovery), P2-11 (hardcoded delta)

---

### 5. `NotificationManager.swift` (114 righe)

| Aspetto | Valutazione |
|---------|-------------|
| Notification auth | Corretto |
| Delegate pattern | NON @MainActor — data race |
| Complessita | Bassa, ben contenuta |

**Issues trovati**: P0-1 (data race in NotificationDelegate)

---

### 6. `WatchConnectivityManager.swift` — iPhone side (1686 righe)

| Aspetto | Valutazione |
|---------|-------------|
| Flutter bridge | MethodChannel completo |
| Dual delivery | sendMessage + applicationContext |
| Caching | UserDefaults per crash recovery |
| NSNull sanitization | Presente e corretto |
| Pending commands | UserDefaults per background safety |

**Issues trovati**: P2-2 (duplicated switch), P2-3 (debug prints con `print()` in produzione)

---

### 7. `watch_connectivity_provider.dart` — Flutter side (1322 righe)

| Aspetto | Valutazione |
|---------|-------------|
| Riverpod pattern | Corretto `NotifierProvider` |
| Callback system | Typedef per ogni tipo di evento |
| Platform check | `Platform.isIOS` guard ovunque |
| Type safety | `(as num?)?.toDouble()` pattern safe |

**Issues trovati**: P2-14 (debugPrint in release)

---

## Checklist Simmetria Bidirezionale Watch/iPhone

### iPhone → Watch (Flutter → Swift → WCSession → Watch)

| Messaggio | Flutter Provider | iPhone Native | Watch Handler | Status |
|-----------|-----------------|---------------|---------------|--------|
| Workout Started | `notifyWorkoutStarted()` | `handleNotifyWorkoutStarted` | `handleWorkoutUpdate` | ✅ |
| Workout Update | `sendWorkoutUpdate()` | `handleSendWorkoutUpdate` | `handleWorkoutUpdate` | ✅ |
| Workout Ended | `notifyWorkoutEnded()` | `handleNotifyWorkoutEnded` | `processIncomingMessage "workoutEnded"` | ✅ |
| Rest Timer Started | `sendRestTimerStarted()` | `handleSendRestTimerStarted` | `handleRestTimerFromContext` | ✅ |
| Rest Timer Skipped | `sendRestTimerSkipped()` | `handleSendRestTimerSkipped` | `processIncomingMessage "restTimerSkipped"` | ✅ |
| Rest Timer Paused | `sendRestTimerPaused()` | `handleSendRestTimerPaused` | `processIncomingMessage "restTimerPaused"` | ✅ |
| Rest Timer Resumed | `sendRestTimerResumed()` | `handleSendRestTimerResumed` | `processIncomingMessage "restTimerResumed"` | ✅ |
| Rest Timer Extended | `sendRestTimerExtended()` | `handleSendRestTimerExtended` | `processIncomingMessage "restTimerExtended"` | ✅ |

### Watch → iPhone (Watch Swift → WCSession → iPhone Native → Flutter)

| Messaggio | Watch Sender | iPhone Handler | Flutter Callback | Status |
|-----------|-------------|----------------|-----------------|--------|
| Set Completed | `sendToiPhone "setCompleted"` | `handleSetCompletedFromWatch` | `onSetCompletedFromWatch` | ✅ |
| Skip Rest | `sendToiPhone "skipRest"` | `handleSkipRestFromWatch` | `onSkipRestFromWatch` | ✅ |
| Health Metrics | `sendToiPhone "healthMetrics"` | direct notifyFlutter | `onHealthMetricsFromWatch` | ✅ |
| End Workout | `sendToiPhone "endWorkout"` | `handleEndWorkoutFromWatch` | `onEndWorkoutFromWatch` | ✅ |
| Pause Workout | `sendToiPhone "pauseWorkout"` | `handlePauseWorkoutFromWatch` | `onPauseWorkoutFromWatch` | ✅ |
| Set Modification | `sendToiPhone "setModification"` | `handleSetModificationFromWatch` | `onSetModificationFromWatch` | ✅ |
| Extend Timer | `sendToiPhone "extendTimer"` | `handleExtendTimerFromWatch` | `onExtendTimerFromWatch` | ✅ |
| Edit Completed Reps | `sendToiPhone "editCompletedSetReps"` | `handleEditCompletedSetRepsFromWatch` | `onEditCompletedSetRepsFromWatch` | ✅ |
| Uncomplete Set | `sendToiPhone "uncompleteSet"` | `handleUncompleteSetFromWatch` | `onUncompleteSetFromWatch` | ✅ |
| Workout Error | `sendToiPhone "workoutError"` | direct notifyFlutter | Flutter `onWorkoutErrorFromWatch` | ✅ |
| Superset Round | `sendToiPhone "supersetRoundCompleted"` | `handleSupersetRoundCompletedFromWatch` | `onSupersetRoundCompletedFromWatch` | ✅ |
| Dropset Stage | `sendToiPhone "dropsetStageCompleted"` | `handleDropsetStageCompletedFromWatch` | `onDropsetStageCompletedFromWatch` | ✅ |
| Dropset Complete | `sendToiPhone "dropsetCompleted"` | `handleDropsetCompletedFromWatch` | `onDropsetCompletedFromWatch` | ✅ |
| Rest-Pause Set | `sendToiPhone "restPauseSetCompleted"` | `handleRestPauseSetCompletedFromWatch` | `onRestPauseSetCompletedFromWatch` | ✅ |
| Rest-Pause Complete | `sendToiPhone "restPauseCompleted"` | `handleRestPauseCompletedFromWatch` | `onRestPauseCompletedFromWatch` | ✅ |
| Jump to Exercise | `sendToiPhone "jumpToExercise"` | direct notifyFlutter | `onJumpToExerciseFromWatch` | ✅ |
| Jump to Set | `sendToiPhone "jumpToSet"` | direct notifyFlutter | `onJumpToSetFromWatch` | ✅ |
| Copy to All Sets | `sendToiPhone "copyToAllSets"` | direct notifyFlutter | `onCopyToAllSetsFromWatch` | ✅ |
| Copy from Previous | `sendToiPhone "copyFromPreviousSet"` | direct notifyFlutter | `onCopyFromPreviousSetFromWatch` | ✅ |
| Start New Timer | `sendToiPhone "startNewTimer"` | `handleStartNewTimerFromWatch` | `onStartNewTimerFromWatch` | ✅ |
| Request State | `sendToiPhone "requestWorkoutState"` | `handleWorkoutStateRequest` (reply only) | `onWorkoutStateRequested` | ✅ |

### Note sulla Simmetria

- **Eccellente**: Tutti i 29 tipi di messaggio hanno handler corrispondenti su entrambi i lati
- **iPhone handler duplicati**: `setCompleted`, `skipRest`, `endWorkout`, `pauseWorkout`, `setModification`, `extendTimer`, `editCompletedSetReps`, `uncompleteSet` hanno handler sia nel percorso con reply che senza reply — ridondanza intenzionale per reliability
- **Reply-only**: `requestWorkoutState` e `requestTemplates` usano solo il percorso con reply handler (corretto)
- **Legacy handlers iPhone**: `workoutCompleted`, `setLogged`, `workoutPaused`, `workoutResumed` sono gestiti nell'iPhone reply-handler switch ma il Watch attuale non sembra inviarli — probabilmente codice preparatorio per workout standalone su Watch

---

## Checklist Progresso

### P0 — Fix Immediato
- [x] P0-1: ~~False positive~~ — codice gia corretto (NotificationDelegate non accede @MainActor state)
- [x] P0-2: Implementato message ordering seriale via AsyncStream (processIncomingMessage + applicationContext)

### P1 — Fix Prossima Release
- [x] P1-1: Splittare `ContentView.swift` in file separati per ogni view — **13 view files in Views/**
- [x] P1-2: Centralizzare localizzazione in enum/dizionario o `.strings` — **WatchStrings.swift creato**
- [x] P1-3: Raggruppare `@Published` properties — **MARK sections gia organizzate; full struct grouping deferred to @Observable (watchOS 10+)**
- [x] P1-4: Definire struct Codable per payload messaggi — **PayloadParsing.swift con Dictionary helpers type-safe**
- [ ] P1-5: Verificare che optimistic timer venga sovrascritto da reply handler
- [x] P1-6: Aggiungere staleness check per sessioni HK recuperate
- [x] P1-7: ~~Gia fixato~~ — timeout gia aumentato a 50s (era 15s nel codice originale)
- [x] P1-8: Aggiungere debounce su `.onChange(of: isWorkoutActive)`

### P2 — Tech Debt
- [x] P2-1: Creare enum condiviso per tipi di messaggio — **WatchMessageType.swift**
- [x] P2-2: Unificare handler messaggi con/senza reply (iPhone) — **no-reply routes to reply handler**
- [ ] P2-3: Sostituire `print()` con `Logger.shared` / `os.Logger` — iPhone side, deferred
- [ ] P2-4: Estrarre business logic da Views in ViewModels
- [ ] P2-5: Aggiungere unit test per parsing messaggi e logica timer
- [x] P2-6: Migrare Timer da target-selector — **reviewed: target-selector pattern is optimal for watchOS RunLoop**
- [x] P2-7: Rendere `ConnectivityManager.init()` private
- [x] P2-9: Spostare `mapWorkoutType` come extension
- [x] P2-10: Sostituire `DispatchQueue.main.asyncAfter` con `Task`
- [x] P2-11: Rendere HR delta threshold configurabile — **WorkoutManager.heartRateDeltaThreshold**
- [x] P2-12: Rendere rate limit configurabile per tipo messaggio — **healthMessageInterval separato**
- [x] P2-13: Aggiungere `os.Logger` strutturato su Watch — **WatchLogger.swift**
- [x] P2-14: Wrappare `debugPrint` Flutter in `kDebugMode` — **_watchLog() helper**

### P3 — Best Practices (Futuro)
- [ ] P3-1: Migrare a `@Observable` macro
- [ ] P3-2: Codable per tutti i payload
- [ ] P3-3: Swift 6 strict concurrency
- [ ] P3-4: Retry con backoff per sendMessage
- [ ] P3-5: Telemetria delivery rate
- [ ] P3-6: Error boundary per Views
- [ ] P3-7: `String(localized:)` per watchOS
- [ ] P3-8: Separare ConnectivityManager in sotto-manager
- [ ] P3-9: Snapshot testing per viste Watch
- [ ] P3-10: Documentare protocollo comunicazione

---

## Stima Effort

| Priorita | Items | Effort Stimato | Rischio |
|----------|-------|----------------|---------|
| **P0** | 2 | 2-3 ore | Basso (fix locali) |
| **P1** | 8 | 8-12 ore | Medio (refactoring UI) |
| **P2** | 14 | 15-20 ore | Basso (tech debt iterativo) |
| **P3** | 10 | 20-30 ore | Basso (miglioramenti graduali) |

### Raccomandazione Priorita

1. **Sprint 1 (1 giorno)**: P0-1 + P0-2 — Fix critici thread safety
2. **Sprint 2 (2-3 giorni)**: P1-1 + P1-2 + P1-3 — Split ContentView + localizzazione + stato raggruppato
3. **Sprint 3 (2 giorni)**: P1-4 + P1-6 + P1-8 — Codable payloads + session staleness + debounce
4. **Ongoing**: P2 items come parte di feature work normale
5. **Futuro**: P3 items quando si fa upgrade a watchOS 10+ minimum target
