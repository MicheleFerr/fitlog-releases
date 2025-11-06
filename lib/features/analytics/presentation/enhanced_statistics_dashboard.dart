import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/enhanced_chart_widgets.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/enhanced_stat_cards.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/enhanced_progress_indicators.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Enhanced Statistics Dashboard with Material 3 design and responsive layout
class EnhancedStatisticsDashboard extends ConsumerWidget {

  const EnhancedStatisticsDashboard({
    super.key,
    required this.activities,
    required this.userEmail,
  });
  final List<ExerciseActivity> activities;
  final String userEmail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = _isTablet(context);
    final stats = _calculateEnhancedStats(activities);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.statisticsDashboard),
        backgroundColor: colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: () => _refreshData(ref),
          ),
          IconButton(
            icon: const Icon(AppIcons.filter),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(ref),
        child: activities.isEmpty
            ? _buildEmptyState(context, localizations)
            : _buildDashboardContent(context, stats, isTablet, localizations),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    EnhancedWorkoutStats stats,
    bool isTablet,
    AppLocalizations localizations,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Quick Stats
          _buildHeaderSection(context, stats, localizations),
          SizedBox(height: isTablet ? 32 : 24),

          // Overview Cards Grid
          _buildOverviewGrid(context, stats, isTablet, localizations),
          SizedBox(height: isTablet ? 32 : 24),

          // Chart Section
          _buildChartsSection(context, activities, isTablet, localizations),
          SizedBox(height: isTablet ? 32 : 24),

          // Progress Tracking Section
          _buildProgressSection(context, activities, isTablet, localizations),
          SizedBox(height: isTablet ? 32 : 24),

          // Detailed Analytics Section
          _buildDetailedAnalyticsSection(context, activities, isTablet, localizations),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    EnhancedWorkoutStats stats,
    AppLocalizations localizations,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.trendUp,
                size: 32,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.workoutProgress,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getProgressSummary(stats, localizations),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat(
                context,
                localizations.thisWeek,
                '${stats.weeklyWorkouts}',
                AppIcons.calendar,
              ),
              _buildQuickStat(
                context,
                localizations.totalVolume,
                '${stats.totalVolume.toStringAsFixed(0)}kg',
                AppIcons.workout,
              ),
              _buildQuickStat(
                context,
                localizations.consistency,
                '${stats.consistencyPercentage}%',
                AppIcons.trendUp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(
          icon,
          color: colorScheme.onPrimaryContainer,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewGrid(
    BuildContext context,
    EnhancedWorkoutStats stats,
    bool isTablet,
    AppLocalizations localizations,
  ) {
    final crossAxisCount = isTablet ? 4 : 2;
    final childAspectRatio = isTablet ? 1.2 : 1.5;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        EnhancedStatCard(
          title: localizations.totalWorkouts,
          value: '${stats.totalWorkouts}',
          icon: AppIcons.workout,
          trend: stats.workoutTrend,
          subtitle: localizations.completedSessions,
        ),
        EnhancedStatCard(
          title: localizations.totalVolume,
          value: '${stats.totalVolume.toStringAsFixed(0)}kg',
          icon: AppIcons.barChart,
          trend: stats.volumeTrend,
          subtitle: localizations.weightLifted,
        ),
        EnhancedStatCard(
          title: localizations.averageWorkoutTime,
          value: '${stats.averageWorkoutDuration}min',
          icon: AppIcons.timer,
          trend: stats.durationTrend,
          subtitle: localizations.perSession,
        ),
        EnhancedStatCard(
          title: localizations.personalRecords,
          value: '${stats.personalRecords}',
          icon: AppIcons.achievement,
          trend: StatTrend.positive,
          subtitle: localizations.newPRs,
        ),
      ],
    );
  }

  Widget _buildChartsSection(
    BuildContext context,
    List<ExerciseActivity> activities,
    bool isTablet,
    AppLocalizations localizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.workoutAnalytics,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (isTablet)
          Row(
            children: [
              Expanded(
                child: EnhancedVolumeChart(activities: activities),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: EnhancedFrequencyChart(activities: activities),
              ),
            ],
          )
        else
          Column(
            children: [
              EnhancedVolumeChart(activities: activities),
              const SizedBox(height: 16),
              EnhancedFrequencyChart(activities: activities),
            ],
          ),
        const SizedBox(height: 16),
        EnhancedBodyPartChart(activities: activities),
      ],
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    List<ExerciseActivity> activities,
    bool isTablet,
    AppLocalizations localizations,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.trendUp,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  localizations.progressTracking,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...activities
                .take(3)
                .map((activity) => EnhancedProgressIndicator(
                      activity: activity,
                      showDetailedMetrics: isTablet,
                    ))
                ,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedAnalyticsSection(
    BuildContext context,
    List<ExerciseActivity> activities,
    bool isTablet,
    AppLocalizations localizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.detailedAnalytics,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (isTablet)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: EnhancedExerciseRankingCard(activities: activities),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: EnhancedStreakCard(activities: activities),
              ),
            ],
          )
        else
          Column(
            children: [
              EnhancedExerciseRankingCard(activities: activities),
              const SizedBox(height: 16),
              EnhancedStreakCard(activities: activities),
            ],
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.analytics,
            size: 120,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          SizedBox(height: 24),
          Text(
            localizations.noWorkoutData,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.completeWorkoutsToSeeAnalytics,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/workout'),
            icon: const Icon(AppIcons.play),
            label: Text(localizations.startFirstWorkout),
          ),
        ],
      ),
    );
  }

  // Utility Methods
  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  void _refreshData(WidgetRef ref) {
    // Refresh providers and invalidate cache
    // Implementation would depend on your provider setup
  }

  void _showFilterDialog(BuildContext context) {
    // Show filter options dialog
    showDialog(
      context: context,
      builder: (context) => const StatisticsFilterDialog(),
    );
  }

  String _getProgressSummary(
    EnhancedWorkoutStats stats,
    AppLocalizations localizations,
  ) {
    if (stats.workoutTrend == StatTrend.positive) {
      return localizations.improvingProgressSummary;
    } else if (stats.workoutTrend == StatTrend.negative) {
      return localizations.needsImprovementSummary;
    } else {
      return localizations.steadyProgressSummary;
    }
  }

  EnhancedWorkoutStats _calculateEnhancedStats(List<ExerciseActivity> activities) {
    // Enhanced calculations for comprehensive statistics
    final now = DateTime.now();
    final thisWeek = now.subtract(const Duration(days: 7));
    
    final weeklyWorkouts = activities
        .where((a) => a.createdAt.isAfter(thisWeek))
        .map((a) => a.schedaName)
        .toSet()
        .length;

    final totalVolume = activities.fold<double>(0.0, (sum, activity) {
      return sum + activity.sets.fold<double>(0.0, (setSum, set) {
        final weight = double.tryParse(set.weight) ?? 0.0;
        final reps = int.tryParse(set.reps) ?? 0;
        return setSum + (weight * reps);
      });
    });

    return EnhancedWorkoutStats(
      totalWorkouts: activities.map((a) => a.schedaName).toSet().length,
      weeklyWorkouts: weeklyWorkouts,
      totalVolume: totalVolume,
      averageWorkoutDuration: 45, // Calculate based on workout data
      personalRecords: 12, // Calculate based on exercise progression
      consistencyPercentage: _calculateConsistency(activities),
      workoutTrend: _calculateTrend(activities, TrendType.workouts),
      volumeTrend: _calculateTrend(activities, TrendType.volume),
      durationTrend: _calculateTrend(activities, TrendType.duration),
    );
  }

  int _calculateConsistency(List<ExerciseActivity> activities) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final workoutDays = activities.where((activity) {
      return activity.createdAt.year == now.year &&
             activity.createdAt.month == now.month;
    }).map((a) => a.createdAt.day).toSet().length;
    
    return ((workoutDays / daysInMonth) * 100).round();
  }

  StatTrend _calculateTrend(List<ExerciseActivity> activities, TrendType type) {
    // Calculate trend based on type (workouts, volume, duration)
    // This is a simplified implementation
    return StatTrend.positive;
  }
}

// Filter Dialog Widget
class StatisticsFilterDialog extends StatefulWidget {
  const StatisticsFilterDialog({super.key});

  @override
  State<StatisticsFilterDialog> createState() => _StatisticsFilterDialogState();
}

class _StatisticsFilterDialogState extends State<StatisticsFilterDialog> {
  String selectedPeriod = 'last30Days';
  Set<String> selectedCategories = {'chest', 'back', 'legs'};

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return AlertDialog(
      title: Text(localizations.filterStatistics),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.timePeriod,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // Time period selection
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(localizations.lastWeek),
                  selected: selectedPeriod == 'lastWeek',
                  onSelected: (selected) {
                    setState(() => selectedPeriod = 'lastWeek');
                  },
                ),
                ChoiceChip(
                  label: Text(localizations.lastMonth),
                  selected: selectedPeriod == 'lastMonth',
                  onSelected: (selected) {
                    setState(() => selectedPeriod = 'lastMonth');
                  },
                ),
                ChoiceChip(
                  label: Text(localizations.lastThreeMonths),
                  selected: selectedPeriod == 'last3Months',
                  onSelected: (selected) {
                    setState(() => selectedPeriod = 'last3Months');
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              localizations.muscleGroups,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // Muscle group filters
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text(localizations.exerciseCategoryChest),
                  selected: selectedCategories.contains('chest'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedCategories.add('chest');
                      } else {
                        selectedCategories.remove('chest');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: Text(localizations.exerciseCategoryBack),
                  selected: selectedCategories.contains('back'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedCategories.add('back');
                      } else {
                        selectedCategories.remove('back');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: Text(localizations.exerciseCategoryLegs),
                  selected: selectedCategories.contains('legs'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedCategories.add('legs');
                      } else {
                        selectedCategories.remove('legs');
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        FilledButton(
          onPressed: () {
            // Apply filters
            Navigator.of(context).pop();
          },
          child: Text(localizations.applyFilters),
        ),
      ],
    );
  }
}

// Data Classes
class EnhancedWorkoutStats {

  EnhancedWorkoutStats({
    required this.totalWorkouts,
    required this.weeklyWorkouts,
    required this.totalVolume,
    required this.averageWorkoutDuration,
    required this.personalRecords,
    required this.consistencyPercentage,
    required this.workoutTrend,
    required this.volumeTrend,
    required this.durationTrend,
  });
  final int totalWorkouts;
  final int weeklyWorkouts;
  final double totalVolume;
  final int averageWorkoutDuration;
  final int personalRecords;
  final int consistencyPercentage;
  final StatTrend workoutTrend;
  final StatTrend volumeTrend;
  final StatTrend durationTrend;
}

enum StatTrend { positive, negative, neutral }
enum TrendType { workouts, volume, duration }
