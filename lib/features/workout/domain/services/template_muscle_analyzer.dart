/// Template Muscle Analyzer
///
/// Calculates muscle coverage from a list of ExerciseTemplate
/// without requiring workout history conversion.
/// Used in the template editor to provide real-time muscle balance feedback.
library;

import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';

/// Result of muscle analysis for a template
class TemplateMuscleAnalysis {
  const TemplateMuscleAnalysis({
    required this.musclePercentages,
    required this.exerciseBreakdown,
    required this.pushPullRatio,
    required this.upperLowerRatio,
    required this.pushPullWarning,
    required this.upperLowerWarning,
    required this.coveredMuscles,
    required this.neglectedMuscles,
    required this.missingMuscles,
    required this.totalSets,
  });

  /// Muscle percentages normalized to heatmap keys (0-100 scale)
  final Map<String, double> musclePercentages;

  /// Per-exercise contribution breakdown on the template total volume
  final List<ExerciseContributionBreakdown> exerciseBreakdown;

  /// Push/Pull ratio (optimal: 1.0)
  final double pushPullRatio;

  /// Upper/Lower ratio (optimal: 1.0)
  final double upperLowerRatio;

  /// True if push/pull ratio is >1.5 or <0.67
  final bool pushPullWarning;

  /// True if upper/lower ratio is >1.5 or <0.67
  final bool upperLowerWarning;

  /// Muscles with >5% volume
  final List<String> coveredMuscles;

  /// Muscles with >0% and <=5% volume
  final List<String> neglectedMuscles;

  /// Muscles with 0% volume (not targeted at all)
  final List<String> missingMuscles;

  /// Total sets in the template
  final int totalSets;

  /// Whether there are any warnings
  bool get hasWarnings => pushPullWarning || upperLowerWarning;

  /// Whether the template is empty (no exercises)
  bool get isEmpty => totalSets == 0;

  static const empty = TemplateMuscleAnalysis(
    musclePercentages: {},
    exerciseBreakdown: [],
    pushPullRatio: 0,
    upperLowerRatio: 0,
    pushPullWarning: false,
    upperLowerWarning: false,
    coveredMuscles: [],
    neglectedMuscles: [],
    missingMuscles: [],
    totalSets: 0,
  );
}

/// Contribution of a single muscle for one exercise.
class ExerciseMuscleContribution {
  const ExerciseMuscleContribution({
    required this.muscleId,
    required this.percentage,
  });

  /// Canonical muscle ID (e.g., QUAD, FEMO).
  final String muscleId;

  /// Percentage contribution on total template volume.
  final double percentage;
}

/// Volume contribution details for one exercise.
class ExerciseContributionBreakdown {
  const ExerciseContributionBreakdown({
    required this.exerciseName,
    required this.sets,
    required this.totalPercentage,
    required this.contributions,
  });

  final String exerciseName;
  final int sets;
  final double totalPercentage;
  final List<ExerciseMuscleContribution> contributions;
}

/// Analyzes muscle coverage from template exercises
class TemplateMuscleAnalyzer {
  TemplateMuscleAnalyzer._();

  // Push muscles (canonical abbreviation IDs)
  static const _pushMuscles = {'PETT', 'TRIC', 'DELT_ANT', 'DELT_LAT', 'QUAD'};

  // Pull muscles
  static const _pullMuscles = {
    'LAT',
    'TRAP',
    'BICI',
    'FEMO',
    'DELT_POST',
    'GLUT',
    'LOMB',
    'ROMB',
  };

  // Upper body muscles
  static const _upperMuscles = {
    'PETT',
    'LAT',
    'TRAP',
    'DELT',
    'DELT_ANT',
    'DELT_LAT',
    'DELT_POST',
    'TRIC',
    'BICI',
    'AVA',
    'LOMB',
    'ROMB',
    'COLL',
  };

  // Lower body muscles
  static const _lowerMuscles = {
    'QUAD',
    'FEMO',
    'GLUT',
    'POLP',
    'ADD',
    'ABDU',
  };

  // All trackable muscles for "missing" detection
  static const _allTrackableMuscles = {
    'PETT',
    'LAT',
    'TRAP',
    'DELT_ANT',
    'DELT_LAT',
    'DELT_POST',
    'TRIC',
    'BICI',
    'QUAD',
    'FEMO',
    'GLUT',
    'POLP',
    'CORE',
  };

  /// Analyze muscle coverage from a list of ExerciseTemplate
  ///
  /// [exercises] - The template exercises to analyze
  /// [muscleMap] - Optional exercise-to-muscle mapping from exerciseMuscleMapProvider
  static TemplateMuscleAnalysis analyze(
    List<ExerciseTemplate> exercises, {
    Map<String, ExerciseMuscleData>? muscleMap,
  }) {
    if (exercises.isEmpty) return TemplateMuscleAnalysis.empty;

    // Accumulate volume per canonical muscle ID
    final muscleVolume = <String, double>{};
    final rawExerciseBreakdowns = <_RawExerciseBreakdown>[];
    int totalSets = 0;

    for (final exercise in exercises) {
      final sets = exercise.sets.length;
      if (sets == 0) continue;
      totalSets += sets;

      final exerciseDistribution = _buildExerciseDistribution(
        exercise,
        sets: sets.toDouble(),
        muscleMap: muscleMap,
      );

      if (exerciseDistribution.isEmpty) continue;

      for (final entry in exerciseDistribution.entries) {
        muscleVolume[entry.key] = (muscleVolume[entry.key] ?? 0) + entry.value;
      }

      rawExerciseBreakdowns.add(
        _RawExerciseBreakdown(
          exerciseName: exercise.exerciseName,
          sets: sets,
          muscleVolume: exerciseDistribution,
        ),
      );
    }

    if (totalSets == 0) return TemplateMuscleAnalysis.empty;

    // Calculate percentages
    final totalVolume = muscleVolume.values.fold(0.0, (sum, v) => sum + v);
    final musclePercentages = <String, double>{};

    if (totalVolume > 0) {
      for (final entry in muscleVolume.entries) {
        musclePercentages[entry.key] = (entry.value / totalVolume) * 100;
      }
    }

    // Calculate push/pull ratio
    double pushVolume = 0;
    double pullVolume = 0;
    for (final entry in muscleVolume.entries) {
      if (_pushMuscles.contains(entry.key)) pushVolume += entry.value;
      if (_pullMuscles.contains(entry.key)) pullVolume += entry.value;
    }
    final pushPullRatio =
        pullVolume > 0 ? pushVolume / pullVolume : (pushVolume > 0 ? 2.0 : 0);

    // Calculate upper/lower ratio
    double upperVolume = 0;
    double lowerVolume = 0;
    for (final entry in muscleVolume.entries) {
      if (_upperMuscles.contains(entry.key)) upperVolume += entry.value;
      if (_lowerMuscles.contains(entry.key)) lowerVolume += entry.value;
    }
    final upperLowerRatio =
        lowerVolume > 0 ? upperVolume / lowerVolume : (upperVolume > 0 ? 2.0 : 0);

    // Classify muscles
    final covered = <String>[];
    final neglected = <String>[];
    final missing = <String>[];

    for (final muscle in _allTrackableMuscles) {
      final pct = musclePercentages[muscle] ?? 0;
      if (pct > 5) {
        covered.add(muscle);
      } else if (pct > 0) {
        neglected.add(muscle);
      } else {
        missing.add(muscle);
      }
    }

    // Sort covered by percentage descending
    covered.sort(
      (a, b) =>
          (musclePercentages[b] ?? 0).compareTo(musclePercentages[a] ?? 0),
    );

    // Convert muscle percentages to heatmap keys for ProfessionalBodyHeatmap
    final heatmapPercentages = <String, double>{};
    for (final entry in musclePercentages.entries) {
      final heatmapKey = MuscleAbbreviationMapper.normalizeToHeatmapKey(
        entry.key,
      );
      heatmapPercentages[heatmapKey] =
          (heatmapPercentages[heatmapKey] ?? 0) + entry.value;
    }

    // Build per-exercise percentages on total volume
    final exerciseBreakdown = <ExerciseContributionBreakdown>[];
    if (totalVolume > 0) {
      for (final raw in rawExerciseBreakdowns) {
        final exerciseTotalVolume = raw.muscleVolume.values.fold(
          0.0,
          (sum, v) => sum + v,
        );

        final contributions = raw.muscleVolume.entries
            .map(
              (entry) => ExerciseMuscleContribution(
                muscleId: entry.key,
                percentage: (entry.value / totalVolume) * 100,
              ),
            )
            .toList()
          ..sort((a, b) => b.percentage.compareTo(a.percentage));

        exerciseBreakdown.add(
          ExerciseContributionBreakdown(
            exerciseName: raw.exerciseName,
            sets: raw.sets,
            totalPercentage: (exerciseTotalVolume / totalVolume) * 100,
            contributions: contributions,
          ),
        );
      }
    }

    return TemplateMuscleAnalysis(
      musclePercentages: heatmapPercentages,
      exerciseBreakdown: exerciseBreakdown,
      pushPullRatio: pushPullRatio.toDouble(),
      upperLowerRatio: upperLowerRatio.toDouble(),
      pushPullWarning: pushPullRatio > 1.5 || (pushPullRatio > 0 && pushPullRatio < 0.67),
      upperLowerWarning: upperLowerRatio > 1.5 || (upperLowerRatio > 0 && upperLowerRatio < 0.67),
      coveredMuscles: covered,
      neglectedMuscles: neglected,
      missingMuscles: missing,
      totalSets: totalSets,
    );
  }

  static Map<String, double> _buildExerciseDistribution(
    ExerciseTemplate exercise, {
    required double sets,
    required Map<String, ExerciseMuscleData>? muscleMap,
  }) {
    final distribution = <String, double>{};
    final muscleData = _findMuscleData(exercise, muscleMap);

    if (muscleData != null && muscleData.hasData) {
      _distributeMuscleVolume(distribution, muscleData, sets);
      return distribution;
    }

    _distributeFallbackVolume(distribution, exercise, sets);
    return distribution;
  }

  /// Find muscle data for an exercise, trying multiple name variants
  static ExerciseMuscleData? _findMuscleData(
    ExerciseTemplate exercise,
    Map<String, ExerciseMuscleData>? muscleMap,
  ) {
    if (muscleMap == null) return null;

    // Try exact name
    final data = muscleMap[exercise.exerciseName];
    if (data != null) return data;

    // Try lowercase
    return muscleMap[exercise.exerciseName.toLowerCase()];
  }

  /// Distribute volume using EMG-weighted muscle data
  static void _distributeMuscleVolume(
    Map<String, double> muscleVolume,
    ExerciseMuscleData muscleData,
    double sets,
  ) {
    final primaryCount = muscleData.primary.length;
    final secondaryCount = muscleData.secondary.length;

    // Primary muscles get 70% of volume, secondary get 30%
    if (primaryCount > 0) {
      final primaryShare = (sets * 0.7) / primaryCount;
      for (final muscle in muscleData.primary) {
        final canonical = MuscleAbbreviationMapper.normalizeToCanonicalId(muscle);
        muscleVolume[canonical] = (muscleVolume[canonical] ?? 0) + primaryShare;
      }
    }

    if (secondaryCount > 0) {
      final secondaryShare = (sets * 0.3) / secondaryCount;
      for (final muscle in muscleData.secondary) {
        final canonical = MuscleAbbreviationMapper.normalizeToCanonicalId(muscle);
        muscleVolume[canonical] = (muscleVolume[canonical] ?? 0) + secondaryShare;
      }
    }

    // If only primary muscles, they get 100%
    if (primaryCount > 0 && secondaryCount == 0) {
      final extraShare = (sets * 0.3) / primaryCount;
      for (final muscle in muscleData.primary) {
        final canonical = MuscleAbbreviationMapper.normalizeToCanonicalId(muscle);
        muscleVolume[canonical] = (muscleVolume[canonical] ?? 0) + extraShare;
      }
    }
  }

  /// Fallback: distribute volume based on ExerciseCategory
  static void _distributeFallbackVolume(
    Map<String, double> muscleVolume,
    ExerciseTemplate exercise,
    double sets,
  ) {
    // Try name-based categorization first (more granular)
    final abbr = MuscleAbbreviationMapper.categorizeExerciseToAbbreviation(
      exercise.exerciseName,
    );

    if (abbr != 'VARIO') {
      final canonical = MuscleAbbreviationMapper.normalizeToCanonicalId(abbr);
      muscleVolume[canonical] = (muscleVolume[canonical] ?? 0) + sets;
      return;
    }

    // Final fallback: use category
    final muscles = _categoryToMuscles(exercise.category);
    if (muscles.isNotEmpty) {
      final share = sets / muscles.length;
      for (final muscle in muscles) {
        muscleVolume[muscle] = (muscleVolume[muscle] ?? 0) + share;
      }
    }
  }

  /// Map ExerciseCategory to default muscle IDs
  static List<String> _categoryToMuscles(ExerciseCategory category) {
    return switch (category) {
      ExerciseCategory.chest => ['PETT'],
      ExerciseCategory.back => ['LAT', 'TRAP'],
      ExerciseCategory.shoulders => ['DELT_ANT', 'DELT_LAT', 'DELT_POST'],
      ExerciseCategory.arms => ['BICI', 'TRIC'],
      ExerciseCategory.legs => ['QUAD', 'FEMO', 'GLUT'],
      ExerciseCategory.abs => ['CORE'],
      ExerciseCategory.cardio => [],
      ExerciseCategory.other => [],
    };
  }
}

class _RawExerciseBreakdown {
  const _RawExerciseBreakdown({
    required this.exerciseName,
    required this.sets,
    required this.muscleVolume,
  });

  final String exerciseName;
  final int sets;
  final Map<String, double> muscleVolume;
}
