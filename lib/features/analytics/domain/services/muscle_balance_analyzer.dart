import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_calculator.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';

/// Scientific muscle group balance analyzer
///
/// Based on:
/// - Croisier et al. (2008): Hamstring:Quad ratio <0.6 = 17x injury risk
/// - Boyle (2016): Push:Pull ratio recommendations for posture
/// - Wilk et al. (2009): Shoulder rotation ratios for overhead athletes
class MuscleBalanceAnalyzer {
  /// Analyze Push:Pull volume ratio
  ///
  /// Scientific Target: 1:1 to 2:3 (Pull emphasis)
  /// Rationale: Postural health, shoulder stability (Boyle, 2016)
  static PushPullBalance analyzePushPullBalance(
    List<ExerciseActivity> activities,
  ) {
    int pushSets = 0;
    int pullSets = 0;
    double pushVolume = 0;
    double pullVolume = 0;

    final pushGroups = {'Chest', 'Shoulders'}; // Anterior chain
    final pullGroups = {'Back'}; // Posterior chain

    for (final activity in activities) {
      // **Uses SSOT**: MuscleAbbreviationMapper.categorizeExerciseByName
      final muscleGroup = MuscleAbbreviationMapper.categorizeExerciseByName(
        activity.exerciseName,
      );
      final volume = VolumeCalculator.calculateTotalVolume(activity.sets);
      final setCount = activity.sets.where((s) => s.done).length;

      if (pushGroups.contains(muscleGroup)) {
        pushSets += setCount;
        pushVolume += volume;
      } else if (pullGroups.contains(muscleGroup)) {
        pullSets += setCount;
        pullVolume += volume;
      }
    }

    final ratio = pullSets > 0 ? pushSets / pullSets : 0.0;

    return PushPullBalance(
      pushSets: pushSets,
      pullSets: pullSets,
      pushVolume: pushVolume,
      pullVolume: pullVolume,
      ratio: ratio.toDouble(),
    );
  }

  /// Analyze Quad:Hamstring volume ratio
  ///
  /// Scientific Target: 0.6-1.0 (Hamstring ≥ 60% of Quad)
  /// Red Flag: <0.5 (Croisier et al., 2008 - hamstring injury risk 17x)
  static QuadHamstringBalance analyzeQuadHamstringBalance(
    List<ExerciseActivity> activities,
  ) {
    int quadSets = 0;
    int hamstringSets = 0;
    double quadVolume = 0;
    double hamstringVolume = 0;

    for (final activity in activities) {
      final name = activity.exerciseName.toLowerCase();
      final volume = VolumeCalculator.calculateTotalVolume(activity.sets);
      final setCount = activity.sets.where((s) => s.done).length;

      // Quad-dominant exercises
      if (name.contains('squat') && !name.contains('rdl') ||
          name.contains('leg press') ||
          name.contains('leg extension') ||
          name.contains('quad') ||
          name.contains('lunge')) {
        quadSets += setCount;
        quadVolume += volume;
      }

      // Hamstring-dominant exercises
      if (name.contains('deadlift') ||
          name.contains('rdl') ||
          name.contains('romanian') ||
          name.contains('hamstring') ||
          name.contains('leg curl') ||
          name.contains('nordic') ||
          name.contains('good morning')) {
        hamstringSets += setCount;
        hamstringVolume += volume;
      }
    }

    final ratio = quadSets > 0 ? hamstringSets / quadSets : 0.0;

    return QuadHamstringBalance(
      quadSets: quadSets,
      hamstringSets: hamstringSets,
      quadVolume: quadVolume,
      hamstringVolume: hamstringVolume,
      ratio: ratio.toDouble(),
    );
  }

  /// Analyze overall muscle group distribution
  static MuscleDistribution analyzeDistribution(
    List<ExerciseActivity> activities,
  ) {
    final volumeByGroup = VolumeCalculator.calculateVolumeByMuscleGroup(
      activities,
    );
    final totalVolume = volumeByGroup.values.fold(0.0, (sum, v) => sum + v);

    if (totalVolume == 0) {
      return MuscleDistribution.empty();
    }

    // Calculate percentage distribution
    final distribution = <String, double>{};
    for (final entry in volumeByGroup.entries) {
      distribution[entry.key] = (entry.value / totalVolume) * 100;
    }

    return MuscleDistribution(
      volumeByGroup: volumeByGroup,
      percentageDistribution: distribution,
      totalVolume: totalVolume,
    );
  }

  /// Get balance feedback key based on scientific thresholds
  /// Returns localization key to be translated by AppLocalizations
  static String getPushPullFeedback(double ratio) {
    if (ratio < 0.5) {
      return 'feedbackTooMuchPull';
    } else if (ratio > 1.2) {
      return 'feedbackTooMuchPush';
    } else if (ratio > 1.0) {
      return 'feedbackSlightPushExcess';
    } else if (ratio >= 0.8) {
      return 'feedbackOptimalPushPull';
    } else {
      return 'feedbackGoodPullEmphasis';
    }
  }

  static String getQuadHamFeedback(double ratio) {
    if (ratio < 0.5) {
      return 'feedbackHamstringSeverelyUndertrained';
    } else if (ratio < 0.6) {
      return 'feedbackHamstringUndertrained';
    } else if (ratio >= 0.6 && ratio <= 1.0) {
      return 'feedbackOptimalQuadHam';
    } else {
      return 'feedbackHamstringOveremphasized';
    }
  }
}

/// Push:Pull balance data
class PushPullBalance {
  // Push:Pull ratio

  PushPullBalance({
    required this.pushSets,
    required this.pullSets,
    required this.pushVolume,
    required this.pullVolume,
    required this.ratio,
  });
  final int pushSets;
  final int pullSets;
  final double pushVolume;
  final double pullVolume;
  final double ratio;

  bool get isBalanced => ratio >= 0.67 && ratio <= 1.0;

  String get status {
    if (ratio < 0.5) return 'Too much Pull';
    if (ratio > 1.2) return 'Too much Push';
    if (ratio >= 0.8 && ratio <= 1.0) return 'Optimal';
    return 'Acceptable';
  }
}

/// Quad:Hamstring balance data
class QuadHamstringBalance {
  // Ham:Quad ratio

  QuadHamstringBalance({
    required this.quadSets,
    required this.hamstringSets,
    required this.quadVolume,
    required this.hamstringVolume,
    required this.ratio,
  });
  final int quadSets;
  final int hamstringSets;
  final double quadVolume;
  final double hamstringVolume;
  final double ratio;

  bool get isBalanced => ratio >= 0.6 && ratio <= 1.0;
  bool get isHighRisk => ratio < 0.5; // Croisier et al., 2008

  String get status {
    if (ratio < 0.5) return 'High Injury Risk';
    if (ratio < 0.6) return 'Under-trained';
    if (ratio >= 0.6 && ratio <= 1.0) return 'Optimal';
    return 'Over-emphasized';
  }
}

/// Muscle distribution data
class MuscleDistribution {
  MuscleDistribution({
    required this.volumeByGroup,
    required this.percentageDistribution,
    required this.totalVolume,
  });

  factory MuscleDistribution.empty() {
    return MuscleDistribution(
      volumeByGroup: {},
      percentageDistribution: {},
      totalVolume: 0,
    );
  }
  final Map<String, double> volumeByGroup;
  final Map<String, double> percentageDistribution;
  final double totalVolume;

  String? get topMuscleGroup {
    if (percentageDistribution.isEmpty) return null;
    return percentageDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double? get topPercentage {
    if (percentageDistribution.isEmpty) return null;
    return percentageDistribution.values.reduce((a, b) => a > b ? a : b);
  }
}
