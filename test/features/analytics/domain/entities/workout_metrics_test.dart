import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  group('WorkoutMetrics', () {
    test('should calculate correct total volume', () {
      // Arrange
      final sets = [
        ExerciseSet(
          setNumber: 1,
          weight: 100,
          reps: 10,
          isCompleted: true,
        ),
        ExerciseSet(
          setNumber: 2,
          weight: 100,
          reps: 8,
          isCompleted: true,
        ),
        ExerciseSet(
          setNumber: 3,
          weight: 90,
          reps: 10,
          isCompleted: true,
        ),
      ];

      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: sets,
      );

      final workout = Workout(
      id: 'test-workout-1',
        name: 'Chest Day',
        exercises: [exercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);

      // Assert
      expect(metrics.totalVolume, equals(2700)); // (100*10) + (100*8) + (90*10)
      expect(metrics.completedSets, equals(3));
      expect(metrics.totalSets, equals(3));
    });

    test('should calculate correct training density', () {
      // Arrange
      final exercise = Exercise(
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 100,
            reps: 10,
            isCompleted: true,
          ),
        ],
      );

      final workout = Workout(
      id: 'test-workout-2',
        name: 'Leg Day',
        exercises: [exercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(minutes: 10)),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);

      // Assert
      expect(metrics.trainingDensity, equals(100)); // 1000kg / 10 minutes
    });

    test('should identify strong workout', () {
      // Arrange
      final sets = List.generate(
        10,
        (index) => ExerciseSet(
          setNumber: index + 1,
          weight: 100,
          reps: 10,
          isCompleted: true,
          rpe: 8,
        ),
      );

      final exercise = Exercise(
        name: 'Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        sets: sets,
      );

      final workout = Workout(
      id: 'test-workout-3',
        name: 'Back Day',
        exercises: [exercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(minutes: 40)),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);

      // Assert
      expect(metrics.totalVolume, equals(10000)); // 10 sets * 100kg * 10 reps
      expect(metrics.averageRPE, equals(8));
      expect(metrics.isStrongWorkout, isTrue);
    });

    test('should calculate quality score correctly', () {
      // Arrange
      final exercise = Exercise(
        name: 'Pull-ups',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 0,
            reps: 10,
            isCompleted: true,
            rpe: 7,
          ),
          ExerciseSet(
            setNumber: 2,
            weight: 0,
            reps: 8,
            isCompleted: true,
            rpe: 8,
          ),
        ],
      );

      final workout = Workout(
      id: 'test-workout-4',
        name: 'Pull Day',
        exercises: [exercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(minutes: 20)),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);
      final qualityScore = metrics.qualityScore;

      // Assert
      expect(qualityScore, greaterThanOrEqualTo(0));
      expect(qualityScore, lessThanOrEqualTo(100));
    });

    test('should handle empty workout correctly', () {
      // Arrange
      final workout = Workout(
      id: 'test-workout-5',
        name: 'Empty Workout',
        exercises: [],
        status: WorkoutStatus.planned,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);

      // Assert
      expect(metrics.totalVolume, equals(0));
      expect(metrics.completedSets, equals(0));
      expect(metrics.averageRPE, equals(0));
      expect(metrics.qualityScore, equals(0));
    });

    test('should format metrics correctly', () {
      // Arrange
      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 100.5,
            reps: 10,
            isCompleted: true,
          ),
        ],
      );

      final workout = Workout(
      id: 'test-workout-6',
        name: 'Test Workout',
        exercises: [exercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);

      // Assert
      expect(metrics.formattedVolume, equals('1005 kg'));
      expect(metrics.formattedDuration, equals('1h 15m'));
      expect(metrics.formattedDensity, matches(RegExp(r'\d+\.\d kg/min')));
    });

    test('should group volume by muscle correctly', () {
      // Arrange
      final chestExercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 100,
            reps: 10,
            isCompleted: true,
          ),
        ],
      );

      final backExercise = Exercise(
        name: 'Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 150,
            reps: 5,
            isCompleted: true,
          ),
        ],
      );

      final workout = Workout(
      id: 'test-workout-7',
        name: 'Upper Body',
        exercises: [chestExercise, backExercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(minutes: 45)),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);

      // Assert
      expect(metrics.volumeByMuscleGroup[ExerciseCategory.chest], equals(1000));
      expect(metrics.volumeByMuscleGroup[ExerciseCategory.back], equals(750));
    });

    test('warmup vs working volume separation', () {
      final exercise = Exercise(
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [
          ExerciseSet(setNumber: 1, weight: 40, reps: 10, isCompleted: true, isWarmup: true),
          ExerciseSet(setNumber: 2, weight: 100, reps: 5, isCompleted: true, isWarmup: false),
        ],
      );

      final workout = Workout(
        id: 'w-warmup',
        name: 'Test',
        exercises: [exercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final metrics = WorkoutMetrics.fromWorkout(workout);
      expect(metrics.warmupSets, 1);
      expect(metrics.workingSets, 1);
      expect(metrics.warmupVolume, 400); // 40*10
      expect(metrics.workingSetsVolume, 500); // 100*5
    });

    test('peakIntensity is maximum weight*reps', () {
      final exercise = Exercise(
        name: 'Bench',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, weight: 80, reps: 10, isCompleted: true),
          ExerciseSet(setNumber: 2, weight: 100, reps: 5, isCompleted: true),
        ],
      );

      final workout = Workout(
        id: 'w-peak',
        name: 'Test',
        exercises: [exercise],
        status: WorkoutStatus.completed,
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final metrics = WorkoutMetrics.fromWorkout(workout);
      // 80*10=800 vs 100*5=500, peak should be 800
      expect(metrics.peakIntensity, 800);
    });
  });

  group('WorkoutMetrics - serialization', () {
    test('toJson contains required fields', () {
      final metrics = WorkoutMetrics.empty('w1');
      final json = metrics.toJson();
      expect(json['workoutId'], 'w1');
      expect(json['totalVolume'], 0);
      expect(json['totalSets'], 0);
    });

    test('fromJson parses complete data', () {
      final json = {
        'workoutId': 'w1',
        'workoutName': 'Test Workout',
        'workoutDate': '2024-06-15T10:00:00.000',
        'calculatedAt': '2024-06-15T10:00:00.000',
        'totalVolume': 1500.0,
        'workingSetsVolume': 1200.0,
        'warmupVolume': 300.0,
        'totalSets': 15,
        'completedSets': 12,
        'workingSets': 10,
        'warmupSets': 2,
        'averageWeight': 80.0,
        'averageRPE': 8.0,
        'averageIntensity': 0.7,
        'peakIntensity': 120.0,
        'trainingDensity': 25.0,
        'completionPercentage': 0.8,
        'exercisesCompleted': 4,
        'totalExercises': 5,
      };
      final metrics = WorkoutMetrics.fromJson(json);
      expect(metrics.workoutId, 'w1');
      expect(metrics.workoutName, 'Test Workout');
      expect(metrics.workoutDate, isNotNull);
      expect(metrics.totalVolume, 1500.0);
      expect(metrics.completedSets, 12);
    });

    test('fromJson with defaults', () {
      final json = <String, dynamic>{
        'calculatedAt': '2024-06-15T10:00:00.000',
      };
      final metrics = WorkoutMetrics.fromJson(json);
      expect(metrics.workoutId, '');
      expect(metrics.totalVolume, 0);
      expect(metrics.totalDuration, Duration.zero);
    });

    test('fromJson with duration', () {
      final json = {
        'workoutId': 'w1',
        'calculatedAt': '2024-06-15T10:00:00.000',
        'totalDuration': 3600,
        'workingTime': 1800,
        'restTime': 1800,
      };
      final metrics = WorkoutMetrics.fromJson(json);
      expect(metrics.totalDuration, const Duration(seconds: 3600));
      expect(metrics.workingTime, const Duration(seconds: 1800));
    });
  });

  group('WorkoutMetrics - copyWith', () {
    test('copies with new values', () {
      final original = WorkoutMetrics.empty('w1');
      final copy = original.copyWith(
        totalVolume: 500.0,
        completedSets: 10,
        averageRPE: 8.0,
      );
      expect(copy.totalVolume, 500.0);
      expect(copy.completedSets, 10);
      expect(copy.averageRPE, 8.0);
      expect(copy.workoutId, 'w1');
    });

    test('copyWith comparison', () {
      final original = WorkoutMetrics.empty('w1');
      final comparison = WorkoutComparison(
        comparisonId: 'c1',
        comparisonDate: DateTime(2024, 6, 10),
        comparisonName: 'Prev',
        volumeChange: 100,
        volumeChangePercentage: 10,
        intensityChange: 0.5,
        intensityChangePercentage: 5,
        durationChange: Duration.zero,
        densityChange: 0,
        improvementScore: 15,
      );
      final copy = original.copyWith(comparison: comparison);
      expect(copy.comparison, isNotNull);
      expect(copy.comparison!.comparisonId, 'c1');
    });
  });

  group('WorkoutMetrics - formattedDuration edge cases', () {
    test('zero duration', () {
      final m = WorkoutMetrics.empty('w1');
      expect(m.formattedDuration, '0m');
    });

    test('exactly one hour', () {
      final m = WorkoutMetrics.empty('w1').copyWith(
        totalDuration: const Duration(hours: 1),
      );
      expect(m.formattedDuration, '1h 0m');
    });
  });

  group('WorkoutComparison', () {
    WorkoutComparison makeComparison({
      double improvementScore = 0,
      double volumeChange = 100,
      double volumeChangePercentage = 10,
      double intensityChange = 0.5,
      double intensityChangePercentage = 5,
      Duration durationChange = Duration.zero,
    }) {
      return WorkoutComparison(
        comparisonId: 'c1',
        comparisonDate: DateTime(2024, 6, 10),
        comparisonName: 'Previous',
        volumeChange: volumeChange,
        volumeChangePercentage: volumeChangePercentage,
        intensityChange: intensityChange,
        intensityChangePercentage: intensityChangePercentage,
        durationChange: durationChange,
        densityChange: 2.0,
        improvementScore: improvementScore,
      );
    }

    test('isImprovement', () {
      expect(makeComparison(improvementScore: 10).isImprovement, true);
      expect(makeComparison(improvementScore: 5).isImprovement, false);
      expect(makeComparison(improvementScore: -10).isImprovement, false);
    });

    test('isSimilar', () {
      expect(makeComparison(improvementScore: 3).isSimilar, true);
      expect(makeComparison(improvementScore: -4).isSimilar, true);
      expect(makeComparison(improvementScore: 10).isSimilar, false);
    });

    test('isRegression', () {
      expect(makeComparison(improvementScore: -10).isRegression, true);
      expect(makeComparison(improvementScore: -5).isRegression, false);
      expect(makeComparison(improvementScore: 10).isRegression, false);
    });

    test('formattedVolumeChange positive', () {
      final c = makeComparison(volumeChange: 150, volumeChangePercentage: 15);
      expect(c.formattedVolumeChange, '+150 kg (15.0%)');
    });

    test('formattedVolumeChange negative', () {
      final c = makeComparison(volumeChange: -100, volumeChangePercentage: -10);
      expect(c.formattedVolumeChange, '-100 kg (-10.0%)');
    });

    test('formattedIntensityChange', () {
      final c = makeComparison(intensityChange: 0.5, intensityChangePercentage: 5);
      expect(c.formattedIntensityChange, '+0.5 RPE (5.0%)');
    });

    test('formattedDurationChange positive', () {
      final c = makeComparison(durationChange: const Duration(minutes: 10));
      expect(c.formattedDurationChange, '+10m');
    });

    test('formattedDurationChange negative', () {
      final c = makeComparison(durationChange: const Duration(minutes: -5));
      expect(c.formattedDurationChange, '-5m');
    });
  });

  group('PersonalRecordAchieved', () {
    PersonalRecordAchieved makePR({
      PRType type = PRType.weight,
      double newValue = 100,
      double? previousValue,
    }) {
      return PersonalRecordAchieved(
        exerciseId: 'e1',
        exerciseName: 'Bench Press',
        type: type,
        newValue: newValue,
        previousValue: previousValue,
        achievedAt: DateTime(2024, 6, 15),
      );
    }

    test('improvementPercentage with previous', () {
      final pr = makePR(newValue: 110, previousValue: 100);
      expect(pr.improvementPercentage, 10.0);
    });

    test('improvementPercentage null previous', () {
      final pr = makePR(newValue: 100);
      expect(pr.improvementPercentage, 100);
    });

    test('improvementPercentage zero previous', () {
      final pr = makePR(newValue: 100, previousValue: 0);
      expect(pr.improvementPercentage, 100);
    });

    test('isSignificant true', () {
      final pr = makePR(newValue: 110, previousValue: 100);
      expect(pr.isSignificant, true); // 10% > 2.5%
    });

    test('isSignificant false', () {
      final pr = makePR(newValue: 101, previousValue: 100);
      expect(pr.isSignificant, false); // 1% < 2.5%
    });

    test('formattedImprovement', () {
      final pr = makePR(newValue: 110, previousValue: 100);
      expect(pr.formattedImprovement, '+10.0%');
    });

    test('typeDescription all types', () {
      for (final type in PRType.values) {
        final pr = makePR(type: type);
        expect(pr.typeDescription, isNotEmpty,
            reason: 'typeDescription for ${type.name}');
      }
    });

    test('typeDescription specific values', () {
      expect(makePR(type: PRType.weight).typeDescription, 'Max Weight');
      expect(makePR(type: PRType.reps).typeDescription, 'Max Reps');
      expect(makePR(type: PRType.volume).typeDescription, 'Volume PR');
      expect(makePR(type: PRType.oneRM).typeDescription, '1RM Est.');
      expect(makePR(type: PRType.totalSets).typeDescription, 'Most Sets');
      expect(makePR(type: PRType.duration).typeDescription, 'Endurance');
    });

    test('default context is empty', () {
      final pr = makePR();
      expect(pr.context, isEmpty);
    });
  });
}