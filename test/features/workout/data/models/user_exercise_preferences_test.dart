import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/user_exercise_preferences.dart';

void main() {
  group('UserExercisePreferences', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final now = DateTime(2024, 1, 15);
        final prefs = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench Press',
          updatedAt: now,
        );

        expect(prefs.visibleId, 'ex-1');
        expect(prefs.exerciseName, 'Bench Press');
        expect(prefs.formCues, isNull);
        expect(prefs.updatedAt, now);
        expect(prefs.needsSync, false);
      });

      test('creates instance with all fields', () {
        final now = DateTime(2024, 1, 15);
        final prefs = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench Press',
          formCues: 'Keep elbows tucked',
          updatedAt: now,
          needsSync: true,
        );

        expect(prefs.visibleId, 'ex-1');
        expect(prefs.exerciseName, 'Bench Press');
        expect(prefs.formCues, 'Keep elbows tucked');
        expect(prefs.updatedAt, now);
        expect(prefs.needsSync, true);
      });

      test('defaults needsSync to false', () {
        final prefs = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Test',
          updatedAt: DateTime.now(),
        );
        expect(prefs.needsSync, false);
      });
    });

    group('generateKey', () {
      test('returns exerciseId when provided', () {
        final key = UserExercisePreferences.generateKey(
          'exercise-123',
          'Bench Press',
        );
        expect(key, 'exercise-123');
      });

      test('returns normalized name when exerciseId is null', () {
        final key = UserExercisePreferences.generateKey(null, 'Bench Press');
        expect(key, 'bench_press');
      });

      test('normalizes name to lowercase', () {
        final key = UserExercisePreferences.generateKey(null, 'BENCH PRESS');
        expect(key, 'bench_press');
      });

      test('trims whitespace from name', () {
        final key = UserExercisePreferences.generateKey(
          null,
          '  Bench Press  ',
        );
        expect(key, 'bench_press');
      });

      test('collapses multiple spaces to single underscore', () {
        final key = UserExercisePreferences.generateKey(
          null,
          'Bench   Press   Hard',
        );
        expect(key, 'bench_press_hard');
      });

      test('handles single word name', () {
        final key = UserExercisePreferences.generateKey(null, 'Squat');
        expect(key, 'squat');
      });

      test('handles empty string name', () {
        final key = UserExercisePreferences.generateKey(null, '');
        expect(key, '');
      });

      test('handles name with tabs and newlines', () {
        final key = UserExercisePreferences.generateKey(
          null,
          'Bench\t\nPress',
        );
        expect(key, 'bench_press');
      });
    });

    group('copyWith', () {
      test('creates new instance with modified fields', () {
        final now = DateTime(2024, 1, 15);
        final later = DateTime(2024, 2, 20);
        final original = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench Press',
          formCues: 'Old cues',
          updatedAt: now,
          needsSync: false,
        );
        final modified = original.copyWith(
          formCues: 'New cues',
          updatedAt: later,
          needsSync: true,
        );

        expect(modified.visibleId, 'ex-1');
        expect(modified.exerciseName, 'Bench Press');
        expect(modified.formCues, 'New cues');
        expect(modified.updatedAt, later);
        expect(modified.needsSync, true);
      });

      test('preserves all fields when no arguments', () {
        final now = DateTime(2024, 1, 15);
        final original = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench Press',
          formCues: 'Keep elbows tucked',
          updatedAt: now,
          needsSync: true,
        );
        final modified = original.copyWith();

        expect(modified.visibleId, original.visibleId);
        expect(modified.exerciseName, original.exerciseName);
        expect(modified.formCues, original.formCues);
        expect(modified.updatedAt, original.updatedAt);
        expect(modified.needsSync, original.needsSync);
      });

      test('can modify visibleId', () {
        final original = UserExercisePreferences(
          visibleId: 'old-id',
          exerciseName: 'Test',
          updatedAt: DateTime.now(),
        );
        final modified = original.copyWith(visibleId: 'new-id');
        expect(modified.visibleId, 'new-id');
      });

      test('can modify exerciseName', () {
        final original = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Old Name',
          updatedAt: DateTime.now(),
        );
        final modified = original.copyWith(exerciseName: 'New Name');
        expect(modified.exerciseName, 'New Name');
      });
    });

    group('toString', () {
      test('returns formatted string with all fields', () {
        final now = DateTime(2024, 1, 15, 10, 30);
        final prefs = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench Press',
          formCues: 'Focus on form',
          updatedAt: now,
          needsSync: true,
        );
        final result = prefs.toString();

        expect(result, contains('UserExercisePreferences'));
        expect(result, contains('visibleId: ex-1'));
        expect(result, contains('exerciseName: Bench Press'));
        expect(result, contains('formCues: Focus on form'));
        expect(result, contains('needsSync: true'));
      });

      test('handles null formCues', () {
        final prefs = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Test',
          updatedAt: DateTime.now(),
        );
        final result = prefs.toString();
        expect(result, contains('formCues: null'));
      });
    });
  });
}
