/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/services
/// 🎯 Feature: analytics
/// 🔧 Type: service
///
/// Balance Trend Calculator - Calculates trends and comparisons across time periods
///
/// **Features**:
/// - Trend calculation (improving/stable/declining)
/// - Period-over-period comparison
/// - Percentage change calculation
/// - Time-filtered balance metrics
library;

import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_balance_calculator.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';

/// Time Filter Period
enum TimePeriod {
  last7Days,
  last30Days,
  last3Months,
  lastYear,
  allTime,
}

/// Trend Direction
enum TrendDirection {
  improving, // Balance score increasing
  stable, // Within ±5% change
  declining, // Balance score decreasing
}

/// Balance Trend Data - Contains current metrics, previous metrics, and trend
class BalanceTrendData {
  const BalanceTrendData({
    required this.currentMetrics,
    required this.previousMetrics,
    required this.trendDirection,
    required this.percentageChange,
    required this.period,
  });

  /// Current period balance metrics
  final MuscleBalanceMetrics currentMetrics;

  /// Previous period balance metrics (for comparison)
  final MuscleBalanceMetrics? previousMetrics;

  /// Trend direction based on balance score change
  final TrendDirection trendDirection;

  /// Percentage change in balance score vs previous period
  final double percentageChange;

  /// Selected time period
  final TimePeriod period;

  /// Helper: Get rating for current metrics
  String get currentRating => _getRating(currentMetrics.balanceScore);

  /// Helper: Get rating for previous metrics
  String? get previousRating =>
      previousMetrics != null ? _getRating(previousMetrics!.balanceScore) : null;

  String _getRating(double score) {
    if (score >= 9.0) return 'Excellent';
    if (score >= 7.5) return 'Good';
    if (score >= 6.0) return 'Fair';
    if (score >= 4.0) return 'Needs Improvement';
    return 'Poor';
  }
}

/// Balance Trend Calculator Service
///
/// **Usage**:
/// ```dart
/// final calculator = BalanceTrendCalculator();
/// final trendData = calculator.calculateTrend(
///   exerciseHistories: allHistories,
///   period: TimePeriod.last30Days,
/// );
///
/// print('Current score: ${trendData.currentMetrics.balanceScore}');
/// print('Trend: ${trendData.trendDirection}');
/// print('Change: ${trendData.percentageChange.toStringAsFixed(1)}%');
/// ```
class BalanceTrendCalculator {
  final MuscleBalanceCalculator _balanceCalculator = MuscleBalanceCalculator();

  /// Calculate balance trend with period filtering
  ///
  /// [exerciseMuscleMap] - Optional map of exercise name to ExerciseMuscleData
  /// for weighted primary/secondary muscle distribution. When provided, volume
  /// is distributed: 70% to primary muscles, 30% to secondary muscles.
  BalanceTrendData calculateTrend({
    required List<ExerciseHistory> exerciseHistories,
    required TimePeriod period,
    Map<String, ExerciseMuscleData>? exerciseMuscleMap,
  }) {
    final now = DateTime.now();

    // Get date ranges
    final currentPeriodStart = _getPeriodStartDate(now, period);
    final previousPeriodStart = _getPreviousPeriodStartDate(currentPeriodStart, period);

    // Filter histories for current period
    final currentHistories = _filterHistoriesByDateRange(
      exerciseHistories,
      start: currentPeriodStart,
      end: now,
    );

    // Filter histories for previous period (same duration)
    final previousHistories = _filterHistoriesByDateRange(
      exerciseHistories,
      start: previousPeriodStart,
      end: currentPeriodStart,
    );

    // Calculate metrics with weighted muscle distribution when map is available
    final currentMetrics = _balanceCalculator.calculateBalance(
      currentHistories,
      exerciseMuscleMap: exerciseMuscleMap,
    );
    final previousMetrics = previousHistories.isNotEmpty
        ? _balanceCalculator.calculateBalance(
            previousHistories,
            exerciseMuscleMap: exerciseMuscleMap,
          )
        : null;

    // Calculate trend
    final trendDirection = _calculateTrendDirection(
      currentScore: currentMetrics.balanceScore,
      previousScore: previousMetrics?.balanceScore,
    );

    // Calculate percentage change
    final percentageChange = _calculatePercentageChange(
      currentScore: currentMetrics.balanceScore,
      previousScore: previousMetrics?.balanceScore,
    );

    return BalanceTrendData(
      currentMetrics: currentMetrics,
      previousMetrics: previousMetrics,
      trendDirection: trendDirection,
      percentageChange: percentageChange,
      period: period,
    );
  }

  /// Get start date for the selected period
  DateTime _getPeriodStartDate(DateTime now, TimePeriod period) {
    switch (period) {
      case TimePeriod.last7Days:
        return now.subtract(const Duration(days: 7));
      case TimePeriod.last30Days:
        return now.subtract(const Duration(days: 30));
      case TimePeriod.last3Months:
        return DateTime(now.year, now.month - 3, now.day);
      case TimePeriod.lastYear:
        return DateTime(now.year - 1, now.month, now.day);
      case TimePeriod.allTime:
        return DateTime(2000, 1, 1); // Far past date
    }
  }

  /// Get start date for the previous period (for comparison)
  DateTime _getPreviousPeriodStartDate(DateTime currentPeriodStart, TimePeriod period) {
    switch (period) {
      case TimePeriod.last7Days:
        return currentPeriodStart.subtract(const Duration(days: 7));
      case TimePeriod.last30Days:
        return currentPeriodStart.subtract(const Duration(days: 30));
      case TimePeriod.last3Months:
        return DateTime(
          currentPeriodStart.year,
          currentPeriodStart.month - 3,
          currentPeriodStart.day,
        );
      case TimePeriod.lastYear:
        return DateTime(
          currentPeriodStart.year - 1,
          currentPeriodStart.month,
          currentPeriodStart.day,
        );
      case TimePeriod.allTime:
        return DateTime(2000, 1, 1); // No previous period for all time
    }
  }

  /// Filter exercise histories by date range
  List<ExerciseHistory> _filterHistoriesByDateRange(
    List<ExerciseHistory> histories, {
    required DateTime start,
    required DateTime end,
  }) {
    return histories.map((history) {
      // Filter sessions within date range
      final filteredSessions = history.sessions.where((session) {
        return session.date.isAfter(start) && session.date.isBefore(end);
      }).toList();

      // Return history with filtered sessions
      return ExerciseHistory(
        exerciseName: history.exerciseName,
        muscleGroup: history.muscleGroup,
        sessions: filteredSessions,
      );
    }).where((history) => history.sessions.isNotEmpty).toList();
  }

  /// Calculate trend direction based on balance score change
  TrendDirection _calculateTrendDirection({
    required double currentScore,
    required double? previousScore,
  }) {
    if (previousScore == null) {
      return TrendDirection.stable; // No previous data to compare
    }

    final change = currentScore - previousScore;
    final changePercent = (change / previousScore) * 100;

    if (changePercent > 5.0) {
      return TrendDirection.improving; // >5% improvement
    } else if (changePercent < -5.0) {
      return TrendDirection.declining; // >5% decline
    } else {
      return TrendDirection.stable; // Within ±5%
    }
  }

  /// Calculate percentage change in balance score
  double _calculatePercentageChange({
    required double currentScore,
    required double? previousScore,
  }) {
    if (previousScore == null || previousScore == 0) {
      return 0.0; // No previous data or division by zero
    }

    final change = currentScore - previousScore;
    return (change / previousScore) * 100;
  }

  /// Get duration in days for a time period
  int getPeriodDurationInDays(TimePeriod period) {
    switch (period) {
      case TimePeriod.last7Days:
        return 7;
      case TimePeriod.last30Days:
        return 30;
      case TimePeriod.last3Months:
        return 90;
      case TimePeriod.lastYear:
        return 365;
      case TimePeriod.allTime:
        return 9999; // Special value for "all time"
    }
  }
}
