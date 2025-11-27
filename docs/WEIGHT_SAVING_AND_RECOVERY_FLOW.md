# Flusso Salvataggio e Recupero Pesi - GymBro Flutter

## Overview

Il sistema GymBro Flutter implementa un **sistema intelligente di salvataggio e recupero pesi** che permette agli utenti di:
1. Salvare i pesi dei set completati quando finisce un workout
2. Recuperare automaticamente i pesi dai workout precedenti quando inizia uno nuovo
3. Applicare moltiplicatori intelligenti ai pesi per la progressione
4. Mostrare cronologia pesi e suggerimenti

---

## PARTE 1: FLUSSO DI SALVATAGGIO DEI PESI

### 1.1 - Workflow di Salvataggio (WorkoutProvider → Repository → Hive)

```
┌─────────────────────────────────────────────────────────────────┐
│ FASE 1: WORKOUT COMPLETION (WorkoutScreen)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. User preme "Complete Workout" button                         │
│  2. CurrentWorkoutNotifier.completeWorkout() viene chiamato      │
│  3. Validazione dello stato del workout                          │
│                                                                   │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ FASE 2: DOMAIN LAYER (CompleteWorkoutUseCase)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  File: lib/features/workout/domain/usecases/                    │
│        complete_workout_usecase.dart                             │
│                                                                   │
│  - _validateWorkoutCompletion(): Verifica stato                 │
│  - _prepareWorkoutForCompletion(): Prepara i dati               │
│  - _calculateWorkoutStats(): Calcola statistiche                │
│  - _checkAchievements(): Verifica achievement                   │
│                                                                   │
│  Output: CompleteWorkoutResult con:                              │
│  ├─ workoutId (string)                                           │
│  ├─ completedWorkout (Workout entity)                            │
│  ├─ activityIds (List<String>)                                  │
│  └─ stats (WorkoutStats)                                        │
│                                                                   │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ FASE 3: REPOSITORY LAYER (HybridWorkoutRepositoryImpl)          │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  File: lib/features/workout/data/repositories/                  │
│        hybrid_workout_repository_impl.dart                       │
│                                                                   │
│  saveWorkout(workout: Workout)                                   │
│  ├─ Converte Workout → WorkoutModel (serializable)              │
│  ├─ SALVA LOCALMENTE: _localDataSource.saveWorkout()            │
│  │  └─ Scrive in Hive (istantaneo)                              │
│  │     Key: "${userId}_{workoutId}"                             │
│  │     Value: WorkoutModel.toJson()                              │
│  │                                                                │
│  └─ SYNC ASINCRONO (se premium/admin):                          │
│     _syncToCloudInBackground()                                   │
│     └─ Scrive su Firestore (dopo locale)                        │
│        Path: users/{userId}/workouts/{workoutId}                │
│                                                                   │
│  ✅ Return: Either<Failure, String> con workoutId              │
│                                                                   │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ FASE 4: DATI STORAGE (Hive & Firestore)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  HIVE LOCAL STORAGE:                                             │
│  ├─ Box: 'workouts'                                              │
│  ├─ Key: "user123_workout456" (userId_workoutId)               │
│  └─ Value: WorkoutModel JSON con:                                │
│     ├─ id, name, status (completed)                             │
│     ├─ startTime, endTime                                        │
│     ├─ exercises[]:                                              │
│     │  ├─ name, type, category                                  │
│     │  └─ sets[]:  ← **PESI SALVATI QUI**                       │
│     │     ├─ weight ✅                                           │
│     │     ├─ reps ✅                                             │
│     │     ├─ actualReps ✅                                       │
│     │     ├─ rpe ✅                                              │
│     │     ├─ isCompleted ✅                                      │
│     │     └─ setDurationMillis ✅                                │
│     │                                                             │
│     └─ analytics data (volume, 1RM, etc.)                        │
│                                                                   │
│  FIRESTORE CLOUD (premium users only):                          │
│  └─ /users/{userId}/workouts/{workoutId}                        │
│     └─ Stessa struttura con sync cloud                          │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 - Esempio di Dati Salvati in Hive

```dart
// WorkoutModel salvato in Hive come JSON
{
  "id": "w_20250115_1",
  "name": "Chest Day",
  "status": "completed",
  "startTime": "2025-01-15T10:00:00Z",
  "endTime": "2025-01-15T10:45:00Z",
  "exercises": [
    {
      "id": "ex_1",
      "name": "Bench Press",
      "type": "single",
      "category": "chest",
      "sets": [
        {
          "id": "set_1",
          "setNumber": 1,
          "weight": 80.0,           // ✅ PESO SALVATO
          "reps": 8,                // ✅ REPS SALVATE
          "actualReps": 8,          // ✅ REPS EFFETTIVE
          "isCompleted": true,      // ✅ SET COMPLETATO
          "rpe": 7,                 // ✅ RPE SALVATO
          "setDurationMillis": 45000 // ✅ TUT EFFETTIVO
        },
        {
          "setNumber": 2,
          "weight": 75.0,
          "reps": 10,
          "actualReps": 10,
          "isCompleted": true,
          "rpe": 8
        },
        {
          "setNumber": 3,
          "weight": 70.0,
          "reps": 12,
          "actualReps": 11,
          "isCompleted": true,
          "rpe": 9
        }
      ]
    }
  ]
}

// ✅ Key in Hive: "user123_w_20250115_1"
```

---

## PARTE 2: FLUSSO DI RECUPERO DEI PESI

### 2.1 - Workflow di Recupero Pesi (Quando inizio un nuovo workout)

```
┌─────────────────────────────────────────────────────────────────┐
│ FASE 1: LOAD TEMPLATE (WorkoutTemplatesScreen)                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  User clicca su un template per avviare workout                 │
│  ├─ previousWorkoutFromTemplateProvider(templateId)             │
│  │  └─ Recupera ultimo workout completato di questo template    │
│  │                                                                │
│  └─ weightRecoveryDataProvider(templateId)                      │
│     └─ Calcola dias_since_last_session                          │
│                                                                   │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ FASE 2: WEIGHT RECOVERY DATA RETRIEVAL (Providers)              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  File: lib/features/workout/presentation/providers/            │
│        previous_workout_provider.dart                            │
│                                                                   │
│  previousWorkoutFromTemplateProvider:                            │
│  ├─ Query Firebase Firestore:                                   │
│  │  collections('users/{userId}/workouts')                      │
│  │  .where('templateId', isEqualTo: templateId)                 │
│  │  .where('status', isEqualTo: 'completed')                    │
│  │  .orderBy('endTime', descending: true)                       │
│  │  .limit(1)                                                    │
│  │                                                                │
│  └─ Return: Workout? (il più recente completato)                │
│                                                                   │
│  weightRecoveryDataProvider:                                     │
│  ├─ Input: previousWorkout                                      │
│  ├─ Calcola: daysSinceLastSession                               │
│  └─ Return: WeightRecoveryData {                                │
│     ├─ previousWorkout: Workout?                                │
│     ├─ lastSessionDate: DateTime?                               │
│     ├─ daysSinceLastSession: int                                │
│     └─ hasData: bool                                             │
│     }                                                             │
│                                                                   │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ FASE 3: WEIGHT RECOVERY OPTIONS DIALOG                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  File: lib/features/workout/presentation/screens/              │
│        workout_templates_screen.dart                             │
│                                                                   │
│  Se hasData && daysSinceLastSession <= 7:                       │
│  ├─ Mostra dialog: "Load previous weights?"                     │
│  ├─ Options:                                                     │
│  │  ├─ Exact: Usa pesi esatti dal workout precedente            │
│  │  ├─ +2.5%: Aumenta pesi del 2.5%                             │
│  │  ├─ -2.5%: Diminuisci pesi del 2.5%                          │
│  │  ├─ -5%: Diminuisci pesi del 5%                              │
│  │  └─ Skip: Non caricare pesi                                  │
│  │                                                                │
│  └─ User seleziona opzione                                      │
│                                                                   │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ FASE 4: APPLY WEIGHTS (WeightRecoveryService)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  File: lib/features/workout/domain/services/                    │
│        weight_recovery_service.dart                              │
│                                                                   │
│  WeightRecoveryService.applyPreviousWeights(                     │
│    currentWorkout: Workout,      // Workout appena creato       │
│    previousWorkout: Workout,     // Ultimo workout completato   │
│    multiplier: double,           // 1.0=exact, 1.025=+2.5%, etc │
│  )                                                                │
│                                                                   │
│  Algoritmo:                                                       │
│  ├─ Per ogni esercizio in currentWorkout:                       │
│  │  ├─ Cerca esercizio con stesso nome in previousWorkout      │
│  │  └─ Se trovato:                                              │
│  │     ├─ Per ogni set in currentWorkout:                       │
│  │     │  ├─ Prendi peso dal set corrispondente in previous    │
│  │     │  ├─ Applica multiplier                                 │
│  │     │  ├─ SmartRound il peso:                                │
│  │     │  │  ├─ < 20kg: Arrotonda a 0.5kg (manubri)            │
│  │     │  │  └─ >= 20kg: Arrotonda a 2.5kg (bilanciere)        │
│  │     │  └─ Aggiorna weight e reps                             │
│  │     │                                                         │
│  │     └─ (Superset handled separately)                         │
│  │                                                                │
│  └─ Return: Aggiornato currentWorkout con pesi applicati        │
│                                                                   │
│  Esempio:                                                         │
│  ├─ Previous: Bench Press 3x @ 80kg                             │
│  ├─ Multiplier: 1.025 (+2.5%)                                   │
│  ├─ Calculation: 80 * 1.025 = 82kg                              │
│  ├─ SmartRound (>20): (82 / 2.5).round() * 2.5 = 82.5kg        │
│  └─ Result: Set 1-3 @ 82.5kg ✅                                 │
│                                                                   │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ FASE 5: UPDATE WORKOUT STATE                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  currentWorkoutProvider.updateExercise():                        │
│  └─ Aggiorna lo stato del workout nel provider                  │
│     con i pesi e reps caricati                                  │
│                                                                   │
│  UI viene ricostruita → User vede i pesi caricati ✅             │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 - Per Singoli Esercizi (Add Exercise Modal)

```
┌─────────────────────────────────────────────────────────────────┐
│ FASE 1: USER ADDS EXERCISE (EnhancedAddExerciseModal)           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. User clicca "Add Exercise"                                   │
│  2. Seleziona esercizio da database                              │
│  3. Nome esercizio passato a _loadPreviousWeights()             │
│                                                                   │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ FASE 2: LOAD PREVIOUS WEIGHTS                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  _loadPreviousWeights(exerciseName: String):                    │
│  ├─ Legge workoutHistoryProvider                                │
│  ├─ Itera attraverso workout precedenti (newest first)          │
│  ├─ Cerca primo workout con:                                    │
│  │  ├─ status == 'completed'                                    │
│  │  ├─ exercise.name == exerciseName                            │
│  │  └─ sets con weight > 0 && isCompleted                       │
│  │                                                                │
│  └─ Estrae dati del primo workout trovato                       │
│                                                                   │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ FASE 3: POPULATE SETS IN MODAL                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  setState() {                                                     │
│    _sets.clear();                                                │
│    for (int i = 0; i < completedSets.length && i < 5; i++) {   │
│      _sets.add(ExerciseSet(                                      │
│        setNumber: i + 1,                                         │
│        weight: completedSets[i].weight,  ← Da workout precedente│
│        reps: completedSets[i].actualReps,                       │
│      ));                                                          │
│    }                                                              │
│    // Se meno di 3 set, aggiungi default                        │
│    while (_sets.length < 3) {                                   │
│      final lastWeight = _sets.last.weight;                      │
│      _sets.add(ExerciseSet(..., weight: lastWeight, ...));      │
│    }                                                              │
│  }                                                                │
│                                                                   │
│  SnackBar: "previousWeightsLoaded" ✅                            │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## PARTE 3: HISTORY & ANALYTICS

### 3.1 - ExerciseHistoryService (Hive Query Layer)

Quando l'app necessita di cronologia pesi per UI/analytics:

```dart
// File: lib/features/workout/data/services/exercise_history_service.dart

Future<List<double>> getRecentWeights(
  String exerciseName,  // "Bench Press"
  String userId,
  {int limit = 5}
) async {
  // 1. Apri box Hive 'workouts'
  // 2. Query tutti workout per questo userId
  // 3. Filter: status != 'planned', exercise.name matching
  // 4. Estrai pesi dai set completati
  // 5. Return unique weights (max 5)
}

Future<({double? weight, DateTime? date})> getLastExerciseData(
  String exerciseName,
  String userId,
) async {
  // Return {weight: 80.0, date: 2025-01-15}
  // Usato per pre-filling singoli set
}

Future<List<ExerciseHistoryData>> getExerciseHistory(
  String exerciseName,
  String userId,
  {int limit = 10}
) async {
  // Return lista di ExerciseHistoryData {
  //   weight, reps, rpe, tut, setDurationMillis, date, workoutName
  // }
  // Usato per exercise history bottom sheet
}
```

### 3.2 - Provider Layer (Riverpod)

```dart
// File: lib/features/workout/presentation/providers/exercise_history_provider.dart

// Recupera i 5 pesi unici più recenti
final recentWeightsProvider = 
  FutureProvider.autoDispose.family<List<double>, String>(...)

// Recupera i dati estesi (peso, reps, data, RPE, TUT)
final recentWeightsWithDetailsProvider = 
  FutureProvider.family.autoDispose<List<ExerciseHistoryData>, String>(...)

// Recupera l'ultimo peso registrato
final lastExerciseDataProvider = 
  FutureProvider.autoDispose.family<({double? weight, DateTime? date}), String>(...)
```

---

## LACUNE E BUG IDENTIFICATI

### 🔴 BUG CRITICO #1: Nome Esercizio Case-Sensitive

**Problema**: Il matching del nome esercizio è **case-insensitive ma fragile**

```dart
// exercise_history_service.dart, linea 177-195
final exerciseNameLower = exercise.name.toLowerCase().trim();
final searchNameLower = exerciseName.toLowerCase().trim();

bool isMatch = false;
if (exerciseNameLower == searchNameLower) {
  isMatch = true;
} else if (exerciseNameLower.contains(searchNameLower) || 
           searchNameLower.contains(exerciseNameLower)) {
  isMatch = true;
} else {
  // Try variations (Italian/English)
  final variations = _getExerciseVariations(searchNameLower);
  // ...
}
```

**Impatto**: 
- "Bench Press" vs "bench press" funziona ✅
- "Bench Press" vs "Bench  Press" (doppio spazio) potrebbe fallire ❌
- Il matching con variations è hardcoded e incompleto

**Fix Consigliato**:
```dart
// Normalizzazione robusta
String _normalizeExerciseName(String name) {
  return name.toLowerCase()
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ')  // Normlizza spazi
      .replaceAll(RegExp(r'[àáâä]'), 'a')  // Accenti
      .replaceAll(RegExp(r'[èéêë]'), 'e');
}

// Usa in queries
final normalized = _normalizeExerciseName(exerciseName);
```

---

### 🔴 BUG CRITICO #2: Manca Sincronizzazione della Cronologia Pesi

**Problema**: Se un workout viene salvato su Firestore (premium), il local history service **non viene aggiornato in real-time**.

```
Scenario:
1. Complete workout on Device A (premium user)
2. Save to Firestore ✅
3. Switch to Device B (login stesso account)
4. Add esercizio -> load previous weights
5. ❌ ERRORE: Local Hive è vuoto, mostra no data!
```

**Causa**: 
- ExerciseHistoryService legge SOLO da Hive locale
- Firebase sync è asincrono e non aggiorna Hive localmente
- Non c'è meccanismo di sync download da cloud → local

**File Coinvolti**:
- `hybrid_workout_repository_impl.dart` - Sync async, non attende
- `exercise_history_service.dart` - Legge solo Hive

**Fix Consigliato**:
```dart
// In hybrid_workout_repository_impl.dart
@override
Future<Either<Failure, String>> saveWorkout(Workout workout) async {
  try {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return left(const AuthenticationFailure(...));
    
    final workoutModel = WorkoutModel.fromDomain(workout);
    
    // SYNC LOCALE FIRST
    final localResult = await _localDataSource.saveWorkout(
      workoutModel,
      currentUser.uid,
    );
    
    // SYNC CLOUD IN BACKGROUND (existing)
    if (isPremiumUser || await isAdminUser) {
      _syncToCloudInBackground(
        workoutModel: workoutModel,
        userId: currentUser.uid,
        operation: 'save',
      );
    }
    
    // ✅ NEW: Trigger local-to-Hive sync
    await _invalidateExerciseHistoryCache(currentUser.uid);
    
    return right(localResult);
  } catch (e) {
    return left(UnexpectedFailure('Failed to save workout: $e'));
  }
}

Future<void> _invalidateExerciseHistoryCache(String userId) async {
  // Force refresh di exerciseHistoryProvider nel prossimo accesso
  final service = ExerciseHistoryService(boxManager: _boxManager);
  // Cache invalidation or refresh
}
```

---

### 🟡 BUG MINORE #3: Memory Leak in ExerciseHistoryService

**Problema**: `ExerciseHistoryService` apre Hive box in ogni metodo ma non li chiude

```dart
// Linea 124-125
final box = await _boxManager.openBox<Map>(_workoutsBoxName);
// ❌ Box rimane aperto!
```

**Impatto**: Accumulo progressivo di box aperti → Memory leak

**Fix Consigliato**:
```dart
// Usa context manager
Future<List<ExerciseHistoryData>> _getExerciseHistory(...) async {
  try {
    final box = await _boxManager.openBox<Map>(_workoutsBoxName);
    // ... query logic
    return result;
  } finally {
    // ✅ Sempre chiudi
    await box.close();
  }
}
```

---

### 🟡 BUG MINORE #4: Matching Fallace con Variazioni di Nome

**Problema**: Le variazioni di nome esercizio sono hardcoded e incomplette

```dart
// exercise_history_service.dart, linea 322-333
final translations = {
  'panca piana': ['bench press', 'flat bench', 'panca', 'distensioni su panca'],
  'bench press': ['panca piana', 'panca', 'distensioni su panca'],
  // ... solo 12 entries!
};
```

**Scenario Fallace**:
- "Horizontal Bench Press" vs "Bench Press" → No match ❌
- "Panca Piana Inclinata" vs "Panca Piana" → No match ❌
- "Chest Press Machine" vs "Bench Press" → No match ❌

**Fix Consigliato**: Usare fuzzy matching
```dart
// Implementare Levenshtein distance o simile
double _calculateSimilarity(String a, String b) {
  final aNorm = _normalizeExerciseName(a);
  final bNorm = _normalizeExerciseName(b);
  
  // Usa package:fuzzy_match o implementa Levenshtein
  // Ritorna score 0.0-1.0
}

// Usa in query
if (_calculateSimilarity(exerciseNameLower, searchNameLower) > 0.7) {
  isMatch = true;
}
```

---

### 🟡 BUG MINORE #5: Nessuna Fallback se Load Pesi Fallisce

**Problema**: Se `_loadPreviousWeights()` fallisce, user non viene informato

```dart
// enhanced_add_exercise_modal.dart, linea 348-351
} catch (e) {
  // Silent failure - no snackbar!
  debugPrint('Error loading previous weights: $e');
  // Sets rimangono ai default (0, 10)
}
```

**Impatto**: User pensa sia vuoto il DB quando è solo un errore

**Fix Consigliato**:
```dart
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).loadWeightsFailed),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  debugPrint('Error loading previous weights: $e');
}
```

---

### 🟡 BUG MINORE #6: Nessun Timeout Esplicito in Provider

**Problema**: `exercise_history_service.dart` apre box e query senza timeout

```dart
final box = await _boxManager.openBox<Map>(_workoutsBoxName);
// ❌ Se box è corrotto, freezes indefinitamente
```

**Fix Consigliato**:
```dart
final box = await _boxManager.openBox<Map>(_workoutsBoxName)
    .timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException('Hive box open timeout'),
    );
```

---

### 🟡 ARCHITECTURAL ISSUE: Hardcoded Status String

**Problema**: Il check `status == 'planned'` e `status == 'completed'` è hardcoded

```dart
// exercise_history_service.dart, linea 173
if (workout.status == 'planned') continue;

// Dovrebbe usare enum!
if (workout.status != WorkoutStatus.completed.name) continue;
```

**Impact**: Fragile a refactoring

---

## PARTE 4: TEST FLOW MANUALE

### Test #1: Salvataggio Pesi Base

```bash
1. Apri app (debug mode)
2. Crea workout: "Bench Press 3x @ 80kg"
3. Completa set 1, 2, 3
4. Click "Complete Workout"
5. ✅ Verifica in Hive debugger:
   - Key: "user123_workoutXYZ"
   - Value.exercises[0].sets[0].weight == 80
   - Value.exercises[0].sets[0].isCompleted == true
```

### Test #2: Recupero Pesi (Template)

```bash
1. Completa workout da template (vedi Test #1)
2. Exit app completamente
3. Riapri app
4. Vai a "Workout Templates"
5. Seleziona stesso template
6. ✅ Verifica: Dialog appare con "Load weights?"
7. Seleziona "Exact"
8. ✅ Verifica: Tutti set hanno weight=80
```

### Test #3: Recupero Pesi (Add Exercise)

```bash
1. Completa workout: "Curl 3x @ 30kg"
2. Crea nuovo workout
3. Click "Add Exercise" → Select "Curl"
4. ✅ Verifica: _sets popolato con 3 set @ 30kg
5. SnackBar mostra "Previous weights loaded"
```

### Test #4: Name Matching Bug

```bash
1. Completa: "Bench Press" (esatto)
2. Crea nuovo workout
3. Add: "bench press" (minuscolo)
4. ✅ ATTESO: Pesi caricati
   Se fallisce → BUG #1 confermato
```

### Test #5: Cross-Device Sync

```bash
1. Device A (premium): Completa workout → sync cloud
2. Device B (premium): Login stesso account
3. Attendi 5 secondi
4. Device B: Add esercizio da Device A
5. ❌ ATTESO FALLIMENTO: Hive local vuoto
   Se pesi appaiono → Bug #2 fixed
```

---

## PARTE 5: ARCHITETTURA MIGLIORATA CONSIGLIATA

### Pattern Proposto: ExerciseHistoryCache

```
Workout Save Flow (CURRENT):
  saveWorkout() → Hive local → Done
  
Workout Save Flow (IMPROVED):
  saveWorkout() → Hive local → ExerciseHistoryCache.invalidate()
                    ↓
  _syncToCloud() → Firebase → ExerciseHistoryCache.sync()
  
ExerciseHistoryCache benefits:
  ✅ Centralizza accesso a history
  ✅ Lazy-loads e caching
  ✅ Cross-device sync tracking
  ✅ Soft-delete support
```

---

## RIASSUNTO COMPLETEZZA

| Aspetto | Status | File Principale |
|---------|--------|-----------------|
| ✅ Salvataggio pesi locali | 100% | hybrid_workout_repository_impl.dart |
| ✅ Salvataggio pesi cloud | 100% (premium) | hybrid_workout_repository_impl.dart |
| ✅ Recupero pesi (template) | 100% | previous_workout_provider.dart |
| ✅ Recupero pesi (add exercise) | 100% | enhanced_add_exercise_modal.dart |
| ✅ Applicazione moltiplicatori | 100% | weight_recovery_service.dart |
| ✅ History view | 100% | exercise_history_provider.dart |
| ❌ Sync cloud → local | 0% | **MISSING** |
| ⚠️ Matching nome robusto | 60% | exercise_history_service.dart |
| ⚠️ Error handling | 70% | multiple files |
| ⚠️ Memory management | 70% | exercise_history_service.dart |

---

## FILE MAPPA COMPLETA

| Feature | Layer | File |
|---------|-------|------|
| **Domain** | Entities | `domain/entities/exercise.dart`, `workout.dart` |
| | Services | `domain/services/weight_recovery_service.dart` |
| | Usecases | `domain/usecases/complete_workout_usecase.dart` |
| | Repositories | `domain/repositories/workout_repository.dart` |
| **Data** | Datasources | `data/datasources/hive_workout_datasource.dart` |
| | Repositories | `data/repositories/hybrid_workout_repository_impl.dart` |
| | Services | `data/services/exercise_history_service.dart` |
| | Models | `data/models/workout_model.dart` |
| **Presentation** | Providers | `presentation/providers/previous_workout_provider.dart` |
| | | `presentation/providers/exercise_history_provider.dart` |
| | | `presentation/providers/workout_provider.dart` |
| | Screens | `presentation/screens/workout_templates_screen.dart` |
| | Widgets | `presentation/widgets/enhanced_add_exercise_modal.dart` |

