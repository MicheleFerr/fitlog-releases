import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
// TODO: Re-enable when VolumeHeatmap is implemented
// import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/charts/volume_heatmap.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_stats_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/workout_frequency_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pr_timeline_widget.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/insights_carousel.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/scientific_muscle_balance_widget.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/export_dialog.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_calculator.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Enhanced analytics screen with advanced features
class EnhancedAnalyticsScreen extends ConsumerStatefulWidget {
  const EnhancedAnalyticsScreen({super.key});

  @override
  ConsumerState<EnhancedAnalyticsScreen> createState() => _EnhancedAnalyticsScreenState();
}

class _EnhancedAnalyticsScreenState extends ConsumerState<EnhancedAnalyticsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedExerciseId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // ⚡ OPTIMIZATION: Use .select() for granular rebuilds
    final authState = ref.watch(authStateProvider);
    final isLoading = ref.watch(
      analyticsProvider.select((state) => state.isLoading),
    );
    final error = ref.watch(
      analyticsProvider.select((state) => state.error),
    );
    final hasActivities = ref.watch(
      analyticsProvider.select((state) => state.activities.isNotEmpty),
    );

    if (authState != AuthState.authenticated) {
      return _buildNotAuthenticatedView(context, localizations);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.analytics),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(analyticsProvider.notifier).refresh();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    const Icon(Icons.download),
                    const SizedBox(width: 8),
                    Text(localizations.exportData),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings),
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
      body: isLoading
          ? _buildLoadingView(context, localizations)
          : error != null
              ? _buildErrorView(context, localizations, error)
              : !hasActivities
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

  Widget _buildOverviewTab(BuildContext context, AppLocalizations localizations) {
    // ⚡ OPTIMIZATION: Watch only needed data with .select()
    final recentPRs = ref.watch(
      analyticsProvider.select((state) => state.recentPRs),
    );
    final activities = ref.watch(
      analyticsProvider.select((state) => state.activities),
    );
    final volumeProgression = ref.watch(
      analyticsProvider.select((state) => state.volumeProgression),
    );
    final personalRecords = ref.watch(
      analyticsProvider.select((state) => state.personalRecords),
    );
    final frequencyStats = ref.read(analyticsProvider.notifier).getFrequencyStats();

    // ✅ FIX: Load actual Workout sessions for frequency chart
    final workoutsAsync = ref.watch(historicalWorkoutsProvider);
    final workouts = workoutsAsync.maybeWhen(
      data: (workouts) => workouts,
      orElse: () => <Workout>[],
    );

    return RefreshIndicator(
      onRefresh: () => ref.read(analyticsProvider.notifier).refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats
            _buildQuickStats(context, localizations, activities, volumeProgression, personalRecords, frequencyStats),
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

            // Workout Frequency
            _buildSectionTitle(context, localizations.workoutFrequency),
            const SizedBox(height: 8),
            WorkoutFrequencyChart(workouts: workouts),
            const SizedBox(height: 16),

            // Top Exercises
            _buildSectionTitle(context, localizations.topExercises),
            const SizedBox(height: 8),
            ExerciseStatsCard(
              workouts: workouts,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthTab(BuildContext context, AppLocalizations localizations) {
    final exerciseList = ref.watch(exerciseListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Re-enable when StrengthProgressionChart is implemented
          // Strength Progression Chart
          /*
          StrengthProgressionChart(
            activities: analyticsState.activities,
            selectedExerciseId: _selectedExerciseId,
            onExerciseSelected: (exerciseId) {
              setState(() {
                _selectedExerciseId = exerciseId;
              });
            },
          ),
          const SizedBox(height: 16),
          */

          // Exercise-specific stats
          if (_selectedExerciseId != null) ...[
            _buildExerciseDetailedStats(context, localizations),
            const SizedBox(height: 16),
          ],

          // Exercise List
          _buildSectionTitle(context, localizations.allExercises),
          const SizedBox(height: 8),
          ...exerciseList.map((exercise) => _buildExerciseListItem(
            context,
            exercise,
            () {
              setState(() {
                _selectedExerciseId = exercise.id;
              });
            },
          )),
        ],
      ),
    );
  }

  Widget _buildVolumeTab(BuildContext context, AppLocalizations localizations) {
    final analyticsState = ref.watch(analyticsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Re-enable when VolumeHeatmap is implemented
          // Volume Heatmap
          /*
          VolumeHeatmap(
            activities: analyticsState.activities,
            onDayTapped: (date) {
              // Handle day tap to show detailed view
              _showDayDetails(context, date);
            },
          ),
          */
          const SizedBox(height: 16),

          // Volume Progression
          _buildVolumeProgression(context, localizations, analyticsState),
          const SizedBox(height: 16),

          // Volume Stats
          _buildVolumeStats(context, localizations, analyticsState),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(BuildContext context, AppLocalizations localizations) {
    final analyticsState = ref.watch(analyticsProvider);
    final recommendations = ref.watch(workoutRecommendationsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Insights Carousel
          if (analyticsState.insights.isNotEmpty) ...[
            _buildSectionTitle(context, localizations.trainingInsights),
            const SizedBox(height: 8),
            InsightsCarousel(insights: analyticsState.insights),
            const SizedBox(height: 16),
          ],

          // Recommendations
          if (recommendations.isNotEmpty) ...[
            _buildSectionTitle(context, localizations.recommendations),
            const SizedBox(height: 8),
            ...recommendations.map((rec) => _buildRecommendationCard(context, rec)),
            const SizedBox(height: 16),
          ],

          // Exercise Trends
          _buildSectionTitle(context, localizations.exerciseTrends),
          const SizedBox(height: 8),
          _buildExerciseTrends(context, analyticsState),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    AppLocalizations localizations,
    List<ExerciseActivity> activities,
    VolumeProgression volumeProgression,
    List<PersonalRecord> personalRecords,
    Map<String, dynamic> frequencyStats,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                localizations.totalWorkouts,
                activities.length.toString(),
                Icons.fitness_center,
              ),
              _buildStatItem(
                context,
                localizations.currentStreak,
                '${frequencyStats['currentStreak'] ?? 0}',
                Icons.local_fire_department,
                color: Colors.orange,
              ),
              _buildStatItem(
                context,
                localizations.thisWeek,
                '${frequencyStats['daysInLast7'] ?? 0}',
                Icons.calendar_today,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                localizations.totalPRs,
                personalRecords.length.toString(),
                Icons.emoji_events,
                color: Colors.amber,
              ),
              _buildStatItem(
                context,
                localizations.volumeChange,
                '${volumeProgression.weeklyChange > 0 ? '+' : ''}${volumeProgression.weeklyChange.toStringAsFixed(0)}%',
                volumeProgression.weeklyChange > 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: volumeProgression.weeklyChange > 0
                    ? Colors.green
                    : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Column(
      children: [
        Icon(icon, size: 24, color: effectiveColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: effectiveColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildExerciseDetailedStats(BuildContext context, AppLocalizations localizations) {
    if (_selectedExerciseId == null) return const SizedBox.shrink();
    
    final stats = ref.read(analyticsProvider.notifier).getExerciseStats(_selectedExerciseId!);
    
    if (stats.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.exerciseDetails,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  context,
                  localizations.maxWeight,
                  '${stats['maxWeight']}kg',
                ),
                _buildDetailItem(
                  context,
                  localizations.maxReps,
                  '${stats['maxReps']}',
                ),
                _buildDetailItem(
                  context,
                  localizations.estimated1RM,
                  '${(stats['estimated1RM'] as double).toStringAsFixed(1)}kg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseListItem(
    BuildContext context,
    ({String id, String name, int count}) exercise,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        title: Text(exercise.name),
        subtitle: Text('${exercise.count} sessions'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildVolumeProgression(
    BuildContext context,
    AppLocalizations localizations,
    AnalyticsState state,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.volumeProgression,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressionItem(
                  context,
                  localizations.weekly,
                  state.volumeProgression.weeklyChange,
                  state.volumeProgression.currentWeekVolume,
                ),
                _buildProgressionItem(
                  context,
                  localizations.monthly,
                  state.volumeProgression.monthlyChange,
                  state.volumeProgression.currentMonthVolume,
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
    final isPositive = change > 0;
    final color = isPositive ? Colors.green : Colors.red;
    
    return Column(
      children: [
        Text(
          period,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 16,
            ),
            Text(
              '${change.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          '${(volume / 1000).toStringAsFixed(1)}t',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildVolumeStats(
    BuildContext context,
    AppLocalizations localizations,
    AnalyticsState state,
  ) {
    final volumeStats = ref.read(analyticsProvider.notifier)
        .getVolumeByPeriod(AnalysisPeriod.month);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.volumeStatistics,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Add volume statistics here
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, String recommendation) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
        title: Text(recommendation),
      ),
    );
  }

  Widget _buildExerciseTrends(BuildContext context, AnalyticsState state) {
    return Column(
      children: state.exerciseTrends.entries.map((entry) {
        final trend = entry.value;
        final exercise = state.activities
            .firstWhere((a) => a.exerciseId == entry.key,
                orElse: () => state.activities.first)
            .exerciseName;
        
        return Card(
          child: ListTile(
            title: Text(exercise),
            subtitle: Text(trend.recommendation),
            trailing: Icon(
              trend.type == TrendType.improving
                  ? Icons.trending_up
                  : trend.type == TrendType.declining
                      ? Icons.trending_down
                      : Icons.trending_flat,
              color: trend.type == TrendType.improving
                  ? Colors.green
                  : trend.type == TrendType.declining
                      ? Colors.red
                      : Colors.orange,
            ),
          ),
        );
      }).toList(),
    );
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
            const Icon(Icons.lock, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              localizations.pleaseLogin,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context, AppLocalizations localizations) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading analytics...'),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, AppLocalizations localizations, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(analyticsProvider.notifier).refresh();
            },
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
          const Icon(Icons.fitness_center, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            localizations.noWorkoutData,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.startWorkoutToSeeAnalytics,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/workout'),
            icon: const Icon(Icons.play_arrow),
            label: Text(localizations.startWorkout),
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
        context.go('/settings');
        break;
    }
  }

  void _showDayDetails(BuildContext context, DateTime date) {
    // TODO: Show detailed view for selected day
  }
}