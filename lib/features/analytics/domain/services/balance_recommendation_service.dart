/// Balance Recommendation Service
///
/// Generates actionable recommendations to correct muscle imbalances
/// based on analysis of training volume distribution.
///
/// Inspired by Fitbod's auto-balance approach:
/// - When push muscles are overworked (>1.5:1 ratio), suggest more pull work
/// - When upper body dominates, suggest more leg exercises
/// - When muscles are neglected (<5% volume), prioritize them
///
/// Research basis:
/// - Hevy App: Track push/pull ratio for injury prevention
/// - Fitbod: Auto-balance when imbalances detected
/// - Optimal ratios: Push/Pull 1:1, Upper/Lower 1:1
library;

import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_balance_calculator.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/fitness_fatigue_service.dart';

/// Type of balance recommendation
enum RecommendationType {
  /// Increase pull work relative to push
  increasePull,

  /// Increase push work relative to pull
  increasePush,

  /// Increase lower body work
  increaseLower,

  /// Increase upper body work
  increaseUpper,

  /// Train a neglected muscle
  trainNeglected,

  /// Reduce overtraining of a muscle
  reduceOvertraining,

  /// Optimal balance - no changes needed
  balanced,

  /// Rest recommendation based on FFM
  restRecommended,
}

/// Priority level for recommendations
enum RecommendationPriority {
  /// Critical - injury risk if not addressed
  critical,

  /// High - significant imbalance
  high,

  /// Medium - noticeable imbalance
  medium,

  /// Low - minor optimization
  low,

  /// Info - for context only
  info,
}

/// A single balance recommendation
class BalanceRecommendation {
  const BalanceRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    this.targetMuscles = const [],
    this.suggestedExercises = const [],
    this.volumeAdjustment,
    this.currentRatio,
    this.targetRatio,
  });

  /// Type of recommendation
  final RecommendationType type;

  /// Priority level
  final RecommendationPriority priority;

  /// Short title for display
  final String title;

  /// Detailed description
  final String description;

  /// Target muscle groups to focus on
  final List<String> targetMuscles;

  /// Suggested exercises to address the imbalance
  final List<String> suggestedExercises;

  /// Suggested volume adjustment (e.g., "+20%", "-10%")
  final String? volumeAdjustment;

  /// Current ratio (for context)
  final double? currentRatio;

  /// Target ratio to achieve
  final double? targetRatio;

  /// Check if this is an actionable recommendation (not just info)
  bool get isActionable => type != RecommendationType.balanced;
}

/// Complete recommendation result
class BalanceRecommendationResult {
  const BalanceRecommendationResult({
    required this.recommendations,
    required this.overallStatus,
    required this.overallScore,
    this.nextWorkoutFocus,
  });

  /// List of recommendations sorted by priority
  final List<BalanceRecommendation> recommendations;

  /// Overall status message
  final String overallStatus;

  /// Overall balance score (0-10)
  final double overallScore;

  /// Suggested focus for next workout
  final String? nextWorkoutFocus;

  /// Get critical recommendations only
  List<BalanceRecommendation> get criticalRecommendations => recommendations
      .where((r) => r.priority == RecommendationPriority.critical)
      .toList();

  /// Get high priority recommendations
  List<BalanceRecommendation> get highPriorityRecommendations => recommendations
      .where((r) => r.priority == RecommendationPriority.high)
      .toList();

  /// Check if any critical issues
  bool get hasCriticalIssues => criticalRecommendations.isNotEmpty;

  /// Get actionable recommendations count
  int get actionableCount =>
      recommendations.where((r) => r.isActionable).length;
}

/// Static service for generating balance recommendations
class BalanceRecommendationService {
  BalanceRecommendationService._();

  /// Generate recommendations from balance metrics
  ///
  /// Analyzes push/pull, upper/lower ratios and neglected muscles
  /// to generate prioritized recommendations.
  static BalanceRecommendationResult generateRecommendations(
    MuscleBalanceMetrics metrics, {
    Map<String, MuscleRecoveryPrediction>? ffmRecovery,
  }) {
    final recommendations = <BalanceRecommendation>[];

    // 1. Check upper body push/pull imbalance
    if (metrics.upperPushPullWarning) {
      recommendations.add(_generateUpperPushPullRecommendation(metrics));
    }

    // 2. Check lower body push/pull imbalance
    if (metrics.lowerPushPullWarning) {
      recommendations.add(_generateLowerPushPullRecommendation(metrics));
    }

    // 3. Check upper/lower imbalance
    if (metrics.upperLowerWarning) {
      recommendations.add(_generateUpperLowerRecommendation(metrics));
    }

    // 4. Check neglected muscles
    for (final muscle in metrics.neglectedMuscles) {
      recommendations.add(
        _generateNeglectedMuscleRecommendation(muscle, metrics),
      );
    }

    // 5. Check overtraining (from FFM if available)
    if (ffmRecovery != null) {
      for (final entry in ffmRecovery.entries) {
        if (entry.value.shouldRest) {
          recommendations.add(_generateRestRecommendation(entry.value));
        }
      }
    }

    // 6. If no issues, add balanced recommendation
    if (recommendations.isEmpty) {
      recommendations.add(
        const BalanceRecommendation(
          type: RecommendationType.balanced,
          priority: RecommendationPriority.info,
          title: 'Well Balanced',
          description:
              'Your training volume is well distributed. Keep up the good work!',
        ),
      );
    }

    // Sort by priority
    recommendations.sort(
      (a, b) => a.priority.index.compareTo(b.priority.index),
    );

    // Determine next workout focus
    final nextFocus = _determineNextWorkoutFocus(recommendations, metrics);

    // Determine overall status
    final status = _getOverallStatus(metrics.balanceScore, recommendations);

    return BalanceRecommendationResult(
      recommendations: recommendations,
      overallStatus: status,
      overallScore: metrics.balanceScore,
      nextWorkoutFocus: nextFocus,
    );
  }

  /// Generate recommendation for upper body push/pull imbalance
  static BalanceRecommendation _generateUpperPushPullRecommendation(
    MuscleBalanceMetrics metrics,
  ) {
    final ratio = metrics.upperPushPullRatio;
    final isPushDominant = ratio > 1.0;

    if (isPushDominant) {
      // Too much push, need more pull
      final priority = ratio > 2.0
          ? RecommendationPriority.critical
          : ratio > 1.5
          ? RecommendationPriority.high
          : RecommendationPriority.medium;

      return BalanceRecommendation(
        type: RecommendationType.increasePull,
        priority: priority,
        title: 'Add Upper Pull Work',
        description:
            'Upper body is push-dominant (${ratio.toStringAsFixed(1)}:1). '
            'Add more rowing and pull exercises to prevent shoulder injuries.',
        targetMuscles: const ['LAT', 'TRAP', 'BICI', 'DELT_POST'],
        suggestedExercises: const [
          'Barbell Row',
          'Pull-ups',
          'Face Pulls',
          'Rear Delt Flyes',
          'Lat Pulldown',
        ],
        volumeAdjustment: '+${((ratio - 1) * 30).clamp(10, 50).round()}%',
        currentRatio: ratio,
        targetRatio: 1.0,
      );
    } else {
      // Too much pull, need more push
      final priority = ratio < 0.5
          ? RecommendationPriority.critical
          : ratio < 0.7
          ? RecommendationPriority.high
          : RecommendationPriority.medium;

      return BalanceRecommendation(
        type: RecommendationType.increasePush,
        priority: priority,
        title: 'Add Upper Push Work',
        description:
            'Upper body is pull-dominant (1:${(1 / ratio).toStringAsFixed(1)}). '
            'Add more pressing and push exercises for balanced development.',
        targetMuscles: const ['PETT', 'TRIC', 'DELT_ANT'],
        suggestedExercises: const [
          'Bench Press',
          'Overhead Press',
          'Dips',
          'Incline Press',
          'Push-ups',
        ],
        volumeAdjustment: '+${(((1 / ratio) - 1) * 30).clamp(10, 50).round()}%',
        currentRatio: ratio,
        targetRatio: 1.0,
      );
    }
  }

  /// Generate recommendation for lower body push/pull imbalance
  static BalanceRecommendation _generateLowerPushPullRecommendation(
    MuscleBalanceMetrics metrics,
  ) {
    final ratio = metrics.lowerPushPullRatio;
    final isQuadDominant = ratio > 1.0;

    if (isQuadDominant) {
      // Too much quad work, need more hamstring/glute work
      final priority = ratio > 2.0
          ? RecommendationPriority.critical
          : ratio > 1.5
          ? RecommendationPriority.high
          : RecommendationPriority.medium;

      return BalanceRecommendation(
        type: RecommendationType.increasePull,
        priority: priority,
        title: 'Add Posterior Chain Work',
        description:
            'Legs are quad-dominant (${ratio.toStringAsFixed(1)}:1). '
            'Add more hip hinge and hamstring exercises to prevent knee issues.',
        targetMuscles: const ['FEMOR', 'GLUT'],
        suggestedExercises: const [
          'Romanian Deadlift',
          'Hip Thrust',
          'Leg Curl',
          'Good Mornings',
          'Glute Bridge',
        ],
        volumeAdjustment: '+${((ratio - 1) * 30).clamp(10, 50).round()}%',
        currentRatio: ratio,
        targetRatio: 1.0,
      );
    } else {
      // Too much posterior chain, need more quad work
      final priority = ratio < 0.5
          ? RecommendationPriority.critical
          : ratio < 0.7
          ? RecommendationPriority.high
          : RecommendationPriority.medium;

      return BalanceRecommendation(
        type: RecommendationType.increasePush,
        priority: priority,
        title: 'Add Quad Work',
        description:
            'Legs are posterior-dominant (1:${(1 / ratio).toStringAsFixed(1)}). '
            'Add more squat and leg extension exercises for balanced legs.',
        targetMuscles: const ['QUAD'],
        suggestedExercises: const [
          'Squats',
          'Leg Press',
          'Leg Extension',
          'Lunges',
          'Step-ups',
        ],
        volumeAdjustment: '+${(((1 / ratio) - 1) * 30).clamp(10, 50).round()}%',
        currentRatio: ratio,
        targetRatio: 1.0,
      );
    }
  }

  /// Generate recommendation for upper/lower imbalance
  static BalanceRecommendation _generateUpperLowerRecommendation(
    MuscleBalanceMetrics metrics,
  ) {
    final ratio = metrics.upperLowerRatio;
    final isUpperDominant = ratio > 1.0;

    if (isUpperDominant) {
      final priority = ratio > 2.0
          ? RecommendationPriority.critical
          : ratio > 1.5
          ? RecommendationPriority.high
          : RecommendationPriority.medium;

      return BalanceRecommendation(
        type: RecommendationType.increaseLower,
        priority: priority,
        title: 'Train Legs More',
        description:
            'Upper body dominates (${ratio.toStringAsFixed(1)}:1). '
            'Add more leg work to prevent imbalances and improve overall strength.',
        targetMuscles: const ['QUAD', 'FEMOR', 'GLUT', 'POLP'],
        suggestedExercises: const [
          'Squats',
          'Deadlifts',
          'Leg Press',
          'Lunges',
          'Calf Raises',
        ],
        volumeAdjustment: '+${((ratio - 1) * 30).clamp(10, 50).round()}%',
        currentRatio: ratio,
        targetRatio: 1.0,
      );
    } else {
      final priority = ratio < 0.5
          ? RecommendationPriority.critical
          : ratio < 0.7
          ? RecommendationPriority.high
          : RecommendationPriority.medium;

      return BalanceRecommendation(
        type: RecommendationType.increaseUpper,
        priority: priority,
        title: 'Train Upper Body More',
        description:
            'Lower body dominates (1:${(1 / ratio).toStringAsFixed(1)}). '
            'Add more upper body work for proportional development.',
        targetMuscles: const ['PETT', 'LAT', 'DELT_ANT', 'DELT_LAT'],
        suggestedExercises: const [
          'Bench Press',
          'Rows',
          'Overhead Press',
          'Pull-ups',
          'Lateral Raises',
        ],
        volumeAdjustment: '+${(((1 / ratio) - 1) * 30).clamp(10, 50).round()}%',
        currentRatio: ratio,
        targetRatio: 1.0,
      );
    }
  }

  /// Generate recommendation for a neglected muscle
  static BalanceRecommendation _generateNeglectedMuscleRecommendation(
    String muscle,
    MuscleBalanceMetrics metrics,
  ) {
    final percentage = metrics.muscleVolumePercentages[muscle] ?? 0;

    // Map muscle abbreviations to display names and exercise suggestions
    final muscleData = _getMuscleData(muscle);

    return BalanceRecommendation(
      type: RecommendationType.trainNeglected,
      priority: percentage < 2
          ? RecommendationPriority.high
          : RecommendationPriority.medium,
      title: 'Train ${muscleData.displayName}',
      description:
          '${muscleData.displayName} is neglected (${percentage.toStringAsFixed(1)}% of volume). '
          'Add dedicated ${muscleData.displayName.toLowerCase()} exercises.',
      targetMuscles: [muscle],
      suggestedExercises: muscleData.exercises,
      volumeAdjustment: '+${(5 - percentage).clamp(1, 5).round()} sets/week',
    );
  }

  /// Generate rest recommendation from FFM
  static BalanceRecommendation _generateRestRecommendation(
    MuscleRecoveryPrediction prediction,
  ) {
    final isRecovering = prediction.state == FFMRecoveryState.overtraining;

    return BalanceRecommendation(
      type: RecommendationType.restRecommended,
      priority: isRecovering
          ? RecommendationPriority.high
          : RecommendationPriority.critical,
      title: 'Rest ${prediction.displayName}',
      description:
          '${prediction.displayName} is at ${prediction.performanceLevel.toStringAsFixed(0)}% performance. '
          '${prediction.optimalTrainingIn != null ? 'Wait ${prediction.optimalTrainingIn} hours for optimal training.' : 'Consider rest before training again.'}',
      targetMuscles: [prediction.muscleId],
    );
  }

  /// Determine suggested focus for next workout
  static String? _determineNextWorkoutFocus(
    List<BalanceRecommendation> recommendations,
    MuscleBalanceMetrics metrics,
  ) {
    // Find highest priority actionable recommendation
    final actionable = recommendations.where((r) => r.isActionable).toList();
    if (actionable.isEmpty) return null;

    final top = actionable.first;

    return switch (top.type) {
      RecommendationType.increasePull => 'Pull Day (Back, Biceps, Rear Delts)',
      RecommendationType.increasePush =>
        'Push Day (Chest, Triceps, Front Delts)',
      RecommendationType.increaseLower => 'Leg Day (Quads, Hamstrings, Glutes)',
      RecommendationType.increaseUpper => 'Upper Body Day',
      RecommendationType.trainNeglected => '${top.targetMuscles.first} Focus',
      RecommendationType.restRecommended => 'Rest Day',
      _ => null,
    };
  }

  /// Get overall status message
  static String _getOverallStatus(
    double score,
    List<BalanceRecommendation> recommendations,
  ) {
    final hasCritical = recommendations.any(
      (r) => r.priority == RecommendationPriority.critical,
    );
    final hasHigh = recommendations.any(
      (r) => r.priority == RecommendationPriority.high,
    );

    if (hasCritical) {
      return 'Critical imbalances detected - action recommended';
    }
    if (hasHigh) {
      return 'Notable imbalances found - consider adjustments';
    }
    if (score >= 9.0) {
      return 'Excellent balance - maintain current routine';
    }
    if (score >= 7.5) {
      return 'Good balance - minor optimizations possible';
    }
    if (score >= 6.0) {
      return 'Fair balance - room for improvement';
    }
    return 'Needs improvement - review training split';
  }

  /// Get muscle display data and exercise suggestions
  ///
  /// **SINGLE SOURCE OF TRUTH**: Uses [MuscleAbbreviationMapper] for display names.
  /// Exercise suggestions are domain-specific business logic kept here.
  static ({String displayName, List<String> exercises}) _getMuscleData(
    String muscle,
  ) {
    // Get display name from centralized mapper (SSOT)
    final canonicalId = MuscleAbbreviationMapper.normalizeToCanonicalId(muscle);
    final displayName = MuscleAbbreviationMapper.codeToDisplayName(
      canonicalId,
      italian: false,
    );

    // Exercise suggestions are domain-specific business logic
    final exercises = _getExerciseSuggestions(canonicalId);

    return (displayName: displayName, exercises: exercises);
  }

  /// Exercise suggestions for each muscle group
  ///
  /// Domain-specific business logic - these are curated exercise recommendations
  /// that help users improve muscle balance.
  static List<String> _getExerciseSuggestions(String canonicalId) {
    return switch (canonicalId.toUpperCase()) {
      'PETT' => ['Bench Press', 'Incline Press', 'Flyes', 'Push-ups', 'Dips'],
      'LAT' => ['Pull-ups', 'Lat Pulldown', 'Rows', 'Pullovers'],
      'TRAP' => ['Shrugs', 'Face Pulls', 'Upright Rows', 'Farmer Walks'],
      'DELT_ANT' => ['Overhead Press', 'Front Raises', 'Arnold Press'],
      'DELT_LAT' => ['Lateral Raises', 'Upright Rows', 'Cable Laterals'],
      'DELT_POST' => ['Face Pulls', 'Rear Delt Flyes', 'Reverse Pec Deck'],
      'DELT' => ['Overhead Press', 'Lateral Raises', 'Face Pulls'],
      'BICI' => ['Barbell Curl', 'Hammer Curl', 'Preacher Curl'],
      'TRIC' => [
        'Tricep Pushdown',
        'Skull Crushers',
        'Dips',
        'Close Grip Press',
      ],
      'QUAD' => ['Squats', 'Leg Press', 'Leg Extension', 'Lunges'],
      'FEMOR' => ['Romanian Deadlift', 'Leg Curl', 'Good Mornings'],
      'GLUT' => ['Hip Thrust', 'Glute Bridge', 'Lunges', 'Squats'],
      'POLP' => ['Standing Calf Raise', 'Seated Calf Raise', 'Leg Press Calf'],
      'CORE' ||
      'ADD' => ['Planks', 'Ab Wheel', 'Cable Crunches', 'Hanging Leg Raises'],
      'LOMBAR' => ['Hyperextensions', 'Good Mornings', 'Deadlifts'],
      'AVA' => ['Wrist Curls', 'Reverse Curls', 'Farmer Walks'],
      _ => ['Targeted exercises for $canonicalId'],
    };
  }
}
