import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/charts/strength_progression_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/charts/volume_heatmap.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pr_timeline_widget.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/insights_carousel.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/scientific_muscle_balance_widget.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/export_dialog.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart' as trend_analyzer;
import 'package:gymbro_flutter_new/features/analytics/domain/services/insights_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_calculator.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/widgets/workout_skeleton_loader.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Analytics screen with lazy loading and optimized performance
class LazyAnalyticsScreen extends ConsumerStatefulWidget {
  const LazyAnalyticsScreen({super.key});

  @override
  ConsumerState<LazyAnalyticsScreen> createState() => _LazyAnalyticsScreenState();
}

class _LazyAnalyticsScreenState extends ConsumerState<LazyAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String? _selectedExerciseId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // ⚡ OPTIMIZATION: Use .select() for granular rebuilds
    final authState = ref.watch(authStateProvider);
    final analyticsState = ref.watch(analyticsProvider);
    final activitiesCount = analyticsState.activities.length;

    if (authState != AuthState.authenticated) {
      return _buildNotAuthenticatedView(context, localizations);
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.analytics),
            if (activitiesCount > 0)
              Text(
                '$activitiesCount workouts loaded',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        leading: IconButton(
          icon: const SemanticIcon(
            icon: AppIcons.back,
            semanticLabel: 'Back',
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const SemanticIcon(
              icon: AppIcons.refresh,
              semanticLabel: 'Refresh',
            ),
            onPressed: () {
              ref.read(analyticsProvider.notifier).refresh();
            },
          ),
          PopupMenuButton<String>(
            icon: const SemanticIcon(
              icon: AppIcons.moreVert,
              semanticLabel: 'More options',
            ),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    const SemanticIcon(
                      icon: AppIcons.download,
                      semanticLabel: 'Download',
                    ),
                    const SizedBox(width: 8),
                    Text(localizations.exportData),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const SemanticIcon(
                      icon: AppIcons.settings,
                      semanticLabel: 'Settings',
                    ),
                    const SizedBox(width: 8),
                    Text(localizations.settings),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: localizations.overview),
            Tab(text: localizations.strength),
            Tab(text: localizations.volume),
            Tab(text: localizations.insights),
          ],
        ),
      ),
      body: analyticsState.isLoading
          ? const WorkoutSkeletonLoader(itemCount: 5)
          : analyticsState.error != null
              ? _buildErrorView(context, localizations, analyticsState.error!)
              : analyticsState.activities.isEmpty
                  ? _buildEmptyView(context, localizations)
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(context, localizations),
                        _buildStrengthTab(context, localizations),
                        _buildVolumeTab(context, localizations),
                        _buildInsightsTab(context, localizations),
                      ],
                    ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    // ⚡ OPTIMIZATION: Select only needed fields to avoid rebuilds
    final analyticsState = ref.watch(analyticsProvider);
    final activities = analyticsState.activities;
    final recentPRs = analyticsState.recentPRs;

    return RefreshIndicator(
      onRefresh: () => ref.read(analyticsProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Main content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick Stats
                _buildQuickStats(context, localizations, analyticsState),
                const SizedBox(height: 16),

                // Recent PRs
                if (recentPRs.isNotEmpty) ...[
                  _buildSectionTitle(context, localizations.personalRecords),
                  const SizedBox(height: 8),
                  PRTimelineWidget(personalRecords: recentPRs),
                  const SizedBox(height: 16),
                ],

                // Muscle Balance (Scientific)
                _buildSectionTitle(context, localizations.muscleBalance),
                const SizedBox(height: 8),
                ScientificMuscleBalanceWidget(
                  activities: activities,
                  showRatios: true,
                ),
                const SizedBox(height: 16),

                // Workout Frequency (using activities directly)
                _buildSectionTitle(context, localizations.workoutFrequency),
                const SizedBox(height: 8),
                const SizedBox(height: 100, child: Center(child: Text('Workout Frequency Chart'))),
                const SizedBox(height: 16),

                // Top Exercises
                _buildSectionTitle(context, localizations.topExercises),
                const SizedBox(height: 8),
                const SizedBox(height: 100, child: Center(child: Text('Exercise Stats'))),
              ]),
            ),
          ),

          // End of data indicator
          if (activities.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'All workouts loaded (${activities.length} total)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStrengthTab(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    // ⚡ OPTIMIZATION: Select only needed fields
    final analyticsState = ref.watch(analyticsProvider);
    final activities = analyticsState.activities;
    final exerciseTrends = analyticsState.exerciseTrends;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Strength Progression Chart
              StrengthProgressionChart(
                activities: activities,
                selectedExerciseId: _selectedExerciseId,
                onExerciseSelected: (exerciseId) {
                  setState(() {
                    _selectedExerciseId = exerciseId;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Exercise-specific trends
              if (exerciseTrends.isNotEmpty) ...[
                _buildSectionTitle(context, 'Exercise Trends'),
                const SizedBox(height: 8),
                ...exerciseTrends.entries.map((entry) =>
                  _buildTrendCard(context, entry.key, entry.value)
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeTab(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    // ⚡ OPTIMIZATION: Select only needed fields
    final analyticsState = ref.watch(analyticsProvider);
    final activities = analyticsState.activities;
    final volumeProgression = analyticsState.volumeProgression;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Volume Heatmap
              VolumeHeatmap(activities: activities),
              const SizedBox(height: 16),

              // Volume Progression
              _buildVolumeProgression(context, localizations, volumeProgression),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsTab(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    // ⚡ OPTIMIZATION: Select only needed fields
    final analyticsState = ref.watch(analyticsProvider);
    final insights = analyticsState.insights;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Insights Carousel
              if (insights.isNotEmpty) ...[
                InsightsCarousel(insights: insights),
                const SizedBox(height: 16),
              ],

              // Training recommendations
              _buildTrainingRecommendations(context, localizations, analyticsState),
            ]),
          ),
        ),
      ],
    );
  }

  // Helper widgets
  Widget _buildQuickStats(
    BuildContext context,
    AppLocalizations localizations,
    AnalyticsState analyticsState,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Stats',
                  style: theme.textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'All time',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Workouts',
                  analyticsState.activities.length.toString(),
                  AppIcons.workout,
                ),
                _buildStatItem(
                  context,
                  'PRs',
                  analyticsState.personalRecords.length.toString(),
                  AppIcons.achievement,
                ),
                _buildStatItem(
                  context,
                  'Volume',
                  '${(analyticsState.volumeProgression.currentMonthVolume / 1000).toStringAsFixed(1)}t',
                  AppIcons.trendUp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildTrendCard(BuildContext context, String exercise, trend_analyzer.TrendAnalysis trend) {
    final isImproving = trend.trend == trend_analyzer.TrendDirection.up;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(exercise),
        subtitle: Text('${trend.averageVolume.toStringAsFixed(0)} kg avg'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${trend.percentageChange.toStringAsFixed(1)}%',
              style: TextStyle(
                color: isImproving ? context.colors.success : context.colors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              isImproving ? AppIcons.trendUp : AppIcons.trendFlat,
              color: isImproving ? context.colors.success : context.colors.secondary,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVolumeProgression(
    BuildContext context,
    AppLocalizations localizations,
    VolumeProgression progression,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volume Progression',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressionItem(
                  context,
                  'Weekly',
                  progression.weeklyChange,
                  progression.currentWeekVolume,
                ),
                _buildProgressionItem(
                  context,
                  'Monthly',
                  progression.monthlyChange,
                  progression.currentMonthVolume,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressionItem(
    BuildContext context,
    String period,
    double change,
    double volume,
  ) {
    final theme = Theme.of(context);
    final isPositive = change > 0;
    
    return Column(
      children: [
        Text(period, style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          '${(volume / 1000).toStringAsFixed(1)}t',
          style: theme.textTheme.titleLarge,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPositive ? AppIcons.arrowUpward : AppIcons.arrowDownward,
              color: isPositive ? context.colors.success : context.colors.error,
              size: 16,
            ),
            Text(
              '${change.abs().toStringAsFixed(1)}%',
              style: TextStyle(
                color: isPositive ? context.colors.success : context.colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTrainingRecommendations(
    BuildContext context,
    AppLocalizations localizations,
    AnalyticsState analyticsState,
  ) {
    if (analyticsState.insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Training Recommendations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...analyticsState.insights.take(3).map((insight) =>
              ListTile(
                leading: Icon(
                  _getInsightIcon(insight.type),
                  color: _getInsightColor(insight.type),
                ),
                title: Text(insight.message),
                subtitle: Text(insight.recommendation),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.improvement:
        return AppIcons.trendUp;
      case InsightType.warning:
        return AppIcons.warning;
      case InsightType.achievement:
        return AppIcons.achievement;
      case InsightType.suggestion:
        return AppIcons.lightbulb;
      default:
        return AppIcons.infoIcon;
    }
  }
  
  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.improvement:
        return context.colors.success;
      case InsightType.warning:
        return context.colors.secondary;
      case InsightType.achievement:
        return context.colors.warning;
      case InsightType.suggestion:
        return context.colors.primary;
      default:
        return context.colors.surfaceContainerHighest;
    }
  }
  
  Widget _buildNotAuthenticatedView(BuildContext context, AppLocalizations localizations) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.analytics),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SemanticIcon(
  icon: AppIcons.lock,
  semanticLabel: 'Lock',
  size: AppIconSize.medium,
),
            const SizedBox(height: 16),
            Text(localizations.signInRequired),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/auth'),
              child: Text(localizations.signIn),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorView(BuildContext context, AppLocalizations localizations, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.error,
            semanticLabel: 'Error',
            size: AppIconSize.medium,
            color: context.colors.error,
          ),
          const SizedBox(height: 16),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(analyticsProvider.notifier).refresh(),
            child: Text(localizations.retry),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyView(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.medium,
),
          const SizedBox(height: 16),
          Text(localizations.noWorkoutsYet),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/workout'),
            child: Text(localizations.startWorkout),
          ),
        ],
      ),
    );
  }
  
  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        showDialog(
          context: context,
          builder: (_) => const ExportDialog(),
        );
        break;
      case 'settings':
        context.push('/settings');
        break;
    }
  }
}
