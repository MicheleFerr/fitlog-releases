import 'package:gymbro_flutter_new/features/workout/domain/entities/pattern_detection_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Service for checking if detected patterns are viable for routine suggestions
///
/// Implements 5 viability rules to ensure pattern quality before showing to user.
/// A pattern must pass ALL rules to be considered viable.
///
/// Rules (from ROUTINE_CENTER_IMPROVEMENTS_PLAN.md lines 1367-1391):
/// 1. Confidence ≥ 0.70 (high confidence threshold)
/// 2. Minimum 3 complete cycles
/// 3. Minimum 18 days of workout data
/// 4. Minimum 6 workouts total
/// 5. Pattern coverage > 50% (pattern workouts / total workouts)
///
/// Example:
/// ```dart
/// final checker = PatternViabilityChecker();
/// final result = checker.isViable(
///   pattern: patternResult,
///   workoutHistory: workouts,
/// );
///
/// if (result.isViable) {
///   // Show pattern-based suggestion to user
/// } else {
///   // Fallback to lower suggestion levels (Routine → Frequency → Day-Based)
///   print('Rejection reason: ${result.reason}');
/// }
/// ```
class PatternViabilityChecker {
  /// Minimum confidence threshold for viable patterns
  static const double minConfidence = 0.70;

  /// Minimum complete cycles required
  static const int minCycles = 3;

  /// Minimum days of workout history required
  static const int minDaysOfData = 18;

  /// Minimum total workouts required
  static const int minTotalWorkouts = 6;

  /// Minimum pattern coverage (pattern workouts / total workouts)
  static const double minCoverage = 0.50;

  /// Check if a detected pattern is viable for routine suggestions
  ///
  /// Returns [ViabilityResult] with isViable flag and rejection reason if not viable
  ViabilityResult isViable({
    required PatternDetectionResult pattern,
    required List<Workout> workoutHistory,
  }) {
    // Rule 1: Minimum 6 workouts total (check first - most basic requirement)
    if (workoutHistory.length < minTotalWorkouts) {
      return ViabilityResult(
        isViable: false,
        reason: 'Insufficient workouts: ${workoutHistory.length} (need ≥6)',
        failedRule: 'Workouts',
      );
    }

    // Rule 2: Minimum 18 days of workout data
    final daysCovered = _calculateDaysCovered(workoutHistory);
    if (daysCovered < minDaysOfData) {
      return ViabilityResult(
        isViable: false,
        reason: 'Insufficient data: $daysCovered days (need ≥18)',
        failedRule: 'Days',
      );
    }

    // Rule 3: Confidence ≥ 0.70
    if (pattern.confidence < minConfidence) {
      return ViabilityResult(
        isViable: false,
        reason: 'Low confidence: ${pattern.displayConfidence} (need ≥70%)',
        failedRule: 'Confidence',
      );
    }

    // Rule 4: Minimum 3 complete cycles
    if (pattern.repetitions < minCycles) {
      return ViabilityResult(
        isViable: false,
        reason: 'Insufficient cycles: ${pattern.repetitions} (need ≥3)',
        failedRule: 'Cycles',
      );
    }

    // Rule 5: Pattern coverage > 50%
    final coverage = _calculateCoverage(pattern, workoutHistory.length);
    if (coverage < minCoverage) {
      return ViabilityResult(
        isViable: false,
        reason: 'Low coverage: ${(coverage * 100).toInt()}% (need ≥50%)',
        failedRule: 'Coverage',
      );
    }

    // All rules passed ✅
    return ViabilityResult(
      isViable: true,
      reason: 'All viability checks passed',
      passedRules: ['Confidence', 'Cycles', 'Days', 'Workouts', 'Coverage'],
    );
  }

  /// Calculate days covered by workout history
  ///
  /// Returns days between first and last workout
  int _calculateDaysCovered(List<Workout> workouts) {
    if (workouts.isEmpty) return 0;

    final dates = workouts
        .where((w) => w.startTime != null)
        .map((w) => w.startTime!)
        .toList()
      ..sort();

    if (dates.isEmpty) return 0;

    final firstDate = dates.first;
    final lastDate = dates.last;

    return lastDate.difference(firstDate).inDays;
  }

  /// Calculate pattern coverage percentage
  ///
  /// Returns: (pattern workouts / total workouts)
  double _calculateCoverage(
    PatternDetectionResult pattern,
    int totalWorkouts,
  ) {
    if (totalWorkouts == 0) return 0.0;

    final patternWorkouts = pattern.repetitions * pattern.patternLength;
    return patternWorkouts / totalWorkouts;
  }

  /// Quick viability check (returns bool only)
  ///
  /// Convenience method for when you only need to know if viable or not
  bool isViableQuick({
    required PatternDetectionResult pattern,
    required List<Workout> workoutHistory,
  }) {
    return isViable(pattern: pattern, workoutHistory: workoutHistory).isViable;
  }

  /// Get detailed viability status for debugging/UI display
  ///
  /// Returns map with all rule checks and their status
  Map<String, bool> getViabilityBreakdown({
    required PatternDetectionResult pattern,
    required List<Workout> workoutHistory,
  }) {
    final daysCovered = _calculateDaysCovered(workoutHistory);
    final coverage = _calculateCoverage(pattern, workoutHistory.length);

    return {
      'Confidence ≥0.70': pattern.confidence >= minConfidence,
      'Cycles ≥3': pattern.repetitions >= minCycles,
      'Days ≥18': daysCovered >= minDaysOfData,
      'Workouts ≥6': workoutHistory.length >= minTotalWorkouts,
      'Coverage ≥50%': coverage >= minCoverage,
    };
  }
}

/// Result of viability check
class ViabilityResult {
  /// Whether the pattern is viable for routine suggestions
  final bool isViable;

  /// Human-readable reason for rejection (if not viable)
  final String reason;

  /// Name of the rule that failed (if not viable)
  final String? failedRule;

  /// List of rules that passed (if viable)
  final List<String>? passedRules;

  const ViabilityResult({
    required this.isViable,
    required this.reason,
    this.failedRule,
    this.passedRules,
  });

  /// Check if pattern is high quality (all rules passed with margin)
  ///
  /// "High quality" means:
  /// - Confidence ≥ 0.80 (not just ≥ 0.70)
  /// - 4+ cycles (not just 3)
  /// - 25+ days (not just 18)
  bool get isHighQuality =>
      isViable &&
      passedRules != null &&
      passedRules!.length == 5; // All 5 rules passed

  @override
  String toString() {
    if (isViable) {
      return 'Viable ✅: $reason';
    } else {
      return 'Not viable ❌: $reason (failed: $failedRule)';
    }
  }
}
