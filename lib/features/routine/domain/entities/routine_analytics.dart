/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain/entities
/// 🎯 Feature: flexible_routine
/// 🔧 Type: entity
/// 🌍 Localization: N/A (domain entity)
/// 🎨 Theme: N/A (domain entity)
/// 📱 Platform: Universal
///
/// ROUTINE ANALYTICS ENTITIES - Domain models for routine statistics and insights
///
/// Features:
/// - Adherence metrics (completion rate, skip rate, recovery rate)
/// - Schedule matching (planned vs actual workouts)
/// - Streak tracking (current, longest)
/// - Template distribution analysis
/// - Automated insights generation
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine_analytics.freezed.dart';
part 'routine_analytics.g.dart';

/// Comprehensive adherence metrics for a routine
///
/// Tracks how well the user is following their planned routine schedule.
/// All rates are expressed as values between 0.0 and 1.0.
@freezed
class RoutineAdherenceMetrics with _$RoutineAdherenceMetrics {
  const factory RoutineAdherenceMetrics({
    /// Overall adherence rate: completedDays / totalPlannedDays
    /// Range: 0.0 (no adherence) to 1.0 (perfect adherence)
    required double adherenceRate,

    /// Total number of days planned in the routine schedule
    required int totalPlannedDays,

    /// Number of days successfully completed
    required int completedDays,

    /// Number of days skipped (not completed on schedule)
    required int skippedDays,

    /// Number of skipped days that were recovered later
    required int recoveredDays,

    /// Current consecutive days without skipping
    required int currentStreak,

    /// Longest streak achieved in this routine
    required int longestStreak,

    /// Distribution of workouts by template ID
    /// Map<templateId, percentageOfTotal>
    required Map<String, double> templateDistribution,

    /// Skip rate: skippedDays / totalPlannedDays
    required double skipRate,

    /// Recovery rate: recoveredDays / skippedDays (0.0 if no skips)
    required double recoveryRate,

    /// Average days between workouts (for consistency analysis)
    required double avgDaysBetweenWorkouts,
  }) = _RoutineAdherenceMetrics;

  factory RoutineAdherenceMetrics.fromJson(Map<String, dynamic> json) =>
      _$RoutineAdherenceMetricsFromJson(json);

  /// Empty metrics for when no data is available
  factory RoutineAdherenceMetrics.empty() => const RoutineAdherenceMetrics(
        adherenceRate: 0.0,
        totalPlannedDays: 0,
        completedDays: 0,
        skippedDays: 0,
        recoveredDays: 0,
        currentStreak: 0,
        longestStreak: 0,
        templateDistribution: {},
        skipRate: 0.0,
        recoveryRate: 0.0,
        avgDaysBetweenWorkouts: 0.0,
      );
}

/// Data point comparing scheduled workout to actual workout
///
/// Used to analyze pattern matching and adherence accuracy.
@freezed
class ScheduleMatchData with _$ScheduleMatchData {
  const factory ScheduleMatchData({
    /// Date of the scheduled workout
    required DateTime date,

    /// Template ID that was scheduled for this day (null if rest day)
    required String? scheduledTemplateId,

    /// Template ID that was actually performed (null if nothing done)
    required String? actualTemplateId,

    /// Whether the actual workout matches the scheduled one
    required bool isMatch,

    /// Whether any workout was completed on this day
    required bool isCompleted,

    /// Whether this day was marked as skipped
    required bool isSkipped,

    /// Whether this day was later recovered
    required bool isRecovered,

    /// Day of week (1 = Monday, 7 = Sunday) for pattern analysis
    required int dayOfWeek,
  }) = _ScheduleMatchData;

  factory ScheduleMatchData.fromJson(Map<String, dynamic> json) =>
      _$ScheduleMatchDataFromJson(json);
}

/// Automated insight generated from routine analytics
///
/// Provides actionable feedback and motivational messages to users.
@freezed
class RoutineInsight with _$RoutineInsight {
  const factory RoutineInsight({
    /// Type of insight (consistency, recovery, performance, motivation)
    required RoutineInsightType type,

    /// Priority level (higher = more important to show)
    required int priority,

    /// Localized message to display to user
    required String message,

    /// Optional action label (e.g., "View Recovery Options")
    String? actionLabel,

    /// Optional route to navigate when action is tapped
    String? actionRoute,

    /// Icon to display with the insight
    String? icon,

    /// Whether this is positive or negative insight
    required bool isPositive,
  }) = _RoutineInsight;

  factory RoutineInsight.fromJson(Map<String, dynamic> json) =>
      _$RoutineInsightFromJson(json);
}

/// Type of routine insight
enum RoutineInsightType {
  /// Insights about workout consistency and streaks
  consistency,

  /// Insights about skip recovery effectiveness
  recovery,

  /// Insights about overall performance trends
  performance,

  /// Motivational messages and celebrations
  motivation,

  /// Warnings about declining adherence
  warning,
}

/// Weekly summary of routine adherence
///
/// Aggregates metrics by week for trend analysis.
@freezed
class WeeklyAdherenceSummary with _$WeeklyAdherenceSummary {
  const factory WeeklyAdherenceSummary({
    /// Start date of the week (Monday)
    required DateTime weekStart,

    /// End date of the week (Sunday)
    required DateTime weekEnd,

    /// Adherence rate for this week
    required double adherenceRate,

    /// Number of workouts planned this week
    required int plannedWorkouts,

    /// Number of workouts completed this week
    required int completedWorkouts,

    /// Number of days skipped this week
    required int skippedDays,

    /// Number of days recovered this week
    required int recoveredDays,
  }) = _WeeklyAdherenceSummary;

  factory WeeklyAdherenceSummary.fromJson(Map<String, dynamic> json) =>
      _$WeeklyAdherenceSummaryFromJson(json);
}

/// Day-of-week adherence pattern
///
/// Shows which days of the week the user is most/least consistent.
@freezed
class DayOfWeekPattern with _$DayOfWeekPattern {
  const factory DayOfWeekPattern({
    /// Day of week (1 = Monday, 7 = Sunday)
    required int dayOfWeek,

    /// Number of times this day was scheduled
    required int timesScheduled,

    /// Number of times workout was completed on this day
    required int timesCompleted,

    /// Adherence rate for this specific day of week
    required double adherenceRate,

    /// Average skip rate for this day
    required double skipRate,
  }) = _DayOfWeekPattern;

  factory DayOfWeekPattern.fromJson(Map<String, dynamic> json) =>
      _$DayOfWeekPatternFromJson(json);
}

/// Complete analytics state for a routine
///
/// Aggregates all analytics data for presentation layer.
@freezed
class RoutineAnalyticsState with _$RoutineAnalyticsState {
  const factory RoutineAnalyticsState({
    /// Routine ID being analyzed
    required String routineId,

    /// Routine name
    required String routineName,

    /// Overall adherence metrics
    required RoutineAdherenceMetrics adherenceMetrics,

    /// Schedule matching data points
    required List<ScheduleMatchData> scheduleMatchData,

    /// Weekly summaries for trend analysis
    required List<WeeklyAdherenceSummary> weeklySummaries,

    /// Day of week patterns
    required List<DayOfWeekPattern> dayOfWeekPatterns,

    /// Generated insights
    required List<RoutineInsight> insights,

    /// Whether data is currently loading
    @Default(false) bool isLoading,

    /// Error message if loading failed
    String? error,

    /// Last updated timestamp
    DateTime? lastUpdated,
  }) = _RoutineAnalyticsState;

  factory RoutineAnalyticsState.fromJson(Map<String, dynamic> json) =>
      _$RoutineAnalyticsStateFromJson(json);

  /// Empty state for initialization
  factory RoutineAnalyticsState.empty(String routineId, String routineName) =>
      RoutineAnalyticsState(
        routineId: routineId,
        routineName: routineName,
        adherenceMetrics: RoutineAdherenceMetrics.empty(),
        scheduleMatchData: [],
        weeklySummaries: [],
        dayOfWeekPatterns: [],
        insights: [],
      );

  /// Loading state
  factory RoutineAnalyticsState.loading(String routineId, String routineName) =>
      RoutineAnalyticsState(
        routineId: routineId,
        routineName: routineName,
        adherenceMetrics: RoutineAdherenceMetrics.empty(),
        scheduleMatchData: [],
        weeklySummaries: [],
        dayOfWeekPatterns: [],
        insights: [],
        isLoading: true,
      );
}
