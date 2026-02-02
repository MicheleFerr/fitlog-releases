/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/streak/domain/entities
/// 🎯 Feature: streak
/// 🔧 Type: entity
///
/// Consistency Score Entity - Workout adherence quality metrics
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/weekly_stats.dart';

part 'consistency_score.freezed.dart';
part 'consistency_score.g.dart';

/// Overtraining risk level
enum OvertrainingRisk { low, medium, high }

/// Consistency score entity - measures workout adherence quality
@freezed
abstract class ConsistencyScore with _$ConsistencyScore {
  const factory ConsistencyScore({
    // NEW: Binary indicators (100% validated thresholds)
    /// Frequency is optimal (3-5 workouts per week)
    /// Source: Schoenfeld et al. 2019 (PMID: 30558493)
    @Default(false) bool frequencyOptimal,

    /// Rest is optimal (2-3 rest days per week)
    /// Source: UCLA Health 2024 - <2 days = 5.2x injury risk
    @Default(false) bool restOptimal,

    /// Progression is positive (>5% improvement)
    /// Source: NASM 2023 - Progressive overload guidelines
    @Default(false) bool progressionPositive,

    // EXISTING: Detailed scores (keep for breakdown view)
    /// Frequency score component (0-100) - changed to int for widget compatibility
    @Default(0) int frequencyScore,

    /// Rest score component (0-100) - changed to int for widget compatibility
    @Default(0) int restScore,

    /// Progression score component (0-100) - changed to int for widget compatibility
    @Default(0) int progressionScore,

    // EXISTING: Statistics
    /// Weekly statistics (aggregated 7-day metrics)
    required WeeklyStats weeklyStats,

    /// Number of workouts completed
    @Default(0) int workoutsCompleted,

    /// Number of workouts skipped
    @Default(0) int workoutsSkipped,

    /// Average workout frequency (workouts per week)
    @Default(0.0) double avgFrequency,

    /// Longest workout streak (consecutive days)
    @Default(0) int longestStreak,

    /// Current workout streak (consecutive days)
    @Default(0) int currentStreak,

    /// Timestamp of calculation
    DateTime? calculatedAt,

    // DEPRECATED: Keep for backward compatibility (1 version)
    /// Overall consistency score (0-100)
    @Deprecated(
      'Use frequencyOptimal, restOptimal, progressionPositive instead',
    )
    int? overallScore,

    /// Score rating text (Excellent, Good, Fair, Poor)
    @Deprecated('Use binary indicators instead') String? scoreRating,

    /// Score rating (Excellent, Good, Fair, Poor) - DEPRECATED, use scoreRating
    @Deprecated('Use binary indicators instead') String? rating,

    /// Risk level (Low, Medium, High) - string version
    @Deprecated('Use binary indicators instead') String? riskLevel,

    /// Overtraining risk level (enum)
    @Deprecated('Insufficient indicators - requires HR monitoring')
    OvertrainingRisk? overtrainingRisk,

    /// Volume score component (0-100) - changed to int for widget compatibility
    @Deprecated('Total volume too generic - needs per-muscle-group')
    int? volumeScore,
  }) = _ConsistencyScore;

  factory ConsistencyScore.fromJson(Map<String, dynamic> json) =>
      _$ConsistencyScoreFromJson(json);

  /// Creates empty score with all indicators false
  factory ConsistencyScore.empty() => ConsistencyScore(
    frequencyOptimal: false,
    restOptimal: false,
    progressionPositive: false,
    frequencyScore: 0,
    restScore: 0,
    progressionScore: 0,
    weeklyStats: WeeklyStats.empty(),
    workoutsCompleted: 0,
    workoutsSkipped: 0,
    avgFrequency: 0.0,
    longestStreak: 0,
    currentStreak: 0,
    calculatedAt: DateTime.now(),
  );
}
