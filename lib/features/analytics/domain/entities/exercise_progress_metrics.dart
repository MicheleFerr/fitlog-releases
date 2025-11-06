import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_progress_metrics.freezed.dart';

/// Metrics for a specific exercise across all workouts
@freezed
class ExerciseProgressMetrics with _$ExerciseProgressMetrics {
  const factory ExerciseProgressMetrics({
    required String exerciseName,
    required int totalSessions,
    required double maxWeight,
    required double averageWeight,
    required double averageReps,
    required double averageRPE,
    required double totalVolume,
    required DateTime lastWorkoutDate,
    required TrendDirection weightTrend,
    required TrendDirection volumeTrend,
    required List<ExerciseSetData> allSets,
  }) = _ExerciseProgressMetrics;

  const ExerciseProgressMetrics._();

  /// Get sets within a specific time period
  List<ExerciseSetData> getSetsInPeriod(TimePeriod period) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (period) {
      case TimePeriod.week:
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case TimePeriod.month:
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case TimePeriod.threeMonths:
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case TimePeriod.year:
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
      case TimePeriod.all:
        return allSets;
    }

    return allSets.where((set) => set.date.isAfter(cutoffDate)).toList();
  }
}

/// Individual set data for charting
@freezed
class ExerciseSetData with _$ExerciseSetData {
  const factory ExerciseSetData({
    required DateTime date,
    required double weight,
    required int reps,
    required int? rpe,
    required double volume,
    required String workoutName,
  }) = _ExerciseSetData;
}

/// Trend direction for metrics
enum TrendDirection {
  improving,
  declining,
  stable,
}

/// Time period for filtering data
enum TimePeriod {
  week,
  month,
  threeMonths,
  year,
  all,
}

/// Extension to calculate trend
extension TrendCalculation on List<ExerciseSetData> {
  TrendDirection calculateWeightTrend() {
    if (length < 2) return TrendDirection.stable;

    // Compare first half vs second half
    final midPoint = length ~/ 2;
    final firstHalf = sublist(0, midPoint);
    final secondHalf = sublist(midPoint);

    final firstAvg = firstHalf.fold<double>(0, (sum, set) => sum + set.weight) / firstHalf.length;
    final secondAvg = secondHalf.fold<double>(0, (sum, set) => sum + set.weight) / secondHalf.length;

    final difference = secondAvg - firstAvg;
    final percentChange = (difference / firstAvg) * 100;

    if (percentChange > 5) return TrendDirection.improving;
    if (percentChange < -5) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  TrendDirection calculateVolumeTrend() {
    if (length < 2) return TrendDirection.stable;

    final midPoint = length ~/ 2;
    final firstHalf = sublist(0, midPoint);
    final secondHalf = sublist(midPoint);

    final firstAvg = firstHalf.fold<double>(0, (sum, set) => sum + set.volume) / firstHalf.length;
    final secondAvg = secondHalf.fold<double>(0, (sum, set) => sum + set.volume) / secondHalf.length;

    final difference = secondAvg - firstAvg;
    final percentChange = (difference / firstAvg) * 100;

    if (percentChange > 5) return TrendDirection.improving;
    if (percentChange < -5) return TrendDirection.declining;
    return TrendDirection.stable;
  }
}
