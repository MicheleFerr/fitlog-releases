/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Insight Severity Visual Indicator - displays severity with color/icon
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Visual indicator for insight severity level
///
/// Displays color-coded icon and label based on severity:
/// - CRITICAL: 🔴 Red - Immediate action required
/// - HIGH: 🟠 Orange - Action recommended
/// - MEDIUM: 🟡 Yellow - Consider action
/// - LOW: 🔵 Blue - Informational
///
/// Usage:
/// ```dart
/// InsightSeverityIndicator(severity: InsightSeverity.critical)
/// ```
class InsightSeverityIndicator extends StatelessWidget {
  const InsightSeverityIndicator({
    required this.severity,
    this.showLabel = true,
    this.size = AppIconSize.medium,
    super.key,
  });

  /// Severity level to display
  final InsightSeverity severity;

  /// Whether to show text label alongside icon
  final bool showLabel;

  /// Icon size (default: AppIconSize.medium = 24)
  final double size;

  @override
  Widget build(BuildContext context) {
    final config = _getSeverityConfig(context, severity);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Severity icon with semantic label for accessibility
        SemanticIcon(
          icon: config.icon,
          semanticLabel: config.semanticLabel,
          size: size,
          color: config.color,
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            config.label,
            style: context.textTheme.labelMedium?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  /// Get configuration for severity level
  _SeverityConfig _getSeverityConfig(
    BuildContext context,
    InsightSeverity severity,
  ) {
    switch (severity) {
      case InsightSeverity.critical:
        return _SeverityConfig(
          icon: AppIcons.error,
          color: context.colors.error,
          label: context.l10n.critical,
          semanticLabel: context.l10n.criticalSeverity,
        );

      case InsightSeverity.high:
        return _SeverityConfig(
          icon: AppIcons.warning,
          color: context.colors.warning,
          label: context.l10n.high,
          semanticLabel: context.l10n.highSeverity,
        );

      case InsightSeverity.medium:
        return _SeverityConfig(
          icon: AppIcons.info,
          color: context.colors.tertiary,
          label: context.l10n.medium,
          semanticLabel: context.l10n.mediumSeverity,
        );

      case InsightSeverity.low:
        return _SeverityConfig(
          icon: AppIcons.complete,
          color: context.colors.primary,
          label: context.l10n.low,
          semanticLabel: context.l10n.lowSeverity,
        );
    }
  }
}

/// Configuration for severity display
class _SeverityConfig {
  const _SeverityConfig({
    required this.icon,
    required this.color,
    required this.label,
    required this.semanticLabel,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String semanticLabel;
}

/// Compact severity badge (icon only, no label)
///
/// Usage:
/// ```dart
/// SeverityBadge(severity: InsightSeverity.high)
/// ```
class SeverityBadge extends StatelessWidget {
  const SeverityBadge({
    required this.severity,
    this.size = AppIconSize.small,
    super.key,
  });

  final InsightSeverity severity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getBadgeColor(context, severity).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InsightSeverityIndicator(
        severity: severity,
        showLabel: false,
        size: size,
      ),
    );
  }

  Color _getBadgeColor(BuildContext context, InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.critical:
        return context.colors.error;
      case InsightSeverity.high:
        return context.colors.warning;
      case InsightSeverity.medium:
        return context.colors.tertiary;
      case InsightSeverity.low:
        return context.colors.primary;
    }
  }
}
