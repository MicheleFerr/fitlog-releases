/// Stress Index Card Widget
///
/// Compact card showing the latest stress index score.
/// Taps to reveal detailed muscle recovery breakdown.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/constants/stress_index_constants.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/widgets/stress_index_detail_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Compact card showing stress index score
///
/// Features:
/// - Circular score indicator with color coding
/// - Confidence badge when RPE data is incomplete
/// - Tap to reveal muscle recovery details
class StressIndexCard extends ConsumerWidget {
  const StressIndexCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stressState = ref.watch(stressIndexNotifierProvider);

    return stressState.when(
      data: (state) {
        if (!state.hasData) {
          return const SizedBox.shrink();
        }
        return _buildCard(context, state.latestResult!, state);
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LoadingIndicator(),
        ),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(
    BuildContext context,
    StressIndexResult result,
    dynamic state,
  ) {
    final score = result.displayScore;
    final color = _getScoreColor(context, score);

    return GestureDetector(
      onTap: () => _showDetailModal(context, result, state),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        AppIcons.bolt,
                        color: context.colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.stressIndex,
                        style: context.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  if (!result.isHighConfidence) _buildConfidenceBadge(context, result),
                ],
              ),
              const SizedBox(height: 12),

              // Score row
              Row(
                children: [
                  _buildScoreCircle(context, score, color),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getScoreLabel(context, result.stressLevel),
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getScoreDescription(context, result.stressLevel),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    AppIcons.chevronRight,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ),

              // RPE hint for low confidence
              if (result.isLowConfidence) ...[
                const SizedBox(height: 12),
                _buildRpeHint(context, result),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(BuildContext context, double score, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
        color: color.withValues(alpha: 0.1),
      ),
      child: Center(
        child: Text(
          score.round().toString(),
          style: context.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(BuildContext context, StressIndexResult result) {
    final confidencePercent = (result.confidence * 100).round();
    final color = result.isMediumConfidence
        ? context.colors.warning
        : context.colors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$confidencePercent% RPE',
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRpeHint(BuildContext context, StressIndexResult result) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.info,
            size: 16,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.lowConfidenceHint,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(BuildContext context, double score) {
    if (score < StressIndexConstants.lightSessionMax) {
      return context.colors.success;
    }
    if (score < StressIndexConstants.moderateSessionMax) {
      return context.colors.warning;
    }
    if (score < StressIndexConstants.hardSessionMax) {
      return Colors.orange;
    }
    return context.colors.error;
  }

  String _getScoreLabel(BuildContext context, StressLevel level) {
    return switch (level) {
      StressLevel.light => context.l10n.stressLevelLight,
      StressLevel.moderate => context.l10n.stressLevelModerate,
      StressLevel.hard => context.l10n.stressLevelHard,
      StressLevel.veryHard => context.l10n.stressLevelVeryHard,
    };
  }

  String _getScoreDescription(BuildContext context, StressLevel level) {
    return switch (level) {
      StressLevel.light => context.l10n.stressDescriptionLight,
      StressLevel.moderate => context.l10n.stressDescriptionModerate,
      StressLevel.hard => context.l10n.stressDescriptionHard,
      StressLevel.veryHard => context.l10n.stressDescriptionVeryHard,
    };
  }

  void _showDetailModal(
    BuildContext context,
    StressIndexResult result,
    dynamic state,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StressIndexDetailModal(
        result: result,
        muscleRecovery: state.muscleRecovery,
      ),
    );
  }
}
