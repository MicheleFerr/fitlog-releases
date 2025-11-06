# 🏋️ Exercise Counting Mode - Piano di Implementazione Completo

> **Obiettivo**: Implementare correttamente la gestione di tre tipologie di esercizi (peso+reps, solo reps, tempo) in tutto il flusso dell'app, dall'inserimento al completamento.

---

## 📊 Executive Summary

**Problema attuale**: L'app tratta tutti gli esercizi come se richiedessero peso + ripetizioni, ma esistono tre tipologie:
1. **Weighted** (peso + reps): panca piana, squat, stacco
2. **Reps** (solo reps, corpo libero): push-ups, pull-ups, dips
3. **Time** (tempo senza peso): plank, wall sit, hollow hold

**Soluzione**: Aggiungere `ExerciseCountingMode` come proprietà dell'esercizio e adattare tutti i componenti UI per mostrare/nascondere i campi appropriati.

**Impatto**:
- 🔧 **6 componenti core** da modificare
- 📝 **3 entità domain** da estendere
- 🧪 **12+ test** da creare
- 📄 **~2500 righe di codice** coinvolte

---

## 🎯 Analisi del Flusso Completo

### 1️⃣ Flusso di Inserimento Esercizio

```
User seleziona esercizio dal database (Exercise - features/exercise_database)
                    ↓
ExerciseCustomizationScreen mostra configurazione
    - 🔴 PROBLEMA: Mostra sempre Weight + Reps
    - ✅ SOLUZIONE: Rilevare countingMode e adattare UI
                    ↓
Crea ExerciseSet[] con valori configurati
    - 🔴 PROBLEMA: ExerciseSet ha weight, reps, seconds ma non logica per tipo
    - ✅ SOLUZIONE: Aggiungere countingMode a Exercise (workout entity)
                    ↓
Esercizio aggiunto al workout
```

### 2️⃣ Flusso di Esecuzione Set

```
User tap su ExerciseListItem per completare un set
                    ↓
Tap normale → UnifiedSetInputModal
    - 🔴 PROBLEMA: Mostra sempre Weight + Reps + RPE
    - ✅ SOLUZIONE: Adattare UI in base a countingMode
                    ↓
User inserisce valori:
    - Weighted: Weight + Reps + RPE
    - Reps: Reps + RPE (no weight)
    - Time: Seconds + RPE (no weight, no reps)
                    ↓
ExerciseSet.completeWithRPE() salva i dati
    - 🔴 PROBLEMA: Metodo assume sempre reps
    - ✅ SOLUZIONE: Adattare logica per gestire time-based
                    ↓
Set completato e timer riposo parte
```

### 3️⃣ Flusso di Quick Edit

```
User tap rapido su peso/reps nel set card
                    ↓
QuickEditOverlayV2 appare sulla posizione tappata
    - 🔴 PROBLEMA: Mostra sempre Weight + Reps picker
    - ✅ SOLUZIONE: Adattare pickers in base a countingMode
                    ↓
User modifica valori con scroll picker
                    ↓
Salva modifiche → ExerciseSet aggiornato
```

### 4️⃣ Flusso di Long Press Edit

```
User long press su set card
                    ↓
EditSetModal viene mostrato
    - 🔴 PROBLEMA: Mostra sempre Weight + Reps + Note
    - ✅ SOLUZIONE: Adattare campi in base a countingMode
                    ↓
User modifica valori con text input
                    ↓
Salva modifiche → ExerciseSet aggiornato
```

---

## 🔍 Problemi Identificati

### ❌ Problema #1: ExerciseCountingMode è solo uno stub

**File**: `lib/features/exercise_database/domain/entities/exercise_counting_mode.dart`

```dart
// STATO ATTUALE: Solo un enum senza integrazione
enum ExerciseCountingMode {
  weighted,  // Weight + reps
  reps,      // Bodyweight - reps only
  time,      // Time-based
}
```

**❌ Manca**:
- Metodi helper per verificare il tipo
- Integrazione con Exercise entity
- Logica di validazione per i campi

**✅ Soluzione**:
```dart
enum ExerciseCountingMode {
  weighted,
  reps,
  time;

  bool get requiresWeight => this == ExerciseCountingMode.weighted;
  bool get requiresReps => this == ExerciseCountingMode.weighted || this == ExerciseCountingMode.reps;
  bool get requiresTime => this == ExerciseCountingMode.time;

  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case weighted: return l10n.countingModeWeighted;
      case reps: return l10n.countingModeReps;
      case time: return l10n.countingModeTime;
    }
  }
}
```

---

### ❌ Problema #2: Exercise (workout) non ha countingMode

**File**: `lib/features/workout/domain/entities/exercise.dart`

```dart
// STATO ATTUALE: Exercise non sa che tipo di conteggio usa
class Exercise {
  final String id;
  final String name;
  final ExerciseType type;  // single, superset, dropset, restPause
  final ExerciseCategory category;
  final List<ExerciseSet> sets;
  // ❌ MANCA: ExerciseCountingMode countingMode
}
```

**✅ Soluzione**:
```dart
class Exercise {
  // ... campi esistenti ...
  final ExerciseCountingMode countingMode; // ✅ NUOVO

  Exercise({
    // ... parametri esistenti ...
    this.countingMode = ExerciseCountingMode.weighted, // Default
  });
}
```

---

### ❌ Problema #3: ExerciseSet non valida i campi in base al tipo

**File**: `lib/features/workout/domain/entities/exercise.dart`

```dart
// STATO ATTUALE: ExerciseSet ha tutti i campi ma nessuna validazione
class ExerciseSet {
  final double? weight;    // Può essere null
  final int? reps;         // Può essere null
  final int? seconds;      // Può essere null
  // ❌ PROBLEMA: Nessuna logica per capire quali campi sono richiesti
}
```

**✅ Soluzione**: Aggiungere metodi di validazione e helper

```dart
class ExerciseSet {
  // ... campi esistenti ...

  // ✅ NUOVO: Validazione per countingMode
  bool isValidFor(ExerciseCountingMode mode) {
    switch (mode) {
      case ExerciseCountingMode.weighted:
        return weight != null && weight! > 0 && reps != null && reps! > 0;
      case ExerciseCountingMode.reps:
        return reps != null && reps! > 0;
      case ExerciseCountingMode.time:
        return seconds != null && seconds! > 0;
    }
  }

  // ✅ NUOVO: Calcolo volume generico
  double calculateVolume(ExerciseCountingMode mode) {
    switch (mode) {
      case ExerciseCountingMode.weighted:
        return (weight ?? 0) * (actualReps ?? reps ?? 0);
      case ExerciseCountingMode.reps:
        return (actualReps ?? reps ?? 0).toDouble();
      case ExerciseCountingMode.time:
        return (seconds ?? 0).toDouble();
    }
  }
}
```

---

### ❌ Problema #4: UnifiedSetInputModal mostra sempre weight+reps

**File**: `lib/features/workout/presentation/widgets/unified_set_input_modal.dart`

**Stato attuale (linea 164-169)**:
```dart
// ❌ Mostra sempre weight e reps
double _selectedWeight = 0.0;
int _selectedReps = 0;
int? _selectedRpe;
```

**✅ Soluzione**: Adattare UI in base a countingMode

```dart
class _UnifiedSetInputModalState extends ConsumerState<UnifiedSetInputModal> {
  // ✅ NUOVO: Supporto per tutti i tipi
  double _selectedWeight = 0.0;
  int _selectedReps = 0;
  int _selectedSeconds = 0; // ✅ NUOVO per time-based
  int? _selectedRpe;

  // ✅ NUOVO: Ottieni countingMode dall'exercise
  ExerciseCountingMode get _countingMode {
    if (widget.exercise != null) {
      return widget.exercise!.countingMode;
    }
    return ExerciseCountingMode.weighted; // Default
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ Mostra solo i campi necessari
        if (_countingMode.requiresWeight) _buildWeightPicker(),
        if (_countingMode.requiresReps) _buildRepsPicker(),
        if (_countingMode.requiresTime) _buildTimePicker(), // ✅ NUOVO
        _buildRpePicker(), // Sempre presente
      ],
    );
  }

  // ✅ NUOVO: Time picker per esercizi time-based
  Widget _buildTimePicker() {
    return Column(
      children: [
        Text('Duration', style: context.textTheme.titleMedium),
        Row(
          children: [
            _buildMinutesPicker(),
            Text(':'),
            _buildSecondsPicker(),
          ],
        ),
      ],
    );
  }
}
```

---

### ❌ Problema #5: QuickEditOverlayV2 mostra sempre weight+reps

**File**: `lib/features/workout/presentation/widgets/quick_edit_overlay_v2.dart`

**Stato attuale (linea 67-68)**:
```dart
// ❌ Mostra sempre weight e reps
late double _selectedWeight;
late int _selectedReps;
```

**✅ Soluzione**: Adattare pickers in base a countingMode

```dart
class _QuickEditOverlayV2State extends ConsumerState<QuickEditOverlayV2> {
  late double _selectedWeight;
  late int _selectedReps;
  late int _selectedSeconds; // ✅ NUOVO

  // ✅ NUOVO: Determina countingMode
  ExerciseCountingMode get _countingMode {
    // Potrebbe essere passato come parametro o rilevato dall'exerciseSet
    return ExerciseCountingMode.weighted; // TODO: Implementare logica
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: _positioning.left,
          top: _positioning.top,
          child: Material(
            child: Container(
              width: 340,
              child: Column(
                children: [
                  // ✅ Mostra solo i picker necessari
                  if (_countingMode.requiresWeight)
                    _buildWeightPicker(),
                  if (_countingMode.requiresReps)
                    _buildRepsPicker(),
                  if (_countingMode.requiresTime)
                    _buildTimePicker(), // ✅ NUOVO
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

---

### ❌ Problema #6: ExerciseCustomizationScreen non rileva il tipo

**File**: `lib/features/exercise_database/presentation/widgets/exercise_customization_screen.dart`

**Stato attuale (linea 36-44)**:
```dart
// ❌ Crea sempre set con weight+reps
_customizations = widget.selectedExercises.map((exercise) =>
  ExerciseCustomization(
    exercise: exercise,
    sets: [
      SetCustomization(setNumber: 1, weight: 0, reps: 10),
      SetCustomization(setNumber: 2, weight: 0, reps: 10),
      SetCustomization(setNumber: 3, weight: 0, reps: 10),
    ],
  )
).toList();
```

**✅ Soluzione**: Rilevare countingMode e creare set appropriati

```dart
void initState() {
  super.initState();
  _customizations = widget.selectedExercises.map((exercise) {
    // ✅ NUOVO: Rileva countingMode dall'exercise database
    final countingMode = _detectCountingMode(exercise);

    return ExerciseCustomization(
      exercise: exercise,
      countingMode: countingMode, // ✅ NUOVO
      sets: _createDefaultSets(countingMode), // ✅ NUOVO
    );
  }).toList();
}

// ✅ NUOVO: Rileva il tipo di conteggio dall'esercizio
ExerciseCountingMode _detectCountingMode(Exercise exercise) {
  // Opzione 1: Se Exercise (database) ha già countingMode → usalo
  // Opzione 2: Euristica basata su nome/categoria

  final lowerName = exercise.nome.toLowerCase();

  // Time-based exercises
  if (lowerName.contains('plank') ||
      lowerName.contains('wall sit') ||
      lowerName.contains('hollow hold') ||
      lowerName.contains('l-sit')) {
    return ExerciseCountingMode.time;
  }

  // Bodyweight exercises (reps only)
  if (lowerName.contains('push-up') ||
      lowerName.contains('pull-up') ||
      lowerName.contains('dip') ||
      lowerName.contains('chin-up') ||
      exercise.attrezzatura.toLowerCase() == 'corpo libero') {
    return ExerciseCountingMode.reps;
  }

  // Default: weighted
  return ExerciseCountingMode.weighted;
}

// ✅ NUOVO: Crea set di default in base al tipo
List<SetCustomization> _createDefaultSets(ExerciseCountingMode mode) {
  switch (mode) {
    case ExerciseCountingMode.weighted:
      return [
        SetCustomization(setNumber: 1, weight: 0, reps: 10),
        SetCustomization(setNumber: 2, weight: 0, reps: 10),
        SetCustomization(setNumber: 3, weight: 0, reps: 10),
      ];
    case ExerciseCountingMode.reps:
      return [
        SetCustomization(setNumber: 1, reps: 10),
        SetCustomization(setNumber: 2, reps: 10),
        SetCustomization(setNumber: 3, reps: 10),
      ];
    case ExerciseCountingMode.time:
      return [
        SetCustomization(setNumber: 1, seconds: 60), // 1 min
        SetCustomization(setNumber: 2, seconds: 60),
        SetCustomization(setNumber: 3, seconds: 60),
      ];
  }
}
```

---

## 🛠️ Piano di Implementazione

### 📦 FASE 1: Domain Layer - Entità e Logica

**Obiettivo**: Estendere le entità domain per supportare ExerciseCountingMode

#### Task 1.1: Migliorare ExerciseCountingMode enum

**File**: `lib/features/exercise_database/domain/entities/exercise_counting_mode.dart`

**Modifiche**:
```dart
enum ExerciseCountingMode {
  weighted,  // Weight + reps (panca, squat, stacco)
  reps,      // Bodyweight - reps only (push-ups, pull-ups)
  time;      // Time-based (plank, wall sit)

  // ✅ Helper methods
  bool get requiresWeight => this == ExerciseCountingMode.weighted;
  bool get requiresReps => this == ExerciseCountingMode.weighted || this == ExerciseCountingMode.reps;
  bool get requiresTime => this == ExerciseCountingMode.time;

  // ✅ Display names (localized)
  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case weighted: return l10n.countingModeWeighted;
      case reps: return l10n.countingModeReps;
      case time: return l10n.countingModeTime;
    }
  }

  // ✅ Icon per UI
  IconData get icon {
    switch (this) {
      case weighted: return Icons.fitness_center;
      case reps: return Icons.repeat;
      case time: return Icons.timer;
    }
  }

  // ✅ Color per UI
  Color getColor(ColorScheme colorScheme) {
    switch (this) {
      case weighted: return colorScheme.primary;
      case reps: return colorScheme.secondary;
      case time: return colorScheme.tertiary;
    }
  }
}
```

**Test da creare**: `test/features/exercise_database/domain/entities/exercise_counting_mode_test.dart`
```dart
void main() {
  group('ExerciseCountingMode', () {
    test('requiresWeight should be true only for weighted', () {
      expect(ExerciseCountingMode.weighted.requiresWeight, true);
      expect(ExerciseCountingMode.reps.requiresWeight, false);
      expect(ExerciseCountingMode.time.requiresWeight, false);
    });

    test('requiresReps should be true for weighted and reps', () {
      expect(ExerciseCountingMode.weighted.requiresReps, true);
      expect(ExerciseCountingMode.reps.requiresReps, true);
      expect(ExerciseCountingMode.time.requiresReps, false);
    });

    test('requiresTime should be true only for time', () {
      expect(ExerciseCountingMode.weighted.requiresTime, false);
      expect(ExerciseCountingMode.reps.requiresTime, false);
      expect(ExerciseCountingMode.time.requiresTime, true);
    });
  });
}
```

---

#### Task 1.2: Aggiungere countingMode a Exercise (workout entity)

**File**: `lib/features/workout/domain/entities/exercise.dart`

**Modifiche**:
```dart
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

class Exercise {
  // ... campi esistenti ...
  final ExerciseCountingMode countingMode; // ✅ NUOVO

  Exercise({
    // ... parametri esistenti ...
    this.countingMode = ExerciseCountingMode.weighted, // Default
  });

  Exercise copyWith({
    // ... parametri esistenti ...
    ExerciseCountingMode? countingMode,
  }) {
    return Exercise(
      // ... copia campi esistenti ...
      countingMode: countingMode ?? this.countingMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ... campi esistenti ...
      'countingMode': countingMode.name, // ✅ NUOVO
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      // ... campi esistenti ...
      countingMode: json['countingMode'] != null
          ? ExerciseCountingMode.values.firstWhere(
              (e) => e.name == json['countingMode'],
              orElse: () => ExerciseCountingMode.weighted,
            )
          : ExerciseCountingMode.weighted, // ✅ NUOVO
    );
  }
}
```

**Test da creare**: `test/features/workout/domain/entities/exercise_counting_mode_integration_test.dart`
```dart
void main() {
  group('Exercise with countingMode', () {
    test('should create exercise with default counting mode', () {
      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      expect(exercise.countingMode, ExerciseCountingMode.weighted);
    });

    test('should create exercise with explicit counting mode', () {
      final exercise = Exercise(
        name: 'Push-ups',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        countingMode: ExerciseCountingMode.reps,
      );

      expect(exercise.countingMode, ExerciseCountingMode.reps);
    });

    test('should serialize and deserialize counting mode', () {
      final exercise = Exercise(
        name: 'Plank',
        type: ExerciseType.single,
        category: ExerciseCategory.abs,
        countingMode: ExerciseCountingMode.time,
      );

      final json = exercise.toJson();
      expect(json['countingMode'], 'time');

      final deserialized = Exercise.fromJson(json);
      expect(deserialized.countingMode, ExerciseCountingMode.time);
    });
  });
}
```

---

#### Task 1.3: Aggiungere validazione e helper a ExerciseSet

**File**: `lib/features/workout/domain/entities/exercise.dart`

**Modifiche**:
```dart
class ExerciseSet {
  // ... campi esistenti (weight, reps, seconds, actualReps, rpe, etc.) ...

  // ✅ NUOVO: Validazione per countingMode
  bool isValidFor(ExerciseCountingMode mode) {
    switch (mode) {
      case ExerciseCountingMode.weighted:
        return weight != null && weight! > 0 && reps != null && reps! > 0;
      case ExerciseCountingMode.reps:
        return reps != null && reps! > 0;
      case ExerciseCountingMode.time:
        return seconds != null && seconds! > 0;
    }
  }

  // ✅ NUOVO: Calcolo volume generico
  double calculateVolume(ExerciseCountingMode mode) {
    switch (mode) {
      case ExerciseCountingMode.weighted:
        return (weight ?? 0) * (actualReps ?? reps ?? 0);
      case ExerciseCountingMode.reps:
        return (actualReps ?? reps ?? 0).toDouble();
      case ExerciseCountingMode.time:
        return (seconds ?? 0).toDouble();
    }
  }

  // ✅ MODIFICATO: Override volume getter per usare il nuovo metodo
  // (Richiede countingMode come parametro o contesto)
  // Per backward compatibility, manteniamo il vecchio getter
  @override
  double get volume {
    // Default weighted behavior
    final effectiveReps = actualReps ?? reps ?? 0;
    final effectiveWeight = weight ?? 0.0;
    return effectiveWeight * effectiveReps;
  }

  // ✅ NUOVO: Text display per UI
  String getDisplayText(ExerciseCountingMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ExerciseCountingMode.weighted:
        final w = weight?.toStringAsFixed(1) ?? '0';
        final r = actualReps ?? reps ?? 0;
        return '$w kg × $r reps';
      case ExerciseCountingMode.reps:
        final r = actualReps ?? reps ?? 0;
        return '$r reps';
      case ExerciseCountingMode.time:
        final s = seconds ?? 0;
        final minutes = s ~/ 60;
        final secs = s % 60;
        if (minutes > 0) {
          return '$minutes:${secs.toString().padLeft(2, '0')} min';
        }
        return '$s sec';
    }
  }
}
```

**Test da creare**: `test/features/workout/domain/entities/exercise_set_counting_mode_test.dart`
```dart
void main() {
  group('ExerciseSet validation with countingMode', () {
    test('should validate weighted set', () {
      final set = ExerciseSet(
        setNumber: 1,
        weight: 80.0,
        reps: 10,
      );

      expect(set.isValidFor(ExerciseCountingMode.weighted), true);
      expect(set.isValidFor(ExerciseCountingMode.reps), true); // reps presente
      expect(set.isValidFor(ExerciseCountingMode.time), false); // seconds mancante
    });

    test('should validate reps-only set', () {
      final set = ExerciseSet(
        setNumber: 1,
        reps: 15,
      );

      expect(set.isValidFor(ExerciseCountingMode.weighted), false); // weight mancante
      expect(set.isValidFor(ExerciseCountingMode.reps), true);
      expect(set.isValidFor(ExerciseCountingMode.time), false);
    });

    test('should validate time-based set', () {
      final set = ExerciseSet(
        setNumber: 1,
        seconds: 60,
      );

      expect(set.isValidFor(ExerciseCountingMode.weighted), false);
      expect(set.isValidFor(ExerciseCountingMode.reps), false);
      expect(set.isValidFor(ExerciseCountingMode.time), true);
    });
  });

  group('ExerciseSet volume calculation', () {
    test('should calculate volume for weighted exercise', () {
      final set = ExerciseSet(
        setNumber: 1,
        weight: 80.0,
        reps: 10,
        actualReps: 12,
      );

      expect(set.calculateVolume(ExerciseCountingMode.weighted), 80.0 * 12);
    });

    test('should calculate volume for reps-only exercise', () {
      final set = ExerciseSet(
        setNumber: 1,
        reps: 10,
        actualReps: 15,
      );

      expect(set.calculateVolume(ExerciseCountingMode.reps), 15.0);
    });

    test('should calculate volume for time-based exercise', () {
      final set = ExerciseSet(
        setNumber: 1,
        seconds: 90,
      );

      expect(set.calculateVolume(ExerciseCountingMode.time), 90.0);
    });
  });
}
```

---

#### Task 1.4: Aggiungere countingMode a Exercise (database entity) - OPZIONALE

**File**: `lib/features/exercise_database/domain/entities/exercise.dart`

**Motivazione**: Sarebbe ideale avere countingMode già nel database degli esercizi, così da non doverlo rilevare con euristiche.

**Modifiche**:
```dart
@HiveType(typeId: 2)
class Exercise extends Equatable {
  // ... campi esistenti ...

  @HiveField(24) // ✅ Prossimo campo disponibile
  final ExerciseCountingMode? countingMode; // Nullable per backward compatibility

  Exercise({
    // ... parametri esistenti ...
    this.countingMode,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      // ... campi esistenti ...
      countingMode: json['countingMode'] != null
          ? ExerciseCountingMode.values.firstWhere(
              (e) => e.name == json['countingMode'],
              orElse: () => null,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ... campi esistenti ...
      if (countingMode != null) 'countingMode': countingMode!.name,
    };
  }
}
```

**NOTA**: Questo richiede:
- Aggiornare il CSV con la nuova colonna `countingMode`
- Rigenerare Hive adapter: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- Migrare dati esistenti

---

### 📦 FASE 2: Service Layer - ExerciseCountingModeService

**Obiettivo**: Creare un service per rilevare automaticamente il countingMode

#### Task 2.1: Creare ExerciseCountingModeService

**File**: `lib/features/exercise_database/domain/services/exercise_counting_mode_service.dart`

**Contenuto**:
```dart
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

/// Service per rilevare automaticamente il counting mode di un esercizio
class ExerciseCountingModeService {
  // ✅ Time-based exercises keywords
  static const _timeBasedKeywords = [
    'plank',
    'wall sit',
    'hollow hold',
    'l-sit',
    'dead hang',
    'front lever',
    'back lever',
    'horse stance',
    'isometric',
  ];

  // ✅ Bodyweight exercises keywords
  static const _bodyweightKeywords = [
    'push-up',
    'pull-up',
    'chin-up',
    'dip',
    'muscle-up',
    'handstand',
    'pistol squat',
    'nordic curl',
  ];

  // ✅ Weighted exercises equipment
  static const _weightedEquipment = [
    'bilanciere',
    'barbell',
    'manubri',
    'dumbbells',
    'kettlebell',
    'macchina',
    'machine',
  ];

  /// Rileva il counting mode da un esercizio del database
  static ExerciseCountingMode detectFromDatabaseExercise(Exercise exercise) {
    // Priorità 1: Se l'esercizio ha già countingMode → usa quello
    if (exercise.countingMode != null) {
      return exercise.countingMode!;
    }

    // Priorità 2: Analizza nome
    final lowerName = exercise.nome.toLowerCase();

    // Check time-based
    for (final keyword in _timeBasedKeywords) {
      if (lowerName.contains(keyword)) {
        return ExerciseCountingMode.time;
      }
    }

    // Check bodyweight
    for (final keyword in _bodyweightKeywords) {
      if (lowerName.contains(keyword)) {
        return ExerciseCountingMode.reps;
      }
    }

    // Priorità 3: Analizza attrezzatura
    final lowerEquipment = exercise.attrezzatura.toLowerCase();

    if (lowerEquipment.contains('corpo libero') || lowerEquipment.contains('bodyweight')) {
      return ExerciseCountingMode.reps;
    }

    for (final equipment in _weightedEquipment) {
      if (lowerEquipment.contains(equipment)) {
        return ExerciseCountingMode.weighted;
      }
    }

    // Default: weighted (la maggior parte degli esercizi)
    return ExerciseCountingMode.weighted;
  }

  /// Crea set di default in base al counting mode
  static List<Map<String, dynamic>> createDefaultSets(
    ExerciseCountingMode mode,
    int count,
  ) {
    switch (mode) {
      case ExerciseCountingMode.weighted:
        return List.generate(
          count,
          (i) => {
            'setNumber': i + 1,
            'weight': 0.0,
            'reps': 10,
          },
        );
      case ExerciseCountingMode.reps:
        return List.generate(
          count,
          (i) => {
            'setNumber': i + 1,
            'reps': 10,
          },
        );
      case ExerciseCountingMode.time:
        return List.generate(
          count,
          (i) => {
            'setNumber': i + 1,
            'seconds': 60, // 1 minuto default
          },
        );
    }
  }

  /// Suggerisci valori di default per un nuovo set
  static Map<String, dynamic> suggestDefaultValues(
    ExerciseCountingMode mode, {
    Map<String, dynamic>? previousSet,
  }) {
    switch (mode) {
      case ExerciseCountingMode.weighted:
        return {
          'weight': previousSet?['weight'] ?? 20.0,
          'reps': previousSet?['reps'] ?? 10,
        };
      case ExerciseCountingMode.reps:
        return {
          'reps': previousSet?['reps'] ?? 10,
        };
      case ExerciseCountingMode.time:
        return {
          'seconds': previousSet?['seconds'] ?? 60,
        };
    }
  }
}
```

**Test da creare**: `test/features/exercise_database/domain/services/exercise_counting_mode_service_test.dart`
```dart
void main() {
  group('ExerciseCountingModeService.detectFromDatabaseExercise', () {
    test('should detect time-based from name', () {
      final exercise = Exercise(
        id: '1',
        nome: 'Plank',
        focus: ['CORE'],
        muscoliSecondari: [],
        difficolta: 'Intermedio',
        tipoEsercizio: 'Isolamento',
        attrezzatura: 'Corpo Libero',
        patternMovimento: 'Core Stability',
        rangeRipetizioni: '30-90 secondi',
      );

      expect(
        ExerciseCountingModeService.detectFromDatabaseExercise(exercise),
        ExerciseCountingMode.time,
      );
    });

    test('should detect reps-only from name', () {
      final exercise = Exercise(
        id: '2',
        nome: 'Push-up',
        focus: ['PETT'],
        muscoliSecondari: ['TRIC'],
        difficolta: 'Principiante',
        tipoEsercizio: 'Compound',
        attrezzatura: 'Corpo Libero',
        patternMovimento: 'Push',
        rangeRipetizioni: '10-20',
      );

      expect(
        ExerciseCountingModeService.detectFromDatabaseExercise(exercise),
        ExerciseCountingMode.reps,
      );
    });

    test('should detect weighted from equipment', () {
      final exercise = Exercise(
        id: '3',
        nome: 'Panca Piana',
        focus: ['PETT'],
        muscoliSecondari: ['TRIC', 'DELT'],
        difficolta: 'Intermedio',
        tipoEsercizio: 'Compound',
        attrezzatura: 'Bilanciere',
        patternMovimento: 'Push',
        rangeRipetizioni: '6-12',
      );

      expect(
        ExerciseCountingModeService.detectFromDatabaseExercise(exercise),
        ExerciseCountingMode.weighted,
      );
    });

    test('should default to weighted for unknown exercises', () {
      final exercise = Exercise(
        id: '4',
        nome: 'Esercizio Sconosciuto',
        focus: ['OTHER'],
        muscoliSecondari: [],
        difficolta: 'Intermedio',
        tipoEsercizio: 'Compound',
        attrezzatura: 'Vario',
        patternMovimento: 'Mixed',
        rangeRipetizioni: '8-12',
      );

      expect(
        ExerciseCountingModeService.detectFromDatabaseExercise(exercise),
        ExerciseCountingMode.weighted,
      );
    });
  });

  group('ExerciseCountingModeService.createDefaultSets', () {
    test('should create weighted sets', () {
      final sets = ExerciseCountingModeService.createDefaultSets(
        ExerciseCountingMode.weighted,
        3,
      );

      expect(sets.length, 3);
      expect(sets[0]['weight'], 0.0);
      expect(sets[0]['reps'], 10);
      expect(sets[0]['seconds'], null);
    });

    test('should create reps-only sets', () {
      final sets = ExerciseCountingModeService.createDefaultSets(
        ExerciseCountingMode.reps,
        3,
      );

      expect(sets.length, 3);
      expect(sets[0]['weight'], null);
      expect(sets[0]['reps'], 10);
      expect(sets[0]['seconds'], null);
    });

    test('should create time-based sets', () {
      final sets = ExerciseCountingModeService.createDefaultSets(
        ExerciseCountingMode.time,
        3,
      );

      expect(sets.length, 3);
      expect(sets[0]['weight'], null);
      expect(sets[0]['reps'], null);
      expect(sets[0]['seconds'], 60);
    });
  });
}
```

---

### 📦 FASE 3: Presentation Layer - UI Components

**Obiettivo**: Adattare tutti i componenti UI per supportare i tre tipi di esercizi

---

#### Task 3.1: ExerciseCustomizationScreen - Rilevamento e configurazione

**File**: `lib/features/exercise_database/presentation/widgets/exercise_customization_screen.dart`

**Modifiche principali**:

1. **Rilevare countingMode per ogni esercizio** (linea 35-45)
2. **Creare set appropriati** in base al tipo
3. **Adattare UI** per mostrare i campi corretti

**Codice modificato**:
```dart
class _ExerciseCustomizationScreenState extends ConsumerState<ExerciseCustomizationScreen> {
  late List<ExerciseCustomization> _customizations;

  @override
  void initState() {
    super.initState();

    // ✅ MODIFICATO: Rileva countingMode per ogni esercizio
    _customizations = widget.selectedExercises.map((exercise) {
      final countingMode = ExerciseCountingModeService.detectFromDatabaseExercise(exercise);

      return ExerciseCustomization(
        exercise: exercise,
        countingMode: countingMode, // ✅ NUOVO
        sets: _createDefaultSets(countingMode),
      );
    }).toList();
  }

  // ✅ NUOVO: Crea set in base al counting mode
  List<SetCustomization> _createDefaultSets(ExerciseCountingMode mode) {
    final defaultSets = ExerciseCountingModeService.createDefaultSets(mode, 3);
    return defaultSets.map((setData) => SetCustomization.fromMap(setData)).toList();
  }

  // ✅ MODIFICATO: Adatta set row in base al counting mode
  Widget _buildSetRow(int exerciseIndex, int setIndex, SetCustomization setCustomization) {
    final customization = _customizations[exerciseIndex];
    final mode = customization.countingMode;

    return Row(
      children: [
        // Set number
        Container(
          width: 40,
          child: Text('${setIndex + 1}', style: context.textTheme.titleMedium),
        ),

        const SizedBox(width: 8),

        // ✅ Mostra weight solo se necessario
        if (mode.requiresWeight) ...[
          Expanded(
            flex: 2,
            child: _buildWeightInput(exerciseIndex, setIndex),
          ),
          const SizedBox(width: 8),
        ],

        // ✅ Mostra reps solo se necessario
        if (mode.requiresReps) ...[
          Expanded(
            flex: 1,
            child: _buildRepsInput(exerciseIndex, setIndex),
          ),
          const SizedBox(width: 8),
        ],

        // ✅ Mostra time solo se necessario
        if (mode.requiresTime) ...[
          Expanded(
            flex: 2,
            child: _buildTimeInput(exerciseIndex, setIndex),
          ),
          const SizedBox(width: 8),
        ],

        // Delete button
        IconButton(
          onPressed: () => _removeSet(exerciseIndex, setIndex),
          icon: const Icon(Icons.close, size: 20),
        ),
      ],
    );
  }

  // ✅ NUOVO: Time input per esercizi time-based
  Widget _buildTimeInput(int exerciseIndex, int setIndex) {
    final set = _customizations[exerciseIndex].sets[setIndex];
    final minutes = (set.seconds ?? 0) ~/ 60;
    final seconds = (set.seconds ?? 0) % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Minutes
          SizedBox(
            width: 40,
            child: TextField(
              controller: TextEditingController(text: minutes.toString()),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '0',
              ),
              onChanged: (value) {
                final min = int.tryParse(value) ?? 0;
                final totalSeconds = min * 60 + seconds;
                _updateSetTime(exerciseIndex, setIndex, totalSeconds);
              },
            ),
          ),
          Text(':', style: context.textTheme.titleMedium),
          // Seconds
          SizedBox(
            width: 40,
            child: TextField(
              controller: TextEditingController(text: seconds.toString().padLeft(2, '0')),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '00',
              ),
              onChanged: (value) {
                final sec = int.tryParse(value) ?? 0;
                final totalSeconds = minutes * 60 + sec;
                _updateSetTime(exerciseIndex, setIndex, totalSeconds);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateSetTime(int exerciseIndex, int setIndex, int totalSeconds) {
    setState(() {
      final set = _customizations[exerciseIndex].sets[setIndex];
      _customizations[exerciseIndex].sets[setIndex] = set.copyWith(seconds: totalSeconds);
    });
  }

  // ✅ MODIFICATO: Aggiunge esercizio con countingMode corretto
  void _addAllToWorkout() {
    final workoutNotifier = ref.read(currentWorkoutProvider.notifier);

    for (final customization in _customizations) {
      // Converti da Exercise (database) a Exercise (workout)
      final workoutExercise = WorkoutExercise.Exercise(
        name: customization.exercise.nome,
        type: WorkoutExercise.ExerciseType.single,
        category: _convertCategory(customization.exercise.focus),
        countingMode: customization.countingMode, // ✅ NUOVO
        sets: customization.sets.map((set) {
          return WorkoutExercise.ExerciseSet(
            setNumber: set.setNumber,
            weight: set.weight,
            reps: set.reps,
            seconds: set.seconds, // ✅ NUOVO
          );
        }).toList(),
      );

      workoutNotifier.addExercise(workoutExercise);
    }

    // Navigate back
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/');
    }
  }
}

// ✅ NUOVO: Model class aggiornato
class ExerciseCustomization {
  final Exercise exercise;
  final ExerciseCountingMode countingMode; // ✅ NUOVO
  final List<SetCustomization> sets;

  ExerciseCustomization({
    required this.exercise,
    required this.countingMode,
    required this.sets,
  });
}

class SetCustomization {
  final int setNumber;
  final double? weight;
  final int? reps;
  final int? seconds; // ✅ NUOVO

  SetCustomization({
    required this.setNumber,
    this.weight,
    this.reps,
    this.seconds,
  });

  factory SetCustomization.fromMap(Map<String, dynamic> map) {
    return SetCustomization(
      setNumber: map['setNumber'],
      weight: map['weight']?.toDouble(),
      reps: map['reps'],
      seconds: map['seconds'],
    );
  }

  SetCustomization copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    int? seconds,
  }) {
    return SetCustomization(
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      seconds: seconds ?? this.seconds,
    );
  }
}
```

**Test da creare**: `test/features/exercise_database/presentation/widgets/exercise_customization_screen_test.dart`
```dart
void main() {
  group('ExerciseCustomizationScreen counting mode detection', () {
    testWidgets('should detect and show weight+reps for weighted exercise', (tester) async {
      final exercise = Exercise(
        id: '1',
        nome: 'Bench Press',
        focus: ['PETT'],
        // ... altri campi
        attrezzatura: 'Bilanciere',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ExerciseCustomizationScreen(
            selectedExercises: [exercise],
          ),
        ),
      );

      // Verifica presenza campi weight + reps
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Reps'), findsOneWidget);
      expect(find.text('Time'), findsNothing);
    });

    testWidgets('should detect and show only reps for bodyweight exercise', (tester) async {
      final exercise = Exercise(
        id: '2',
        nome: 'Push-ups',
        focus: ['PETT'],
        // ... altri campi
        attrezzatura: 'Corpo Libero',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ExerciseCustomizationScreen(
            selectedExercises: [exercise],
          ),
        ),
      );

      // Verifica solo reps presente
      expect(find.text('Weight'), findsNothing);
      expect(find.text('Reps'), findsOneWidget);
      expect(find.text('Time'), findsNothing);
    });

    testWidgets('should detect and show time for time-based exercise', (tester) async {
      final exercise = Exercise(
        id: '3',
        nome: 'Plank',
        focus: ['CORE'],
        // ... altri campi
        attrezzatura: 'Corpo Libero',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ExerciseCustomizationScreen(
            selectedExercises: [exercise],
          ),
        ),
      );

      // Verifica solo time presente
      expect(find.text('Weight'), findsNothing);
      expect(find.text('Reps'), findsNothing);
      expect(find.text('Time'), findsOneWidget);
    });
  });
}
```

---

#### Task 3.2: UnifiedSetInputModal - Adattamento UI

**File**: `lib/features/workout/presentation/widgets/unified_set_input_modal.dart`

**Modifiche principali**:

1. **Aggiungere controller per seconds** (linea 158)
2. **Aggiungere _buildTimePicker** widget
3. **Mostrare/nascondere campi** in base a countingMode
4. **Salvare correttamente** i valori

**Codice modificato**:
```dart
class _UnifiedSetInputModalState extends ConsumerState<UnifiedSetInputModal>
    with TickerProviderStateMixin {
  // Controllers esistenti
  late FixedExtentScrollController _weightController;
  late FixedExtentScrollController _repsController;
  late FixedExtentScrollController _minutesController; // ✅ NUOVO
  late FixedExtentScrollController _secondsController; // ✅ NUOVO

  // Values
  double _selectedWeight = 0.0;
  int _selectedReps = 0;
  int _selectedSeconds = 0; // ✅ NUOVO (total seconds)
  int? _selectedRpe;
  int? _calculatedRir;
  bool _isCompleted = false;

  // ✅ NUOVO: Ottieni countingMode
  ExerciseCountingMode get _countingMode {
    if (widget.exercise != null) {
      return widget.exercise!.countingMode;
    }
    return ExerciseCountingMode.weighted; // Default
  }

  @override
  void initState() {
    super.initState();

    // Initialize single exercise values
    _selectedWeight = widget.exerciseSet.weight ?? widget.previousSet?.weight ?? 20.0;
    _selectedReps = widget.exerciseSet.reps ?? widget.previousSet?.reps ?? 10;
    _selectedSeconds = widget.exerciseSet.seconds ?? widget.previousSet?.seconds ?? 60; // ✅ NUOVO
    _selectedRpe = widget.exerciseSet.rpe;
    _isCompleted = widget.exerciseSet.isCompleted;

    _updateRir();

    // Initialize scroll controllers
    final weightIndex = (_selectedWeight * 2).round().clamp(0, 400);
    final repsIndex = (_selectedReps - 1).clamp(0, 49);
    final minutes = _selectedSeconds ~/ 60;
    final seconds = _selectedSeconds % 60;

    _weightController = FixedExtentScrollController(initialItem: weightIndex);
    _repsController = FixedExtentScrollController(initialItem: repsIndex);
    _minutesController = FixedExtentScrollController(initialItem: minutes.clamp(0, 10)); // ✅ NUOVO (max 10 min)
    _secondsController = FixedExtentScrollController(initialItem: seconds); // ✅ NUOVO

    // ... resto initState ...
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _minutesController.dispose(); // ✅ NUOVO
    _secondsController.dispose(); // ✅ NUOVO
    // ... resto dispose ...
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 20),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              // ... styling ...
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildHeader(),

                  const SizedBox(height: 24),

                  // ✅ MODIFICATO: Mostra solo i campi necessari
                  if (_countingMode.requiresWeight) _buildWeightPicker(),
                  if (_countingMode.requiresWeight && _countingMode.requiresReps)
                    const SizedBox(height: 16),
                  if (_countingMode.requiresReps) _buildRepsPicker(),
                  if (_countingMode.requiresTime) _buildTimePicker(), // ✅ NUOVO

                  const SizedBox(height: 24),

                  // RPE Selector (sempre presente)
                  _buildRpeSelector(),

                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ NUOVO: Time picker per esercizi time-based
  Widget _buildTimePicker() {
    return Column(
      children: [
        // Label
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer, color: context.colors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              context.l10n.duration,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Picker
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.outline.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              // Minutes picker
              Expanded(
                child: CupertinoPicker(
                  scrollController: _minutesController,
                  itemExtent: 44,
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      final minutes = index;
                      final seconds = _selectedSeconds % 60;
                      _selectedSeconds = minutes * 60 + seconds;
                    });
                  },
                  children: List.generate(11, (index) {
                    return Center(
                      child: Text(
                        '$index',
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Text(':', style: context.textTheme.headlineMedium),

              // Seconds picker
              Expanded(
                child: CupertinoPicker(
                  scrollController: _secondsController,
                  itemExtent: 44,
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      final minutes = _selectedSeconds ~/ 60;
                      _selectedSeconds = minutes * 60 + index;
                    });
                  },
                  children: List.generate(60, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Quick time buttons
        Wrap(
          spacing: 8,
          children: [30, 45, 60, 90, 120].map((seconds) {
            final isSelected = _selectedSeconds == seconds;
            return ActionChip(
              label: Text(_formatTimeShort(seconds)),
              onPressed: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  _selectedSeconds = seconds;
                  _minutesController.jumpToItem(seconds ~/ 60);
                  _secondsController.jumpToItem(seconds % 60);
                });
              },
              backgroundColor: isSelected ? context.colors.primary : null,
              labelStyle: TextStyle(
                color: isSelected ? context.colors.onPrimary : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatTimeShort(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m${seconds > 0 ? ' ${seconds}s' : ''}';
    }
    return '${seconds}s';
  }

  // ✅ MODIFICATO: Salva valori corretti in base al counting mode
  void _handleSave() {
    ExerciseSet updatedSet;

    switch (_countingMode) {
      case ExerciseCountingMode.weighted:
        updatedSet = widget.exerciseSet.copyWith(
          weight: _selectedWeight,
          reps: _selectedReps,
          actualReps: _selectedReps, // Initial value
          rpe: _selectedRpe,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        break;
      case ExerciseCountingMode.reps:
        updatedSet = widget.exerciseSet.copyWith(
          reps: _selectedReps,
          actualReps: _selectedReps, // Initial value
          rpe: _selectedRpe,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        break;
      case ExerciseCountingMode.time:
        updatedSet = widget.exerciseSet.copyWith(
          seconds: _selectedSeconds,
          rpe: _selectedRpe,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        break;
    }

    widget.onSave(updatedSet);
    Navigator.of(context).pop();
  }
}
```

**Test da creare**: `test/features/workout/presentation/widgets/unified_set_input_modal_counting_mode_test.dart`
```dart
void main() {
  group('UnifiedSetInputModal with counting modes', () {
    testWidgets('should show weight+reps for weighted exercise', (tester) async {
      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        countingMode: ExerciseCountingMode.weighted,
      );

      final exerciseSet = ExerciseSet(
        setNumber: 1,
        weight: 80.0,
        reps: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedSetInputModal(
              exerciseSet: exerciseSet,
              onSave: (_) {},
              exerciseName: 'Bench Press',
              exercise: exercise,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica presenza weight + reps picker
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Reps'), findsOneWidget);
      expect(find.text('Duration'), findsNothing);
    });

    testWidgets('should show only reps for bodyweight exercise', (tester) async {
      final exercise = Exercise(
        name: 'Push-ups',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        countingMode: ExerciseCountingMode.reps,
      );

      final exerciseSet = ExerciseSet(
        setNumber: 1,
        reps: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedSetInputModal(
              exerciseSet: exerciseSet,
              onSave: (_) {},
              exerciseName: 'Push-ups',
              exercise: exercise,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica solo reps presente
      expect(find.text('Weight'), findsNothing);
      expect(find.text('Reps'), findsOneWidget);
      expect(find.text('Duration'), findsNothing);
    });

    testWidgets('should show time picker for time-based exercise', (tester) async {
      final exercise = Exercise(
        name: 'Plank',
        type: ExerciseType.single,
        category: ExerciseCategory.abs,
        countingMode: ExerciseCountingMode.time,
      );

      final exerciseSet = ExerciseSet(
        setNumber: 1,
        seconds: 60,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedSetInputModal(
              exerciseSet: exerciseSet,
              onSave: (_) {},
              exerciseName: 'Plank',
              exercise: exercise,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica solo time presente
      expect(find.text('Weight'), findsNothing);
      expect(find.text('Reps'), findsNothing);
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text(':'), findsOneWidget); // Separator minutes:seconds
    });

    testWidgets('should save correct values for time-based exercise', (tester) async {
      ExerciseSet? savedSet;

      final exercise = Exercise(
        name: 'Plank',
        type: ExerciseType.single,
        category: ExerciseCategory.abs,
        countingMode: ExerciseCountingMode.time,
      );

      final exerciseSet = ExerciseSet(
        setNumber: 1,
        seconds: 60,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedSetInputModal(
              exerciseSet: exerciseSet,
              onSave: (set) => savedSet = set,
              exerciseName: 'Plank',
              exercise: exercise,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Modifica time (es: 1 min 30 sec)
      // TODO: Simulare scroll sui pickers

      // Tap save button
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verifica set salvato
      expect(savedSet, isNotNull);
      expect(savedSet!.seconds, isNotNull);
      expect(savedSet!.weight, isNull);
      expect(savedSet!.reps, isNull);
    });
  });
}
```

---

#### Task 3.3: QuickEditOverlayV2 - Adattamento pickers

**File**: `lib/features/workout/presentation/widgets/quick_edit_overlay_v2.dart`

**Modifiche principali**:

1. **Aggiungere controller per time** (linea 80-81)
2. **Rilevare countingMode** dall'exerciseSet
3. **Mostrare solo i pickers necessari**
4. **Gestire salvataggio corretto**

**Codice modificato**:
```dart
class QuickEditOverlayV2 extends ConsumerStatefulWidget {
  const QuickEditOverlayV2({
    super.key,
    this.exerciseSet,
    this.onSave,
    required this.onCancel,
    required this.position,
    this.previousSet,
    this.exerciseName,
    this.exerciseNames,
    this.exerciseSets,
    this.onSupersetSave,
    this.isSuperset = false,
    this.countingMode, // ✅ NUOVO: Passato dall'esterno
  });

  // ... campi esistenti ...
  final ExerciseCountingMode? countingMode; // ✅ NUOVO
}

class _QuickEditOverlayV2State extends ConsumerState<QuickEditOverlayV2>
    with SingleTickerProviderStateMixin {
  // Controllers esistenti
  late FixedExtentScrollController _weightController;
  late FixedExtentScrollController _repsController;
  late FixedExtentScrollController _minutesController; // ✅ NUOVO
  late FixedExtentScrollController _secondsController; // ✅ NUOVO

  // Values
  late double _selectedWeight;
  late int _selectedReps;
  late int _selectedSeconds; // ✅ NUOVO (total seconds)

  // ✅ NUOVO: Ottieni countingMode
  ExerciseCountingMode get _countingMode {
    return widget.countingMode ?? ExerciseCountingMode.weighted;
  }

  @override
  void initState() {
    super.initState();

    // ... calcolo posizione ...

    if (widget.isSuperset) {
      // ... logica superset ...
    } else {
      // Initialize single exercise values
      _selectedWeight = widget.exerciseSet!.weight ?? 0.0;
      _selectedReps = widget.exerciseSet!.reps ?? 0;
      _selectedSeconds = widget.exerciseSet!.seconds ?? 60; // ✅ NUOVO
    }

    // Controllers
    _weightController = FixedExtentScrollController(
      initialItem: (_selectedWeight * 2).round(),
    );
    _repsController = FixedExtentScrollController(
      initialItem: _selectedReps > 0 ? _selectedReps - 1 : 0,
    );
    _minutesController = FixedExtentScrollController(
      initialItem: (_selectedSeconds ~/ 60).clamp(0, 10),
    ); // ✅ NUOVO
    _secondsController = FixedExtentScrollController(
      initialItem: (_selectedSeconds % 60),
    ); // ✅ NUOVO

    // ... resto initState ...
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _minutesController.dispose(); // ✅ NUOVO
    _secondsController.dispose(); // ✅ NUOVO
    // ... resto dispose ...
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onCancel,
            child: Container(color: Colors.transparent),
          ),
        ),

        // Overlay card
        Positioned(
          left: _positioning.left,
          top: _positioning.top,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 340,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          _buildHeader(),

                          const SizedBox(height: 16),

                          // ✅ MODIFICATO: Mostra solo i picker necessari
                          if (_countingMode.requiresWeight)
                            _buildWeightPicker(),
                          if (_countingMode.requiresWeight && _countingMode.requiresReps)
                            const SizedBox(height: 12),
                          if (_countingMode.requiresReps)
                            _buildRepsPicker(),
                          if (_countingMode.requiresTime)
                            _buildTimePicker(), // ✅ NUOVO

                          const SizedBox(height: 16),

                          // Action buttons
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ✅ NUOVO: Time picker compatto
  Widget _buildTimePicker() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Minutes
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('min', style: context.textTheme.labelSmall),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _minutesController,
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        final seconds = _selectedSeconds % 60;
                        _selectedSeconds = index * 60 + seconds;
                      });
                    },
                    children: List.generate(11, (index) {
                      return Center(
                        child: Text(
                          '$index',
                          style: context.textTheme.headlineSmall,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          Text(':', style: context.textTheme.headlineMedium),

          // Seconds
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('sec', style: context.textTheme.labelSmall),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _secondsController,
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        final minutes = _selectedSeconds ~/ 60;
                        _selectedSeconds = minutes * 60 + index;
                      });
                    },
                    children: List.generate(60, (index) {
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: context.textTheme.headlineSmall,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MODIFICATO: Salva valori corretti
  void _handleSave() {
    if (widget.isSuperset) {
      // ... logica superset ...
    } else {
      ExerciseSet updatedSet;

      switch (_countingMode) {
        case ExerciseCountingMode.weighted:
          updatedSet = widget.exerciseSet!.copyWith(
            weight: _selectedWeight,
            reps: _selectedReps,
          );
          break;
        case ExerciseCountingMode.reps:
          updatedSet = widget.exerciseSet!.copyWith(
            reps: _selectedReps,
          );
          break;
        case ExerciseCountingMode.time:
          updatedSet = widget.exerciseSet!.copyWith(
            seconds: _selectedSeconds,
          );
          break;
      }

      widget.onSave!(updatedSet);
    }

    widget.onCancel();
  }
}
```

**Test da creare**: `test/features/workout/presentation/widgets/quick_edit_overlay_v2_counting_mode_test.dart`
```dart
void main() {
  group('QuickEditOverlayV2 with counting modes', () {
    testWidgets('should show weight+reps pickers for weighted exercise', (tester) async {
      final exerciseSet = ExerciseSet(
        setNumber: 1,
        weight: 80.0,
        reps: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickEditOverlayV2(
              exerciseSet: exerciseSet,
              onSave: (_) {},
              onCancel: () {},
              position: const Offset(100, 100),
              countingMode: ExerciseCountingMode.weighted,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica presenza weight + reps pickers
      expect(find.text('kg'), findsOneWidget);
      expect(find.text('reps'), findsOneWidget);
    });

    testWidgets('should show only reps picker for bodyweight exercise', (tester) async {
      final exerciseSet = ExerciseSet(
        setNumber: 1,
        reps: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickEditOverlayV2(
              exerciseSet: exerciseSet,
              onSave: (_) {},
              onCancel: () {},
              position: const Offset(100, 100),
              countingMode: ExerciseCountingMode.reps,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica solo reps presente
      expect(find.text('reps'), findsOneWidget);
    });

    testWidgets('should show time picker for time-based exercise', (tester) async {
      final exerciseSet = ExerciseSet(
        setNumber: 1,
        seconds: 90,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickEditOverlayV2(
              exerciseSet: exerciseSet,
              onSave: (_) {},
              onCancel: () {},
              position: const Offset(100, 100),
              countingMode: ExerciseCountingMode.time,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica time picker presente
      expect(find.text('min'), findsOneWidget);
      expect(find.text('sec'), findsOneWidget);
      expect(find.text(':'), findsOneWidget);
    });
  });
}
```

---

#### Task 3.4: EditSetModal - Long Press Edit

**File**: `lib/features/workout/presentation/widgets/edit_set_modal.dart`

**Modifiche principali**:

1. **Aggiungere parametro countingMode**
2. **Mostrare solo i campi necessari**
3. **Validare input correttamente**

**Codice modificato**:
```dart
class EditSetModal extends ConsumerStatefulWidget {
  const EditSetModal({
    super.key,
    required this.exerciseSet,
    required this.onSave,
    this.countingMode, // ✅ NUOVO
  });

  final ExerciseSet exerciseSet;
  final Function(ExerciseSet) onSave;
  final ExerciseCountingMode? countingMode; // ✅ NUOVO
}

class _EditSetModalState extends ConsumerState<EditSetModal> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _minutesController; // ✅ NUOVO
  late TextEditingController _secondsController; // ✅ NUOVO
  late TextEditingController _notesController;

  // ✅ NUOVO: Ottieni countingMode
  ExerciseCountingMode get _countingMode {
    return widget.countingMode ?? ExerciseCountingMode.weighted;
  }

  @override
  void initState() {
    super.initState();

    _weightController = TextEditingController(
      text: widget.exerciseSet.weight?.toString() ?? '0',
    );
    _repsController = TextEditingController(
      text: widget.exerciseSet.reps?.toString() ?? '0',
    );

    // ✅ NUOVO: Controllers per time
    final totalSeconds = widget.exerciseSet.seconds ?? 0;
    _minutesController = TextEditingController(
      text: (totalSeconds ~/ 60).toString(),
    );
    _secondsController = TextEditingController(
      text: (totalSeconds % 60).toString(),
    );

    _notesController = TextEditingController(
      text: widget.exerciseSet.notes ?? '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _minutesController.dispose(); // ✅ NUOVO
    _secondsController.dispose(); // ✅ NUOVO
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              context.l10n.editSet,
              style: context.textTheme.headlineSmall,
            ),

            const SizedBox(height: 24),

            // ✅ MODIFICATO: Mostra solo i campi necessari
            if (_countingMode.requiresWeight) ...[
              TextField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: context.l10n.weight,
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
            ],

            if (_countingMode.requiresReps) ...[
              TextField(
                controller: _repsController,
                decoration: InputDecoration(
                  labelText: context.l10n.reps,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
            ],

            if (_countingMode.requiresTime) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minutesController,
                      decoration: InputDecoration(
                        labelText: context.l10n.minutes,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _secondsController,
                      decoration: InputDecoration(
                        labelText: context.l10n.seconds,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Notes (sempre presente)
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: context.l10n.notes,
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleSave,
                  child: Text(context.l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    ExerciseSet updatedSet;

    switch (_countingMode) {
      case ExerciseCountingMode.weighted:
        final weight = double.tryParse(_weightController.text) ?? 0.0;
        final reps = int.tryParse(_repsController.text) ?? 0;

        updatedSet = widget.exerciseSet.copyWith(
          weight: weight,
          reps: reps,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        break;

      case ExerciseCountingMode.reps:
        final reps = int.tryParse(_repsController.text) ?? 0;

        updatedSet = widget.exerciseSet.copyWith(
          reps: reps,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        break;

      case ExerciseCountingMode.time:
        final minutes = int.tryParse(_minutesController.text) ?? 0;
        final seconds = int.tryParse(_secondsController.text) ?? 0;
        final totalSeconds = minutes * 60 + seconds;

        updatedSet = widget.exerciseSet.copyWith(
          seconds: totalSeconds,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        break;
    }

    widget.onSave(updatedSet);
    Navigator.of(context).pop();
  }
}
```

**Test da creare**: `test/features/workout/presentation/widgets/edit_set_modal_counting_mode_test.dart`

---

#### Task 3.5: ExerciseListItem - Passare countingMode ai modal

**File**: `lib/features/workout/presentation/widgets/exercise_list_item.dart`

**Modifiche alla riga ~2004** (long press handler):

```dart
// ✅ MODIFICATO: Passa countingMode ai modal
GestureDetector(
  onTap: () {
    // ... tap handler esistente ...
  },
  onLongPress: widget.onSetUpdate != null
      ? () {
          HapticFeedback.mediumImpact();

          // ✅ NUOVO: Ottieni countingMode dall'esercizio
          final countingMode = widget.exercise.countingMode;

          showDialog(
            context: context,
            builder: (context) => EditSetModal(
              exerciseSet: set,
              countingMode: countingMode, // ✅ NUOVO
              onSave: (updatedSet) {
                widget.onSetUpdate?.call(updatedSet);
              },
            ),
          );
        }
      : null,
  child: _buildSetCard(set, setIndex),
)
```

---

### 📦 FASE 4: Localizzazione

**Obiettivo**: Aggiungere tutte le stringhe localizzate necessarie

#### Task 4.1: Aggiungere stringhe ARB

**Files**:
- `assets/i18n/app_en.arb`
- `assets/i18n/app_it.arb`

**Stringhe da aggiungere**:

```json
// app_en.arb
{
  // ... stringhe esistenti ...

  "countingModeWeighted": "Weight + Reps",
  "countingModeReps": "Reps Only",
  "countingModeTime": "Time-Based",
  "duration": "Duration",
  "minutes": "Minutes",
  "seconds": "Seconds",
  "timeFormat": "{minutes}:{seconds}",
  "timeShortFormat": "{value}s",
  "timeShortMinutesFormat": "{minutes}m {seconds}s"
}
```

```json
// app_it.arb
{
  // ... stringhe esistenti ...

  "countingModeWeighted": "Peso + Ripetizioni",
  "countingModeReps": "Solo Ripetizioni",
  "countingModeTime": "A Tempo",
  "duration": "Durata",
  "minutes": "Minuti",
  "seconds": "Secondi",
  "timeFormat": "{minutes}:{seconds}",
  "timeShortFormat": "{value}s",
  "timeShortMinutesFormat": "{minutes}m {seconds}s"
}
```

Dopo aver aggiunto le stringhe, rigenerare:
```bash
flutter gen-l10n
```

---

### 📦 FASE 5: Integration Tests

**Obiettivo**: Creare test end-to-end per verificare tutto il flusso

#### Task 5.1: Test completo flusso weighted exercise

**File**: `test/integration/weighted_exercise_flow_test.dart`

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Weighted Exercise Flow', () {
    testWidgets('complete flow from insert to completion', (tester) async {
      // 1. Launch app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // 2. Navigate to exercise database
      await tester.tap(find.text('Exercise Database'));
      await tester.pumpAndSettle();

      // 3. Select weighted exercise (Bench Press)
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();

      // 4. Customize (should show weight + reps)
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Reps'), findsOneWidget);

      // 5. Add to workout
      await tester.tap(find.text('Add to Workout'));
      await tester.pumpAndSettle();

      // 6. Start workout
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      // 7. Complete first set (should show weight + reps modal)
      await tester.tap(find.text('Set 1'));
      await tester.pumpAndSettle();

      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Reps'), findsOneWidget);

      // 8. Save set
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // 9. Verify set completed
      expect(find.text('✓'), findsOneWidget);
    });
  });
}
```

#### Task 5.2: Test completo flusso reps-only exercise

**File**: `test/integration/reps_only_exercise_flow_test.dart`

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Reps-Only Exercise Flow', () {
    testWidgets('complete flow for bodyweight exercise', (tester) async {
      // Similar to above but for Push-ups
      // Verify only reps field is shown
    });
  });
}
```

#### Task 5.3: Test completo flusso time-based exercise

**File**: `test/integration/time_based_exercise_flow_test.dart`

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Time-Based Exercise Flow', () {
    testWidgets('complete flow for plank', (tester) async {
      // Similar to above but for Plank
      // Verify only time picker is shown
    });
  });
}
```

---

## ✅ Checklist Finale

Prima di considerare completa l'implementazione, verificare:

### Domain Layer
- [ ] `ExerciseCountingMode` ha helper methods
- [ ] `Exercise` (workout) ha `countingMode` field
- [ ] `ExerciseSet` ha metodi `isValidFor()` e `calculateVolume()`
- [ ] `ExerciseSet` ha `getDisplayText()` per UI
- [ ] Test unitari per tutte le entità (3 file)

### Service Layer
- [ ] `ExerciseCountingModeService` implementato
- [ ] Service rileva correttamente i tre tipi
- [ ] Test service (1 file)

### Presentation Layer
- [ ] `ExerciseCustomizationScreen` rileva e configura countingMode
- [ ] `UnifiedSetInputModal` adatta UI per i tre tipi
- [ ] `QuickEditOverlayV2` mostra picker corretti
- [ ] `EditSetModal` mostra campi corretti
- [ ] `ExerciseListItem` passa countingMode ai modal
- [ ] Test widget per tutti i componenti (5 file)

### Localization
- [ ] Stringhe aggiunte in `app_en.arb`
- [ ] Stringhe aggiunte in `app_it.arb`
- [ ] `flutter gen-l10n` eseguito

### Integration Tests
- [ ] Test flusso weighted exercise
- [ ] Test flusso reps-only exercise
- [ ] Test flusso time-based exercise

### Code Quality
- [ ] Nessun testo hardcoded
- [ ] Nessun colore hardcoded
- [ ] `flutter analyze` passa senza errori
- [ ] Tutti i test passano

---

## 🚀 Strategia di Esecuzione con Claude-Yes

Per eseguire questo piano con `claude-yes` (esecuzione automatica):

1. **Creare task separati** per ogni fase
2. **Eseguire in ordine sequenziale**:
   - FASE 1 (Domain) prima
   - FASE 2 (Service) dopo FASE 1
   - FASE 3 (Presentation) dopo FASE 2
   - FASE 4 (Localization) dopo FASE 3
   - FASE 5 (Tests) per ultimo

3. **Checkpoint dopo ogni fase**:
   - Eseguire `flutter analyze`
   - Eseguire test unitari
   - Verificare che l'app compili

4. **Rollback plan**: Se una fase fallisce, rollback con git

---

## 📊 Metriche di Successo

- ✅ **100% copertura** per le nuove entità domain
- ✅ **3 flussi end-to-end** funzionanti
- ✅ **0 errori** di `flutter analyze`
- ✅ **Tutti i test** passano (unit + widget + integration)
- ✅ **UI responsive** per tutti e tre i tipi
- ✅ **Backward compatibility** mantenuta per workout esistenti

---

## 🎯 Risultato Finale

Al termine di questa implementazione:

1. ✅ **Weighted exercises** (peso + reps) → funzionano perfettamente
2. ✅ **Reps-only exercises** (corpo libero) → mostrano solo reps
3. ✅ **Time-based exercises** (plank, isometric) → mostrano timer
4. ✅ **Tutto il flusso** dall'inserimento al completamento è corretto
5. ✅ **Test completi** garantiscono qualità del codice
6. ✅ **Nessun breaking change** per utenti esistenti

---

**Ultima modifica**: 2025-01-30
**Autore**: Claude (Anthropic)
**Versione piano**: 1.0
**Durata stimata implementazione**: 8-12 ore (con claude-yes)
**Righe di codice stimate**: ~2500 righe (inclusi test)
