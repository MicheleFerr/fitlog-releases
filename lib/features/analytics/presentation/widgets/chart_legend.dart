/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// ChartLegend - Color-coded legend for landscape multi-metric chart
///
/// **Purpose**: Display legend showing metric colors for chart interpretation
///
/// **Features**:
/// - Shows only selected metrics (from landscapeMetricsProvider)
/// - Color-coded circles matching chart lines
/// - Localized metric labels
/// - Horizontal layout with wrapping
/// - Theme-aware colors
///
/// **Usage**:
/// ```dart
/// ChartLegend() // Automatically watches selected metrics
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/landscape_metrics_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Chart legend widget showing selected metrics with colors
///
/// **State**: Reactive to landscapeMetricsProvider changes
///
/// **Colors**: Fixed color mapping for each metric
/// - Volume: Primary color
/// - Weight: Secondary color
/// - 1RM: Tertiary color
/// - Weight×Reps: Success color
class ChartLegend extends ConsumerWidget {
  const ChartLegend({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch selected metrics
    final selectedMetrics = ref.watch(landscapeMetricsProvider);

    // If no metrics selected, show nothing
    if (selectedMetrics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(
            color: context.colors.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: selectedMetrics.map((metric) {
          return _LegendItem(
            metric: metric,
            color: _getMetricColor(context, metric),
          );
        }).toList(),
      ),
    );
  }

  /// Get color for metric
  ///
  /// **Color Mapping**:
  /// - Volume: Primary color (blue)
  /// - Weight: Secondary color (orange)
  /// - 1RM: Tertiary color (purple)
  /// - Weight×Reps: Success color (green)
  Color _getMetricColor(BuildContext context, MetricType metric) {
    switch (metric) {
      case MetricType.volume:
        return context.colors.primary;
      case MetricType.weight:
        return context.colors.secondary;
      case MetricType.oneRmEstimated:
        return context.colors.tertiary;
      case MetricType.weightTimesReps:
        return context.colors.success;
    }
  }
}

/// Legend item showing color circle + metric label
class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.metric, required this.color});

  final MetricType metric;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Color circle
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Metric label
        Text(
          _getLabel(context, metric),
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Get localized label for metric
  String _getLabel(BuildContext context, MetricType metric) {
    switch (metric) {
      case MetricType.volume:
        return context.l10n.volume;
      case MetricType.weight:
        return context.l10n.weight;
      case MetricType.oneRmEstimated:
        return context.l10n.oneRmEstimated;
      case MetricType.weightTimesReps:
        return context.l10n.weightTimesReps;
    }
  }
}
