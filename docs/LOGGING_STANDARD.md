# 📋 Logging Standard - FitLog Pro

> **Standard obbligatorio** per tutti i log nell'applicazione.
> Vedere `docs/plans/2025-11-27-unified-logger-design.md` per dettagli architetturali.

---

## Quick Start

```dart
import 'package:gymbro_flutter_new/core/logging/unified_logger.dart';

// Debug (solo in debug mode)
UnifiedLogger.debug('Widget rebuilt', tag: LogTag.ui);

// Info (eventi normali)
UnifiedLogger.info('Workout started', tag: LogTag.workout, data: {'templateId': 't123'});

// Warning (potenziali problemi)
UnifiedLogger.warning('Slow query', tag: LogTag.performance, data: {'ms': 800});

// Error (errori da gestire)
UnifiedLogger.error('API failed', error: e, stackTrace: st, tag: LogTag.http);

// Audit (GDPR - azioni utente tracciabili)
UnifiedLogger.audit('workout_deleted', data: {'workoutId': 'w123'});

// Secure (dati sensibili - masking automatico)
UnifiedLogger.secure('Login attempt', email: email, userId: id);
```

---

## Regole (OBBLIGATORIE)

| Regola | Descrizione |
|--------|-------------|
| ✅ **Usa `UnifiedLogger`** | Unico logger permesso |
| ❌ **MAI `print()`** | Bloccato da pre-commit |
| ❌ **MAI `debugPrint()`** | Usa `UnifiedLogger.debug()` |
| ❌ **MAI creare nuovi logger** | Bloccato da pre-commit |
| ✅ **Specifica sempre `tag`** | Per filtering efficace |
| ✅ **Usa `.secure()`** | Per email, userId, dati sensibili |
| ✅ **Usa `.audit()`** | Per azioni utente GDPR-relevant |

---

## Tags Disponibili

### Per Layer

```dart
LogTag.domain        // Business logic
LogTag.data          // Repository, datasource
LogTag.presentation  // UI, widgets (alias: LogTag.ui)
```

### Per Feature

```dart
LogTag.workout       // Workout feature
LogTag.timer         // Timer, rest periods
LogTag.auth          // Authentication
LogTag.sync          // Firebase sync
LogTag.analytics     // Analytics feature
LogTag.health        // HealthKit/Health Connect
```

### Tecnici

```dart
LogTag.http          // HTTP requests/responses
LogTag.cache         // Caching operations
LogTag.performance   // Performance metrics
LogTag.audit         // GDPR audit trail
```

---

## Esempi per Caso d'Uso

### Logging in un Provider

```dart
class WorkoutNotifier extends StateNotifier<WorkoutState> {
  Future<void> startWorkout(String templateId) async {
    UnifiedLogger.info(
      'Starting workout',
      tag: LogTag.workout,
      data: {'templateId': templateId},
    );

    try {
      // ... logic
    } catch (e, st) {
      UnifiedLogger.error(
        'Failed to start workout',
        error: e,
        stackTrace: st,
        tag: LogTag.workout,
      );
    }
  }
}
```

### Logging in un Repository

```dart
class WorkoutRepositoryImpl implements WorkoutRepository {
  @override
  Future<void> save(Workout workout) async {
    UnifiedLogger.debug(
      'Saving workout to Firestore',
      tag: LogTag.data,
      data: {'workoutId': workout.id},
    );

    // ... save logic

    UnifiedLogger.audit('workout_saved', data: {'workoutId': workout.id});
  }
}
```

### Logging con Dati Sensibili

```dart
// ❌ SBAGLIATO - espone email
UnifiedLogger.info('User logged in', data: {'email': user.email});

// ✅ CORRETTO - masking automatico
UnifiedLogger.secure('User logged in', email: user.email, userId: user.id);
// Output: "User logged in" {email: "m***@g***.com", userId: "use***123"}
```

### Performance Logging

```dart
final stopwatch = Stopwatch()..start();
await heavyOperation();
stopwatch.stop();

if (stopwatch.elapsedMilliseconds > 500) {
  UnifiedLogger.warning(
    'Slow operation detected',
    tag: LogTag.performance,
    data: {
      'operation': 'heavyOperation',
      'ms': stopwatch.elapsedMilliseconds,
    },
  );
}
```

---

## Livelli di Log

| Livello | Metodo | Quando usare | In Release |
|---------|--------|--------------|------------|
| Debug | `.debug()` | Sviluppo, verbose | ❌ No |
| Info | `.info()` | Eventi normali | Configurabile |
| Warning | `.warning()` | Potenziali problemi | ✅ Sì |
| Error | `.error()` | Errori da gestire | ✅ Sì |
| Audit | `.audit()` | Azioni utente (GDPR) | ✅ Sì |
| Secure | `.secure()` | Dati PII | ✅ Sì (masked) |

---

## Filtering dei Log

### In Debug Screen

```dart
// Tutti i log
final allLogs = await UnifiedLogger.getLogs();

// Solo errori
final errors = await UnifiedLogger.getLogs(minLevel: LogLevel.error);

// Solo workout
final workoutLogs = await UnifiedLogger.getLogs(tag: LogTag.workout);

// Errori workout dell'ultima ora
final recentErrors = await UnifiedLogger.getLogs(
  tag: LogTag.workout,
  minLevel: LogLevel.error,
  since: DateTime.now().subtract(Duration(hours: 1)),
);
```

---

## Bypass (Solo se Necessario)

Se hai un caso eccezionale dove devi usare print:

```dart
print('Debug message'); // ignore-logger-check
```

⚠️ **Usa con estrema parsimonia** - il pre-commit mostrerà warning ma non bloccherà.

---

## Checklist per Code Review

- [ ] Nessun `print()` o `debugPrint()`
- [ ] Tutti i log usano `UnifiedLogger`
- [ ] Tag specificato per ogni log
- [ ] Dati sensibili passati via `.secure()`
- [ ] Azioni utente tracciate via `.audit()`
- [ ] Error logging include `error` e `stackTrace`
