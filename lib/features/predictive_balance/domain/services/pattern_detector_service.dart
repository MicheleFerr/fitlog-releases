/// Predictive Balance - Pattern Detector Service
///
/// Core service for detecting weekly workout patterns from user history.
/// Analyzes workout history to find repeating cycles (e.g., Push/Pull/Legs).
library;

import 'dart:collection';

import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/weekly_pattern.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/workout_fingerprint.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';

/// Pattern Detector Service
///
/// Detects weekly workout patterns by analyzing workout history.
///
/// **Algorithm**:
/// 1. Filter workouts from last N weeks
/// 2. Group by ISO week
/// 3. Create fingerprint for each workout
/// 4. Find repeating cycle across weeks
/// 5. Calculate confidence (matched weeks / total weeks)
///
/// **Usage**:
/// ```dart
/// final pattern = PatternDetectorService.detect(
///   history: workoutHistory,
///   muscleMap: exerciseMuscleMap,
/// );
///
/// if (pattern != null && pattern.isValid) {
///   // User has a consistent workout pattern
///   print('Detected ${pattern.cycleLength}-day cycle');
/// }
/// ```
class PatternDetectorService {
  /// Minimum workouts required to detect a pattern
  static const int minWorkoutsForPattern = 6;

  /// Number of weeks to analyze for pattern detection
  static const int weeksToAnalyze = 3;

  /// Minimum confidence threshold for valid pattern
  static const double minConfidence = 0.66;

  /// Detect weekly pattern from workout history
  ///
  /// Returns null if:
  /// - Insufficient data (< 6 workouts)
  /// - Less than 2 weeks of data
  /// - No consistent pattern found
  static WeeklyPattern? detect({
    required List<Workout> history,
    required Map<String, ExerciseMuscleData> muscleMap,
  }) {
    // 1. Filter last N weeks of completed workouts
    final cutoff = DateTime.now().subtract(const Duration(days: weeksToAnalyze * 7));
    final recent = history
        .where(
          (w) =>
              w.status == WorkoutStatus.completed &&
              w.completedAt != null &&
              w.completedAt!.isAfter(cutoff),
        )
        .toList();

    if (recent.length < minWorkoutsForPattern) return null;

    // 2. Group by ISO week
    final byWeek = _groupByIsoWeek(recent);
    if (byWeek.length < 2) return null;

    // 3. Create fingerprints for each workout
    final weekFingerprints = <List<WorkoutFingerprint>>[];
    for (final weekWorkouts in byWeek.values) {
      final fingerprints = weekWorkouts
          .map((w) => _createFingerprint(w, muscleMap))
          .where((f) => f.dominantMuscles.isNotEmpty)
          .toList();
      if (fingerprints.isNotEmpty) {
        weekFingerprints.add(fingerprints);
      }
    }

    if (weekFingerprints.length < 2) return null;

    // 4. Find repeating cycle
    final cycle = _findRepeatingCycle(weekFingerprints);
    if (cycle == null || cycle.isEmpty) return null;

    // 5. Calculate confidence
    final matchedWeeks = _countMatchingWeeks(weekFingerprints, cycle);
    final confidence = matchedWeeks / weekFingerprints.length;

    // Calculate average workouts per week
    final totalWorkouts = weekFingerprints.fold(
      0,
      (sum, week) => sum + week.length,
    );
    final avgWorkoutsPerWeek = (totalWorkouts / weekFingerprints.length)
        .round();

    return WeeklyPattern(
      cycle: cycle,
      confidence: confidence,
      weeksAnalyzed: weekFingerprints.length,
      weeksMatched: matchedWeeks,
      analyzedAt: DateTime.now(),
      avgWorkoutsPerWeek: avgWorkoutsPerWeek,
    );
  }

  /// Group workouts by ISO week number
  static Map<int, List<Workout>> _groupByIsoWeek(List<Workout> workouts) {
    final grouped = SplayTreeMap<int, List<Workout>>();

    for (final workout in workouts) {
      final date = workout.completedAt!;
      final weekKey = _getIsoWeekKey(date);

      grouped.putIfAbsent(weekKey, () => []);
      grouped[weekKey]!.add(workout);
    }

    // Sort each week's workouts by date
    for (final week in grouped.values) {
      week.sort((a, b) => a.completedAt!.compareTo(b.completedAt!));
    }

    return grouped;
  }

  /// Get ISO week number combined with year
  /// Returns YYYYWW format for proper sorting
  static int _getIsoWeekKey(DateTime date) {
    // Calculate ISO week number
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays + 1;
    final weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();

    return date.year * 100 + weekNumber;
  }

  /// Create fingerprint from workout
  static WorkoutFingerprint _createFingerprint(
    Workout workout,
    Map<String, ExerciseMuscleData> muscleMap,
  ) {
    // Calculate volume per muscle
    final muscleVolume = <String, double>{};

    for (final exercise in workout.exercises) {
      final nameLower = exercise.name.toLowerCase();
      final data = muscleMap[exercise.name] ?? muscleMap[nameLower];

      if (data == null || !data.hasData) continue;

      final volume = _calculateExerciseVolume(exercise);

      // Primary muscles get 100% volume credit
      for (final muscle in data.primary) {
        final normalized = normalizeMuscle(muscle);
        muscleVolume[normalized] = (muscleVolume[normalized] ?? 0) + volume;
      }

      // Secondary muscles get 50% volume credit
      for (final muscle in data.secondary) {
        final normalized = normalizeMuscle(muscle);
        muscleVolume[normalized] =
            (muscleVolume[normalized] ?? 0) + volume * 0.5;
      }
    }

    // Get top 3 muscles by volume
    final sorted = muscleVolume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dominantMuscles = sorted.take(3).map((e) => e.key).toList();

    // Infer category from dominant muscles
    final category = inferCategory(dominantMuscles);

    // Calculate total volume
    final totalVolume = muscleVolume.values.fold(0.0, (a, b) => a + b);

    return WorkoutFingerprint(
      id: generateId(dominantMuscles, category),
      templateName: workout.name,
      templateId: workout.templateId,
      dominantMuscles: dominantMuscles,
      category: category,
      totalVolume: totalVolume,
      workoutDate: workout.completedAt,
    );
  }

  /// Calculate volume for an exercise (sets × reps × weight)
  static double _calculateExerciseVolume(Exercise exercise) {
    double total = 0.0;

    for (final set in exercise.sets) {
      if (!set.isCompleted) continue;

      final reps = set.actualReps ?? set.reps ?? 0;
      final weight = set.weight ?? 1.0; // Use 1.0 for bodyweight exercises

      total += reps * weight;
    }

    return total;
  }

  /// Normalize muscle codes from JSON to standard names
  ///
  /// **SINGLE SOURCE OF TRUTH**: Delegates to MuscleAbbreviationMapper.
  /// Exposed for use by PredictionEngineService.
  static String normalizeMuscle(String code) {
    return MuscleAbbreviationMapper.normalizeToHeatmapKey(code);
  }

  /// Infer workout category from dominant muscles
  ///
  /// Exposed for use by PredictionEngineService.
  static WorkoutCategory inferCategory(List<String> muscles) {
    final muscleSet = muscles.toSet();

    // Push: chest, shoulders, triceps
    final hasPushMuscles =
        muscleSet.contains('chest') ||
        muscleSet.contains('shoulders') ||
        muscleSet.contains('triceps');
    final pushCount = [
      if (muscleSet.contains('chest')) 1,
      if (muscleSet.contains('shoulders')) 1,
      if (muscleSet.contains('triceps')) 1,
    ].length;

    // Pull: back, biceps
    final hasPullMuscles =
        muscleSet.contains('back') || muscleSet.contains('biceps');
    final pullCount = [
      if (muscleSet.contains('back')) 1,
      if (muscleSet.contains('biceps')) 1,
    ].length;

    // Legs: quadriceps, hamstrings, glutes, calves
    final hasLegMuscles =
        muscleSet.contains('quadriceps') ||
        muscleSet.contains('hamstrings') ||
        muscleSet.contains('glutes') ||
        muscleSet.contains('calves');
    final legCount = [
      if (muscleSet.contains('quadriceps')) 1,
      if (muscleSet.contains('hamstrings')) 1,
      if (muscleSet.contains('glutes')) 1,
      if (muscleSet.contains('calves')) 1,
    ].length;

    // Pure legs
    if (hasLegMuscles && legCount >= 2 && !hasPushMuscles && !hasPullMuscles) {
      return WorkoutCategory.legs;
    }

    // Pure push
    if (hasPushMuscles && pushCount >= 2 && !hasPullMuscles && !hasLegMuscles) {
      return WorkoutCategory.push;
    }

    // Pure pull
    if (hasPullMuscles && pullCount >= 2 && !hasPushMuscles && !hasLegMuscles) {
      return WorkoutCategory.pull;
    }

    // Upper body (mix of push + pull)
    if ((hasPushMuscles || hasPullMuscles) && !hasLegMuscles) {
      return WorkoutCategory.upper;
    }

    // Lower body
    if (hasLegMuscles && !hasPushMuscles && !hasPullMuscles) {
      return WorkoutCategory.lower;
    }

    // Full body (has both upper and lower)
    if ((hasPushMuscles || hasPullMuscles) && hasLegMuscles) {
      return WorkoutCategory.fullBody;
    }

    return WorkoutCategory.other;
  }

  /// Generate unique ID for fingerprint
  ///
  /// Exposed for use by PredictionEngineService.
  static String generateId(List<String> muscles, WorkoutCategory category) {
    final data = '${category.name}:${muscles.join(',')}';
    final bytes = utf8.encode(data);
    final digest = md5.convert(bytes);
    return digest.toString().substring(0, 8);
  }

  /// Find repeating cycle across weeks
  ///
  /// Uses first week as reference and finds matching fingerprints in other weeks.
  static List<WorkoutFingerprint>? _findRepeatingCycle(
    List<List<WorkoutFingerprint>> weekFingerprints,
  ) {
    if (weekFingerprints.isEmpty) return null;

    // Use most recent complete week as reference
    // (exclude current week if it might be incomplete)
    final referenceWeek = weekFingerprints.length > 1
        ? weekFingerprints[weekFingerprints.length - 2]
        : weekFingerprints.first;

    if (referenceWeek.isEmpty) return null;

    // Deduplicate by category to get unique workout types
    final uniqueTypes = <WorkoutCategory, WorkoutFingerprint>{};
    for (final fp in referenceWeek) {
      if (fp.category != WorkoutCategory.other) {
        // Keep first (or update if new one has template name)
        if (!uniqueTypes.containsKey(fp.category) ||
            (fp.templateName != null && fp.templateName!.isNotEmpty)) {
          uniqueTypes[fp.category] = fp;
        }
      }
    }

    return uniqueTypes.values.toList();
  }

  /// Count how many weeks match the expected cycle
  static int _countMatchingWeeks(
    List<List<WorkoutFingerprint>> weekFingerprints,
    List<WorkoutFingerprint> cycle,
  ) {
    int matchedWeeks = 0;

    for (final weekFps in weekFingerprints) {
      // Count how many cycle items are found in this week
      int matchedItems = 0;

      for (final cycleItem in cycle) {
        final hasMatch = weekFps.any((fp) => fp.matches(cycleItem));
        if (hasMatch) matchedItems++;
      }

      // Week matches if at least 50% of cycle items are present
      if (matchedItems >= (cycle.length / 2).ceil()) {
        matchedWeeks++;
      }
    }

    return matchedWeeks;
  }
}
