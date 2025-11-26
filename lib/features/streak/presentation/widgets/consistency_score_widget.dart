/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/streak/presentation/widgets
/// 🎯 Feature: streak
/// 🔧 Type: widget
///
/// Consistency Score Widget - Binary indicators with scientific validation
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/consistency_score.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/providers/streak_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Main consistency score widget with provider integration
class ConsistencyScoreWidget extends ConsumerWidget {
  const ConsistencyScoreWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(consistencyScoreProvider);

    return scoreAsync.when(
      data: (score) => CompactScoreCard(score: score),
      loading: () => const LoadingIndicator(),
      error: (err, stack) => Center(
        child: Text(
          context.l10n.errorLoadingConsistencyScore,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.error,
          ),
        ),
      ),
    );
  }
}

/// Compact score card for home screen with elevated design
class CompactScoreCard extends StatelessWidget {

  const CompactScoreCard({
    super.key,
    required this.score,
  });
  final ConsistencyScore score;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final indicatorsCount = [
      score.frequencyOptimal,
      score.restOptimal,
      score.progressionPositive,
    ].where((x) => x).length;

    final badgeColor = _getBadgeColor(context, indicatorsCount);
    final badgeText = _getBadgeText(context, indicatorsCount);

    // Choose gradient colors based on score
    final gradientColors = _getGradientColors(context, indicatorsCount);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: RadialGradient(
          center: const Alignment(0.3, -0.4),
          radius: 1.5,
          colors: gradientColors,
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.surface.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            badgeColor.withValues(alpha: 0.8),
                            badgeColor.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: badgeColor.withValues(alpha: 0.2),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getBadgeIcon(indicatorsCount),
                        color: colorScheme.surface,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.consistencyIndicators,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '$indicatorsCount/3',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Indicators with enhanced styling
                _EnhancedIndicatorRow(
                  icon: AppIcons.fitnessCenter,
                  label: context.l10n.training,
                  value: '${score.weeklyStats.avgWorkoutsPerWeek.toStringAsFixed(1)}/${context.l10n.perWeek}',
                  isOptimal: score.frequencyOptimal,
                ),
                const SizedBox(height: 12),
                _EnhancedIndicatorRow(
                  icon: AppIcons.bedtime,
                  label: context.l10n.rest,
                  value: '${score.weeklyStats.avgRestDaysPerWeek.toStringAsFixed(1)} ${context.l10n.days}',
                  isOptimal: score.restOptimal,
                ),
                const SizedBox(height: 12),
                _EnhancedIndicatorRow(
                  icon: AppIcons.trendingUp,
                  label: context.l10n.progress,
                  value: _getProgressionText(context, score),
                  isOptimal: score.progressionPositive,
                ),

                const SizedBox(height: 16),

                // Overall status badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(_getBadgeIcon(indicatorsCount), size: 18, color: badgeColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          badgeText,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(BuildContext context, int count) {
    final colorScheme = context.colors;
    if (count >= 2) {
      // Success state - greenish tints
      return [
        colorScheme.primaryContainer.withValues(alpha: 1.0),
        colorScheme.secondaryContainer.withValues(alpha: 0.9),
        colorScheme.tertiaryContainer.withValues(alpha: 0.8),
      ];
    } else if (count == 1) {
      // Warning state - warm tints
      return [
        colorScheme.tertiaryContainer.withValues(alpha: 1.0),
        colorScheme.secondaryContainer.withValues(alpha: 0.9),
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
      ];
    }
    // Needs attention - surface tints
    return [
      colorScheme.surfaceContainerHighest.withValues(alpha: 1.0),
      colorScheme.surfaceContainerHigh.withValues(alpha: 0.9),
      colorScheme.surfaceContainer.withValues(alpha: 0.8),
    ];
  }

  Color _getBadgeColor(BuildContext context, int count) {
    if (count >= 2) return context.colors.success;
    if (count == 1) return context.colors.warning;
    return context.colors.error;
  }

  String _getBadgeText(BuildContext context, int count) {
    if (count >= 2) return context.l10n.doingWell;
    if (count == 1) return context.l10n.canImprove;
    return context.l10n.reviewRoutine;
  }

  IconData _getBadgeIcon(int count) {
    if (count >= 2) return AppIcons.checkCircle;
    if (count == 1) return AppIcons.warning;
    return AppIcons.cancel;
  }

  String _getProgressionText(BuildContext context, ConsistencyScore score) {
    // Calculate rough progression percentage
    if (score.progressionScore >= 85) return '+5-15%';
    if (score.progressionScore >= 70) return '+1-5%';
    if (score.progressionScore >= 50) return '±0%';
    return '-5%';
  }
}

/// Enhanced indicator row with pill background
class _EnhancedIndicatorRow extends StatelessWidget {

  const _EnhancedIndicatorRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isOptimal,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool isOptimal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final statusColor = isOptimal ? colorScheme.success : colorScheme.error;
    final statusIcon = isOptimal ? AppIcons.checkCircle : AppIcons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: AppIconSize.small, color: context.iconPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(statusIcon, size: AppIconSize.small, color: statusColor),
          const SizedBox(width: 8),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single indicator row (legacy - for external use)
class IndicatorRow extends StatelessWidget {

  const IndicatorRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isOptimal,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool isOptimal;

  @override
  Widget build(BuildContext context) {
    final color = isOptimal ? context.colors.success : context.colors.error;
    final statusIcon = isOptimal ? AppIcons.checkCircle : AppIcons.cancel;

    return Row(
      children: [
        Icon(icon, size: AppIconSize.medium, color: context.iconPrimary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: context.textTheme.bodyMedium),
        ),
        Icon(statusIcon, size: AppIconSize.small, color: color),
        const SizedBox(width: 8),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
