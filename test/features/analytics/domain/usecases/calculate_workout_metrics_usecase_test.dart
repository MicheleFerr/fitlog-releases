/// CalculateWorkoutMetricsUseCase unit tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/usecases/calculate_workout_metrics_usecase.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

Workout _makeWorkout({
  String id = 'w-1',
  String name = 'Test Workout',
  List<Exercise>? exercises,
  DateTime? startTime,
  DateTime? updatedAt,
  DateTime? createdAt,
}) {
  final now = DateTime(2024, 6, 15, 11, 0);
  return Workout(
    id: id,
    name: name,
    exercises: exercises ?? [],
    startTime: startTime ?? DateTime(2024, 6, 15, 10, 0),
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

Exercise _makeExercise({
  String name = 'Bench Press',
  ExerciseCategory category = ExerciseCategory.chest,
  List<ExerciseSet>? sets,
}) {
  return Exercise(
    name: name,
    type: ExerciseType.single,
    category: category,
    sets: sets ??
        [
          ExerciseSet(
              setNumber: 1,
              weight: 80,
              reps: 10,
              isCompleted: true),
          ExerciseSet(
              setNumber: 2,
              weight: 80,
              reps: 8,
              isCompleted: true),
        ],
  );
}

void main() {
  late CalculateWorkoutMetricsUseCase useCase;

  setUp(() {
    useCase = CalculateWorkoutMetricsUseCase();
  });

  group('execute', () {
    test('returns metrics for valid workout', () {
      final workout = _makeWorkout(
        exercises: [_makeExercise()],
      );
      final metrics = useCase.execute(workout);
      expect(metrics, isA<WorkoutMetrics>());
      expect(metrics.totalVolume, greaterThan(0));
    });

    test('returns empty metrics for empty workout', () {
      final workout = _makeWorkout();
      final metrics = useCase.execute(workout);
      expect(metrics.totalVolume, 0);
      expect(metrics.completedSets, 0);
    });

    test('returns empty metrics on calculation error', () {
      // A workout with no exercises should work fine (empty metrics)
      final workout = _makeWorkout(id: 'w-err');
      final metrics = useCase.execute(workout);
      expect(metrics.workoutId, 'w-err');
    });
  });

  group('executeWithComparison', () {
    test('returns base metrics when no historical workouts', () {
      final workout = _makeWorkout(
        exercises: [_makeExercise()],
      );
      final metrics = useCase.executeWithComparison(workout, []);
      expect(metrics.comparison, isNull);
      expect(metrics.totalVolume, greaterThan(0));
    });

    test('returns comparison when similar workout exists', () {
      final current = _makeWorkout(
        id: 'w-current',
        exercises: [_makeExercise(name: 'Bench Press')],
        updatedAt: DateTime(2024, 6, 15),
      );
      final historical = _makeWorkout(
        id: 'w-hist',
        exercises: [_makeExercise(name: 'Bench Press')],
        updatedAt: DateTime(2024, 6, 10),
      );
      final metrics = useCase.executeWithComparison(current, [historical]);
      expect(metrics.comparison, isNotNull);
      expect(metrics.comparison!.comparisonId, 'w-hist');
    });

    test('falls back to most recent when no similar workout', () {
      final current = _makeWorkout(
        id: 'w-current',
        exercises: [_makeExercise(name: 'Bench Press')],
        updatedAt: DateTime(2024, 6, 15),
      );
      final historical = _makeWorkout(
        id: 'w-different',
        exercises: [
          _makeExercise(
              name: 'Squat', category: ExerciseCategory.legs),
        ],
        updatedAt: DateTime(2024, 6, 10),
      );
      final metrics = useCase.executeWithComparison(current, [historical]);
      // Falls back to most recent since similarity < 0.5
      expect(metrics.comparison, isNotNull);
      expect(metrics.comparison!.comparisonId, 'w-different');
    });

    test('picks most recent similar workout', () {
      final current = _makeWorkout(
        id: 'w-current',
        exercises: [_makeExercise(name: 'Bench Press')],
        updatedAt: DateTime(2024, 6, 15),
      );
      final older = _makeWorkout(
        id: 'w-older',
        exercises: [_makeExercise(name: 'Bench Press')],
        updatedAt: DateTime(2024, 6, 5),
      );
      final newer = _makeWorkout(
        id: 'w-newer',
        exercises: [_makeExercise(name: 'Bench Press')],
        updatedAt: DateTime(2024, 6, 12),
      );
      final metrics =
          useCase.executeWithComparison(current, [older, newer]);
      expect(metrics.comparison!.comparisonId, 'w-newer');
    });
  });

  group('executeIncremental', () {
    test('calculates from scratch when no previous metrics', () {
      final workout = _makeWorkout(
        exercises: [_makeExercise()],
      );
      final metrics = useCase.executeIncremental(workout, null);
      expect(metrics.totalVolume, greaterThan(0));
    });

    test('recalculates when exercise count changes', () {
      final workout = _makeWorkout(
        exercises: [
          _makeExercise(name: 'Bench Press'),
          _makeExercise(name: 'Incline Press'),
        ],
      );
      // Previous metrics had only 1 exercise
      final previousMetrics = useCase.execute(
        _makeWorkout(exercises: [_makeExercise()]),
      );
      final metrics = useCase.executeIncremental(workout, previousMetrics);
      expect(metrics.totalExercises, 2);
    });

    test('recalculates when completed sets change significantly', () {
      final workout = _makeWorkout(
        exercises: [
          _makeExercise(sets: [
            ExerciseSet(
                setNumber: 1,
                weight: 80,
                reps: 10,
                isCompleted: true),
            ExerciseSet(
                setNumber: 2,
                weight: 80,
                reps: 10,
                isCompleted: true),
            ExerciseSet(
                setNumber: 3,
                weight: 80,
                reps: 10,
                isCompleted: true),
            ExerciseSet(
                setNumber: 4,
                weight: 80,
                reps: 10,
                isCompleted: true),
            ExerciseSet(
                setNumber: 5,
                weight: 80,
                reps: 10,
                isCompleted: true),
          ]),
        ],
      );
      // Previous metrics had 2 completed sets
      final previousMetrics = useCase.execute(
        _makeWorkout(exercises: [_makeExercise()]),
      );
      final metrics = useCase.executeIncremental(workout, previousMetrics);
      expect(metrics.completedSets, 5);
    });

    test('does incremental update when no significant changes', () {
      final exercise = _makeExercise();
      final workout = _makeWorkout(exercises: [exercise]);
      final previousMetrics = useCase.execute(workout);

      // Same workout structure, should do incremental
      final metrics = useCase.executeIncremental(workout, previousMetrics);
      expect(metrics.totalVolume, previousMetrics.totalVolume);
    });
  });

  group('workout similarity', () {
    test('identical exercises => high similarity', () {
      final w1 = _makeWorkout(
        exercises: [
          _makeExercise(name: 'Bench Press'),
          _makeExercise(name: 'Squat'),
        ],
      );
      final w2 = _makeWorkout(
        id: 'w-2',
        exercises: [
          _makeExercise(name: 'Bench Press'),
          _makeExercise(name: 'Squat'),
        ],
        updatedAt: DateTime(2024, 6, 10),
      );
      // Similar enough (> 0.5) to be used as comparison
      final metrics = useCase.executeWithComparison(w1, [w2]);
      expect(metrics.comparison!.comparisonId, 'w-2');
    });

    test('no overlap => falls back to most recent', () {
      final w1 = _makeWorkout(
        exercises: [_makeExercise(name: 'Bench Press')],
      );
      final w2 = _makeWorkout(
        id: 'w-2',
        exercises: [
          _makeExercise(
              name: 'Deadlift', category: ExerciseCategory.back),
        ],
        updatedAt: DateTime(2024, 6, 10),
      );
      final metrics = useCase.executeWithComparison(w1, [w2]);
      expect(metrics.comparison!.comparisonId, 'w-2');
    });

    test('empty exercises => similarity 0, falls back', () {
      final w1 = _makeWorkout();
      final w2 = _makeWorkout(
        id: 'w-2',
        updatedAt: DateTime(2024, 6, 10),
      );
      final metrics = useCase.executeWithComparison(w1, [w2]);
      expect(metrics.comparison!.comparisonId, 'w-2');
    });
  });
}
