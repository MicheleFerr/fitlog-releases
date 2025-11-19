/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/usecases
/// 🎯 Feature: analytics
/// 🔧 Type: use case
///
/// NormalizeMetricsUseCase - Normalize exercise metrics to 0-100 scale for charting
///
/// **Purpose**: Convert different metric scales (volume, weight, 1RM, weight×reps)
/// to a unified 0-100 scale for multi-line chart comparison
///
/// **Algorithm**: Min-Max Normalization
/// ```
/// normalizedValue = ((value - min) / (max - min)) × 100
/// ```
///
/// **Example**:
/// ```dart
/// // Volume data: [800, 1200, 1000] kg
/// // Min: 800, Max: 1200
/// // Normalized: [0, 100, 50]
/// ```
///
/// **Edge Cases**:
/// - All values equal (min == max) → all normalized to 100
/// - Single data point → normalized to 100
/// - Empty data → returns empty list
///
/// **Usage**:
/// ```dart
/// final useCase = NormalizeMetricsUseCase();
/// final normalized = useCase.call(
///   history: exerciseHistory,
///   selectedMetrics: {MetricType.volume, MetricType.weight},
/// );
/// ```
library;

import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/landscape_metrics_provider.dart';

/// Normalized data point for charting
///
/// **Properties**:
/// - date: When the session occurred
/// - normalizedValue: Value scaled to 0-100 range
/// - originalValue: Original metric value (for tooltips)
class NormalizedDataPoint {
  const NormalizedDataPoint({
    required this.date,
    required this.normalizedValue,
    required this.originalValue,
  });

  /// Session date
  final DateTime date;

  /// Value normalized to 0-100 scale
  final double normalizedValue;

  /// Original metric value before normalization
  ///
  /// Used for tooltips to show actual values (e.g., "1200 kg")
  final double originalValue;
}

/// Use case for normalizing exercise metrics to 0-100 scale
///
/// **Design Pattern**: Use Case (Clean Architecture)
///
/// **Benefits**:
/// - Allows comparison of different metric types on same chart
/// - Ensures all lines are visible (no tiny lines for small values)
/// - Maintains proportional relationships between data points
class NormalizeMetricsUseCase {
  /// Normalize selected metrics for the given exercise history
  ///
  /// **Parameters**:
  /// - history: Exercise history with all sessions
  /// - selectedMetrics: Metrics to normalize (1-4 metrics)
  ///
  /// **Returns**: Map of metric type to normalized data points
  ///
  /// **Empty Results**:
  /// - If no sessions → returns empty map
  /// - If metric not selected → not included in result
  ///
  /// **Performance**: O(n × m) where n = sessions, m = selected metrics
  Map<MetricType, List<NormalizedDataPoint>> call({
    required ExerciseHistory history,
    required Set<MetricType> selectedMetrics,
  }) {
    // Early return if no sessions or no metrics selected
    if (history.sessions.isEmpty || selectedMetrics.isEmpty) {
      return {};
    }

    final result = <MetricType, List<NormalizedDataPoint>>{};

    // Normalize each selected metric independently
    for (final metric in selectedMetrics) {
      result[metric] = _normalizeMetric(history, metric);
    }

    return result;
  }

  /// Normalize a single metric across all sessions
  ///
  /// **Algorithm**:
  /// 1. Extract metric values from all sessions
  /// 2. Find min and max values
  /// 3. Apply min-max normalization: ((value - min) / (max - min)) × 100
  /// 4. Handle edge case: if min == max, all values = 100
  ///
  /// **Returns**: List of normalized data points sorted by date ascending
  List<NormalizedDataPoint> _normalizeMetric(
    ExerciseHistory history,
    MetricType metric,
  ) {
    // Extract metric values from sessions
    final values = history.sessions.map((session) {
      return _extractMetricValue(session, metric);
    }).toList();

    // Find min and max for normalization
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    // Edge case: all values are equal
    if (minValue == maxValue) {
      // Return all values as 100 (no variation)
      return history.sessions.map((session) {
        return NormalizedDataPoint(
          date: session.date,
          normalizedValue: 100.0,
          originalValue: minValue,
        );
      }).toList();
    }

    // Apply min-max normalization
    final normalized = <NormalizedDataPoint>[];
    for (int i = 0; i < history.sessions.length; i++) {
      final session = history.sessions[i];
      final originalValue = values[i];

      // Normalize: ((value - min) / (max - min)) × 100
      final normalizedValue =
          ((originalValue - minValue) / (maxValue - minValue)) * 100;

      normalized.add(
        NormalizedDataPoint(
          date: session.date,
          normalizedValue: normalizedValue,
          originalValue: originalValue,
        ),
      );
    }

    // Sort by date ascending (for charting)
    normalized.sort((a, b) => a.date.compareTo(b.date));

    return normalized;
  }

  /// Extract metric value from a session
  ///
  /// **Metric Extraction**:
  /// - volume: session.totalVolume
  /// - weight: session.maxWeight
  /// - oneRmEstimated: session.highestEstimated1RM
  /// - weightTimesReps: max(set.volume) across all sets
  ///
  /// **Returns**: Metric value as double
  double _extractMetricValue(ExerciseSession session, MetricType metric) {
    switch (metric) {
      case MetricType.volume:
        return session.totalVolume;

      case MetricType.weight:
        return session.maxWeight;

      case MetricType.oneRmEstimated:
        return session.highestEstimated1RM;

      case MetricType.weightTimesReps:
        // Find max weight×reps among all sets in this session
        if (session.sets.isEmpty) return 0;
        return session.sets
            .map((set) => set.volume) // volume = weight × reps
            .reduce((a, b) => a > b ? a : b);
    }
  }
}
