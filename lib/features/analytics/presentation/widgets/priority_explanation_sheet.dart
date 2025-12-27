/// Priority Explanation BottomSheet
///
/// Shows a detailed explanation of how muscle priority is calculated.
/// Opened when user taps on the priority badge.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Priority Explanation Sheet - Explains how priority is calculated
///
/// Shows:
/// - Total priority score breakdown
/// - Severity contribution
/// - Antagonist imbalance contribution
/// - Posture risk contribution
class PriorityExplanationSheet extends StatelessWidget {
  const PriorityExplanationSheet({
    required this.neglectedMuscle,
    super.key,
  });

  final NeglectedMuscle neglectedMuscle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIcons.info,
                      color: colorScheme.onPrimaryContainer,
                      size: AppIconSize.medium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.priorityExplanationTitle,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          neglectedMuscle.muscleName.toUpperCase(),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Priority score badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(context).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getPriorityColor(context),
                      ),
                    ),
                    child: Text(
                      neglectedMuscle.priority.toStringAsFixed(1),
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getPriorityColor(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                l10n.priorityExplanationDescription,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Score breakdown
              Text(
                l10n.priorityBreakdown,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 1. Severity score
              _ScoreRow(
                icon: AppIcons.warning,
                iconColor: _getSeverityColor(context),
                title: l10n.prioritySeverityScore,
                subtitle: _getSeverityExplanation(context),
                score: _getSeverityScore(),
                maxScore: 4,
              ),
              const SizedBox(height: 12),

              // 2. Antagonist imbalance
              _ScoreRow(
                icon: AppIcons.balance,
                iconColor: colorScheme.tertiary,
                title: l10n.priorityAntagonistScore,
                subtitle: l10n.priorityAntagonistExplanation,
                score: _getAntagonistScore(),
                maxScore: 3,
              ),
              const SizedBox(height: 12),

              // 3. Posture risk
              _ScoreRow(
                icon: AppIcons.accessibility,
                iconColor: colorScheme.error,
                title: l10n.priorityPostureScore,
                subtitle: l10n.priorityPostureExplanation,
                score: _getPostureScore(),
                maxScore: 3,
              ),
              const SizedBox(height: 24),

              // Volume info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.barChart,
                      color: colorScheme.onSurfaceVariant,
                      size: AppIconSize.medium,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.currentVolume,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${neglectedMuscle.volumePercentage.toStringAsFixed(1)}%',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.recommendedVolume,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '5-15%',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Severity thresholds explanation
              Text(
                l10n.severityThresholds,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _ThresholdRow(
                color: context.colors.error,
                label: l10n.severityCritical,
                description: l10n.severityCriticalThreshold,
              ),
              const SizedBox(height: 8),
              _ThresholdRow(
                color: context.colors.warning,
                label: l10n.severityHigh,
                description: l10n.severityHighThreshold,
              ),
              const SizedBox(height: 8),
              _ThresholdRow(
                color: context.colors.tertiary,
                label: l10n.severityMedium,
                description: l10n.severityMediumThreshold,
              ),
              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.understood),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(BuildContext context) {
    if (neglectedMuscle.priority >= 7) {
      return context.colors.error;
    } else if (neglectedMuscle.priority >= 4) {
      return context.colors.warning;
    } else {
      return context.colors.tertiary;
    }
  }

  Color _getSeverityColor(BuildContext context) {
    switch (neglectedMuscle.severity) {
      case NeglectSeverity.critical:
        return context.colors.error;
      case NeglectSeverity.high:
        return context.colors.warning;
      case NeglectSeverity.medium:
        return context.colors.tertiary;
    }
  }

  String _getSeverityExplanation(BuildContext context) {
    final l10n = context.l10n;
    switch (neglectedMuscle.severity) {
      case NeglectSeverity.critical:
        return l10n.severityCriticalExplanation;
      case NeglectSeverity.high:
        return l10n.severityHighExplanation;
      case NeglectSeverity.medium:
        return l10n.severityMediumExplanation;
    }
  }

  double _getSeverityScore() {
    switch (neglectedMuscle.severity) {
      case NeglectSeverity.critical:
        return 4.0;
      case NeglectSeverity.high:
        return 3.0;
      case NeglectSeverity.medium:
        return 2.0;
    }
  }

  /// Approximate antagonist score based on total priority
  double _getAntagonistScore() {
    final total = neglectedMuscle.priority;
    final severityScore = _getSeverityScore();
    final postureScore = _getPostureScore();
    return (total - severityScore - postureScore).clamp(0.0, 3.0);
  }

  /// Approximate posture score based on muscle name
  double _getPostureScore() {
    final muscle = neglectedMuscle.muscleName.toLowerCase();
    // These are approximations - the actual values depend on the full balance data
    if (muscle == 'back' && neglectedMuscle.priority >= 7) {
      return 3.0;
    } else if (muscle == 'hamstrings' && neglectedMuscle.priority >= 7) {
      return 3.0;
    } else if (muscle == 'rear_delts' && neglectedMuscle.priority >= 5) {
      return 2.5;
    } else if (muscle == 'lower_back' && neglectedMuscle.priority >= 5) {
      return 2.0;
    }
    return 0.0;
  }
}

/// Score Row - Shows one component of the priority calculation
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.score,
    required this.maxScore,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final double score;
  final int maxScore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: AppIconSize.small,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${score.toStringAsFixed(1)}/$maxScore',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Threshold Row - Shows severity threshold info
class _ThresholdRow extends StatelessWidget {
  const _ThresholdRow({
    required this.color,
    required this.label,
    required this.description,
  });

  final Color color;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
