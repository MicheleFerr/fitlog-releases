/// Predictive Balance - Weekly Pattern Entity
///
/// Represents a detected weekly workout pattern from user history.
/// Used to predict which workouts the user will likely do.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/workout_fingerprint.dart';

part 'weekly_pattern.freezed.dart';
part 'weekly_pattern.g.dart';

/// Detected weekly workout pattern
///
/// Represents the recurring cycle of workouts a user follows.
/// Example: [Push, Pull, Legs] repeated each week.
@freezed
abstract class WeeklyPattern with _$WeeklyPattern {
  const factory WeeklyPattern({
    /// Fingerprints of workouts in the cycle
    /// Order represents typical sequence (e.g., Push → Pull → Legs)
    required List<WorkoutFingerprint> cycle,

    /// Confidence score (0.0 - 1.0)
    /// Based on how consistently the pattern repeats
    required double confidence,

    /// Number of weeks analyzed to detect pattern
    required int weeksAnalyzed,

    /// Number of weeks that matched the pattern
    required int weeksMatched,

    /// When this pattern was last analyzed
    required DateTime analyzedAt,

    /// Average workouts per week in the pattern
    @Default(0) int avgWorkoutsPerWeek,
  }) = _WeeklyPattern;

  const WeeklyPattern._();

  factory WeeklyPattern.fromJson(Map<String, dynamic> json) =>
      _$WeeklyPatternFromJson(json);

  /// Pattern is considered valid if confidence ≥ 66% (2/3 weeks match)
  bool get isValid => confidence >= 0.66;

  /// Pattern is strong if confidence ≥ 80%
  bool get isStrong => confidence >= 0.80;

  /// Number of workouts in the cycle
  int get cycleLength => cycle.length;

  /// Check if pattern is stale (analyzed more than 7 days ago)
  bool get isStale => DateTime.now().difference(analyzedAt).inDays > 7;

  /// Get all muscle groups covered by this pattern
  Set<String> get allMusclesCovered {
    final muscles = <String>{};
    for (final fingerprint in cycle) {
      muscles.addAll(fingerprint.dominantMuscles);
    }
    return muscles;
  }

  /// Get human-readable pattern description
  /// Example: "Push → Pull → Legs (3 workouts/week)"
  String get description {
    final names = cycle.map((f) => f.displayName).join(' → ');
    return '$names (${cycle.length} workouts/week)';
  }
}
