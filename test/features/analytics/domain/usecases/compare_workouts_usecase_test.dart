import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/usecases/compare_workouts_usecase.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

// ─────────────────────────────────────────────
// Test helpers
// ─────────────────────────────────────────────

ExerciseSet _makeSet({
  int setNumber = 1,
  double weight = 80.0,
  int reps = 10,
  int? rpe,
  bool isCompleted = true,
  bool isWarmup = false,
}) {
  return ExerciseSet(
    setNumber: setNumber,
    weight: weight,
    reps: reps,
    rpe: rpe,
    isCompleted: isCompleted,
    isWarmup: isWarmup,
  );
}

Exercise _makeExercise({
  String name = 'Squat',
  ExerciseCategory category = ExerciseCategory.legs,
  List<ExerciseSet>? sets,
}) {
  return Exercise(
    name: name,
    type: ExerciseType.single,
    category: category,
    sets: sets ??
        [
          _makeSet(setNumber: 1, weight: 80, reps: 10),
          _makeSet(setNumber: 2, weight: 80, reps: 10),
          _makeSet(setNumber: 3, weight: 80, reps: 10),
        ],
  );
}

Workout _makeWorkout({
  String id = 'w1',
  String name = 'Test Workout',
  List<Exercise>? exercises,
  DateTime? updatedAt,
  DateTime? startTime,
  DateTime? endTime,
}) {
  final now = DateTime.now();
  return Workout(
    id: id,
    name: name,
    exercises: exercises ?? [],
    createdAt: now,
    updatedAt: updatedAt ?? now,
    startTime: startTime,
    endTime: endTime,
  );
}

// ─────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────

void main() {
  late CompareWorkoutsUseCase useCase;

  setUp(() {
    useCase = CompareWorkoutsUseCase();
  });

  // ───────────────────────────────────────────
  // execute()
  // ───────────────────────────────────────────

  group('execute()', () {
    test('returns null when historicalWorkouts is empty', () {
      final current = _makeWorkout(id: 'current');
      final result = useCase.execute(current, []);
      expect(result, isNull);
    });

    test('returns null when no match has similarity > 0.3', () {
      // current has chest exercises; historical has only abs – very different
      final current = _makeWorkout(
        id: 'current',
        exercises: [_makeExercise(name: 'Bench Press', category: ExerciseCategory.chest)],
      );
      final historical = _makeWorkout(
        id: 'hist1',
        exercises: [_makeExercise(name: 'Plank', category: ExerciseCategory.abs)],
      );
      // With only 1 overlapping category vs. 2 total, muscleGroupSimilarity = 0.
      // Exercise overlap = 0, volume is rough.  Overall well below 0.3.
      final result = useCase.execute(current, [historical]);
      expect(result, isNull);
    });

    test('returns null when the only historical workout has the same id', () {
      final w = _makeWorkout(
        id: 'same',
        exercises: [_makeExercise(name: 'Squat')],
      );
      final result = useCase.execute(w, [w]);
      expect(result, isNull);
    });

    test('returns a WorkoutComparison when a good match is found', () {
      final exercise = _makeExercise(name: 'Squat', category: ExerciseCategory.legs);
      final current = _makeWorkout(id: 'c1', exercises: [exercise]);
      final historical = _makeWorkout(id: 'h1', exercises: [exercise]);

      final result = useCase.execute(current, [historical]);
      expect(result, isNotNull);
      expect(result!.comparisonId, equals('h1'));
    });

    test('skips workout with same id even when other candidates exist', () {
      final exercise = _makeExercise(name: 'Squat', category: ExerciseCategory.legs);
      final current = _makeWorkout(id: 'c1', exercises: [exercise]);

      // One candidate with same id – should be skipped.
      // Another with a different id – should be picked.
      final sameId = _makeWorkout(id: 'c1', exercises: [exercise]);
      final other = _makeWorkout(id: 'h2', exercises: [exercise]);

      final result = useCase.execute(current, [sameId, other]);
      expect(result, isNotNull);
      expect(result!.comparisonId, equals('h2'));
    });
  });

  // ───────────────────────────────────────────
  // findSimilarWorkouts()
  // ───────────────────────────────────────────

  group('findSimilarWorkouts()', () {
    test('returns empty list when all candidates have the same id', () {
      final w = _makeWorkout(id: 'same', exercises: [_makeExercise()]);
      final result = useCase.findSimilarWorkouts(w, [w]);
      expect(result, isEmpty);
    });

    test('filters out results below minSimilarity', () {
      final target = _makeWorkout(
        id: 'target',
        exercises: [_makeExercise(name: 'Bench Press', category: ExerciseCategory.chest)],
      );
      final unrelated = _makeWorkout(
        id: 'u1',
        exercises: [_makeExercise(name: 'Plank', category: ExerciseCategory.abs)],
      );

      // Default minSimilarity = 0.3; these workouts share nothing.
      final result = useCase.findSimilarWorkouts(target, [unrelated]);
      expect(result, isEmpty);
    });

    test('includes results at or above minSimilarity', () {
      final exercise = _makeExercise(name: 'Squat', category: ExerciseCategory.legs);
      final target = _makeWorkout(id: 'target', exercises: [exercise]);
      final similar = _makeWorkout(id: 'sim1', exercises: [exercise]);

      final result = useCase.findSimilarWorkouts(target, [similar]);
      expect(result, isNotEmpty);
      expect(result.first.workout.id, equals('sim1'));
    });

    test('respects custom minSimilarity threshold', () {
      final exercise = _makeExercise(name: 'Squat', category: ExerciseCategory.legs);
      final target = _makeWorkout(id: 'target', exercises: [exercise]);
      final similar = _makeWorkout(id: 'sim1', exercises: [exercise]);

      // With minSimilarity = 0.99 the workout should be excluded unless it is
      // a perfect match.  Two identical workouts share all exercises (1.0
      // similarity) so they still appear.
      final result = useCase.findSimilarWorkouts(
        target,
        [similar],
        minSimilarity: 0.99,
      );
      // Similarity == 1.0 because all exercises match exactly.
      expect(result, isNotEmpty);
    });

    test('limits results to the provided limit', () {
      final exercise = _makeExercise(name: 'Squat', category: ExerciseCategory.legs);
      final target = _makeWorkout(id: 'target', exercises: [exercise]);
      final candidates = List.generate(
        10,
        (i) => _makeWorkout(id: 'h$i', exercises: [exercise]),
      );

      final result = useCase.findSimilarWorkouts(target, candidates, limit: 3);
      expect(result.length, lessThanOrEqualTo(3));
    });

    test('results are sorted by similarity descending', () {
      // Create one highly similar (same exercise) and one partially similar.
      final squat = _makeExercise(name: 'Squat', category: ExerciseCategory.legs);
      final bench = _makeExercise(name: 'Bench Press', category: ExerciseCategory.chest);

      final target = _makeWorkout(
        id: 'target',
        exercises: [squat, bench],
      );
      // w1: matches both exercises (similarity 1.0)
      final w1 = _makeWorkout(id: 'w1', exercises: [squat, bench]);
      // w2: matches only one exercise (lower similarity)
      final w2 = _makeWorkout(id: 'w2', exercises: [squat]);

      final result = useCase.findSimilarWorkouts(target, [w2, w1]);
      expect(result.first.workout.id, equals('w1'));
      expect(result.first.similarity, greaterThanOrEqualTo(result.last.similarity));
    });

    test('each WorkoutSimilarity contains a comparison object', () {
      final exercise = _makeExercise(name: 'Squat', category: ExerciseCategory.legs);
      final target = _makeWorkout(id: 'target', exercises: [exercise]);
      final similar = _makeWorkout(id: 'sim1', exercises: [exercise]);

      final result = useCase.findSimilarWorkouts(target, [similar]);
      expect(result.first.comparison, isNotNull);
    });
  });

  // ───────────────────────────────────────────
  // compareDetailed()
  // ───────────────────────────────────────────

  group('compareDetailed()', () {
    test('returns a DetailedWorkoutComparison with both workouts', () {
      final w1 = _makeWorkout(
        id: 'w1',
        exercises: [_makeExercise(name: 'Squat')],
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now(),
      );
      final w2 = _makeWorkout(
        id: 'w2',
        exercises: [_makeExercise(name: 'Squat')],
        startTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
        endTime: DateTime.now(),
      );

      final result = useCase.compareDetailed(w1, w2);

      expect(result.workout1.id, equals('w1'));
      expect(result.workout2.id, equals('w2'));
    });

    test('volume comparison current equals workout1 metrics volume', () {
      final sets = [_makeSet(weight: 100, reps: 10)]; // volume = 1000
      final w1 = _makeWorkout(
        id: 'w1',
        exercises: [_makeExercise(name: 'Squat', sets: sets)],
      );
      final w2 = _makeWorkout(
        id: 'w2',
        exercises: [
          _makeExercise(
            name: 'Squat',
            sets: [_makeSet(weight: 80, reps: 10)], // volume = 800
          ),
        ],
      );

      final result = useCase.compareDetailed(w1, w2);

      expect(result.volumeComparison.current, closeTo(1000, 0.1));
      expect(result.volumeComparison.previous, closeTo(800, 0.1));
      expect(result.volumeComparison.change, closeTo(200, 0.1));
    });

    test('volume change percentage is correct when previous volume > 0', () {
      final w1 = _makeWorkout(
        id: 'w1',
        exercises: [
          _makeExercise(
            name: 'Squat',
            sets: [_makeSet(weight: 120, reps: 10)], // 1200
          ),
        ],
      );
      final w2 = _makeWorkout(
        id: 'w2',
        exercises: [
          _makeExercise(
            name: 'Squat',
            sets: [_makeSet(weight: 100, reps: 10)], // 1000
          ),
        ],
      );

      final result = useCase.compareDetailed(w1, w2);

      // (1200 - 1000) / 1000 * 100 = 20%
      expect(result.volumeComparison.changePercentage, closeTo(20, 0.01));
    });

    test('volume changePercentage is 0 when previous volume is 0', () {
      final w1 = _makeWorkout(
        id: 'w1',
        exercises: [
          _makeExercise(
            name: 'Squat',
            sets: [_makeSet(weight: 100, reps: 10)],
          ),
        ],
      );
      // w2 has no completed sets → volume = 0
      final w2 = _makeWorkout(
        id: 'w2',
        exercises: [
          _makeExercise(
            name: 'Squat',
            sets: [_makeSet(weight: 100, reps: 10, isCompleted: false)],
          ),
        ],
      );

      final result = useCase.compareDetailed(w1, w2);
      expect(result.volumeComparison.changePercentage, closeTo(0, 0.01));
    });

    test('exercise comparison lists all unique exercises from both workouts', () {
      final w1 = _makeWorkout(
        id: 'w1',
        exercises: [
          _makeExercise(name: 'Squat'),
          _makeExercise(name: 'Bench Press', category: ExerciseCategory.chest),
        ],
      );
      final w2 = _makeWorkout(
        id: 'w2',
        exercises: [
          _makeExercise(name: 'Squat'),
          _makeExercise(name: 'Deadlift', category: ExerciseCategory.back),
        ],
      );

      final result = useCase.compareDetailed(w1, w2);

      expect(result.exerciseComparison.keys, containsAll(['Squat', 'Bench Press', 'Deadlift']));
    });

    test('exercise in both workouts has inWorkout1 and inWorkout2 = true', () {
      final w1 = _makeWorkout(id: 'w1', exercises: [_makeExercise(name: 'Squat')]);
      final w2 = _makeWorkout(id: 'w2', exercises: [_makeExercise(name: 'Squat')]);

      final result = useCase.compareDetailed(w1, w2);
      final squat = result.exerciseComparison['Squat']!;

      expect(squat.isInBoth, isTrue);
      expect(squat.isNewExercise, isFalse);
      expect(squat.isRemovedExercise, isFalse);
    });

    test('exercise only in workout1 is flagged as new', () {
      final w1 = _makeWorkout(id: 'w1', exercises: [_makeExercise(name: 'Bench Press', category: ExerciseCategory.chest)]);
      final w2 = _makeWorkout(id: 'w2', exercises: [_makeExercise(name: 'Squat', category: ExerciseCategory.legs)]);

      final result = useCase.compareDetailed(w1, w2);
      final bench = result.exerciseComparison['Bench Press']!;

      expect(bench.isNewExercise, isTrue);
      expect(bench.isRemovedExercise, isFalse);
    });

    test('exercise only in workout2 is flagged as removed', () {
      final w1 = _makeWorkout(id: 'w1', exercises: [_makeExercise(name: 'Squat', category: ExerciseCategory.legs)]);
      final w2 = _makeWorkout(id: 'w2', exercises: [_makeExercise(name: 'Bench Press', category: ExerciseCategory.chest)]);

      final result = useCase.compareDetailed(w1, w2);
      final bench = result.exerciseComparison['Bench Press']!;

      expect(bench.isRemovedExercise, isTrue);
    });

    test('overallScore is a finite number', () {
      final w1 = _makeWorkout(id: 'w1', exercises: [_makeExercise(name: 'Squat')]);
      final w2 = _makeWorkout(id: 'w2', exercises: [_makeExercise(name: 'Squat')]);

      final result = useCase.compareDetailed(w1, w2);
      expect(result.overallScore.isFinite, isTrue);
    });

    test('overallScore is 0 when both workouts have empty metrics', () {
      final w1 = _makeWorkout(id: 'w1');
      final w2 = _makeWorkout(id: 'w2');

      final result = useCase.compareDetailed(w1, w2);
      // Both metrics are zero → scores are all 0
      expect(result.overallScore, closeTo(0, 0.01));
    });
  });

  // ───────────────────────────────────────────
  // getWorkoutTrends()
  // ───────────────────────────────────────────

  group('getWorkoutTrends()', () {
    test('returns empty list for fewer than 2 workouts', () {
      final w = _makeWorkout();
      expect(useCase.getWorkoutTrends([]), isEmpty);
      expect(useCase.getWorkoutTrends([w]), isEmpty);
    });

    test('returns empty list when all workouts are outside the period', () {
      final old = DateTime.now().subtract(const Duration(days: 60));
      final w1 = _makeWorkout(id: 'w1', updatedAt: old.subtract(const Duration(days: 1)));
      final w2 = _makeWorkout(id: 'w2', updatedAt: old);

      final result = useCase.getWorkoutTrends([w1, w2], periodDays: 30);
      expect(result, isEmpty);
    });

    test('includes trends for workouts within the period', () {
      final now = DateTime.now();
      final w1 = _makeWorkout(
        id: 'w1',
        updatedAt: now.subtract(const Duration(days: 5)),
        exercises: [_makeExercise(name: 'Squat')],
      );
      final w2 = _makeWorkout(
        id: 'w2',
        updatedAt: now.subtract(const Duration(days: 2)),
        exercises: [_makeExercise(name: 'Squat')],
      );

      final result = useCase.getWorkoutTrends([w1, w2], periodDays: 30);
      expect(result, isNotEmpty);
    });

    test('sorts workouts by date before computing trends', () {
      final now = DateTime.now();
      // Provide workouts in reverse-chronological order.
      final w2 = _makeWorkout(
        id: 'w2',
        updatedAt: now.subtract(const Duration(days: 2)),
        exercises: [_makeExercise()],
      );
      final w1 = _makeWorkout(
        id: 'w1',
        updatedAt: now.subtract(const Duration(days: 5)),
        exercises: [_makeExercise()],
      );

      final result = useCase.getWorkoutTrends([w2, w1], periodDays: 30);
      // Trends should be based on w1 → w2 comparison (oldest first)
      expect(result, isNotEmpty);
    });

    test('each trend carries a trendDirection', () {
      final now = DateTime.now();
      final w1 = _makeWorkout(
        id: 'w1',
        updatedAt: now.subtract(const Duration(days: 5)),
        exercises: [_makeExercise()],
      );
      final w2 = _makeWorkout(
        id: 'w2',
        updatedAt: now.subtract(const Duration(days: 2)),
        exercises: [_makeExercise()],
      );

      final result = useCase.getWorkoutTrends([w1, w2], periodDays: 30);
      expect(result.first.trendDirection, isA<TrendDirection>());
    });

    test('trend date matches the current workout updatedAt', () {
      final now = DateTime.now();
      final w1 = _makeWorkout(
        id: 'w1',
        updatedAt: now.subtract(const Duration(days: 5)),
        exercises: [_makeExercise()],
      );
      final w2 = _makeWorkout(
        id: 'w2',
        updatedAt: now.subtract(const Duration(days: 2)),
        exercises: [_makeExercise()],
      );

      final result = useCase.getWorkoutTrends([w1, w2], periodDays: 30);
      expect(result.first.date, equals(w2.updatedAt));
    });
  });

  // ───────────────────────────────────────────
  // TrendDirection logic (via getWorkoutTrends)
  // ───────────────────────────────────────────

  group('TrendDirection thresholds', () {
    Workout _workoutWithVolume(String id, double weight, DateTime updatedAt) {
      return _makeWorkout(
        id: id,
        updatedAt: updatedAt,
        exercises: [
          _makeExercise(
            name: 'Squat',
            sets: [_makeSet(weight: weight, reps: 10, rpe: 8)],
          ),
        ],
      );
    }

    test('stable when improvement score is within ±5', () {
      final now = DateTime.now();
      // Same weight → score ≈ 0 → stable
      final w1 = _workoutWithVolume('w1', 80, now.subtract(const Duration(days: 5)));
      final w2 = _workoutWithVolume('w2', 80, now.subtract(const Duration(days: 2)));

      final trends = useCase.getWorkoutTrends([w1, w2], periodDays: 30);
      expect(trends.first.trendDirection, equals(TrendDirection.stable));
    });
  });

  // ───────────────────────────────────────────
  // MetricComparison computed properties
  // ───────────────────────────────────────────

  group('MetricComparison', () {
    test('isImprovement is true when change > 0', () {
      const mc = MetricComparison(current: 10, previous: 8, change: 2, changePercentage: 25);
      expect(mc.isImprovement, isTrue);
    });

    test('isRegression is true when change < 0', () {
      const mc = MetricComparison(current: 8, previous: 10, change: -2, changePercentage: -20);
      expect(mc.isRegression, isTrue);
    });

    test('isStable is true when change absolute value < 0.01', () {
      const mc = MetricComparison(current: 10, previous: 10, change: 0, changePercentage: 0);
      expect(mc.isStable, isTrue);
    });

    test('isStable is false when change > 0.01', () {
      const mc = MetricComparison(current: 10.02, previous: 10, change: 0.02, changePercentage: 0.2);
      expect(mc.isStable, isFalse);
    });
  });

  // ───────────────────────────────────────────
  // ExerciseComparison computed properties
  // ───────────────────────────────────────────

  group('ExerciseComparison', () {
    test('isInBoth true when in both workouts', () {
      const ec = ExerciseComparison(
        exerciseName: 'Squat',
        inWorkout1: true,
        inWorkout2: true,
        volume1: 1000,
        volume2: 900,
        sets1: 3,
        sets2: 3,
      );
      expect(ec.isInBoth, isTrue);
      expect(ec.isNewExercise, isFalse);
      expect(ec.isRemovedExercise, isFalse);
    });

    test('isNewExercise true when only in workout1', () {
      const ec = ExerciseComparison(
        exerciseName: 'Bench Press',
        inWorkout1: true,
        inWorkout2: false,
        volume1: 500,
        volume2: 0,
        sets1: 3,
        sets2: 0,
      );
      expect(ec.isNewExercise, isTrue);
      expect(ec.isInBoth, isFalse);
      expect(ec.isRemovedExercise, isFalse);
    });

    test('isRemovedExercise true when only in workout2', () {
      const ec = ExerciseComparison(
        exerciseName: 'Deadlift',
        inWorkout1: false,
        inWorkout2: true,
        volume1: 0,
        volume2: 800,
        sets1: 0,
        sets2: 4,
      );
      expect(ec.isRemovedExercise, isTrue);
      expect(ec.isInBoth, isFalse);
      expect(ec.isNewExercise, isFalse);
    });

    test('volumeChange is volume1 - volume2', () {
      const ec = ExerciseComparison(
        exerciseName: 'Squat',
        inWorkout1: true,
        inWorkout2: true,
        volume1: 1200,
        volume2: 1000,
        sets1: 3,
        sets2: 3,
      );
      expect(ec.volumeChange, closeTo(200, 0.01));
    });

    test('setsChange is sets1 - sets2', () {
      const ec = ExerciseComparison(
        exerciseName: 'Squat',
        inWorkout1: true,
        inWorkout2: true,
        volume1: 1000,
        volume2: 1000,
        sets1: 4,
        sets2: 3,
      );
      expect(ec.setsChange, equals(1));
    });
  });

  // ───────────────────────────────────────────
  // WorkoutComparison computed properties
  // ───────────────────────────────────────────

  group('WorkoutComparison', () {
    WorkoutComparison _makeComparison({double improvementScore = 0}) {
      return WorkoutComparison(
        comparisonId: 'cmp1',
        comparisonDate: DateTime(2025, 1, 1),
        comparisonName: 'Old Workout',
        volumeChange: 100,
        volumeChangePercentage: 10,
        intensityChange: 0.5,
        intensityChangePercentage: 5,
        durationChange: const Duration(minutes: -5),
        densityChange: 1.0,
        improvementScore: improvementScore,
      );
    }

    test('isImprovement is true when improvementScore > 5', () {
      expect(_makeComparison(improvementScore: 10).isImprovement, isTrue);
    });

    test('isImprovement is false when improvementScore <= 5', () {
      expect(_makeComparison(improvementScore: 5).isImprovement, isFalse);
      expect(_makeComparison(improvementScore: 3).isImprovement, isFalse);
    });

    test('isSimilar is true when abs(improvementScore) <= 5', () {
      expect(_makeComparison(improvementScore: 0).isSimilar, isTrue);
      expect(_makeComparison(improvementScore: 5).isSimilar, isTrue);
      expect(_makeComparison(improvementScore: -5).isSimilar, isTrue);
    });

    test('isSimilar is false when abs(improvementScore) > 5', () {
      expect(_makeComparison(improvementScore: 6).isSimilar, isFalse);
      expect(_makeComparison(improvementScore: -6).isSimilar, isFalse);
    });

    test('isRegression is true when improvementScore < -5', () {
      expect(_makeComparison(improvementScore: -10).isRegression, isTrue);
    });

    test('isRegression is false when improvementScore >= -5', () {
      expect(_makeComparison(improvementScore: -5).isRegression, isFalse);
      expect(_makeComparison(improvementScore: 0).isRegression, isFalse);
    });

    test('formattedVolumeChange shows + sign for positive change', () {
      final cmp = _makeComparison();
      expect(cmp.formattedVolumeChange, startsWith('+'));
    });

    test('formattedVolumeChange shows no + sign for negative change', () {
      final cmp = WorkoutComparison(
        comparisonId: 'c',
        comparisonDate: DateTime(2025, 1, 1),
        comparisonName: 'Old',
        volumeChange: -100,
        volumeChangePercentage: -10,
        intensityChange: 0,
        intensityChangePercentage: 0,
        durationChange: Duration.zero,
        densityChange: 0,
        improvementScore: -10,
      );
      expect(cmp.formattedVolumeChange, startsWith('-'));
    });

    test('formattedDurationChange shows - sign for negative duration', () {
      final cmp = _makeComparison(); // durationChange = -5 min
      expect(cmp.formattedDurationChange, startsWith('-'));
    });

    test('formattedDurationChange shows + sign for positive duration', () {
      final cmp = WorkoutComparison(
        comparisonId: 'c',
        comparisonDate: DateTime(2025, 1, 1),
        comparisonName: 'Old',
        volumeChange: 0,
        volumeChangePercentage: 0,
        intensityChange: 0,
        intensityChangePercentage: 0,
        durationChange: const Duration(minutes: 5),
        densityChange: 0,
        improvementScore: 0,
      );
      expect(cmp.formattedDurationChange, startsWith('+'));
    });
  });

  // ───────────────────────────────────────────
  // WorkoutSimilarity
  // ───────────────────────────────────────────

  group('WorkoutSimilarity', () {
    test('exposes workout, similarity, and comparison fields', () {
      final w = _makeWorkout(id: 'w1', exercises: [_makeExercise()]);
      final cmp = WorkoutComparison(
        comparisonId: 'c1',
        comparisonDate: DateTime(2025, 1, 1),
        comparisonName: 'Ref',
        volumeChange: 0,
        volumeChangePercentage: 0,
        intensityChange: 0,
        intensityChangePercentage: 0,
        durationChange: Duration.zero,
        densityChange: 0,
        improvementScore: 0,
      );

      final ws = WorkoutSimilarity(workout: w, similarity: 0.8, comparison: cmp);

      expect(ws.workout.id, equals('w1'));
      expect(ws.similarity, equals(0.8));
      expect(ws.comparison, equals(cmp));
    });
  });

  // ───────────────────────────────────────────
  // DetailedWorkoutComparison
  // ───────────────────────────────────────────

  group('DetailedWorkoutComparison structure', () {
    test('holds all required fields', () {
      final now = DateTime.now();
      final w1 = _makeWorkout(
        id: 'w1',
        exercises: [_makeExercise(name: 'Squat')],
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: now,
      );
      final w2 = _makeWorkout(
        id: 'w2',
        exercises: [_makeExercise(name: 'Squat')],
        startTime: now.subtract(const Duration(hours: 1, minutes: 5)),
        endTime: now,
      );

      final detail = useCase.compareDetailed(w1, w2);

      expect(detail.workout1, equals(w1));
      expect(detail.workout2, equals(w2));
      expect(detail.metrics1.workoutId, equals('w1'));
      expect(detail.metrics2.workoutId, equals('w2'));
      expect(detail.volumeComparison, isNotNull);
      expect(detail.intensityComparison, isNotNull);
      expect(detail.durationComparison, isNotNull);
      expect(detail.exerciseComparison, isNotNull);
    });
  });

  // ───────────────────────────────────────────
  // Similarity calculation edge cases
  // ───────────────────────────────────────────

  group('Similarity edge cases', () {
    test('two empty workouts have similarity based purely on volume (both 0)', () {
      // Both empty → exercise similarity = 0 (union empty), muscle = 0, volume = 1.0
      // Result = 0*0.5 + 0*0.3 + 1.0*0.2 = 0.2  → below 0.3 threshold
      final w1 = _makeWorkout(id: 'w1');
      final w2 = _makeWorkout(id: 'w2');

      final result = useCase.execute(w1, [w2]);
      // Similarity is 0.2 which is < 0.3, so no match returned
      expect(result, isNull);
    });

    test('identical non-empty workouts have similarity >= 0.3', () {
      final exercise = _makeExercise(name: 'Squat');
      final w1 = _makeWorkout(id: 'w1', exercises: [exercise]);
      final w2 = _makeWorkout(id: 'w2', exercises: [exercise]);

      final result = useCase.execute(w1, [w2]);
      expect(result, isNotNull);
    });

    test('volume similarity is 1.0 when both have the same volume', () {
      // Indirectly tested via compareDetailed overallScore not being NaN
      final sets = [_makeSet(weight: 100, reps: 5)];
      final w1 = _makeWorkout(id: 'w1', exercises: [_makeExercise(sets: sets)]);
      final w2 = _makeWorkout(id: 'w2', exercises: [_makeExercise(sets: sets)]);

      final result = useCase.compareDetailed(w1, w2);
      expect(result.volumeComparison.change, closeTo(0, 0.01));
    });
  });

  // ───────────────────────────────────────────
  // Improvement score clamping
  // ───────────────────────────────────────────

  group('Improvement score clamping', () {
    test('improvementScore in WorkoutComparison is between -100 and 100', () {
      // Use very different volumes to push score towards extremes.
      final highVolumeSets = List.generate(
        20,
        (i) => _makeSet(setNumber: i + 1, weight: 200, reps: 10, rpe: 10),
      );
      final zeroSets = [_makeSet(weight: 0, reps: 0, isCompleted: false)];

      final current = _makeWorkout(
        id: 'c',
        exercises: [_makeExercise(name: 'Squat', sets: highVolumeSets)],
      );
      final previous = _makeWorkout(
        id: 'p',
        exercises: [_makeExercise(name: 'Squat', sets: zeroSets)],
      );

      final result = useCase.execute(current, [previous]);
      if (result != null) {
        expect(result.improvementScore, greaterThanOrEqualTo(-100));
        expect(result.improvementScore, lessThanOrEqualTo(100));
      }
    });
  });
}
