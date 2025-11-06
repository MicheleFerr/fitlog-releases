import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_performance_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_set.dart';

void main() {
  group('WorkoutPerformanceProvider Tests', () {
    late ProviderContainer container;
    late Workout testWorkout;

    setUp(() {
      container = ProviderContainer();
      
      testWorkout = Workout(
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        id: 'test-workout-1',
        name: 'Push Day',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        exercises: [
          Exercise(
            id: 'ex1',
            name: 'Bench Press',
            muscleGroup: 'Chest',
            sets: [
              ExerciseSet(
                id: 's1',
                setNumber: 1,
                targetWeight: 80,
                targetReps: 10,
                actualWeight: 80,
                actualReps: 10,
                isCompleted: true,
              ),
              ExerciseSet(
                id: 's2',
                setNumber: 2,
                targetWeight: 80,
                targetReps: 10,
                actualWeight: 80,
                actualReps: 8,
                isCompleted: true,
              ),
              ExerciseSet(
                id: 's3',
                setNumber: 3,
                targetWeight: 75,
                targetReps: 10,
                actualWeight: 75,
                actualReps: 10,
                isCompleted: true,
              ),
            ],
          ),
          Exercise(
            id: 'ex2',
            name: 'Shoulder Press',
            muscleGroup: 'Shoulders',
            sets: [
              ExerciseSet(
                id: 's4',
                setNumber: 1,
                targetWeight: 40,
                targetReps: 12,
                actualWeight: 40,
                actualReps: 12,
                isCompleted: true,
              ),
              ExerciseSet(
                id: 's5',
                setNumber: 2,
                targetWeight: 40,
                targetReps: 12,
                actualWeight: 40,
                actualReps: 10,
                isCompleted: true,
              ),
            ],
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('calculates total volume correctly', () {
      final volume = container.read(workoutTotalVolumeProvider(testWorkout));
      
      // Expected: (80*10 + 80*8 + 75*10) + (40*12 + 40*10)
      // = (800 + 640 + 750) + (480 + 400)
      // = 2190 + 880 = 3070
      expect(volume, 3070.0);
    });

    test('calculates workout intensity correctly', () {
      final intensity = container.read(workoutIntensityProvider(testWorkout));
      
      // Average weight used across all sets
      // (80 + 80 + 75 + 40 + 40) / 5 = 315 / 5 = 63
      expect(intensity, 63.0);
    });

    test('tracks exercise progression', () {
      final previousWorkout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        id: 'prev-1',
        name: 'Previous Push Day',
        startTime: DateTime.now().subtract(const Duration(days: 7)),
        exercises: [
          Exercise(
            id: 'ex1',
            name: 'Bench Press',
            sets: [
              ExerciseSet(
                id: 'ps1',
                setNumber: 1,
                actualWeight: 75,
                actualReps: 10,
                isCompleted: true,
              ),
            ],
          ),
        ],
      );

      final progressionData = container.read(
        exerciseProgressionProvider([previousWorkout, testWorkout])
      );

      expect(progressionData, isNotEmpty);
      expect(progressionData['Bench Press'], isNotNull);
      
      final benchProgression = progressionData['Bench Press'];
      if (benchProgression != null) {
        expect(benchProgression.maxWeight, 80.0);
        expect(benchProgression.totalVolume, greaterThan(0));
      }
    });

    test('identifies personal records', () {
      final workoutHistory = [
        Workout(
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          id: 'w1',
          name: 'Old Workout',
          startTime: DateTime.now().subtract(const Duration(days: 30)),
          exercises: [
            Exercise(
              id: 'e1',
              name: 'Bench Press',
              sets: [
                ExerciseSet(
                  id: 's1',
                  actualWeight: 70,
                  actualReps: 10,
                  isCompleted: true,
                ),
              ],
            ),
          ],
        ),
        testWorkout,
      ];

      final records = container.read(
        personalRecordsProvider((workout: testWorkout, history: workoutHistory))
      );

      expect(records, isNotEmpty);
      // Should identify 80kg as a PR for Bench Press
      expect(
        records.any((r) => r.exerciseName == 'Bench Press' && r.weight == 80),
        true,
      );
    });

    test('calculates workout duration', () {
      final completedWorkout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        id: 'completed-1',
        name: 'Completed Workout',
        startTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        endTime: DateTime.now(),
        exercises: [],
      );

      final duration = completedWorkout.endTime!.difference(completedWorkout.startTime);
      expect(duration.inMinutes, 90);
    });

    test('calculates rest time analytics', () {
      final restAnalytics = container.read(restTimeAnalyticsProvider(testWorkout));
      
      expect(restAnalytics.averageRestTime, isNotNull);
      expect(restAnalytics.totalRestTime, greaterThanOrEqualTo(0));
      expect(restAnalytics.restTimesByExercise, isNotEmpty);
    });

    test('muscle group distribution analysis', () {
      final distribution = container.read(muscleGroupDistributionProvider(testWorkout));
      
      expect(distribution['Chest'], isNotNull);
      expect(distribution['Shoulders'], isNotNull);
      
      // Chest should have more volume (3 sets vs 2 sets)
      expect(distribution['Chest']! > distribution['Shoulders']!, true);
    });

    test('workout rating calculation', () {
      // Complete all planned sets/reps = high rating
      final rating = container.read(workoutRatingProvider(testWorkout));
      
      expect(rating, greaterThanOrEqualTo(0));
      expect(rating, lessThanOrEqualTo(5));
    });

    test('calculates set completion rate', () {
      final completionRate = testWorkout.exercises
          .expand((e) => e.sets)
          .where((s) => s.isCompleted)
          .length / 
          testWorkout.exercises.expand((e) => e.sets).length;
      
      expect(completionRate, 1.0); // All sets completed in test workout
    });

    test('identifies workout trends over time', () {
      final workoutHistory = List.generate(5, (i) {
        return Workout(
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          id: 'workout-$i',
          name: 'Push Day',
          startTime: DateTime.now().subtract(Duration(days: i * 7)),
          exercises: [
            Exercise(
              id: 'ex-$i',
              name: 'Bench Press',
              sets: [
                ExerciseSet(
                  id: 'set-$i',
                  actualWeight: 70.0 + (i * 2.5), // Progressive overload
                  actualReps: 10,
                  isCompleted: true,
                ),
              ],
            ),
          ],
        );
      });

      final trends = container.read(workoutTrendsProvider(workoutHistory));
      
      expect(trends.volumeTrend, isNotNull);
      expect(trends.intensityTrend, isNotNull);
      expect(trends.frequencyTrend, isNotNull);
    });

    test('calculates estimated 1RM', () {
      // Using Epley formula: 1RM = weight × (1 + reps/30)
      final oneRM = container.read(
        estimated1RMProvider((weight: 80.0, reps: 10))
      );
      
      // 80 × (1 + 10/30) = 80 × 1.333... ≈ 106.67
      expect(oneRM, closeTo(106.67, 0.1));
    });

    test('provides workout recommendations', () {
      final recommendations = container.read(
        workoutRecommendationsProvider(testWorkout)
      );
      
      expect(recommendations, isNotEmpty);
      expect(recommendations.length, lessThanOrEqualTo(5));
      
      for (final recommendation in recommendations) {
        expect(recommendation.title, isNotEmpty);
        expect(recommendation.description, isNotEmpty);
        expect(recommendation.priority, greaterThan(0));
      }
    });
  });
}