import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_analyzer.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';

void main() {
  group('calculateWeeklySets', () {
    test('should calculate weekly sets per muscle group correctly', () {
      // 🐛 BUG PREVENTED: Incorrect volume tracking leading to overtraining/undertraining
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 4),
            _createExercise('Squat', ExerciseCategory.legs, sets: 5),
          ],
        ),
        _createWorkout(
          daysAgo: 4,
          exercises: [
            _createExercise('Pull-ups', ExerciseCategory.back, sets: 3),
            _createExercise('Overhead Press', ExerciseCategory.shoulders, sets: 4),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySets(workouts);

      expect(result[MuscleGroup.chest], 4);
      expect(result[MuscleGroup.legs], 5);
      expect(result[MuscleGroup.back], 3);
      expect(result[MuscleGroup.shoulders], 4);
      expect(result[MuscleGroup.arms], 0);
      expect(result[MuscleGroup.core], 0);
    });

    test('should only count workouts from last 7 days', () {
      // 🐛 BUG PREVENTED: Old workouts counted in weekly volume
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 4)],
        ),
        _createWorkout(
          daysAgo: 10, // Older than 7 days, should not count
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 3)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySets(workouts);

      // Only recent workout should count
      expect(result[MuscleGroup.chest], 4);
    });

    test('should handle empty workouts list', () {
      // 🐛 BUG PREVENTED: Crash on empty data
      final result = VolumeAnalyzer.calculateWeeklySets([]);

      expect(result[MuscleGroup.chest], 0);
      expect(result[MuscleGroup.back], 0);
      expect(result[MuscleGroup.shoulders], 0);
      expect(result[MuscleGroup.arms], 0);
      expect(result[MuscleGroup.legs], 0);
      expect(result[MuscleGroup.core], 0);
    });

    test('should skip cardio and uncategorized exercises', () {
      // 🐛 BUG PREVENTED: Cardio sets counted as muscle volume
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 4),
            _createExercise('Running', ExerciseCategory.cardio, sets: 1), // Should skip
            _createExercise('Unknown', ExerciseCategory.other, sets: 2), // Should skip
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySets(workouts);

      // Only chest should count
      expect(result[MuscleGroup.chest], 4);
    });

    test('should accumulate sets from multiple workouts', () {
      // 🐛 BUG PREVENTED: Sets not accumulated across workouts
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 3)],
        ),
        _createWorkout(
          daysAgo: 3,
          exercises: [_createExercise('Incline Press', ExerciseCategory.chest, sets: 3)],
        ),
        _createWorkout(
          daysAgo: 5,
          exercises: [_createExercise('Flyes', ExerciseCategory.chest, sets: 2)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySets(workouts);

      expect(result[MuscleGroup.chest], 8); // 3 + 3 + 2
    });
  });

  group('calculateWeeklySetsWithExercises', () {
    test('should return exercises grouped by muscle with set counts', () {
      // 🐛 BUG PREVENTED: Lost exercise-level detail in volume tracking
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 4),
            _createExercise('Squat', ExerciseCategory.legs, sets: 5),
            _createExercise('Pull-ups', ExerciseCategory.back, sets: 3),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises(workouts);

      expect(result.categorized[MuscleGroup.chest]!.length, 1);
      expect(result.categorized[MuscleGroup.chest]!.first.exerciseName, 'Bench Press');
      expect(result.categorized[MuscleGroup.chest]!.first.sets, 4);

      expect(result.categorized[MuscleGroup.legs]!.length, 1);
      expect(result.categorized[MuscleGroup.legs]!.first.sets, 5);

      expect(result.categorized[MuscleGroup.back]!.length, 1);
      expect(result.categorized[MuscleGroup.back]!.first.sets, 3);
    });

    test('should combine sets for same exercise across workouts', () {
      // 🐛 BUG PREVENTED: Duplicate exercise entries instead of combining
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 3)],
        ),
        _createWorkout(
          daysAgo: 4,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 4)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises(workouts);

      expect(result.categorized[MuscleGroup.chest]!.length, 1);
      expect(result.categorized[MuscleGroup.chest]!.first.exerciseName, 'Bench Press');
      expect(result.categorized[MuscleGroup.chest]!.first.sets, 7); // 3 + 4
    });

    test('should handle uncategorized exercises separately', () {
      // 🐛 BUG PREVENTED: Uncategorized exercises lost in analysis
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 4),
            _createExercise('Running', ExerciseCategory.cardio, sets: 1),
            _createExercise('Yoga', ExerciseCategory.other, sets: 1),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises(workouts);

      expect(result.categorized[MuscleGroup.chest]!.length, 1);
      expect(result.uncategorized.length, 2);
      expect(result.uncategorized.any((e) => e.exerciseName == 'Running'), true);
      expect(result.uncategorized.any((e) => e.exerciseName == 'Yoga'), true);
    });

    test('should sort exercises by sets descending', () {
      // 🐛 BUG PREVENTED: Exercises not sorted by volume contribution
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 2),
            _createExercise('Incline Press', ExerciseCategory.chest, sets: 5),
            _createExercise('Flyes', ExerciseCategory.chest, sets: 3),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises(workouts);

      final chestExercises = result.categorized[MuscleGroup.chest]!;
      expect(chestExercises[0].exerciseName, 'Incline Press'); // 5 sets
      expect(chestExercises[1].exerciseName, 'Flyes'); // 3 sets
      expect(chestExercises[2].exerciseName, 'Bench Press'); // 2 sets
    });

    test('should handle empty workouts gracefully', () {
      // 🐛 BUG PREVENTED: Crash on empty data
      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises([]);

      expect(result.categorized[MuscleGroup.chest], isEmpty);
      expect(result.categorized[MuscleGroup.back], isEmpty);
      expect(result.uncategorized, isEmpty);
    });
  });

  group('analyzeRepContinuum', () {
    test('should classify strength sets correctly (1-5 reps)', () {
      // 🐛 BUG PREVENTED: Incorrect rep range classification
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest,
              sets: 3, repsPerSet: [3, 4, 5]),
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.strengthSets, 3);
      expect(result.hypertrophySets, 0);
      expect(result.enduranceSets, 0);
      expect(result.totalSets, 3);
      expect(result.strengthPercentage, 100.0);
    });

    test('should classify hypertrophy sets correctly (6-15 reps)', () {
      // 🐛 BUG PREVENTED: Hypertrophy training not detected
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest,
              sets: 4, repsPerSet: [8, 10, 12, 15]),
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.strengthSets, 0);
      expect(result.hypertrophySets, 4);
      expect(result.enduranceSets, 0);
      expect(result.hypertrophyPercentage, 100.0);
    });

    test('should classify endurance sets correctly (16+ reps)', () {
      // 🐛 BUG PREVENTED: Endurance training not detected
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Leg Press', ExerciseCategory.legs,
              sets: 3, repsPerSet: [16, 20, 25]),
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.strengthSets, 0);
      expect(result.hypertrophySets, 0);
      expect(result.enduranceSets, 3);
      expect(result.endurancePercentage, 100.0);
    });

    test('should handle mixed rep ranges', () {
      // 🐛 BUG PREVENTED: Mixed training not analyzed correctly
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Squat', ExerciseCategory.legs,
              sets: 5, repsPerSet: [3, 5, 10, 12, 20]),
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.strengthSets, 2); // 3, 5 reps
      expect(result.hypertrophySets, 2); // 10, 12 reps
      expect(result.enduranceSets, 1); // 20 reps
      expect(result.totalSets, 5);
      expect(result.strengthPercentage, 40.0);
      expect(result.hypertrophyPercentage, 40.0);
      expect(result.endurancePercentage, 20.0);
    });

    test('should skip sets without rep data', () {
      // 🐛 BUG PREVENTED: Null reps causing crash or incorrect analysis
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest,
              sets: 3, repsPerSet: [10, null, 12]), // Middle set has no reps
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.totalSets, 2); // Only counted sets with reps
      expect(result.hypertrophySets, 2);
    });

    test('should handle empty workouts', () {
      // 🐛 BUG PREVENTED: Division by zero on empty data
      final result = VolumeAnalyzer.analyzeRepContinuum([]);

      expect(result.totalSets, 0);
      expect(result.strengthPercentage, 0.0);
      expect(result.hypertrophyPercentage, 0.0);
      expect(result.endurancePercentage, 0.0);
    });
  });

  group('getVolumeZone', () {
    test('should identify below maintenance volume correctly', () {
      // 🐛 BUG PREVENTED: User losing muscle without warning
      // Chest MV = 6 sets
      final zone = VolumeAnalyzer.getVolumeZone(4, MuscleGroup.chest);

      expect(zone, VolumeZone.belowMaintenance);
    });

    test('should identify maintenance volume correctly', () {
      // 🐛 BUG PREVENTED: User not progressing, needs guidance
      // Chest: MV=6, MEV=10
      final zone1 = VolumeAnalyzer.getVolumeZone(6, MuscleGroup.chest);
      final zone2 = VolumeAnalyzer.getVolumeZone(9, MuscleGroup.chest);

      expect(zone1, VolumeZone.maintenance);
      expect(zone2, VolumeZone.maintenance);
    });

    test('should identify effective volume correctly', () {
      // 🐛 BUG PREVENTED: User training in growth zone not recognized
      // Chest: MEV=10, MAV=18
      final zone1 = VolumeAnalyzer.getVolumeZone(10, MuscleGroup.chest);
      final zone2 = VolumeAnalyzer.getVolumeZone(17, MuscleGroup.chest);

      expect(zone1, VolumeZone.effective);
      expect(zone2, VolumeZone.effective);
    });

    test('should identify optimal volume correctly', () {
      // 🐛 BUG PREVENTED: Peak training zone not recognized
      // Chest: MAV=18, MRV=22
      final zone1 = VolumeAnalyzer.getVolumeZone(18, MuscleGroup.chest);
      final zone2 = VolumeAnalyzer.getVolumeZone(21, MuscleGroup.chest);

      expect(zone1, VolumeZone.optimal);
      expect(zone2, VolumeZone.optimal);
    });

    test('should identify excessive volume correctly', () {
      // 🐛 BUG PREVENTED: Overtraining not flagged
      // Chest MRV = 22 sets
      final zone = VolumeAnalyzer.getVolumeZone(25, MuscleGroup.chest);

      expect(zone, VolumeZone.excessive);
    });

    test('should handle different muscle groups with different landmarks', () {
      // 🐛 BUG PREVENTED: Same volume thresholds applied to all muscles
      // Back has higher thresholds than chest
      final chestZone = VolumeAnalyzer.getVolumeZone(12, MuscleGroup.chest);
      final backZone = VolumeAnalyzer.getVolumeZone(12, MuscleGroup.back);

      // 12 sets for chest = effective (MEV=10, MAV=18)
      expect(chestZone, VolumeZone.effective);
      // 12 sets for back = effective (exactly at MEV=12, MAV=20)
      expect(backZone, VolumeZone.effective);
    });

    test('should handle edge case at exactly MV', () {
      // 🐛 BUG PREVENTED: Boundary condition error
      // Chest MV = 6
      final zone = VolumeAnalyzer.getVolumeZone(6, MuscleGroup.chest);

      expect(zone, VolumeZone.maintenance);
    });

    test('should handle zero volume', () {
      // 🐛 BUG PREVENTED: No training for muscle group
      final zone = VolumeAnalyzer.getVolumeZone(0, MuscleGroup.chest);

      expect(zone, VolumeZone.belowMaintenance);
    });
  });

  group('Data Classes', () {
    test('VolumeLandmarks should store all landmark values', () {
      const landmarks = VolumeLandmarks(
        mv: 6,
        mev: 10,
        mav: 18,
        mrv: 22,
      );

      expect(landmarks.mv, 6);
      expect(landmarks.mev, 10);
      expect(landmarks.mav, 18);
      expect(landmarks.mrv, 22);
    });

    test('RepContinuumData should store all rep data', () {
      final data = RepContinuumData(
        strengthPercentage: 25.0,
        hypertrophyPercentage: 50.0,
        endurancePercentage: 25.0,
        strengthSets: 5,
        hypertrophySets: 10,
        enduranceSets: 5,
        totalSets: 20,
      );

      expect(data.strengthPercentage, 25.0);
      expect(data.hypertrophyPercentage, 50.0);
      expect(data.endurancePercentage, 25.0);
      expect(data.strengthSets, 5);
      expect(data.hypertrophySets, 10);
      expect(data.enduranceSets, 5);
      expect(data.totalSets, 20);
    });

    test('ExerciseContribution should store exercise details', () {
      final contribution = ExerciseContribution(
        exerciseName: 'Bench Press',
        sets: 4,
        workoutDate: DateTime(2024, 1, 1),
        category: ExerciseCategory.chest,
      );

      expect(contribution.exerciseName, 'Bench Press');
      expect(contribution.sets, 4);
      expect(contribution.workoutDate, DateTime(2024, 1, 1));
      expect(contribution.category, ExerciseCategory.chest);
    });
  });
}

// Helper functions

Workout _createWorkout({
  required int daysAgo,
  required List<Exercise> exercises,
}) {
  return Workout(
    id: 'workout-${DateTime.now().millisecondsSinceEpoch}',
    name: 'Test Workout',
    exercises: exercises,
    createdAt: DateTime.now().subtract(Duration(days: daysAgo)),
    updatedAt: DateTime.now().subtract(Duration(days: daysAgo)),
  );
}

Exercise _createExercise(
  String name,
  ExerciseCategory category, {
  required int sets,
  List<int?>? repsPerSet,
}) {
  final setsList = List.generate(sets, (i) {
    final reps = repsPerSet != null && i < repsPerSet.length
        ? repsPerSet[i]
        : 10; // Default to 10 reps

    return ExerciseSet(
      id: 'set-$i',
      setNumber: i,
      reps: reps,
      weight: 100.0,
      isCompleted: true,
    );
  });

  return Exercise(
    id: 'exercise-${DateTime.now().millisecondsSinceEpoch}-${name.hashCode}',
    name: name,
    type: ExerciseType.single,
    category: category,
    sets: setsList,
    notes: null,
  );
}
