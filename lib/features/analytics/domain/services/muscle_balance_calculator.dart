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
///
/// **Muscle Distribution** (based on EMG research):
/// Uses dynamic ratios per movement pattern category:
/// - Push Horizontal: 60% primary, 25% high synergist, 15% moderate synergist
/// - Push Vertical: 55% primary, 35% high synergist, 10% moderate synergist
/// - Pull Horizontal: 60% primary, 25% high synergist, 15% moderate synergist
/// - Pull Vertical: 55% primary, 30% high synergist, 15% moderate synergist
/// - Squat: 50% primary, 35% high synergist, 15% moderate synergist
/// - Hinge: 55% primary, 30% high synergist, 15% moderate synergist
/// - Isolation: 85% primary, 15% stabilizers
///
/// Reference: Rodríguez-Ridao et al. (2020), Schoenfeld et al. (2020)
library;

import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/balance_recommendation_service.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/emg_movement_ratios.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/fitness_fatigue_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';

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
///
/// **With weighted distribution** (recommended):
/// ```dart
/// final balance = calculator.calculateBalance(
///   exerciseHistories,
///   exerciseMuscleMap: muscleMap,  // From exerciseMuscleMapProvider
/// );
/// ```
class MuscleBalanceCalculator {
  /// Fallback weight for primary muscles when movement pattern is unknown
  static const double fallbackPrimaryWeight = 0.7;

  /// Fallback weight for secondary muscles when movement pattern is unknown
  static const double fallbackSecondaryWeight = 0.3;

  /// Calculate balance metrics from exercise history
  ///
  /// Uses custom exercise categorization first, then exercise name inference
  /// to correctly classify push/pull when the stored muscleGroup is generic.
  ///
  /// [customExercises] - Map of exercise name (lowercase) to CustomExercise
  /// for proper categorization of user-defined exercises
  ///
  /// [exerciseMuscleMap] - Optional map of exercise name to ExerciseMuscleData
  /// for weighted primary/secondary muscle distribution. When provided, volume
  /// is distributed: 70% to primary muscles, 30% to secondary muscles.
  ///
  /// Returns [MuscleBalanceMetrics] with ratios, warnings, and suggestions
  MuscleBalanceMetrics calculateBalance(
    List<ExerciseHistory> exerciseHistories, {
    Map<String, CustomExercise>? customExercises,
    Map<String, ExerciseMuscleData>? exerciseMuscleMap,
  }) {
    if (exerciseHistories.isEmpty) {
      return MuscleBalanceMetrics.empty();
    }

    // Calculate volume per muscle group with corrected classifications
    final Map<String, double> muscleVolumes = {};
    double totalVolume = 0;

    for (final history in exerciseHistories) {
      final volume = history.sessions.fold<double>(
        0,
        (sum, session) => sum + session.totalVolume,
      );

      // Try to get muscle data from the map first
      // Use case-insensitive lookup: try exact match, then lowercase
      final muscleData = exerciseMuscleMap?[history.exerciseName] ??
          exerciseMuscleMap?[history.exerciseName.toLowerCase()];

      if (muscleData != null && muscleData.hasData) {
        // Get movement pattern from patternMovimento or infer from name
        final movementPattern = muscleData.fileCategory.isNotEmpty
            ? EmgMovementRatios.fromPatternMovimento(
                muscleData.fileCategory,
                exerciseName: muscleData.exerciseName.isNotEmpty
                    ? muscleData.exerciseName
                    : history.exerciseName,
              )
            : EmgMovementRatios.inferPattern(
                fileCategory: '',
                exerciseName: muscleData.exerciseName.isNotEmpty
                    ? muscleData.exerciseName
                    : history.exerciseName,
                focusMuscle: muscleData.primary.isNotEmpty
                    ? muscleData.primary.first
                    : null,
              );

        // Distribute volume using EMG-based ratios for this movement pattern
        _distributeWeightedVolume(
          muscleVolumes,
          muscleData.primary,
          muscleData.secondary,
          volume,
          movementPattern: movementPattern,
        );
      } else {
        // Fallback to single muscle group from custom exercise or name inference
        final customExercise =
            customExercises?[history.exerciseName.toLowerCase()];
        final muscle = _getCorrectedMuscleGroup(
          history.exerciseName,
          history.muscleGroup,
          customExercise: customExercise,
        ).toLowerCase();

        muscleVolumes[muscle] = (muscleVolumes[muscle] ?? 0) + volume;
      }

      totalVolume += volume;
    }

    // Categorize muscles with separated upper/lower push-pull (P1 enhancement)
    double pushVolume = 0;
    double pullVolume = 0;
    double upperVolume = 0;
    double lowerVolume = 0;

    // P1: Separated upper/lower push-pull tracking
    double upperPushVolume = 0;
    double upperPullVolume = 0;
    double lowerPushVolume = 0;
    double lowerPullVolume = 0;

    muscleVolumes.forEach((muscle, volume) {
      final isPush = _isPushMuscle(muscle);
      final isPull = _isPullMuscle(muscle);
      final isUpper = _isUpperBody(muscle);
      final isLower = _isLowerBody(muscle);

      // Total push/pull (combined)
      if (isPush) pushVolume += volume;
      if (isPull) pullVolume += volume;

      // Upper/lower body totals
      if (isUpper) upperVolume += volume;
      if (isLower) lowerVolume += volume;

      // P1: Separated upper/lower push-pull
      // Upper push: chest, triceps, anterior delts
      // Upper pull: back, biceps, posterior delts
      if (isUpper && isPush) upperPushVolume += volume;
      if (isUpper && isPull) upperPullVolume += volume;

      // Lower push: quads
      // Lower pull: hamstrings, glutes (hip hinge movements)
      if (isLower && isPush) lowerPushVolume += volume;
      if (isLower && isPull) lowerPullVolume += volume;
    });

    // Calculate ratios
    final pushPullRatio = pullVolume > 0 ? (pushVolume / pullVolume).toDouble() : 0.0;
    final upperLowerRatio = lowerVolume > 0 ? (upperVolume / lowerVolume).toDouble() : 0.0;

    // P1: Separated upper/lower push-pull ratios
    final upperPushPullRatio =
        upperPullVolume > 0 ? (upperPushVolume / upperPullVolume).toDouble() : 0.0;
    final lowerPushPullRatio =
        lowerPullVolume > 0 ? (lowerPushVolume / lowerPullVolume).toDouble() : 0.0;

    // Detect warnings (imbalance >50% from optimal 1:1)
    final pushPullWarning = pushPullRatio > 1.5 || pushPullRatio < 0.7;
    final upperLowerWarning = upperLowerRatio > 1.5 || upperLowerRatio < 0.7;

    // P1: Warnings for separated upper/lower push-pull
    final upperPushPullWarning = upperPushPullRatio > 1.5 || upperPushPullRatio < 0.7;
    final lowerPushPullWarning = lowerPushPullRatio > 1.5 || lowerPushPullRatio < 0.7;

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

    // Penalty for total push/pull imbalance (-2 points)
    if (pushPullWarning) {
      balanceScore -= 2.0;
    }

    // P1: Penalty for upper body push/pull imbalance (-1.5 points)
    if (upperPushPullWarning) {
      balanceScore -= 1.5;
    }

    // P1: Penalty for lower body push/pull imbalance (-1.5 points)
    if (lowerPushPullWarning) {
      balanceScore -= 1.5;
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
      // P1: Separated upper/lower push-pull ratios
      upperPushPullRatio: upperPushPullRatio,
      lowerPushPullRatio: lowerPushPullRatio,
      upperPushPullWarning: upperPushPullWarning,
      lowerPushPullWarning: lowerPushPullWarning,
    );
  }

  /// Check if muscle is a push muscle
  ///
  /// Supports both English and Italian abbreviations
  ///
  /// **Deltoid Classification** (P0 fix):
  /// - DELT_ANT (anterior) → PUSH
  /// - DELT_LAT (lateral) → NEUTRAL (excluded from push/pull)
  /// - DELT_POST (posterior) → PULL (see _isPullMuscle)
  /// - DELT (generic) → PUSH (backward compatibility)
  bool _isPushMuscle(String muscle) {
    // First, check for specific deltoid portions
    final muscleLower = muscle.toLowerCase();

    // DELT_LAT is neutral (not push, not pull) - skip it
    if (muscleLower.contains('delt_lat')) {
      return false;
    }

    // DELT_POST is a pull muscle - skip it
    if (muscleLower.contains('delt_post')) {
      return false;
    }

    // DELT_ANT is a push muscle
    if (muscleLower.contains('delt_ant')) {
      return true;
    }

    const pushMuscles = [
      // English
      'chest',
      'pectorals',
      'triceps',
      'shoulders',
      'anterior delts',
      'front delts',
      'quads',
      'quadriceps',
      // Italian abbreviations from JSON
      'pett', // Pettorali
      'tric', // Tricipiti
      'delt', // Deltoidi (generic - legacy, backward compatibility)
      'quad', // Quadricipiti
    ];

    return pushMuscles.any((push) => muscle.contains(push));
  }

  /// Check if muscle is a pull muscle
  ///
  /// Supports both English and Italian abbreviations
  ///
  /// **Deltoid Classification** (P0 fix):
  /// - DELT_POST (posterior) → PULL
  /// - DELT_ANT (anterior) → PUSH (see _isPushMuscle)
  /// - DELT_LAT (lateral) → NEUTRAL (excluded from push/pull)
  bool _isPullMuscle(String muscle) {
    // First, check for specific deltoid portions
    final muscleLower = muscle.toLowerCase();

    // DELT_POST is a pull muscle
    if (muscleLower.contains('delt_post')) {
      return true;
    }

    // DELT_ANT and DELT_LAT are NOT pull muscles
    if (muscleLower.contains('delt_ant') || muscleLower.contains('delt_lat')) {
      return false;
    }

    const pullMuscles = [
      // English
      'back',
      'lats',
      'traps',
      'biceps',
      'hamstrings',
      'rear delts',
      'posterior delts',
      'posterior',
      'rhomboids',
      // Italian abbreviations from JSON
      'lat', // Latissimus
      'trap', // Trapezio
      'bic', // Bicipiti
      'femor', // Femorali (hamstrings)
      'dorso', // Back
    ];

    return pullMuscles.any((pull) => muscle.contains(pull));
  }

  /// Check if muscle is upper body
  ///
  /// Supports both English and Italian abbreviations
  bool _isUpperBody(String muscle) {
    const upperMuscles = [
      // English
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
      'forearms',
      'abs',
      'core',
      'neck',
      // Italian abbreviations
      'pett', // Pettorali
      'lat', // Latissimus
      'trap', // Trapezio
      'delt', // Deltoidi (includes delt_ant, delt_lat, delt_post)
      'bic', // Bicipiti
      'tric', // Tricipiti
      'ava', // Avambracci (forearms)
      'avamb', // Avambracci
      'addom', // Addominali
      'dorso', // Back
      'lombar', // Lombari
      'lomb', // Lombari
      'lom', // Lombari
      'collo', // Collo (neck)
    ];

    return upperMuscles.any((upper) => muscle.contains(upper));
  }

  /// Check if muscle is lower body
  ///
  /// Supports both English and Italian abbreviations
  bool _isLowerBody(String muscle) {
    const lowerMuscles = [
      // English
      'legs',
      'quads',
      'quadriceps',
      'hamstrings',
      'glutes',
      'calves',
      'hips',
      'adductors',
      'abductors',
      // Italian abbreviations
      'quad', // Quadricipiti
      'femor', // Femorali
      'femo', // Femorali (short)
      'glut', // Glutei
      'polp', // Polpacci
      'poll', // Polpacci (variant)
      'addut', // Adduttori (specific, avoids matching 'addom')
      'addu', // Adduttori (specific, avoids matching 'addom')
      'abdut', // Abduttori
      'abdu', // Abduttori
    ];

    return lowerMuscles.any((lower) => muscle.contains(lower));
  }

  /// Infer specific muscle group from exercise name
  ///
  /// Returns specific muscle groups for push/pull classification
  String _inferMuscleFromName(String exerciseName) {
    final nameLower = exerciseName.toLowerCase();

    // === PUSH EXERCISES ===

    // Quad-dominant (PUSH)
    const quadPatterns = [
      'leg extension', 'leg press', 'squat', 'sissy squat', 'hack squat',
      'front squat', 'affond', 'lunge', 'bulgarian', 'step up', 'pressa',
      'quadricip',
    ];
    for (final pattern in quadPatterns) {
      if (nameLower.contains(pattern)) return 'quads';
    }

    // Triceps (PUSH)
    const tricepsPatterns = [
      'tricep', 'pushdown', 'push down', 'skull crusher', 'french press',
      'dip', 'close grip', 'diamond', 'kickback',
      'estensione tricipiti', 'push-down',
    ];
    for (final pattern in tricepsPatterns) {
      if (nameLower.contains(pattern)) return 'triceps';
    }

    // Chest (PUSH)
    const chestPatterns = [
      'bench press', 'panca piana', 'panca inclinata', 'panca declinata',
      'chest', 'pettoral', 'fly', 'flye', 'crossover', 'pec deck', 'push up',
      'pushup',
    ];
    for (final pattern in chestPatterns) {
      if (nameLower.contains(pattern)) return 'chest';
    }

    // === PULL EXERCISES ===

    // Hamstring-dominant (PULL)
    const hamstringPatterns = [
      'leg curl', 'lying curl', 'seated curl', 'stacco rumeno',
      'romanian deadlift', 'rdl', 'good morning', 'glute ham',
      'hip thrust', 'femorali', 'nordic', 'hyperextension',
    ];
    for (final pattern in hamstringPatterns) {
      if (nameLower.contains(pattern)) return 'hamstrings';
    }

    // Biceps (PULL)
    const bicepsPatterns = [
      'bicep', 'curl', 'preacher', 'hammer', 'concentration',
      'spider curl', 'incline curl', 'ez bar curl', 'barbell curl',
    ];
    for (final pattern in bicepsPatterns) {
      if (nameLower.contains(pattern) && !nameLower.contains('leg curl')) {
        return 'biceps';
      }
    }

    // Back (PULL)
    const backPatterns = [
      'row', 'pull up', 'pullup', 'pull-up', 'chin up', 'chinup', 'chin-up',
      'lat pull', 'pulldown', 'deadlift', 'stacco da terra',
      'rematore', 'trazioni', 'lat machine', 't-bar',
      'seal row', 'meadow', 'dorso',
    ];
    for (final pattern in backPatterns) {
      if (nameLower.contains(pattern)) return 'back';
    }

    return '';
  }

  /// Get corrected muscle group using custom exercise data first, then name inference
  ///
  /// Priority order:
  /// 1. User's custom exercise categorization (if exists)
  /// 2. Name-based inference patterns
  /// 3. Original stored muscle group
  String _getCorrectedMuscleGroup(
    String exerciseName,
    String storedMuscleGroup, {
    CustomExercise? customExercise,
  }) {
    // 1. Check custom exercise patternMovimento first (only if user modified it)
    if (customExercise != null &&
        customExercise.isModifiedFromBase &&
        customExercise.patternMovimento.isNotEmpty) {
      final pattern = customExercise.patternMovimento.toLowerCase();

      // Map pattern to muscle group for push/pull classification
      if (pattern == 'push') {
        // Use first focus muscle or default to 'chest' for push
        return customExercise.focus.isNotEmpty
            ? customExercise.focus.first.toLowerCase()
            : 'chest';
      } else if (pattern == 'pull') {
        // Use first focus muscle or default to 'back' for pull
        return customExercise.focus.isNotEmpty
            ? customExercise.focus.first.toLowerCase()
            : 'back';
      } else if (pattern == 'hinge' || pattern == 'squat' || pattern == 'accessory') {
        // For other patterns, use first focus muscle if available
        if (customExercise.focus.isNotEmpty) {
          return customExercise.focus.first.toLowerCase();
        }
      }
    }

    // 2. Fallback to name-based inference
    final inferred = _inferMuscleFromName(exerciseName);
    return inferred.isNotEmpty ? inferred : storedMuscleGroup;
  }

  /// Distribute volume with EMG-based movement pattern ratios and tiered synergists
  ///
  /// Uses dynamic ratios based on the movement pattern:
  /// - Push Horizontal: Primary 60%, High synergist 25%, Moderate synergists 15%
  /// - Push Vertical: Primary 55%, High synergist 35%, Moderate synergists 10%
  /// - Isolation: Primary 85%, High synergist 15%
  /// - etc.
  ///
  /// Synergist tiers (based on EMG research):
  /// - First synergist (secondary[0]) = High synergist (e.g., anterior delt in bench)
  /// - Other synergists (secondary[1+]) = Moderate synergists (e.g., triceps in bench)
  ///
  /// Example: Bench Press (pushHorizontal) with volume 1000kg
  /// - Primary [PETT]: 600kg
  /// - High synergist [DELT]: 250kg
  /// - Moderate synergist [TRIC]: 150kg
  void _distributeWeightedVolume(
    Map<String, double> muscleVolumes,
    List<String> primary,
    List<String> secondary,
    double volume, {
    MovementPattern movementPattern = MovementPattern.other,
  }) {
    // Get EMG-based tiered ratios for this movement pattern
    final (primaryRatio, highSynergistRatio, moderateSynergistRatio) =
        EmgMovementRatios.getTieredRatios(movementPattern);

    // Calculate primary muscle share
    if (primary.isNotEmpty) {
      final primaryVolume = volume * primaryRatio;
      final perPrimary = primaryVolume / primary.length;
      for (final muscle in primary) {
        final muscleLower = muscle.toLowerCase();
        muscleVolumes[muscleLower] = (muscleVolumes[muscleLower] ?? 0) + perPrimary;
      }
    }

    // Distribute to secondary muscles with tiered approach
    if (secondary.isNotEmpty) {
      // First synergist gets highSynergistRatio
      final firstSynergist = secondary.first.toLowerCase();
      final highVolume = volume * highSynergistRatio;
      muscleVolumes[firstSynergist] = (muscleVolumes[firstSynergist] ?? 0) + highVolume;

      // Remaining synergists split moderateSynergistRatio
      if (secondary.length > 1) {
        final remainingSynergists = secondary.sublist(1);
        final volumePerMod = (volume * moderateSynergistRatio) / remainingSynergists.length;
        for (final muscle in remainingSynergists) {
          final muscleLower = muscle.toLowerCase();
          muscleVolumes[muscleLower] = (muscleVolumes[muscleLower] ?? 0) + volumePerMod;
        }
      }
    }
  }
}

/// Muscle Balance Metrics - Result of balance calculation
///
/// **Properties**:
/// - pushPullRatio: Push volume / Pull volume (optimal: 1.0) - TOTAL
/// - upperPushPullRatio: Upper body Push/Pull ratio (chest+tric+delt_ant vs back+bic+delt_post)
/// - lowerPushPullRatio: Lower body Push/Pull ratio (quads vs hamstrings+glutes)
/// - upperLowerRatio: Upper / Lower volume (optimal: 1.0)
/// - pushPullWarning: True if ratio >1.5 or <0.7
/// - upperLowerWarning: True if ratio >1.5 or <0.7
/// - balanceScore: Overall balance (0-10, 10 = perfect)
/// - neglectedMuscles: Muscles with <5% total volume
/// - topMuscles: Muscles with >15% total volume
/// - muscleVolumePercentages: % of total volume per muscle
///
/// **P1 Enhancement**: Separate upper/lower push-pull ratios for better
/// injury prevention analysis (based on research showing different optimal
/// ratios for upper body vs lower body training).
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
    // P1: Separated upper/lower push-pull ratios
    this.upperPushPullRatio = 1.0,
    this.lowerPushPullRatio = 1.0,
    this.upperPushPullWarning = false,
    this.lowerPushPullWarning = false,
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
        upperPushPullRatio: 1.0,
        lowerPushPullRatio: 1.0,
        upperPushPullWarning: false,
        lowerPushPullWarning: false,
      );

  /// Push/Pull ratio (optimal: 1.0) - TOTAL (upper + lower combined)
  final double pushPullRatio;

  /// Upper body Push/Pull ratio (optimal: 1.0)
  /// Push: chest, triceps, anterior delts
  /// Pull: back, biceps, posterior delts
  final double upperPushPullRatio;

  /// Lower body Push/Pull ratio (optimal: 1.0)
  /// Push: quads
  /// Pull: hamstrings, glutes
  final double lowerPushPullRatio;

  /// Upper/Lower ratio (optimal: 1.0)
  final double upperLowerRatio;

  /// True if TOTAL push/pull imbalance detected (>1.5 or <0.7)
  final bool pushPullWarning;

  /// True if upper body push/pull imbalance detected (>1.5 or <0.7)
  final bool upperPushPullWarning;

  /// True if lower body push/pull imbalance detected (>1.5 or <0.7)
  final bool lowerPushPullWarning;

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
  bool get hasWarnings =>
      pushPullWarning ||
      upperPushPullWarning ||
      lowerPushPullWarning ||
      upperLowerWarning ||
      neglectedMuscles.isNotEmpty;

  /// Get balance score rating
  String get balanceRating {
    if (balanceScore >= 9.0) return 'Excellent';
    if (balanceScore >= 7.5) return 'Good';
    if (balanceScore >= 6.0) return 'Fair';
    if (balanceScore >= 4.0) return 'Needs Improvement';
    return 'Poor';
  }

  // === P3: AUTO-BALANCE RECOMMENDATIONS ===

  /// Generate actionable recommendations to fix detected imbalances
  ///
  /// Analyzes push/pull ratios, upper/lower distribution, and neglected
  /// muscles to generate prioritized suggestions.
  ///
  /// Optional [ffmRecovery] adds FFM-based rest recommendations when
  /// muscles are overtrained.
  ///
  /// Usage:
  /// ```dart
  /// final metrics = calculator.calculateBalance(histories);
  /// final recommendations = metrics.getRecommendations();
  ///
  /// for (final rec in recommendations.recommendations) {
  ///   print('${rec.title}: ${rec.description}');
  /// }
  /// ```
  BalanceRecommendationResult getRecommendations({
    Map<String, MuscleRecoveryPrediction>? ffmRecovery,
  }) {
    return BalanceRecommendationService.generateRecommendations(
      this,
      ffmRecovery: ffmRecovery,
    );
  }

  /// Get next workout suggestion based on detected imbalances
  ///
  /// Returns a short description of what to focus on next.
  /// Returns null if balance is optimal.
  String? get nextWorkoutSuggestion {
    if (!hasWarnings) return null;

    if (upperPushPullWarning) {
      return upperPushPullRatio > 1.0
          ? 'Focus on pull exercises (rows, pull-ups)'
          : 'Focus on push exercises (bench, overhead press)';
    }

    if (lowerPushPullWarning) {
      return lowerPushPullRatio > 1.0
          ? 'Focus on hamstrings/glutes (RDL, hip thrust)'
          : 'Focus on quads (squats, leg press)';
    }

    if (upperLowerWarning) {
      return upperLowerRatio > 1.0
          ? 'Add more leg work to balance upper/lower'
          : 'Add more upper body work';
    }

    if (neglectedMuscles.isNotEmpty) {
      return 'Train ${neglectedMuscles.first} - currently neglected';
    }

    return null;
  }
}
