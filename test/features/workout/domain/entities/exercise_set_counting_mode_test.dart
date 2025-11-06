import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Unit tests for ExerciseSet validation and helper methods with ExerciseCountingMode
///
/// Tests cover:
/// 1. isValid() method for all counting modes
/// 2. getMissingFields() method
/// 3. getDisplayText() method
/// 4. Edge cases and boundary conditions
void main() {
  group('ExerciseSet - Counting Mode Validation', () {
    group('isValid() - Weighted Mode', () {
      test('should return true when both weight and reps are present', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: 60.0,
          reps: 10,
        );

        expect(set.isValid(ExerciseCountingMode.weighted), true);
      });

      test('should return false when weight is missing', () {
        final set = ExerciseSet(
          setNumber: 1,
          reps: 10,
        );

        expect(set.isValid(ExerciseCountingMode.weighted), false);
      });

      test('should return false when reps are missing', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: 60.0,
        );

        expect(set.isValid(ExerciseCountingMode.weighted), false);
      });

      test('should return false when weight is zero', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: 0.0,
          reps: 10,
        );

        expect(set.isValid(ExerciseCountingMode.weighted), false);
      });

      test('should return false when reps are zero', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: 60.0,
          reps: 0,
        );

        expect(set.isValid(ExerciseCountingMode.weighted), false);
      });

      test('should return false when both are zero', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: 0.0,
          reps: 0,
        );

        expect(set.isValid(ExerciseCountingMode.weighted), false);
      });

      test('should return true with actualReps instead of target reps', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: 60.0,
          reps: 10,
          actualReps: 8,
        );

        expect(set.isValid(ExerciseCountingMode.weighted), true);
      });
    });

    group('isValid() - Reps Mode', () {
      test('should return true when reps are present', () {
        final set = ExerciseSet(
          setNumber: 1,
          reps: 15,
        );

        expect(set.isValid(ExerciseCountingMode.reps), true);
      });

      test('should return false when reps are missing', () {
        final set = ExerciseSet(
          setNumber: 1,
        );

        expect(set.isValid(ExerciseCountingMode.reps), false);
      });

      test('should return false when reps are zero', () {
        final set = ExerciseSet(
          setNumber: 1,
          reps: 0,
        );

        expect(set.isValid(ExerciseCountingMode.reps), false);
      });

      test('should ignore weight field (bodyweight exercise)', () {
        final set = ExerciseSet(
          setNumber: 1,
          reps: 15,
          weight: 10.0, // Weight should be ignored
        );

        expect(set.isValid(ExerciseCountingMode.reps), true);
      });

      test('should return true with actualReps', () {
        final set = ExerciseSet(
          setNumber: 1,
          reps: 15,
          actualReps: 12,
        );

        expect(set.isValid(ExerciseCountingMode.reps), true);
      });
    });

    group('isValid() - Time Mode', () {
      test('should return true when seconds are present', () {
        final set = ExerciseSet(
          setNumber: 1,
          seconds: 60,
        );

        expect(set.isValid(ExerciseCountingMode.time), true);
      });

      test('should return false when seconds are missing', () {
        final set = ExerciseSet(
          setNumber: 1,
        );

        expect(set.isValid(ExerciseCountingMode.time), false);
      });

      test('should return false when seconds are zero', () {
        final set = ExerciseSet(
          setNumber: 1,
          seconds: 0,
        );

        expect(set.isValid(ExerciseCountingMode.time), false);
      });

      test('should ignore weight and reps fields', () {
        final set = ExerciseSet(
          setNumber: 1,
          seconds: 60,
          weight: 10.0, // Should be ignored
          reps: 5, // Should be ignored
        );

        expect(set.isValid(ExerciseCountingMode.time), true);
      });

      test('should work with large time values (multiple minutes)', () {
        final set = ExerciseSet(
          setNumber: 1,
          seconds: 300, // 5 minutes
        );

        expect(set.isValid(ExerciseCountingMode.time), true);
      });
    });

    group('getMissingFields()', () {
      group('Weighted Mode', () {
        test('should return empty list when all fields present', () {
          final set = ExerciseSet(
            setNumber: 1,
            weight: 60.0,
            reps: 10,
          );

          final missing = set.getMissingFields(ExerciseCountingMode.weighted);

          expect(missing, isEmpty);
        });

        test('should return [weight] when weight is missing', () {
          final set = ExerciseSet(
            setNumber: 1,
            reps: 10,
          );

          final missing = set.getMissingFields(ExerciseCountingMode.weighted);

          expect(missing, ['weight']);
        });

        test('should return [reps] when reps are missing', () {
          final set = ExerciseSet(
            setNumber: 1,
            weight: 60.0,
          );

          final missing = set.getMissingFields(ExerciseCountingMode.weighted);

          expect(missing, ['reps']);
        });

        test('should return [weight, reps] when both are missing', () {
          final set = ExerciseSet(
            setNumber: 1,
          );

          final missing = set.getMissingFields(ExerciseCountingMode.weighted);

          expect(missing, containsAll(['weight', 'reps']));
          expect(missing.length, 2);
        });

        test('should return [weight] when weight is zero', () {
          final set = ExerciseSet(
            setNumber: 1,
            weight: 0.0,
            reps: 10,
          );

          final missing = set.getMissingFields(ExerciseCountingMode.weighted);

          expect(missing, ['weight']);
        });
      });

      group('Reps Mode', () {
        test('should return empty list when reps present', () {
          final set = ExerciseSet(
            setNumber: 1,
            reps: 15,
          );

          final missing = set.getMissingFields(ExerciseCountingMode.reps);

          expect(missing, isEmpty);
        });

        test('should return [reps] when reps are missing', () {
          final set = ExerciseSet(
            setNumber: 1,
          );

          final missing = set.getMissingFields(ExerciseCountingMode.reps);

          expect(missing, ['reps']);
        });

        test('should return [reps] when reps are zero', () {
          final set = ExerciseSet(
            setNumber: 1,
            reps: 0,
          );

          final missing = set.getMissingFields(ExerciseCountingMode.reps);

          expect(missing, ['reps']);
        });
      });

      group('Time Mode', () {
        test('should return empty list when seconds present', () {
          final set = ExerciseSet(
            setNumber: 1,
            seconds: 60,
          );

          final missing = set.getMissingFields(ExerciseCountingMode.time);

          expect(missing, isEmpty);
        });

        test('should return [seconds] when seconds are missing', () {
          final set = ExerciseSet(
            setNumber: 1,
          );

          final missing = set.getMissingFields(ExerciseCountingMode.time);

          expect(missing, ['seconds']);
        });

        test('should return [seconds] when seconds are zero', () {
          final set = ExerciseSet(
            setNumber: 1,
            seconds: 0,
          );

          final missing = set.getMissingFields(ExerciseCountingMode.time);

          expect(missing, ['seconds']);
        });
      });
    });

    group('getDisplayText()', () {
      group('Weighted Mode', () {
        test('should display weight and reps correctly', () {
          final set = ExerciseSet(
            setNumber: 1,
            weight: 60.0,
            reps: 10,
          );

          final text = set.getDisplayText(ExerciseCountingMode.weighted);

          expect(text, '60.0 kg × 10 reps');
        });

        test('should display actualReps when present', () {
          final set = ExerciseSet(
            setNumber: 1,
            weight: 60.0,
            reps: 10,
            actualReps: 8,
          );

          final text = set.getDisplayText(ExerciseCountingMode.weighted);

          expect(text, '60.0 kg × 8 reps');
        });

        test('should show ? when weight is missing', () {
          final set = ExerciseSet(
            setNumber: 1,
            reps: 10,
          );

          final text = set.getDisplayText(ExerciseCountingMode.weighted);

          expect(text, contains('?'));
          expect(text, contains('10 reps'));
        });

        test('should show ? when reps are missing', () {
          final set = ExerciseSet(
            setNumber: 1,
            weight: 60.0,
          );

          final text = set.getDisplayText(ExerciseCountingMode.weighted);

          expect(text, contains('60.0 kg'));
          expect(text, contains('?'));
        });

        test('should format decimal weights correctly', () {
          final set = ExerciseSet(
            setNumber: 1,
            weight: 62.5,
            reps: 8,
          );

          final text = set.getDisplayText(ExerciseCountingMode.weighted);

          expect(text, '62.5 kg × 8 reps');
        });
      });

      group('Reps Mode', () {
        test('should display only reps', () {
          final set = ExerciseSet(
            setNumber: 1,
            reps: 15,
          );

          final text = set.getDisplayText(ExerciseCountingMode.reps);

          expect(text, '15 reps');
        });

        test('should display actualReps when present', () {
          final set = ExerciseSet(
            setNumber: 1,
            reps: 20,
            actualReps: 18,
          );

          final text = set.getDisplayText(ExerciseCountingMode.reps);

          expect(text, '18 reps');
        });

        test('should show ? when reps are missing', () {
          final set = ExerciseSet(
            setNumber: 1,
          );

          final text = set.getDisplayText(ExerciseCountingMode.reps);

          expect(text, '? reps');
        });

        test('should not show weight even if present', () {
          final set = ExerciseSet(
            setNumber: 1,
            reps: 15,
            weight: 10.0, // Should be ignored
          );

          final text = set.getDisplayText(ExerciseCountingMode.reps);

          expect(text, '15 reps');
          expect(text, isNot(contains('kg')));
        });
      });

      group('Time Mode', () {
        test('should display seconds only (< 1 minute)', () {
          final set = ExerciseSet(
            setNumber: 1,
            seconds: 45,
          );

          final text = set.getDisplayText(ExerciseCountingMode.time);

          expect(text, '45s');
        });

        test('should display minutes and seconds (>= 1 minute)', () {
          final set = ExerciseSet(
            setNumber: 1,
            seconds: 90,
          );

          final text = set.getDisplayText(ExerciseCountingMode.time);

          expect(text, '1m 30s');
        });

        test('should display exact minutes', () {
          final set = ExerciseSet(
            setNumber: 1,
            seconds: 120,
          );

          final text = set.getDisplayText(ExerciseCountingMode.time);

          expect(text, '2m 0s');
        });

        test('should display multiple minutes correctly', () {
          final set = ExerciseSet(
            setNumber: 1,
            seconds: 185, // 3m 5s
          );

          final text = set.getDisplayText(ExerciseCountingMode.time);

          expect(text, '3m 5s');
        });

        test('should display 0s when seconds are missing', () {
          final set = ExerciseSet(
            setNumber: 1,
          );

          final text = set.getDisplayText(ExerciseCountingMode.time);

          expect(text, '0s');
        });

        test('should not show weight or reps even if present', () {
          final set = ExerciseSet(
            setNumber: 1,
            seconds: 60,
            weight: 10.0, // Should be ignored
            reps: 5, // Should be ignored
          );

          final text = set.getDisplayText(ExerciseCountingMode.time);

          expect(text, '1m 0s');
          expect(text, isNot(contains('kg')));
          expect(text, isNot(contains('reps')));
        });
      });
    });

    group('Edge Cases', () {
      test('should handle negative values gracefully (invalid)', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: -10.0,
          reps: -5,
        );

        expect(set.isValid(ExerciseCountingMode.weighted), false);
      });

      test('should handle very large weights', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: 500.0,
          reps: 1,
        );

        expect(set.isValid(ExerciseCountingMode.weighted), true);
        final text = set.getDisplayText(ExerciseCountingMode.weighted);
        expect(text, '500.0 kg × 1 reps');
      });

      test('should handle very large rep counts', () {
        final set = ExerciseSet(
          setNumber: 1,
          reps: 100,
        );

        expect(set.isValid(ExerciseCountingMode.reps), true);
        final text = set.getDisplayText(ExerciseCountingMode.reps);
        expect(text, '100 reps');
      });

      test('should handle very long time durations', () {
        final set = ExerciseSet(
          setNumber: 1,
          seconds: 600, // 10 minutes
        );

        expect(set.isValid(ExerciseCountingMode.time), true);
        final text = set.getDisplayText(ExerciseCountingMode.time);
        expect(text, '10m 0s');
      });
    });

    group('Validation with Different Modes', () {
      test('weighted set should be invalid for reps mode if weight present', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: 60.0,
          reps: 10,
        );

        // Valid for weighted mode
        expect(set.isValid(ExerciseCountingMode.weighted), true);

        // Also valid for reps mode (reps are present)
        expect(set.isValid(ExerciseCountingMode.reps), true);

        // Invalid for time mode (no seconds)
        expect(set.isValid(ExerciseCountingMode.time), false);
      });

      test('reps set should be invalid for weighted mode', () {
        final set = ExerciseSet(
          setNumber: 1,
          reps: 15,
        );

        // Invalid for weighted mode (no weight)
        expect(set.isValid(ExerciseCountingMode.weighted), false);

        // Valid for reps mode
        expect(set.isValid(ExerciseCountingMode.reps), true);

        // Invalid for time mode (no seconds)
        expect(set.isValid(ExerciseCountingMode.time), false);
      });

      test('time set should be invalid for weighted and reps modes', () {
        final set = ExerciseSet(
          setNumber: 1,
          seconds: 60,
        );

        // Invalid for weighted mode (no weight/reps)
        expect(set.isValid(ExerciseCountingMode.weighted), false);

        // Invalid for reps mode (no reps)
        expect(set.isValid(ExerciseCountingMode.reps), false);

        // Valid for time mode
        expect(set.isValid(ExerciseCountingMode.time), true);
      });
    });
  });
}
