/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/entities
/// 🎯 Feature: ai_coach
/// 🔧 Type: entity
///
/// Health Metric Entity - Domain model for health data from HealthKit
///
/// **Supported Metrics**:
/// - Steps (daily count)
/// - Heart Rate (BPM)
/// - Active Energy (kcal)
/// - Exercise Time (minutes)
/// - Workout Session (type, duration, calories)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_metric.freezed.dart';
part 'health_metric.g.dart';

/// Health metric type enum
enum HealthMetricType {
  /// Daily step count
  steps,

  /// Heart rate (beats per minute)
  heartRate,

  /// Active energy burned (kcal)
  activeEnergy,

  /// Exercise time (minutes)
  exerciseTime,

  /// Workout session
  workout,
}

/// Health metric entity (immutable)
///
/// **Usage**:
/// ```dart
/// final metric = HealthMetric(
///   type: HealthMetricType.steps,
///   value: 8500,
///   unit: 'count',
///   dateFrom: DateTime.now().subtract(Duration(hours: 24)),
///   dateTo: DateTime.now(),
/// );
/// ```
@freezed
abstract class HealthMetric with _$HealthMetric {
  const factory HealthMetric({
    /// Metric type (steps, heart rate, etc.)
    required HealthMetricType type,

    /// Numeric value (e.g., 8500 steps, 72 BPM)
    required double value,

    /// Unit of measurement (count, bpm, kcal, minutes)
    required String unit,

    /// Start timestamp for metric collection
    required DateTime dateFrom,

    /// End timestamp for metric collection
    required DateTime dateTo,

    /// Source device (optional)
    String? sourceDevice,

    /// Source app (optional)
    String? sourceApp,

    /// Workout type (for HealthMetricType.workout only)
    String? workoutType,

    /// Workout duration (seconds, for HealthMetricType.workout only)
    int? workoutDuration,

    /// Workout distance (meters, for HealthMetricType.workout only)
    double? workoutDistance,
  }) = _HealthMetric;

  factory HealthMetric.fromJson(Map<String, dynamic> json) =>
      _$HealthMetricFromJson(json);
}

/// Extension for HealthMetric convenience methods
extension HealthMetricX on HealthMetric {
  /// Get formatted value with unit
  ///
  /// Examples:
  /// - "8,500 steps"
  /// - "72 BPM"
  /// - "350 kcal"
  String get formattedValue {
    switch (type) {
      case HealthMetricType.steps:
        return '${value.toInt().toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )} steps';
      case HealthMetricType.heartRate:
        return '${value.toInt()} BPM';
      case HealthMetricType.activeEnergy:
        return '${value.toInt()} kcal';
      case HealthMetricType.exerciseTime:
        return '${value.toInt()} min';
      case HealthMetricType.workout:
        return workoutType ?? 'Workout';
    }
  }

  /// Get duration in hours (difference between dateTo and dateFrom)
  Duration get duration => dateTo.difference(dateFrom);

  /// Check if metric is from today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dateFrom.isAfter(today) || dateFrom.isAtSameMomentAs(today);
  }

  /// Check if metric is from this week (last 7 days)
  bool get isThisWeek {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    return dateFrom.isAfter(lastWeek);
  }

  /// Check if metric is a workout session
  bool get isWorkout => type == HealthMetricType.workout;

  /// Get workout duration in minutes (for workout metrics only)
  int? get workoutDurationMinutes {
    if (!isWorkout || workoutDuration == null) return null;
    return (workoutDuration! / 60).round();
  }

  /// Get workout distance in kilometers (for workout metrics only)
  double? get workoutDistanceKm {
    if (!isWorkout || workoutDistance == null) return null;
    return workoutDistance! / 1000;
  }
}

/// Aggregate health metrics (for summaries)
///
/// **Usage**:
/// ```dart
/// final summary = HealthMetricSummary(
///   metricType: HealthMetricType.steps,
///   totalValue: 50000,
///   averageValue: 7142,
///   minValue: 4500,
///   maxValue: 10500,
///   dataPoints: 7,
///   periodStart: lastWeek,
///   periodEnd: now,
/// );
/// ```
@freezed
abstract class HealthMetricSummary with _$HealthMetricSummary {
  const factory HealthMetricSummary({
    /// Metric type being summarized
    required HealthMetricType metricType,

    /// Total/sum of all values in period
    required double totalValue,

    /// Average value per day
    required double averageValue,

    /// Minimum value in period
    required double minValue,

    /// Maximum value in period
    required double maxValue,

    /// Number of data points
    required int dataPoints,

    /// Period start
    required DateTime periodStart,

    /// Period end
    required DateTime periodEnd,

    /// Unit of measurement
    required String unit,
  }) = _HealthMetricSummary;

  factory HealthMetricSummary.fromJson(Map<String, dynamic> json) =>
      _$HealthMetricSummaryFromJson(json);
}

/// Extension for HealthMetricSummary convenience methods
extension HealthMetricSummaryX on HealthMetricSummary {
  /// Get formatted total value with unit
  String get formattedTotal {
    switch (metricType) {
      case HealthMetricType.steps:
        return '${totalValue.toInt().toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )} steps';
      case HealthMetricType.heartRate:
        return '${averageValue.toInt()} BPM avg';
      case HealthMetricType.activeEnergy:
        return '${totalValue.toInt()} kcal';
      case HealthMetricType.exerciseTime:
        return '${totalValue.toInt()} min';
      case HealthMetricType.workout:
        return '$dataPoints workouts';
    }
  }

  /// Get period duration in days
  int get periodDays => periodEnd.difference(periodStart).inDays;

  /// Get average per day (different from averageValue which is avg of data points)
  double get averagePerDay {
    if (periodDays == 0) return totalValue;
    return totalValue / periodDays;
  }
}
