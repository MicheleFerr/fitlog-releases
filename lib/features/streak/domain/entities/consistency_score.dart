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
enum OvertrainingRisk {
  low,
  medium,
  high,
}

/// Consistency score entity - measures workout adherence quality
@freezed
class ConsistencyScore with _$ConsistencyScore {
  const factory ConsistencyScore({
    /// Overall consistency score (0-100)
    @Default(0) int overallScore,

    /// Score rating text (Excellent, Good, Fair, Poor)
    @Default('Not Available') String scoreRating,

    /// Score rating (Excellent, Good, Fair, Poor) - DEPRECATED, use scoreRating
    @Default('Not Available') String rating,

    /// Risk level (Low, Medium, High) - string version
    @Default('Unknown') String riskLevel,

    /// Overtraining risk level (enum)
    @Default(OvertrainingRisk.low) OvertrainingRisk overtrainingRisk,

    /// Frequency score component (0-100) - changed to int for widget compatibility
    @Default(0) int frequencyScore,

    /// Rest score component (0-100) - changed to int for widget compatibility
    @Default(0) int restScore,

    /// Volume score component (0-100) - changed to int for widget compatibility
    @Default(0) int volumeScore,

    /// Progression score component (0-100) - changed to int for widget compatibility
    @Default(0) int progressionScore,

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
  }) = _ConsistencyScore;

  factory ConsistencyScore.fromJson(Map<String, dynamic> json) =>
      _$ConsistencyScoreFromJson(json);

  /// Factory for empty/default score
  factory ConsistencyScore.empty() => ConsistencyScore(
        overallScore: 0,
        scoreRating: 'Not Available',
        rating: 'Not Available',
        riskLevel: 'Unknown',
        overtrainingRisk: OvertrainingRisk.low,
        frequencyScore: 0,
        restScore: 0,
        volumeScore: 0,
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
