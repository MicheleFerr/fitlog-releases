# Live Activity Audit - 20 Febbraio 2026

## Overview

Audit completo del flusso Live Activities eseguito da un team di 7 agenti specializzati.
**Problema principale**: Il pulsante "+15s" sulla Live Activity (lock screen/Dynamic Island) non funziona.

## Team

| # | Agente | Ruolo |
|---|--------|-------|
| 1 | `flutter-analyst` | Architettura Flutter-side (Riverpod, Provider, Platform Channel) |
| 2 | `ios-analyst` | iOS nativo (ActivityKit, AppIntents, Widget Extension) |
| 3 | `timer-analyst` | Sincronizzazione Timer <-> Live Activity |
| 4 | `debugger` | Race conditions, edge cases, bug hunting |
| 5 | `perf-analyst` | Performance canale Flutter-iOS, rebuild, throttling |
| 6 | `code-reviewer` | Review end-to-end coerenza globale |
| 7 | `researcher` | Documentazione Apple, soluzioni community |

---

## ROOT CAUSE ARCHITETTURALE

Gli AppIntents girano nel **processo widget extension**, NON nell'app principale. Usano **Darwin notifications** per comunicare con Flutter, ma queste vengono **PERSE quando l'app e' sospesa** (caso tipico da lock screen). La soluzione e' conformare gli intents al protocollo **`LiveActivityIntent`**.

```
ATTUALE (fragile):
  Button tap -> AppIntent.perform() [widget extension process]
    -> Darwin Notification -> App riceve (FORSE) -> Flutter channel -> Update stato

CORRETTO (deterministico):
  Button tap -> LiveActivityIntent.perform() [MAIN APP process]
    -> Accesso diretto stato app -> Activity.update()
```

---

## Architettura: Due Sistemi LA Paralleli

| Sistema | Target | Attributes | Intent +time |
|---------|--------|-----------|--------------|
| **A** (legacy) | iOS 16.1+ | `GymBroTimerAttributes` | `AddTimeIntent` (+15s) |
| **B** (nuovo) | iOS 17.0+ | `WorkoutSessionAttributes` | `WorkoutAddTimeIntent` (+15s) |

Durante un workout attivo, Flutter avvia il Sistema B. Il Sistema A viene usato solo se B non e' attivo (guard in `unified_timer_provider.dart:1892`).

---

## Flusso Completo "+15s" (Stato Attuale)

```
Utente preme "+15s" sulla LA (app in foreground)
  |
  v
iOS: WorkoutAddTimeIntent.perform() [widget extension process]
  |-- guard mode == .rest && restEndDate != nil
  |   |-- FAIL -> return .result() silenzioso
  |   +-- OK -> newEndDate = currentEndDate + 15s
  |             activity.update(updatedState)  <-- activity.update() #1
  |             saveEventToUserDefaults("add_time", addedSeconds: 15)
  |             CFNotificationCenter.post("com.gymbro.workoutSession.event")
  |
  v
iOS Runner: WorkoutSessionManager.handleDarwinNotification()
  |-- legge evento da UserDefaults
  |-- CANCELLA evento da UserDefaults  <-- BUG-2: cancella PRIMA del processing
  |-- methodChannel.invokeMethod("onWorkoutSessionEvent", eventData)
  |
  v
Flutter: WorkoutSessionLAService._handleMethodCall()
  |-- WorkoutSessionEvent.fromMap(data)
  |-- event.addedSeconds = data['addedSeconds'] as int?  <-- potrebbe essere null
  |-- _eventController.add(event)
  |
  v
Flutter: WorkoutSessionLANotifier._handleLiveActivityEvent(event)
  |-- addedSeconds = event.addedSeconds ?? 15  <-- fallback 15
  |-- workoutNotifier.extendRestTimerFromLiveActivity(addedSeconds)  <-- Future non awaited (BUG-6)
  |
  v
Flutter: UnifiedTimerProvider.addTime(seconds, fromLiveActivity: true)
  |-- stato Flutter aggiornato (remaining + total + endTime)
  |-- unawaited(syncRestEndTime(newEndTime))  <-- activity.update() #2 (BUG-3: doppio update)


Utente preme "+15s" sulla LA (app SOSPESA)
  |
  v
iOS: WorkoutAddTimeIntent.perform() -> salva in UserDefaults + Darwin notification
  |-- Darwin notification PERSA (app sospesa, by design iOS)  <-- ARCH-2
  |
  v
App riprende -> checkPendingEventsOnResume()
  |-- await _service.checkPendingEvents()
  |-- RISULTATO SCARTATO  <-- ARCH-3: evento mai processato!
```

---

## Bug Trovati (12 totali)

### P0 - Architettura (Fix una volta, risolve multipli bug)

#### ARCH-1: AppIntents non conformano a `LiveActivityIntent`

- **File**: `ios/GymBroTimerWidget/WorkoutSessionIntents.swift`
- **File**: `ios/GymBroTimerWidget/AppIntent.swift`
- **Problema**: `perform()` gira nel widget extension process, non nell'app principale. Non ha accesso allo stato dell'app.
- **Fix**: Conformare a `LiveActivityIntent` protocol. Questo FORZA l'esecuzione nel main app process.
- **Fonte**: [Zach Waugh](https://zachwaugh.com/posts/forcing-appintent-to-run-in-main-app-process)

```swift
// PRIMA (sbagliato)
struct WorkoutAddTimeIntent: AppIntent { ... }

// DOPO (corretto)
struct WorkoutAddTimeIntent: LiveActivityIntent { ... }
```

#### ARCH-2: Darwin notification persa con app sospesa

- **File**: `ios/Runner/Managers/WorkoutSessionManager.swift:801`
- **Problema**: `CFNotificationCenter` NON risveglia l'app. Notifica persa se app sospesa.
- **Fix**: Con `LiveActivityIntent` (ARCH-1) questo non serve piu' - perform() gira nel main app process. Mantenere come fallback.
- **Fonte**: [Apple Developer Forums](https://developer.apple.com/forums/thread/769398)

#### ARCH-3: `checkPendingEvents()` risultato SCARTATO

- **File**: `lib/features/workout/presentation/providers/workout_session_la_provider.dart:464`
- **Problema**: Il risultato di `checkPendingEvents()` viene ignorato. L'evento non entra mai nello stream di processing.
- **Fix**: Processare il risultato e aggiungerlo allo stream `_eventController`.

```dart
// PRIMA (bug)
await _service.checkPendingEvents();

// DOPO (fix)
final pendingEvent = await _service.checkPendingEvents();
if (pendingEvent != null) {
  _handleLiveActivityEvent(WorkoutSessionEvent.fromMap(pendingEvent));
}
```

---

### P1 - Bug Critici

#### BUG-1: `_isTransitioningToExercise` non resettato su errore

- **File**: `lib/features/workout/presentation/providers/workout_session_la_provider.dart:396-438`
- **Problema**: Se `transitionToExercise()` fallisce con eccezione, il flag `_isTransitioningToExercise` resta `true`. Tutti i timer successivi vengono ignorati.
- **Fix**: Wrappare in try-finally.

```dart
// PRIMA (bug)
_isTransitioningToExercise = true;
// ... codice che puo' fallire ...
_isTransitioningToExercise = false;

// DOPO (fix)
_isTransitioningToExercise = true;
try {
  // ... codice che puo' fallire ...
} finally {
  _isTransitioningToExercise = false;
}
```

#### BUG-2: Evento cancellato da UserDefaults PRIMA del processing Flutter

- **File**: `ios/Runner/Managers/WorkoutSessionManager.swift:844`
- **Problema**: `handleDarwinNotification` legge l'evento da UserDefaults e lo cancella PRIMA di inviarlo a Flutter via MethodChannel. Se il channel call fallisce, l'evento e' perso.
- **Fix**: Cancellare DOPO la conferma di ricezione da Flutter, oppure usare un meccanismo di acknowledge.

#### BUG-3: Doppio `activity.update()` senza throttle

- **File**: `ios/GymBroTimerWidget/WorkoutSessionIntents.swift` + `ios/Runner/Managers/WorkoutSessionManager.swift`
- **Problema**: AppIntent chiama `activity.update()` + Flutter via `syncRestEndTime` chiama un altro `activity.update()`. ActivityKit ha rate limit ~1 update/sec.
- **Fix**: Skip `syncRestEndTime` quando `fromLiveActivity: true` (l'AppIntent ha gia' aggiornato la LA).

```dart
// unified_timer_provider.dart:878
if (!fromLiveActivity) {
  unawaited(
    ref.read(workoutSessionLAServiceProvider).syncRestEndTime(newEndTime),
  );
}
```

#### BUG-4: Intent struct non `public` - non funziona in release/TestFlight

- **File**: `ios/GymBroTimerWidget/WorkoutSessionIntents.swift`
- **Problema**: Le struct intent funzionano in debug ma potrebbero non funzionare in release mode se non marcate `public`.
- **Fix**: Aggiungere `public` modifier.
- **Fonte**: [Apple Developer Forums](https://developer.apple.com/forums/thread/731852)

---

### P2 - Bug Medi

#### BUG-5: `restTotalSeconds` calcolato male dopo multipli +15s

- **File**: `ios/Runner/Managers/WorkoutSessionManager.swift:541`
- **Problema**: Quando si aggiunge tempo multiplo volte, `restTotalSeconds` non viene ricalcolato correttamente.

#### BUG-6: `extendRestTimerFromLiveActivity` e' Future ma non awaited

- **File**: `lib/features/workout/presentation/providers/workout_session_la_provider.dart:494`
- **Problema**: La funzione e' `Future<void>` ma il chiamante non usa `await`. Potenziale race condition se il provider si dispose prima del completamento.

#### BUG-7: Nessun debounce su tap rapidi pulsante LA

- **File**: `ios/GymBroTimerWidget/WorkoutSessionIntents.swift`
- **Problema**: Se l'utente preme "+15s" due volte in <500ms, uno degli update puo' essere perso per rate limit ActivityKit.

#### BUG-8: `ref.listen(unifiedTimerProvider)` senza `.select()` - 60 callback/min inutili

- **File**: `lib/features/workout/presentation/providers/workout_session_la_provider.dart`
- **Problema**: Ogni tick del timer (ogni secondo) scatena la callback, anche se la logica fa early return. Overhead inutile.
- **Fix**: Usare `.select()` per filtrare solo cambiamenti rilevanti.

---

### P3 - Bug Minori

#### BUG-9: Label "30 seconds" ma codice aggiunge 15

- **File**: `ios/GymBroTimerWidget/WorkoutSessionIntents.swift:194`
- **Nota**: Il commit recente ha cambiato da 30s a 15s nei pulsanti. Verificare coerenza label/codice.

#### BUG-10: `unawaited(syncRestEndTime)` maschera errori

- **File**: `lib/features/workout/data/services/unified_timer_provider.dart:878`
- **Problema**: Errori nel sync vengono persi silenziosamente.

#### BUG-11: StreamController `_eventController` mai disposed

- **File**: `lib/features/workout/data/services/workout_session_la_service.dart`
- **Problema**: `dispose()` non e' chiamato da nessun provider `ref.onDispose()`.

---

## Findings dalla Ricerca Community

1. **`LiveActivityIntent` protocol** forza esecuzione nel main app process (CRITICO)
2. **Intent deve essere `public`** per funzionare in release mode
3. **Target membership** richiesta in entrambi i target (app + widget extension)
4. **Darwin notifications** NON funzionano con app sospesa (by design Apple)
5. **Due Activity types** non sono un problema di per se (Apple li supporta)
6. **iOS 18 bug** possibile dove `perform()` non viene chiamato (monitorare)
7. **Widget/App non sincronizzano stato** automaticamente - usare App Groups

---

## Piano di Implementazione

### Fase 1 (P0): Fix Architetturale
1. Conformare AppIntents a `LiveActivityIntent`
2. Aggiungere `public` modifier agli intent struct
3. Fix `checkPendingEvents` - processare il risultato
4. Verificare target membership in Xcode

### Fase 2 (P1): Fix Bug Critici
5. Try-finally su `_isTransitioningToExercise`
6. Cancellare evento UserDefaults DOPO processing
7. Skip `syncRestEndTime` quando `fromLiveActivity: true`

### Fase 3 (P2): Hardening
8. Fix calcolo `restTotalSeconds`
9. Await `extendRestTimerFromLiveActivity`
10. Debounce su tap rapidi LA
11. `.select()` su `ref.listen` timer

### Fase 4 (P3): Polish
12. Verificare coerenza label/codice secondi
13. Error handling su `syncRestEndTime`
14. Dispose `_eventController`
