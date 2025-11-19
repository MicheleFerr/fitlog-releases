/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/providers
/// 🎯 Feature: analytics
/// 🔧 Type: provider (state management)
///
/// LandscapeMetricsProvider - State management for landscape graph metric selection
///
/// **Purpose**: Track selected metrics for landscape fullscreen graph (multi-select)
///
/// **State**: Set<MetricType> (1-4 metrics can be selected)
///
/// **Default**: {MetricType.volume} (Volume metric selected by default)
///
/// **Methods**:
/// - toggle(metric): Add/remove metric from selection
/// - clear(): Remove all metrics
/// - selectAll(): Select all 4 metrics
///
/// **Usage**:
/// ```dart
/// // Watch selected metrics
/// final selectedMetrics = ref.watch(landscapeMetricsProvider);
///
/// // Toggle metric
/// ref.read(landscapeMetricsProvider.notifier).toggle(MetricType.weight);
///
/// // Clear all
/// ref.read(landscapeMetricsProvider.notifier).clear();
/// ```
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Metric types available for landscape graph
///
/// **Supported Metrics**:
/// - volume: Total volume (weight × reps × sets)
/// - weight: Max weight lifted
/// - oneRmEstimated: Estimated 1-rep max (Brzycki formula)
/// - weightTimesReps: Weight × reps (volume per set)
enum MetricType {
  /// Total volume (weight × reps × sets)
  volume,

  /// Maximum weight lifted
  weight,

  /// Estimated 1-rep max (Brzycki formula)
  oneRmEstimated,

  /// Weight × reps (volume per set)
  weightTimesReps,
}

/// StateNotifier for landscape metrics selection
///
/// **State Management**: Set<MetricType> (immutable set)
///
/// **Default State**: {MetricType.volume} (Volume selected)
class LandscapeMetricsNotifier extends StateNotifier<Set<MetricType>> {
  LandscapeMetricsNotifier() : super({MetricType.volume}); // Default: Volume only

  /// Toggle metric selection
  ///
  /// **Behavior**:
  /// - If metric already selected → remove it
  /// - If metric not selected → add it
  ///
  /// **Note**: Allows 0 selections (user can deselect all)
  void toggle(MetricType metric) {
    if (state.contains(metric)) {
      // Remove metric
      state = {...state}..remove(metric);
    } else {
      // Add metric
      state = {...state, metric};
    }
  }

  /// Clear all metric selections
  ///
  /// **Result**: Empty set (no metrics selected)
  void clear() {
    state = {};
  }

  /// Select all metrics
  ///
  /// **Result**: Set with all 4 metrics
  void selectAll() {
    state = MetricType.values.toSet();
  }

  /// Check if metric is selected
  ///
  /// **Usage**:
  /// ```dart
  /// final isVolumeSelected = ref.read(landscapeMetricsProvider.notifier).isSelected(MetricType.volume);
  /// ```
  bool isSelected(MetricType metric) {
    return state.contains(metric);
  }
}

/// Provider for landscape metrics selection state
///
/// **Scope**: Screen-scoped (state persists while LandscapeGraphScreen is mounted)
///
/// **Default**: {MetricType.volume}
final landscapeMetricsProvider =
    StateNotifierProvider<LandscapeMetricsNotifier, Set<MetricType>>(
  (ref) => LandscapeMetricsNotifier(),
);
