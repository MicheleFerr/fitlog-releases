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

/// Compact score card for home screen
class CompactScoreCard extends StatelessWidget {

  const CompactScoreCard({
    super.key,
    required this.score,
  });
  final ConsistencyScore score;

  @override
  Widget build(BuildContext context) {
    final indicatorsCount = [
      score.frequencyOptimal,
      score.restOptimal,
      score.progressionPositive,
    ].where((x) => x).length;

    final badgeColor = _getBadgeColor(context, indicatorsCount);
    final badgeText = _getBadgeText(context, indicatorsCount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              context.l10n.consistencyIndicators,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Indicators
            IndicatorRow(
              icon: AppIcons.fitnessCenter,
              label: context.l10n.training,
              value: '${score.weeklyStats.avgWorkoutsPerWeek.toStringAsFixed(1)}/${context.l10n.perWeek}',
              isOptimal: score.frequencyOptimal,
            ),
            const SizedBox(height: 8),
            IndicatorRow(
              icon: AppIcons.bedtime,
              label: context.l10n.rest,
              value: '${score.weeklyStats.avgRestDaysPerWeek.toStringAsFixed(1)} ${context.l10n.days}',
              isOptimal: score.restOptimal,
            ),
            const SizedBox(height: 8),
            IndicatorRow(
              icon: AppIcons.trendingUp,
              label: context.l10n.progress,
              value: _getProgressionText(context, score),
              isOptimal: score.progressionPositive,
            ),

            const SizedBox(height: 16),

            // Overall badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getBadgeIcon(indicatorsCount), size: 16, color: badgeColor),
                  const SizedBox(width: 8),
                  Text(
                    badgeText,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '($indicatorsCount/3 ✅)',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

/// Single indicator row
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
