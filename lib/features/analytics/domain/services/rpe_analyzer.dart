import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/utils/muscle_group_mapper.dart';

/// RPE & Intensity Analysis Service
///
/// Based on scientific research:
/// - Helms et al. (2018): RPE-Based Training Load Monitoring
///   https://doi.org/10.1519/SSC.0000000000000373
/// - Zourdos et al. (2016): Novel Resistance Training-Specific RPE Scale
///   https://doi.org/10.1519/JSC.0000000000001049
class RPEAnalyzer {
  /// RPE zones based on Helms 2018
  static const int recoveryMaxRPE = 6;    // Recovery/Easy: RPE 5-6
  static const int moderateMinRPE = 7;    // Moderate: RPE 7
  static const int hardMinRPE = 8;        // Hard: RPE 8
  static const int veryHardMinRPE = 9;    // Very Hard: RPE 9
  static const int maximalRPE = 10;       // Maximal: RPE 10

  /// Optimal training distribution (Helms et al. 2018)
  /// For hypertrophy: 70% of sets at RPE 7-9
  /// For strength: 60% of sets at RPE 8-10
  static const double hypertrophyOptimalMin = 0.6;  // 60% minimum
  static const double hypertrophyOptimalMax = 0.8;  // 80% maximum
  static const double strengthOptimalMin = 0.5;     // 50% minimum
  static const double strengthOptimalMax = 0.7;     // 70% maximum

  /// Analyze RPE distribution across workouts
  /// Filters to last 7 days by default to match VolumeAnalyzer
  static RPEDistributionData analyzeRPEDistribution(List<Workout> workouts, {int days = 7}) {
    // Filter workouts to last N days
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentWorkouts = workouts.where((w) => w.createdAt.isAfter(cutoffDate)).toList();

    int recoverySets = 0;      // RPE 5-6
    int moderateSets = 0;      // RPE 7
    int hardSets = 0;          // RPE 8
    int veryHardSets = 0;      // RPE 9
    int maximalSets = 0;       // RPE 10
    int totalSetsWithRPE = 0;

    for (final workout in recentWorkouts) {
      for (final exercise in workout.exercises) {
        for (final set in exercise.sets) {
          // Skip warmup sets and sets without RPE
          if (set.isWarmup || set.rpe == null || !set.isCompleted) continue;

          totalSetsWithRPE++;
          final rpe = set.rpe!;

          if (rpe <= recoveryMaxRPE) {
            recoverySets++;
          } else if (rpe == moderateMinRPE) {
            moderateSets++;
          } else if (rpe == hardMinRPE) {
            hardSets++;
          } else if (rpe == veryHardMinRPE) {
            veryHardSets++;
          } else if (rpe >= maximalRPE) {
            maximalSets++;
          }
        }
      }
    }

    final recoveryPercentage = totalSetsWithRPE > 0 ? (recoverySets / totalSetsWithRPE * 100) : 0.0;
    final moderatePercentage = totalSetsWithRPE > 0 ? (moderateSets / totalSetsWithRPE * 100) : 0.0;
    final hardPercentage = totalSetsWithRPE > 0 ? (hardSets / totalSetsWithRPE * 100) : 0.0;
    final veryHardPercentage = totalSetsWithRPE > 0 ? (veryHardSets / totalSetsWithRPE * 100) : 0.0;
    final maximalPercentage = totalSetsWithRPE > 0 ? (maximalSets / totalSetsWithRPE * 100) : 0.0;

    return RPEDistributionData(
      recoverySets: recoverySets,
      moderateSets: moderateSets,
      hardSets: hardSets,
      veryHardSets: veryHardSets,
      maximalSets: maximalSets,
      totalSetsWithRPE: totalSetsWithRPE,
      recoveryPercentage: recoveryPercentage,
      moderatePercentage: moderatePercentage,
      hardPercentage: hardPercentage,
      veryHardPercentage: veryHardPercentage,
      maximalPercentage: maximalPercentage,
    );
  }

  /// Analyze average RPE per muscle group
  /// Filters to last 7 days by default to match VolumeAnalyzer
  static Map<MuscleGroup, RPEStats> analyzeRPEPerMuscleGroup(List<Workout> workouts, {int days = 7}) {
    // Filter workouts to last N days
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentWorkouts = workouts.where((w) => w.createdAt.isAfter(cutoffDate)).toList();

    final rpeData = <MuscleGroup, List<int>>{
      MuscleGroup.chest: [],
      MuscleGroup.back: [],
      MuscleGroup.shoulders: [],
      MuscleGroup.arms: [],
      MuscleGroup.legs: [],
      MuscleGroup.core: [],
    };

    for (final workout in recentWorkouts) {
      for (final exercise in workout.exercises) {
        final muscleGroup = MuscleGroupMapper.fromExerciseCategory(exercise.category);
        if (muscleGroup == null) continue;

        for (final set in exercise.sets) {
          // Skip warmup sets and sets without RPE
          if (set.isWarmup || set.rpe == null || !set.isCompleted) continue;

          rpeData[muscleGroup]!.add(set.rpe!);
        }
      }
    }

    final stats = <MuscleGroup, RPEStats>{};
    for (final entry in rpeData.entries) {
      if (entry.value.isEmpty) {
        stats[entry.key] = RPEStats(
          averageRPE: 0,
          minRPE: 0,
          maxRPE: 0,
          totalSets: 0,
        );
      } else {
        final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
        final min = entry.value.reduce((a, b) => a < b ? a : b);
        final max = entry.value.reduce((a, b) => a > b ? a : b);

        stats[entry.key] = RPEStats(
          averageRPE: average,
          minRPE: min,
          maxRPE: max,
          totalSets: entry.value.length,
        );
      }
    }

    return stats;
  }

  /// Get training intensity zone
  static IntensityZone getIntensityZone(RPEDistributionData distribution) {
    // Calculate percentage of "productive" sets (RPE 7-9)
    final productivePercentage = distribution.moderatePercentage +
                                  distribution.hardPercentage +
                                  distribution.veryHardPercentage;

    // Calculate percentage of "very hard" sets (RPE 8-10)
    final veryHardPercentage = distribution.hardPercentage +
                               distribution.veryHardPercentage +
                               distribution.maximalPercentage;

    // Too easy: >50% recovery sets
    if (distribution.recoveryPercentage > 50) {
      return IntensityZone.tooEasy;
    }

    // Optimal hypertrophy: 60-80% productive sets
    if (productivePercentage >= hypertrophyOptimalMin * 100 &&
        productivePercentage <= hypertrophyOptimalMax * 100) {
      return IntensityZone.optimalHypertrophy;
    }

    // Optimal strength: 50-70% very hard sets
    if (veryHardPercentage >= strengthOptimalMin * 100 &&
        veryHardPercentage <= strengthOptimalMax * 100) {
      return IntensityZone.optimalStrength;
    }

    // Too hard: >30% maximal sets
    if (distribution.maximalPercentage > 30) {
      return IntensityZone.tooHard;
    }

    // Balanced if nothing above applies
    return IntensityZone.balanced;
  }
}

/// RPE Distribution analysis result
class RPEDistributionData {

  RPEDistributionData({
    required this.recoverySets,
    required this.moderateSets,
    required this.hardSets,
    required this.veryHardSets,
    required this.maximalSets,
    required this.totalSetsWithRPE,
    required this.recoveryPercentage,
    required this.moderatePercentage,
    required this.hardPercentage,
    required this.veryHardPercentage,
    required this.maximalPercentage,
  });
  final int recoverySets;       // RPE 5-6
  final int moderateSets;       // RPE 7
  final int hardSets;           // RPE 8
  final int veryHardSets;       // RPE 9
  final int maximalSets;        // RPE 10
  final int totalSetsWithRPE;

  final double recoveryPercentage;
  final double moderatePercentage;
  final double hardPercentage;
  final double veryHardPercentage;
  final double maximalPercentage;
}

/// RPE statistics per muscle group
class RPEStats {

  RPEStats({
    required this.averageRPE,
    required this.minRPE,
    required this.maxRPE,
    required this.totalSets,
  });
  final double averageRPE;
  final int minRPE;
  final int maxRPE;
  final int totalSets;
}

/// Intensity zones based on RPE distribution
enum IntensityZone {
  tooEasy,              // >50% recovery sets
  optimalHypertrophy,   // 60-80% productive sets (RPE 7-9)
  optimalStrength,      // 50-70% very hard sets (RPE 8-10)
  balanced,             // Good mix
  tooHard,              // >30% maximal sets
}
