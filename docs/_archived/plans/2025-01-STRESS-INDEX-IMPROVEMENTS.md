# Stress Index Improvements - Design Document

**Data**: Dicembre 2024
**Stato**: Draft
**Feature**: Stress Index / Training Stress

---

## 1. Problema Attuale

### Sintomo
L'utente vede il messaggio "Non ci sono dati sufficienti" nella tab Stress Index anche se ha workout storici.

### Causa Root
Il sistema calcola lo stress index **solo al momento del salvataggio** del workout. I workout esistenti (pre-feature) non hanno dati di stress calcolati.

### Flow Attuale

```
┌─────────────────────┐
│ User completa       │
│ workout             │
└─────────┬───────────┘
          ▼
┌─────────────────────┐
│ WorkoutProvider     │
│ .saveWorkout()      │
└─────────┬───────────┘
          ▼
┌─────────────────────┐
│ StressIndexNotifier │
│ .calculateAndSave() │
└─────────┬───────────┘
          ▼
┌─────────────────────┐
│ StressIndexCalc     │────► Requisiti per set valido:
│ .calculate()        │      • isCompleted = true
└─────────┬───────────┘      • isWarmup = false
          │                  • weight > 0
          ▼                  • reps > 0
┌─────────────────────┐
│ Repository          │
│ save to Hive +      │
│ Firestore           │
└─────────────────────┘
```

### Limitazioni Identificate

| Limitazione | Impatto |
|-------------|---------|
| Solo workout nuovi hanno stress index | Utenti esistenti vedono "no data" |
| `getRecent(days: 7)` filtra troppo | Dati vecchi non mostrati |
| Messaggio generico | Utente non capisce cosa fare |
| No progress indicator | Utente non sa quanti workout servono |

---

## 2. Soluzione Proposta

### 2.1 Backfill Storico (Priorità Alta)

Calcolare stress index per **tutti i workout esistenti** che non lo hanno.

```dart
/// Backfill stress index for historical workouts
Future<BackfillResult> backfillHistoricalWorkouts() async {
  final workouts = await workoutRepository.getAllCompletedWorkouts();
  final existingStressIds = await stressRepository.getAllWorkoutIds();

  int processed = 0;
  int skipped = 0;

  for (final workout in workouts) {
    // Skip if already calculated
    if (existingStressIds.contains(workout.id)) {
      skipped++;
      continue;
    }

    // Skip if workout can't be calculated
    if (!StressIndexCalculator.canCalculate(workout)) {
      skipped++;
      continue;
    }

    // Calculate and save
    final result = StressIndexCalculator.calculate(workout);
    await stressRepository.save(result);
    processed++;
  }

  return BackfillResult(processed: processed, skipped: skipped);
}
```

**Trigger**:
- Al primo accesso alla tab Stress Index
- Oppure in background dopo login

### 2.2 Messaggio Migliorato (Priorità Alta)

Invece di generico "no data", mostrare stato specifico:

```dart
Widget _buildEmptyState(BuildContext context, EmptyStateReason reason) {
  return switch (reason) {
    EmptyStateReason.noWorkouts => _NoWorkoutsState(),
    EmptyStateReason.noValidSets => _NoValidSetsState(),
    EmptyStateReason.backfillInProgress => _BackfillProgressState(),
    EmptyStateReason.allDataExpired => _DataExpiredState(),
  };
}
```

**Messaggi specifici**:

| Stato | Messaggio IT | Azione |
|-------|--------------|--------|
| No workout | "Completa il tuo primo workout per vedere lo stress allenante" | CTA → Inizia Workout |
| No valid sets | "I tuoi workout non hanno set con peso e ripetizioni registrate" | Info su come registrare |
| Backfill in corso | "Analisi workout storici in corso..." | Progress indicator |
| Dati scaduti | "Non hai workout negli ultimi 7 giorni" | Mostra storico completo |

### 2.3 Estendere Periodo Visualizzazione (Priorità Media)

Cambiare da 7 giorni fissi a periodo configurabile:

```dart
// Prima
final recentResults = await repository.getRecent(days: 7);

// Dopo
final recentResults = await repository.getRecent(days: 30);
// + sezione "Storico completo" con tutti i dati
```

### 2.4 Progress Indicator per Nuovi Utenti (Priorità Bassa)

Mostrare progresso verso dati significativi:

```
┌────────────────────────────────────┐
│ 🏋️ Stress Index                    │
│                                    │
│ ████████░░░░░░░░ 2/5 workout       │
│                                    │
│ Completa altri 3 workout per       │
│ sbloccare analisi dettagliata      │
└────────────────────────────────────┘
```

---

## 3. Architettura Tecnica

### 3.1 Nuovi File

```
lib/features/stress_index/
├── domain/
│   └── services/
│       └── stress_index_backfill_service.dart  [NEW]
├── presentation/
│   ├── providers/
│   │   └── stress_index_provider.dart          [MODIFY]
│   └── widgets/
│       └── stress_index_empty_states.dart      [NEW]
```

### 3.2 StressIndexBackfillService

```dart
/// Service per backfill storico stress index
class StressIndexBackfillService {
  StressIndexBackfillService({
    required this.workoutRepository,
    required this.stressRepository,
  });

  final WorkoutRepository workoutRepository;
  final StressIndexRepository stressRepository;

  /// Stream per progress updates
  final _progressController = StreamController<BackfillProgress>.broadcast();
  Stream<BackfillProgress> get progressStream => _progressController.stream;

  /// Esegue backfill per tutti i workout senza stress index
  Future<BackfillResult> execute({
    Map<String, List<String>>? exerciseFocusMap,
  }) async {
    final workouts = await _getWorkoutsNeedingBackfill();

    if (workouts.isEmpty) {
      return BackfillResult.empty();
    }

    int processed = 0;
    final total = workouts.length;

    for (final workout in workouts) {
      // Emit progress
      _progressController.add(BackfillProgress(
        current: processed,
        total: total,
        currentWorkoutName: workout.name,
      ));

      // Calculate and save
      if (StressIndexCalculator.canCalculate(workout)) {
        final result = StressIndexCalculator.calculate(
          workout,
          exerciseFocusMap: exerciseFocusMap,
        );
        await stressRepository.save(result);
        processed++;
      }

      // Yield to UI thread
      await Future.delayed(Duration.zero);
    }

    _progressController.add(BackfillProgress.completed(processed));

    return BackfillResult(
      processed: processed,
      total: total,
    );
  }

  Future<List<Workout>> _getWorkoutsNeedingBackfill() async {
    final allWorkouts = await workoutRepository.getAllCompleted();
    final existingIds = await stressRepository.getAllWorkoutIds();

    return allWorkouts
        .where((w) => !existingIds.contains(w.id))
        .toList();
  }
}

/// Progress durante backfill
class BackfillProgress {
  const BackfillProgress({
    required this.current,
    required this.total,
    this.currentWorkoutName,
    this.isCompleted = false,
  });

  final int current;
  final int total;
  final String? currentWorkoutName;
  final bool isCompleted;

  factory BackfillProgress.completed(int total) => BackfillProgress(
    current: total,
    total: total,
    isCompleted: true,
  );

  double get progress => total > 0 ? current / total : 0;
}

/// Risultato backfill
class BackfillResult {
  const BackfillResult({
    required this.processed,
    required this.total,
  });

  final int processed;
  final int total;

  factory BackfillResult.empty() => const BackfillResult(processed: 0, total: 0);

  int get skipped => total - processed;
  bool get hasData => processed > 0;
}
```

### 3.3 Provider Aggiornato

```dart
/// Provider per backfill service
final stressIndexBackfillServiceProvider = Provider<StressIndexBackfillService>((ref) {
  return StressIndexBackfillService(
    workoutRepository: ref.watch(workoutRepositoryProvider),
    stressRepository: ref.watch(stressIndexRepositoryProvider),
  );
});

/// Provider per stato backfill
final backfillProgressProvider = StreamProvider<BackfillProgress>((ref) {
  final service = ref.watch(stressIndexBackfillServiceProvider);
  return service.progressStream;
});

/// Provider che triggera backfill se necessario
final stressIndexWithBackfillProvider = FutureProvider<StressIndexState>((ref) async {
  final stressNotifier = ref.watch(stressIndexNotifierProvider.notifier);
  final state = ref.watch(stressIndexNotifierProvider);

  // Se non ci sono dati, prova backfill
  if (state.valueOrNull?.hasData != true) {
    final backfillService = ref.watch(stressIndexBackfillServiceProvider);
    final focusMap = await ref.watch(exerciseFocusMapProvider.future);

    final result = await backfillService.execute(exerciseFocusMap: focusMap);

    if (result.hasData) {
      await stressNotifier.refresh();
    }
  }

  return state.valueOrNull ?? StressIndexState.empty();
});
```

### 3.4 Empty States Widget

```dart
/// Enum per i diversi stati vuoti
enum StressIndexEmptyReason {
  noWorkouts,
  noValidSets,
  backfillInProgress,
  allDataOld,
}

/// Widget per empty states specifici
class StressIndexEmptyState extends StatelessWidget {
  const StressIndexEmptyState({
    required this.reason,
    this.backfillProgress,
    super.key,
  });

  final StressIndexEmptyReason reason;
  final BackfillProgress? backfillProgress;

  @override
  Widget build(BuildContext context) {
    return switch (reason) {
      StressIndexEmptyReason.noWorkouts => _buildNoWorkouts(context),
      StressIndexEmptyReason.noValidSets => _buildNoValidSets(context),
      StressIndexEmptyReason.backfillInProgress => _buildBackfillProgress(context),
      StressIndexEmptyReason.allDataOld => _buildAllDataOld(context),
    };
  }

  Widget _buildNoWorkouts(BuildContext context) {
    return _EmptyStateCard(
      icon: AppIcons.fitnessCenter,
      title: context.l10n.noWorkoutsYet,
      subtitle: context.l10n.completeFirstWorkoutForStress,
      action: FilledButton.icon(
        onPressed: () => context.go('/workout'),
        icon: Icon(AppIcons.play),
        label: Text(context.l10n.startWorkout),
      ),
    );
  }

  Widget _buildNoValidSets(BuildContext context) {
    return _EmptyStateCard(
      icon: AppIcons.warning,
      title: context.l10n.noValidSetsFound,
      subtitle: context.l10n.recordWeightAndRepsForStress,
      action: null,
    );
  }

  Widget _buildBackfillProgress(BuildContext context) {
    final progress = backfillProgress;
    return _EmptyStateCard(
      icon: AppIcons.sync,
      title: context.l10n.analyzingHistory,
      subtitle: progress != null
          ? context.l10n.analyzingWorkout(progress.current, progress.total)
          : context.l10n.pleaseWait,
      action: progress != null
          ? LinearProgressIndicator(value: progress.progress)
          : const LoadingIndicator(),
    );
  }

  Widget _buildAllDataOld(BuildContext context) {
    return _EmptyStateCard(
      icon: AppIcons.history,
      title: context.l10n.noRecentWorkouts,
      subtitle: context.l10n.noWorkoutsInLast7Days,
      action: TextButton(
        onPressed: () {
          // Show full history
        },
        child: Text(context.l10n.viewFullHistory),
      ),
    );
  }
}
```

---

## 4. Localizzazioni Necessarie

### app_en.arb
```json
{
  "noWorkoutsYet": "No workouts yet",
  "completeFirstWorkoutForStress": "Complete your first workout to see training stress analysis",
  "noValidSetsFound": "No valid sets found",
  "recordWeightAndRepsForStress": "Record weight and reps in your sets to calculate stress",
  "analyzingHistory": "Analyzing workout history",
  "analyzingWorkout": "Analyzing {current} of {total} workouts...",
  "pleaseWait": "Please wait...",
  "noRecentWorkouts": "No recent workouts",
  "noWorkoutsInLast7Days": "You haven't trained in the last 7 days",
  "viewFullHistory": "View full history",
  "backfillComplete": "Analysis complete! Found {count} workouts"
}
```

### app_it.arb
```json
{
  "noWorkoutsYet": "Nessun workout ancora",
  "completeFirstWorkoutForStress": "Completa il tuo primo workout per vedere l'analisi dello stress allenante",
  "noValidSetsFound": "Nessun set valido trovato",
  "recordWeightAndRepsForStress": "Registra peso e ripetizioni nei tuoi set per calcolare lo stress",
  "analyzingHistory": "Analisi storico workout",
  "analyzingWorkout": "Analisi {current} di {total} workout...",
  "pleaseWait": "Attendere prego...",
  "noRecentWorkouts": "Nessun workout recente",
  "noWorkoutsInLast7Days": "Non ti sei allenato negli ultimi 7 giorni",
  "viewFullHistory": "Vedi storico completo",
  "backfillComplete": "Analisi completata! Trovati {count} workout"
}
```

---

## 5. Piano di Implementazione

### Fase 1: Backfill Service (Priorità Alta)
1. [ ] Creare `StressIndexBackfillService`
2. [ ] Aggiungere metodo `getAllWorkoutIds()` al repository
3. [ ] Creare provider per backfill
4. [ ] Testare con workout storici

### Fase 2: Empty States (Priorità Alta)
1. [ ] Creare enum `StressIndexEmptyReason`
2. [ ] Creare widget `StressIndexEmptyState`
3. [ ] Aggiungere localizzazioni
4. [ ] Integrare in `StressIndexTab`

### Fase 3: Auto-Backfill (Priorità Media)
1. [ ] Trigger backfill al primo accesso tab
2. [ ] Mostrare progress durante backfill
3. [ ] Refresh automatico dopo backfill

### Fase 4: Storico Esteso (Priorità Bassa)
1. [ ] Aggiungere `getAll()` al repository
2. [ ] Creare sezione "Storico completo"
3. [ ] Paginazione per grandi dataset

---

## 6. Rischi e Mitigazioni

| Rischio | Probabilità | Impatto | Mitigazione |
|---------|-------------|---------|-------------|
| Backfill lento su molti workout | Media | Basso | Progress indicator + yield UI thread |
| Memory issue con troppi workout | Bassa | Alto | Processare in batch di 50 |
| Inconsistenza dati dopo backfill | Bassa | Medio | Validazione post-backfill |
| UI freeze durante calcolo | Media | Medio | Compute isolate per calcoli pesanti |

---

## 7. Metriche di Successo

- [ ] 0% utenti vedono "no data" se hanno workout validi
- [ ] Backfill completa in < 5 secondi per 100 workout
- [ ] Empty state mostra sempre messaggio actionable
- [ ] Nessun crash/freeze durante backfill
