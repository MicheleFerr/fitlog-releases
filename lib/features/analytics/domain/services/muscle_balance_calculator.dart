/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/services
/// 🎯 Feature: analytics
/// 🔧 Type: service
///
/// Muscle Balance Calculator - Calculates push/pull ratio, upper/lower balance
///
/// **Best Practices from Research**:
/// - Hevy App: Track push/pull ratio for injury prevention
/// - Fitbod: Auto-balance when push muscles overworked (>1.5:1 ratio)
/// - Optimal ratios: Push/Pull 1:1, Upper/Lower 1:1
///
/// **Warning Thresholds**:
/// - Push/Pull imbalance: >1.5:1 or <0.7:1
/// - Upper/Lower imbalance: >1.5:1 or <0.7:1
/// - Neglected muscle: <5% of total volume
library;

import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';

/// Muscle Balance Calculator Service
///
/// Analyzes exercise history to detect muscle imbalances and provide
/// actionable recommendations.
///
/// **Usage**:
/// ```dart
/// final calculator = MuscleBalanceCalculator();
/// final balance = calculator.calculateBalance(exerciseHistories);
///
/// if (balance.pushPullWarning) {
///   print('Push/Pull imbalance detected: ${balance.pushPullRatio}');
/// }
/// ```
class MuscleBalanceCalculator {
  /// Calculate balance metrics from exercise history
  ///
  /// Returns [MuscleBalanceMetrics] with ratios, warnings, and suggestions
  MuscleBalanceMetrics calculateBalance(
    List<ExerciseHistory> exerciseHistories,
  ) {
    if (exerciseHistories.isEmpty) {
      return MuscleBalanceMetrics.empty();
    }

    // Calculate volume per muscle group
    final Map<String, double> muscleVolumes = {};
    double totalVolume = 0;

    for (final history in exerciseHistories) {
      final muscle = history.muscleGroup.toLowerCase();
      final volume = history.sessions.fold<double>(
        0,
        (sum, session) => sum + session.totalVolume,
      );

      muscleVolumes[muscle] = (muscleVolumes[muscle] ?? 0) + volume;
      totalVolume += volume;
    }

    // Categorize muscles
    double pushVolume = 0;
    double pullVolume = 0;
    double upperVolume = 0;
    double lowerVolume = 0;

    muscleVolumes.forEach((muscle, volume) {
      // Push muscles: chest, triceps, shoulders (anterior delts), quads
      if (_isPushMuscle(muscle)) {
        pushVolume += volume;
      }

      // Pull muscles: back, biceps, hamstrings, rear delts
      if (_isPullMuscle(muscle)) {
        pullVolume += volume;
      }

      // Upper body: chest, back, shoulders, arms
      if (_isUpperBody(muscle)) {
        upperVolume += volume;
      }

      // Lower body: legs, glutes, calves
      if (_isLowerBody(muscle)) {
        lowerVolume += volume;
      }
    });

    // Calculate ratios
    final pushPullRatio = pullVolume > 0 ? (pushVolume / pullVolume).toDouble() : 0.0;
    final upperLowerRatio = lowerVolume > 0 ? (upperVolume / lowerVolume).toDouble() : 0.0;

    // Detect warnings (imbalance >50% from optimal 1:1)
    final pushPullWarning = pushPullRatio > 1.5 || pushPullRatio < 0.7;
    final upperLowerWarning = upperLowerRatio > 1.5 || upperLowerRatio < 0.7;

    // Find neglected muscles (<5% of total volume)
    final neglectedMuscles = muscleVolumes.entries
        .where((e) => (e.value / totalVolume) < 0.05)
        .map((e) => e.key)
        .toList();

    // Find top trained muscles (>15% of total volume)
    final topMuscles = muscleVolumes.entries
        .where((e) => (e.value / totalVolume) > 0.15)
        .map((e) => e.key)
        .toList()
      ..sort((a, b) {
        final aVol = muscleVolumes[a] ?? 0;
        final bVol = muscleVolumes[b] ?? 0;
        return bVol.compareTo(aVol);
      });

    // Calculate overall balance score (0-10)
    // 10 = perfect balance, 0 = severe imbalance
    double balanceScore = 10.0;

    // Penalty for push/pull imbalance (-3 points)
    if (pushPullWarning) {
      balanceScore -= 3.0;
    }

    // Penalty for upper/lower imbalance (-2 points)
    if (upperLowerWarning) {
      balanceScore -= 2.0;
    }

    // Penalty for neglected muscles (-0.5 per muscle)
    balanceScore -= neglectedMuscles.length * 0.5;

    // Clamp to 0-10 range
    balanceScore = balanceScore.clamp(0.0, 10.0);

    return MuscleBalanceMetrics(
      pushPullRatio: pushPullRatio,
      upperLowerRatio: upperLowerRatio,
      pushPullWarning: pushPullWarning,
      upperLowerWarning: upperLowerWarning,
      neglectedMuscles: neglectedMuscles,
      topMuscles: topMuscles,
      balanceScore: balanceScore,
      muscleVolumePercentages: muscleVolumes.map(
        (muscle, volume) => MapEntry(muscle, (volume / totalVolume) * 100),
      ),
    );
  }

  /// Check if muscle is a push muscle
  bool _isPushMuscle(String muscle) {
    const pushMuscles = [
      'chest',
      'pectorals',
      'triceps',
      'shoulders',
      'delts',
      'anterior delts',
      'quads',
      'quadriceps',
    ];

    return pushMuscles.any((push) => muscle.contains(push));
  }

  /// Check if muscle is a pull muscle
  bool _isPullMuscle(String muscle) {
    const pullMuscles = [
      'back',
      'lats',
      'traps',
      'biceps',
      'hamstrings',
      'rear delts',
      'posterior',
      'rhomboids',
    ];

    return pullMuscles.any((pull) => muscle.contains(pull));
  }

  /// Check if muscle is upper body
  bool _isUpperBody(String muscle) {
    const upperMuscles = [
      'chest',
      'pectorals',
      'back',
      'lats',
      'traps',
      'shoulders',
      'delts',
      'biceps',
      'triceps',
      'arms',
      'abs',
      'core',
    ];

    return upperMuscles.any((upper) => muscle.contains(upper));
  }

  /// Check if muscle is lower body
  bool _isLowerBody(String muscle) {
    const lowerMuscles = [
      'legs',
      'quads',
      'quadriceps',
      'hamstrings',
      'glutes',
      'calves',
      'hips',
    ];

    return lowerMuscles.any((lower) => muscle.contains(lower));
  }
}

/// Muscle Balance Metrics - Result of balance calculation
///
/// **Properties**:
/// - pushPullRatio: Push volume / Pull volume (optimal: 1.0)
/// - upperLowerRatio: Upper / Lower volume (optimal: 1.0)
/// - pushPullWarning: True if ratio >1.5 or <0.7
/// - upperLowerWarning: True if ratio >1.5 or <0.7
/// - balanceScore: Overall balance (0-10, 10 = perfect)
/// - neglectedMuscles: Muscles with <5% total volume
/// - topMuscles: Muscles with >15% total volume
/// - muscleVolumePercentages: % of total volume per muscle
class MuscleBalanceMetrics {
  const MuscleBalanceMetrics({
    required this.pushPullRatio,
    required this.upperLowerRatio,
    required this.pushPullWarning,
    required this.upperLowerWarning,
    required this.neglectedMuscles,
    required this.topMuscles,
    required this.balanceScore,
    required this.muscleVolumePercentages,
  });

  factory MuscleBalanceMetrics.empty() => const MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 1.0,
        pushPullWarning: false,
        upperLowerWarning: false,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 10.0,
        muscleVolumePercentages: {},
      );

  /// Push/Pull ratio (optimal: 1.0)
  final double pushPullRatio;

  /// Upper/Lower ratio (optimal: 1.0)
  final double upperLowerRatio;

  /// True if push/pull imbalance detected (>1.5 or <0.7)
  final bool pushPullWarning;

  /// True if upper/lower imbalance detected (>1.5 or <0.7)
  final bool upperLowerWarning;

  /// Muscles with <5% of total volume
  final List<String> neglectedMuscles;

  /// Top trained muscles (>15% of total volume)
  final List<String> topMuscles;

  /// Overall balance score (0-10, 10 = perfect balance)
  final double balanceScore;

  /// Percentage of total volume per muscle group
  final Map<String, double> muscleVolumePercentages;

  /// Check if any warnings present
  bool get hasWarnings => pushPullWarning || upperLowerWarning || neglectedMuscles.isNotEmpty;

  /// Get balance score rating
  String get balanceRating {
    if (balanceScore >= 9.0) return 'Excellent';
    if (balanceScore >= 7.5) return 'Good';
    if (balanceScore >= 6.0) return 'Fair';
    if (balanceScore >= 4.0) return 'Needs Improvement';
    return 'Poor';
  }
}
