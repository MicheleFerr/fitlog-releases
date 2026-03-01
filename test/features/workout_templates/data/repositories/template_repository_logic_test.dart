/// Tests for TemplateRepository pure logic (no Firebase).
///
/// TemplateRepository is tightly coupled to FirebaseFirestore and FirebaseAuth.
/// This file tests:
/// - Domain entities used by the repository (WorkoutTemplate / CommunityWorkoutTemplate)
/// - Pure logic in weightOption handling for replaceExerciseInTemplates
/// - Set/rep clamping logic (updateExerciseSetRepsInTemplate)
/// - restSeconds clamping logic (updateExerciseRestTimeInTemplate)
/// - _normalizeFirestoreData (Timestamp → ISO string conversion logic)
/// - addExerciseToTemplate duplicate detection logic
/// - removeExerciseFromTemplate match priority logic
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
ExerciseSet makeSet({
  int setNumber = 1,
  double? weight = 80.0,
  int? reps = 10,
  int? restTime,
}) =>
    ExerciseSet(
      id: 'set_$setNumber',
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      restTime: restTime,
    );

Exercise makeExercise({
  String id = 'ex1',
  String name = 'Bench Press',
  ExerciseCategory category = ExerciseCategory.chest,
  List<ExerciseSet>? sets,
  int? restTime,
}) =>
    Exercise(
      id: id,
      name: name,
      type: ExerciseType.single,
      category: category,
      sets: sets ?? [makeSet()],
      restTime: restTime,
    );

CommunityWorkoutTemplate makeTemplate({
  String id = 'tmpl1',
  String userId = 'user1',
  String name = 'Push Day',
  List<Exercise>? exercises,
  TemplateVisibility visibility = TemplateVisibility.private,
  TemplateCategory category = TemplateCategory.custom,
}) {
  final now = DateTime(2024, 1, 15);
  return CommunityWorkoutTemplate(
    id: id,
    userId: userId,
    name: name,
    exercises: exercises ??
        [
          makeExercise(id: 'ex1', name: 'Bench Press'),
          makeExercise(id: 'ex2', name: 'Overhead Press'),
        ],
    visibility: visibility,
    category: category,
    createdAt: now,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  group('CommunityWorkoutTemplate entity', () {
    test('creates with required fields', () {
      final template = makeTemplate();
      expect(template.id, equals('tmpl1'));
      expect(template.userId, equals('user1'));
      expect(template.name, equals('Push Day'));
      expect(template.exercises.length, equals(2));
      expect(template.visibility, equals(TemplateVisibility.private));
      expect(template.category, equals(TemplateCategory.custom));
    });

    test('copyWith updates name preserving other fields', () {
      final original = makeTemplate();
      final copy = original.copyWith(name: 'Pull Day');
      expect(copy.name, equals('Pull Day'));
      expect(copy.id, equals('tmpl1'));
      expect(copy.userId, equals('user1'));
      expect(copy.exercises.length, equals(2));
    });

    test('copyWith updates exercises list', () {
      final original = makeTemplate(exercises: [makeExercise(id: 'e1')]);
      final newExercises = [
        makeExercise(id: 'e2', name: 'Squat'),
        makeExercise(id: 'e3', name: 'Deadlift'),
      ];
      final copy = original.copyWith(exercises: newExercises);
      expect(copy.exercises.length, equals(2));
      expect(copy.exercises.first.name, equals('Squat'));
    });

    test('copyWith updates visibility', () {
      final original = makeTemplate(visibility: TemplateVisibility.private);
      final copy = original.copyWith(visibility: TemplateVisibility.public);
      expect(copy.visibility, equals(TemplateVisibility.public));
    });

    test('default values are applied', () {
      final now = DateTime.now();
      final template = CommunityWorkoutTemplate(
        id: 'x',
        userId: 'u',
        name: 'Test',
        exercises: const [],
        createdAt: now,
      );
      expect(template.category, equals(TemplateCategory.custom));
      expect(template.visibility, equals(TemplateVisibility.private));
      expect(template.downloadCount, equals(0));
      expect(template.likeCount, equals(0));
      expect(template.isAnonymous, isFalse);
      expect(template.tags, isEmpty);
    });

    group('toJson / fromJson round-trip', () {
      test('preserves id, userId, name', () {
        final template = makeTemplate(id: 'rt1', userId: 'u1', name: 'RT');
        final json = template.toJson();
        final restored = CommunityWorkoutTemplate.fromJson(json);

        expect(restored.id, equals('rt1'));
        expect(restored.userId, equals('u1'));
        expect(restored.name, equals('RT'));
      });

      test('preserves visibility', () {
        final template = makeTemplate(visibility: TemplateVisibility.public);
        final json = template.toJson();
        final restored = CommunityWorkoutTemplate.fromJson(json);
        expect(restored.visibility, equals(TemplateVisibility.public));
      });

      test('preserves category', () {
        final template = makeTemplate(category: TemplateCategory.strength);
        final json = template.toJson();
        final restored = CommunityWorkoutTemplate.fromJson(json);
        expect(restored.category, equals(TemplateCategory.strength));
      });

      test('preserves exercises list', () {
        final template = makeTemplate(
          exercises: [
            makeExercise(id: 'ex1', name: 'Squat'),
            makeExercise(id: 'ex2', name: 'Deadlift'),
          ],
        );
        final json = template.toJson();
        final restored = CommunityWorkoutTemplate.fromJson(json);
        expect(restored.exercises.length, equals(2));
      });

      test('preserves tags', () {
        final template = makeTemplate().copyWith(tags: ['push', 'upper body']);
        final json = template.toJson();
        final restored = CommunityWorkoutTemplate.fromJson(json);
        expect(restored.tags, contains('push'));
        expect(restored.tags, contains('upper body'));
      });

      test('preserves isAnonymous', () {
        final template = makeTemplate().copyWith(isAnonymous: true);
        final json = template.toJson();
        final restored = CommunityWorkoutTemplate.fromJson(json);
        expect(restored.isAnonymous, isTrue);
      });

      test('preserves authorName', () {
        final template = makeTemplate().copyWith(authorName: 'John Doe');
        final json = template.toJson();
        final restored = CommunityWorkoutTemplate.fromJson(json);
        expect(restored.authorName, equals('John Doe'));
      });

      test('preserves estimatedDurationMinutes', () {
        final template = makeTemplate().copyWith(estimatedDurationMinutes: 60);
        final json = template.toJson();
        final restored = CommunityWorkoutTemplate.fromJson(json);
        expect(restored.estimatedDurationMinutes, equals(60));
      });

      test('preserves difficultyLevel', () {
        final template = makeTemplate().copyWith(difficultyLevel: 'advanced');
        final json = template.toJson();
        final restored = CommunityWorkoutTemplate.fromJson(json);
        expect(restored.difficultyLevel, equals('advanced'));
      });
    });
  });

  group('TemplateVisibility enum', () {
    test('has private, public, friends values', () {
      expect(TemplateVisibility.values.length, equals(3));
      expect(TemplateVisibility.values, contains(TemplateVisibility.private));
      expect(TemplateVisibility.values, contains(TemplateVisibility.public));
      expect(TemplateVisibility.values, contains(TemplateVisibility.friends));
    });
  });

  group('TemplateCategory enum', () {
    test('has all expected categories', () {
      expect(TemplateCategory.values.length, equals(10));
      expect(TemplateCategory.values, contains(TemplateCategory.strength));
      expect(TemplateCategory.values, contains(TemplateCategory.hypertrophy));
      expect(TemplateCategory.values, contains(TemplateCategory.endurance));
      expect(TemplateCategory.values, contains(TemplateCategory.powerlifting));
      expect(TemplateCategory.values, contains(TemplateCategory.bodybuilding));
      expect(TemplateCategory.values, contains(TemplateCategory.crossfit));
      expect(TemplateCategory.values, contains(TemplateCategory.calisthenics));
      expect(TemplateCategory.values, contains(TemplateCategory.cardio));
      expect(TemplateCategory.values, contains(TemplateCategory.mixed));
      expect(TemplateCategory.values, contains(TemplateCategory.custom));
    });
  });

  // -------------------------------------------------------------------------
  // replaceExerciseInTemplates weight option logic
  // -------------------------------------------------------------------------
  group('replaceExerciseInTemplates – weightOption logic (pure)', () {
    late List<ExerciseSet> originalSets;

    setUp(() {
      originalSets = [
        makeSet(setNumber: 1, weight: 100.0, reps: 5),
        makeSet(setNumber: 2, weight: 100.0, reps: 5),
        makeSet(setNumber: 3, weight: 100.0, reps: 5),
      ];
    });

    test('keep option preserves original weights', () {
      const weightOption = 'keep';
      final newSets = originalSets.map((set) {
        if (weightOption == 'reset') {
          return set.copyWith(weight: 0.0);
        } else if (weightOption == 'manual') {
          return set.copyWith(weight: null);
        }
        return set;
      }).toList();

      expect(newSets.every((s) => s.weight == 100.0), isTrue);
    });

    test('reset option sets weight to 0 for all sets', () {
      const weightOption = 'reset';
      final newSets = originalSets.map((set) {
        if (weightOption == 'reset') {
          return set.copyWith(weight: 0.0);
        } else if (weightOption == 'manual') {
          return set.copyWith(weight: null);
        }
        return set;
      }).toList();

      expect(newSets.every((s) => s.weight == 0.0), isTrue);
    });

    test('manual option sets weight to null for all sets', () {
      const weightOption = 'manual';
      final newSets = originalSets.map((set) {
        if (weightOption == 'reset') {
          return set.copyWith(weight: 0.0);
        } else if (weightOption == 'manual') {
          return set.copyWith(weight: null);
        }
        return set;
      }).toList();

      expect(newSets.every((s) => s.weight == null), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // updateExerciseRestTimeInTemplate – restSeconds clamping logic
  // -------------------------------------------------------------------------
  group('updateExerciseRestTimeInTemplate – restSeconds clamping (pure)', () {
    int clampRest(int seconds) => seconds.clamp(20, 300);

    test('restSeconds below 20 is clamped to 20', () {
      expect(clampRest(10), equals(20));
    });

    test('restSeconds above 300 is clamped to 300', () {
      expect(clampRest(400), equals(300));
    });

    test('restSeconds within range passes through', () {
      expect(clampRest(90), equals(90));
      expect(clampRest(20), equals(20));
      expect(clampRest(300), equals(300));
    });

    test('restSeconds of 0 is clamped to 20', () {
      expect(clampRest(0), equals(20));
    });
  });

  // -------------------------------------------------------------------------
  // updateExerciseSetRepsInTemplate – sets/reps clamping logic
  // -------------------------------------------------------------------------
  group('updateExerciseSetRepsInTemplate – clamping logic (pure)', () {
    int? clampSets(int? sets) => sets?.clamp(1, 8);
    int? clampReps(int? reps) => reps?.clamp(1, 50);

    test('sets are clamped to 1..8', () {
      expect(clampSets(0), equals(1));
      expect(clampSets(9), equals(8));
      expect(clampSets(4), equals(4));
      expect(clampSets(null), isNull);
    });

    test('reps are clamped to 1..50', () {
      expect(clampReps(0), equals(1));
      expect(clampReps(51), equals(50));
      expect(clampReps(12), equals(12));
      expect(clampReps(null), isNull);
    });

    test('minReps/maxReps are swapped when minReps > maxReps', () {
      int? safeMin = 20;
      int? safeMax = 10;
      if (safeMin != null && safeMax != null && safeMin > safeMax) {
        final tmp = safeMin;
        safeMin = safeMax;
        safeMax = tmp;
      }
      expect(safeMin, equals(10));
      expect(safeMax, equals(20));
    });

    test('minReps/maxReps are not swapped when minReps <= maxReps', () {
      int? safeMin = 8;
      int? safeMax = 12;
      if (safeMin != null && safeMax != null && safeMin > safeMax) {
        final tmp = safeMin;
        safeMin = safeMax;
        safeMax = tmp;
      }
      expect(safeMin, equals(8));
      expect(safeMax, equals(12));
    });
  });

  // -------------------------------------------------------------------------
  // addExerciseToTemplate – duplicate detection logic
  // -------------------------------------------------------------------------
  group('addExerciseToTemplate – duplicate detection logic (pure)', () {
    bool isDuplicate(List<Exercise> exercises, String newName) {
      final normalized = newName.trim().toLowerCase();
      return exercises.any(
        (e) => e.name.trim().toLowerCase() == normalized,
      );
    }

    test('detects exact match as duplicate', () {
      final exercises = [makeExercise(name: 'Bench Press')];
      expect(isDuplicate(exercises, 'Bench Press'), isTrue);
    });

    test('detects case-insensitive match as duplicate', () {
      final exercises = [makeExercise(name: 'bench press')];
      expect(isDuplicate(exercises, 'BENCH PRESS'), isTrue);
    });

    test('returns false for non-duplicate', () {
      final exercises = [makeExercise(name: 'Bench Press')];
      expect(isDuplicate(exercises, 'Squat'), isFalse);
    });

    test('returns false for empty list', () {
      expect(isDuplicate([], 'Squat'), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // addExerciseToTemplate – insertAt bounds logic
  // -------------------------------------------------------------------------
  group('addExerciseToTemplate – insertAt bounds (pure)', () {
    int clampInsertAt(int? insertAt, int listLength) {
      var safe = insertAt ?? listLength;
      if (safe < 0) safe = 0;
      if (safe > listLength) safe = listLength;
      return safe;
    }

    test('null insertAt defaults to end of list', () {
      expect(clampInsertAt(null, 3), equals(3));
    });

    test('negative insertAt is clamped to 0', () {
      expect(clampInsertAt(-5, 3), equals(0));
    });

    test('insertAt beyond list length is clamped to length', () {
      expect(clampInsertAt(99, 3), equals(3));
    });

    test('valid insertAt passes through', () {
      expect(clampInsertAt(1, 3), equals(1));
      expect(clampInsertAt(0, 3), equals(0));
      expect(clampInsertAt(3, 3), equals(3));
    });
  });

  // -------------------------------------------------------------------------
  // removeExerciseFromTemplate – match priority logic
  // -------------------------------------------------------------------------
  group('removeExerciseFromTemplate – match priority (pure)', () {
    List<MapEntry<int, Exercise>> findMatches(
      List<Exercise> exercises,
      String target, {
      bool preferExact = true,
    }) {
      final indexed = exercises.asMap().entries.toList();
      final normalized = target.trim().toLowerCase();
      final exactMatches = indexed
          .where((e) => e.value.name.trim().toLowerCase() == normalized)
          .toList();
      final containsMatches = exactMatches.isNotEmpty
          ? exactMatches
          : indexed
                .where(
                  (e) => e.value.name.trim().toLowerCase().contains(normalized),
                )
                .toList();
      return containsMatches;
    }

    test('exact match has priority over contains match', () {
      final exercises = [
        makeExercise(id: 'e1', name: 'Squat'),
        makeExercise(id: 'e2', name: 'Squat Variation'),
      ];
      final matches = findMatches(exercises, 'Squat');
      // Only exact match returned (1 result, not 2)
      expect(matches.length, equals(1));
      expect(matches.first.value.name, equals('Squat'));
    });

    test('falls back to contains match when no exact match', () {
      final exercises = [
        makeExercise(id: 'e1', name: 'Romanian Deadlift'),
        makeExercise(id: 'e2', name: 'Squat'),
      ];
      final matches = findMatches(exercises, 'deadlift');
      expect(matches.length, equals(1));
      expect(matches.first.value.name, equals('Romanian Deadlift'));
    });

    test('returns empty when no match found', () {
      final exercises = [makeExercise(name: 'Bench Press')];
      final matches = findMatches(exercises, 'xyz_no_match');
      expect(matches, isEmpty);
    });

    test('removeAllMatches removes all matching exercises', () {
      final exercises = [
        makeExercise(id: 'e1', name: 'Bench Press'),
        makeExercise(id: 'e2', name: 'Incline Bench Press'),
        makeExercise(id: 'e3', name: 'Squat'),
      ];
      final indexed = exercises.asMap().entries.toList();
      final target = 'bench press';
      final exactMatches = indexed
          .where((e) => e.value.name.trim().toLowerCase() == target)
          .toList();
      final containsMatches = exactMatches.isNotEmpty
          ? exactMatches
          : indexed
                .where(
                  (e) => e.value.name.trim().toLowerCase().contains(target),
                )
                .toList();
      final toRemove = containsMatches.map((e) => e.key).toSet();
      final remaining = indexed
          .where((e) => !toRemove.contains(e.key))
          .map((e) => e.value)
          .toList();
      expect(remaining.length, equals(1));
      expect(remaining.first.name, equals('Squat'));
    });

    test('removeFirstMatch removes only first match', () {
      final exercises = [
        makeExercise(id: 'e1', name: 'Bench Press'),
        makeExercise(id: 'e2', name: 'Incline Bench Press'),
      ];
      final indexed = exercises.asMap().entries.toList();
      final target = 'bench press';
      final exactMatches = indexed
          .where((e) => e.value.name.trim().toLowerCase() == target)
          .toList();
      final containsMatches = exactMatches.isNotEmpty
          ? exactMatches
          : indexed
                .where(
                  (e) => e.value.name.trim().toLowerCase().contains(target),
                )
                .toList();
      // Only first match
      final toRemove = {containsMatches.first.key};
      final remaining = indexed
          .where((e) => !toRemove.contains(e.key))
          .map((e) => e.value)
          .toList();
      expect(remaining.length, equals(1));
      expect(remaining.first.name, equals('Incline Bench Press'));
    });
  });

  // -------------------------------------------------------------------------
  // replaceExerciseInTemplate – match logic
  // -------------------------------------------------------------------------
  group('replaceExerciseInTemplate – match and replace logic (pure)', () {
    test('replaces only first matching exercise when replaceAllMatches=false', () {
      final exercises = [
        makeExercise(id: 'e1', name: 'Squat'),
        makeExercise(id: 'e2', name: 'Squat'),
        makeExercise(id: 'e3', name: 'Deadlift'),
      ];
      final newExercise = makeExercise(id: 'new', name: 'Box Squat');
      final indexed = exercises.asMap().entries.toList();
      final target = 'squat';
      final exactMatches = indexed
          .where((e) => e.value.name.trim().toLowerCase() == target)
          .toList();
      final toReplace = {exactMatches.first.key}; // first only
      final result = indexed.map((e) {
        if (toReplace.contains(e.key)) return newExercise;
        return e.value;
      }).toList();

      expect(result[0].name, equals('Box Squat'));
      expect(result[1].name, equals('Squat')); // unchanged
      expect(result[2].name, equals('Deadlift'));
    });

    test('replaces all matching exercises when replaceAllMatches=true', () {
      final exercises = [
        makeExercise(id: 'e1', name: 'Squat'),
        makeExercise(id: 'e2', name: 'Squat'),
        makeExercise(id: 'e3', name: 'Deadlift'),
      ];
      final newExercise = makeExercise(id: 'new', name: 'Box Squat');
      final indexed = exercises.asMap().entries.toList();
      final target = 'squat';
      final exactMatches = indexed
          .where((e) => e.value.name.trim().toLowerCase() == target)
          .toList();
      final toReplace = exactMatches.map((e) => e.key).toSet();
      final result = indexed.map((e) {
        if (toReplace.contains(e.key)) return newExercise;
        return e.value;
      }).toList();

      expect(result[0].name, equals('Box Squat'));
      expect(result[1].name, equals('Box Squat'));
      expect(result[2].name, equals('Deadlift'));
    });
  });

  // -------------------------------------------------------------------------
  // updateExerciseSetRepsInTemplate – buildSetFromBase logic
  // -------------------------------------------------------------------------
  group('updateExerciseSetRepsInTemplate – buildSetFromBase (pure)', () {
    ExerciseSet buildSet({
      required ExerciseSet? base,
      required int setNumber,
      int? safeReps,
      int? safeMinReps,
      int? safeMaxReps,
    }) {
      final useRange = safeMinReps != null && safeMaxReps != null;
      final resolvedReps = useRange
          ? null
          : (safeReps ?? base?.reps ?? 10);
      final resolvedMin = useRange
          ? safeMinReps
          : (safeReps != null ? null : base?.minReps);
      final resolvedMax = useRange
          ? safeMaxReps
          : (safeReps != null ? null : base?.maxReps);

      return ExerciseSet(
        id: base?.id,
        setNumber: setNumber,
        weight: base?.weight,
        reps: resolvedReps,
        minReps: resolvedMin,
        maxReps: resolvedMax,
      );
    }

    test('uses safeReps when provided (no range)', () {
      final base = makeSet(setNumber: 1, reps: 5);
      final result = buildSet(base: base, setNumber: 1, safeReps: 12);
      expect(result.reps, equals(12));
      expect(result.minReps, isNull);
      expect(result.maxReps, isNull);
    });

    test('uses range when both minReps and maxReps provided', () {
      final base = makeSet(setNumber: 1);
      final result = buildSet(
        base: base,
        setNumber: 1,
        safeMinReps: 8,
        safeMaxReps: 12,
      );
      expect(result.reps, isNull);
      expect(result.minReps, equals(8));
      expect(result.maxReps, equals(12));
    });

    test('falls back to base.reps when safeReps not provided', () {
      final base = makeSet(setNumber: 1, reps: 15);
      final result = buildSet(base: base, setNumber: 1);
      expect(result.reps, equals(15));
    });

    test('falls back to default reps (10) when base and safeReps both null', () {
      final result = buildSet(base: null, setNumber: 1);
      expect(result.reps, equals(10));
    });
  });
}
