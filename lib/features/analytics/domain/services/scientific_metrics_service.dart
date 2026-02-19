import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_calculator.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';

/// Scientific metrics service with peer-reviewed calculations
///
/// All formulas are based on published research with citations
class ScientificMetricsService {
  /// Calculate Progressive Overload between workout sessions
  ///
  /// **Scientific Basis:**
  /// - Kraemer & Ratamess (2004): "Fundamentals of resistance training"
  /// - ACSM (2009): "Progression models in resistance training"
  ///
  /// **Validated Thresholds:**
  /// - Beginners: 2-5% weekly increase sustainable
  /// - Intermediates: 1-3% weekly increase
  /// - Advanced: 0.5-2% weekly increase
  /// - >10% weekly = overtraining risk
  ///
  /// Formula: [(Volume₂ - Volume₁) / Volume₁] × 100
  static ProgressiveOverloadResult calculateProgressiveOverload({
    required List<ExerciseActivity> currentSession,
    required List<ExerciseActivity> previousSession,
    required String exerciseId,
  }) {
    // Filter for same exercise
    final current = currentSession
        .where((a) => a.exerciseId == exerciseId)
        .toList();
    final previous = previousSession
        .where((a) => a.exerciseId == exerciseId)
        .toList();

    if (current.isEmpty || previous.isEmpty) {
      return ProgressiveOverloadResult.noData();
    }

    // Calculate volume: Sets × Reps × Load
    final currentVolume = current.fold<double>(
      0,
      (sum, a) => sum + VolumeCalculator.calculateTotalVolume(a.sets),
    );

    final previousVolume = previous.fold<double>(
      0,
      (sum, a) => sum + VolumeCalculator.calculateTotalVolume(a.sets),
    );

    if (previousVolume == 0) {
      return ProgressiveOverloadResult.noData();
    }

    final overloadPercent =
        ((currentVolume - previousVolume) / previousVolume) * 100;

    return ProgressiveOverloadResult(
      currentVolume: currentVolume,
      previousVolume: previousVolume,
      overloadPercent: overloadPercent,
      exerciseName: current.first.exerciseName,
    );
  }

  /// Calculate Volume Load Index per muscle group
  ///
  /// **Scientific Basis:**
  /// - Schoenfeld et al. (2017): "Dose-response relationship between weekly
  ///   resistance training volume and increases in muscle mass"
  /// - Baz-Valle et al. (2022): "Effects of different resistance training volumes"
  ///
  /// **Validated Ranges (sets/muscle/week):**
  /// - Hypertrophy Beginners: 10-12 sets
  /// - Hypertrophy Intermediates: 12-20 sets
  /// - Hypertrophy Advanced: 15-25+ sets
  /// - Strength: 8-15 sets (higher intensity, lower volume)
  ///
  /// Formula: Σ (Sets × Reps × Load) per muscle group
  static Map<String, VolumeLoadResult> calculateVolumeLoadIndex(
    List<ExerciseActivity> activities,
  ) {
    final results = <String, VolumeLoadResult>{};
    final volumeByGroup = VolumeCalculator.calculateVolumeByMuscleGroup(
      activities,
    );

    // Count sets per muscle group
    // **Uses SSOT**: MuscleAbbreviationMapper.categorizeExerciseByName
    final setsByGroup = <String, int>{};
    for (final activity in activities) {
      final muscleGroup = MuscleAbbreviationMapper.categorizeExerciseByName(
        activity.exerciseName,
      );
      final setCount = activity.sets.where((s) => s.done && !s.isWarmup).length;
      setsByGroup[muscleGroup] = (setsByGroup[muscleGroup] ?? 0) + setCount;
    }

    for (final entry in volumeByGroup.entries) {
      final muscleGroup = entry.key;
      final volume = entry.value;
      final sets = setsByGroup[muscleGroup] ?? 0;

      results[muscleGroup] = VolumeLoadResult(
        muscleGroup: muscleGroup,
        totalVolume: volume,
        totalSets: sets,
        volumeLoad: volume, // Volume Load = total volume in kg
      );
    }

    return results;
  }

  /// Calculate Relative Intensity (% 1RM) using validated formulas
  ///
  /// **Scientific Basis:**
  /// - Epley (1985): Best for 6-10 reps (±5% accuracy)
  /// - Brzycki (1993): Best for <6 reps (more conservative)
  /// - Reynolds et al. (2006): Validated accuracy across rep ranges
  ///
  /// **Intensity Zones (% 1RM):**
  /// - Max Strength: 85-100% (1-5 reps)
  /// - Strength/Hypertrophy: 75-85% (6-8 reps)
  /// - Hypertrophy: 67-85% (6-12 reps)
  /// - Muscular Endurance: <67% (12-20+ reps)
  ///
  /// **Formulas:**
  /// - Epley: 1RM = Weight × (1 + Reps/30)
  /// - Brzycki: 1RM = Weight / (1.0278 - 0.0278 × Reps)
  static RelativeIntensityResult calculateRelativeIntensity({
    required double weight,
    required int reps,
  }) {
    if (reps <= 0 || weight <= 0) {
      return RelativeIntensityResult.invalid();
    }

    // Too many reps for accurate 1RM estimation
    if (reps > 15) {
      return RelativeIntensityResult(
        weight: weight,
        reps: reps,
        estimated1RM: 0,
        percentOf1RM: 0,
        formula: 'None',
        reliability: 'Low',
        zone: IntensityZone.endurance,
      );
    }

    // Choose formula based on rep range
    double estimated1RM;
    String formula;

    if (reps <= 5) {
      // Brzycki for low reps (more conservative)
      estimated1RM = weight / (1.0278 - 0.0278 * reps);
      formula = 'Brzycki';
    } else if (reps <= 10) {
      // Epley for mid reps (most accurate)
      estimated1RM = weight * (1 + reps / 30);
      formula = 'Epley';
    } else {
      // Average of both for higher reps
      final epley = weight * (1 + reps / 30);
      final brzycki = weight / (1.0278 - 0.0278 * reps);
      estimated1RM = (epley + brzycki) / 2;
      formula = 'Epley+Brzycki';
    }

    final percentOf1RM = (weight / estimated1RM) * 100;

    // Determine intensity zone
    IntensityZone zone;
    if (percentOf1RM >= 85) {
      zone = IntensityZone.maxStrength;
    } else if (percentOf1RM >= 75) {
      zone = IntensityZone.strengthHypertrophy;
    } else if (percentOf1RM >= 67) {
      zone = IntensityZone.hypertrophy;
    } else {
      zone = IntensityZone.endurance;
    }

    // Reliability based on rep range
    String reliability;
    if (reps <= 5) {
      reliability = 'High (±2-3%)';
    } else if (reps <= 10) {
      reliability = 'High (±5%)';
    } else {
      reliability = 'Medium (±10-15%)';
    }

    return RelativeIntensityResult(
      weight: weight,
      reps: reps,
      estimated1RM: estimated1RM,
      percentOf1RM: percentOf1RM,
      formula: formula,
      reliability: reliability,
      zone: zone,
    );
  }

  /// Get Progressive Overload feedback based on scientific thresholds
  static String getOverloadFeedback(
    double overloadPercent, {
    String level = 'intermediate',
  }) {
    if (overloadPercent < 0) {
      return 'Volume regression detected. Verify recovery status and training stress.';
    }
    if (overloadPercent == 0) {
      return 'No progression. Consider increasing weight, reps, or sets.';
    }

    // Thresholds by training level
    final thresholds = {
      'beginner': {'min': 2.0, 'max': 5.0},
      'intermediate': {'min': 1.0, 'max': 3.0},
      'advanced': {'min': 0.5, 'max': 2.0},
    };

    final threshold = thresholds[level] ?? thresholds['intermediate']!;
    final min = threshold['min']!;
    final max = threshold['max']!;

    if (overloadPercent < min) {
      return 'Below optimal progression rate. Safe but could increase slightly.';
    } else if (overloadPercent <= max) {
      return 'Optimal progressive overload! Sustainable progression rate.';
    } else if (overloadPercent <= 10) {
      return 'Rapid progression. Monitor recovery closely to avoid overtraining.';
    } else {
      return 'Excessive volume increase (>${overloadPercent.toStringAsFixed(1)}%). HIGH risk of overtraining/injury.';
    }
  }

  /// Get Volume Load feedback based on Schoenfeld et al. (2017)
  static String getVolumeLoadFeedback({
    required int weeklySetCount,
    required String goal,
    required String level,
  }) {
    final ranges = {
      'hypertrophy': {
        'beginner': {'min': 10, 'max': 12},
        'intermediate': {'min': 12, 'max': 20},
        'advanced': {'min': 15, 'max': 25},
      },
      'strength': {
        'beginner': {'min': 8, 'max': 12},
        'intermediate': {'min': 10, 'max': 15},
        'advanced': {'min': 12, 'max': 18},
      },
    };

    final range = ranges[goal]?[level] ?? {'min': 10, 'max': 20};
    final min = range['min']!;
    final max = range['max']!;

    if (weeklySetCount < min) {
      return 'Below optimal volume ($weeklySetCount sets/week). Target: $min-$max sets for $goal.';
    } else if (weeklySetCount > max * 1.5) {
      return 'Excessive volume ($weeklySetCount sets). Risk of overtraining. Consider deload.';
    } else if (weeklySetCount > max) {
      return 'High volume ($weeklySetCount sets). Monitor recovery carefully.';
    } else {
      return 'Optimal volume for $goal ($weeklySetCount sets/week).';
    }
  }

  /// Get Intensity Zone feedback
  static String getIntensityFeedback({
    required double percentOf1RM,
    required String goal,
  }) {
    if (goal == 'strength' && percentOf1RM >= 85) {
      return 'Perfect intensity for max strength (${percentOf1RM.toStringAsFixed(0)}% 1RM)';
    } else if (goal == 'hypertrophy' &&
        percentOf1RM >= 67 &&
        percentOf1RM < 85) {
      return 'Optimal intensity for hypertrophy (${percentOf1RM.toStringAsFixed(0)}% 1RM)';
    } else if (goal == 'strength' && percentOf1RM < 85) {
      return 'Intensity too low for max strength. Increase to 85%+ 1RM.';
    } else if (goal == 'hypertrophy' && percentOf1RM >= 85) {
      return 'Intensity very high for hypertrophy. Could reduce to 67-85% for more volume.';
    } else if (percentOf1RM < 67) {
      return 'Low intensity (${percentOf1RM.toStringAsFixed(0)}% 1RM). Better for muscular endurance.';
    }
    return 'Intensity: ${percentOf1RM.toStringAsFixed(0)}% 1RM';
  }
}

/// Progressive Overload calculation result
class ProgressiveOverloadResult {
  ProgressiveOverloadResult({
    required this.currentVolume,
    required this.previousVolume,
    required this.overloadPercent,
    required this.exerciseName,
    this.hasData = true,
  });

  factory ProgressiveOverloadResult.noData() {
    return ProgressiveOverloadResult(
      currentVolume: 0,
      previousVolume: 0,
      overloadPercent: 0,
      exerciseName: '',
      hasData: false,
    );
  }
  final double currentVolume;
  final double previousVolume;
  final double overloadPercent;
  final String exerciseName;
  final bool hasData;

  bool get isProgressing => overloadPercent > 0;
  bool get isRegressing => overloadPercent < 0;
  bool get isOptimal =>
      overloadPercent > 0 &&
      overloadPercent <= 5; // Conservative for all levels
}

/// Volume Load calculation result
class VolumeLoadResult {
  VolumeLoadResult({
    required this.muscleGroup,
    required this.totalVolume,
    required this.totalSets,
    required this.volumeLoad,
  });
  final String muscleGroup;
  final double totalVolume;
  final int totalSets;
  final double volumeLoad;
}

/// Relative Intensity calculation result
class RelativeIntensityResult {
  RelativeIntensityResult({
    required this.weight,
    required this.reps,
    required this.estimated1RM,
    required this.percentOf1RM,
    required this.formula,
    required this.reliability,
    required this.zone,
    this.isValid = true,
  });

  factory RelativeIntensityResult.invalid() {
    return RelativeIntensityResult(
      weight: 0,
      reps: 0,
      estimated1RM: 0,
      percentOf1RM: 0,
      formula: 'None',
      reliability: 'Invalid',
      zone: IntensityZone.endurance,
      isValid: false,
    );
  }
  final double weight;
  final int reps;
  final double estimated1RM;
  final double percentOf1RM;
  final String formula;
  final String reliability;
  final IntensityZone zone;
  final bool isValid;
}

/// Intensity zones based on % 1RM
enum IntensityZone {
  maxStrength, // 85-100% 1RM
  strengthHypertrophy, // 75-85% 1RM
  hypertrophy, // 67-85% 1RM
  endurance, // <67% 1RM
}
