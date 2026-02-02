import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/utils/muscle_group_mapper.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/emg_movement_ratios.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';

/// Volume Analysis Service
///
/// Based on scientific research:
/// - Schoenfeld et al. (2021): Loading Recommendations for Muscle Strength and Hypertrophy
///   https://doi.org/10.1519/JSC.0000000000003932
/// - Bernárdez-Vázquez et al. (2022): Resistance Training Variables
///   https://doi.org/10.3390/healthcare10040674
/// - EMG studies: Rodríguez-Ridao et al. (2020) - Bench Press Muscle Activation
///   https://pmc.ncbi.nlm.nih.gov/articles/PMC7579505/
///
/// Volume distribution (based on EMG research):
/// - Uses dynamic ratios from EmgMovementRatios based on movement pattern
/// - Primary muscles: ~60-75% depending on movement pattern
/// - Secondary muscles: tiered distribution (high synergist vs moderate synergists)
class VolumeAnalyzer {
  /// @deprecated Use EmgMovementRatios.getTieredRatios() for dynamic ratios
  /// Kept for backward compatibility with simple calculations
  static const double primaryMuscleWeight = 0.7;

  /// @deprecated Use EmgMovementRatios.getTieredRatios() for dynamic ratios
  static const double secondaryMuscleWeight = 0.3;

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

    final recentWorkouts = workouts
        .where((w) => w.createdAt.isAfter(weekAgo))
        .toList();

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
        final muscleGroup = MuscleGroupMapper.fromExerciseCategory(
          exercise.category,
        );

        // Skip cardio/other exercises
        if (muscleGroup == null) continue;

        final setsCount = exercise.sets.length;
        setsPerMuscle[muscleGroup] =
            (setsPerMuscle[muscleGroup] ?? 0) + setsCount;
      }
    }

    return setsPerMuscle;
  }

  /// Calculate weekly sets per muscle group with weighted distribution
  ///
  /// Uses focus/secondary muscles from exercise database for accurate tracking:
  /// - Primary muscles (focus): receive 70% of each set
  /// - Secondary muscles: share 30% of each set (split evenly)
  ///
  /// Falls back to ExerciseCategory when muscle data is not available.
  ///
  /// Parameters:
  /// - [workouts]: List of workouts to analyze
  /// - [exerciseMuscleMap]: Map of exercise name → muscle data (primary + secondary)
  ///
  /// Returns: Map of MuscleGroup → weighted set count (as double for precision)
  static Map<MuscleGroup, double> calculateWeeklySetsWeighted(
    List<Workout> workouts, {
    Map<String, ExerciseMuscleData>? exerciseMuscleMap,
  }) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final recentWorkouts = workouts
        .where((w) => w.createdAt.isAfter(weekAgo))
        .toList();

    final setsPerMuscle = <MuscleGroup, double>{
      MuscleGroup.chest: 0.0,
      MuscleGroup.back: 0.0,
      MuscleGroup.shoulders: 0.0,
      MuscleGroup.arms: 0.0,
      MuscleGroup.legs: 0.0,
      MuscleGroup.core: 0.0,
    };

    for (final workout in recentWorkouts) {
      for (final exercise in workout.exercises) {
        final setsCount = exercise.sets.length.toDouble();
        if (setsCount <= 0) continue;

        // Try to get muscle data from the map
        // Use case-insensitive lookup: try exact match, then lowercase
        final muscleData =
            exerciseMuscleMap?[exercise.name] ??
            exerciseMuscleMap?[exercise.name.toLowerCase()];

        if (muscleData != null && muscleData.hasData) {
          // Use EMG-based weighted distribution based on focus/secondary muscles
          _distributeWeightedSets(
            setsPerMuscle: setsPerMuscle,
            muscleData: muscleData,
            setsCount: setsCount,
            exerciseName: exercise.name,
          );
        } else {
          // Fallback to category-based assignment (100% to primary group)
          final muscleGroup = MuscleGroupMapper.fromExerciseCategory(
            exercise.category,
          );
          if (muscleGroup != null) {
            setsPerMuscle[muscleGroup] =
                (setsPerMuscle[muscleGroup] ?? 0) + setsCount;
          }
        }
      }
    }

    return setsPerMuscle;
  }

  /// Internal method to distribute sets across muscle groups with EMG-based weighting
  ///
  /// Uses tiered synergist distribution:
  /// - First synergist gets highSynergistRatio
  /// - Remaining synergists split moderateSynergistRatio
  static void _distributeWeightedSets({
    required Map<MuscleGroup, double> setsPerMuscle,
    required ExerciseMuscleData muscleData,
    required double setsCount,
    String exerciseName = '',
  }) {
    final primaryGroups = MuscleGroupMapper.fromMuscleAbbreviations(
      muscleData.primary,
    );
    final secondaryGroups = MuscleGroupMapper.fromMuscleAbbreviations(
      muscleData.secondary,
    );

    // If no muscles found, skip
    if (primaryGroups.isEmpty && secondaryGroups.isEmpty) return;

    // Get movement pattern for EMG-based ratios
    final movementPattern = muscleData.fileCategory.isNotEmpty
        ? EmgMovementRatios.fromPatternMovimento(
            muscleData.fileCategory,
            exerciseName: exerciseName.isNotEmpty
                ? exerciseName
                : muscleData.exerciseName,
          )
        : EmgMovementRatios.inferPattern(
            fileCategory: muscleData.fileCategory,
            exerciseName: exerciseName.isNotEmpty
                ? exerciseName
                : muscleData.exerciseName,
            focusMuscle: muscleData.primary.isNotEmpty
                ? muscleData.primary.first
                : null,
          );

    // Get EMG-based tiered ratios
    final (primaryRatio, highSynergistRatio, moderateSynergistRatio) =
        EmgMovementRatios.getTieredRatios(movementPattern);

    // Calculate distribution
    if (primaryGroups.isEmpty && secondaryGroups.isNotEmpty) {
      // Only secondary (rare): 100% to secondary
      final setsPerSecondary = setsCount / secondaryGroups.length;
      for (final group in secondaryGroups) {
        setsPerMuscle[group] = (setsPerMuscle[group] ?? 0) + setsPerSecondary;
      }
      return;
    }

    // Distribute to primary muscle groups
    final primarySets = secondaryGroups.isNotEmpty
        ? setsCount * primaryRatio
        : setsCount;

    if (primaryGroups.isNotEmpty) {
      final setsPerPrimary = primarySets / primaryGroups.length;
      for (final group in primaryGroups) {
        setsPerMuscle[group] = (setsPerMuscle[group] ?? 0) + setsPerPrimary;
      }
    }

    // Distribute to secondary muscle groups with tiered approach
    if (secondaryGroups.isNotEmpty) {
      // First synergist gets highSynergistRatio
      final firstSynergistSets = setsCount * highSynergistRatio;
      setsPerMuscle[secondaryGroups.first] =
          (setsPerMuscle[secondaryGroups.first] ?? 0) + firstSynergistSets;

      // Remaining synergists split moderateSynergistRatio
      if (secondaryGroups.length > 1) {
        final remainingGroups = secondaryGroups.sublist(1);
        final moderateSets = setsCount * moderateSynergistRatio;
        final setsPerModerate = moderateSets / remainingGroups.length;
        for (final group in remainingGroups) {
          setsPerMuscle[group] = (setsPerMuscle[group] ?? 0) + setsPerModerate;
        }
      }
    }
  }

  /// Calculate weekly sets per muscle group with exercise breakdown (weighted)
  ///
  /// Uses focus/secondary muscles for accurate tracking with 70/30 distribution.
  /// Also returns uncategorized exercises separately.
  ///
  /// Parameters:
  /// - [workouts]: List of workouts to analyze
  /// - [exerciseMuscleMap]: Map of exercise name → muscle data (primary + secondary)
  static ({
    Map<MuscleGroup, List<ExerciseContributionWeighted>> categorized,
    List<ExerciseContributionWeighted> uncategorized,
    Map<MuscleGroup, double> totalWeightedSets,
  })
  calculateWeeklySetsWithExercisesWeighted(
    List<Workout> workouts, {
    Map<String, ExerciseMuscleData>? exerciseMuscleMap,
  }) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final recentWorkouts = workouts
        .where((w) => w.createdAt.isAfter(weekAgo))
        .toList();

    final exercisesPerMuscle =
        <MuscleGroup, List<ExerciseContributionWeighted>>{
          MuscleGroup.chest: [],
          MuscleGroup.back: [],
          MuscleGroup.shoulders: [],
          MuscleGroup.arms: [],
          MuscleGroup.legs: [],
          MuscleGroup.core: [],
        };

    final totalWeightedSets = <MuscleGroup, double>{
      MuscleGroup.chest: 0.0,
      MuscleGroup.back: 0.0,
      MuscleGroup.shoulders: 0.0,
      MuscleGroup.arms: 0.0,
      MuscleGroup.legs: 0.0,
      MuscleGroup.core: 0.0,
    };

    final uncategorizedExercises = <ExerciseContributionWeighted>[];

    for (final workout in recentWorkouts) {
      for (final exercise in workout.exercises) {
        final rawSetsCount = exercise.sets.length;
        if (rawSetsCount <= 0) continue;

        // Try to get muscle data from the map
        // Use case-insensitive lookup: try exact match, then lowercase
        final muscleData =
            exerciseMuscleMap?[exercise.name] ??
            exerciseMuscleMap?[exercise.name.toLowerCase()];

        if (muscleData != null && muscleData.hasData) {
          // Distribute to multiple muscle groups with EMG-based weighting
          final distribution = _calculateExerciseDistribution(
            muscleData: muscleData,
            rawSets: rawSetsCount,
            exerciseName: exercise.name,
          );

          for (final entry in distribution.entries) {
            final group = entry.key;
            final weightedSets = entry.value.weightedSets;
            final isPrimary = entry.value.isPrimary;

            totalWeightedSets[group] =
                (totalWeightedSets[group] ?? 0) + weightedSets;

            // Find or create contribution
            final existingIndex = exercisesPerMuscle[group]!.indexWhere(
              (e) =>
                  e.exerciseName.toLowerCase() == exercise.name.toLowerCase(),
            );

            if (existingIndex != -1) {
              exercisesPerMuscle[group]![existingIndex] =
                  ExerciseContributionWeighted(
                    exerciseName: exercise.name,
                    rawSets:
                        exercisesPerMuscle[group]![existingIndex].rawSets +
                        rawSetsCount,
                    weightedSets:
                        exercisesPerMuscle[group]![existingIndex].weightedSets +
                        weightedSets,
                    workoutDate: workout.createdAt,
                    category: exercise.category,
                    isPrimary: isPrimary,
                  );
            } else {
              exercisesPerMuscle[group]!.add(
                ExerciseContributionWeighted(
                  exerciseName: exercise.name,
                  rawSets: rawSetsCount,
                  weightedSets: weightedSets,
                  workoutDate: workout.createdAt,
                  category: exercise.category,
                  isPrimary: isPrimary,
                ),
              );
            }
          }
        } else {
          // Fallback to category-based assignment
          final muscleGroup = MuscleGroupMapper.fromExerciseCategory(
            exercise.category,
          );

          if (muscleGroup != null) {
            final weightedSets = rawSetsCount.toDouble();
            totalWeightedSets[muscleGroup] =
                (totalWeightedSets[muscleGroup] ?? 0) + weightedSets;

            final existingIndex = exercisesPerMuscle[muscleGroup]!.indexWhere(
              (e) =>
                  e.exerciseName.toLowerCase() == exercise.name.toLowerCase(),
            );

            if (existingIndex != -1) {
              exercisesPerMuscle[muscleGroup]![existingIndex] =
                  ExerciseContributionWeighted(
                    exerciseName: exercise.name,
                    rawSets:
                        exercisesPerMuscle[muscleGroup]![existingIndex]
                            .rawSets +
                        rawSetsCount,
                    weightedSets:
                        exercisesPerMuscle[muscleGroup]![existingIndex]
                            .weightedSets +
                        weightedSets,
                    workoutDate: workout.createdAt,
                    category: exercise.category,
                    isPrimary: true,
                  );
            } else {
              exercisesPerMuscle[muscleGroup]!.add(
                ExerciseContributionWeighted(
                  exerciseName: exercise.name,
                  rawSets: rawSetsCount,
                  weightedSets: weightedSets,
                  workoutDate: workout.createdAt,
                  category: exercise.category,
                  isPrimary: true,
                ),
              );
            }
          } else {
            // Track uncategorized exercises
            final existingIndex = uncategorizedExercises.indexWhere(
              (e) =>
                  e.exerciseName.toLowerCase() == exercise.name.toLowerCase(),
            );

            if (existingIndex != -1) {
              uncategorizedExercises[existingIndex] =
                  ExerciseContributionWeighted(
                    exerciseName: exercise.name,
                    rawSets:
                        uncategorizedExercises[existingIndex].rawSets +
                        rawSetsCount,
                    weightedSets:
                        uncategorizedExercises[existingIndex].weightedSets +
                        rawSetsCount.toDouble(),
                    workoutDate: workout.createdAt,
                    category: exercise.category,
                    isPrimary: true,
                  );
            } else {
              uncategorizedExercises.add(
                ExerciseContributionWeighted(
                  exerciseName: exercise.name,
                  rawSets: rawSetsCount,
                  weightedSets: rawSetsCount.toDouble(),
                  workoutDate: workout.createdAt,
                  category: exercise.category,
                  isPrimary: true,
                ),
              );
            }
          }
        }
      }
    }

    // Sort by weighted sets descending
    for (final muscle in MuscleGroup.values) {
      exercisesPerMuscle[muscle]!.sort(
        (a, b) => b.weightedSets.compareTo(a.weightedSets),
      );
    }
    uncategorizedExercises.sort(
      (a, b) => b.weightedSets.compareTo(a.weightedSets),
    );

    return (
      categorized: exercisesPerMuscle,
      uncategorized: uncategorizedExercises,
      totalWeightedSets: totalWeightedSets,
    );
  }

  /// Calculate distribution of an exercise across muscle groups
  ///
  /// Uses EMG-based tiered synergist distribution:
  /// - First synergist gets highSynergistRatio
  /// - Remaining synergists split moderateSynergistRatio
  static Map<MuscleGroup, ({double weightedSets, bool isPrimary})>
  _calculateExerciseDistribution({
    required ExerciseMuscleData muscleData,
    required int rawSets,
    String exerciseName = '',
  }) {
    final distribution =
        <MuscleGroup, ({double weightedSets, bool isPrimary})>{};
    final setsCount = rawSets.toDouble();

    final primaryGroups = MuscleGroupMapper.fromMuscleAbbreviations(
      muscleData.primary,
    );
    final secondaryGroups = MuscleGroupMapper.fromMuscleAbbreviations(
      muscleData.secondary,
    );

    // If no muscles found, return empty
    if (primaryGroups.isEmpty && secondaryGroups.isEmpty) return distribution;

    // Get movement pattern for EMG-based ratios
    final movementPattern = muscleData.fileCategory.isNotEmpty
        ? EmgMovementRatios.fromPatternMovimento(
            muscleData.fileCategory,
            exerciseName: exerciseName.isNotEmpty
                ? exerciseName
                : muscleData.exerciseName,
          )
        : EmgMovementRatios.inferPattern(
            fileCategory: muscleData.fileCategory,
            exerciseName: exerciseName.isNotEmpty
                ? exerciseName
                : muscleData.exerciseName,
            focusMuscle: muscleData.primary.isNotEmpty
                ? muscleData.primary.first
                : null,
          );

    // Get EMG-based tiered ratios
    final (primaryRatio, highSynergistRatio, moderateSynergistRatio) =
        EmgMovementRatios.getTieredRatios(movementPattern);

    // Handle case where only secondary exists
    if (primaryGroups.isEmpty && secondaryGroups.isNotEmpty) {
      final setsPerSecondary = setsCount / secondaryGroups.length;
      for (final group in secondaryGroups) {
        distribution[group] = (
          weightedSets: setsPerSecondary,
          isPrimary: false,
        );
      }
      return distribution;
    }

    // Calculate distribution based on whether secondaries exist
    final primarySets = secondaryGroups.isNotEmpty
        ? setsCount * primaryRatio
        : setsCount;

    // Add primary groups
    if (primaryGroups.isNotEmpty) {
      final setsPerPrimary = primarySets / primaryGroups.length;
      for (final group in primaryGroups) {
        distribution[group] = (weightedSets: setsPerPrimary, isPrimary: true);
      }
    }

    // Add secondary groups with tiered distribution
    if (secondaryGroups.isNotEmpty) {
      // First synergist gets highSynergistRatio
      final firstSynergistSets = setsCount * highSynergistRatio;
      final firstGroup = secondaryGroups.first;
      if (distribution.containsKey(firstGroup)) {
        final existing = distribution[firstGroup]!;
        distribution[firstGroup] = (
          weightedSets: existing.weightedSets + firstSynergistSets,
          isPrimary: existing.isPrimary,
        );
      } else {
        distribution[firstGroup] = (
          weightedSets: firstSynergistSets,
          isPrimary: false,
        );
      }

      // Remaining synergists split moderateSynergistRatio
      if (secondaryGroups.length > 1) {
        final remainingGroups = secondaryGroups.sublist(1);
        final moderateSets = setsCount * moderateSynergistRatio;
        final setsPerModerate = moderateSets / remainingGroups.length;
        for (final group in remainingGroups) {
          if (distribution.containsKey(group)) {
            final existing = distribution[group]!;
            distribution[group] = (
              weightedSets: existing.weightedSets + setsPerModerate,
              isPrimary: existing.isPrimary,
            );
          } else {
            distribution[group] = (
              weightedSets: setsPerModerate,
              isPrimary: false,
            );
          }
        }
      }
    }

    return distribution;
  }

  /// Calculate weekly sets per muscle group with exercise breakdown
  /// Also returns uncategorized exercises separately
  static ({
    Map<MuscleGroup, List<ExerciseContribution>> categorized,
    List<ExerciseContribution> uncategorized,
  })
  calculateWeeklySetsWithExercises(List<Workout> workouts) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final recentWorkouts = workouts
        .where((w) => w.createdAt.isAfter(weekAgo))
        .toList();

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
        final muscleGroup = MuscleGroupMapper.fromExerciseCategory(
          exercise.category,
        );
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
          exercisesPerMuscle[muscleGroup]![existingIndex] =
              ExerciseContribution(
                exerciseName: exercise.name,
                sets:
                    exercisesPerMuscle[muscleGroup]![existingIndex].sets +
                    setsCount,
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

    return (
      categorized: exercisesPerMuscle,
      uncategorized: uncategorizedExercises,
    );
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
          } else if (set.reps! >= hypertrophyMinReps &&
              set.reps! <= hypertrophyMaxReps) {
            hypertrophySets++;
          } else if (set.reps! >= enduranceMinReps) {
            enduranceSets++;
          }
        }
      }
    }

    final strengthPercentage = totalSets > 0
        ? (strengthSets / totalSets * 100)
        : 0.0;
    final hypertrophyPercentage = totalSets > 0
        ? (hypertrophySets / totalSets * 100)
        : 0.0;
    final endurancePercentage = totalSets > 0
        ? (enduranceSets / totalSets * 100)
        : 0.0;

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
class VolumeLandmarks {
  // Maximum Recoverable Volume

  const VolumeLandmarks({
    required this.mv,
    required this.mev,
    required this.mav,
    required this.mrv,
  });
  final int mv; // Maintenance Volume
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
  maintenance, // MV to MEV
  effective, // MEV to MAV
  optimal, // MAV to MRV
  excessive, // > MRV
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

/// Exercise contribution with weighted set distribution
///
/// Tracks both raw sets and weighted contribution based on:
/// - Primary muscles: 70% weight
/// - Secondary muscles: 30% weight (split among them)
class ExerciseContributionWeighted {
  ExerciseContributionWeighted({
    required this.exerciseName,
    required this.rawSets,
    required this.weightedSets,
    required this.workoutDate,
    required this.isPrimary,
    this.category,
  });

  /// Exercise name
  final String exerciseName;

  /// Raw number of sets performed
  final int rawSets;

  /// Weighted set contribution (e.g., 3 sets × 0.7 = 2.1 for primary)
  final double weightedSets;

  /// Most recent workout date
  final DateTime workoutDate;

  /// Exercise category (if available)
  final ExerciseCategory? category;

  /// Whether this exercise targets this muscle group as primary
  final bool isPrimary;

  /// Display string showing raw and weighted sets
  String get displaySets {
    if (rawSets == weightedSets.round()) {
      return '$rawSets sets';
    }
    return '${weightedSets.toStringAsFixed(1)} sets (${rawSets} raw)';
  }
}
