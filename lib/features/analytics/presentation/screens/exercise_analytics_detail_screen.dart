/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/screens
/// 🎯 Feature: analytics
/// 🔧 Type: screen
///
/// Exercise Analytics Detail Screen - Detailed analytics for a single exercise
///
/// **Purpose**: Show comprehensive analytics for specific exercise
///
/// **Features**:
/// - 5 chart types (max weight, volume, 1RM, reps, PR timeline)
/// - Timeframe filtering (week, month, 3 months, year, all time)
/// - Stats summary (PR, avg volume, total sessions)
/// - Real-time sync via exerciseHistoryByNameProvider
///
/// **Usage**:
/// ```dart
/// context.push('/analytics/exercise/$exerciseName');
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/charts/max_weight_progression_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/charts/volume_progression_chart_analytics.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/charts/one_rm_progression_chart_analytics.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/charts/reps_progression_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/charts/pr_timeline_chart.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/current_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Timeframe options for filtering chart data
enum Timeframe {
  week,
  month,
  threeMonths,
  year,
  allTime;

  /// Get duration from now for filtering
  DateTime? get cutoffDate {
    final now = DateTime.now();
    switch (this) {
      case Timeframe.week:
        return now.subtract(const Duration(days: 7));
      case Timeframe.month:
        return now.subtract(const Duration(days: 30));
      case Timeframe.threeMonths:
        return now.subtract(const Duration(days: 90));
      case Timeframe.year:
        return now.subtract(const Duration(days: 365));
      case Timeframe.allTime:
        return null; // No filtering
    }
  }

  /// Get display label
  String getLabel(BuildContext context) {
    switch (this) {
      case Timeframe.week:
        return context.l10n.week;
      case Timeframe.month:
        return context.l10n.month;
      case Timeframe.threeMonths:
        return '3 ${context.l10n.months}';
      case Timeframe.year:
        return context.l10n.year;
      case Timeframe.allTime:
        return context.l10n.allTime;
    }
  }
}

/// Provider for selected timeframe (defaults to all time)
final selectedTimeframeProvider = StateProvider<Timeframe>(
  (ref) => Timeframe.allTime,
);

/// Exercise analytics detail screen
class ExerciseAnalyticsDetailScreen extends ConsumerWidget {
  const ExerciseAnalyticsDetailScreen({
    required this.exerciseName,
    super.key,
  });

  final String exerciseName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(exerciseName),
        backgroundColor: context.colors.surfaceContainerHighest,
        leading: IconButton(
          icon: SemanticIcon.button(
            icon: AppIcons.back,
            semanticLabel: context.l10n.back,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: userId == null
          ? const _NotAuthenticatedView()
          : _ExerciseDetailContent(
              userId: userId,
              exerciseName: exerciseName,
            ),
    );
  }
}

/// Exercise detail content with chart tabs
class _ExerciseDetailContent extends ConsumerWidget {
  const _ExerciseDetailContent({
    required this.userId,
    required this.exerciseName,
  });

  final String userId;
  final String exerciseName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(
      exerciseHistoryByNameProvider((userId, exerciseName)),
    );

    return historyAsync.when(
      data: (history) => _ExerciseCharts(history: history),
      loading: () => const _LoadingView(),
      error: (error, _) => _ErrorView(error: error.toString()),
    );
  }
}

/// Exercise charts and stats
class _ExerciseCharts extends ConsumerWidget {
  const _ExerciseCharts({required this.history});

  final ExerciseHistory history;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (history.sessions.isEmpty) {
      return const _EmptyStateView();
    }

    // Watch selected timeframe
    final selectedTimeframe = ref.watch(selectedTimeframeProvider);

    // Filter sessions based on timeframe
    final cutoffDate = selectedTimeframe.cutoffDate;
    final filteredSessions = cutoffDate == null
        ? history.sessions
        : history.sessions.where((session) => session.date.isAfter(cutoffDate)).toList();

    // Create filtered history
    final filteredHistory = ExerciseHistory(
      exerciseName: history.exerciseName,
      muscleGroup: history.muscleGroup,
      sessions: filteredSessions,
    );

    // Check if filtered history is empty
    if (filteredSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.calendar,
              semanticLabel: context.l10n.noDataAvailable,
              size: AppIconSize.xxlarge,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noDataForTimeframe,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.tryDifferentTimeframe,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          // Stats summary card
          _StatsSummaryCard(history: filteredHistory),

          // Timeframe selector
          _TimeframeSelector(),

          // Chart type tabs
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                icon: SemanticIcon(
                  icon: AppIcons.weight,
                  semanticLabel: context.l10n.maxWeight,
                  size: AppIconSize.small,
                ),
                text: context.l10n.maxWeight,
              ),
              Tab(
                icon: SemanticIcon(
                  icon: AppIcons.barChart,
                  semanticLabel: context.l10n.volume,
                  size: AppIconSize.small,
                ),
                text: context.l10n.volume,
              ),
              Tab(
                icon: SemanticIcon(
                  icon: AppIcons.trendingUp,
                  semanticLabel: '1RM',
                  size: AppIconSize.small,
                ),
                text: '1RM',
              ),
              Tab(
                icon: SemanticIcon(
                  icon: AppIcons.repeat,
                  semanticLabel: context.l10n.reps,
                  size: AppIconSize.small,
                ),
                text: context.l10n.reps,
              ),
              Tab(
                icon: SemanticIcon(
                  icon: AppIcons.achievement,
                  semanticLabel: 'PR Timeline',
                  size: AppIconSize.small,
                ),
                text: 'PR',
              ),
            ],
          ),

          // Chart views
          Expanded(
            child: TabBarView(
              children: [
                // Max weight chart
                MaxWeightProgressionChart(history: filteredHistory),
                // Volume chart
                VolumeProgressionChartAnalytics(history: filteredHistory),
                // 1RM chart
                OneRMProgressionChartAnalytics(history: filteredHistory),
                // Reps chart
                RepsProgressionChart(history: filteredHistory),
                // PR timeline chart
                PRTimelineChart(history: filteredHistory),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Timeframe selector widget with chips
class _TimeframeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTimeframe = ref.watch(selectedTimeframeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: Timeframe.values.map((timeframe) {
            final isSelected = selectedTimeframe == timeframe;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(timeframe.getLabel(context)),
                selected: isSelected,
                onSelected: (_) {
                  ref.read(selectedTimeframeProvider.notifier).state = timeframe;
                },
                selectedColor: context.colors.primary.withValues(alpha: 0.2),
                checkmarkColor: context.colors.primary,
                labelStyle: context.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Stats summary card
class _StatsSummaryCard extends StatelessWidget {
  const _StatsSummaryCard({required this.history});

  final ExerciseHistory history;

  @override
  Widget build(BuildContext context) {
    final pr = history.personalRecord;
    final sessionsCount = history.sessions.length;
    final weeklyProgression = history.weeklyVolumeProgression;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // PR
            _StatItem(
              icon: AppIcons.achievement,
              label: 'PR',
              value: '${pr.toStringAsFixed(1)} kg',
              color: context.colors.primary,
            ),
            _Divider(),
            // Sessions
            _StatItem(
              icon: AppIcons.calendar,
              label: context.l10n.workouts,
              value: '$sessionsCount',
              color: context.colors.secondary,
            ),
            _Divider(),
            // Weekly progression
            _StatItem(
              icon: weeklyProgression >= 0
                  ? AppIcons.trendingUp
                  : AppIcons.trendingDown,
              label: context.l10n.progress,
              value: '${weeklyProgression.toStringAsFixed(1)}%',
              color: weeklyProgression >= 0
                  ? context.colors.success
                  : context.colors.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SemanticIcon(
          icon: icon,
          semanticLabel: '$label: $value',
          size: AppIconSize.medium,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 60,
      color: context.colors.onSurfaceVariant.withValues(alpha: 0.2),
    );
  }
}

// State views
class _NotAuthenticatedView extends StatelessWidget {
  const _NotAuthenticatedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.lock,
            semanticLabel: context.l10n.pleaseLoginToViewAnalytics,
            size: AppIconSize.xxlarge,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.pleaseLoginToViewAnalytics,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 16),
          Text(
            context.l10n.loadingYourAnalytics,
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.error,
            semanticLabel: context.l10n.errorLoadingAnalytics,
            size: AppIconSize.xxlarge,
            color: context.colors.error,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.errorLoadingAnalytics,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.barChart,
            semanticLabel: context.l10n.noWorkoutDataYet,
            size: AppIconSize.xxlarge,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.noWorkoutDataYet,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.completeWorkoutsToSeeAnalytics,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
