/// Stress Index Detail Modal
///
/// Shows detailed breakdown of stress index including:
/// - Overall score with confidence
/// - Muscle-by-muscle recovery status
/// - Stress breakdown by muscle group
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/constants/stress_index_constants.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_recovery_status.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Detail modal for stress index
///
/// Shows:
/// - Header with overall score
/// - Muscle recovery grid
/// - Stress breakdown by muscle
/// - Confidence explanation
class StressIndexDetailModal extends StatelessWidget {
  const StressIndexDetailModal({
    required this.result,
    required this.muscleRecovery,
    super.key,
  });

  final StressIndexResult result;
  final Map<String, MuscleRecoveryStatus> muscleRecovery;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildMuscleRecoverySection(context),
                    if (result.muscleBreakdown.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildStressBreakdownSection(context),
                    ],
                    const SizedBox(height: 24),
                    _buildConfidenceSection(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final score = result.displayScore;
    final color = _getScoreColor(context, score);

    return Row(
      children: [
        // Large score circle
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 4),
            color: color.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Text(
              score.round().toString(),
              style: context.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.stressIndex,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getStressLevelText(context, result.stressLevel),
                style: context.textTheme.bodyLarge?.copyWith(
                  color: color,
                ),
              ),
              if (!result.isHighConfidence) ...[
                const SizedBox(height: 4),
                Text(
                  context.l10n.estimatedRange(result.scoreRange),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleRecoverySection(BuildContext context) {
    if (muscleRecovery.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by recovery percentage (least recovered first)
    final sortedMuscles = muscleRecovery.values.toList()
      ..sort((a, b) => a.recoveryPercentage.compareTo(b.recoveryPercentage));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              AppIcons.accessibility,
              color: context.colors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.muscleRecovery,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sortedMuscles.map((status) {
            return _MuscleRecoveryChip(status: status);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStressBreakdownSection(BuildContext context) {
    // Sort by stress score (highest first)
    final sortedMuscles = result.muscleBreakdown.values.toList()
      ..sort((a, b) => b.stressScore.compareTo(a.stressScore));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              AppIcons.analytics,
              color: context.colors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.stressBreakdown,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sortedMuscles.map((muscle) => _buildMuscleStressRow(context, muscle)),
      ],
    );
  }

  Widget _buildMuscleStressRow(BuildContext context, dynamic muscle) {
    final score = muscle.stressScore;
    final color = _getScoreColor(context, score);
    final percentage = (score / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                muscle.displayName,
                style: context.textTheme.bodyMedium,
              ),
              Row(
                children: [
                  Text(
                    '${muscle.setsCount} sets',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    score.toStringAsFixed(0),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceSection(BuildContext context) {
    final confidencePercent = (result.confidence * 100).round();
    final setsWithRpe = result.setsWithRpe;
    final totalSets = result.totalSets;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.info,
                color: context.colors.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.accuracyInfo,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.confidenceExplanation(confidencePercent, setsWithRpe, totalSets),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          if (!result.isHighConfidence) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  AppIcons.lightbulb,
                  color: context.colors.warning,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.rpeImproveAccuracy,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
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

  String _getStressLevelText(BuildContext context, StressLevel level) {
    return switch (level) {
      StressLevel.light => context.l10n.stressLevelLight,
      StressLevel.moderate => context.l10n.stressLevelModerate,
      StressLevel.hard => context.l10n.stressLevelHard,
      StressLevel.veryHard => context.l10n.stressLevelVeryHard,
    };
  }
}

/// Chip showing muscle recovery status
class _MuscleRecoveryChip extends StatelessWidget {
  const _MuscleRecoveryChip({required this.status});

  final MuscleRecoveryStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _getRecoveryColor(context, status.state);
    final percentage = status.recoveryPercentage.clamp(0, 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRecoveryIcon(status.state),
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$percentage%',
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRecoveryColor(BuildContext context, RecoveryState state) {
    return switch (state) {
      RecoveryState.fullyRecovered => context.colors.success,
      RecoveryState.almostReady => const Color(0xFF8BC34A), // Light green
      RecoveryState.recovering => context.colors.warning,
      RecoveryState.fatigued => Colors.orange,
      RecoveryState.exhausted => context.colors.error,
    };
  }

  IconData _getRecoveryIcon(RecoveryState state) {
    return switch (state) {
      RecoveryState.fullyRecovered => AppIcons.checkCircle,
      RecoveryState.almostReady => AppIcons.clock,
      RecoveryState.recovering => AppIcons.hourglassEmpty,
      RecoveryState.fatigued => AppIcons.warning,
      RecoveryState.exhausted => AppIcons.error,
    };
  }
}
