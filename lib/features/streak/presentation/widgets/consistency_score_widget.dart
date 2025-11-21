import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/consistency_score.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/providers/streak_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Widget that displays workout consistency score in MINIMAL format (1 line)
///
/// Shows: Score + Rating + Risk on ONE line
/// Tap to open modal with full breakdown
///
/// Example: "📊 81 - Ottimo | ✅ Rischio: Basso"
class ConsistencyScoreWidget extends ConsumerWidget {
  const ConsistencyScoreWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(consistencyScoreProvider);

    return scoreAsync.when(
      data: (score) => _MinimalScoreCard(score: score),
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: AppIcons.error,
              semanticLabel: context.l10n.errorLoadingData,
              size: AppIconSize.xlarge,
              color: context.colors.error,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.errorLoadingData,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal score card - ONE line with score + rating + risk
/// Tap to expand full details in modal
class _MinimalScoreCard extends StatelessWidget {
  final ConsistencyScore score;

  const _MinimalScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(context, score.overallScore);
    final riskConfig = _getRiskConfig(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showDetailsModal(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: scoreColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Score Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scoreColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: scoreColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${score.overallScore}',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Score Rating Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.consistencyScore,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      _getScoreRatingText(context, score.scoreRating),
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Risk Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: riskConfig['color'].withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: riskConfig['color'],
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      riskConfig['emoji'],
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      riskConfig['text'],
                      style: context.textTheme.bodySmall?.copyWith(
                        color: riskConfig['color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Expand Icon
              Icon(
                AppIcons.forwardIos,
                size: AppIconSize.small,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show full details in bottom sheet modal
  void _showDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.analytics,
                      color: context.colors.primary,
                      size: AppIconSize.medium,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.consistencyScore,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: _FullScoreDetails(score: score),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getScoreRatingText(BuildContext context, String rating) {
    switch (rating) {
      case 'Excellent':
        return context.l10n.scoreRatingExcellent;
      case 'Great':
        return context.l10n.scoreRatingGreat;
      case 'Good':
        return context.l10n.scoreRatingGood;
      case 'Fair':
        return context.l10n.scoreRatingFair;
      case 'Needs Improvement':
        return context.l10n.scoreRatingNeedsImprovement;
      default:
        return rating;
    }
  }

  Color _getScoreColor(BuildContext context, int score) {
    if (score >= 90) return context.colors.success;
    if (score >= 75) return context.colors.primary;
    if (score >= 60) return context.colors.secondary;
    if (score >= 40) return context.colors.warning;
    return context.colors.error;
  }

  Map<String, dynamic> _getRiskConfig(BuildContext context) {
    switch (score.overtrainingRisk) {
      case OvertrainingRisk.low:
        return {
          'emoji': '✅',
          'text': context.l10n.riskLow,
          'color': context.colors.success,
        };
      case OvertrainingRisk.medium:
        return {
          'emoji': '⚠️',
          'text': context.l10n.riskMedium,
          'color': context.colors.warning,
        };
      case OvertrainingRisk.high:
        return {
          'emoji': '🚨',
          'text': context.l10n.riskHigh,
          'color': context.colors.error,
        };
    }
  }
}

/// Full score details (shown in modal)
class _FullScoreDetails extends StatelessWidget {
  final ConsistencyScore score;

  const _FullScoreDetails({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Score Card
        Center(
          child: _CircularScoreDisplay(score: score.overallScore),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _getScoreRatingText(context, score.scoreRating),
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getScoreColor(context, score.overallScore),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Overtraining Risk Badge
        Center(child: _RiskLevelBadge(riskLevel: score.overtrainingRisk)),

        const SizedBox(height: 24),

        // Score Breakdown Section
        Text(
          context.l10n.scoreBreakdown,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _ScoreBarItem(
          label: context.l10n.frequencyScore,
          score: score.frequencyScore,
          color: context.colors.primary,
        ),
        const SizedBox(height: 8),
        _ScoreBarItem(
          label: context.l10n.restScore,
          score: score.restScore,
          color: context.colors.success,
        ),
        const SizedBox(height: 8),
        _ScoreBarItem(
          label: context.l10n.volumeScore,
          score: score.volumeScore,
          color: context.colors.secondary,
        ),
        const SizedBox(height: 8),
        _ScoreBarItem(
          label: context.l10n.progressionScore,
          score: score.progressionScore,
          color: context.colors.tertiary,
        ),

        const SizedBox(height: 24),

        // Weekly Stats Section
        Text(
          context.l10n.weeklyStats,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: AppIcons.workout,
                value: score.weeklyStats.avgWorkoutsPerWeek.toStringAsFixed(1),
                label: context.l10n.workoutsPerWeek,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: AppIcons.bedtime,
                value: score.weeklyStats.avgRestDaysPerWeek.toStringAsFixed(1),
                label: context.l10n.restDaysPerWeek,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getScoreRatingText(BuildContext context, String rating) {
    switch (rating) {
      case 'Excellent':
        return context.l10n.scoreRatingExcellent;
      case 'Great':
        return context.l10n.scoreRatingGreat;
      case 'Good':
        return context.l10n.scoreRatingGood;
      case 'Fair':
        return context.l10n.scoreRatingFair;
      case 'Needs Improvement':
        return context.l10n.scoreRatingNeedsImprovement;
      default:
        return rating;
    }
  }

  Color _getScoreColor(BuildContext context, int score) {
    if (score >= 90) return context.colors.success;
    if (score >= 75) return context.colors.primary;
    if (score >= 60) return context.colors.secondary;
    if (score >= 40) return context.colors.warning;
    return context.colors.error;
  }
}

/// Circular score display (for modal)
class _CircularScoreDisplay extends StatelessWidget {
  final int score;

  const _CircularScoreDisplay({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(context, score);

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(
          color: color,
          width: 4,
        ),
      ),
      child: Center(
        child: Text(
          '$score',
          style: context.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(BuildContext context, int score) {
    if (score >= 90) return context.colors.success;
    if (score >= 75) return context.colors.primary;
    if (score >= 60) return context.colors.secondary;
    if (score >= 40) return context.colors.warning;
    return context.colors.error;
  }
}

/// Risk level badge
class _RiskLevelBadge extends StatelessWidget {
  final OvertrainingRisk riskLevel;

  const _RiskLevelBadge({required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    final riskConfig = _getRiskConfig(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: riskConfig['color'].withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: riskConfig['color'],
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            riskConfig['emoji'],
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.overtrainingRisk,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              Text(
                riskConfig['text'],
                style: context.textTheme.titleSmall?.copyWith(
                  color: riskConfig['color'],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getRiskConfig(BuildContext context) {
    switch (riskLevel) {
      case OvertrainingRisk.low:
        return {
          'emoji': '✅',
          'text': context.l10n.riskLow,
          'color': context.colors.success,
        };
      case OvertrainingRisk.medium:
        return {
          'emoji': '⚠️',
          'text': context.l10n.riskMedium,
          'color': context.colors.warning,
        };
      case OvertrainingRisk.high:
        return {
          'emoji': '🚨',
          'text': context.l10n.riskHigh,
          'color': context.colors.error,
        };
    }
  }
}

/// Score bar item (for modal breakdown)
class _ScoreBarItem extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreBarItem({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$score',
              style: context.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: context.colors.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(8),
          minHeight: 8,
        ),
      ],
    );
  }
}

/// Stat card (for modal stats)
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SemanticIcon(
            icon: icon,
            semanticLabel: label,
            size: AppIconSize.medium,
            color: context.colors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
