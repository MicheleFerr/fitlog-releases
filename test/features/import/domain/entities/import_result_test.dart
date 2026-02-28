import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/import/domain/entities/import_result.dart';

void main() {
  group('ImportParseResult', () {
    test('creates with required fields', () {
      const result = ImportParseResult(
        sourceApp: 'strong',
        workouts: [],
        unmappedExercises: [],
        autoMappedExercises: {},
        totalRows: 0,
        parsedRows: 0,
      );

      expect(result.sourceApp, 'strong');
      expect(result.workouts, isEmpty);
      expect(result.unmappedExercises, isEmpty);
      expect(result.autoMappedExercises, isEmpty);
      expect(result.warnings, isEmpty); // default
      expect(result.totalRows, 0);
      expect(result.parsedRows, 0);
    });

    test('defaults warnings to empty list', () {
      const result = ImportParseResult(
        sourceApp: 'hevy',
        workouts: [],
        unmappedExercises: [],
        autoMappedExercises: {},
        totalRows: 5,
        parsedRows: 5,
      );

      expect(result.warnings, const <String>[]);
    });

    test('copyWith updates fields', () {
      const original = ImportParseResult(
        sourceApp: 'strong',
        workouts: [],
        unmappedExercises: [],
        autoMappedExercises: {},
        totalRows: 10,
        parsedRows: 8,
      );

      final updated = original.copyWith(
        parsedRows: 10,
        warnings: ['some warning'],
      );

      expect(updated.sourceApp, 'strong');
      expect(updated.totalRows, 10);
      expect(updated.parsedRows, 10);
      expect(updated.warnings, ['some warning']);
    });

    test('equality works correctly', () {
      const a = ImportParseResult(
        sourceApp: 'strong',
        workouts: [],
        unmappedExercises: [],
        autoMappedExercises: {},
        totalRows: 5,
        parsedRows: 5,
      );

      const b = ImportParseResult(
        sourceApp: 'strong',
        workouts: [],
        unmappedExercises: [],
        autoMappedExercises: {},
        totalRows: 5,
        parsedRows: 5,
      );

      expect(a, equals(b));
    });

    test('inequality when fields differ', () {
      const a = ImportParseResult(
        sourceApp: 'strong',
        workouts: [],
        unmappedExercises: [],
        autoMappedExercises: {},
        totalRows: 5,
        parsedRows: 5,
      );

      const b = ImportParseResult(
        sourceApp: 'hevy',
        workouts: [],
        unmappedExercises: [],
        autoMappedExercises: {},
        totalRows: 5,
        parsedRows: 5,
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('ParsedWorkout', () {
    test('creates with required fields', () {
      final date = DateTime(2024, 1, 15);
      final workout = ParsedWorkout(
        name: 'Push Day',
        date: date,
        exercises: const [],
      );

      expect(workout.name, 'Push Day');
      expect(workout.date, date);
      expect(workout.exercises, isEmpty);
      expect(workout.durationMinutes, isNull);
      expect(workout.notes, isNull);
    });

    test('creates with optional fields', () {
      final date = DateTime(2024, 1, 15, 10, 30);
      const exercise = ParsedExercise(
        originalName: 'Bench Press',
        sets: [
          ParsedSet(setNumber: 1, weight: 80.0, reps: 8),
        ],
      );

      final workout = ParsedWorkout(
        name: 'Push Day',
        date: date,
        durationMinutes: 60,
        notes: 'Great session',
        exercises: [exercise],
      );

      expect(workout.durationMinutes, 60);
      expect(workout.notes, 'Great session');
      expect(workout.exercises.length, 1);
    });

    test('copyWith preserves other fields', () {
      final original = ParsedWorkout(
        name: 'Push Day',
        date: DateTime(2024, 1, 15),
        durationMinutes: 45,
        exercises: const [],
      );

      final updated = original.copyWith(name: 'Pull Day');

      expect(updated.name, 'Pull Day');
      expect(updated.durationMinutes, 45);
      expect(updated.date, DateTime(2024, 1, 15));
    });

    test('equality is structural not referential', () {
      final date = DateTime(2024, 1, 15);
      final a = ParsedWorkout(name: 'Leg Day', date: date, exercises: const []);
      final b = ParsedWorkout(name: 'Leg Day', date: date, exercises: const []);

      expect(a, equals(b));
    });
  });

  group('ParsedExercise', () {
    test('creates with originalName and sets', () {
      const exercise = ParsedExercise(
        originalName: 'Squat',
        sets: [ParsedSet(setNumber: 1, weight: 100.0, reps: 5)],
      );

      expect(exercise.originalName, 'Squat');
      expect(exercise.sets.length, 1);
      expect(exercise.mappedExerciseId, isNull);
      expect(exercise.mappedExerciseName, isNull);
    });

    test('creates with mapped fields', () {
      const exercise = ParsedExercise(
        originalName: 'Bench Press',
        mappedExerciseId: 'ex-001',
        mappedExerciseName: 'Panca Piana',
        sets: [],
      );

      expect(exercise.mappedExerciseId, 'ex-001');
      expect(exercise.mappedExerciseName, 'Panca Piana');
    });

    test('isMapped returns true when mapped', () {
      const exercise = ParsedExercise(
        originalName: 'Bench Press',
        mappedExerciseId: 'ex-001',
        mappedExerciseName: 'Panca Piana',
        sets: [],
      );

      expect(exercise.mappedExerciseId, isNotNull);
    });

    test('copyWith can set mappedExerciseId', () {
      const original = ParsedExercise(
        originalName: 'Pull Up',
        sets: [],
      );

      final mapped = original.copyWith(
        mappedExerciseId: 'ex-050',
        mappedExerciseName: 'Trazioni',
      );

      expect(mapped.originalName, 'Pull Up');
      expect(mapped.mappedExerciseId, 'ex-050');
      expect(mapped.mappedExerciseName, 'Trazioni');
    });

    test('equality based on fields', () {
      const a = ParsedExercise(originalName: 'Squat', sets: []);
      const b = ParsedExercise(originalName: 'Squat', sets: []);
      expect(a, equals(b));
    });
  });

  group('ParsedSet', () {
    test('creates with required setNumber only', () {
      const set = ParsedSet(setNumber: 1);

      expect(set.setNumber, 1);
      expect(set.weight, isNull);
      expect(set.reps, isNull);
      expect(set.seconds, isNull);
      expect(set.distance, isNull);
      expect(set.rpe, isNull);
      expect(set.notes, isNull);
    });

    test('creates fully populated set', () {
      const set = ParsedSet(
        setNumber: 2,
        weight: 80.5,
        reps: 8,
        seconds: null,
        distance: null,
        rpe: 8,
        notes: 'Good form',
      );

      expect(set.setNumber, 2);
      expect(set.weight, 80.5);
      expect(set.reps, 8);
      expect(set.rpe, 8);
      expect(set.notes, 'Good form');
    });

    test('creates cardio set with distance and duration', () {
      const set = ParsedSet(
        setNumber: 1,
        seconds: 1800,
        distance: 5.0,
      );

      expect(set.seconds, 1800);
      expect(set.distance, 5.0);
      expect(set.weight, isNull);
      expect(set.reps, isNull);
    });

    test('equality is structural', () {
      const a = ParsedSet(setNumber: 1, weight: 100.0, reps: 5);
      const b = ParsedSet(setNumber: 1, weight: 100.0, reps: 5);
      expect(a, equals(b));
    });

    test('inequality when reps differ', () {
      const a = ParsedSet(setNumber: 1, weight: 100.0, reps: 5);
      const b = ParsedSet(setNumber: 1, weight: 100.0, reps: 6);
      expect(a, isNot(equals(b)));
    });

    test('copyWith works correctly', () {
      const original = ParsedSet(setNumber: 1, weight: 100.0, reps: 5);
      final updated = original.copyWith(reps: 8);

      expect(updated.setNumber, 1);
      expect(updated.weight, 100.0);
      expect(updated.reps, 8);
    });
  });

  group('UnmappedExercise', () {
    test('creates with required fields', () {
      const unmapped = UnmappedExercise(
        originalName: 'Bench Press',
        occurrences: 12,
      );

      expect(unmapped.originalName, 'Bench Press');
      expect(unmapped.occurrences, 12);
      expect(unmapped.suggestions, isEmpty); // default
    });

    test('creates with suggestions', () {
      const suggestions = [
        ExerciseMatch(
          exerciseId: 'ex-001',
          name: 'Panca Piana',
          confidence: 0.95,
        ),
      ];

      const unmapped = UnmappedExercise(
        originalName: 'Flat Bench Press',
        occurrences: 5,
        suggestions: suggestions,
      );

      expect(unmapped.suggestions.length, 1);
      expect(unmapped.suggestions.first.confidence, 0.95);
    });

    test('copyWith can add suggestions', () {
      const original = UnmappedExercise(
        originalName: 'Bench Press',
        occurrences: 10,
      );

      final withSuggestions = original.copyWith(
        suggestions: [
          const ExerciseMatch(
            exerciseId: 'ex-001',
            name: 'Panca Piana',
            confidence: 0.9,
          ),
        ],
      );

      expect(withSuggestions.originalName, 'Bench Press');
      expect(withSuggestions.suggestions.length, 1);
    });
  });

  group('ExerciseMatch', () {
    test('creates with all required fields', () {
      const match = ExerciseMatch(
        exerciseId: 'ex-001',
        name: 'Panca Piana',
        confidence: 0.95,
      );

      expect(match.exerciseId, 'ex-001');
      expect(match.name, 'Panca Piana');
      expect(match.confidence, 0.95);
    });

    test('equality is structural', () {
      const a = ExerciseMatch(
        exerciseId: 'ex-001',
        name: 'Squat',
        confidence: 0.8,
      );
      const b = ExerciseMatch(
        exerciseId: 'ex-001',
        name: 'Squat',
        confidence: 0.8,
      );
      expect(a, equals(b));
    });

    test('copyWith updates confidence', () {
      const original = ExerciseMatch(
        exerciseId: 'ex-001',
        name: 'Panca Piana',
        confidence: 0.7,
      );
      final updated = original.copyWith(confidence: 0.95);
      expect(updated.confidence, 0.95);
      expect(updated.exerciseId, 'ex-001');
    });
  });

  group('ImportFinalResult', () {
    test('creates with required fields', () {
      final now = DateTime(2024, 1, 15);
      final result = ImportFinalResult(
        workoutsImported: 10,
        workoutsSkipped: 2,
        exercisesImported: 45,
        setsImported: 180,
        importedAt: now,
        sourceApp: 'strong',
      );

      expect(result.workoutsImported, 10);
      expect(result.workoutsSkipped, 2);
      expect(result.exercisesImported, 45);
      expect(result.setsImported, 180);
      expect(result.errors, isEmpty); // default
      expect(result.importedAt, now);
      expect(result.sourceApp, 'strong');
    });

    test('creates with errors', () {
      final result = ImportFinalResult(
        workoutsImported: 8,
        workoutsSkipped: 2,
        exercisesImported: 30,
        setsImported: 120,
        importedAt: DateTime(2024, 1, 15),
        sourceApp: 'hevy',
        errors: ['Row 5: invalid date', 'Row 12: missing exercise name'],
      );

      expect(result.errors.length, 2);
    });

    test('copyWith works', () {
      final original = ImportFinalResult(
        workoutsImported: 5,
        workoutsSkipped: 0,
        exercisesImported: 20,
        setsImported: 80,
        importedAt: DateTime(2024, 1, 15),
        sourceApp: 'strong',
      );

      final updated = original.copyWith(workoutsImported: 10);
      expect(updated.workoutsImported, 10);
      expect(updated.sourceApp, 'strong');
    });
  });
}
