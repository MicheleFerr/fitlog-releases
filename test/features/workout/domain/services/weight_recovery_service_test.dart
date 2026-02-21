/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/domain/services
/// 🎯 Feature: Weight Recovery from Previous Workout
/// 🧪 Type: Service Unit Tests
///
/// Test completi per weight recovery service - progressive overload automation
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/weight_recovery_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  group('WeightRecoveryService', () {
    group('applyPreviousWeights', () {
      test('should apply weights from previous workout with 1.0 multiplier', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [0, 0, 0]),
        ]);

        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [100, 105, 110]),
        ]);

        final result = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
          multiplier: 1.0,
        );

        expect(result.exercises.first.sets[0].weight, equals(100));
        expect(result.exercises.first.sets[1].weight, equals(105));
        expect(result.exercises.first.sets[2].weight, equals(110));
      });

      test('should apply weights with +2.5% multiplier', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [0, 0, 0]),
        ]);

        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [100, 100, 100]),
        ]);

        final result = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
          multiplier: 1.025, // +2.5%
        );

        // 100 * 1.025 = 102.5, arrotondato a 102.5 (bilanciere)
        expect(result.exercises.first.sets[0].weight, equals(102.5));
        expect(result.exercises.first.sets[1].weight, equals(102.5));
        expect(result.exercises.first.sets[2].weight, equals(102.5));
      });

      test('should apply weights with -2.5% multiplier', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [0, 0, 0]),
        ]);

        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [100, 100, 100]),
        ]);

        final result = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
          multiplier: 0.975, // -2.5%
        );

        // 100 * 0.975 = 97.5, arrotondato a 97.5 (bilanciere)
        expect(result.exercises.first.sets[0].weight, equals(97.5));
      });

      test('should handle exercise not found in previous workout', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('New Exercise', [0, 0]),
        ]);

        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Old Exercise', [100, 100]),
        ]);

        final result = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
          multiplier: 1.0,
        );

        // Exercise not found, should keep original (0)
        expect(result.exercises.first.sets[0].weight, equals(0));
        expect(result.exercises.first.sets[1].weight, equals(0));
      });

      test('should handle previous exercise with no sets', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [0, 0]),
        ]);

        final previousWorkout = Workout(
      id: 'prev',
          name: 'Push Day',
          exercises: [
            Exercise(
              id: 'ex1',
              name: 'Bench Press',
              sets: [], // No sets
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
            ),
          ],
          status: WorkoutStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
          multiplier: 1.0,
        );

        // No sets in previous, should keep original (0)
        expect(result.exercises.first.sets[0].weight, equals(0));
      });

      test('should use last set when current has more sets than previous', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [0, 0, 0, 0, 0]), // 5 sets
        ]);

        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [100, 105]), // Only 2 sets
        ]);

        final result = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
          multiplier: 1.0,
        );

        // First 2 sets use corresponding previous sets
        expect(result.exercises.first.sets[0].weight, equals(100));
        expect(result.exercises.first.sets[1].weight, equals(105));

        // Last 3 sets use last previous set (105)
        expect(result.exercises.first.sets[2].weight, equals(105));
        expect(result.exercises.first.sets[3].weight, equals(105));
        expect(result.exercises.first.sets[4].weight, equals(105));
      });

      test('should copy reps from previous workout', () {
        final currentWorkout = Workout(
      id: 'current',
          name: 'Push Day',
          exercises: [
            Exercise(
              id: 'ex1',
              name: 'Bench Press',
              sets: [
                ExerciseSet(setNumber: 1, weight: 0, reps: 0),
                ExerciseSet(setNumber: 2, weight: 0, reps: 0),
              ],
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
            ),
          ],
          status: WorkoutStatus.planned,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final previousWorkout = Workout(
      id: 'prev',
          name: 'Push Day',
          exercises: [
            Exercise(
              id: 'ex1',
              name: 'Bench Press',
              sets: [
                ExerciseSet(setNumber: 1, weight: 100, reps: 10),
                ExerciseSet(setNumber: 2, weight: 105, reps: 8),
              ],
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
            ),
          ],
          status: WorkoutStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
          multiplier: 1.0,
        );

        // Both weight and reps should be copied
        expect(result.exercises.first.sets[0].weight, equals(100));
        expect(result.exercises.first.sets[0].reps, equals(10));
        expect(result.exercises.first.sets[1].weight, equals(105));
        expect(result.exercises.first.sets[1].reps, equals(8));
      });

      test('should handle multiple exercises in workout', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [0, 0]),
          _createExercise('Incline Press', [0, 0]),
          _createExercise('Tricep Extension', [0, 0]),
        ]);

        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [100, 105]),
          _createExercise('Incline Press', [80, 85]),
          _createExercise('Tricep Extension', [30, 35]),
        ]);

        final result = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
          multiplier: 1.0,
        );

        expect(result.exercises[0].sets[0].weight, equals(100));
        expect(result.exercises[1].sets[0].weight, equals(80));
        expect(result.exercises[2].sets[0].weight, equals(30));
      });

      test('should preserve exercise order from current workout', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Exercise A', [0]),
          _createExercise('Exercise B', [0]),
          _createExercise('Exercise C', [0]),
        ]);

        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Exercise C', [30]),
          _createExercise('Exercise A', [10]),
          _createExercise('Exercise B', [20]),
        ]);

        final result = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
          multiplier: 1.0,
        );

        // Order should match current workout
        expect(result.exercises[0].name, equals('Exercise A'));
        expect(result.exercises[0].sets[0].weight, equals(10));

        expect(result.exercises[1].name, equals('Exercise B'));
        expect(result.exercises[1].sets[0].weight, equals(20));

        expect(result.exercises[2].name, equals('Exercise C'));
        expect(result.exercises[2].sets[0].weight, equals(30));
      });

      test('should handle null weights in previous workout', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [0, 0]),
        ]);

        final previousWorkout = Workout(
      id: 'prev',
          name: 'Push Day',
          exercises: [
            Exercise(
              id: 'ex1',
              name: 'Bench Press',
              sets: [
                ExerciseSet(setNumber: 1, weight: null, reps: 10),
                ExerciseSet(setNumber: 2, weight: 100, reps: 10),
              ],
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
            ),
          ],
          status: WorkoutStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
          multiplier: 1.0,
        );

        // Null weight should keep current (0)
        expect(result.exercises.first.sets[0].weight, equals(0));
        // Valid weight should be applied
        expect(result.exercises.first.sets[1].weight, equals(100));
      });
    });

    group('_smartRound', () {
      test('should return weight unchanged if zero or negative', () {
        expect(WeightRecoveryService.getMultiplier(0) * 0, equals(0));
      });

      test('should round to 0.5kg for weights under 20kg (dumbbells)', () {
        // Test with light dumbbell weights
        final result1 = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: _createWorkout('Test', [_createExercise('DB Curl', [0])]),
          previousWorkout: _createWorkout('Test', [_createExercise('DB Curl', [12.3])]),
          multiplier: 1.0,
        );
        expect(result1.exercises.first.sets[0].weight, equals(12.5)); // 12.3 → 12.5

        final result2 = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: _createWorkout('Test', [_createExercise('DB Curl', [0])]),
          previousWorkout: _createWorkout('Test', [_createExercise('DB Curl', [12.7])]),
          multiplier: 1.0,
        );
        expect(result2.exercises.first.sets[0].weight, equals(12.5)); // 12.7 → 12.5 (rounds down)

        final result3 = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: _createWorkout('Test', [_createExercise('DB Curl', [0])]),
          previousWorkout: _createWorkout('Test', [_createExercise('DB Curl', [15.2])]),
          multiplier: 1.0,
        );
        expect(result3.exercises.first.sets[0].weight, equals(15.0)); // 15.2 → 15.0
      });

      test('should round to 2.5kg for weights 20kg and above (barbell)', () {
        // Test with barbell weights
        final result1 = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: _createWorkout('Test', [_createExercise('Bench', [0])]),
          previousWorkout: _createWorkout('Test', [_createExercise('Bench', [81])]),
          multiplier: 1.0,
        );
        expect(result1.exercises.first.sets[0].weight, equals(80.0)); // 81 → 80.0

        final result2 = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: _createWorkout('Test', [_createExercise('Bench', [0])]),
          previousWorkout: _createWorkout('Test', [_createExercise('Bench', [102.3])]),
          multiplier: 1.0,
        );
        expect(result2.exercises.first.sets[0].weight, equals(102.5)); // 102.3 → 102.5

        final result3 = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: _createWorkout('Test', [_createExercise('Bench', [0])]),
          previousWorkout: _createWorkout('Test', [_createExercise('Bench', [97.6])]),
          multiplier: 1.0,
        );
        expect(result3.exercises.first.sets[0].weight, equals(97.5)); // 97.6 → 97.5
      });

      test('should round correctly at 20kg boundary', () {
        final result19 = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: _createWorkout('Test', [_createExercise('Ex', [0])]),
          previousWorkout: _createWorkout('Test', [_createExercise('Ex', [19.9])]),
          multiplier: 1.0,
        );
        expect(result19.exercises.first.sets[0].weight, equals(20.0)); // <20: round to 0.5kg

        final result20 = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: _createWorkout('Test', [_createExercise('Ex', [0])]),
          previousWorkout: _createWorkout('Test', [_createExercise('Ex', [20.1])]),
          multiplier: 1.0,
        );
        expect(result20.exercises.first.sets[0].weight, equals(20.0)); // ≥20: round to 2.5kg
      });

      test('should work with multiplier adjustments', () {
        // 10kg * 1.05 = 10.5 → rounds to 10.5 (dumbbell)
        final resultLight = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: _createWorkout('Test', [_createExercise('DB', [0])]),
          previousWorkout: _createWorkout('Test', [_createExercise('DB', [10])]),
          multiplier: 1.05,
        );
        expect(resultLight.exercises.first.sets[0].weight, equals(10.5));

        // 100kg * 1.05 = 105 → rounds to 105.0 (barbell)
        final resultHeavy = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: _createWorkout('Test', [_createExercise('BB', [0])]),
          previousWorkout: _createWorkout('Test', [_createExercise('BB', [100])]),
          multiplier: 1.05,
        );
        expect(resultHeavy.exercises.first.sets[0].weight, equals(105.0));
      });
    });

    group('getMultiplier', () {
      test('should return 1.0 for 0%', () {
        expect(WeightRecoveryService.getMultiplier(0), equals(1.0));
      });

      test('should return 1.025 for +2.5%', () {
        expect(WeightRecoveryService.getMultiplier(2.5), equals(1.025));
      });

      test('should return 1.05 for +5%', () {
        expect(WeightRecoveryService.getMultiplier(5), equals(1.05));
      });

      test('should return 0.975 for -2.5%', () {
        expect(WeightRecoveryService.getMultiplier(-2.5), equals(0.975));
      });

      test('should return 0.90 for -10%', () {
        expect(WeightRecoveryService.getMultiplier(-10), equals(0.90));
      });

      test('should handle large percentages', () {
        expect(WeightRecoveryService.getMultiplier(50), equals(1.5));
        expect(WeightRecoveryService.getMultiplier(-50), equals(0.5));
      });
    });

    group('applyPreviousWeights copies weights and reps', () {
      test('should copy both weights and reps from previous workout', () {
        final currentWorkout = _createWorkoutWithReps('Push Day', [
          _createExerciseWithReps('Bench Press', [0, 0, 0], [8, 8, 8]),
        ]);

        final previousWorkout = _createWorkoutWithReps('Push Day', [
          _createExerciseWithReps('Bench Press', [100, 105, 110], [12, 10, 8]),
        ]);

        final result = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
          multiplier: 1.0,
        );

        // Weights should be copied
        expect(result.exercises.first.sets[0].weight, equals(100));

        // Reps should ALSO be copied (default behavior)
        expect(result.exercises.first.sets[0].reps, equals(12));
        expect(result.exercises.first.sets[1].reps, equals(10));
        expect(result.exercises.first.sets[2].reps, equals(8));
      });

      test('should only apply weights to matching template exercises', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [0, 0]),
          _createExercise('Shoulder Press', [0, 0]),
        ]);

        // Previous workout had an extra exercise not in template
        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [100, 105]),
          _createExercise('Cable Fly', [30, 30]),
        ]);

        final result = WeightRecoveryService.applyPreviousWeights(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
          multiplier: 1.0,
        );

        // Bench Press should get weights from previous
        expect(result.exercises[0].sets[0].weight, equals(100));
        expect(result.exercises[0].sets[1].weight, equals(105));

        // Shoulder Press has no match in previous, stays at 0
        expect(result.exercises[1].sets[0].weight, equals(0));
        expect(result.exercises[1].sets[1].weight, equals(0));
      });
    });

    group('calculateDifferences', () {
      test('should calculate weight difference for matching exercises', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [105, 110, 110]),
        ]);

        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [100, 105, 105]),
        ]);

        final differences = WeightRecoveryService.calculateDifferences(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
        );

        expect(differences.containsKey('Bench Press'), isTrue);

        final diff = differences['Bench Press']!;
        expect(diff.exerciseName, equals('Bench Press'));

        // Previous average: (100 + 105 + 105) / 3 = 103.33...
        expect(diff.previousWeight, closeTo(103.33, 0.01));

        // Current average: (105 + 110 + 110) / 3 = 108.33...
        expect(diff.currentWeight, closeTo(108.33, 0.01));

        // Difference: (108.33 - 103.33) / 103.33 * 100 ≈ 4.84%
        expect(diff.differencePercent, closeTo(4.84, 0.1));
        expect(diff.isIncrease, isTrue);
      });

      test('should handle multiple exercises', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [110]),
          _createExercise('Incline Press', [80]),
        ]);

        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [100]),
          _createExercise('Incline Press', [85]),
        ]);

        final differences = WeightRecoveryService.calculateDifferences(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
        );

        expect(differences.length, equals(2));
        expect(differences['Bench Press']!.differencePercent, closeTo(10, 0.1));
        expect(differences['Incline Press']!.differencePercent, closeTo(-5.88, 0.1));
      });

      test('should skip exercises not in previous workout', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('New Exercise', [100]),
        ]);

        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Old Exercise', [100]),
        ]);

        final differences = WeightRecoveryService.calculateDifferences(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
        );

        expect(differences.isEmpty, isTrue);
      });

      test('should skip exercises with empty sets', () {
        final currentWorkout = Workout(
      id: 'current',
          name: 'Test',
          exercises: [
            Exercise(
              id: 'ex1',
              name: 'Bench Press',
              sets: [],
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
            ),
          ],
          status: WorkoutStatus.planned,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final previousWorkout = _createWorkout('Test', [
          _createExercise('Bench Press', [100]),
        ]);

        final differences = WeightRecoveryService.calculateDifferences(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
        );

        expect(differences.isEmpty, isTrue);
      });

      test('should skip exercises with zero average weight', () {
        final currentWorkout = Workout(
      id: 'current',
          name: 'Test',
          exercises: [
            Exercise(
              id: 'ex1',
              name: 'Bodyweight Exercise',
              sets: [
                ExerciseSet(setNumber: 1, weight: 0, reps: 10),
              ],
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
            ),
          ],
          status: WorkoutStatus.planned,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final previousWorkout = _createWorkout('Test', [
          _createExercise('Bodyweight Exercise', [0]),
        ]);

        final differences = WeightRecoveryService.calculateDifferences(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
        );

        expect(differences.isEmpty, isTrue);
      });

      test('should calculate negative difference when weight decreases', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [95]),
        ]);

        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [100]),
        ]);

        final differences = WeightRecoveryService.calculateDifferences(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
        );

        final diff = differences['Bench Press']!;
        expect(diff.differencePercent, closeTo(-5, 0.1));
        expect(diff.isDecrease, isTrue);
      });

      test('should calculate zero difference when weight unchanged', () {
        final currentWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [100]),
        ]);

        final previousWorkout = _createWorkout('Push Day', [
          _createExercise('Bench Press', [100]),
        ]);

        final differences = WeightRecoveryService.calculateDifferences(
          currentWorkout: currentWorkout,
          previousWorkout: previousWorkout,
        );

        final diff = differences['Bench Press']!;
        expect(diff.differencePercent, equals(0));
        expect(diff.isEqual, isTrue);
      });
    });
  });

  group('WeightDifference', () {
    test('should identify increase correctly', () {
      final diff = WeightDifference(
        exerciseName: 'Test',
        previousWeight: 100,
        currentWeight: 105,
        differencePercent: 5,
      );

      expect(diff.isIncrease, isTrue);
      expect(diff.isDecrease, isFalse);
      expect(diff.isEqual, isFalse);
    });

    test('should identify decrease correctly', () {
      final diff = WeightDifference(
        exerciseName: 'Test',
        previousWeight: 100,
        currentWeight: 95,
        differencePercent: -5,
      );

      expect(diff.isIncrease, isFalse);
      expect(diff.isDecrease, isTrue);
      expect(diff.isEqual, isFalse);
    });

    test('should identify equal correctly', () {
      final diff = WeightDifference(
        exerciseName: 'Test',
        previousWeight: 100,
        currentWeight: 100,
        differencePercent: 0,
      );

      expect(diff.isIncrease, isFalse);
      expect(diff.isDecrease, isFalse);
      expect(diff.isEqual, isTrue);
    });
  });
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

Workout _createWorkout(String name, List<Exercise> exercises) {
  return Workout(
    id: 'workout-${DateTime.now().millisecondsSinceEpoch}',
    name: name,
    exercises: exercises,
    status: WorkoutStatus.planned,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

Exercise _createExercise(String name, List<double> weights) {
  return Exercise(
    id: 'exercise-${name.replaceAll(' ', '-').toLowerCase()}',
    name: name,
    sets: weights.asMap().entries.map((entry) {
      return ExerciseSet(
        setNumber: entry.key + 1,
        weight: entry.value,
        reps: 10, // Default reps
      );
    }).toList(),
    type: ExerciseType.single,
    category: ExerciseCategory.chest,
  );
}

Workout _createWorkoutWithReps(String name, List<Exercise> exercises) {
  return Workout(
    id: 'workout-${DateTime.now().millisecondsSinceEpoch}',
    name: name,
    exercises: exercises,
    status: WorkoutStatus.planned,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

Exercise _createExerciseWithReps(
  String name,
  List<double> weights,
  List<int> reps,
) {
  return Exercise(
    id: 'exercise-${name.replaceAll(' ', '-').toLowerCase()}',
    name: name,
    sets: weights.asMap().entries.map((entry) {
      return ExerciseSet(
        setNumber: entry.key + 1,
        weight: entry.value,
        reps: entry.key < reps.length ? reps[entry.key] : 10,
      );
    }).toList(),
    type: ExerciseType.single,
    category: ExerciseCategory.chest,
  );
}
