/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/streak/domain/entities
/// 🎯 Feature: streak
/// 🔧 Type: entity
///
/// Weekly Statistics Entity - Aggregated weekly workout data
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_stats.freezed.dart';
part 'weekly_stats.g.dart';

/// Weekly statistics entity - aggregated workout metrics for 7-day period
@freezed
abstract class WeeklyStats with _$WeeklyStats {
  const factory WeeklyStats({
    /// Average workouts completed per week
    @Default(0.0) double avgWorkoutsPerWeek,

    /// Average rest days per week
    @Default(0.0) double avgRestDaysPerWeek,

    /// Total workouts in period
    @Default(0) int totalWorkouts,

    /// Total rest days in period
    @Default(0) int totalRestDays,

    /// Total active days (days with at least one workout)
    @Default(0) int totalActiveDays,

    /// Week start date
    DateTime? weekStartDate,

    /// Week end date
    DateTime? weekEndDate,
  }) = _WeeklyStats;

  factory WeeklyStats.fromJson(Map<String, dynamic> json) =>
      _$WeeklyStatsFromJson(json);

  /// Factory for empty/default stats
  factory WeeklyStats.empty() => const WeeklyStats(
    avgWorkoutsPerWeek: 0.0,
    avgRestDaysPerWeek: 7.0, // Default: all rest days
    totalWorkouts: 0,
    totalRestDays: 7,
    totalActiveDays: 0,
  );
}
