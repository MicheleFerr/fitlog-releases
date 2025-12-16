# Workout History Dual-Write Sync Design

**Created**: 2025-11-26
**Status**: Implementation
**Complexity**: MEDIUM
**Estimated Time**: ~2h

---

## Problem Statement

La schermata cronologia non mostra i workout salvati perché:
- **WorkoutProvider** salva in box `'workouts'` con chiave `{userId}_{workoutId}`
- **WorkoutHistoryRepositoryEnhanced** legge da box `'workout_history_enhanced'` con chiave `workout_{workoutId}`

**Root Cause**: Due box separati, nessun sync tra loro.

---

## Solution: Dual-Write Sincrono

### Write Path (Approvato)

```
User completa workout
        ↓
WorkoutProvider.completeWorkout()
        ↓
    ┌───┴───┐
    ↓       ↓
 [workouts] [workout_history_enhanced]  ← DUAL-WRITE SINCRONO
    ↓       ↓
    └───┬───┘
        ↓
   SyncQueue.add('create')
        ↓
   (Flush dopo 30min / background / logout)
        ↓
   Firestore (eventualmente)
```

### Read Path (Approvato)

- **History Screen**: Legge SOLO da `workout_history_enhanced` (MASTER)
- **Altri usi**: Leggono da `workouts` (SLAVE)
- **Nessuna lettura diretta da Firestore** in condizioni normali

### Update/Delete Path (Approvato)

1. Modifica su `workout_history_enhanced` (MASTER)
2. Propaga modifica a `workouts` (SLAVE)
3. Accoda in SyncQueue per Firestore
4. Conflict resolution: **Last-Write-Wins** (LWW) con timestamp

### Pull-to-Refresh (Approvato)

- Rate limited: 1 ogni ora
- **Silent fail**: Se in cooldown, non mostra nessun feedback
- Sincronizza Firestore → `workout_history_enhanced`

---

## Research Validation

### Pattern Validati:

| Pattern | Fonte |
|---------|-------|
| Dual-write sincrono | [Transactional Outbox Pattern](https://microservices.io/patterns/data/transactional-outbox.html) |
| Last-Write-Wins | Standard conflict resolution per offline-first |
| Constructor injection | [Riverpod Best Practices](https://github.com/rrousselGit/riverpod/discussions/2662) |
| putAll() per atomicità | [Hive Best Practices](https://climbtheladder.com/10-flutter-hive-best-practices/) |

---

## Files da Modificare

### 1. `lib/core/data/hive_box_names.dart`

```dart
// Aggiungere nella sezione HISTORY FEATURE:
/// Enhanced workout history box (MASTER for history reads)
static const String workoutHistoryEnhanced = 'workout_history_enhanced';
```

### 2. `lib/features/history/data/repositories/workout_history_repository_enhanced.dart`

```dart
/// Salvataggio diretto per dual-write (chiamato da WorkoutProvider)
Future<void> saveWorkoutDirectly(WorkoutHistoryDetail workout) async {
  await _ensureInitialized();
  await _saveWorkoutLocally(workout);
  await _addToSyncQueue('create', workout);
}
```

### 3. `lib/features/history/presentation/providers/workout_history_provider.dart` (nuovo)

```dart
final workoutHistoryRepositoryEnhancedProvider = Provider<WorkoutHistoryRepositoryEnhanced>((ref) {
  final boxManager = ref.watch(hiveBoxManagerEnhancedProvider);
  return WorkoutHistoryRepositoryEnhanced(boxManager: boxManager);
});
```

### 4. `lib/features/workout/presentation/providers/workout_provider.dart`

Nella funzione `_saveCompletedWorkoutToFirestore()`, dopo il salvataggio in Hive `workouts`:

```dart
// DUAL-WRITE: Salva anche in workout_history_enhanced per visibilità immediata
try {
  final historyRepo = ref.read(workoutHistoryRepositoryEnhancedProvider);
  await historyRepo.saveWorkoutDirectly(workoutHistoryDetail);

  if (kDebugMode) {
    debugLog(LogCategory.workout, '✅ [WorkoutProvider] Dual-write to workout_history_enhanced complete');
  }
} catch (historyError) {
  if (kDebugMode) {
    debugLog(LogCategory.workout, '⚠️ [WorkoutProvider] Dual-write failed: $historyError');
  }
  // Non-critical: workout già salvato in box principale
}
```

---

## Checklist Implementazione

- [ ] Aggiungere costante `workoutHistoryEnhanced` in `hive_box_names.dart`
- [ ] Aggiungere metodo `saveWorkoutDirectly()` in `WorkoutHistoryRepositoryEnhanced`
- [ ] Creare provider per `WorkoutHistoryRepositoryEnhanced`
- [ ] Implementare dual-write in `WorkoutProvider._saveCompletedWorkoutToFirestore()`
- [ ] Test manuale: completare workout → verificare visibilità in cronologia

---

## Note

- `workout_history_enhanced` è MASTER per letture cronologia
- `workouts` è SLAVE, mantenuto per compatibilità con altri consumer
- Firestore sync è lazy (30min / background / logout)
- Pull-to-refresh ha rate limiting 1/ora con silent fail
