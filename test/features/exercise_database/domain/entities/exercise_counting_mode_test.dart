import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

void main() {
  group('ExerciseCountingMode', () {
    group('requiresWeight', () {
      test('should be true only for weighted', () {
        expect(ExerciseCountingMode.weighted.requiresWeight, true);
        expect(ExerciseCountingMode.reps.requiresWeight, false);
        expect(ExerciseCountingMode.time.requiresWeight, false);
      });
    });

    group('requiresReps', () {
      test('should be true for weighted and reps', () {
        expect(ExerciseCountingMode.weighted.requiresReps, true);
        expect(ExerciseCountingMode.reps.requiresReps, true);
        expect(ExerciseCountingMode.time.requiresReps, false);
      });
    });

    group('requiresTime', () {
      test('should be true only for time', () {
        expect(ExerciseCountingMode.weighted.requiresTime, false);
        expect(ExerciseCountingMode.reps.requiresTime, false);
        expect(ExerciseCountingMode.time.requiresTime, true);
      });
    });

    group('icon', () {
      test('should return correct icons for each mode', () {
        expect(
          ExerciseCountingMode.weighted.icon,
          Icons.fitness_center,
        );
        expect(
          ExerciseCountingMode.reps.icon,
          Icons.repeat,
        );
        expect(
          ExerciseCountingMode.time.icon,
          Icons.timer,
        );
      });
    });

    group('getColor', () {
      test('should return correct colors for each mode', () {
        const colorScheme = ColorScheme.light();

        expect(
          ExerciseCountingMode.weighted.getColor(colorScheme),
          colorScheme.primary,
        );
        expect(
          ExerciseCountingMode.reps.getColor(colorScheme),
          colorScheme.secondary,
        );
        expect(
          ExerciseCountingMode.time.getColor(colorScheme),
          colorScheme.tertiary,
        );
      });
    });

    group('fromString', () {
      test('should parse valid string values', () {
        expect(
          ExerciseCountingMode.fromString('weighted'),
          ExerciseCountingMode.weighted,
        );
        expect(
          ExerciseCountingMode.fromString('reps'),
          ExerciseCountingMode.reps,
        );
        expect(
          ExerciseCountingMode.fromString('time'),
          ExerciseCountingMode.time,
        );
      });

      test('should default to weighted for null', () {
        expect(
          ExerciseCountingMode.fromString(null),
          ExerciseCountingMode.weighted,
        );
      });

      test('should default to weighted for invalid strings', () {
        expect(
          ExerciseCountingMode.fromString('invalid'),
          ExerciseCountingMode.weighted,
        );
        expect(
          ExerciseCountingMode.fromString(''),
          ExerciseCountingMode.weighted,
        );
      });
    });

    group('toJson', () {
      test('should serialize to string name', () {
        expect(ExerciseCountingMode.weighted.toJson(), 'weighted');
        expect(ExerciseCountingMode.reps.toJson(), 'reps');
        expect(ExerciseCountingMode.time.toJson(), 'time');
      });
    });

    group('serialization round-trip', () {
      test('should serialize and deserialize correctly', () {
        for (final mode in ExerciseCountingMode.values) {
          final json = mode.toJson();
          final deserialized = ExerciseCountingMode.fromString(json);
          expect(deserialized, mode);
        }
      });
    });
  });
}
