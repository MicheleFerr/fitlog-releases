/// Metric Display Widgets
///
/// Reusable widgets for displaying metrics, statistics, and KPIs
/// across the application with consistent styling.
///
/// ## Widgets
/// - `MetricDisplay` - Basic metric with label and value
/// - `MetricCard` - Metric in a card container
/// - `CompactMetric` - Minimal inline metric
/// - `MetricWithTrend` - Metric with trend indicator
/// - `MetricRing` - Circular progress metric
///
/// ## Usage
/// ```dart
/// MetricDisplay(
///   label: 'Total Workouts',
///   value: '42',
///   icon: AppIcons.dumbbell,
/// )
///
/// MetricCard(
///   label: 'Weekly Volume',
///   value: '12,500 kg',
///   trend: TrendDirection.up,
///   trendValue: '+15%',
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Direction of trend indicator
enum TrendDirection {
  up,
  down,
  neutral,
}

/// Size variants for metric displays
enum MetricSize {
  /// Small: label 12px, value 16px
  small,

  /// Medium: label 14px, value 24px
  medium,

  /// Large: label 16px, value 36px
  large,

  /// Hero: label 18px, value 48px
  hero,
}

/// Basic metric display widget
///
/// Shows a label and value with optional icon and unit
class MetricDisplay extends StatelessWidget {
  const MetricDisplay({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.iconColor,
    this.size = MetricSize.medium,
    this.alignment = CrossAxisAlignment.start,
    this.labelStyle,
    this.valueStyle,
    this.spacing = 4,
  });

  /// Label text (e.g., "Total Workouts")
  final String label;

  /// Value text (e.g., "42")
  final String value;

  /// Optional unit suffix (e.g., "kg", "%")
  final String? unit;

  /// Optional leading icon
  final IconData? icon;

  /// Custom icon color (defaults to primary)
  final Color? iconColor;

  /// Size variant
  final MetricSize size;

  /// Cross axis alignment
  final CrossAxisAlignment alignment;

  /// Custom label text style
  final TextStyle? labelStyle;

  /// Custom value text style
  final TextStyle? valueStyle;

  /// Spacing between label and value
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    // Size-dependent styles
    final (labelFontSize, valueFontSize, iconSize) = switch (size) {
      MetricSize.small => (12.0, 16.0, AppIconSize.small),
      MetricSize.medium => (14.0, 24.0, AppIconSize.medium),
      MetricSize.large => (16.0, 36.0, AppIconSize.large),
      MetricSize.hero => (18.0, 48.0, AppIconSize.xlarge),
    };

    final effectiveLabelStyle = labelStyle ??
        textTheme.labelSmall?.copyWith(
          fontSize: labelFontSize,
          color: colorScheme.onSurfaceVariant,
        );

    final effectiveValueStyle = valueStyle ??
        textTheme.titleLarge?.copyWith(
          fontSize: valueFontSize,
          fontWeight: FontWeight.bold,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        // Label with optional icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? colorScheme.primary,
              ),
              const SizedBox(width: 6),
            ],
            Text(label, style: effectiveLabelStyle),
          ],
        ),
        SizedBox(height: spacing),
        // Value with optional unit
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: effectiveValueStyle),
            if (unit != null) ...[
              const SizedBox(width: 4),
              Text(
                unit!,
                style: effectiveLabelStyle?.copyWith(
                  fontSize: valueFontSize * 0.5,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Metric display in a card container
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.iconColor,
    this.trend,
    this.trendValue,
    this.size = MetricSize.medium,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.padding,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color? iconColor;
  final TrendDirection? trend;
  final String? trendValue;
  final MetricSize size;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Material(
      color: backgroundColor ?? colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ?? colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetricDisplay(
                label: label,
                value: value,
                unit: unit,
                icon: icon,
                iconColor: iconColor,
                size: size,
              ),
              if (trend != null && trendValue != null) ...[
                const SizedBox(height: 8),
                _TrendIndicator(
                  direction: trend!,
                  value: trendValue!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact inline metric display
class CompactMetric extends StatelessWidget {
  const CompactMetric({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.iconColor,
    this.divider = ':',
  });

  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color? iconColor;
  final String divider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: AppIconSize.tiny,
            color: iconColor ?? colorScheme.primary,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '$divider ',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (unit != null)
          Text(
            ' $unit',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

/// Metric with trend indicator
class MetricWithTrend extends StatelessWidget {
  const MetricWithTrend({
    super.key,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendValue,
    this.unit,
    this.size = MetricSize.medium,
  });

  final String label;
  final String value;
  final TrendDirection trend;
  final String trendValue;
  final String? unit;
  final MetricSize size;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MetricDisplay(
          label: label,
          value: value,
          unit: unit,
          size: size,
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _TrendIndicator(
            direction: trend,
            value: trendValue,
          ),
        ),
      ],
    );
  }
}

/// Circular progress metric (ring)
class MetricRing extends StatelessWidget {
  const MetricRing({
    super.key,
    required this.label,
    required this.value,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
    this.showPercentage = false,
  });

  final String label;
  final String value;
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: strokeWidth,
                color: backgroundColor ?? colorScheme.surfaceContainerHighest,
              ),
              // Progress ring
              CircularProgressIndicator(
                value: progress.clamp(0, 1),
                strokeWidth: strokeWidth,
                color: progressColor ?? colorScheme.primary,
                strokeCap: StrokeCap.round,
              ),
              // Center value
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showPercentage)
                    Text(
                      '${(progress * 100).round()}%',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Internal trend indicator widget
class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({
    required this.direction,
    required this.value,
  });

  final TrendDirection direction;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    final (icon, color) = switch (direction) {
      TrendDirection.up => (AppIcons.trendingUp, colorScheme.primary),
      TrendDirection.down => (AppIcons.trendingDown, colorScheme.error),
      TrendDirection.neutral => (AppIcons.trendingFlat, colorScheme.onSurfaceVariant),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppIconSize.tiny, color: color),
        const SizedBox(width: 2),
        Text(
          value,
          style: context.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
