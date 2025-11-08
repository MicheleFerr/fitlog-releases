import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/horizontal_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_volume_classifier.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/weekly_dashboard_widget.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/utils/muscle_group_mapper.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/enhanced_workout_heatmap.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/lazy_chart_wrapper.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class AnalyticsInsightsTab extends ConsumerStatefulWidget {

  const AnalyticsInsightsTab({
    super.key,
    required this.workouts,
    required this.isPremium,
  });
  final List<Workout> workouts;
  final bool isPremium;

  @override
  ConsumerState<AnalyticsInsightsTab> createState() => _AnalyticsInsightsTabState();
}

class _AnalyticsInsightsTabState extends ConsumerState<AnalyticsInsightsTab> {
  String? _selectedType;
  String? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (!widget.isPremium) {
      return _buildPremiumLockScreen(context, theme, l10n);
    }
    
    // Show admin badge if user is admin
    final isAdminMode = widget.isPremium && widget.workouts.isNotEmpty;
    
    return Stack(
      children: [
        ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Weekly Dashboard
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
                      size: 24,
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
                  activities: _convertWorkoutsToActivities(widget.workouts),
                  isPremium: widget.isPremium,
                  onDataSync: (data) {
                    HapticFeedback.mediumImpact();
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Muscle Balance Analysis
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.balance,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.muscleGroupBalance,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LazyMuscleChartWrapper(
                  delayMs: 300,
                  child: HorizontalMuscleBalanceChart(
                    muscleData: _generateMuscleData(widget.workouts),
                    onMuscleGroupTap: (muscle) {
                      HapticFeedback.lightImpact();
                      _showMuscleDetailsBottomSheet(context, muscle);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Workout Consistency Heatmap
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.calendarViewMonth,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.consistencyHeatmap,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LazyChartWrapper(
                  skeletonHeight: 250,
                  showLegend: false,
                  delayMs: 400,
                  child: EnhancedWorkoutHeatmap(
                    workoutData: _generateWorkoutData(widget.workouts),
                    weeksToShow: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Training Recommendations
        _buildTrainingRecommendations(context, l10n, widget.workouts),
        
        const SizedBox(height: 100), // Space for bottom navigation
      ],
    ),
        // Admin indicator
        if (isAdminMode)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.admin,
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.adminMode,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildPremiumLockScreen(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.lock,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.premiumInsights,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.unlockAdvancedAnalytics,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Feature list
            _buildFeatureItem(
              context,
              AppIcons.dashboard,
              l10n.weeklyPerformanceDashboard,
              theme,
            ),
            _buildFeatureItem(
              context,
              AppIcons.balance,
              l10n.muscleGroupBalanceAnalysis,
              theme,
            ),
            _buildFeatureItem(
              context,
              AppIcons.calendarMonth,
              l10n.workoutConsistencyTracking,
              theme,
            ),
            _buildFeatureItem(
              context,
              AppIcons.ai,
              l10n.personalizedRecommendations,
              theme,
            ),
            SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/premium'),
              icon: const Icon(AppIcons.star),
              label: Text(l10n.unlockPremium),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(BuildContext context, IconData icon, String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrainingRecommendations(BuildContext context, AppLocalizations l10n, List<Workout> workouts) {
    final theme = Theme.of(context);
    final allRecommendations = _generateRecommendations(workouts);

    // Apply filters
    final filteredRecommendations = allRecommendations.where((rec) {
      final typeMatch = _selectedType == null || rec['type'] == _selectedType;
      final priorityMatch = _selectedPriority == null || rec['priority'] == _selectedPriority;
      return typeMatch && priorityMatch;
    }).toList();

    final hasActiveFilters = _selectedType != null || _selectedPriority != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.ai,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.filterRecommendations,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (hasActiveFilters)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedType = null;
                        _selectedPriority = null;
                      });
                      HapticFeedback.lightImpact();
                    },
                    icon: const Icon(AppIcons.clearAll, size: 18),
                    label: Text(l10n.clearFilters),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Filter chips
            _buildFilterChips(context, l10n, theme),
            const SizedBox(height: 16),

            // Recommendations list
            if (filteredRecommendations.isEmpty && hasActiveFilters)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        AppIcons.filterAltOff,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noRecommendationsFound,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filteredRecommendations.map((rec) => _buildRecommendationItem(
                context,
                rec['type'] as String,
                rec['message'] as String,
                rec['priority'] as String,
                rec['reason'],
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type filter
        Text(
          l10n.filterByType,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text(l10n.all),
              selected: _selectedType == null,
              onSelected: (selected) {
                setState(() => _selectedType = null);
                HapticFeedback.selectionClick();
              },
            ),
            FilterChip(
              label: Text(l10n.warning),
              selected: _selectedType == 'warning',
              onSelected: (selected) {
                setState(() => _selectedType = selected ? 'warning' : null);
                HapticFeedback.selectionClick();
              },
            ),
            FilterChip(
              label: Text(l10n.success),
              selected: _selectedType == 'success',
              onSelected: (selected) {
                setState(() => _selectedType = selected ? 'success' : null);
                HapticFeedback.selectionClick();
              },
            ),
            FilterChip(
              label: Text(l10n.info),
              selected: _selectedType == 'info',
              onSelected: (selected) {
                setState(() => _selectedType = selected ? 'info' : null);
                HapticFeedback.selectionClick();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Priority filter
        Text(
          l10n.filterByPriority,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text(l10n.all),
              selected: _selectedPriority == null,
              onSelected: (selected) {
                setState(() => _selectedPriority = null);
                HapticFeedback.selectionClick();
              },
            ),
            FilterChip(
              label: Text(l10n.high),
              selected: _selectedPriority == 'high',
              onSelected: (selected) {
                setState(() => _selectedPriority = selected ? 'high' : null);
                HapticFeedback.selectionClick();
              },
            ),
            FilterChip(
              label: Text(l10n.medium),
              selected: _selectedPriority == 'medium',
              onSelected: (selected) {
                setState(() => _selectedPriority = selected ? 'medium' : null);
                HapticFeedback.selectionClick();
              },
            ),
            FilterChip(
              label: Text(l10n.low),
              selected: _selectedPriority == 'low',
              onSelected: (selected) {
                setState(() => _selectedPriority = selected ? 'low' : null);
                HapticFeedback.selectionClick();
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildRecommendationItem(
    BuildContext context,
    String type,
    String message,
    String priority,
    String? reason,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final icon = type == 'warning' ? AppIcons.warningAmberRounded
                : type == 'success' ? AppIcons.completeOutline
                : AppIcons.infoOutline;

    final color = type == 'warning' ? Colors.orange
                 : type == 'success' ? Colors.green
                 : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: reason != null
          ? () {
              HapticFeedback.lightImpact();
              _showRecommendationDetails(context, message, reason, color);
            }
          : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (priority == 'high')
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.highPriority,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (reason != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.experiment,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.tapForScientificExplanation,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (reason != null)
                Icon(
                  AppIcons.chevronRight,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecommendationDetails(
    BuildContext context,
    String title,
    String reason,
    Color color,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(AppIcons.science, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.scientificBasis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                reason,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  void _showMuscleDetailsBottomSheet(BuildContext context, MuscleGroup muscle) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final muscleData = _generateMuscleData(widget.workouts);
    final data = muscleData[muscle];

    if (data == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                _getMuscleDisplayName(muscle),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Stats
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatChip(
                    theme,
                    l10n.total,
                    '${(data.totalVolume / 1000).toStringAsFixed(1)}k kg',
                    AppIcons.workout,
                  ),
                  _buildStatChip(
                    theme,
                    l10n.primary,
                    '${(data.primaryVolume / 1000).toStringAsFixed(1)}k kg',
                    AppIcons.star,
                    color: theme.colorScheme.primary,
                  ),
                  _buildStatChip(
                    theme,
                    l10n.secondary,
                    '${(data.secondaryVolume / 1000).toStringAsFixed(1)}k kg',
                    AppIcons.starHalfIcon,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  _buildStatChip(
                    theme,
                    l10n.target,
                    '${data.targetStrength.toStringAsFixed(0)}%',
                    AppIcons.flag,
                    color: theme.colorScheme.tertiary,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Exercise breakdown
              Text(
                l10n.exerciseBreakdown,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: data.exerciseBreakdown.entries
                    .map((e) => _buildExerciseItem(
                      theme,
                      e.key,
                      e.value,
                      data.totalVolume,
                    ))
                    .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final chipColor = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: theme.textTheme.labelMedium?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(ThemeData theme, String name, double volume, double totalVolume) {
    final percentage = (volume / totalVolume * 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            '${(volume / 1000).toStringAsFixed(1)}k kg',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getMuscleDisplayName(MuscleGroup muscle) {
    final l10n = AppLocalizations.of(context);
    switch (muscle) {
      case MuscleGroup.chest:
        return l10n.pectorals;
      case MuscleGroup.back:
        return l10n.back;
      case MuscleGroup.shoulders:
        return l10n.deltoids;
      case MuscleGroup.arms:
        return l10n.arms;
      case MuscleGroup.legs:
        return l10n.legs;
      case MuscleGroup.core:
        return l10n.core;
    }
  }

  /// Converts workouts to exercise activities for widgets that still use the old format
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

  Map<MuscleGroup, MuscleStrengthData> _generateMuscleData(List<Workout> workouts) {
    // Collect all exercises from workouts
    final allExercises = <Exercise>[];
    final exerciseBreakdown = <MuscleGroup, Map<String, double>>{};

    for (final workout in workouts) {
      allExercises.addAll(workout.exercises);

      // Build exercise breakdown for display
      for (final exercise in workout.exercises) {
        final muscle = MuscleGroupMapper.fromExerciseCategory(exercise.category);
        if (muscle == null) continue; // Skip cardio/other exercises
        final volume = _calculateVolumeFromExercise(exercise);

        exerciseBreakdown[muscle] ??= {};
        exerciseBreakdown[muscle]![exercise.name] =
            (exerciseBreakdown[muscle]![exercise.name] ?? 0) + volume;
      }
    }

    // Use classifier to calculate primary/secondary distribution
    final volumeDistribution = MuscleVolumeClassifier.calculateVolumeDistribution(allExercises);

    // Calculate total weighted volume for percentages
    final totalWeightedVolume = volumeDistribution.values
      .fold<double>(0, (sum, dist) => sum + dist.totalWeightedVolume);

    // Build muscle data with primary/secondary info
    return Map.fromEntries(
      volumeDistribution.entries.map((entry) {
        final muscle = entry.key;
        final distribution = entry.value;
        final percentage = totalWeightedVolume > 0
          ? (distribution.totalWeightedVolume / totalWeightedVolume * 100)
          : 0;

        return MapEntry(
          muscle,
          MuscleStrengthData(
            currentStrength: percentage.toDouble(),
            targetStrength: 16.7, // Optimal balance ~17% per group
            totalVolume: distribution.totalWeightedVolume,
            exerciseBreakdown: exerciseBreakdown[muscle] ?? {},
            primaryVolume: distribution.primaryVolume,
            secondaryVolume: distribution.secondaryVolume,
          ),
        );
      }),
    );
  }
  
  Map<DateTime, WorkoutDayData> _generateWorkoutData(List<Workout> workouts) {
    final data = <DateTime, List<ExerciseData>>{};

    for (final workout in workouts) {
      final date = DateTime(
        workout.createdAt.year,
        workout.createdAt.month,
        workout.createdAt.day,
      );

      data[date] ??= [];

      for (final exercise in workout.exercises) {
        final exerciseData = ExerciseData(
          name: exercise.name,
          sets: exercise.sets.map((set) => SetData(
            reps: set.actualReps ?? set.reps ?? 0,
            weight: set.weight ?? 0,
          )).toList(),
        );

        data[date]!.add(exerciseData);
      }
    }

    return data.map((date, exercises) => MapEntry(
      date,
      WorkoutDayData(
        exercises: exercises,
        totalMinutes: exercises.length * 5, // Estimate 5 minutes per exercise
      ),
    ));
  }
  
  List<Map<String, String>> _generateRecommendations(List<Workout> workouts) {
    final recommendations = <Map<String, String>>[];

    if (workouts.isEmpty) {
      recommendations.add({
        'type': 'info',
        'message': 'Start your fitness journey! Complete your first workout to get personalized insights',
        'priority': 'high',
        'reason': 'No workout data available',
      });
      return recommendations;
    }

    final now = DateTime.now();
    final lastWorkout = workouts.isNotEmpty
      ? workouts.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b).createdAt
      : null;

    final daysSinceLastWorkout = lastWorkout != null
      ? now.difference(lastWorkout).inDays
      : 999;

    // Check workout frequency in last 30 days
    final daysWithWorkout = _countWorkoutDays(workouts);
    final avgWorkoutsPerWeek = (daysWithWorkout / 30 * 7).round();

    // SMART LOGIC: Avoid contradictions

    // 1. If resting too long (>3 days) → suggest getting back to training
    if (daysSinceLastWorkout > 3) {
      recommendations.add({
        'type': 'warning',
        'message': 'It\'s been $daysSinceLastWorkout days since your last workout. Time to get back on track!',
        'priority': 'high',
        'reason': 'Last workout was ${daysSinceLastWorkout}d ago. Optimal rest is 1-2 days between sessions.',
      });
    }
    // 2. If training consistently (3+ workouts/week and last workout <3 days ago)
    else if (avgWorkoutsPerWeek >= 3 && daysSinceLastWorkout <= 3) {
      recommendations.add({
        'type': 'success',
        'message': 'Great consistency! You\'re averaging $avgWorkoutsPerWeek workouts per week',
        'priority': 'low',
        'reason': '$daysWithWorkout workout days in last 30 days. Research shows 3-5x/week is optimal.',
      });
    }
    // 3. If training too infrequently
    else if (avgWorkoutsPerWeek < 3) {
      recommendations.add({
        'type': 'warning',
        'message': 'Increase workout frequency to 3-5 times per week for optimal results',
        'priority': 'high',
        'reason': 'Currently averaging $avgWorkoutsPerWeek workouts/week. Studies show 3-5x/week maximizes hypertrophy.',
      });
    }

    // 4. Check if overtraining (7+ days/week AND last workout was today/yesterday)
    if (daysWithWorkout >= 21 && daysSinceLastWorkout <= 1) {
      recommendations.add({
        'type': 'warning',
        'message': 'You\'re training very frequently ($daysWithWorkout days/month). Don\'t forget rest days for recovery!',
        'priority': 'high',
        'reason': 'Training $daysWithWorkout days in 30 days. Recovery is crucial for muscle growth and injury prevention.',
      });
    }

    // Check muscle balance
    final muscleData = _generateMuscleData(workouts);
    final imbalanced = muscleData.entries.where((e) =>
      (e.value.currentStrength - e.value.targetStrength).abs() > 5).toList();

    if (imbalanced.isNotEmpty) {
      final neglected = imbalanced.firstWhere(
        (e) => e.value.currentStrength < e.value.targetStrength,
        orElse: () => imbalanced.first,
      );

      final currentPercentage = neglected.value.currentStrength.round();
      final targetPercentage = neglected.value.targetStrength.round();

      recommendations.add({
        'type': 'info',
        'message': 'Your ${neglected.key.name} is underworked ($currentPercentage% vs $targetPercentage% target). Add more exercises for balanced development',
        'priority': 'medium',
        'reason': 'Muscle imbalance detected. Optimal balance is ~17% per major group (Baz-Valle et al., 2022)',
      });
    }

    // Volume check (scientific approach: 10-20 sets/week per muscle group)
    final totalSetsPerWeek = _calculateWeeklySets(workouts);
    if (totalSetsPerWeek < 10) {
      recommendations.add({
        'type': 'warning',
        'message': 'Your weekly volume is low ($totalSetsPerWeek sets/week). Aim for 10-20 sets per muscle group for optimal growth',
        'priority': 'medium',
        'reason': 'Meta-analyses show 10-20 sets/week/muscle maximizes hypertrophy (Schoenfeld et al., 2017)',
      });
    } else if (totalSetsPerWeek > 30) {
      recommendations.add({
        'type': 'info',
        'message': 'High volume detected ($totalSetsPerWeek sets/week). Ensure you\'re recovering adequately',
        'priority': 'low',
        'reason': 'Volumes >20-30 sets/week show diminishing returns without proper recovery (Baz-Valle, 2022)',
      });
    }

    return recommendations;
  }

  int _calculateWeeklySets(List<Workout> workouts) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    int totalSets = 0;

    for (final workout in workouts) {
      if (workout.createdAt.isAfter(sevenDaysAgo)) {
        totalSets += workout.exercises.fold(0, (sum, ex) => sum + ex.sets.length);
      }
    }

    return totalSets;
  }
  
  double _calculateVolumeFromExercise(Exercise exercise) {
    return exercise.sets.fold(0.0, (sum, set) {
      if (!set.isCompleted) return sum;
      final weight = set.weight ?? 0;
      final reps = set.actualReps ?? set.reps ?? 0;
      return sum + (weight * reps);
    });
  }
  
  int _countWorkoutDays(List<Workout> workouts) {
    final uniqueDays = <String>{};
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    for (final workout in workouts) {
      if (workout.createdAt.isAfter(thirtyDaysAgo) && workout.isCompleted) {
        uniqueDays.add('${workout.createdAt.year}-${workout.createdAt.month}-${workout.createdAt.day}');
      }
    }

    return uniqueDays.length;
  }
}
