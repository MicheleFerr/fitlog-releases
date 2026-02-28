import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_time_calculator.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';

// ---------------------------------------------------------------------------
// Test helpers - build minimal Workout/Exercise objects
// ---------------------------------------------------------------------------

Exercise _makeExercise(
  String name,
  int setCount, {
  int? restTime,
  ExerciseCategory category = ExerciseCategory.chest,
}) {
  return Exercise(
    id: name,
    name: name,
    type: ExerciseType.single,
    category: category,
    sets: List.generate(
      setCount,
      (i) => ExerciseSet(setNumber: i + 1, reps: 10, weight: 50),
    ),
    restTime: restTime,
  );
}

SupersetExercise _makeSupersetExercise({
  required int roundCount,
  required int exerciseCount,
  int? restTime,
}) {
  final exercises = List.generate(
    exerciseCount,
    (i) => Exercise(
      id: 'ss_ex_$i',
      name: 'Superset Exercise $i',
      type: ExerciseType.single,
      category: ExerciseCategory.chest,
      sets: [],
    ),
  );

  final supersetSets = List.generate(roundCount, (i) {
    final exerciseData = <String, SupersetExerciseData>{};
    for (final ex in exercises) {
      exerciseData[ex.id] = SupersetExerciseData(
        exerciseId: ex.id,
        exerciseName: ex.name,
        isCompleted: false,
      );
    }
    return SupersetSet(
      id: 'ss_set_$i',
      setNumber: i + 1,
      exerciseData: exerciseData,
    );
  });

  return SupersetExercise(
    id: 'superset_1',
    name: 'Superset',
    exercises: exercises,
    supersetSets: supersetSets,
    restTime: restTime,
  );
}

Workout _makeWorkout({
  List<Exercise> exercises = const [],
  Duration? duration,
}) {
  final now = DateTime(2026, 1, 15, 10, 0);
  return Workout(
    id: 'test_workout',
    name: 'Test Workout',
    exercises: exercises,
    createdAt: now,
    updatedAt: now,
    startTime: now,
    endTime: duration != null ? now.add(duration) : null,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('WorkoutTimeCalculator', () {
    // =========================================================================
    // calculateTotalRestTime
    // =========================================================================
    group('calculateTotalRestTime', () {
      test('empty workout returns zero', () {
        final workout = _makeWorkout();
        final rest = WorkoutTimeCalculator.calculateTotalRestTime(workout);
        expect(rest, Duration.zero);
      });

      test('single exercise with 1 set returns zero rest', () {
        final workout = _makeWorkout(
          exercises: [_makeExercise('Bench Press', 1, restTime: 90)],
        );
        final rest = WorkoutTimeCalculator.calculateTotalRestTime(workout);
        expect(rest, Duration.zero);
      });

      test('single exercise with 4 sets and 90s rest', () {
        // 4 sets -> 3 rest periods of 90s = 270s
        final workout = _makeWorkout(
          exercises: [_makeExercise('Bench Press', 4, restTime: 90)],
        );
        final rest = WorkoutTimeCalculator.calculateTotalRestTime(workout);
        expect(rest, const Duration(seconds: 270));
      });

      test('uses default 60s rest when restTime is null', () {
        // 3 sets -> 2 rest periods of 60s = 120s
        final workout = _makeWorkout(
          exercises: [_makeExercise('Bench Press', 3)],
        );
        final rest = WorkoutTimeCalculator.calculateTotalRestTime(workout);
        expect(rest, const Duration(seconds: 120));
      });

      test('multiple exercises sum rest times', () {
        // Exercise 1: 4 sets, 90s rest -> 3 * 90 = 270s
        // Exercise 2: 3 sets, 60s rest -> 2 * 60 = 120s
        final workout = _makeWorkout(
          exercises: [
            _makeExercise('Bench Press', 4, restTime: 90),
            _makeExercise('Flyes', 3, restTime: 60),
          ],
        );
        final rest = WorkoutTimeCalculator.calculateTotalRestTime(workout);
        expect(rest, const Duration(seconds: 390));
      });

      test('superset exercise uses roundCount for rest', () {
        // 3 rounds with 60s rest -> 2 rest periods = 120s
        final superset = _makeSupersetExercise(
          roundCount: 3,
          exerciseCount: 2,
          restTime: 60,
        );
        final workout = _makeWorkout(exercises: [superset]);
        final rest = WorkoutTimeCalculator.calculateTotalRestTime(workout);
        expect(rest, const Duration(seconds: 120));
      });

      test('superset with 1 round has no rest', () {
        final superset = _makeSupersetExercise(
          roundCount: 1,
          exerciseCount: 2,
          restTime: 90,
        );
        final workout = _makeWorkout(exercises: [superset]);
        final rest = WorkoutTimeCalculator.calculateTotalRestTime(workout);
        expect(rest, Duration.zero);
      });

      test('mixed exercises and supersets', () {
        // Normal: 3 sets, 90s rest -> 2 * 90 = 180s
        // Superset: 4 rounds, default 60s rest -> 3 * 60 = 180s
        final workout = _makeWorkout(
          exercises: [
            _makeExercise('Bench Press', 3, restTime: 90),
            _makeSupersetExercise(
              roundCount: 4,
              exerciseCount: 2,
            ),
          ],
        );
        final rest = WorkoutTimeCalculator.calculateTotalRestTime(workout);
        expect(rest, const Duration(seconds: 360));
      });
    });

    // =========================================================================
    // calculateTotalSets
    // =========================================================================
    group('calculateTotalSets', () {
      test('empty workout returns 0', () {
        final workout = _makeWorkout();
        expect(WorkoutTimeCalculator.calculateTotalSets(workout), 0);
      });

      test('single exercise counts sets', () {
        final workout = _makeWorkout(
          exercises: [_makeExercise('Bench Press', 4)],
        );
        expect(WorkoutTimeCalculator.calculateTotalSets(workout), 4);
      });

      test('multiple exercises sum sets', () {
        final workout = _makeWorkout(
          exercises: [
            _makeExercise('Bench Press', 4),
            _makeExercise('Flyes', 3),
          ],
        );
        expect(WorkoutTimeCalculator.calculateTotalSets(workout), 7);
      });

      test('superset counts rounds * exercises', () {
        // 3 rounds, 2 exercises = 6 total sets
        final superset = _makeSupersetExercise(
          roundCount: 3,
          exerciseCount: 2,
        );
        final workout = _makeWorkout(exercises: [superset]);
        expect(WorkoutTimeCalculator.calculateTotalSets(workout), 6);
      });

      test('mixed normal and superset exercises', () {
        // Normal: 4 sets
        // Superset: 3 rounds * 3 exercises = 9
        // Total: 13
        final workout = _makeWorkout(
          exercises: [
            _makeExercise('Bench Press', 4),
            _makeSupersetExercise(roundCount: 3, exerciseCount: 3),
          ],
        );
        expect(WorkoutTimeCalculator.calculateTotalSets(workout), 13);
      });
    });

    // =========================================================================
    // calculateSuggestedDuration
    // =========================================================================
    group('calculateSuggestedDuration', () {
      test('empty workout returns zero', () {
        final workout = _makeWorkout();
        final suggested = WorkoutTimeCalculator.calculateSuggestedDuration(
          workout,
        );
        expect(suggested, Duration.zero);
      });

      test('calculates rest + 2min per set', () {
        // 4 sets, 90s rest -> 3*90=270s rest
        // 4 sets * 2min = 480s execution
        // Total: 270 + 480 = 750s
        final workout = _makeWorkout(
          exercises: [_makeExercise('Bench Press', 4, restTime: 90)],
        );
        final suggested = WorkoutTimeCalculator.calculateSuggestedDuration(
          workout,
        );
        expect(suggested, const Duration(seconds: 270 + 480));
      });

      test('accounts for multiple exercises', () {
        // Ex1: 4 sets, 90s -> 3*90=270s rest, 4*120=480s exec
        // Ex2: 3 sets, 60s -> 2*60=120s rest, 3*120=360s exec
        // Total: 270+120 + 480+360 = 1230s
        final workout = _makeWorkout(
          exercises: [
            _makeExercise('Bench Press', 4, restTime: 90),
            _makeExercise('Flyes', 3, restTime: 60),
          ],
        );
        final suggested = WorkoutTimeCalculator.calculateSuggestedDuration(
          workout,
        );
        expect(suggested, const Duration(seconds: 1230));
      });
    });

    // =========================================================================
    // isWorkoutDurationSuspicious
    // =========================================================================
    group('isWorkoutDurationSuspicious', () {
      test('returns false when no actual duration', () {
        // No endTime -> duration is null
        final workout = Workout(
          id: 'test',
          name: 'Test',
          exercises: [_makeExercise('Bench Press', 4, restTime: 90)],
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          startTime: null,
        );
        expect(
          WorkoutTimeCalculator.isWorkoutDurationSuspicious(workout),
          isFalse,
        );
      });

      test('returns false when rest time is zero (all single sets)', () {
        final workout = _makeWorkout(
          exercises: [_makeExercise('Bench Press', 1)],
          duration: const Duration(minutes: 1),
        );
        expect(
          WorkoutTimeCalculator.isWorkoutDurationSuspicious(workout),
          isFalse,
        );
      });

      test('returns false when duration exceeds rest time', () {
        // 4 sets, 90s rest -> 270s rest time
        // Duration: 10 minutes = 600s > 270s
        final workout = _makeWorkout(
          exercises: [_makeExercise('Bench Press', 4, restTime: 90)],
          duration: const Duration(minutes: 10),
        );
        expect(
          WorkoutTimeCalculator.isWorkoutDurationSuspicious(workout),
          isFalse,
        );
      });

      test('returns true when duration is less than rest time', () {
        // 4 sets, 90s rest -> 270s rest time
        // Duration: 2 minutes = 120s < 270s
        final workout = _makeWorkout(
          exercises: [_makeExercise('Bench Press', 4, restTime: 90)],
          duration: const Duration(minutes: 2),
        );
        expect(
          WorkoutTimeCalculator.isWorkoutDurationSuspicious(workout),
          isTrue,
        );
      });

      test('returns false for empty workout', () {
        final workout = _makeWorkout(duration: const Duration(minutes: 5));
        expect(
          WorkoutTimeCalculator.isWorkoutDurationSuspicious(workout),
          isFalse,
        );
      });
    });

    // =========================================================================
    // getTimeMetrics
    // =========================================================================
    group('getTimeMetrics', () {
      test('returns all metrics for workout with exercises', () {
        final workout = _makeWorkout(
          exercises: [
            _makeExercise('Bench Press', 4, restTime: 90),
            _makeExercise('Flyes', 3, restTime: 60),
          ],
          duration: const Duration(minutes: 30),
        );

        final metrics = WorkoutTimeCalculator.getTimeMetrics(workout);
        expect(metrics.actualDuration, const Duration(minutes: 30));
        expect(metrics.totalRestTime, const Duration(seconds: 390));
        expect(metrics.totalSets, 7);
        expect(metrics.isSuspicious, isFalse);
        expect(
          metrics.suggestedDuration,
          const Duration(seconds: 390 + 7 * 120),
        );
      });

      test('empty workout returns zero metrics', () {
        // No startTime -> duration is null -> actualDuration defaults to zero
        final workout = Workout(
          id: 'test',
          name: 'Test',
          exercises: [],
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        final metrics = WorkoutTimeCalculator.getTimeMetrics(workout);
        expect(metrics.actualDuration, Duration.zero);
        expect(metrics.totalRestTime, Duration.zero);
        expect(metrics.totalSets, 0);
        expect(metrics.suggestedDuration, Duration.zero);
        expect(metrics.isSuspicious, isFalse);
      });

      test('suspicious workout is flagged', () {
        final workout = _makeWorkout(
          exercises: [_makeExercise('Bench Press', 4, restTime: 90)],
          duration: const Duration(seconds: 60),
        );
        final metrics = WorkoutTimeCalculator.getTimeMetrics(workout);
        expect(metrics.isSuspicious, isTrue);
      });
    });
  });

  // ===========================================================================
  // WorkoutTimeMetrics
  // ===========================================================================
  group('WorkoutTimeMetrics', () {
    group('formatDuration', () {
      test('formats hours and minutes', () {
        const metrics = WorkoutTimeMetrics(
          actualDuration: Duration.zero,
          totalRestTime: Duration.zero,
          suggestedDuration: Duration.zero,
          totalSets: 0,
          isSuspicious: false,
        );
        expect(
          metrics.formatDuration(const Duration(hours: 1, minutes: 30)),
          '1h 30m',
        );
      });

      test('formats minutes and seconds for sub-hour durations', () {
        const metrics = WorkoutTimeMetrics(
          actualDuration: Duration.zero,
          totalRestTime: Duration.zero,
          suggestedDuration: Duration.zero,
          totalSets: 0,
          isSuspicious: false,
        );
        expect(
          metrics.formatDuration(const Duration(minutes: 45, seconds: 30)),
          '45m 30s',
        );
      });

      test('formats zero duration', () {
        const metrics = WorkoutTimeMetrics(
          actualDuration: Duration.zero,
          totalRestTime: Duration.zero,
          suggestedDuration: Duration.zero,
          totalSets: 0,
          isSuspicious: false,
        );
        expect(metrics.formatDuration(Duration.zero), '0m 0s');
      });

      test('formats exactly 1 hour', () {
        const metrics = WorkoutTimeMetrics(
          actualDuration: Duration.zero,
          totalRestTime: Duration.zero,
          suggestedDuration: Duration.zero,
          totalSets: 0,
          isSuspicious: false,
        );
        expect(
          metrics.formatDuration(const Duration(hours: 1)),
          '1h 0m',
        );
      });

      test('formats just seconds', () {
        const metrics = WorkoutTimeMetrics(
          actualDuration: Duration.zero,
          totalRestTime: Duration.zero,
          suggestedDuration: Duration.zero,
          totalSets: 0,
          isSuspicious: false,
        );
        expect(
          metrics.formatDuration(const Duration(seconds: 45)),
          '0m 45s',
        );
      });

      test('multiple hours', () {
        const metrics = WorkoutTimeMetrics(
          actualDuration: Duration.zero,
          totalRestTime: Duration.zero,
          suggestedDuration: Duration.zero,
          totalSets: 0,
          isSuspicious: false,
        );
        expect(
          metrics.formatDuration(const Duration(hours: 2, minutes: 15)),
          '2h 15m',
        );
      });
    });

    group('formatted getters', () {
      test('actualDurationFormatted works', () {
        const metrics = WorkoutTimeMetrics(
          actualDuration: Duration(minutes: 30, seconds: 15),
          totalRestTime: Duration.zero,
          suggestedDuration: Duration.zero,
          totalSets: 0,
          isSuspicious: false,
        );
        expect(metrics.actualDurationFormatted, '30m 15s');
      });

      test('totalRestTimeFormatted works', () {
        const metrics = WorkoutTimeMetrics(
          actualDuration: Duration.zero,
          totalRestTime: Duration(minutes: 4, seconds: 30),
          suggestedDuration: Duration.zero,
          totalSets: 0,
          isSuspicious: false,
        );
        expect(metrics.totalRestTimeFormatted, '4m 30s');
      });

      test('suggestedDurationFormatted works', () {
        const metrics = WorkoutTimeMetrics(
          actualDuration: Duration.zero,
          totalRestTime: Duration.zero,
          suggestedDuration: Duration(hours: 1, minutes: 10),
          totalSets: 0,
          isSuspicious: false,
        );
        expect(metrics.suggestedDurationFormatted, '1h 10m');
      });
    });
  });
}
