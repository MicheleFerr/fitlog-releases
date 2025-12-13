/// Recovery Insight Sheet
///
/// Expanded bottom sheet with full recovery details.
///
/// **Sections**:
/// - Recovery Score with category breakdown
/// - Weekly Sleep Chart (7-day bar chart)
/// - Sleep-Workout Correlation (Pro only)
/// - Actionable Recommendations
///
/// **Tap on Card → Opens this sheet**
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/recovery_insight.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_record.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_workout_correlation.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/presentation/providers/recovery_insight_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Bottom sheet with expanded recovery insight details
class RecoveryInsightSheet extends ConsumerStatefulWidget {
  const RecoveryInsightSheet({super.key});

  /// Show the recovery insight bottom sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RecoveryInsightSheet(),
    );
  }

  @override
  ConsumerState<RecoveryInsightSheet> createState() =>
      _RecoveryInsightSheetState();
}

class _RecoveryInsightSheetState extends ConsumerState<RecoveryInsightSheet> {
  // Track expanded state for collapsible sections
  bool _sleepDetailsExpanded = true;
  bool _correlationExpanded = true;

  @override
  Widget build(BuildContext context) {
    final insightAsync = ref.watch(recoveryInsightProvider);
    final sleepRecordsAsync = ref.watch(sleepRecordsProvider);
    final isPro = ref.watch(isPremiumUserProvider);
    final l10n = context.l10n;

    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.95);
    return DraggableScrollableSheet(
      initialChildSize: 0.6, // 60% height
      minChildSize: 0.3,
      maxChildSize: safeMax,
      snap: true,
      snapSizes: [0.6, safeMax],
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.bedtime,
                      color: context.colors.primary,
                      size: AppIconSize.large,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.recoveryInsight,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            l10n.sleepRecoveryAnalysis,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        AppIcons.close,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: insightAsync.when(
                  data: (insight) => _buildContent(
                    context,
                    scrollController,
                    insight,
                    sleepRecordsAsync.valueOrNull ?? [],
                    isPro,
                  ),
                  loading: () => const Center(child: LoadingIndicator()),
                  error: (e, _) => _buildError(context, e),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ScrollController scrollController,
    RecoveryInsight insight,
    List<SleepRecord> sleepRecords,
    bool isPro,
  ) {
    final l10n = context.l10n;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Main score card
        _buildScoreCard(context, insight),
        const SizedBox(height: 20),

        // Category breakdown
        _buildCategoryBreakdown(context, insight),
        const SizedBox(height: 20),

        // Collapsible Sleep Details Section
        _buildCollapsibleSection(
          context: context,
          title: l10n.sleepDetails,
          icon: AppIcons.nightlight,
          isExpanded: _sleepDetailsExpanded,
          onToggle: () =>
              setState(() => _sleepDetailsExpanded = !_sleepDetailsExpanded),
          child: Column(
            children: [
              // Sleep metrics grid
              _buildSleepMetricsGrid(context, insight),
              const SizedBox(height: 16),

              // Weekly chart
              if (sleepRecords.isNotEmpty)
                _buildWeeklySleepChart(context, sleepRecords),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Collapsible Correlation Section (Pro only)
        _buildCollapsibleSection(
          context: context,
          title: l10n.sleepWorkoutCorrelation,
          icon: AppIcons.analytics,
          isExpanded: _correlationExpanded,
          onToggle: () =>
              setState(() => _correlationExpanded = !_correlationExpanded),
          child: isPro
              ? _buildCorrelationContent(context, insight.correlation)
              : _buildProUpgradePrompt(context),
        ),
        const SizedBox(height: 24),

        // Recommendation card
        _buildRecommendationCard(context, insight),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildScoreCard(BuildContext context, RecoveryInsight insight) {
    final categoryColor = _getCategoryColor(insight.category, context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withValues(alpha: 0.2),
            categoryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Circular score indicator
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 8,
                  backgroundColor: categoryColor.withValues(alpha: 0.1),
                  valueColor:
                      AlwaysStoppedAnimation(categoryColor.withValues(alpha: 0.2)),
                ),
                // Progress circle
                CircularProgressIndicator(
                  value: insight.score / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(categoryColor),
                ),
                // Score text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${insight.score}',
                      style: context.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                    Text(
                      '/100',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: categoryColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      insight.category.emoji,
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      insight.category.displayName,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getCategoryDescription(insight.category, context),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
      BuildContext context, RecoveryInsight insight) {
    final categoryColor = _getCategoryColor(insight.category, context);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.readinessLevel,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Progress dots (5 dots showing category)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isFilled = index < insight.category.filledDots;
              final dotColor = _getDotColor(index, context);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isFilled
                              ? dotColor
                              : context.colors.surfaceContainerHighest,
                          border: isFilled
                              ? null
                              : Border.all(
                                  color: context.colors.outline
                                      .withValues(alpha: 0.3),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCategoryName(index, context),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: isFilled
                              ? dotColor
                              : context.colors.onSurface.withValues(alpha: 0.4),
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepMetricsGrid(
      BuildContext context, RecoveryInsight insight) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            icon: AppIcons.nightlight,
            label: l10n.lastNight,
            value: insight.formattedLastNight,
            color: context.colors.tertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            icon: AppIcons.barChart,
            label: l10n.weeklyAverage,
            value: insight.formattedWeeklyAverage,
            color: context.colors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            icon: AppIcons.streak,
            label: l10n.streakDays,
            value: '${insight.streakDays}',
            color: context.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.medium, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySleepChart(
      BuildContext context, List<SleepRecord> records) {
    final l10n = context.l10n;

    // Get last 7 days (or less if not available)
    final weekRecords = records.take(7).toList().reversed.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklyOverview,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Chart
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final hasRecord = index < weekRecords.length;
                final record = hasRecord ? weekRecords[index] : null;
                final hours = record?.asleepHours ?? 0;
                final maxHours = 10.0;
                final heightPercent = (hours / maxHours).clamp(0.0, 1.0);
                final barColor = _getSleepBarColor(hours, context);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: hasRecord ? 80 * heightPercent : 0,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Hours label
                        if (hasRecord)
                          Text(
                            '${hours.toStringAsFixed(1)}h',
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              color: barColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 4),
                        // Day label
                        Text(
                          _getDayLabel(index, weekRecords.length, context),
                          style: context.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color:
                                context.colors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          // Legend: 7h recommended line indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 2,
                color: context.colors.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.recommendedSleep,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationContent(
      BuildContext context, SleepWorkoutCorrelation? correlation) {
    final l10n = context.l10n;

    if (correlation == null || !correlation.hasEnoughData) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              AppIcons.info,
              color: context.colors.onSurfaceVariant,
              size: AppIconSize.large,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.correlationInsufficientData,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Good sleep effect
          _buildCorrelationRow(
            context,
            icon: AppIcons.trendUp,
            label: l10n.goodSleepEffect,
            value: correlation.formattedGoodSleepChange,
            subtitle: '${correlation.workoutsWithGoodSleep} ${l10n.workouts}',
            isPositive: correlation.volumeChangeAbove7h >= 0,
          ),
          const SizedBox(height: 12),
          // Poor sleep effect
          _buildCorrelationRow(
            context,
            icon: AppIcons.trendDown,
            label: l10n.poorSleepEffect,
            value: correlation.formattedPoorSleepChange,
            subtitle: '${correlation.workoutsWithPoorSleep} ${l10n.workouts}',
            isPositive: false,
          ),
          const SizedBox(height: 16),
          // Summary message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.lightbulb,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    correlation.summaryMessage,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required bool isPositive,
  }) {
    final color = isPositive ? context.successColor : context.errorColor;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: AppIconSize.small),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProUpgradePrompt(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withValues(alpha: 0.15),
            context.colors.tertiary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.star,
            color: context.colors.primary,
            size: AppIconSize.xlarge,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.premiumFeature,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.sleepCorrelationProDescription,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              // Navigate to premium screen
              // context.pushNamed(AppRoutes.premiumName);
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
            ),
            child: Text(l10n.upgradeToPro),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, RecoveryInsight insight) {
    final categoryColor = _getCategoryColor(insight.category, context);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.tip,
                color: categoryColor,
                size: AppIconSize.medium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.todaysRecommendation,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.recommendation,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (insight.consecutiveBadNights > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.warning,
                    size: AppIconSize.small,
                    color: context.errorColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${insight.consecutiveBadNights} ${l10n.consecutiveBadNights}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      children: [
        // Section header (always visible)
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: context.colors.primary, size: AppIconSize.medium),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    AppIcons.expandMore,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Animated content
        AnimatedCrossFade(
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: child,
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState:
              isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.error,
              size: 64,
              color: context.colors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingData,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getCategoryColor(RecoveryCategory category, BuildContext context) {
    return switch (category) {
      RecoveryCategory.optimal => context.colors.primary,
      RecoveryCategory.good => context.successColor,
      RecoveryCategory.moderate => context.warningColor,
      RecoveryCategory.low => context.errorColor,
      RecoveryCategory.critical => context.errorColor,
    };
  }

  String _getCategoryDescription(
      RecoveryCategory category, BuildContext context) {
    final l10n = context.l10n;
    return switch (category) {
      RecoveryCategory.optimal => l10n.recoveryOptimalDescription,
      RecoveryCategory.good => l10n.recoveryGoodDescription,
      RecoveryCategory.moderate => l10n.recoveryModerateDescription,
      RecoveryCategory.low => l10n.recoveryLowDescription,
      RecoveryCategory.critical => l10n.recoveryCriticalDescription,
    };
  }

  Color _getDotColor(int index, BuildContext context) {
    // Index 0 = critical (red), 4 = optimal (green)
    return switch (index) {
      0 => context.errorColor, // Critical
      1 => context.errorColor.withValues(alpha: 0.7), // Low
      2 => context.warningColor, // Moderate
      3 => context.successColor.withValues(alpha: 0.7), // Good
      4 => context.successColor, // Optimal
      _ => context.colors.onSurface,
    };
  }

  String _getCategoryName(int index, BuildContext context) {
    return switch (index) {
      0 => 'Crit',
      1 => 'Basso',
      2 => 'Mod',
      3 => 'Buono',
      4 => 'Top',
      _ => '',
    };
  }

  Color _getSleepBarColor(double hours, BuildContext context) {
    if (hours < 6) return context.errorColor;
    if (hours < 7) return context.warningColor;
    if (hours <= 9) return context.successColor;
    return context.warningColor; // Too much sleep
  }

  String _getDayLabel(int index, int totalRecords, BuildContext context) {
    if (totalRecords == 0) return '';
    // Show day abbreviations based on actual date
    final days = ['L', 'M', 'M', 'G', 'V', 'S', 'D']; // Italian
    final dayIndex = (DateTime.now()
            .subtract(Duration(days: totalRecords - 1 - index))
            .weekday -
        1);
    return days[dayIndex % 7];
  }
}
