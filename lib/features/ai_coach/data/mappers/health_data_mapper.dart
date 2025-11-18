/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/mappers
/// 🎯 Feature: ai_coach
/// 🔧 Type: mapper
///
/// Health Data Mapper - Converts HealthKit data to domain entities
///
/// **Mapping**:
/// - `HealthDataPoint` (health package) → `HealthMetric` (domain)
/// - `List<HealthDataPoint>` → `HealthMetricSummary` (aggregated)
library;

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/health_metric.dart';

/// Mapper for HealthKit data to domain entities
///
/// **Usage**:
/// ```dart
/// final dataPoint = await health.getHealthDataFromTypes(...);
/// final metric = HealthDataMapper.toHealthMetric(dataPoint.first);
/// ```
class HealthDataMapper {
  /// Convert HealthDataPoint to HealthMetric
  ///
  /// Returns `null` if data point is invalid or unsupported type
  static HealthMetric? toHealthMetric(HealthDataPoint dataPoint) {
    try {
      // Map HealthDataType to HealthMetricType
      final metricType = _mapHealthDataType(dataPoint.type);
      if (metricType == null) return null;

      // Extract numeric value
      final value = _extractValue(dataPoint.value);
      if (value == null) return null;

      // Extract unit
      final unit = _mapUnit(dataPoint.unit);

      // Handle workout-specific data
      String? workoutType;
      int? workoutDuration;
      double? workoutDistance;

      if (dataPoint.type == HealthDataType.WORKOUT) {
        final workoutValue = dataPoint.value as WorkoutHealthValue?;
        workoutType = workoutValue?.workoutActivityType.name;
        // Duration calculated from timestamp difference (in seconds)
        workoutDuration = dataPoint.dateTo.difference(dataPoint.dateFrom).inSeconds;
        workoutDistance = workoutValue?.totalDistance?.toDouble();
      }

      return HealthMetric(
        type: metricType,
        value: value,
        unit: unit,
        dateFrom: dataPoint.dateFrom,
        dateTo: dataPoint.dateTo,
        sourceDevice: dataPoint.sourceDeviceId,
        sourceApp: dataPoint.sourceName,
        workoutType: workoutType,
        workoutDuration: workoutDuration,
        workoutDistance: workoutDistance,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthDataMapper] Error mapping data point: $e');
      }
      return null;
    }
  }

  /// Convert list of HealthDataPoints to list of HealthMetrics
  ///
  /// Filters out invalid data points
  static List<HealthMetric> toHealthMetrics(List<HealthDataPoint> dataPoints) {
    return dataPoints
        .map(toHealthMetric)
        .where((metric) => metric != null)
        .cast<HealthMetric>()
        .toList();
  }

  /// Aggregate list of HealthDataPoints into HealthMetricSummary
  ///
  /// Returns `null` if no valid data points
  static HealthMetricSummary? toHealthMetricSummary(
    List<HealthDataPoint> dataPoints,
  ) {
    if (dataPoints.isEmpty) return null;

    try {
      // Convert to metrics
      final metrics = toHealthMetrics(dataPoints);
      if (metrics.isEmpty) return null;

      // All metrics should be same type
      final metricType = metrics.first.type;

      // Calculate aggregates
      double totalValue = 0;
      double minValue = double.infinity;
      double maxValue = double.negativeInfinity;

      for (final metric in metrics) {
        totalValue += metric.value;
        if (metric.value < minValue) minValue = metric.value;
        if (metric.value > maxValue) maxValue = metric.value;
      }

      final averageValue = totalValue / metrics.length;

      // Get period range
      final dateFrom = metrics.map((m) => m.dateFrom).reduce(
            (a, b) => a.isBefore(b) ? a : b,
          );
      final dateTo = metrics.map((m) => m.dateTo).reduce(
            (a, b) => a.isAfter(b) ? a : b,
          );

      return HealthMetricSummary(
        metricType: metricType,
        totalValue: totalValue,
        averageValue: averageValue,
        minValue: minValue,
        maxValue: maxValue,
        dataPoints: metrics.length,
        periodStart: dateFrom,
        periodEnd: dateTo,
        unit: metrics.first.unit,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthDataMapper] Error creating summary: $e');
      }
      return null;
    }
  }

  /// Convert HealthMetric back to Map (for Firebase storage)
  ///
  /// Used by sync service to store metrics in Firebase
  static Map<String, dynamic> toFirebaseMap(HealthMetric metric) {
    return {
      'type': metric.type.name,
      'value': metric.value,
      'unit': metric.unit,
      'date_from': metric.dateFrom.toIso8601String(),
      'date_to': metric.dateTo.toIso8601String(),
      'source_device': metric.sourceDevice,
      'source_app': metric.sourceApp,
      if (metric.workoutType != null) 'workout_type': metric.workoutType,
      if (metric.workoutDuration != null)
        'workout_duration': metric.workoutDuration,
      if (metric.workoutDistance != null)
        'workout_distance': metric.workoutDistance,
    };
  }

  /// Convert list of HealthMetrics to Firebase-friendly Map
  ///
  /// Used by sync service for batch storage
  static Map<String, dynamic> metricsToFirebaseMap(
    List<HealthMetric> metrics,
  ) {
    final map = <String, dynamic>{};

    // Group by type
    for (final type in HealthMetricType.values) {
      final metricsOfType = metrics.where((m) => m.type == type).toList();

      if (metricsOfType.isNotEmpty) {
        map['${type.name}_metrics'] = metricsOfType
            .map((m) => toFirebaseMap(m))
            .toList();
      }
    }

    map['synced_at'] = DateTime.now().toIso8601String();
    map['total_metrics'] = metrics.length;

    return map;
  }

  // ==========================================
  // PRIVATE HELPER METHODS
  // ==========================================

  /// Map HealthDataType to HealthMetricType
  static HealthMetricType? _mapHealthDataType(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return HealthMetricType.steps;
      case HealthDataType.HEART_RATE:
        return HealthMetricType.heartRate;
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return HealthMetricType.activeEnergy;
      case HealthDataType.EXERCISE_TIME:
        return HealthMetricType.exerciseTime;
      case HealthDataType.WORKOUT:
        return HealthMetricType.workout;
      default:
        return null; // Unsupported type
    }
  }

  /// Extract numeric value from HealthValue
  static double? _extractValue(HealthValue value) {
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    } else if (value is WorkoutHealthValue) {
      // For workouts, return duration in minutes
      return (value.totalEnergyBurned ?? 0).toDouble();
    }
    return null;
  }

  /// Map HealthDataUnit to string unit
  static String _mapUnit(HealthDataUnit unit) {
    switch (unit) {
      case HealthDataUnit.COUNT:
        return 'count';
      case HealthDataUnit.BEATS_PER_MINUTE:
        return 'bpm';
      case HealthDataUnit.KILOCALORIE:
        return 'kcal';
      case HealthDataUnit.MINUTE:
        return 'min';
      case HealthDataUnit.METER:
        return 'm';
      case HealthDataUnit.KILOGRAM:
        return 'kg';
      default:
        return unit.name.toLowerCase();
    }
  }
}
