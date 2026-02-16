/// Template Suggestion Engine - Multi-Factor Template Scoring
///
/// Implements 6-factor scoring algorithm to rank workout templates
/// based on recovery, volume needs, neglect, patterns, variety, and balance.
///
/// **Algorithm**:
/// ```
/// Score = 0.25×Recovery + 0.25×Volume + 0.20×Neglected
///       + 0.15×Pattern + 0.10×Variety + 0.05×Balance
/// ```
///
/// **Key Innovation**: Recovery 70-90% scores HIGHER than 100%
/// (supercompensation window is optimal for training)
library;

import 'dart:math' show max;
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/constants/volume_landmarks.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_readiness_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/weekly_volume_tracker.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart'
    as workout;
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';

/// Context data for template suggestion
///
/// Contains all data needed for multi-factor scoring
class SuggestionContext {
  const SuggestionContext({
    required this.muscleRecovery,
    required this.weeklyVolumes,
    required this.neglectedMuscles,
    required this.history,
  });

  /// Current muscle recovery state (PETT: 80%, LAT: 65%, etc.)
  final Map<String, MuscleReadinessData> muscleRecovery;

  /// Weekly volume tracker (PETT: 12 sets, LAT: 14 sets, etc.)
  final WeeklyVolumeTracker weeklyVolumes;

  /// Neglected muscles from detector (priority 0-10)
  final List<NeglectedMuscle> neglectedMuscles;

  /// Workout history for pattern detection
  final List<WorkoutHistoryDetail> history;
}

/// Template Suggestion Engine - Scores templates based on multiple factors
class TemplateSuggestionEngine {
  const TemplateSuggestionEngine();

  /// Scoring weights for each factor (must sum to 1.0)
  static const _weights = {
    'recovery': 0.25,
    'volume': 0.25,
    'neglected': 0.20,
    'pattern': 0.15,
    'variety': 0.10,
    'balance': 0.05,
  };

  /// Compute composite score for a template (0-100)
  ///
  /// Returns weighted sum of all 6 factors
  double computeScore(
    CommunityWorkoutTemplate template,
    SuggestionContext ctx,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    final scores = {
      'recovery': recoveryScore(template, ctx.muscleRecovery, exerciseDB),
      'volume': volumeNeedScore(template, ctx.weeklyVolumes, exerciseDB),
      'neglected': neglectedScore(template, ctx.neglectedMuscles, exerciseDB),
      'pattern': patternScore(template, ctx.history),
      'variety': varietyScore(template, ctx.history, exerciseDB),
      'balance': balanceScore(template, ctx.weeklyVolumes, exerciseDB),
    };

    double total = 0;
    for (final entry in scores.entries) {
      total += _weights[entry.key]! * entry.value;
    }

    return total.clamp(0, 100);
  }

  /// Compute score breakdown for UI debug
  ///
  /// Returns map of factor -> score for transparency
  Map<String, double> computeScoreBreakdown(
    CommunityWorkoutTemplate template,
    SuggestionContext ctx,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    return {
      'recovery': recoveryScore(template, ctx.muscleRecovery, exerciseDB),
      'volume': volumeNeedScore(template, ctx.weeklyVolumes, exerciseDB),
      'neglected': neglectedScore(template, ctx.neglectedMuscles, exerciseDB),
      'pattern': patternScore(template, ctx.history),
      'variety': varietyScore(template, ctx.history, exerciseDB),
      'balance': balanceScore(template, ctx.weeklyVolumes, exerciseDB),
    };
  }

  // =========================================================================
  // FACTOR 1: RECOVERY SCORE (25% weight)
  // =========================================================================

  /// Calculate recovery score based on supercompensation curve
  ///
  /// **Key insight**: 70-90% recovery is BETTER than 100%!
  /// That's the supercompensation window - optimal for growth.
  ///
  /// **Formula**: Weighted average of primary (70%) + secondary (30%)
  double recoveryScore(
    CommunityWorkoutTemplate template,
    Map<String, MuscleReadinessData> recovery,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    final muscles = _extractMuscles(template, exerciseDB);
    final primaryMuscles = muscles['primary'] ?? <String>{};
    final secondaryMuscles = muscles['secondary'] ?? <String>{};

    if (primaryMuscles.isEmpty) return 50.0; // Neutral if no muscles

    // Calculate scores for primary muscles
    final primaryScores = primaryMuscles.map((m) {
      final r = recovery[m]?.recoveryPercent ?? 100.0;
      return _supercompensationCurve(r);
    }).toList();

    final primaryAvg = primaryScores.isEmpty
        ? 50.0
        : primaryScores.reduce((a, b) => a + b) / primaryScores.length;

    // Calculate scores for secondary muscles
    final secondaryScores = secondaryMuscles.map((m) {
      final r = recovery[m]?.recoveryPercent ?? 100.0;
      return _supercompensationCurve(r);
    }).toList();

    final secondaryAvg = secondaryScores.isEmpty
        ? 50.0
        : secondaryScores.reduce((a, b) => a + b) / secondaryScores.length;

    // Weighted average: primary 70%, secondary 30%
    return primaryAvg * 0.7 + secondaryAvg * 0.3;
  }

  /// Supercompensation curve - peaks in 70-90% recovery window
  ///
  /// **Science**: MPS peaks 24-48h post-training (70-90% recovery)
  /// Training at 100%+ means you're past the optimal window
  double _supercompensationCurve(double recoveryPercent) {
    if (recoveryPercent >= 90) return 95.0; // Supercompensated
    if (recoveryPercent >= 70) return 100.0; // OPTIMAL WINDOW!
    if (recoveryPercent >= 50) return 70.0; // Partial recovery
    if (recoveryPercent >= 30) return 40.0; // Still fatigued
    return 10.0; // Acute fatigue
  }

  // =========================================================================
  // FACTOR 2: VOLUME NEED SCORE (25% weight)
  // =========================================================================

  /// Calculate volume need score based on MEV/MAV landmarks
  ///
  /// **Priority**:
  /// - Under MEV = URGENT (100 points) - muscle not growing
  /// - MEV to MAV = Good (50 points) - room for volume
  /// - Above MAV = Avoid (0 points) - risk overtraining
  double volumeNeedScore(
    CommunityWorkoutTemplate template,
    WeeklyVolumeTracker volumes,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    final primaryMuscles = _extractPrimaryMuscles(template, exerciseDB);

    if (primaryMuscles.isEmpty) return 0.0;

    double totalNeed = 0;
    for (final muscle in primaryMuscles) {
      final currentSets = volumes.setsThisWeek(muscle);
      final landmarks = volumeLandmarks[muscle] ?? defaultVolumeLandmarks;

      final mev = landmarks.mev;
      final mav = landmarks.mavHigh;

      if (currentSets < mev) {
        // Under MEV: URGENT - this muscle isn't growing
        final deficit = 1 - (currentSets / mev);
        totalNeed += 100.0 * deficit;
      } else if (currentSets < mav) {
        // Between MEV and MAV: there's room for volume
        final range = mav - mev;
        final position = currentSets - mev;
        totalNeed += 50.0 * (1 - position / range);
      } else {
        // Above MAV: risk overtraining
        totalNeed += 0.0;
      }
    }

    return (totalNeed / primaryMuscles.length).clamp(0, 100);
  }

  // =========================================================================
  // FACTOR 3: NEGLECTED SCORE (20% weight)
  // =========================================================================

  /// Calculate neglected muscle score
  ///
  /// Templates that cover neglected muscles get higher scores.
  /// Uses priority from NeglectedMuscleDetector (0-10 scale).
  double neglectedScore(
    CommunityWorkoutTemplate template,
    List<NeglectedMuscle> neglected,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    if (neglected.isEmpty) return 50.0; // Neutral if no neglected muscles

    final templateMuscles = _extractAllMuscles(template, exerciseDB);

    // Map neglected muscle names (english) to abbreviations (PETT, LAT, etc.)
    final muscleNameMap = _buildMuscleNameMap();

    double score = 0;
    int coveredCount = 0;

    for (final n in neglected) {
      // Convert neglected muscle name to abbreviation
      final abbr = muscleNameMap[n.muscleName.toLowerCase()];
      if (abbr != null && templateMuscles.contains(abbr)) {
        // Template covers this neglected muscle
        score += n.priority * 10; // Priority is 0-10, scale to 0-100
        coveredCount++;
      }
    }

    // Return 0 if template doesn't cover any neglected muscles
    if (coveredCount == 0) return 0.0;

    // Average score for covered neglected muscles
    return (score / coveredCount).clamp(0, 100);
  }

  /// Build map from english muscle names to abbreviations
  ///
  /// Example: "chest" -> "PETT", "back" -> "LAT", etc.
  Map<String, String> _buildMuscleNameMap() {
    return {
      'chest': 'PETT',
      'back': 'LAT',
      'shoulders': 'DELT',
      'rear_delts': 'DELT_POST',
      'biceps': 'BICI',
      'triceps': 'TRIC',
      'forearms': 'AVA',
      'quads': 'QUAD',
      'hamstrings': 'FEMO',
      'glutes': 'GLUT',
      'calves': 'POLP',
      'abs': 'CORE',
      'lower_back': 'LOMB',
    };
  }

  // =========================================================================
  // FACTOR 4: PATTERN SCORE (15% weight)
  // =========================================================================

  /// Calculate pattern score - how often user trains this split on this weekday
  ///
  /// Example: User always does legs on Monday -> high score for leg templates on Monday
  ///
  /// **Window**: Last 60 days (to capture monthly patterns)
  double patternScore(
    CommunityWorkoutTemplate template,
    List<WorkoutHistoryDetail> history,
  ) {
    if (history.isEmpty) return 50.0; // Neutral for new users

    final today = DateTime.now().weekday; // 1=Mon, 7=Sun
    final last60Days = DateTime.now().subtract(const Duration(days: 60));

    // Filter history to last 60 days and same weekday
    final workoutsOnThisWeekday = history
        .where((w) => w.completedAt.isAfter(last60Days))
        .where((w) => w.completedAt.weekday == today)
        .toList();

    if (workoutsOnThisWeekday.isEmpty) return 50.0; // No pattern yet

    // Count how many used this exact template ID
    final matchCount = workoutsOnThisWeekday
        .where((w) => w.templateId == template.id)
        .length;

    final ratio = matchCount / workoutsOnThisWeekday.length;
    return (ratio * 100).clamp(0, 100);
  }

  // =========================================================================
  // FACTOR 5: VARIETY SCORE (10% weight)
  // =========================================================================

  /// Calculate variety score - penalize repeating same template
  ///
  /// **Logic**:
  /// - Same template ID as last workout = 10 points (strong penalty)
  /// - Same primary muscles as last workout = scaled penalty
  /// - Different = 100 points
  double varietyScore(
    CommunityWorkoutTemplate template,
    List<WorkoutHistoryDetail> history,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    if (history.isEmpty) return 100.0; // No history = full variety

    // Get most recent workout
    final sortedHistory = history.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final lastWorkout = sortedHistory.first;

    // Strong penalty for exact same template
    if (lastWorkout.templateId == template.id) return 10.0;

    // Moderate penalty for same primary muscles
    final thisMuscles = _extractPrimaryMuscles(template, exerciseDB);
    final lastMuscles = _extractPrimaryMusclesFromHistory(
      lastWorkout,
      exerciseDB,
    );

    if (thisMuscles.isEmpty || lastMuscles.isEmpty) return 100.0;

    final overlap = thisMuscles.where((m) => lastMuscles.contains(m)).length;
    final overlapRatio = overlap / thisMuscles.length;

    return ((1 - overlapRatio) * 100).clamp(0, 100);
  }

  // =========================================================================
  // FACTOR 6: BALANCE SCORE (5% weight)
  // =========================================================================

  /// Calculate balance score - check antagonist pair ratios
  ///
  /// **Target**: ~1.0 ratio for push/pull, quads/hamstrings, etc.
  /// Templates that help balance get higher scores.
  double balanceScore(
    CommunityWorkoutTemplate template,
    WeeklyVolumeTracker volumes,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    // Antagonist pairs (muscle A, muscle B)
    final pairs = [
      ('PETT', 'LAT'), // Push/Pull upper
      ('QUAD', 'FEMO'), // Push/Pull lower
      ('BICI', 'TRIC'), // Arms
    ];

    double totalImbalance = 0;
    int pairsChecked = 0;

    for (final (a, b) in pairs) {
      final volA = volumes.setsThisWeek(a);
      final volB = volumes.setsThisWeek(b);

      if (volA + volB == 0) continue; // Skip if neither trained

      final ratio = volA / max(volB, 1);
      final deviation = (ratio - 1.0).abs();

      totalImbalance += deviation;
      pairsChecked++;
    }

    if (pairsChecked == 0) return 50.0; // Neutral if no pairs trained

    final avgImbalance = totalImbalance / pairsChecked;

    // Convert imbalance to score (lower imbalance = higher score)
    // Perfect balance (0.0) = 100 points
    // 2x imbalance (1.0) = 50 points
    // 3x+ imbalance (2.0+) = 0 points
    return ((1 - (avgImbalance / 2)) * 100).clamp(0, 100);
  }

  // =========================================================================
  // HELPER METHODS: Muscle Extraction
  // =========================================================================

  /// Extract primary and secondary muscles from template
  ///
  /// Returns: {'primary': {PETT, TRIC}, 'secondary': {DELT}}
  Map<String, Set<String>> _extractMuscles(
    CommunityWorkoutTemplate template,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    final primaryMuscles = <String>{};
    final secondaryMuscles = <String>{};

    for (final exercise in template.exercises) {
      // Look up by ID or name
      final definition =
          exerciseDB[exercise.id] ?? exerciseDB[exercise.name];

      if (definition != null) {
        primaryMuscles.addAll(definition.focus);
        secondaryMuscles.addAll(definition.muscoliSecondari);
      }

      // Handle supersets
      if (exercise is workout.SupersetExercise) {
        for (final subExercise in exercise.exercises) {
          final subDef =
              exerciseDB[subExercise.id] ?? exerciseDB[subExercise.name];
          if (subDef != null) {
            primaryMuscles.addAll(subDef.focus);
            secondaryMuscles.addAll(subDef.muscoliSecondari);
          }
        }
      }
    }

    // Remove overlap (primary takes precedence)
    secondaryMuscles.removeWhere((m) => primaryMuscles.contains(m));

    return {'primary': primaryMuscles, 'secondary': secondaryMuscles};
  }

  /// Extract only primary muscles from template
  Set<String> _extractPrimaryMuscles(
    CommunityWorkoutTemplate template,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    final muscles = _extractMuscles(template, exerciseDB);
    return muscles['primary'] ?? <String>{};
  }

  /// Extract all muscles (primary + secondary) from template
  Set<String> _extractAllMuscles(
    CommunityWorkoutTemplate template,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    final muscles = _extractMuscles(template, exerciseDB);
    return {
      ...muscles['primary'] ?? <String>{},
      ...muscles['secondary'] ?? <String>{},
    };
  }

  /// Extract primary muscles from workout history
  Set<String> _extractPrimaryMusclesFromHistory(
    WorkoutHistoryDetail workout,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    final primaryMuscles = <String>{};

    for (final exercise in workout.exercises) {
      final definition =
          exerciseDB[exercise.id] ?? exerciseDB[exercise.name];
      if (definition != null) {
        primaryMuscles.addAll(definition.focus);
      }
    }

    return primaryMuscles;
  }
}

/// Ranked template with score and breakdown
class RankedTemplate {
  const RankedTemplate({
    required this.template,
    required this.score,
    required this.breakdown,
  });

  final CommunityWorkoutTemplate template;
  final double score; // 0-100
  final Map<String, double> breakdown; // For UI debug

  @override
  String toString() =>
      'RankedTemplate(${template.name}, score: ${score.toStringAsFixed(1)})';
}
