/// Plateau Detection Tab for Pro Analytics
///
/// Shows exercises with training plateaus and provides
/// actionable recommendations for breaking through.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/plateau_detection_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

/// Tab widget showing plateau detection analytics
class PlateauDetectionTab extends ConsumerWidget {
  const PlateauDetectionTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plateausAsync = ref.watch(plateauDetectionProvider);

    return plateausAsync.when(
      data: (plateaus) => _buildContent(context, plateaus),
      loading: () => const Center(child: LoadingIndicator()),
      error: (e, _) => _buildErrorState(context, e),
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

  Widget _buildContent(BuildContext context, List<PlateauData> plateaus) {
    final l10n = context.l10n;

    if (plateaus.isEmpty) {
      return _buildEmptyState(context);
    }

    // Separate into categories
    final plateaued = plateaus.where((p) => p.isPlateau).toList();
    final declining = plateaus
        .where((p) => p.isDeclining && !p.isPlateau)
        .toList();
    final progressing = plateaus.where((p) => p.isProgressing).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        _buildSummaryCard(
          context,
          plateaued.length,
          declining.length,
          progressing.length,
        ),
        const SizedBox(height: 16),

        // Plateau section (priority)
        if (plateaued.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            l10n.aiInsightVolumePlateau,
            AppIcons.warning,
            context.colors.warning,
          ),
          const SizedBox(height: 8),
          ...plateaued.map((p) => _buildExerciseCard(context, p)),
          const SizedBox(height: 16),
        ],

        // Declining section
        if (declining.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            l10n.declining,
            AppIcons.trendDown,
            context.colors.error,
          ),
          const SizedBox(height: 8),
          ...declining.map((p) => _buildExerciseCard(context, p)),
          const SizedBox(height: 16),
        ],

        // Progressing section
        if (progressing.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            l10n.improving,
            AppIcons.trendUp,
            context.colors.success,
          ),
          const SizedBox(height: 8),
          ...progressing.map((p) => _buildExerciseCard(context, p)),
        ],

        const SizedBox(height: 24),

        // Strategies card
        if (plateaued.isNotEmpty || declining.isNotEmpty)
          _buildStrategiesCard(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.analytics,
              size: AppIconSize.xxlarge,
              color: context.colors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.notEnoughWorkoutData,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noDataForChart,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    int plateaued,
    int declining,
    int progressing,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              plateaued.toString(),
              context.l10n.analyticsTrendPlateau,
              context.colors.warning,
              AppIcons.warning,
            ),
            Container(
              width: 1,
              height: 40,
              color: context.colors.outlineVariant,
            ),
            _buildStatItem(
              context,
              declining.toString(),
              context.l10n.declining,
              context.colors.error,
              AppIcons.trendDown,
            ),
            Container(
              width: 1,
              height: 40,
              color: context.colors.outlineVariant,
            ),
            _buildStatItem(
              context,
              progressing.toString(),
              context.l10n.improving,
              context.colors.success,
              AppIcons.trendUp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppIconSize.small, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: AppIconSize.small, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(BuildContext context, PlateauData data) {
    final color = data.isPlateau
        ? context.colors.warning
        : data.isDeclining
        ? context.colors.error
        : context.colors.success;

    final trendText = data.trendPercent >= 0
        ? '+${data.trendPercent.toStringAsFixed(1)}%'
        : '${data.trendPercent.toStringAsFixed(1)}%';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Trend indicator
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    data.isPlateau
                        ? AppIcons.warning
                        : data.isDeclining
                        ? AppIcons.trendDown
                        : AppIcons.trendUp,
                    size: AppIconSize.small,
                    color: color,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trendText,
                    style: context.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.exerciseName,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.sessionsAnalyzed} ${context.l10n.sessions} • ${context.l10n.average}: ${data.avgVolume.toStringAsFixed(0)} kg',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${context.l10n.lastWorkout}: ${DateFormat.MMMd().format(data.lastSessionDate)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
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

  Widget _buildStrategiesCard(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.lightbulb,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.advancedQuickWinTitle,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStrategyItem(
              context,
              l10n.strategyPlateauincreasevolumeTitle,
              l10n.strategyPlateauincreasevolumeDesc,
            ),
            _buildStrategyItem(
              context,
              l10n.strategyPlateauvaryrepsTitle,
              l10n.strategyPlateauvaryrepsDesc,
            ),
            _buildStrategyItem(
              context,
              l10n.strategyPlateauchangeexercisesTitle,
              l10n.strategyPlateauchangeexercisesDesc,
            ),
            _buildStrategyItem(
              context,
              l10n.strategyPlateaudeloadweekTitle,
              l10n.strategyPlateaudeloadweekDesc,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: context.colors.primary,
              shape: BoxShape.circle,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
