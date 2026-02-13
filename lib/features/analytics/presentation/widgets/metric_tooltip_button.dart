/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/widgets
/// Feature: analytics
/// Type: widget
///
/// Metric Tooltip Button - Educational tooltips for technical metrics
///
/// **Purpose**: Show "?" icon button that opens MetricExplanationSheet
/// **Usage**:
/// ```dart
/// MetricTooltipButton(metricKey: 'rpe')
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/metric_explanation_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Button that shows educational tooltip for a metric
class MetricTooltipButton extends StatelessWidget {
  const MetricTooltipButton({
    super.key,
    required this.metricKey,
    this.size = AppIconSize.small,
    this.color,
  });

  /// Metric identifier ('rpe', '1rm', 'volume', 'tonnage', 'r_squared')
  final String metricKey;

  /// Icon size
  final double size;

  /// Icon color (default: onSurfaceVariant)
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        AppIcons.info,
        size: size,
        color: color ?? context.colors.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(
        minWidth: 24,
        minHeight: 24,
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        MetricExplanationSheet.show(context, metricKey: metricKey);
      },
      tooltip: 'Info',
    );
  }
}
