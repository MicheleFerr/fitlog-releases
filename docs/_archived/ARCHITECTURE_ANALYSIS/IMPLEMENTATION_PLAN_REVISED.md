# 🎯 Advanced Workouts Refactoring - Piano di Implementazione Rivisto

**Data**: 2025-10-31
**Basato su**: Feedback consulente + analisi codice esistente
**Stato**: Ready for Implementation

---

## 📊 Executive Summary

Questo piano implementa il refactoring con le **raccomandazioni del consulente**, adattate alla **realtà del codice esistente**:

### ✅ Feedback Consulente (Applicati)
1. **Sealed classes** invece di abstract classes (compile-time safety)
2. **Schema versioning esplicito** nei document Firestore (`_schemaVersion`)
3. **Feature flag con factory pattern** (non if/else sparsi)
4. **Migration testing suite** con test per schema V1→V2
5. **Dry-run con Firestore emulator** prima del deploy production

### 🎯 Obiettivi Principali
- **Fix critico**: `SupersetExerciseData` senza `countingMode` support
- **Code reduction**: ~40% (da 3,300 a 2,000 linee)
- **Type safety**: Sealed classes + exhaustive pattern matching
- **Zero downtime**: Gradual rollout con feature flags

---

## 🔍 Analisi Codice Attuale

### Struttura Esistente

```dart
// ❌ PROBLEMA CRITICO: SupersetExerciseData senza countingMode
class SupersetExerciseData {
  final String exerciseId;
  final String exerciseName;
  final double? targetWeight;    // ❌ Solo weighted exercises
  final int? targetReps;          // ❌ Solo rep-based
  final double? actualWeight;
  final int? actualReps;
  final int? rpe;
  // ❌ MISSING: countingMode, targetSeconds, actualSeconds
}

// ✅ Base Exercise HA countingMode support
class Exercise {
  final ExerciseCountingMode countingMode; // weighted, reps, time
  final List<ExerciseSet> sets; // Set può avere weight, reps, o seconds
}
```

**Conseguenza**: Non puoi fare superset con plank (time-based) + push-ups (reps-based).

---

## 🚀 Piano di Implementazione (4 Fasi)

### 📌 Phase 0: Setup & Preparation (3 giorni)

#### 0.1 Setup Firestore Emulator
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Init emulators
firebase init emulators
# Select: Firestore, Authentication

# Export 50-100 real workouts from production
firebase firestore:export --project=gymbro-prod ./firestore_export

# Import into emulator for testing
firebase emulators:start --import=./firestore_export
```

#### 0.2 Feature Flag Infrastructure

**Crea file**: `lib/core/config/feature_flags.dart`

```dart
/// ✅ CONSULTANT RECOMMENDATION: Factory pattern, NO scattered if/else
abstract class ExecutionSheetFactory {
  Widget buildExecutionSheet(Exercise exercise);
}

/// New implementation with sealed classes
class UnifiedExecutionSheetFactory implements ExecutionSheetFactory {
  @override
  Widget buildExecutionSheet(Exercise exercise) {
    return switch(exercise) {
      SupersetExercise s => AdvancedExerciseExecutionSheet(exercise: s),
      DropsetExercise d => AdvancedExerciseExecutionSheet(exercise: d),
      RestPauseExercise r => AdvancedExerciseExecutionSheet(exercise: r),
      _ => throw UnsupportedError('Unknown exercise type: ${exercise.runtimeType}'),
    };
  }
}

/// Legacy implementation (current code)
class LegacyExecutionSheetFactory implements ExecutionSheetFactory {
  @override
  Widget buildExecutionSheet(Exercise exercise) {
    if (exercise is SupersetExercise) {
      return SupersetSequentialExecutionSheet(
        superset: exercise,
        // ...
      );
    } else if (exercise is DropsetExercise) {
      return DropsetExecutionSheet(
        dropset: exercise,
        // ...
      );
    } else if (exercise is RestPauseExercise) {
      return RestPauseExecutionSheet(
        restPause: exercise,
        // ...
      );
    }
    throw UnsupportedError('Unknown exercise type');
  }
}

/// Feature flag configuration
class FeatureFlags {
  static bool _useUnifiedExecutionSheets = false;

  static bool get useUnifiedExecutionSheets => _useUnifiedExecutionSheets;

  static ExecutionSheetFactory get executionSheetFactory {
    return _useUnifiedExecutionSheets
        ? UnifiedExecutionSheetFactory()
        : LegacyExecutionSheetFactory();
  }

  /// Enable for specific user ID (beta testing)
  static void setUnifiedExecutionSheets(bool enabled) {
    _useUnifiedExecutionSheets = enabled;
  }
}
```

**Vantaggio**: Quando disabiliti il flag, elimini l'intero `LegacyExecutionSheetFactory` senza cercare if/else sparsi.

#### 0.3 Schema Versioning Constants

**Crea file**: `lib/core/config/schema_versions.dart`

```dart
/// ✅ CONSULTANT RECOMMENDATION: Explicit schema versioning
class SchemaVersions {
  /// Versione 1: SupersetExerciseData without countingMode
  static const int supersetDataV1 = 1;

  /// Versione 2: SupersetExerciseData with countingMode + time support
  static const int supersetDataV2 = 2;

  /// Current schema version (target)
  static const int currentSupersetDataVersion = 2;
}
```

---

### 📌 Phase 1: Domain Layer - Sealed Classes (5 giorni)

#### 1.1 Create Sealed Base Classes

**File**: `lib/features/workout/domain/entities/advanced_exercise.dart` (NEW)

```dart
/// ✅ CONSULTANT RECOMMENDATION: Sealed class for compile-time safety
sealed class AdvancedExercise extends Exercise {
  AdvancedExercise({
    required super.id,
    required super.name,
    required super.type,
    required super.category,
    required this.stages,
    super.notes,
    super.restTime,
    super.createdAt,
    super.updatedAt,
  });

  /// Generic stages - each subclass provides typed access
  final List<AdvancedStage> stages;

  /// Progress calculation (0.0 to 100.0)
  double get completionPercentage {
    if (stages.isEmpty) return 0.0;
    final completed = stages.where((s) => s.isCompleted).length;
    return (completed / stages.length) * 100.0;
  }

  /// Validation of data consistency
  bool get isDataConsistent;

  /// Number of completed stages
  int get completedStagesCount =>
      stages.where((s) => s.isCompleted).length;

  /// Total number of stages
  int get totalStagesCount => stages.length;
}

/// ✅ Interface for all stage types
abstract class AdvancedStage {
  String get id;
  int get stageNumber;
  bool get isCompleted;
  DateTime? get completedAt;
}
```

#### 1.2 Fix SupersetExerciseData (CRITICAL)

**Modifica**: `lib/features/workout/domain/entities/exercise.dart`

```dart
/// ✅ CONSULTANT FIX: Add countingMode + time support
class SupersetExerciseData {
  const SupersetExerciseData({
    required this.exerciseId,
    required this.exerciseName,
    required this.countingMode,  // ✅ NEW: Support all counting modes

    // Weighted mode fields
    this.targetWeight,
    this.actualWeight,

    // Reps mode fields (used by weighted + bodyweight)
    this.targetReps,
    this.actualReps,

    // Time mode fields
    this.targetSeconds,           // ✅ NEW: For time-based exercises
    this.actualSeconds,           // ✅ NEW: For time-based exercises

    // Common fields
    this.rpe,
    this.isCompleted = false,
    this.notes,
  });

  final String exerciseId;
  final String exerciseName;
  final ExerciseCountingMode countingMode;  // ✅ NEW

  // Weighted mode
  final double? targetWeight;
  final double? actualWeight;

  // Reps mode
  final int? targetReps;
  final int? actualReps;

  // Time mode
  final int? targetSeconds;    // ✅ NEW
  final int? actualSeconds;    // ✅ NEW

  // Common
  final int? rpe;
  final bool isCompleted;
  final String? notes;

  /// ✅ Helper: Get display value based on counting mode
  String getDisplayValue() {
    switch (countingMode) {
      case ExerciseCountingMode.weighted:
        final w = actualWeight ?? targetWeight ?? 0;
        final r = actualReps ?? targetReps ?? 0;
        return '${w.toStringAsFixed(1)}kg × $r reps';

      case ExerciseCountingMode.reps:
        final r = actualReps ?? targetReps ?? 0;
        return '$r reps';

      case ExerciseCountingMode.time:
        final s = actualSeconds ?? targetSeconds ?? 0;
        final min = s ~/ 60;
        final sec = s % 60;
        return '${min}:${sec.toString().padLeft(2, '0')}';
    }
  }

  /// ✅ Helper: Validate data consistency
  bool isValid() {
    switch (countingMode) {
      case ExerciseCountingMode.weighted:
        return targetWeight != null && targetReps != null;
      case ExerciseCountingMode.reps:
        return targetReps != null;
      case ExerciseCountingMode.time:
        return targetSeconds != null;
    }
  }

  /// ✅ CONSULTANT RECOMMENDATION: Schema versioning in fromJson
  factory SupersetExerciseData.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['_schemaVersion'] as int? ?? 1;

    return switch(schemaVersion) {
      1 => _migrateFromV1(json),  // Old schema without countingMode
      2 => _parseV2(json),        // New schema with countingMode
      _ => throw UnsupportedError('Unknown schema version: $schemaVersion'),
    };
  }

  /// Migrate V1 → V2 (add countingMode with backward compatibility)
  static SupersetExerciseData _migrateFromV1(Map<String, dynamic> json) {
    return SupersetExerciseData(
      exerciseId: json['exerciseId'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      countingMode: ExerciseCountingMode.weighted, // ✅ Default for backward compatibility
      targetWeight: json['targetWeight']?.toDouble(),
      targetReps: json['targetReps'],
      actualWeight: json['actualWeight']?.toDouble(),
      actualReps: json['actualReps'],
      targetSeconds: null,  // Not available in V1
      actualSeconds: null,  // Not available in V1
      rpe: json['rpe'],
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
    );
  }

  /// Parse V2 schema
  static SupersetExerciseData _parseV2(Map<String, dynamic> json) {
    return SupersetExerciseData(
      exerciseId: json['exerciseId'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      countingMode: ExerciseCountingMode.fromString(
        json['countingMode'] ?? 'weighted',
      ),
      targetWeight: json['targetWeight']?.toDouble(),
      actualWeight: json['actualWeight']?.toDouble(),
      targetReps: json['targetReps'],
      actualReps: json['actualReps'],
      targetSeconds: json['targetSeconds'],      // ✅ NEW
      actualSeconds: json['actualSeconds'],      // ✅ NEW
      rpe: json['rpe'],
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_schemaVersion': 2,  // ✅ NEW: Explicit versioning
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'countingMode': countingMode.name,  // ✅ NEW
      'targetWeight': targetWeight,
      'actualWeight': actualWeight,
      'targetReps': targetReps,
      'actualReps': actualReps,
      'targetSeconds': targetSeconds,      // ✅ NEW
      'actualSeconds': actualSeconds,      // ✅ NEW
      'rpe': rpe,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  SupersetExerciseData copyWith({
    String? exerciseId,
    String? exerciseName,
    ExerciseCountingMode? countingMode,
    double? targetWeight,
    double? actualWeight,
    int? targetReps,
    int? actualReps,
    int? targetSeconds,
    int? actualSeconds,
    int? rpe,
    bool? isCompleted,
    String? notes,
  }) {
    return SupersetExerciseData(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      countingMode: countingMode ?? this.countingMode,
      targetWeight: targetWeight ?? this.targetWeight,
      actualWeight: actualWeight ?? this.actualWeight,
      targetReps: targetReps ?? this.targetReps,
      actualReps: actualReps ?? this.actualReps,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      actualSeconds: actualSeconds ?? this.actualSeconds,
      rpe: rpe ?? this.rpe,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}
```

#### 1.3 Refactor SupersetExercise as Sealed Class

```dart
/// ✅ Sealed class implementation
class SupersetExercise extends AdvancedExercise {
  SupersetExercise({
    required super.id,
    required super.name,
    required List<Exercise> exercises,
    List<SupersetSet>? supersetSets,
    super.notes,
    super.restTime,
    super.createdAt,
    super.updatedAt,
  }) :
    exercises = exercises,
    super(
      type: ExerciseType.superset,
      category: exercises.isNotEmpty ? exercises.first.category : ExerciseCategory.other,
      stages: supersetSets ?? [],
    );

  final List<Exercise> exercises;

  /// Typed access to stages
  @override
  List<SupersetSet> get stages => super.stages.cast<SupersetSet>();

  /// ✅ Implementation of abstract method
  @override
  bool get isDataConsistent {
    for (final set in stages) {
      // Check all exercises have data
      for (final exercise in exercises) {
        if (!set.exerciseData.containsKey(exercise.id)) {
          return false;
        }
        // Validate data consistency
        final data = set.exerciseData[exercise.id]!;
        if (!data.isValid()) {
          return false;
        }
      }
    }
    return true;
  }

  /// ✅ Synchronize sets with current exercise list
  SupersetExercise ensureConsistency() {
    if (isDataConsistent) return this;

    final syncedSets = stages.map((set) {
      final updatedData = <String, SupersetExerciseData>{};

      for (final exercise in exercises) {
        if (set.exerciseData.containsKey(exercise.id)) {
          // Keep existing data
          updatedData[exercise.id] = set.exerciseData[exercise.id]!;
        } else {
          // Add default data for new exercises
          updatedData[exercise.id] = SupersetExerciseData(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            countingMode: exercise.countingMode,  // ✅ Use exercise's counting mode
            targetWeight: exercise.countingMode == ExerciseCountingMode.weighted ? 0.0 : null,
            targetReps: exercise.countingMode != ExerciseCountingMode.time ? 10 : null,
            targetSeconds: exercise.countingMode == ExerciseCountingMode.time ? 60 : null,
            isCompleted: false,
          );
        }
      }

      return set.copyWith(
        exerciseData: updatedData,
        isCompleted: set.isCompleted && updatedData.length == set.exerciseData.length,
      );
    }).toList();

    return copyWith(supersetSets: syncedSets);
  }
}
```

#### 1.4 Update SupersetSet to Implement AdvancedStage

```dart
/// ✅ SupersetSet implements AdvancedStage interface
class SupersetSet implements AdvancedStage {
  SupersetSet({
    String? id,
    required this.setNumber,
    required this.exerciseData,
    this.isCompleted = false,
    this.completedAt,
    this.setDurationMillis,
    this.setStartedAt,
    this.isWarmup = false,
    this.notes,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  @override
  final String id;

  final int setNumber;
  final Map<String, SupersetExerciseData> exerciseData;

  @override
  final bool isCompleted;

  @override
  final DateTime? completedAt;

  final double? setDurationMillis;
  final DateTime? setStartedAt;
  final bool isWarmup;
  final String? notes;

  @override
  int get stageNumber => setNumber;

  /// Check if all exercises in set are completed
  bool get isFullyCompleted =>
      exerciseData.values.every((data) => data.isCompleted);

  /// Count completed exercises
  int get completedExercisesCount =>
      exerciseData.values.where((data) => data.isCompleted).length;

  SupersetSet copyWith({
    String? id,
    int? setNumber,
    Map<String, SupersetExerciseData>? exerciseData,
    bool? isCompleted,
    DateTime? completedAt,
    double? setDurationMillis,
    DateTime? setStartedAt,
    bool? isWarmup,
    String? notes,
  }) {
    return SupersetSet(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      exerciseData: exerciseData ?? Map.from(this.exerciseData),
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      setDurationMillis: setDurationMillis ?? this.setDurationMillis,
      setStartedAt: setStartedAt ?? this.setStartedAt,
      isWarmup: isWarmup ?? this.isWarmup,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setNumber': setNumber,
      'exerciseData': exerciseData.map((key, value) => MapEntry(key, value.toJson())),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'setDurationMillis': setDurationMillis,
      'setStartedAt': setStartedAt?.toIso8601String(),
      'isWarmup': isWarmup,
      'notes': notes,
    };
  }

  factory SupersetSet.fromJson(Map<String, dynamic> json) {
    return SupersetSet(
      id: json['id'],
      setNumber: json['setNumber'],
      exerciseData: (json['exerciseData'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, SupersetExerciseData.fromJson(value)))
          ?? {},
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      setDurationMillis: json['setDurationMillis']?.toDouble(),
      setStartedAt: json['setStartedAt'] != null
          ? DateTime.parse(json['setStartedAt'])
          : null,
      isWarmup: json['isWarmup'] ?? false,
      notes: json['notes'],
    );
  }
}
```

---

### 📌 Phase 2: Testing Layer (3 giorni)

#### 2.1 Unit Tests for Schema Migration

**File**: `test/features/workout/domain/entities/superset_exercise_data_test.dart` (NEW)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

/// ✅ CONSULTANT RECOMMENDATION: Test migration V1→V2
void main() {
  group('SupersetExerciseData Schema Migration', () {
    test('V1 to V2: Missing countingMode gets default weighted', () {
      // V1 JSON without countingMode field
      final v1Json = {
        'exerciseId': 'bench-press-123',
        'exerciseName': 'Barbell Bench Press',
        'targetWeight': 80.0,
        'targetReps': 8,
        // Nota: countingMode è mancante in V1
      };

      // Parse JSON (should trigger migration)
      final migrated = SupersetExerciseData.fromJson(v1Json);

      // Verify default countingMode
      expect(migrated.countingMode, equals(ExerciseCountingMode.weighted));
      expect(migrated.targetWeight, equals(80.0));
      expect(migrated.targetReps, equals(8));
      expect(migrated.targetSeconds, isNull); // Not in V1
      expect(migrated.actualSeconds, isNull); // Not in V1
    });

    test('V2: Explicit schema version with time-based exercise', () {
      final v2Json = {
        '_schemaVersion': 2,
        'exerciseId': 'plank-456',
        'exerciseName': 'Plank Hold',
        'countingMode': 'time',
        'targetSeconds': 60,
        'actualSeconds': 55,
      };

      final parsed = SupersetExerciseData.fromJson(v2Json);

      expect(parsed.countingMode, equals(ExerciseCountingMode.time));
      expect(parsed.targetSeconds, equals(60));
      expect(parsed.actualSeconds, equals(55));
      expect(parsed.targetWeight, isNull);
      expect(parsed.targetReps, isNull);
    });

    test('V2: toJson includes schema version', () {
      final data = SupersetExerciseData(
        exerciseId: 'pushups-789',
        exerciseName: 'Push-ups',
        countingMode: ExerciseCountingMode.reps,
        targetReps: 20,
        actualReps: 22,
      );

      final json = data.toJson();

      expect(json['_schemaVersion'], equals(2));
      expect(json['countingMode'], equals('reps'));
      expect(json['targetReps'], equals(20));
      expect(json['actualReps'], equals(22));
    });

    test('V1: Completed workout data preserved during migration', () {
      final v1Json = {
        'exerciseId': 'squat-101',
        'exerciseName': 'Barbell Squat',
        'targetWeight': 100.0,
        'targetReps': 5,
        'actualWeight': 100.0,
        'actualReps': 6,
        'rpe': 8,
        'isCompleted': true,
      };

      final migrated = SupersetExerciseData.fromJson(v1Json);

      // All V1 data should be preserved
      expect(migrated.targetWeight, equals(100.0));
      expect(migrated.actualWeight, equals(100.0));
      expect(migrated.targetReps, equals(5));
      expect(migrated.actualReps, equals(6));
      expect(migrated.rpe, equals(8));
      expect(migrated.isCompleted, isTrue);

      // Migrated fields
      expect(migrated.countingMode, equals(ExerciseCountingMode.weighted));
    });
  });

  group('SupersetExerciseData Validation', () {
    test('isValid() returns true for weighted exercise with complete data', () {
      final data = SupersetExerciseData(
        exerciseId: '1',
        exerciseName: 'Bench Press',
        countingMode: ExerciseCountingMode.weighted,
        targetWeight: 80.0,
        targetReps: 10,
      );

      expect(data.isValid(), isTrue);
    });

    test('isValid() returns false for weighted exercise missing weight', () {
      final data = SupersetExerciseData(
        exerciseId: '1',
        exerciseName: 'Bench Press',
        countingMode: ExerciseCountingMode.weighted,
        targetReps: 10,
        // Missing targetWeight
      );

      expect(data.isValid(), isFalse);
    });

    test('isValid() returns true for time-based exercise', () {
      final data = SupersetExerciseData(
        exerciseId: '2',
        exerciseName: 'Plank',
        countingMode: ExerciseCountingMode.time,
        targetSeconds: 60,
      );

      expect(data.isValid(), isTrue);
    });

    test('isValid() returns false for time-based exercise missing targetSeconds', () {
      final data = SupersetExerciseData(
        exerciseId: '2',
        exerciseName: 'Plank',
        countingMode: ExerciseCountingMode.time,
        // Missing targetSeconds
      );

      expect(data.isValid(), isFalse);
    });
  });

  group('SupersetExerciseData Display Value', () {
    test('getDisplayValue() formats weighted exercise correctly', () {
      final data = SupersetExerciseData(
        exerciseId: '1',
        exerciseName: 'Bench Press',
        countingMode: ExerciseCountingMode.weighted,
        targetWeight: 80.5,
        actualWeight: 82.5,
        targetReps: 10,
        actualReps: 8,
      );

      expect(data.getDisplayValue(), equals('82.5kg × 8 reps'));
    });

    test('getDisplayValue() formats reps-only exercise correctly', () {
      final data = SupersetExerciseData(
        exerciseId: '2',
        exerciseName: 'Push-ups',
        countingMode: ExerciseCountingMode.reps,
        targetReps: 20,
        actualReps: 22,
      );

      expect(data.getDisplayValue(), equals('22 reps'));
    });

    test('getDisplayValue() formats time-based exercise correctly', () {
      final data = SupersetExerciseData(
        exerciseId: '3',
        exerciseName: 'Plank',
        countingMode: ExerciseCountingMode.time,
        targetSeconds: 90,
        actualSeconds: 85,
      );

      expect(data.getDisplayValue(), equals('1:25'));
    });

    test('getDisplayValue() formats time with proper padding', () {
      final data = SupersetExerciseData(
        exerciseId: '3',
        exerciseName: 'Plank',
        countingMode: ExerciseCountingMode.time,
        targetSeconds: 125,
      );

      expect(data.getDisplayValue(), equals('2:05')); // 2 min 5 sec
    });
  });
}
```

#### 2.2 Integration Test for Superset with Mixed Modes

**File**: `test/features/workout/domain/entities/superset_exercise_test.dart` (NEW)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

/// ✅ CONSULTANT RECOMMENDATION: Test mixed counting modes in superset
void main() {
  group('SupersetExercise with Mixed Counting Modes', () {
    test('Create superset with time-based + weighted exercises', () {
      // Create exercises with different counting modes
      final plank = Exercise(
        id: 'plank-1',
        name: 'Plank Hold',
        type: ExerciseType.single,
        category: ExerciseCategory.abs,
        countingMode: ExerciseCountingMode.time,
      );

      final pushups = Exercise(
        id: 'pushups-1',
        name: 'Push-ups',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        countingMode: ExerciseCountingMode.reps,
      );

      // Create superset
      final superset = SupersetExercise(
        id: 'superset-1',
        name: 'Core + Upper Body',
        exercises: [plank, pushups],
        supersetSets: [
          SupersetSet(
            setNumber: 1,
            exerciseData: {
              'plank-1': SupersetExerciseData(
                exerciseId: 'plank-1',
                exerciseName: 'Plank Hold',
                countingMode: ExerciseCountingMode.time,
                targetSeconds: 60,
              ),
              'pushups-1': SupersetExerciseData(
                exerciseId: 'pushups-1',
                exerciseName: 'Push-ups',
                countingMode: ExerciseCountingMode.reps,
                targetReps: 20,
              ),
            },
          ),
        ],
      );

      // Verify superset properties
      expect(superset.exercises.length, equals(2));
      expect(superset.stages.length, equals(1));
      expect(superset.isDataConsistent, isTrue);

      // Verify plank data
      final plankData = superset.stages.first.exerciseData['plank-1']!;
      expect(plankData.countingMode, equals(ExerciseCountingMode.time));
      expect(plankData.targetSeconds, equals(60));
      expect(plankData.getDisplayValue(), equals('1:00'));

      // Verify pushups data
      final pushupsData = superset.stages.first.exerciseData['pushups-1']!;
      expect(pushupsData.countingMode, equals(ExerciseCountingMode.reps));
      expect(pushupsData.targetReps, equals(20));
      expect(pushupsData.getDisplayValue(), equals('20 reps'));
    });

    test('ensureConsistency() adds missing exercises with correct countingMode', () {
      // Create superset with 2 exercises
      final bench = Exercise(
        id: 'bench-1',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        countingMode: ExerciseCountingMode.weighted,
      );

      final rows = Exercise(
        id: 'rows-1',
        name: 'Barbell Rows',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        countingMode: ExerciseCountingMode.weighted,
      );

      final superset = SupersetExercise(
        id: 'superset-1',
        name: 'Chest + Back',
        exercises: [bench, rows],
        supersetSets: [
          SupersetSet(
            setNumber: 1,
            exerciseData: {
              'bench-1': SupersetExerciseData(
                exerciseId: 'bench-1',
                exerciseName: 'Bench Press',
                countingMode: ExerciseCountingMode.weighted,
                targetWeight: 80.0,
                targetReps: 8,
              ),
              // ❌ Missing 'rows-1'
            },
          ),
        ],
      );

      // Verify inconsistency detected
      expect(superset.isDataConsistent, isFalse);

      // Fix consistency
      final fixed = superset.ensureConsistency();

      // Verify consistency
      expect(fixed.isDataConsistent, isTrue);
      expect(fixed.stages.first.exerciseData.length, equals(2));

      // Verify rows was added with correct countingMode
      final rowsData = fixed.stages.first.exerciseData['rows-1']!;
      expect(rowsData.countingMode, equals(ExerciseCountingMode.weighted));
      expect(rowsData.targetWeight, equals(0.0)); // Default weight
      expect(rowsData.targetReps, equals(10)); // Default reps
    });

    test('JSON serialization preserves all countingModes', () {
      final superset = SupersetExercise(
        id: 'superset-1',
        name: 'Mixed Workout',
        exercises: [
          Exercise(
            id: 'plank-1',
            name: 'Plank',
            type: ExerciseType.single,
            category: ExerciseCategory.abs,
            countingMode: ExerciseCountingMode.time,
          ),
          Exercise(
            id: 'pushups-1',
            name: 'Push-ups',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            countingMode: ExerciseCountingMode.reps,
          ),
        ],
        supersetSets: [
          SupersetSet(
            setNumber: 1,
            exerciseData: {
              'plank-1': SupersetExerciseData(
                exerciseId: 'plank-1',
                exerciseName: 'Plank',
                countingMode: ExerciseCountingMode.time,
                targetSeconds: 60,
              ),
              'pushups-1': SupersetExerciseData(
                exerciseId: 'pushups-1',
                exerciseName: 'Push-ups',
                countingMode: ExerciseCountingMode.reps,
                targetReps: 20,
              ),
            },
          ),
        ],
      );

      // Serialize to JSON
      final json = superset.toJson();

      // Deserialize from JSON
      final deserialized = SupersetExercise.fromJson(json);

      // Verify all data preserved
      expect(deserialized.id, equals('superset-1'));
      expect(deserialized.exercises.length, equals(2));
      expect(deserialized.stages.length, equals(1));

      // Verify plank
      final plankData = deserialized.stages.first.exerciseData['plank-1']!;
      expect(plankData.countingMode, equals(ExerciseCountingMode.time));
      expect(plankData.targetSeconds, equals(60));

      // Verify pushups
      final pushupsData = deserialized.stages.first.exerciseData['pushups-1']!;
      expect(pushupsData.countingMode, equals(ExerciseCountingMode.reps));
      expect(pushupsData.targetReps, equals(20));
    });
  });
}
```

#### 2.3 Run Tests

```bash
# Run unit tests
flutter test test/features/workout/domain/entities/superset_exercise_data_test.dart

# Run integration tests
flutter test test/features/workout/domain/entities/superset_exercise_test.dart

# Run all tests with coverage
flutter test --coverage
```

---

### 📌 Phase 3: Database Migration (5 giorni)

#### 3.1 Create Migration Script

**File**: `lib/core/migrations/superset_data_migration.dart` (NEW)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/core/config/schema_versions.dart';

/// ✅ CONSULTANT RECOMMENDATION: Explicit database migration with dry-run
class SupersetDataMigration {
  final FirebaseFirestore _firestore;

  SupersetDataMigration(this._firestore);

  /// Run migration with optional dry-run mode
  Future<MigrationResult> migrate({
    required String userId,
    bool dryRun = false,
  }) async {
    print('🔄 Starting superset data migration...');
    print('Mode: ${dryRun ? "DRY RUN (no changes)" : "PRODUCTION (will modify data)"}');

    final workoutsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts');

    // Get all workouts
    final snapshot = await workoutsRef.get();

    int totalWorkouts = snapshot.docs.length;
    int migratedCount = 0;
    int errorCount = 0;
    int skippedCount = 0;
    List<String> errors = [];

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        final exercises = data['exercises'] as List<dynamic>?;

        if (exercises == null) {
          skippedCount++;
          continue;
        }

        bool needsUpdate = false;
        final updatedExercises = exercises.map((exerciseJson) {
          if (exerciseJson['type'] == 'superset') {
            final supersetSets = exerciseJson['supersetSets'] as List<dynamic>?;

            if (supersetSets != null) {
              final updatedSets = supersetSets.map((setJson) {
                final exerciseData = setJson['exerciseData'] as Map<String, dynamic>?;

                if (exerciseData != null) {
                  final updatedData = <String, dynamic>{};

                  exerciseData.forEach((exerciseId, data) {
                    // Check if already migrated
                    if (data['_schemaVersion'] == SchemaVersions.supersetDataV2) {
                      updatedData[exerciseId] = data;
                      return;
                    }

                    // ✅ Migrate V1 → V2
                    updatedData[exerciseId] = {
                      '_schemaVersion': SchemaVersions.supersetDataV2,
                      ...data,
                      'countingMode': data['countingMode'] ?? 'weighted', // Default
                      'targetSeconds': data['targetSeconds'],  // null if not present
                      'actualSeconds': data['actualSeconds'],  // null if not present
                    };
                    needsUpdate = true;
                  });

                  setJson['exerciseData'] = updatedData;
                }

                return setJson;
              }).toList();

              exerciseJson['supersetSets'] = updatedSets;
            }
          }

          return exerciseJson;
        }).toList();

        if (needsUpdate) {
          if (!dryRun) {
            // ✅ PRODUCTION: Actually update the document
            await doc.reference.update({
              'exercises': updatedExercises,
              'migratedAt': FieldValue.serverTimestamp(),
            });
          }

          migratedCount++;
          print('✓ ${dryRun ? "Would migrate" : "Migrated"} workout: ${doc.id}');
        } else {
          skippedCount++;
        }
      } catch (e) {
        errorCount++;
        final errorMsg = 'Error migrating workout ${doc.id}: $e';
        print('❌ $errorMsg');
        errors.add(errorMsg);
      }
    }

    final result = MigrationResult(
      totalWorkouts: totalWorkouts,
      migratedCount: migratedCount,
      skippedCount: skippedCount,
      errorCount: errorCount,
      errors: errors,
      dryRun: dryRun,
    );

    print('\n📊 Migration Summary:');
    print('Total workouts: $totalWorkouts');
    print('Migrated: $migratedCount');
    print('Skipped (no superset): $skippedCount');
    print('Errors: $errorCount');
    if (dryRun) {
      print('\n⚠️ DRY RUN MODE - No changes were made');
    }

    return result;
  }
}

class MigrationResult {
  final int totalWorkouts;
  final int migratedCount;
  final int skippedCount;
  final int errorCount;
  final List<String> errors;
  final bool dryRun;

  MigrationResult({
    required this.totalWorkouts,
    required this.migratedCount,
    required this.skippedCount,
    required this.errorCount,
    required this.errors,
    required this.dryRun,
  });

  bool get hasErrors => errorCount > 0;
  bool get success => errorCount == 0;
  double get successRate => totalWorkouts > 0
      ? (migratedCount / totalWorkouts) * 100
      : 0.0;
}
```

#### 3.2 Create CLI Tool for Migration

**File**: `bin/migrate_superset_data.dart` (NEW)

```dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymbro_flutter_new/core/migrations/superset_data_migration.dart';

/// ✅ CONSULTANT RECOMMENDATION: CLI tool for safe migration
///
/// Usage:
/// dart run bin/migrate_superset_data.dart --user-id=USER_ID --dry-run
/// dart run bin/migrate_superset_data.dart --user-id=USER_ID --production
Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('user-id', abbr: 'u', help: 'Firebase user ID to migrate')
    ..addFlag('dry-run', abbr: 'd', help: 'Run in dry-run mode (no changes)', defaultsTo: false)
    ..addFlag('production', abbr: 'p', help: 'Run in production mode (will modify data)', defaultsTo: false)
    ..addFlag('help', abbr: 'h', help: 'Show this help message', negatable: false);

  final results = parser.parse(arguments);

  if (results['help'] as bool) {
    print('Superset Data Migration Tool\n');
    print(parser.usage);
    exit(0);
  }

  final userId = results['user-id'] as String?;
  if (userId == null) {
    print('❌ Error: --user-id is required');
    print('\nUsage:');
    print(parser.usage);
    exit(1);
  }

  final dryRun = results['dry-run'] as bool;
  final production = results['production'] as bool;

  if (!dryRun && !production) {
    print('❌ Error: Must specify either --dry-run or --production');
    exit(1);
  }

  if (dryRun && production) {
    print('❌ Error: Cannot specify both --dry-run and --production');
    exit(1);
  }

  // Initialize Firebase
  print('Initializing Firebase...');
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final migration = SupersetDataMigration(firestore);

  // Confirmation for production mode
  if (production) {
    print('\n⚠️  WARNING: Production mode will modify data!');
    print('User ID: $userId');
    print('\nAre you sure you want to proceed? (yes/no)');
    final confirmation = stdin.readLineSync();
    if (confirmation?.toLowerCase() != 'yes') {
      print('Migration cancelled.');
      exit(0);
    }
  }

  // Run migration
  final result = await migration.migrate(
    userId: userId,
    dryRun: dryRun,
  );

  // Print results
  print('\n' + '=' * 60);
  print('Migration Complete');
  print('=' * 60);
  print('Total workouts: ${result.totalWorkouts}');
  print('Migrated: ${result.migratedCount}');
  print('Skipped: ${result.skippedCount}');
  print('Errors: ${result.errorCount}');
  print('Success rate: ${result.successRate.toStringAsFixed(1)}%');

  if (result.hasErrors) {
    print('\n❌ Errors occurred:');
    for (final error in result.errors) {
      print('  - $error');
    }
    exit(1);
  }

  if (dryRun) {
    print('\n✅ Dry run completed successfully!');
    print('Run with --production to apply changes.');
  } else {
    print('\n✅ Migration completed successfully!');
  }

  exit(0);
}
```

**Add to `pubspec.yaml`**:
```yaml
dependencies:
  args: ^2.4.0

executables:
  migrate_superset_data:
```

#### 3.3 Test Migration with Firestore Emulator

```bash
# 1. Start Firestore emulator
firebase emulators:start --only firestore --import=./firestore_export

# 2. Run dry-run migration
dart run bin/migrate_superset_data.dart --user-id=YOUR_TEST_USER_ID --dry-run

# 3. If dry-run succeeds, run production
dart run bin/migrate_superset_data.dart --user-id=YOUR_TEST_USER_ID --production

# 4. Verify data in emulator UI
# Open http://localhost:4000 to inspect migrated data
```

---

### 📌 Phase 4: UI Layer with Feature Flag (7 giorni)

#### 4.1 Update Exercise Card to Use Factory

**File**: `lib/features/workout/presentation/widgets/exercise_list_item.dart`

**Modifica** (cerca il punto dove apre execution sheet):

```dart
// ❌ PRIMA (hardcoded sheet selection)
if (exercise is SupersetExercise) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SupersetSequentialExecutionSheet(
      superset: exercise,
      // ...
    ),
  );
}

// ✅ DOPO (usa factory con feature flag)
import 'package:gymbro_flutter_new/core/config/feature_flags.dart';

void _openExecutionSheet(Exercise exercise) {
  final factory = FeatureFlags.executionSheetFactory;
  final sheet = factory.buildExecutionSheet(exercise);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => sheet,
  );
}
```

#### 4.2 Create Unified Execution Sheet (NEW)

**File**: `lib/features/workout/presentation/widgets/advanced_exercise_execution_sheet.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/advanced_exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// ✅ CONSULTANT RECOMMENDATION: Generic execution sheet with sealed classes
class AdvancedExerciseExecutionSheet extends ConsumerStatefulWidget {
  const AdvancedExerciseExecutionSheet({
    super.key,
    required this.exercise,
    required this.stageIndex,
    required this.onStageCompleted,
    this.onAllStagesCompleted,
  });

  final AdvancedExercise exercise;
  final int stageIndex;
  final Function(AdvancedStage completedStage) onStageCompleted;
  final VoidCallback? onAllStagesCompleted;

  @override
  ConsumerState<AdvancedExerciseExecutionSheet> createState() =>
      _AdvancedExerciseExecutionSheetState();
}

class _AdvancedExerciseExecutionSheetState
    extends ConsumerState<AdvancedExerciseExecutionSheet> {

  @override
  Widget build(BuildContext context) {
    final stage = widget.exercise.stages[widget.stageIndex];
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ SHARED: Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ✅ SHARED: Header with polymorphic icon
            Row(
              children: [
                _getExerciseIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exercise.name,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getStageLabel(stage),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ✅ SHARED: Progress indicator
            _buildProgressIndicator(),

            const SizedBox(height: 24),

            // ✅ POLYMORPHIC: Stage-specific content using sealed class
            _buildStageContent(context, stage),

            const SizedBox(height: 24),

            // ✅ SHARED: Execute button
            FilledButton.icon(
              onPressed: stage.isCompleted ? null : () => _executeStage(stage),
              icon: Icon(stage.isCompleted ? Icons.check_circle : Icons.play_arrow),
              label: Text(
                stage.isCompleted
                    ? l10n.completed
                    : _isLastStage ? l10n.complete : l10n.execute,
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ SEALED CLASS PATTERN MATCHING: Get icon based on type
  Widget _getExerciseIcon() {
    return switch(widget.exercise) {
      SupersetExercise() => Icon(
        Icons.repeat,
        color: context.colors.secondary,
        size: 28,
      ),
      DropsetExercise() => Icon(
        Icons.trending_down,
        color: context.colors.tertiary,
        size: 28,
      ),
      RestPauseExercise() => Icon(
        Icons.pause_circle_outline,
        color: context.colors.primary,
        size: 28,
      ),
      _ => Icon(
        Icons.fitness_center,
        color: context.colors.onSurface,
        size: 28,
      ),
    };
  }

  /// ✅ SEALED CLASS PATTERN MATCHING: Get stage label
  String _getStageLabel(AdvancedStage stage) {
    final l10n = context.l10n;
    final current = stage.stageNumber;
    final total = widget.exercise.stages.length;

    return switch(widget.exercise) {
      SupersetExercise() => '${l10n.round} $current/$total',
      DropsetExercise() => '${l10n.stage} $current/$total',
      RestPauseExercise() => '${l10n.set} $current/$total',
      _ => '$current/$total',
    };
  }

  /// ✅ SHARED: Progress indicator
  Widget _buildProgressIndicator() {
    final percentage = widget.exercise.completionPercentage;
    final completed = widget.exercise.completedStagesCount;
    final total = widget.exercise.totalStagesCount;

    return Column(
      children: [
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: context.colors.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(context.colors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          '$completed/$total ${context.l10n.completed}',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// ✅ SEALED CLASS PATTERN MATCHING: Build stage-specific content
  Widget _buildStageContent(BuildContext context, AdvancedStage stage) {
    return switch((widget.exercise, stage)) {
      (SupersetExercise superset, SupersetSet set) => _buildSupersetContent(superset, set),
      (DropsetExercise dropset, DropsetStage dropStage) => _buildDropsetContent(dropset, dropStage),
      (RestPauseExercise restPause, RestPauseStage restStage) => _buildRestPauseContent(restPause, restStage),
      _ => const SizedBox.shrink(),
    };
  }

  /// Build superset round content
  Widget _buildSupersetContent(SupersetExercise superset, SupersetSet set) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Exercise list
        ...superset.exercises.map((exercise) {
          final exerciseData = set.exerciseData[exercise.id];
          final isCompleted = exerciseData?.isCompleted ?? false;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted
                  ? context.colors.secondaryContainer
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted
                    ? context.colors.secondary
                    : context.colors.outline.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted
                      ? context.colors.secondary
                      : context.colors.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (exerciseData != null)
                        Text(
                          '${context.l10n.target}: ${exerciseData.getDisplayValue()}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.outline,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 16),

        // Info box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: context.colors.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Esegui tutti gli esercizi in sequenza senza riposo',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build dropset stage content
  Widget _buildDropsetContent(DropsetExercise dropset, DropsetStage stage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Weight display
          Text(
            '${stage.weight.toStringAsFixed(1)} kg',
            style: context.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${context.l10n.target}: ${stage.targetReps} reps',
            style: context.textTheme.titleMedium,
          ),
          if (stage.actualReps != null) ...[
            const SizedBox(height: 8),
            Text(
              '${context.l10n.actual}: ${stage.actualReps} reps',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build rest-pause stage content
  Widget _buildRestPauseContent(RestPauseExercise restPause, RestPauseStage stage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${restPause.weight.toStringAsFixed(1)} kg',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.repeat, color: context.colors.primary),
              const SizedBox(width: 8),
              Text(
                '${stage.targetReps} reps',
                style: context.textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: context.colors.tertiary),
              const SizedBox(width: 8),
              Text(
                '${stage.restSeconds}s rest',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.tertiary,
                ),
              ),
            ],
          ),
          if (stage.actualReps != null) ...[
            const SizedBox(height: 16),
            Text(
              '${context.l10n.actual}: ${stage.actualReps} reps',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ SEALED CLASS PATTERN MATCHING: Execute stage
  Future<void> _executeStage(AdvancedStage stage) async {
    // Implementation depends on stage type
    // TODO: Implement execution logic for each type
  }

  bool get _isLastStage =>
      widget.stageIndex >= widget.exercise.stages.length - 1;
}
```

#### 4.3 Enable Feature Flag for Testing

```dart
// In main.dart or debug screen
if (kDebugMode) {
  FeatureFlags.setUnifiedExecutionSheets(true); // Enable new UI
}
```

---

## ⏱️ Timeline Rivisto

| Fase | Durata | Descrizione | Output |
|------|--------|-------------|--------|
| **Phase 0** | 3 giorni | Setup emulator + feature flags | ✅ Infrastructure ready |
| **Phase 1** | 5 giorni | Domain layer (sealed classes + migration logic) | ✅ Type-safe entities |
| **Phase 2** | 3 giorni | Testing suite (unit + integration tests) | ✅ Test coverage 80%+ |
| **Phase 3** | 5 giorni | Database migration (dry-run → production) | ✅ Migrated data |
| **Phase 4** | 7 giorni | UI layer with feature flag | ✅ New execution sheets |
| **Cleanup** | 2 giorni | Remove legacy code + docs | ✅ Clean codebase |
| **TOTALE** | **25 giorni** | ~5 settimane | ✅ Refactoring complete |

---

## 🧪 Testing Checklist

### Unit Tests
- [ ] `SupersetExerciseData.fromJson()` migrates V1→V2 correctly
- [ ] Schema version 2 parses time-based exercises
- [ ] `isValid()` returns true/false correctly for all modes
- [ ] `getDisplayValue()` formats weighted/reps/time correctly
- [ ] `SupersetExercise.ensureConsistency()` adds missing exercises

### Integration Tests
- [ ] Create superset with plank (time) + pushups (reps)
- [ ] JSON serialization preserves all countingModes
- [ ] Sealed class pattern matching works in switch statements

### Migration Tests (Emulator)
- [ ] Dry-run detects workouts needing migration
- [ ] Production migration updates schema version
- [ ] Old workouts load correctly after migration
- [ ] New workouts save with V2 schema

### UI Tests
- [ ] Feature flag switches between old/new execution sheets
- [ ] New execution sheet displays time-based exercises
- [ ] Polymorphic icon/label rendering works
- [ ] Progress indicator shows correct percentage

---

## 📋 Deliverables per Phase

### Phase 1
- `advanced_exercise.dart` (sealed base classes)
- Updated `exercise.dart` with `SupersetExerciseData` V2
- `schema_versions.dart` constants

### Phase 2
- `superset_exercise_data_test.dart` (12+ tests)
- `superset_exercise_test.dart` (6+ tests)
- Coverage report showing 80%+ coverage

### Phase 3
- `superset_data_migration.dart` (migration logic)
- `migrate_superset_data.dart` (CLI tool)
- Migration report from emulator testing

### Phase 4
- `feature_flags.dart` (factory pattern)
- `advanced_exercise_execution_sheet.dart` (generic UI)
- Updated `exercise_list_item.dart` (uses factory)

---

## ✅ Success Criteria

1. **Type Safety**: All advanced exercises use sealed classes
2. **Migration**: 100% of workouts migrated without data loss
3. **Testing**: 80%+ test coverage on new code
4. **Feature Flag**: Can switch between old/new UI seamlessly
5. **User Impact**: Zero crashes reported in first 2 weeks
6. **Performance**: New UI loads <150ms (measured with DevTools)

---

## 🆘 Rollback Plan

Se qualcosa va male:

1. **Disable feature flag**: `FeatureFlags.setUnifiedExecutionSheets(false)`
2. **Check logs**: Firebase Crashlytics per errori runtime
3. **Rollback migration**: Use backup created before migration
4. **Hotfix release**: Deploy old code in <2 hours

---

## 📚 Riferimenti

**Consultant Recommendations**:
1. Sealed classes > abstract classes (compile-time safety)
2. Explicit schema versioning in Firestore documents
3. Feature flag with factory pattern (no scattered if/else)
4. Migration testing with Firestore emulator
5. Dry-run before production migration

**Flutter Best Practices**:
- [Dart 3 Sealed Classes](https://dart.dev/language/class-modifiers#sealed)
- [Firebase Migration Guide](https://firebase.google.com/docs/firestore/manage-data/structure-data)
- [Feature Flags in Flutter](https://docs.flutter.dev/deployment/flavors)

---

**END OF IMPLEMENTATION PLAN**
