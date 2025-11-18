/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: analytics
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// **Monthly Summary Card - Priority 1 Feature**
/// Evidence: +78% retention (Strava case study)
/// Shows: This month vs last month comparison with trend indicators
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Monthly summary card comparing current month vs last month
class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({
    required this.workouts,
    super.key,
  });

  final List<Workout> workouts;

  @override
  Widget build(BuildContext context) {
    final stats = _calculateMonthlyStats(workouts);
    final highlight = _getBestImprovement(stats);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  AppIcons.calendar,
                  color: context.colors.primary,
                  size: AppIconSize.large,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 ${context.l10n.monthlyProgress}',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        context.l10n.thisMonthVsLast,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🌟 Highlight Card (Best Improvement)
            if (highlight != null) ...[
              _buildHighlightBanner(context, highlight),
              const SizedBox(height: 16),
            ],

            // Metrics Comparison Grid
            _buildMetricsGrid(context, stats),
          ],
        ),
      ),
    );
  }

  /// Build highlight banner showing best improvement
  Widget _buildHighlightBanner(
    BuildContext context,
    _MetricImprovement highlight,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.success.withAlpha(40),
            context.colors.success.withAlpha(20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.success.withAlpha(100),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.success,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              AppIcons.trendUp,
              color: Colors.white,
              size: AppIconSize.medium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌟 ${context.l10n.bestImprovement}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.success,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  highlight.message,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${highlight.percentChange.abs().toStringAsFixed(0)}%',
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build metrics comparison grid
  Widget _buildMetricsGrid(
    BuildContext context,
    _MonthlyStats stats,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context,
                icon: AppIcons.workout,
                label: context.l10n.workouts,
                thisMonth: stats.thisMonthWorkouts.toString(),
                lastMonth: stats.lastMonthWorkouts.toString(),
                percentChange: stats.workoutsChangePercent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                context,
                icon: AppIcons.weight,
                label: context.l10n.volume,
                thisMonth: '${stats.thisMonthVolume.toStringAsFixed(0)} kg',
                lastMonth: '${stats.lastMonthVolume.toStringAsFixed(0)} kg',
                percentChange: stats.volumeChangePercent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context,
                icon: AppIcons.clock,
                label: context.l10n.avgDuration,
                thisMonth: '${stats.thisMonthAvgDuration.toStringAsFixed(0)} min',
                lastMonth: '${stats.lastMonthAvgDuration.toStringAsFixed(0)} min',
                percentChange: stats.durationChangePercent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                context,
                icon: AppIcons.calendar,
                label: context.l10n.consistency,
                thisMonth: '${stats.thisMonthConsistency.toStringAsFixed(0)}%',
                lastMonth: '${stats.lastMonthConsistency.toStringAsFixed(0)}%',
                percentChange: stats.consistencyChangePercent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual metric tile with comparison
  Widget _buildMetricTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String thisMonth,
    required String lastMonth,
    required double percentChange,
  }) {
    final isImproved = percentChange > 0;
    final isStable = percentChange.abs() < 5; // < 5% = stable
    final color = isStable
        ? Theme.of(context).colorScheme.tertiary
        : (isImproved ? context.colors.success : context.colors.error);

    final trendIcon = isStable
        ? AppIcons.trendFlat
        : (isImproved ? AppIcons.trendUp : AppIcons.trendDown);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Label
          Row(
            children: [
              Icon(
                icon,
                size: AppIconSize.small,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // This Month Value
          Text(
            thisMonth,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Comparison Row
          Row(
            children: [
              Icon(
                trendIcon,
                size: AppIconSize.tiny,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${percentChange > 0 ? '+' : ''}${percentChange.toStringAsFixed(0)}%',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'vs $lastMonth',
                style: context.textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================================
  // CALCULATION LOGIC
  // =============================================================================

  _MonthlyStats _calculateMonthlyStats(List<Workout> workouts) {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = thisMonthStart.subtract(const Duration(days: 1));

    // Filter workouts
    final thisMonthWorkouts = workouts.where((w) {
      final date = w.endTime ?? w.createdAt;
      return date.isAfter(thisMonthStart) && date.isBefore(now);
    }).toList();

    final lastMonthWorkouts = workouts.where((w) {
      final date = w.endTime ?? w.createdAt;
      return date.isAfter(lastMonthStart) && date.isBefore(lastMonthEnd);
    }).toList();

    // Calculate stats this month
    final thisMonthCount = thisMonthWorkouts.length;
    final thisMonthVolume = _calculateTotalVolume(thisMonthWorkouts);
    final thisMonthAvgDuration = _calculateAvgDuration(thisMonthWorkouts);
    final thisMonthConsistency = _calculateConsistency(thisMonthWorkouts, now);

    // Calculate stats last month
    final lastMonthCount = lastMonthWorkouts.length;
    final lastMonthVolume = _calculateTotalVolume(lastMonthWorkouts);
    final lastMonthAvgDuration = _calculateAvgDuration(lastMonthWorkouts);
    final lastMonthConsistency = _calculateConsistency(
      lastMonthWorkouts,
      lastMonthEnd,
    );

    // Calculate percent changes
    final workoutsChange = _percentChange(lastMonthCount.toDouble(), thisMonthCount.toDouble());
    final volumeChange = _percentChange(lastMonthVolume, thisMonthVolume);
    final durationChange = _percentChange(lastMonthAvgDuration, thisMonthAvgDuration);
    final consistencyChange = _percentChange(lastMonthConsistency, thisMonthConsistency);

    return _MonthlyStats(
      thisMonthWorkouts: thisMonthCount,
      lastMonthWorkouts: lastMonthCount,
      workoutsChangePercent: workoutsChange,
      thisMonthVolume: thisMonthVolume,
      lastMonthVolume: lastMonthVolume,
      volumeChangePercent: volumeChange,
      thisMonthAvgDuration: thisMonthAvgDuration,
      lastMonthAvgDuration: lastMonthAvgDuration,
      durationChangePercent: durationChange,
      thisMonthConsistency: thisMonthConsistency,
      lastMonthConsistency: lastMonthConsistency,
      consistencyChangePercent: consistencyChange,
    );
  }

  double _calculateTotalVolume(List<Workout> workouts) {
    return workouts.fold(0.0, (sum, workout) {
      return sum +
          workout.exercises.fold(0.0, (exSum, exercise) {
            return exSum +
                exercise.sets.where((s) => s.isCompleted && !s.isWarmup).fold(
                    0.0, (setSum, set) {
                  final weight = set.weight ?? 0.0;
                  final reps = set.reps ?? 0;
                  return setSum + (weight * reps);
                });
          });
    });
  }

  double _calculateAvgDuration(List<Workout> workouts) {
    if (workouts.isEmpty) return 0.0;

    final totalMinutes = workouts.fold(0.0, (sum, workout) {
      return sum + (workout.duration?.inMinutes ?? 0);
    });

    return totalMinutes / workouts.length;
  }

  double _calculateConsistency(List<Workout> workouts, DateTime monthEnd) {
    if (workouts.isEmpty) return 0.0;

    final daysInMonth = DateTime(monthEnd.year, monthEnd.month + 1, 0).day;
    final workoutDays = workouts
        .map((w) => (w.endTime ?? w.createdAt).day)
        .toSet()
        .length;

    return (workoutDays / daysInMonth) * 100;
  }

  double _percentChange(double oldValue, double newValue) {
    if (oldValue == 0) return newValue > 0 ? 100.0 : 0.0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  _MetricImprovement? _getBestImprovement(_MonthlyStats stats) {
    final improvements = <_MetricImprovement>[
      if (stats.workoutsChangePercent > 5)
        _MetricImprovement(
          metric: 'workouts',
          percentChange: stats.workoutsChangePercent,
          message: 'Workouts: ${stats.thisMonthWorkouts} this month! 💪',
        ),
      if (stats.volumeChangePercent > 5)
        _MetricImprovement(
          metric: 'volume',
          percentChange: stats.volumeChangePercent,
          message: 'Volume: ${stats.thisMonthVolume.toStringAsFixed(0)}kg! 🚀',
        ),
      if (stats.durationChangePercent > 5)
        _MetricImprovement(
          metric: 'duration',
          percentChange: stats.durationChangePercent,
          message: 'Avg duration: ${stats.thisMonthAvgDuration.toStringAsFixed(0)}min! ⏱️',
        ),
      if (stats.consistencyChangePercent > 5)
        _MetricImprovement(
          metric: 'consistency',
          percentChange: stats.consistencyChangePercent,
          message: 'Consistency: ${stats.thisMonthConsistency.toStringAsFixed(0)}%! 🎯',
        ),
    ];

    if (improvements.isEmpty) return null;

    // Return improvement with highest % change
    improvements.sort((a, b) => b.percentChange.compareTo(a.percentChange));
    return improvements.first;
  }
}

// =============================================================================
// DATA CLASSES
// =============================================================================

class _MonthlyStats {
  const _MonthlyStats({
    required this.thisMonthWorkouts,
    required this.lastMonthWorkouts,
    required this.workoutsChangePercent,
    required this.thisMonthVolume,
    required this.lastMonthVolume,
    required this.volumeChangePercent,
    required this.thisMonthAvgDuration,
    required this.lastMonthAvgDuration,
    required this.durationChangePercent,
    required this.thisMonthConsistency,
    required this.lastMonthConsistency,
    required this.consistencyChangePercent,
  });

  final int thisMonthWorkouts;
  final int lastMonthWorkouts;
  final double workoutsChangePercent;

  final double thisMonthVolume;
  final double lastMonthVolume;
  final double volumeChangePercent;

  final double thisMonthAvgDuration;
  final double lastMonthAvgDuration;
  final double durationChangePercent;

  final double thisMonthConsistency;
  final double lastMonthConsistency;
  final double consistencyChangePercent;
}

class _MetricImprovement {
  const _MetricImprovement({
    required this.metric,
    required this.percentChange,
    required this.message,
  });

  final String metric;
  final double percentChange;
  final String message;
}
