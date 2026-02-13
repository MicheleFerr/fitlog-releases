import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/exercise_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/hero_stat_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/weekly_dashboard_widget.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/premium_feature_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';

class AnalyticsOverviewTab extends ConsumerStatefulWidget {
  const AnalyticsOverviewTab({super.key, required this.workouts});
  final List<Workout> workouts;

  @override
  ConsumerState<AnalyticsOverviewTab> createState() =>
      _AnalyticsOverviewTabState();
}

class _AnalyticsOverviewTabState extends ConsumerState<AnalyticsOverviewTab> {
  TimePeriod _selectedPeriod = TimePeriod.week;

  List<Workout> get filteredWorkouts {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case TimePeriod.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        return widget.workouts
            .where((w) => (w.endTime ?? w.createdAt).isAfter(weekAgo))
            .toList();
      case TimePeriod.month:
        final monthAgo = now.subtract(const Duration(days: 30));
        return widget.workouts
            .where((w) => (w.endTime ?? w.createdAt).isAfter(monthAgo))
            .toList();
      case TimePeriod.year:
        final yearAgo = now.subtract(const Duration(days: 365));
        return widget.workouts
            .where((w) => (w.endTime ?? w.createdAt).isAfter(yearAgo))
            .toList();
      case TimePeriod.all:
        return widget.workouts;
    }
  }

  /// Compute period statistics from workouts
  ({int totalWorkouts, double totalVolume}) _computePeriodStats(
    List<Workout> workouts,
  ) {
    var totalVolume = 0.0;

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            final weight = set.weight ?? 0;
            final reps = set.reps ?? 0;
            totalVolume += weight * reps;
          }
        }
      }
    }

    return (totalWorkouts: workouts.length, totalVolume: totalVolume);
  }

  /// Show dialog to set weekly workout goal
  void _showWeeklyGoalDialog(BuildContext context, WidgetRef ref) {
    final currentGoal = ref.read(weeklyWorkoutGoalProvider);
    int selectedGoal = currentGoal;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final l10n = AppLocalizations.of(context);

            return AlertDialog(
              title: Text(l10n.weeklyGoalTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.weeklyGoalQuestion),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (index) {
                      final goal = index + 1;
                      final isSelected = goal == selectedGoal;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGoal = goal;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              '$goal',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(weeklyWorkoutGoalProvider.notifier).state =
                        selectedGoal;
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Compute stats locally from filtered workouts
    final stats = _computePeriodStats(filteredWorkouts);
    final weeklyGoal = ref.watch(weeklyWorkoutGoalProvider);
    final isPremium = ref.watch(isPremiumUserProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh will be handled by parent
        await Future.delayed(const Duration(seconds: 1));
      },
      child: CustomScrollView(
        slivers: [
          // Fixed Header with Period Selector and Hero Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  // Period Selector
                  _buildPeriodSelector(context),
                  const SizedBox(height: 20),

                  // Hero Card - Period Summary
                  HeroStatCard(
                    title: _getPeriodTitle(context, _selectedPeriod),
                    value: '${stats.totalWorkouts}',
                    subtitle: '${stats.totalVolume.round()} kg total volume',
                    icon: AppIcons.workout,
                    gradientColors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ],
                    onTap: () {
                      // Navigate to detailed view
                    },
                  ),
                  const SizedBox(height: 16),

                  // Weekly Dashboard with e1RM Tracker
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                AppIcons.dashboard,
                                color: theme.colorScheme.primary,
                                size: AppIconSize.medium,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.weeklyDashboard,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          WeeklyDashboardWidget(
                            activities: _convertWorkoutsToActivities(
                              widget.workouts,
                            ),
                            isPremium: isPremium, // Dynamic from user profile
                            onDataSync: (data) {
                              HapticFeedback.mediumImpact();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Minimal Stats Bar - Slides up when scrolling
          SliverPersistentHeader(
            pinned: false, // Slides up with scroll
            floating: true, // Reappears when scrolling up
            delegate: _MinimalStatsBarDelegate(
              stats: stats,
              workouts: widget.workouts,
              weeklyGoal: weeklyGoal,
              l10n: l10n,
              minHeight: 0, // Fully slides up
              maxHeight: 100, // ~100px height when visible
              onWeeklyGoalTap: () => _showWeeklyGoalDialog(context, ref),
            ),
          ),

          // Scrollable Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),

                // Pro Insights Section - Premium Analytics with blur/lock
                _buildProInsightsSection(context, isPremium, l10n, theme),
                const SizedBox(height: 20),

                // Recent Workouts Section
                _buildRecentWorkouts(context, filteredWorkouts),
                const SizedBox(height: 20),
                // Quick Actions
                _buildQuickActions(context),
                const TabBarBottomPadding(), // Bottom padding for tab bar overlay
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton(
            context,
            l10n.week,
            _selectedPeriod == TimePeriod.week,
            TimePeriod.week,
          ),
          _buildPeriodButton(
            context,
            l10n.month,
            _selectedPeriod == TimePeriod.month,
            TimePeriod.month,
          ),
          _buildPeriodButton(
            context,
            l10n.year,
            _selectedPeriod == TimePeriod.year,
            TimePeriod.year,
          ),
          _buildPeriodButton(
            context,
            l10n.all,
            _selectedPeriod == TimePeriod.all,
            TimePeriod.all,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(
    BuildContext context,
    String label,
    bool isSelected,
    TimePeriod period,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the Pro Insights section with premium analytics cards
  /// Shows blur/lock overlay for FREE users, full content for PREMIUM users
  Widget _buildProInsightsSection(
    BuildContext context,
    bool isPremium,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with PRO badge
        PremiumSectionHeader(
          title: l10n.proInsights,
          subtitle: l10n.advancedAnalytics,
          isPremium: isPremium,
          onSeeAllTap: isPremium
              ? () {
                  HapticFeedback.lightImpact();
                  // Navigate to full analytics dashboard when available
                }
              : null,
        ),

        // Premium Cards Grid
        Column(
          children: [
            // Card 1: Rep Range Analysis
            PremiumFeatureCard(
              title: l10n.repRangeAnalysis,
              description: l10n.repRangeDesc,
              icon: AppIcons.barChart,
              isUnlocked: isPremium,
              height: 200,
              onUpgradeTap: () {
                HapticFeedback.heavyImpact();
                _navigateToUpgrade(context);
              },
              child: _buildRepRangePreview(context, theme),
            ),
            const SizedBox(height: 12),

            // Card 2: Volume Progression
            PremiumFeatureCard(
              title: l10n.volumeProgression,
              description: l10n.volumeProgressionDesc,
              icon: AppIcons.trendUp,
              isUnlocked: isPremium,
              height: 180,
              onUpgradeTap: () {
                HapticFeedback.heavyImpact();
                _navigateToUpgrade(context);
              },
              child: _buildVolumeProgressionPreview(context, theme),
            ),
            const SizedBox(height: 12),

            // Card 3: Muscle Distribution
            PremiumFeatureCard(
              title: l10n.muscleDistribution,
              description: l10n.muscleDistributionDesc,
              icon: AppIcons.accessibility,
              isUnlocked: isPremium,
              height: 180,
              onUpgradeTap: () {
                HapticFeedback.heavyImpact();
                _navigateToUpgrade(context);
              },
              child: _buildMuscleDistributionPreview(context, theme),
            ),
          ],
        ),
      ],
    );
  }

  /// Preview content for Rep Range Analysis (visible when locked with blur)
  Widget _buildRepRangePreview(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildRepZoneBar(
            context,
            l10n.strengthGoal,
            '1-5',
            0.3,
            theme.colorScheme.error,
          ),
          _buildRepZoneBar(
            context,
            l10n.hypertrophyGoal,
            '8-12',
            0.5,
            theme.colorScheme.primary,
          ),
          _buildRepZoneBar(
            context,
            l10n.enduranceGoal,
            '15+',
            0.2,
            theme.colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildRepZoneBar(
    BuildContext context,
    String label,
    String reps,
    double percentage,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${(percentage * 100).round()}%',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 48,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 48,
              height: 60 * percentage,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          reps,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Preview content for Volume Progression
  Widget _buildVolumeProgressionPreview(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple line chart representation
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _SimpleLineChartPainter(
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week 1',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Week 4',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Preview content for Muscle Distribution
  Widget _buildMuscleDistributionPreview(
    BuildContext context,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMuscleChip('Chest', 0.25, theme),
          _buildMuscleChip('Back', 0.30, theme),
          _buildMuscleChip('Legs', 0.20, theme),
          _buildMuscleChip('Arms', 0.15, theme),
          _buildMuscleChip('Core', 0.10, theme),
        ],
      ),
    );
  }

  Widget _buildMuscleChip(String label, double percentage, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(
              alpha: percentage + 0.2,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${(percentage * 100).round()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
      ],
    );
  }

  void _navigateToUpgrade(BuildContext context) {
    // Navigate to premium upgrade screen
    Navigator.pushNamed(context, '/premium');
  }

  Widget _buildRecentWorkouts(BuildContext context, List<Workout> workouts) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final recent = workouts.take(3).toList();

    if (recent.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                SemanticIcon(
                  icon: AppIcons.workout,
                  semanticLabel: l10n.workout,
                  size: AppIconSize.xxlarge,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.noRecentWorkouts,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noRecentWorkoutsDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                  l10n.recentWorkouts,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showAllWorkouts(context);
                  },
                  child: Text(l10n.seeAll),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recent.map((workout) => _buildWorkoutItem(context, workout)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutItem(BuildContext context, Workout workout) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final timeAgo = _getTimeAgo(context, workout.endTime ?? workout.createdAt);
    final volume = workout.exercises.fold(0.0, (sum, e) => sum + e.totalVolume);
    final workoutName = workout.name;

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showWorkoutDetail(context, workout);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workoutName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${workout.exercises.length} ${l10n.exercises} • $timeAgo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${volume.toStringAsFixed(0)} kg',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              SemanticIcon(
                icon: AppIcons.chevronRight,
                semanticLabel: l10n.viewDetails,
                size: AppIconSize.small,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkoutDetail(BuildContext context, Workout workout) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.95);
    ModalService.showSheet(context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: safeMax,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SemanticIcon(
                        icon: AppIcons.workout,
                        semanticLabel: l10n.workout,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'dd MMMM yyyy - HH:mm',
                            ).format(workout.endTime ?? workout.createdAt),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: SemanticIcon(
                        icon: AppIcons.close,
                        semanticLabel: l10n.close,
                      ),
                    ),
                  ],
                ),
              ),
              // Stats summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildStatChip(
                      context,
                      AppIcons.workout,
                      '${workout.exercises.length}',
                      l10n.exercises,
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      context,
                      AppIcons.scale,
                      '${workout.exercises.fold(0.0, (sum, e) => sum + e.totalVolume).toStringAsFixed(0)} kg',
                      l10n.volumeLabel,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              // Exercise list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: workout.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = workout.exercises[index];
                    return _buildExerciseDetailCard(
                      context,
                      exercise,
                      index + 1,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.small, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseDetailCard(
    BuildContext context,
    Exercise exercise,
    int order,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$order',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exercise.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                l10n.setsCount(exercise.sets.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Sets table header
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  l10n.sets,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  l10n.weightLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  l10n.repsLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  'RPE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Sets rows
          ...exercise.sets.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final set = entry.value;
            // Display as warmup if RPE is 0 or if isWarmup is true
            final isWarmupSet =
                set.isWarmup || (set.rpe != null && set.rpe == 0);

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isWarmupSet
                    ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                    : theme.colorScheme.surface.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isWarmupSet
                            ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                            : theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isWarmupSet ? 'W' : '${setIndex + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isWarmupSet
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      set.weight != null
                          ? '${set.weight!.toStringAsFixed(1)} kg'
                          : '-',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      set.actualReps?.toString() ?? set.reps?.toString() ?? '-',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: isWarmupSet
                        ? Text(
                            l10n.warmup,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : set.rpe != null
                        ? _buildRpeIndicator(context, set.rpe!)
                        : Text(
                            '-',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRpeIndicator(BuildContext context, int rpe) {
    final theme = Theme.of(context);
    final color = rpe <= 5
        ? theme.colorScheme.primary.withValues(alpha: 0.7)
        : rpe <= 7
        ? theme.colorScheme.secondary
        : rpe <= 8
        ? theme.colorScheme.tertiary
        : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$rpe',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/workout');
            },
            icon: SemanticIcon(icon: AppIcons.add, semanticLabel: l10n.add),
            label: Text(l10n.startWorkout),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to detailed stats
            },
            icon: SemanticIcon(
              icon: AppIcons.barChart,
              semanticLabel: l10n.viewStats,
            ),
            label: Text(l10n.viewStats),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAllWorkouts(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (kDebugMode) {
      debugPrint('🔍 [Analytics] _showAllWorkouts called');
    }
    if (kDebugMode) {
      debugPrint(
        '📊 [Analytics] Total workouts to process: ${widget.workouts.length}',
      );
    }

    // TEMPORARY FIX: Don't filter by isCompleted since all sets from Firebase have isCompleted=false
    // after the Model→Domain conversion. We'll filter based on having exercises and sets only.
    final validWorkouts = widget.workouts.where((w) {
      final hasValidExercises = w.exercises.any((e) => e.sets.isNotEmpty);
      if (!hasValidExercises) {
        if (kDebugMode) {
          debugPrint(
            '  ⚠️ [Analytics] Skipping workout "${w.name}" - no exercises with sets',
          );
        }
      }
      return hasValidExercises;
    }).toList();

    if (kDebugMode) {
      debugPrint(
        '📋 [Analytics] Valid workouts after filtering: ${validWorkouts.length}/${widget.workouts.length}',
      );
    }

    // Log detailed workout information (only for valid workouts)
    for (var i = 0; i < validWorkouts.length.clamp(0, 5); i++) {
      // Log first 5 workouts max
      final workout = validWorkouts[i];
      if (kDebugMode) {
        debugPrint('  📋 [Analytics] Workout $i: "${workout.name}"');
      }
      if (kDebugMode) {
        debugPrint('     - Status: ${workout.status}');
      }
      if (kDebugMode) {
        debugPrint('     - Exercises: ${workout.exercises.length}');
      }

      for (var j = 0; j < workout.exercises.length; j++) {
        final exercise = workout.exercises[j];
        if (kDebugMode) {
          debugPrint('       💪 [Analytics] Exercise $j: "${exercise.name}"');
        }
        if (kDebugMode) {
          debugPrint('          - Total sets: ${exercise.sets.length}');
        }
        if (kDebugMode) {
          debugPrint(
            '          - Exercise isCompleted: ${exercise.isCompleted}',
          );
        }

        if (exercise.sets.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '          ⚠️ [Analytics] WARNING: Exercise has NO sets!',
            );
          }
          continue;
        }

        for (var k = 0; k < exercise.sets.length; k++) {
          final set = exercise.sets[k];
          if (kDebugMode) {
            debugPrint(
              '          ✓ [Analytics] Set ${k + 1}: weight=${set.weight}, reps=${set.reps}, isCompleted=${set.isCompleted}',
            );
          }
        }

        final completedSets = exercise.sets.where((s) => s.isCompleted).length;
        if (kDebugMode) {
          debugPrint(
            '          - Completed sets: $completedSets/${exercise.sets.length}',
          );
        }
        if (kDebugMode) {
          debugPrint(
            '          - Has any completed set: ${exercise.sets.any((s) => s.isCompleted)}',
          );
        }
      }
    }

    if (validWorkouts.length > 5) {
      if (kDebugMode) {
        debugPrint(
          '  ... (${validWorkouts.length - 5} more workouts not logged)',
        );
      }
    }

    // If no valid workouts, show error message
    if (validWorkouts.isEmpty) {
      if (kDebugMode) {
        debugPrint('❌ [Analytics] ERROR: No valid workouts found!');
      }
      if (kDebugMode) {
        debugPrint('   All ${widget.workouts.length} workouts have either:');
      }
      if (kDebugMode) {
        debugPrint('   - Empty exercises array');
      }
      if (kDebugMode) {
        debugPrint('   - Exercises with empty sets array');
      }
      if (kDebugMode) {
        debugPrint('   - Exercises with no completed sets');
      }

      SnackBarService.showError(context, l10n.errorLoadingData);
      return;
    }

    final syntheticActivities = validWorkouts.expand((w) {
      if (kDebugMode) {
        debugPrint('🔄 [Analytics] Processing workout: "${w.name}"');
      }

      final filteredExercises = w.exercises.where((e) {
        // Extra safety check: ensure sets array is not empty
        if (e.sets.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '  ⚠️ [Analytics] Exercise "${e.name}" has EMPTY sets array - skipping',
            );
          }
          return false;
        }

        final hasCompletedSets = e.sets.any((s) => s.isCompleted);
        if (kDebugMode) {
          debugPrint(
            '  🔎 [Analytics] Exercise "${e.name}": hasCompletedSets=$hasCompletedSets (${e.sets.length} sets)',
          );
        }
        return hasCompletedSets;
      }).toList();

      if (kDebugMode) {
        debugPrint(
          '  ✅ [Analytics] Filtered exercises for "${w.name}": ${filteredExercises.length}/${w.exercises.length}',
        );
      }

      return filteredExercises.map((e) {
        if (kDebugMode) {
          debugPrint(
            '  🏗️ [Analytics] Creating ExerciseActivity for "${e.name}"',
          );
        }
        final activity = ExerciseActivity.fromExercise(
          exercise: e,
          userEmail: '',
          workoutName: w.name,
          workoutDate: w.endTime,
        );
        if (kDebugMode) {
          debugPrint('     - Activity sets: ${activity.sets.length}');
        }
        return activity;
      });
    }).toList();

    if (kDebugMode) {
      debugPrint(
        '🎯 [Analytics] Total synthetic activities created: ${syntheticActivities.length}',
      );
    }
    if (kDebugMode) {
      debugPrint('');
    }

    // Safety check before showing modal
    if (syntheticActivities.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '❌ [Analytics] ERROR: syntheticActivities is EMPTY after processing!',
        );
      }
      SnackBarService.showError(context, l10n.errorLoadingData);
      return;
    }

    ModalService.showSheet(context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _AllActivitiesModal(
        activities: syntheticActivities,
        exerciseRepository: ref.read(exerciseRepositoryProvider),
      ),
    );
  }

  String _getPeriodTitle(BuildContext context, TimePeriod period) {
    final l10n = AppLocalizations.of(context);
    switch (period) {
      case TimePeriod.week:
        return l10n.thisWeek;
      case TimePeriod.month:
        return l10n.thisMonthProgress;
      case TimePeriod.year:
        return l10n.thisYearProgress;
      case TimePeriod.all:
        return l10n.allTimeProgress;
    }
  }

  String _getTimeAgo(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return l10n.daysAgo(diff.inDays);
    } else if (diff.inHours > 0) {
      return l10n.hoursAgo(diff.inHours);
    } else if (diff.inMinutes > 0) {
      return l10n.minutesAgo(diff.inMinutes);
    }
    return l10n.justNow;
  }

  /// Converts workouts to exercise activities for WeeklyDashboardWidget
  List<ExerciseActivity> _convertWorkoutsToActivities(List<Workout> workouts) {
    final activities = <ExerciseActivity>[];

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        // Only convert exercises with completed sets
        if (exercise.sets.any((set) => set.isCompleted)) {
          final activity = ExerciseActivity.fromExercise(
            exercise: exercise,
            userEmail: '', // Not needed for analytics
            workoutName: workout.name,
            workoutDate: workout.createdAt,
          );
          activities.add(activity);
        }
      }
    }

    return activities;
  }
}

// Enhanced modal with muscle group filters
class _AllActivitiesModal extends StatefulWidget {
  const _AllActivitiesModal({
    required this.activities,
    required this.exerciseRepository,
  });
  final List<ExerciseActivity> activities;
  final ExerciseRepository exerciseRepository;

  @override
  State<_AllActivitiesModal> createState() => _AllActivitiesModalState();
}

class _AllActivitiesModalState extends State<_AllActivitiesModal> {
  Set<String> selectedMuscleGroups = {};
  Map<String, List<String>> exerciseMuscleGroups = {};
  Map<String, MuscleGroupStats> muscleGroupStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExerciseData();
  }

  Future<void> _loadExerciseData() async {
    try {
      // Load exercise data to get muscle groups
      for (final activity in widget.activities) {
        final exercise = await widget.exerciseRepository.getExerciseById(
          activity.exerciseId,
        );
        if (exercise != null) {
          exerciseMuscleGroups[activity.id] = exercise.muscleGroups;

          // Calculate stats for each muscle group
          for (final muscleGroup in exercise.muscleGroups) {
            final stats = muscleGroupStats[muscleGroup] ?? MuscleGroupStats();
            stats.workoutCount++;
            stats.totalSets += activity.sets.length;
            stats.totalVolume += _calculateExerciseVolume(activity);
            stats.exercises.add(activity.exerciseName);
            muscleGroupStats[muscleGroup] = stats;
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading exercise data: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  List<ExerciseActivity> get filteredActivities {
    if (selectedMuscleGroups.isEmpty) {
      return widget.activities;
    }

    return widget.activities.where((activity) {
      final muscleGroups = exerciseMuscleGroups[activity.id] ?? [];
      return muscleGroups.any((group) => selectedMuscleGroups.contains(group));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.95);
    return DraggableScrollableSheet(
      initialChildSize: safeMax.clamp(0.0, 0.9),
      minChildSize: 0.5,
      maxChildSize: safeMax,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.allActivitiesCount(filteredActivities.length),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: SemanticIcon(
                        icon: AppIcons.close,
                        semanticLabel: l10n.close,
                      ),
                    ),
                  ],
                ),
              ),

              // Muscle Group Filters
              if (!isLoading && muscleGroupStats.isNotEmpty) ...[
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip(
                        l10n.all,
                        selectedMuscleGroups.isEmpty,
                        () {
                          setState(() {
                            selectedMuscleGroups.clear();
                          });
                        },
                        theme,
                      ),
                      const SizedBox(width: 8),
                      ...muscleGroupStats.keys.map(
                        (group) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            _getMuscleGroupName(group),
                            selectedMuscleGroups.contains(group),
                            () {
                              setState(() {
                                if (selectedMuscleGroups.contains(group)) {
                                  selectedMuscleGroups.remove(group);
                                } else {
                                  selectedMuscleGroups.add(group);
                                }
                              });
                            },
                            theme,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Expandable Muscle Group Stats
              if (!isLoading && selectedMuscleGroups.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ExpansionTile(
                    title: Text(
                      l10n.muscleGroupStatistics,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    initiallyExpanded: false,
                    children: selectedMuscleGroups.map((group) {
                      final stats = muscleGroupStats[group]!;
                      return _buildMuscleGroupStatCard(group, stats, theme);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              const Divider(height: 1),

              // Activities list
              Expanded(
                child: isLoading
                    ? const Center(child: LoadingIndicator())
                    : filteredActivities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SemanticIcon(
                              icon: AppIcons.workout,
                              semanticLabel: l10n.workout,
                              size: AppIconSize.xxlarge,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              selectedMuscleGroups.isEmpty
                                  ? l10n.noActivitiesInPeriod
                                  : l10n.noActivitiesForSelectedMuscleGroups,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredActivities.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final activity = filteredActivities[index];
                          final muscleGroups =
                              exerciseMuscleGroups[activity.id] ?? [];
                          return _buildDetailedActivityCard(
                            context,
                            activity,
                            muscleGroups,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildMuscleGroupStatCard(
    String group,
    MuscleGroupStats stats,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getMuscleGroupName(group),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.workoutsCount(stats.workoutCount, 4),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildStatChip(
                  AppIcons.workout,
                  l10n.exercisesCount(stats.exercises.length),
                  theme,
                ),
                _buildStatChip(
                  AppIcons.formatListNumbered,
                  l10n.setsCount(stats.totalSets),
                  theme,
                ),
                _buildStatChip(
                  AppIcons.weight,
                  '${stats.totalVolume.toStringAsFixed(0)} kg',
                  theme,
                ),
              ],
            ),
            if (stats.exercises.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.exercises}: ${stats.exercises.take(3).join(', ')}${stats.exercises.length > 3 ? '...' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedActivityCard(
    BuildContext context,
    ExerciseActivity activity,
    List<String> muscleGroups,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final volume = _calculateExerciseVolume(activity);
    final dateStr = DateFormat(
      'MMM d, yyyy • h:mm a',
    ).format(activity.createdAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: theme.colorScheme.surface.withValues(alpha: 0),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          leading: Icon(AppIcons.workout, color: theme.colorScheme.primary),
          title: Text(
            activity.exerciseName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              if (muscleGroups.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: muscleGroups
                      .map(
                        (group) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getMuscleGroupName(group),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${volume.toStringAsFixed(0)} kg',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: theme.colorScheme.outlineVariant),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).setsDetails,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                ...activity.sets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;
                  final weight = double.tryParse(set.weight) ?? 0;
                  final reps = int.tryParse(set.reps) ?? 0;
                  final setVolume = weight * reps;
                  final rpe = set.effort;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
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
                                Row(
                                  children: [
                                    SemanticIcon(
                                      icon: AppIcons.workout,
                                      semanticLabel: l10n.weightLabel,
                                      size: AppIconSize.tiny,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    SemanticIcon(
                                      icon: AppIcons.repeat,
                                      semanticLabel: l10n.repsLabel,
                                      size: AppIconSize.tiny,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      ).repsCount(reps),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      ).volumeWithValue(
                                        setVolume.toStringAsFixed(0),
                                      ),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    ...[
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .secondaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SemanticIcon(
                                              icon: AppIcons.speed,
                                              semanticLabel: l10n.effort,
                                              size: AppIconSize.medium,
                                              color: theme
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              ).rpeWithValue(rpe.toString()),
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSecondaryContainer,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        AppIcons.formatListNumbered,
                        AppLocalizations.of(
                          context,
                        ).setsCount(activity.sets.length),
                        theme,
                      ),
                      _buildSummaryItem(
                        AppIcons.workout,
                        AppLocalizations.of(
                          context,
                        ).kgMax(_getMaxWeight(activity).toStringAsFixed(0)),
                        theme,
                      ),
                      _buildSummaryItem(
                        AppIcons.repeat,
                        AppLocalizations.of(
                          context,
                        ).repsCount(_getTotalReps(activity)),
                        theme,
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

  Widget _buildSummaryItem(IconData icon, String label, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppIconSize.small, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppIconSize.tiny,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateExerciseVolume(ExerciseActivity activity) {
    double total = 0;
    for (final set in activity.sets) {
      final weight = double.tryParse(set.weight) ?? 0;
      final reps = int.tryParse(set.reps) ?? 0;
      total += weight * reps;
    }
    return total;
  }

  double _getMaxWeight(ExerciseActivity activity) {
    double maxWeight = 0;
    for (final set in activity.sets) {
      final weight = double.tryParse(set.weight) ?? 0;
      if (weight > maxWeight) maxWeight = weight;
    }
    return maxWeight;
  }

  int _getTotalReps(ExerciseActivity activity) {
    int totalReps = 0;
    for (final set in activity.sets) {
      totalReps += int.tryParse(set.reps) ?? 0;
    }
    return totalReps;
  }

  /// Get display name for muscle code using centralized mapper
  ///
  /// Uses [MuscleAbbreviationMapper] as SINGLE SOURCE OF TRUTH.
  String _getMuscleGroupName(String code) {
    return MuscleAbbreviationMapper.getMuscleInfo(code)?.displayNameEn ?? code;
  }
}

// Stats class for muscle groups
class MuscleGroupStats {
  int workoutCount = 0;
  int totalSets = 0;
  double totalVolume = 0;
  Set<String> exercises = {};
}

// Delegate for minimal stats bar with slide-up animation
class _MinimalStatsBarDelegate extends SliverPersistentHeaderDelegate {
  _MinimalStatsBarDelegate({
    required this.stats,
    required this.workouts,
    required this.weeklyGoal,
    required this.l10n,
    required this.minHeight,
    required this.maxHeight,
    required this.onWeeklyGoalTap,
  });

  final dynamic stats;
  final List<Workout> workouts;
  final int weeklyGoal;
  final AppLocalizations l10n;
  final double minHeight;
  final double maxHeight;
  final VoidCallback onWeeklyGoalTap;

  /// Calculate workouts in the last 7 days
  int _calculateWeeklyWorkouts() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weeklyDates = <DateTime>{};
    for (final workout in workouts) {
      final workoutDate = workout.endTime ?? workout.createdAt;
      if (workoutDate.isAfter(weekAgo)) {
        final dateOnly = DateTime(
          workoutDate.year,
          workoutDate.month,
          workoutDate.day,
        );
        weeklyDates.add(dateOnly);
      }
    }

    return weeklyDates.length;
  }

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final progress = (shrinkOffset / maxExtent).clamp(0.0, 1.0);
    final opacity = 1.0 - progress;

    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: shrinkOffset > 0
              ? [
                  BoxShadow(
                    color: context.colors.onSurface.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Streak
            Expanded(
              child: _buildMinimalStat(
                context,
                AppIcons.streak,
                '${stats.currentStreak}',
                l10n.dayStreakLabel,
                theme.colorScheme.error,
              ),
            ),
            // Volume
            Expanded(
              child: _buildMinimalStat(
                context,
                AppIcons.workout,
                _formatVolumeShort(stats.totalVolume),
                l10n.totalVolume,
                theme.colorScheme.secondary,
              ),
            ),
            // Weekly Workouts (tappable to set goal)
            Expanded(
              child: _buildMinimalStat(
                context,
                AppIcons.calendar,
                '${_calculateWeeklyWorkouts()}/$weeklyGoal',
                l10n.weekly,
                theme.colorScheme.primary,
                onTap: onWeeklyGoalTap,
              ),
            ),
            // Consistency
            Expanded(
              child: _buildMinimalStat(
                context,
                AppIcons.insights,
                '${stats.consistency}%',
                l10n.consistency,
                theme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppIconSize.small, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }

  String _formatVolumeShort(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k';
    }
    return volume.round().toString();
  }

  @override
  bool shouldRebuild(_MinimalStatsBarDelegate oldDelegate) {
    return stats != oldDelegate.stats ||
        workouts != oldDelegate.workouts ||
        weeklyGoal != oldDelegate.weeklyGoal;
  }
}

/// Simple line chart painter for volume progression preview
/// Shows an upward-trending line to visualize progress concept
class _SimpleLineChartPainter extends CustomPainter {
  _SimpleLineChartPainter({required this.color, required this.backgroundColor});

  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 1;

    // Draw subtle horizontal grid lines
    for (var i = 0; i < 4; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Create upward-trending sample data points
    final points = <Offset>[
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.65),
      Offset(size.width * 0.3, size.height * 0.55),
      Offset(size.width * 0.45, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.35),
      Offset(size.width * 0.9, size.height * 0.25),
      Offset(size.width, size.height * 0.2),
    ];

    // Draw the line path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      // Use quadratic bezier for smooth curves
      final prev = points[i - 1];
      final curr = points[i];
      final controlX = (prev.dx + curr.dx) / 2;
      path.quadraticBezierTo(controlX, prev.dy, controlX, curr.dy);
      path.lineTo(curr.dx, curr.dy);
    }

    canvas.drawPath(path, paint);

    // Draw gradient fill under the line
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);

    // Draw data points
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_SimpleLineChartPainter oldDelegate) {
    return color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
