import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Integration tests for Exercise entity with ExerciseCountingMode
///
/// These tests verify that:
/// 1. Exercise can be created with different counting modes
/// 2. Counting mode is properly serialized/deserialized
/// 3. Exercise sets validate correctly based on counting mode
void main() {
  group('Exercise with ExerciseCountingMode', () {
    group('Constructor and Default Values', () {
      test('should default to weighted mode when not specified', () {
        final exercise = Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
        );

        expect(exercise.countingMode, ExerciseCountingMode.weighted);
      });

      test('should accept weighted counting mode', () {
        final exercise = Exercise(
          name: 'Squat',
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
          countingMode: ExerciseCountingMode.weighted,
        );

        expect(exercise.countingMode, ExerciseCountingMode.weighted);
      });

      test('should accept reps counting mode', () {
        final exercise = Exercise(
          name: 'Push-up',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.reps,
        );

        expect(exercise.countingMode, ExerciseCountingMode.reps);
      });

      test('should accept time counting mode', () {
        final exercise = Exercise(
          name: 'Plank',
          type: ExerciseType.single,
          category: ExerciseCategory.abs,
          countingMode: ExerciseCountingMode.time,
        );

        expect(exercise.countingMode, ExerciseCountingMode.time);
      });
    });

    group('copyWith', () {
      test('should preserve counting mode when not changed', () {
        final exercise = Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.weighted,
        );

        final copy = exercise.copyWith(name: 'Incline Bench Press');

        expect(copy.countingMode, ExerciseCountingMode.weighted);
      });

      test('should update counting mode when specified', () {
        final exercise = Exercise(
          name: 'Push-up',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.weighted,
        );

        final copy = exercise.copyWith(
          countingMode: ExerciseCountingMode.reps,
        );

        expect(copy.countingMode, ExerciseCountingMode.reps);
      });

      test('should change from weighted to time mode', () {
        final exercise = Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.weighted,
        );

        final copy = exercise.copyWith(
          name: 'Plank',
          category: ExerciseCategory.abs,
          countingMode: ExerciseCountingMode.time,
        );

        expect(copy.countingMode, ExerciseCountingMode.time);
        expect(copy.name, 'Plank');
      });
    });

    group('Serialization', () {
      test('should serialize weighted mode correctly', () {
        final exercise = Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.weighted,
        );

        final json = exercise.toJson();

        expect(json['countingMode'], 'weighted');
      });

      test('should serialize reps mode correctly', () {
        final exercise = Exercise(
          name: 'Push-up',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.reps,
        );

        final json = exercise.toJson();

        expect(json['countingMode'], 'reps');
      });

      test('should serialize time mode correctly', () {
        final exercise = Exercise(
          name: 'Plank',
          type: ExerciseType.single,
          category: ExerciseCategory.abs,
          countingMode: ExerciseCountingMode.time,
        );

        final json = exercise.toJson();

        expect(json['countingMode'], 'time');
      });
    });

    group('Deserialization', () {
      test('should deserialize weighted mode correctly', () {
        final json = {
          'id': 'test-id',
          'name': 'Bench Press',
          'type': 'single',
          'category': 'chest',
          'sets': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'countingMode': 'weighted',
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.countingMode, ExerciseCountingMode.weighted);
      });

      test('should deserialize reps mode correctly', () {
        final json = {
          'id': 'test-id',
          'name': 'Push-up',
          'type': 'single',
          'category': 'chest',
          'sets': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'countingMode': 'reps',
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.countingMode, ExerciseCountingMode.reps);
      });

      test('should deserialize time mode correctly', () {
        final json = {
          'id': 'test-id',
          'name': 'Plank',
          'type': 'single',
          'category': 'abs',
          'sets': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'countingMode': 'time',
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.countingMode, ExerciseCountingMode.time);
      });

      test('should default to weighted when countingMode is null', () {
        final json = {
          'id': 'test-id',
          'name': 'Bench Press',
          'type': 'single',
          'category': 'chest',
          'sets': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          // countingMode missing
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.countingMode, ExerciseCountingMode.weighted);
      });

      test('should default to weighted when countingMode is invalid', () {
        final json = {
          'id': 'test-id',
          'name': 'Bench Press',
          'type': 'single',
          'category': 'chest',
          'sets': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'countingMode': 'invalid_mode',
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.countingMode, ExerciseCountingMode.weighted);
      });
    });

    group('Round-trip Serialization', () {
      test('should preserve weighted mode through serialization', () {
        final original = Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.weighted,
        );

        final json = original.toJson();
        final deserialized = Exercise.fromJson(json);

        expect(deserialized.countingMode, original.countingMode);
      });

      test('should preserve reps mode through serialization', () {
        final original = Exercise(
          name: 'Push-up',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.reps,
        );

        final json = original.toJson();
        final deserialized = Exercise.fromJson(json);

        expect(deserialized.countingMode, original.countingMode);
      });

      test('should preserve time mode through serialization', () {
        final original = Exercise(
          name: 'Plank',
          type: ExerciseType.single,
          category: ExerciseCategory.abs,
          countingMode: ExerciseCountingMode.time,
        );

        final json = original.toJson();
        final deserialized = Exercise.fromJson(json);

        expect(deserialized.countingMode, original.countingMode);
      });
    });

    group('Integration with Sets', () {
      test('weighted exercise should have sets with weight and reps', () {
        final exercise = Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.weighted,
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: 60.0,
              reps: 10,
            ),
            ExerciseSet(
              setNumber: 2,
              weight: 70.0,
              reps: 8,
            ),
          ],
        );

        expect(exercise.sets.length, 2);
        for (final set in exercise.sets) {
          expect(set.isValid(exercise.countingMode), true);
          expect(set.weight, isNotNull);
          expect(set.reps, isNotNull);
        }
      });

      test('reps exercise should have sets with only reps', () {
        final exercise = Exercise(
          name: 'Push-up',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.reps,
          sets: [
            ExerciseSet(
              setNumber: 1,
              reps: 15,
            ),
            ExerciseSet(
              setNumber: 2,
              reps: 12,
            ),
          ],
        );

        expect(exercise.sets.length, 2);
        for (final set in exercise.sets) {
          expect(set.isValid(exercise.countingMode), true);
          expect(set.reps, isNotNull);
          expect(set.weight, isNull);
        }
      });

      test('time exercise should have sets with seconds', () {
        final exercise = Exercise(
          name: 'Plank',
          type: ExerciseType.single,
          category: ExerciseCategory.abs,
          countingMode: ExerciseCountingMode.time,
          sets: [
            ExerciseSet(
              setNumber: 1,
              seconds: 60,
            ),
            ExerciseSet(
              setNumber: 2,
              seconds: 45,
            ),
          ],
        );

        expect(exercise.sets.length, 2);
        for (final set in exercise.sets) {
          expect(set.isValid(exercise.countingMode), true);
          expect(set.seconds, isNotNull);
          expect(set.weight, isNull);
          expect(set.reps, isNull);
        }
      });
    });

    group('Validation Scenarios', () {
      test('should detect invalid weighted set (missing weight)', () {
        final exercise = Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.weighted,
        );

        final invalidSet = ExerciseSet(
          setNumber: 1,
          reps: 10,
          // weight missing
        );

        expect(invalidSet.isValid(exercise.countingMode), false);
        expect(
          invalidSet.getMissingFields(exercise.countingMode),
          contains('weight'),
        );
      });

      test('should detect invalid weighted set (missing reps)', () {
        final exercise = Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.weighted,
        );

        final invalidSet = ExerciseSet(
          setNumber: 1,
          weight: 60.0,
          // reps missing
        );

        expect(invalidSet.isValid(exercise.countingMode), false);
        expect(
          invalidSet.getMissingFields(exercise.countingMode),
          contains('reps'),
        );
      });

      test('should detect invalid reps set (missing reps)', () {
        final exercise = Exercise(
          name: 'Push-up',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.reps,
        );

        final invalidSet = ExerciseSet(
          setNumber: 1,
          // reps missing
        );

        expect(invalidSet.isValid(exercise.countingMode), false);
        expect(
          invalidSet.getMissingFields(exercise.countingMode),
          contains('reps'),
        );
      });

      test('should detect invalid time set (missing seconds)', () {
        final exercise = Exercise(
          name: 'Plank',
          type: ExerciseType.single,
          category: ExerciseCategory.abs,
          countingMode: ExerciseCountingMode.time,
        );

        final invalidSet = ExerciseSet(
          setNumber: 1,
          // seconds missing
        );

        expect(invalidSet.isValid(exercise.countingMode), false);
        expect(
          invalidSet.getMissingFields(exercise.countingMode),
          contains('seconds'),
        );
      });
    });

    group('Display Text Generation', () {
      test('should generate correct display text for weighted set', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: 60.5,
          reps: 10,
        );

        final displayText = set.getDisplayText(ExerciseCountingMode.weighted);

        expect(displayText, contains('60.5'));
        expect(displayText, contains('10'));
        expect(displayText, contains('kg'));
        expect(displayText, contains('reps'));
      });

      test('should generate correct display text for reps set', () {
        final set = ExerciseSet(
          setNumber: 1,
          reps: 15,
        );

        final displayText = set.getDisplayText(ExerciseCountingMode.reps);

        expect(displayText, contains('15'));
        expect(displayText, contains('reps'));
        expect(displayText, isNot(contains('kg')));
      });

      test('should generate correct display text for time set (seconds)', () {
        final set = ExerciseSet(
          setNumber: 1,
          seconds: 45,
        );

        final displayText = set.getDisplayText(ExerciseCountingMode.time);

        expect(displayText, contains('45'));
        expect(displayText, contains('s'));
        expect(displayText, isNot(contains('m')));
      });

      test('should generate correct display text for time set (minutes)', () {
        final set = ExerciseSet(
          setNumber: 1,
          seconds: 90, // 1 minute 30 seconds
        );

        final displayText = set.getDisplayText(ExerciseCountingMode.time);

        expect(displayText, contains('1m'));
        expect(displayText, contains('30s'));
      });
    });
  });
}
