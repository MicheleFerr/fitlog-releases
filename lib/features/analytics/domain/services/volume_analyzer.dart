import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/utils/muscle_group_mapper.dart';

/// Volume Analysis Service
///
/// Based on scientific research:
/// - Schoenfeld et al. (2021): Loading Recommendations for Muscle Strength and Hypertrophy
///   https://doi.org/10.1519/JSC.0000000000003932
/// - Bernárdez-Vázquez et al. (2022): Resistance Training Variables
///   https://doi.org/10.3390/healthcare10040674
class VolumeAnalyzer {
  /// Rep range classifications based on Schoenfeld 2021
  static const int strengthMaxReps = 5;
  static const int hypertrophyMinReps = 6;
  static const int hypertrophyMaxReps = 15;
  static const int enduranceMinReps = 16;

  /// Volume Landmarks based on Bernárdez-Vázquez 2022
  /// MV = Maintenance Volume (minimum to maintain muscle)
  /// MEV = Minimum Effective Volume (start seeing gains)
  /// MAV = Maximum Adaptive Volume (optimal for growth)
  /// MRV = Maximum Recoverable Volume (max before overtraining)
  static const Map<MuscleGroup, VolumeLandmarks> defaultLandmarks = {
    MuscleGroup.chest: VolumeLandmarks(mv: 6, mev: 10, mav: 18, mrv: 22),
    MuscleGroup.back: VolumeLandmarks(mv: 8, mev: 12, mav: 20, mrv: 25),
    MuscleGroup.shoulders: VolumeLandmarks(mv: 6, mev: 8, mav: 16, mrv: 20),
    MuscleGroup.arms: VolumeLandmarks(mv: 6, mev: 8, mav: 14, mrv: 18),
    MuscleGroup.legs: VolumeLandmarks(mv: 8, mev: 10, mav: 18, mrv: 22),
    MuscleGroup.core: VolumeLandmarks(mv: 6, mev: 8, mav: 15, mrv: 20),
  };

  /// Calculate weekly sets per muscle group
  static Map<MuscleGroup, int> calculateWeeklySets(List<Workout> workouts) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final recentWorkouts = workouts.where((w) =>
      w.createdAt.isAfter(weekAgo)
    ).toList();

    final setsPerMuscle = <MuscleGroup, int>{
      MuscleGroup.chest: 0,
      MuscleGroup.back: 0,
      MuscleGroup.shoulders: 0,
      MuscleGroup.arms: 0,
      MuscleGroup.legs: 0,
      MuscleGroup.core: 0,
    };

    for (final workout in recentWorkouts) {
      for (final exercise in workout.exercises) {
        final muscleGroup = MuscleGroupMapper.fromExerciseCategory(exercise.category);

        // Skip cardio/other exercises
        if (muscleGroup == null) continue;

        final setsCount = exercise.sets.length;
        setsPerMuscle[muscleGroup] = (setsPerMuscle[muscleGroup] ?? 0) + setsCount;
      }
    }

    return setsPerMuscle;
  }

  /// Calculate weekly sets per muscle group with exercise breakdown
  /// Also returns uncategorized exercises separately
  static ({
    Map<MuscleGroup, List<ExerciseContribution>> categorized,
    List<ExerciseContribution> uncategorized,
  }) calculateWeeklySetsWithExercises(
    List<Workout> workouts,
  ) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final recentWorkouts = workouts.where((w) =>
      w.createdAt.isAfter(weekAgo)
    ).toList();

    final exercisesPerMuscle = <MuscleGroup, List<ExerciseContribution>>{
      MuscleGroup.chest: [],
      MuscleGroup.back: [],
      MuscleGroup.shoulders: [],
      MuscleGroup.arms: [],
      MuscleGroup.legs: [],
      MuscleGroup.core: [],
    };

    final uncategorizedExercises = <ExerciseContribution>[];

    for (final workout in recentWorkouts) {
      for (final exercise in workout.exercises) {
        final muscleGroup = MuscleGroupMapper.fromExerciseCategory(exercise.category);
        final setsCount = exercise.sets.length;

        if (muscleGroup == null) {
          // Track uncategorized exercises separately
          final existingIndex = uncategorizedExercises.indexWhere(
            (e) => e.exerciseName.toLowerCase() == exercise.name.toLowerCase(),
          );

          if (existingIndex != -1) {
            uncategorizedExercises[existingIndex] = ExerciseContribution(
              exerciseName: exercise.name,
              sets: uncategorizedExercises[existingIndex].sets + setsCount,
              workoutDate: workout.createdAt,
              category: exercise.category,
            );
          } else {
            uncategorizedExercises.add(
              ExerciseContribution(
                exerciseName: exercise.name,
                sets: setsCount,
                workoutDate: workout.createdAt,
                category: exercise.category,
              ),
            );
          }
          continue;
        }

        // Check if exercise already exists
        final existingIndex = exercisesPerMuscle[muscleGroup]!.indexWhere(
          (e) => e.exerciseName.toLowerCase() == exercise.name.toLowerCase(),
        );

        if (existingIndex != -1) {
          // Update existing exercise
          exercisesPerMuscle[muscleGroup]![existingIndex] = ExerciseContribution(
            exerciseName: exercise.name,
            sets: exercisesPerMuscle[muscleGroup]![existingIndex].sets + setsCount,
            workoutDate: workout.createdAt,
            category: exercise.category,
          );
        } else {
          // Add new exercise
          exercisesPerMuscle[muscleGroup]!.add(
            ExerciseContribution(
              exerciseName: exercise.name,
              sets: setsCount,
              workoutDate: workout.createdAt,
              category: exercise.category,
            ),
          );
        }
      }
    }

    // Sort by sets descending
    for (final muscle in MuscleGroup.values) {
      exercisesPerMuscle[muscle]!.sort((a, b) => b.sets.compareTo(a.sets));
    }
    uncategorizedExercises.sort((a, b) => b.sets.compareTo(a.sets));

    return (categorized: exercisesPerMuscle, uncategorized: uncategorizedExercises);
  }

  /// Classify rep range distribution
  static RepContinuumData analyzeRepContinuum(List<Workout> workouts) {
    int strengthSets = 0;
    int hypertrophySets = 0;
    int enduranceSets = 0;
    int totalSets = 0;

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        for (final set in exercise.sets) {
          if (set.reps == null) continue;

          totalSets++;

          if (set.reps! <= strengthMaxReps) {
            strengthSets++;
          } else if (set.reps! >= hypertrophyMinReps && set.reps! <= hypertrophyMaxReps) {
            hypertrophySets++;
          } else if (set.reps! >= enduranceMinReps) {
            enduranceSets++;
          }
        }
      }
    }

    final strengthPercentage = totalSets > 0 ? (strengthSets / totalSets * 100) : 0.0;
    final hypertrophyPercentage = totalSets > 0 ? (hypertrophySets / totalSets * 100) : 0.0;
    final endurancePercentage = totalSets > 0 ? (enduranceSets / totalSets * 100) : 0.0;

    return RepContinuumData(
      strengthPercentage: strengthPercentage,
      hypertrophyPercentage: hypertrophyPercentage,
      endurancePercentage: endurancePercentage,
      strengthSets: strengthSets,
      hypertrophySets: hypertrophySets,
      enduranceSets: enduranceSets,
      totalSets: totalSets,
    );
  }

  /// Get volume zone for a muscle group
  static VolumeZone getVolumeZone(int weeklySets, MuscleGroup muscle) {
    final landmarks = defaultLandmarks[muscle]!;

    if (weeklySets < landmarks.mv) {
      return VolumeZone.belowMaintenance;
    } else if (weeklySets >= landmarks.mv && weeklySets < landmarks.mev) {
      return VolumeZone.maintenance;
    } else if (weeklySets >= landmarks.mev && weeklySets < landmarks.mav) {
      return VolumeZone.effective;
    } else if (weeklySets >= landmarks.mav && weeklySets < landmarks.mrv) {
      return VolumeZone.optimal;
    } else {
      return VolumeZone.excessive;
    }
  }
}

/// Volume Landmarks data structure
class VolumeLandmarks { // Maximum Recoverable Volume

  const VolumeLandmarks({
    required this.mv,
    required this.mev,
    required this.mav,
    required this.mrv,
  });
  final int mv;  // Maintenance Volume
  final int mev; // Minimum Effective Volume
  final int mav; // Maximum Adaptive Volume
  final int mrv;
}

/// Rep Continuum analysis result
class RepContinuumData {

  RepContinuumData({
    required this.strengthPercentage,
    required this.hypertrophyPercentage,
    required this.endurancePercentage,
    required this.strengthSets,
    required this.hypertrophySets,
    required this.enduranceSets,
    required this.totalSets,
  });
  final double strengthPercentage;
  final double hypertrophyPercentage;
  final double endurancePercentage;
  final int strengthSets;
  final int hypertrophySets;
  final int enduranceSets;
  final int totalSets;
}

/// Volume zones based on landmarks
enum VolumeZone {
  belowMaintenance, // < MV
  maintenance,      // MV to MEV
  effective,        // MEV to MAV
  optimal,          // MAV to MRV
  excessive,        // > MRV
}

/// Exercise contribution to muscle group volume
class ExerciseContribution {

  ExerciseContribution({
    required this.exerciseName,
    required this.sets,
    required this.workoutDate,
    this.category,
  });
  final String exerciseName;
  final int sets;
  final DateTime workoutDate;
  final ExerciseCategory? category;
}
