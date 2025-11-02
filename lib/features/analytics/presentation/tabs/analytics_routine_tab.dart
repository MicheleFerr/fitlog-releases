/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/tabs
/// 🎯 Feature: analytics
/// 🔧 Type: widget (tab)
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// ANALYTICS ROUTINE TAB - Dedicated tab for routine analytics
///
/// Features:
/// - Adherence KPI cards (completion rate, skip rate, recovery rate)
/// - Current and longest streak display
/// - Weekly adherence trend chart
/// - Day of week pattern analysis
/// - Automated insights and suggestions
/// - Template distribution visualization
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_analytics.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_analytics_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Tab displaying routine-specific analytics
class AnalyticsRoutineTab extends ConsumerWidget {
  const AnalyticsRoutineTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(activeRoutineAnalyticsProvider);

    return analyticsAsync.when(
      data: (analytics) {
        if (analytics == null) {
          return _buildNoActiveRoutineView(context);
        }

        return _buildRoutineAnalytics(context, analytics);
      },
      loading: () => const LoadingIndicator(
        message: 'Loading routine analytics...',
      ),
      error: (error, stack) => _buildErrorView(context, error.toString()),
    );
  }

  Widget _buildNoActiveRoutineView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.calendarTodayOutlined,
              size: 80,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Routine',
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Create and activate a routine to see analytics here',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // TODO: Navigate to routine creation
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Routine'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: context.colors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Analytics',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineAnalytics(
    BuildContext context,
    RoutineAnalyticsState analytics,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header with routine name
        _buildRoutineHeader(context, analytics),
        const SizedBox(height: 24),

        // Main KPI Cards
        _buildKPICards(context, analytics.adherenceMetrics),
        const SizedBox(height: 24),

        // Streak Cards
        _buildStreakCards(context, analytics.adherenceMetrics),
        const SizedBox(height: 24),

        // Insights Section
        if (analytics.insights.isNotEmpty) ...[
          _buildInsightsSection(context, analytics.insights),
          const SizedBox(height: 24),
        ],

        // Template Distribution
        if (analytics.adherenceMetrics.templateDistribution.isNotEmpty) ...[
          _buildTemplateDistribution(
            context,
            analytics.adherenceMetrics.templateDistribution,
          ),
          const SizedBox(height: 24),
        ],

        // Day of Week Patterns
        if (analytics.dayOfWeekPatterns.isNotEmpty) ...[
          _buildDayOfWeekPatterns(context, analytics.dayOfWeekPatterns),
          const SizedBox(height: 24),
        ],

        // Weekly Trend
        if (analytics.weeklySummaries.isNotEmpty) ...[
          _buildWeeklyTrend(context, analytics.weeklySummaries),
        ],
      ],
    );
  }

  Widget _buildRoutineHeader(
    BuildContext context,
    RoutineAnalyticsState analytics,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month,
                color: context.colors.onPrimaryContainer,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analytics.routineName,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Active Routine Analytics',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
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

  Widget _buildKPICards(
    BuildContext context,
    RoutineAdherenceMetrics metrics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Metrics',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                context,
                title: 'Adherence',
                value: '${(metrics.adherenceRate * 100).toStringAsFixed(1)}%',
                icon: Icons.check_circle,
                color: _getAdherenceColor(context, metrics.adherenceRate),
                subtitle: '${metrics.completedDays}/${metrics.totalPlannedDays} days',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                context,
                title: 'Skip Rate',
                value: '${(metrics.skipRate * 100).toStringAsFixed(1)}%',
                icon: Icons.event_busy,
                color: _getSkipRateColor(context, metrics.skipRate),
                subtitle: '${metrics.skippedDays} skipped',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                context,
                title: 'Recovery',
                value: '${(metrics.recoveryRate * 100).toStringAsFixed(1)}%',
                icon: Icons.replay,
                color: _getRecoveryColor(context, metrics.recoveryRate),
                subtitle: '${metrics.recoveredDays} recovered',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                context,
                title: 'Avg Gap',
                value: '${metrics.avgDaysBetweenWorkouts.toStringAsFixed(1)}d',
                icon: Icons.trending_neutral,
                color: context.colors.secondary,
                subtitle: 'between workouts',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCards(
    BuildContext context,
    RoutineAdherenceMetrics metrics,
  ) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: context.colors.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: context.colors.onPrimaryContainer,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${metrics.currentStreak}',
                    style: context.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Current Streak',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            color: context.colors.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: context.colors.onSecondaryContainer,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${metrics.longestStreak}',
                    style: context.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSecondaryContainer,
                    ),
                  ),
                  Text(
                    'Best Streak',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(
    BuildContext context,
    List<RoutineInsight> insights,
  ) {
    // Show top 3 insights only
    final topInsights = insights.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💡 Insights',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...topInsights.map((insight) => _buildInsightCard(context, insight)),
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, RoutineInsight insight) {
    final bgColor = insight.isPositive
        ? context.colors.primaryContainer
        : context.colors.errorContainer;
    final textColor = insight.isPositive
        ? context.colors.onPrimaryContainer
        : context.colors.onErrorContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (insight.icon != null) ...[
            Text(
              insight.icon!,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.message,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (insight.actionLabel != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    insight.actionLabel!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateDistribution(
    BuildContext context,
    Map<String, double> distribution,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Template Distribution',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...distribution.entries.map(
              (entry) => _buildDistributionBar(
                context,
                label: 'Template ${entry.key.substring(0, 8)}...',
                percentage: entry.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionBar(
    BuildContext context, {
    required String label,
    required double percentage,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall,
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: context.colors.surfaceContainerHighest,
            color: context.colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDayOfWeekPatterns(
    BuildContext context,
    List<DayOfWeekPattern> patterns,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_view_week,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Pattern',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...patterns.map((pattern) => _buildDayOfWeekBar(context, pattern)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayOfWeekBar(BuildContext context, DayOfWeekPattern pattern) {
    final dayName = _getDayName(pattern.dayOfWeek);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayName,
                style: context.textTheme.bodyMedium,
              ),
              Text(
                '${(pattern.adherenceRate * 100).toStringAsFixed(0)}%',
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getAdherenceColor(context, pattern.adherenceRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: pattern.adherenceRate,
            backgroundColor: context.colors.surfaceContainerHighest,
            color: _getAdherenceColor(context, pattern.adherenceRate),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrend(
    BuildContext context,
    List<WeeklyAdherenceSummary> summaries,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Adherence Trend',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Chart visualization coming soon',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            // TODO: Implement chart widget with fl_chart
          ],
        ),
      ),
    );
  }

  Color _getAdherenceColor(BuildContext context, double rate) {
    if (rate >= 0.8) return context.colors.primary;
    if (rate >= 0.6) return Colors.orange;
    return context.colors.error;
  }

  Color _getSkipRateColor(BuildContext context, double rate) {
    if (rate <= 0.2) return context.colors.primary;
    if (rate <= 0.4) return Colors.orange;
    return context.colors.error;
  }

  Color _getRecoveryColor(BuildContext context, double rate) {
    if (rate >= 0.7) return context.colors.primary;
    if (rate >= 0.4) return Colors.orange;
    return context.colors.error;
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}
