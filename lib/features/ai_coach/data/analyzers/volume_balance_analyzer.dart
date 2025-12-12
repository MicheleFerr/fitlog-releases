/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/analyzers
/// 🎯 Feature: ai_coach
/// 🔧 Type: analyzer
///
/// Volume Balance Analyzer - detects muscle group imbalances
/// Extracted from legacy ai_coach_service.dart _analyzeVolumeByMuscleGroup
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/insight_analyzer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

/// Analyzes muscle group volume balance
///
/// Based on scientific evidence:
/// - Schoenfeld & Grgic (2018): Evidence-based guidelines for resistance training volume
/// - Israetel et al. (2017): Volume Landmarks (MEV/MAV/MRV)
///
/// Personalized thresholds by experience level:
/// - Beginner: MEV=8, MAV=15, MRV=20 sets/week per muscle group
/// - Intermediate: MEV=10, MAV=18, MRV=25 sets/week
/// - Advanced: MEV=12, MAV=20, MRV=30 sets/week
class VolumeBalanceAnalyzer implements InsightAnalyzer {
  VolumeBalanceAnalyzer(this._exerciseDatabase);

  final Map<String, Exercise> _exerciseDatabase;

  @override
  InsightType get type => InsightType.muscleGroupBalance;

  @override
  int get basePriority => 2; // Important - address imbalances

  @override
  bool shouldAnalyze(UserContext context) {
    // Available for all tiers (free feature)
    return true;
  }

  @override
  Future<AIInsight?> analyze(
    List<Workout> workouts,
    UserContext context,
  ) async {
    // Require at least 2 weeks of data
    if (workouts.length < 4) return null;

    // Filter last 7 days
    final weeklyWorkouts = workouts.where(
      (w) => w.createdAt.isAfter(
        DateTime.now().subtract(const Duration(days: 7)),
      ),
    ).toList();

    if (weeklyWorkouts.isEmpty) return null;

    // Calculate weekly volume by muscle group
    final volumeByMuscle = _calculateWeeklyVolumeByMuscleGroup(
      weeklyWorkouts,
    );

    // Get personalized thresholds
    final thresholds = _getThresholds(context.experienceLevel);

    // Find undertrained muscles (below MEV)
    final undertrainedMuscles = _findUndertrainedMuscles(
      volumeByMuscle,
      thresholds,
    );

    if (undertrainedMuscles.isNotEmpty) {
      return _createUndertrainedInsight(
        undertrainedMuscles.first,
        volumeByMuscle,
        thresholds,
      );
    }

    // Find overtrained muscles (above MRV)
    final overtrainedMuscles = _findOvertrainedMuscles(
      volumeByMuscle,
      thresholds,
    );

    if (overtrainedMuscles.isNotEmpty) {
      return _createOvertrainedInsight(
        overtrainedMuscles.first,
        volumeByMuscle,
        thresholds,
      );
    }

    // All optimal - return positive feedback (low priority)
    return _createOptimalVolumeInsight(volumeByMuscle, thresholds);
  }

  /// Calculate weekly volume by muscle group from workouts
  Map<String, MuscleGroupVolume> _calculateWeeklyVolumeByMuscleGroup(
    List<Workout> workouts,
  ) {
    final volumeByMuscle = <String, MuscleGroupVolume>{};

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        // Get exercise metadata from database
        final exerciseMeta = _exerciseDatabase[exercise.name];
        if (exerciseMeta == null) continue;

        final primaryMuscles = exerciseMeta.focus;
        if (primaryMuscles.isEmpty) continue;

        // Use first primary muscle group
        final muscleGroup = primaryMuscles.first;

        // Count completed sets
        final completedSets = exercise.sets.where((s) => s.isCompleted).length;

        if (!volumeByMuscle.containsKey(muscleGroup)) {
          volumeByMuscle[muscleGroup] = const MuscleGroupVolume(
            muscleGroup: '',
            totalSets: 0,
            exercises: [],
          );
        }

        volumeByMuscle[muscleGroup] = MuscleGroupVolume(
          muscleGroup: muscleGroup,
          totalSets: volumeByMuscle[muscleGroup]!.totalSets + completedSets,
          exercises: [
            ...volumeByMuscle[muscleGroup]!.exercises,
            exercise.name,
          ],
        );
      }
    }

    return volumeByMuscle;
  }

  /// Get personalized thresholds based on experience level
  VolumeThresholds _getThresholds(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return const VolumeThresholds(mev: 8, mav: 15, mrv: 20);
      case ExperienceLevel.intermediate:
        return const VolumeThresholds(mev: 10, mav: 18, mrv: 25);
      case ExperienceLevel.advanced:
        return const VolumeThresholds(mev: 12, mav: 20, mrv: 30);
    }
  }

  /// Find undertrained muscles (below MEV)
  List<String> _findUndertrainedMuscles(
    Map<String, MuscleGroupVolume> volumeByMuscle,
    VolumeThresholds thresholds,
  ) {
    return volumeByMuscle.entries
        .where((e) => e.value.totalSets < thresholds.mev)
        .map((e) => e.key)
        .toList();
  }

  /// Find overtrained muscles (above MRV)
  List<String> _findOvertrainedMuscles(
    Map<String, MuscleGroupVolume> volumeByMuscle,
    VolumeThresholds thresholds,
  ) {
    return volumeByMuscle.entries
        .where((e) => e.value.totalSets > thresholds.mrv)
        .map((e) => e.key)
        .toList();
  }

  /// Create insight for undertrained muscle
  AIInsight _createUndertrainedInsight(
    String muscleGroup,
    Map<String, MuscleGroupVolume> volumeByMuscle,
    VolumeThresholds thresholds,
  ) {
    final volume = volumeByMuscle[muscleGroup]!;
    final deficit = thresholds.mev - volume.totalSets;

    return AIInsight(
      id: 'volume_balance_undertrained_${muscleGroup}_${DateTime.now().millisecondsSinceEpoch}',
      type: InsightType.muscleGroupBalance,
      severity: InsightSeverity.medium,
      title: 'Muscle Group Imbalance Detected',
      description: 'Your $muscleGroup training volume is below the minimum effective threshold (${volume.totalSets} sets vs. recommended ${thresholds.mev}+ sets/week).',
      recommendation: 'Increase $muscleGroup training by adding $deficit sets per week. Consider adding 1-2 more exercises or increasing sets per exercise.',
      priority: basePriority,
      affectedExercise: null,
      affectedTemplates: null,
      scientificStrategies: [
        'Increase frequency: Train $muscleGroup 2-3x per week instead of 1x',
        'Prioritize weak muscles: Do $muscleGroup exercises first when fresh',
        'Add isolation exercises: Target $muscleGroup with focused movements',
      ],
      dataPoints: {
        'muscleGroup': muscleGroup,
        'currentSets': volume.totalSets,
        'recommendedMEV': thresholds.mev,
        'recommendedMAV': thresholds.mav,
        'deficit': deficit,
        'exercises': volume.exercises.take(3).join(', '),
      },
      timestamp: DateTime.now(),
    );
  }

  /// Create insight for overtrained muscle
  AIInsight _createOvertrainedInsight(
    String muscleGroup,
    Map<String, MuscleGroupVolume> volumeByMuscle,
    VolumeThresholds thresholds,
  ) {
    final volume = volumeByMuscle[muscleGroup]!;
    final excess = volume.totalSets - thresholds.mrv;

    return AIInsight(
      id: 'volume_balance_overtrained_${muscleGroup}_${DateTime.now().millisecondsSinceEpoch}',
      type: InsightType.volumeOptimization,
      severity: InsightSeverity.high, // High priority - overtraining risk
      title: 'High Volume Alert',
      description: 'Your $muscleGroup training volume is above maximum recoverable threshold (${volume.totalSets} sets vs. recommended max ${thresholds.mrv} sets/week). Risk of overtraining.',
      recommendation: 'Reduce $muscleGroup volume by $excess sets per week. Consider deload week or spreading volume across more days.',
      priority: 1, // Critical - overtraining prevention
      affectedExercise: null,
      affectedTemplates: null,
      scientificStrategies: [
        'Reduce gradually: Cut 2-3 sets per week until at MRV (${thresholds.mrv} sets)',
        'Deload week: Reduce volume by 40-50% for one week to recover',
        'Increase frequency: Spread ${volume.totalSets} sets across more days for better recovery',
      ],
      dataPoints: {
        'muscleGroup': muscleGroup,
        'currentSets': volume.totalSets,
        'recommendedMRV': thresholds.mrv,
        'recommendedMAV': thresholds.mav,
        'excess': excess,
        'exercises': volume.exercises.take(3).join(', '),
        'overtrainingRisk': 'High',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Create positive feedback for optimal volume
  AIInsight _createOptimalVolumeInsight(
    Map<String, MuscleGroupVolume> volumeByMuscle,
    VolumeThresholds thresholds,
  ) {
    final optimalMuscles = volumeByMuscle.entries
        .where((e) =>
          e.value.totalSets >= thresholds.mev &&
          e.value.totalSets <= thresholds.mav
        )
        .toList();

    if (optimalMuscles.isEmpty) {
      // Calculate total sets across all muscle groups
      final totalSets = volumeByMuscle.values.fold<int>(
        0, (sum, v) => sum + v.totalSets,
      );
      final muscleCount = volumeByMuscle.length;

      return AIInsight(
        id: 'volume_balance_neutral_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.motivational,
        severity: InsightSeverity.low,
        title: 'Keep Training!',
        description: 'Continue tracking your volume to optimize muscle growth.',
        recommendation: 'Aim for ${thresholds.mev}-${thresholds.mav} sets per muscle group per week.',
        priority: 5,
        dataPoints: {
          'muscleGroup': 'all muscles',
          'currentSets': totalSets,
          'muscleGroupCount': muscleCount,
          'recommendedMEV': thresholds.mev,
          'recommendedMAV': thresholds.mav,
        },
        timestamp: DateTime.now(),
      );
    }

    final muscle = optimalMuscles.first.key;
    final sets = optimalMuscles.first.value.totalSets;

    return AIInsight(
      id: 'volume_balance_optimal_${muscle}_${DateTime.now().millisecondsSinceEpoch}',
      type: InsightType.motivational,
      severity: InsightSeverity.low,
      title: 'Optimal Volume!',
      description: 'Your $muscle training volume is in the optimal range ($sets sets/week). This maximizes muscle growth while ensuring recovery.',
      recommendation: 'Maintain this volume. Consider tracking other muscle groups to ensure balanced development.',
      priority: 4, // Low priority - positive feedback
      dataPoints: {
        'muscleGroup': muscle,
        'currentSets': sets,
        'optimalMuscles': optimalMuscles.length,
        'MAV': thresholds.mav,
      },
      timestamp: DateTime.now(),
    );
  }
}

/// Volume data for a muscle group
class MuscleGroupVolume {
  const MuscleGroupVolume({
    required this.muscleGroup,
    required this.totalSets,
    required this.exercises,
  });

  final String muscleGroup;
  final int totalSets;
  final List<String> exercises;

  bool isOptimal(VolumeThresholds thresholds) =>
      totalSets >= thresholds.mev && totalSets <= thresholds.mav;
}

/// Volume thresholds (MEV/MAV/MRV)
class VolumeThresholds {
  const VolumeThresholds({
    required this.mev,
    required this.mav,
    required this.mrv,
  });

  final int mev; // Minimum Effective Volume
  final int mav; // Maximum Adaptive Volume
  final int mrv; // Maximum Recoverable Volume
}
