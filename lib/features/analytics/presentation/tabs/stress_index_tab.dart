/// Stress Index Tab for Pro Analytics
///
/// Shows detailed stress index and recovery information
/// within the Pro Analytics tabbed interface.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/constants/stress_index_constants.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_recovery_status.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Tab widget showing stress index analytics
class StressIndexTab extends ConsumerWidget {
  const StressIndexTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stressState = ref.watch(stressIndexNotifierProvider);

    return stressState.when(
      data: (state) {
        if (!state.hasData) {
          return _buildEmptyState(context);
        }
        return _buildContent(context, state);
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (e, _) => _buildErrorState(context, e),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.bolt,
              size: AppIconSize.xxlarge,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noDataAvailable,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.completeWorkoutForStressIndex,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.error,
              size: AppIconSize.xxlarge,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.errorLoadingData,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic state) {
    final latestResult = state.latestResult as StressIndexResult?;
    final muscleRecovery =
        state.muscleRecovery as Map<String, MuscleRecoveryStatus>;
    final history = state.history as List<StressIndexResult>;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current stress score card
        if (latestResult != null) _buildCurrentScoreCard(context, latestResult),
        const SizedBox(height: 16),

        // Muscle recovery section
        if (muscleRecovery.isNotEmpty)
          _buildMuscleRecoverySection(context, muscleRecovery),
        const SizedBox(height: 16),

        // Recent history
        if (history.isNotEmpty) _buildHistorySection(context, history),
      ],
    );
  }

  Widget _buildCurrentScoreCard(BuildContext context, StressIndexResult result) {
    final score = result.displayScore;
    final color = _getScoreColor(context, score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.bolt,
                  color: context.colors.primary,
                  size: AppIconSize.medium,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.stressIndex,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Large score circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 6),
                    color: color.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      score.round().toString(),
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStressLevelText(context, result.stressLevel),
                        style: context.textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStressDescription(context, result.stressLevel),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            AppIcons.info,
                            size: AppIconSize.tiny,
                            color: context.colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(result.confidence * 100).round()}% ${context.l10n.confidence}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleRecoverySection(
    BuildContext context,
    Map<String, MuscleRecoveryStatus> muscleRecovery,
  ) {
    // Sort by recovery percentage (least recovered first)
    final sortedMuscles = muscleRecovery.values.toList()
      ..sort((a, b) => a.recoveryPercentage.compareTo(b.recoveryPercentage));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.accessibility,
                  color: context.colors.primary,
                  size: AppIconSize.medium,
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
            const SizedBox(height: 16),
            ...sortedMuscles.map((status) => _buildMuscleRecoveryRow(context, status)),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleRecoveryRow(BuildContext context, MuscleRecoveryStatus status) {
    final color = _getRecoveryColor(context, status.state);
    final percentage = status.recoveryPercentage.clamp(0, 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getRecoveryIcon(status.state),
                    color: color,
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status.displayName,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '$percentage%',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, List<StressIndexResult> history) {
    // Take last 7 entries
    final recentHistory = history.take(7).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.history,
                  color: context.colors.primary,
                  size: AppIconSize.medium,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.recentHistory,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recentHistory.map((result) => _buildHistoryRow(context, result)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryRow(BuildContext context, StressIndexResult result) {
    final score = result.displayScore;
    final color = _getScoreColor(context, score);
    final date = result.calculatedAt;
    final dateText = _formatDate(context, date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              color: color.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Text(
                score.round().toString(),
                style: context.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStressLevelText(context, result.stressLevel),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  dateText,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${result.totalSets} sets',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
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

  String _getStressLevelText(BuildContext context, StressLevel level) {
    return switch (level) {
      StressLevel.light => context.l10n.stressLevelLight,
      StressLevel.moderate => context.l10n.stressLevelModerate,
      StressLevel.hard => context.l10n.stressLevelHard,
      StressLevel.veryHard => context.l10n.stressLevelVeryHard,
    };
  }

  String _getStressDescription(BuildContext context, StressLevel level) {
    return switch (level) {
      StressLevel.light => context.l10n.stressDescriptionLight,
      StressLevel.moderate => context.l10n.stressDescriptionModerate,
      StressLevel.hard => context.l10n.stressDescriptionHard,
      StressLevel.veryHard => context.l10n.stressDescriptionVeryHard,
    };
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return context.l10n.today;
    if (diff == 1) return context.l10n.yesterday;
    if (diff < 7) return context.l10n.daysAgo(diff);

    return '${date.day}/${date.month}/${date.year}';
  }
}
