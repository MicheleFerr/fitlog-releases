/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// MetricChip - Filter chip for metric selection in landscape graph
///
/// **Purpose**: Display selectable metric chip with Material Design styling
///
/// **Features**:
/// - Multi-select behavior (toggle on tap)
/// - Haptic feedback on selection
/// - Theme-aware colors (primary color for selected)
/// - Checkmark indicator when selected
/// - Localized labels
///
/// **Usage**:
/// ```dart
/// MetricChip(metric: MetricType.volume)
/// MetricChip(metric: MetricType.weight)
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/landscape_metrics_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Selectable metric chip widget
///
/// **Material Design**: FilterChip with multi-select support
///
/// **State**: Managed by landscapeMetricsProvider
class MetricChip extends ConsumerWidget {
  const MetricChip({required this.metric, super.key});

  /// Metric type to display
  final MetricType metric;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select() to only rebuild when THIS metric's selection status changes
    // This is high-impact: MetricChip is rendered once per MetricType
    final isSelected = ref.watch(
      landscapeMetricsProvider.select((metrics) => metrics.contains(metric)),
    );

    return FilterChip(
      label: Text(_getLabel(context, metric)),
      selected: isSelected,
      onSelected: (_) {
        // Haptic feedback for tactile confirmation
        HapticFeedback.selectionClick();

        // Toggle metric selection
        // OK: read - Using ref.read() in callback is correct pattern for calling notifier methods
        ref.read(landscapeMetricsProvider.notifier).toggle(metric);
      },
      showCheckmark: true,
      selectedColor: context.colors.primary.withValues(alpha: 0.2),
      checkmarkColor: context.colors.primary,
      backgroundColor: context.colors.surfaceContainerHighest,
      side: BorderSide(
        color: isSelected
            ? context.colors.primary
            : context.colors.outline.withValues(alpha: 0.5),
        width: isSelected ? 2 : 1,
      ),
      labelStyle: context.textTheme.labelLarge?.copyWith(
        color: isSelected
            ? context.colors.primary
            : context.colors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  /// Get localized label for metric type
  ///
  /// **Localization keys** (EN/IT):
  /// - volume → "Volume" / "Volume"
  /// - weight → "Weight" / "Peso"
  /// - oneRmEstimated → "1RM (Est.)" / "1RM (Stim.)"
  /// - weightTimesReps → "Weight × Reps" / "Peso × Rip"
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
