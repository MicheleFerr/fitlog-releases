import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Integration tests for Exercise Counting Mode UI flows
///
/// These tests verify the complete user flows for all three counting modes:
/// 1. Weighted exercises (weight + reps) - e.g., Bench Press
/// 2. Bodyweight exercises (reps only) - e.g., Push-ups
/// 3. Time-based exercises (duration) - e.g., Plank
///
/// Each test verifies:
/// - Exercise creation with correct counting mode
/// - Set data validation works correctly
/// - Display formatting is correct
/// - Data integrity is maintained through the workflow
void main() {
  group('Counting Mode UI Flow Integration Tests', () {
    group('Weighted Exercise Flow', () {
      test('Complete weighted exercise flow - add exercise, enter sets, complete', () {
        // 1. Create workout
        var workout = Workout(
          name: 'Weighted Exercise Test',
          status: WorkoutStatus.inProgress,
          startTime: DateTime.now(),
          exercises: [],
        );

        expect(workout.exercises, isEmpty);

        // 2. Add weighted exercise (Bench Press)
        final benchPress = Exercise(
          id: 'bench-1',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.weighted,
          sets: [],
          restTime: 120,
        );

        // Verify counting mode requirements
        expect(benchPress.countingMode, ExerciseCountingMode.weighted);
        expect(benchPress.countingMode.requiresWeight, true);
        expect(benchPress.countingMode.requiresReps, true);
        expect(benchPress.countingMode.requiresTime, false);

        workout = workout.copyWith(exercises: [benchPress]);
        expect(workout.exercises.length, 1);
        expect(workout.exercises.first.name, 'Bench Press');

        // 3. Add first set with weight and reps
        final set1 = ExerciseSet(
          id: 'set-1',
          setNumber: 1,
          weight: 60.0,
          reps: 10,
          isCompleted: false,
        );

        // Validate set
        expect(set1.isValid(ExerciseCountingMode.weighted), true);
        expect(set1.getMissingFields(ExerciseCountingMode.weighted), isEmpty);

        // Update exercise with set
        var updatedBenchPress = benchPress.copyWith(sets: [set1]);
        workout = workout.copyWith(exercises: [updatedBenchPress]);

        expect(workout.exercises.first.sets.length, 1);
        expect(workout.exercises.first.sets.first.weight, 60.0);
        expect(workout.exercises.first.sets.first.reps, 10);

        // 4. Add second set with different weight
        final set2 = ExerciseSet(
          id: 'set-2',
          setNumber: 2,
          weight: 65.0,
          reps: 8,
          isCompleted: false,
        );

        expect(set2.isValid(ExerciseCountingMode.weighted), true);

        updatedBenchPress = updatedBenchPress.copyWith(sets: [set1, set2]);
        workout = workout.copyWith(exercises: [updatedBenchPress]);

        expect(workout.exercises.first.sets.length, 2);

        // 5. Complete sets
        final completedSet1 = set1.copyWith(isCompleted: true);
        final completedSet2 = set2.copyWith(isCompleted: true, reps: 7); // Hit 7 reps instead of 8

        updatedBenchPress = updatedBenchPress.copyWith(
          sets: [completedSet1, completedSet2],
        );
        workout = workout.copyWith(exercises: [updatedBenchPress]);

        expect(workout.exercises.first.sets.every((s) => s.isCompleted), true);

        // 6. Verify display text formatting
        final displayText1 = completedSet1.getDisplayText(ExerciseCountingMode.weighted);
        expect(displayText1, contains('60')); // weight
        expect(displayText1, contains('10')); // reps
        expect(displayText1, contains('kg'));
        expect(displayText1, contains('reps'));

        final displayText2 = completedSet2.getDisplayText(ExerciseCountingMode.weighted);
        expect(displayText2, contains('65'));
        expect(displayText2, contains('7'));

        // 7. Calculate total volume
        double totalVolume = 0;
        for (final set in workout.exercises.first.sets) {
          final weight = set.weight ?? 0;
          final reps = set.reps ?? 0;
          totalVolume += weight * reps;
        }

        // Expected: (60 * 10) + (65 * 7) = 600 + 455 = 1055
        expect(totalVolume, 1055.0);
      });

      test('Weighted exercise - validation catches missing fields', () {
        // Set missing weight
        final setNoWeight = ExerciseSet(
          id: 'set-1',
          setNumber: 1,
          reps: 10,
          // weight missing
        );

        expect(setNoWeight.isValid(ExerciseCountingMode.weighted), false);
        expect(
          setNoWeight.getMissingFields(ExerciseCountingMode.weighted),
          contains('weight'),
        );

        // Set missing reps
        final setNoReps = ExerciseSet(
          id: 'set-2',
          setNumber: 2,
          weight: 60.0,
          // reps missing
        );

        expect(setNoReps.isValid(ExerciseCountingMode.weighted), false);
        expect(
          setNoReps.getMissingFields(ExerciseCountingMode.weighted),
          contains('reps'),
        );

        // Valid set
        final validSet = ExerciseSet(
          id: 'set-3',
          setNumber: 3,
          weight: 60.0,
          reps: 10,
        );

        expect(validSet.isValid(ExerciseCountingMode.weighted), true);
        expect(validSet.getMissingFields(ExerciseCountingMode.weighted), isEmpty);
      });
    });

    group('Bodyweight Exercise Flow (Reps)', () {
      test('Complete bodyweight exercise flow - add exercise, enter reps, complete', () {
        // 1. Create workout
        var workout = Workout(
          name: 'Bodyweight Exercise Test',
          status: WorkoutStatus.inProgress,
          startTime: DateTime.now(),
          exercises: [],
        );

        // 2. Add bodyweight exercise (Push-ups)
        final pushUps = Exercise(
          id: 'pushup-1',
          name: 'Push-ups',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.reps,
          sets: [],
          restTime: 90,
        );

        // Verify counting mode requirements
        expect(pushUps.countingMode, ExerciseCountingMode.reps);
        expect(pushUps.countingMode.requiresWeight, false);
        expect(pushUps.countingMode.requiresReps, true);
        expect(pushUps.countingMode.requiresTime, false);

        workout = workout.copyWith(exercises: [pushUps]);

        // 3. Add first set with reps only (no weight)
        final set1 = ExerciseSet(
          id: 'set-1',
          setNumber: 1,
          reps: 20,
          weight: null, // No weight for bodyweight
          isCompleted: false,
        );

        // Validate set
        expect(set1.isValid(ExerciseCountingMode.reps), true);
        expect(set1.getMissingFields(ExerciseCountingMode.reps), isEmpty);
        expect(set1.weight, isNull);

        // Update exercise with set
        var updatedPushUps = pushUps.copyWith(sets: [set1]);
        workout = workout.copyWith(exercises: [updatedPushUps]);

        expect(workout.exercises.first.sets.length, 1);
        expect(workout.exercises.first.sets.first.reps, 20);
        expect(workout.exercises.first.sets.first.weight, isNull);

        // 4. Add multiple sets
        final set2 = ExerciseSet(id: 'set-2', setNumber: 2, reps: 18);
        final set3 = ExerciseSet(id: 'set-3', setNumber: 3, reps: 15);

        expect(set2.isValid(ExerciseCountingMode.reps), true);
        expect(set3.isValid(ExerciseCountingMode.reps), true);

        updatedPushUps = updatedPushUps.copyWith(sets: [set1, set2, set3]);
        workout = workout.copyWith(exercises: [updatedPushUps]);

        expect(workout.exercises.first.sets.length, 3);

        // 5. Complete sets
        final completedSet1 = set1.copyWith(isCompleted: true);
        final completedSet2 = set2.copyWith(isCompleted: true);
        final completedSet3 = set3.copyWith(isCompleted: true, reps: 12); // Did 12 instead of 15

        updatedPushUps = updatedPushUps.copyWith(
          sets: [completedSet1, completedSet2, completedSet3],
        );
        workout = workout.copyWith(exercises: [updatedPushUps]);

        expect(workout.exercises.first.sets.every((s) => s.isCompleted), true);
        expect(workout.exercises.first.sets.every((s) => s.weight == null), true);

        // 6. Verify display text formatting (reps only, no weight)
        final displayText1 = completedSet1.getDisplayText(ExerciseCountingMode.reps);
        expect(displayText1, contains('20'));
        expect(displayText1, contains('reps'));
        expect(displayText1, isNot(contains('kg')));

        // 7. Calculate total reps
        int totalReps = 0;
        for (final set in workout.exercises.first.sets) {
          totalReps += set.reps ?? 0;
        }

        // Expected: 20 + 18 + 12 = 50
        expect(totalReps, 50);
      });

      test('Bodyweight exercise - validation catches missing reps', () {
        final setNoReps = ExerciseSet(
          id: 'set-1',
          setNumber: 1,
          // reps missing
          weight: null,
        );

        expect(setNoReps.isValid(ExerciseCountingMode.reps), false);
        expect(
          setNoReps.getMissingFields(ExerciseCountingMode.reps),
          contains('reps'),
        );

        // Valid set (weight is optional and should be ignored)
        final validSet = ExerciseSet(
          id: 'set-2',
          setNumber: 2,
          reps: 15,
          weight: null,
        );

        expect(validSet.isValid(ExerciseCountingMode.reps), true);
        expect(validSet.getMissingFields(ExerciseCountingMode.reps), isEmpty);
      });
    });

    group('Time-based Exercise Flow', () {
      test('Complete time-based exercise flow - add exercise, enter duration, complete', () {
        // 1. Create workout
        var workout = Workout(
          name: 'Time-based Exercise Test',
          status: WorkoutStatus.inProgress,
          startTime: DateTime.now(),
          exercises: [],
        );

        // 2. Add time-based exercise (Plank)
        final plank = Exercise(
          id: 'plank-1',
          name: 'Plank',
          type: ExerciseType.single,
          category: ExerciseCategory.abs,
          countingMode: ExerciseCountingMode.time,
          sets: [],
          restTime: 60,
        );

        // Verify counting mode requirements
        expect(plank.countingMode, ExerciseCountingMode.time);
        expect(plank.countingMode.requiresWeight, false);
        expect(plank.countingMode.requiresReps, false);
        expect(plank.countingMode.requiresTime, true);

        workout = workout.copyWith(exercises: [plank]);

        // 3. Add first set with duration (60 seconds)
        final set1 = ExerciseSet(
          id: 'set-1',
          setNumber: 1,
          seconds: 60,
          weight: null,
          reps: null,
          isCompleted: false,
        );

        // Validate set
        expect(set1.isValid(ExerciseCountingMode.time), true);
        expect(set1.getMissingFields(ExerciseCountingMode.time), isEmpty);
        expect(set1.weight, isNull);
        expect(set1.reps, isNull);

        // Update exercise with set
        var updatedPlank = plank.copyWith(sets: [set1]);
        workout = workout.copyWith(exercises: [updatedPlank]);

        expect(workout.exercises.first.sets.length, 1);
        expect(workout.exercises.first.sets.first.seconds, 60);
        expect(workout.exercises.first.sets.first.weight, isNull);
        expect(workout.exercises.first.sets.first.reps, isNull);

        // 4. Add multiple sets with different durations
        final set2 = ExerciseSet(id: 'set-2', setNumber: 2, seconds: 45);
        final set3 = ExerciseSet(id: 'set-3', setNumber: 3, seconds: 90); // 1m 30s

        expect(set2.isValid(ExerciseCountingMode.time), true);
        expect(set3.isValid(ExerciseCountingMode.time), true);

        updatedPlank = updatedPlank.copyWith(sets: [set1, set2, set3]);
        workout = workout.copyWith(exercises: [updatedPlank]);

        expect(workout.exercises.first.sets.length, 3);

        // 5. Complete sets
        final completedSet1 = set1.copyWith(isCompleted: true);
        final completedSet2 = set2.copyWith(isCompleted: true);
        final completedSet3 = set3.copyWith(isCompleted: true, seconds: 75); // Held 75s instead of 90s

        updatedPlank = updatedPlank.copyWith(
          sets: [completedSet1, completedSet2, completedSet3],
        );
        workout = workout.copyWith(exercises: [updatedPlank]);

        expect(workout.exercises.first.sets.every((s) => s.isCompleted), true);
        expect(workout.exercises.first.sets.every((s) => s.weight == null), true);
        expect(workout.exercises.first.sets.every((s) => s.reps == null), true);

        // 6. Verify display text formatting (time only)
        // 60 seconds displays as "1m 0s"
        final displayText1 = completedSet1.getDisplayText(ExerciseCountingMode.time);
        expect(displayText1, contains('1m')); // 60s = 1m 0s
        expect(displayText1, isNot(contains('kg')));
        expect(displayText1, isNot(contains('reps')));

        // For 90 seconds should show "1m 30s"
        final displayText3 = set3.getDisplayText(ExerciseCountingMode.time);
        expect(displayText3, contains('m'));
        expect(displayText3, contains('s'));

        // 7. Calculate total duration
        int totalSeconds = 0;
        for (final set in workout.exercises.first.sets) {
          totalSeconds += set.seconds ?? 0;
        }

        // Expected: 60 + 45 + 75 = 180 seconds (3 minutes)
        expect(totalSeconds, 180);
      });

      test('Time-based exercise - validation catches missing seconds', () {
        final setNoSeconds = ExerciseSet(
          id: 'set-1',
          setNumber: 1,
          // seconds missing
          weight: null,
          reps: null,
        );

        expect(setNoSeconds.isValid(ExerciseCountingMode.time), false);
        expect(
          setNoSeconds.getMissingFields(ExerciseCountingMode.time),
          contains('seconds'),
        );

        // Valid set
        final validSet = ExerciseSet(
          id: 'set-2',
          setNumber: 2,
          seconds: 60,
          weight: null,
          reps: null,
        );

        expect(validSet.isValid(ExerciseCountingMode.time), true);
        expect(validSet.getMissingFields(ExerciseCountingMode.time), isEmpty);
      });

      test('Time-based exercise - smart duration formatting', () {
        // Short duration (< 60s) - show "45s"
        final shortSet = ExerciseSet(
          id: 'set-1',
          setNumber: 1,
          seconds: 45,
        );

        final shortDisplay = shortSet.getDisplayText(ExerciseCountingMode.time);
        expect(shortDisplay, contains('45'));
        expect(shortDisplay, contains('s'));
        expect(shortDisplay, isNot(contains('m')));

        // Medium duration (exactly 60s) - show "1m 0s"
        final mediumSet = ExerciseSet(
          id: 'set-2',
          setNumber: 2,
          seconds: 60,
        );

        final mediumDisplay = mediumSet.getDisplayText(ExerciseCountingMode.time);
        expect(mediumDisplay, contains('1m'));

        // Long duration (90s) - show "1m 30s"
        final longSet = ExerciseSet(
          id: 'set-3',
          setNumber: 3,
          seconds: 90,
        );

        final longDisplay = longSet.getDisplayText(ExerciseCountingMode.time);
        expect(longDisplay, contains('1m'));
        expect(longDisplay, contains('30s'));

        // Very long duration (150s) - show "2m 30s"
        final veryLongSet = ExerciseSet(
          id: 'set-4',
          setNumber: 4,
          seconds: 150,
        );

        final veryLongDisplay = veryLongSet.getDisplayText(ExerciseCountingMode.time);
        expect(veryLongDisplay, contains('2m'));
        expect(veryLongDisplay, contains('30s'));
      });
    });

    group('Mixed Counting Mode Workflow', () {
      test('Workout with all three counting modes', () {
        // 1. Create workout
        var workout = Workout(
          name: 'Mixed Counting Mode Test',
          status: WorkoutStatus.inProgress,
          startTime: DateTime.now(),
          exercises: [],
        );

        // 2. Add weighted exercise
        final benchPress = Exercise(
          id: 'bench-1',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.weighted,
          sets: [
            ExerciseSet(id: 's1', setNumber: 1, weight: 60.0, reps: 10, isCompleted: true),
          ],
        );

        // 3. Add bodyweight exercise
        final pushUps = Exercise(
          id: 'pushup-1',
          name: 'Push-ups',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          countingMode: ExerciseCountingMode.reps,
          sets: [
            ExerciseSet(id: 's2', setNumber: 1, reps: 20, isCompleted: true),
          ],
        );

        // 4. Add time-based exercise
        final plank = Exercise(
          id: 'plank-1',
          name: 'Plank',
          type: ExerciseType.single,
          category: ExerciseCategory.abs,
          countingMode: ExerciseCountingMode.time,
          sets: [
            ExerciseSet(id: 's3', setNumber: 1, seconds: 60, isCompleted: true),
          ],
        );

        // Add all exercises
        workout = workout.copyWith(exercises: [benchPress, pushUps, plank]);

        expect(workout.exercises.length, 3);

        // Verify each exercise has correct counting mode
        expect(workout.exercises[0].countingMode, ExerciseCountingMode.weighted);
        expect(workout.exercises[1].countingMode, ExerciseCountingMode.reps);
        expect(workout.exercises[2].countingMode, ExerciseCountingMode.time);

        // Verify data types
        expect(workout.exercises[0].sets.first.weight, isNotNull);
        expect(workout.exercises[0].sets.first.reps, isNotNull);

        expect(workout.exercises[1].sets.first.weight, isNull);
        expect(workout.exercises[1].sets.first.reps, isNotNull);

        expect(workout.exercises[2].sets.first.weight, isNull);
        expect(workout.exercises[2].sets.first.reps, isNull);
        expect(workout.exercises[2].sets.first.seconds, isNotNull);

        // Verify all sets are valid for their counting mode
        for (var i = 0; i < workout.exercises.length; i++) {
          final exercise = workout.exercises[i];
          for (final set in exercise.sets) {
            expect(set.isValid(exercise.countingMode), true);
            expect(set.getMissingFields(exercise.countingMode), isEmpty);
          }
        }
      });
    });

    group('Counting Mode Persistence', () {
      test('Counting mode survives serialization round-trip', () {
        // Create exercises with all counting modes
        final weightedExercise = Exercise(
          id: 'ex-1',
          name: 'Squat',
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
          countingMode: ExerciseCountingMode.weighted,
          sets: [
            ExerciseSet(id: 's1', setNumber: 1, weight: 100.0, reps: 5),
          ],
        );

        final repsExercise = Exercise(
          id: 'ex-2',
          name: 'Pull-ups',
          type: ExerciseType.single,
          category: ExerciseCategory.back,
          countingMode: ExerciseCountingMode.reps,
          sets: [
            ExerciseSet(id: 's2', setNumber: 1, reps: 10),
          ],
        );

        final timeExercise = Exercise(
          id: 'ex-3',
          name: 'Wall Sit',
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
          countingMode: ExerciseCountingMode.time,
          sets: [
            ExerciseSet(id: 's3', setNumber: 1, seconds: 90),
          ],
        );

        // Serialize
        final json1 = weightedExercise.toJson();
        final json2 = repsExercise.toJson();
        final json3 = timeExercise.toJson();

        expect(json1['countingMode'], 'weighted');
        expect(json2['countingMode'], 'reps');
        expect(json3['countingMode'], 'time');

        // Deserialize
        final deserialized1 = Exercise.fromJson(json1);
        final deserialized2 = Exercise.fromJson(json2);
        final deserialized3 = Exercise.fromJson(json3);

        // Verify counting mode preserved
        expect(deserialized1.countingMode, ExerciseCountingMode.weighted);
        expect(deserialized2.countingMode, ExerciseCountingMode.reps);
        expect(deserialized3.countingMode, ExerciseCountingMode.time);

        // Verify set data preserved
        expect(deserialized1.sets.first.weight, 100.0);
        expect(deserialized1.sets.first.reps, 5);

        expect(deserialized2.sets.first.weight, isNull);
        expect(deserialized2.sets.first.reps, 10);

        expect(deserialized3.sets.first.weight, isNull);
        expect(deserialized3.sets.first.reps, isNull);
        expect(deserialized3.sets.first.seconds, 90);
      });
    });
  });
}
