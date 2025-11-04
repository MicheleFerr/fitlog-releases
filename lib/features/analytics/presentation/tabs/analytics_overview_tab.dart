import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/exercise_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/hero_stat_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/compact_stat_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/memoized_analytics_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';

class AnalyticsOverviewTab extends ConsumerStatefulWidget {

  const AnalyticsOverviewTab({
    super.key,
    required this.workouts,
  });
  final List<Workout> workouts;

  @override
  ConsumerState<AnalyticsOverviewTab> createState() => _AnalyticsOverviewTabState();
}

class _AnalyticsOverviewTabState extends ConsumerState<AnalyticsOverviewTab> {
  TimePeriod _selectedPeriod = TimePeriod.week;

  List<Workout> get filteredWorkouts {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case TimePeriod.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        return widget.workouts.where((w) => (w.endTime ?? w.createdAt).isAfter(weekAgo)).toList();
      case TimePeriod.month:
        final monthAgo = now.subtract(const Duration(days: 30));
        return widget.workouts.where((w) => (w.endTime ?? w.createdAt).isAfter(monthAgo)).toList();
      case TimePeriod.year:
        final yearAgo = now.subtract(const Duration(days: 365));
        return widget.workouts.where((w) => (w.endTime ?? w.createdAt).isAfter(yearAgo)).toList();
      case TimePeriod.all:
        return widget.workouts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Watch memoized stats provider - this is cached!
    final stats = ref.watch(periodAnalyticsStatsProvider(_selectedPeriod));
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh will be handled by parent
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Period Selector
          _buildPeriodSelector(context),
          const SizedBox(height: 20),

          // Hero Card - Period Summary
          HeroStatCard(
            title: _getPeriodTitle(context, _selectedPeriod),
            value: '${stats.totalWorkouts}',
            subtitle: '${stats.totalVolume.round()} kg total volume',
            icon: Icons.fitness_center,
            gradientColors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.7),
            ],
            onTap: () {
              // Navigate to detailed view
            },
          ),
          const SizedBox(height: 16),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              CompactStatCard(
                value: '${stats.totalWorkouts}',
                label: l10n.totalWorkouts,
                icon: Icons.calendar_today,
                color: Colors.blue,
                subtitle: _getPeriodSubtitle(context, _selectedPeriod),
                trend: _buildTrend(stats.workoutTrend),
                tooltipTitle: l10n.totalWorkouts,
                tooltipDescription: l10n.workoutFrequencyTooltip,
              ),
              CompactStatCard(
                value: _formatVolume(stats.totalVolume),
                label: l10n.totalVolume,
                icon: Icons.fitness_center,
                color: Colors.orange,
                subtitle: _getPeriodSubtitle(context, _selectedPeriod),
                trend: _buildTrend(stats.volumeTrend),
                tooltipTitle: l10n.totalVolume,
                tooltipDescription: l10n.totalVolumeTooltip,
              ),
              CompactStatCard(
                value: '${stats.currentStreak}',
                label: l10n.dayStreak,
                icon: Icons.local_fire_department,
                color: Colors.red,
                subtitle: stats.currentStreak > 0 ? l10n.keepItUp : l10n.startToday,
                tooltipTitle: l10n.dayStreak,
                tooltipDescription: l10n.currentStreakTooltip,
              ),
              CompactStatCard(
                value: '${stats.consistency}%',
                label: l10n.consistency,
                icon: Icons.insights,
                color: Colors.green,
                subtitle: l10n.last30Days,
                tooltipTitle: l10n.consistency,
                tooltipDescription: l10n.consistencyTooltip,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Recent Workouts Section
          _buildRecentWorkouts(context, filteredWorkouts),
          const SizedBox(height: 20),
          
          // Quick Actions
          _buildQuickActions(context),
          const SizedBox(height: 100), // Space for bottom navigation
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
          _buildPeriodButton(context, l10n.week, _selectedPeriod == TimePeriod.week, TimePeriod.week),
          _buildPeriodButton(context, l10n.month, _selectedPeriod == TimePeriod.month, TimePeriod.month),
          _buildPeriodButton(context, l10n.year, _selectedPeriod == TimePeriod.year, TimePeriod.year),
          _buildPeriodButton(context, l10n.all, _selectedPeriod == TimePeriod.all, TimePeriod.all),
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
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
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
                Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
        ],
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
            icon: const Icon(Icons.add),
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
            icon: const Icon(Icons.bar_chart),
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
  
  Widget _buildTrend(double value) {
    final color = value > 0 ? Colors.green : value < 0 ? Colors.red : Colors.grey;
    final icon = value > 0 ? Icons.trending_up : value < 0 ? Icons.trending_down : Icons.remove;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            '${value.abs().toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAllWorkouts(BuildContext context) {
    if (kDebugMode) {
      debugPrint('🔍 [Analytics] _showAllWorkouts called');
    }
    if (kDebugMode) {
      debugPrint('📊 [Analytics] Total workouts to process: ${widget.workouts.length}');
    }

    // TEMPORARY FIX: Don't filter by isCompleted since all sets from Firebase have isCompleted=false
    // after the Model→Domain conversion. We'll filter based on having exercises and sets only.
    final validWorkouts = widget.workouts.where((w) {
      final hasValidExercises = w.exercises.any((e) => e.sets.isNotEmpty);
      if (!hasValidExercises) {
        if (kDebugMode) {
          debugPrint('  ⚠️ [Analytics] Skipping workout "${w.name}" - no exercises with sets');
        }
      }
      return hasValidExercises;
    }).toList();

    if (kDebugMode) {
      debugPrint('📋 [Analytics] Valid workouts after filtering: ${validWorkouts.length}/${widget.workouts.length}');
    }

    // Log detailed workout information (only for valid workouts)
    for (var i = 0; i < validWorkouts.length.clamp(0, 5); i++) {  // Log first 5 workouts max
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
          debugPrint('          - Exercise isCompleted: ${exercise.isCompleted}');
        }

        if (exercise.sets.isEmpty) {
          if (kDebugMode) {
            debugPrint('          ⚠️ [Analytics] WARNING: Exercise has NO sets!');
          }
          continue;
        }

        for (var k = 0; k < exercise.sets.length; k++) {
          final set = exercise.sets[k];
          if (kDebugMode) {
            debugPrint('          ✓ [Analytics] Set ${k + 1}: weight=${set.weight}, reps=${set.reps}, isCompleted=${set.isCompleted}');
          }
        }

        final completedSets = exercise.sets.where((s) => s.isCompleted).length;
        if (kDebugMode) {
          debugPrint('          - Completed sets: $completedSets/${exercise.sets.length}');
        }
        if (kDebugMode) {
          debugPrint('          - Has any completed set: ${exercise.sets.any((s) => s.isCompleted)}');
        }
      }
    }

    if (validWorkouts.length > 5) {
      if (kDebugMode) {
        debugPrint('  ... (${validWorkouts.length - 5} more workouts not logged)');
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No completed exercises found in your workouts'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final syntheticActivities = validWorkouts.expand((w) {
      if (kDebugMode) {
        debugPrint('🔄 [Analytics] Processing workout: "${w.name}"');
      }

      final filteredExercises = w.exercises
        .where((e) {
          // Extra safety check: ensure sets array is not empty
          if (e.sets.isEmpty) {
            if (kDebugMode) {
              debugPrint('  ⚠️ [Analytics] Exercise "${e.name}" has EMPTY sets array - skipping');
            }
            return false;
          }

          final hasCompletedSets = e.sets.any((s) => s.isCompleted);
          if (kDebugMode) {
            debugPrint('  🔎 [Analytics] Exercise "${e.name}": hasCompletedSets=$hasCompletedSets (${e.sets.length} sets)');
          }
          return hasCompletedSets;
        })
        .toList();

      if (kDebugMode) {
        debugPrint('  ✅ [Analytics] Filtered exercises for "${w.name}": ${filteredExercises.length}/${w.exercises.length}');
      }

      return filteredExercises.map((e) {
        if (kDebugMode) {
          debugPrint('  🏗️ [Analytics] Creating ExerciseActivity for "${e.name}"');
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
      debugPrint('🎯 [Analytics] Total synthetic activities created: ${syntheticActivities.length}');
    }
    if (kDebugMode) {
      debugPrint('');
    }

    // Safety check before showing modal
    if (syntheticActivities.isEmpty) {
      if (kDebugMode) {
        debugPrint('❌ [Analytics] ERROR: syntheticActivities is EMPTY after processing!');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to load exercise activities'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
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
        return l10n.thisWeekProgress;
      case TimePeriod.month:
        return l10n.thisMonthProgress;
      case TimePeriod.year:
        return l10n.thisYearProgress;
      case TimePeriod.all:
        return l10n.allTimeProgress;
    }
  }

  String _getPeriodSubtitle(BuildContext context, TimePeriod period) {
    final l10n = AppLocalizations.of(context);
    switch (period) {
      case TimePeriod.week:
        return l10n.last7Days;
      case TimePeriod.month:
        return l10n.last30Days;
      case TimePeriod.year:
        return l10n.last365Days;
      case TimePeriod.all:
        return l10n.allTime;
    }
  }

  // REMOVED: _calculateStats - now using memoized provider
  Map<String, dynamic> _calculateStatsOLD_UNUSED(List<Workout> workouts, TimePeriod period) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    
    // Period stats
    final periodWorkouts = workouts.length;
    final periodVolume = _calculateTotalVolume(workouts);
    
    // Total stats (using all workouts if not already 'all')
    final allWorkouts = period == TimePeriod.all ? workouts : widget.workouts;
    final totalWorkouts = allWorkouts.length;
    final totalVolume = _calculateTotalVolume(allWorkouts);
    
    // Trends (comparing to previous period)
    List<Workout> prevPeriodWorkouts;
    switch (period) {
      case TimePeriod.week:
        final prevWeekStart = weekStart.subtract(const Duration(days: 7));
        prevPeriodWorkouts = widget.workouts.where((w) => 
          (w.endTime ?? w.createdAt).isAfter(prevWeekStart) && (w.endTime ?? w.createdAt).isBefore(weekStart)).toList();
        break;
      case TimePeriod.month:
        final prevMonthStart = monthStart.subtract(const Duration(days: 30));
        prevPeriodWorkouts = widget.workouts.where((w) => 
          (w.endTime ?? w.createdAt).isAfter(prevMonthStart) && (w.endTime ?? w.createdAt).isBefore(monthStart)).toList();
        break;
      case TimePeriod.year:
        final prevYearStart = DateTime(now.year - 1);
        prevPeriodWorkouts = widget.workouts.where((w) => 
          (w.endTime ?? w.createdAt).isAfter(prevYearStart) && (w.endTime ?? w.createdAt).isBefore(DateTime(now.year))).toList();
        break;
      case TimePeriod.all:
        prevPeriodWorkouts = [];
        break;
    }
    
    final prevPeriodVolume = _calculateTotalVolume(prevPeriodWorkouts);
    final volumeTrend = prevPeriodVolume > 0 
        ? ((periodVolume - prevPeriodVolume) / prevPeriodVolume * 100)
        : periodVolume > 0 ? 100.0 : 0.0;
    
    final prevPeriodWorkoutCount = prevPeriodWorkouts.length;
    final workoutTrend = prevPeriodWorkoutCount > 0
        ? ((periodWorkouts - prevPeriodWorkoutCount) / prevPeriodWorkoutCount * 100)
        : periodWorkouts > 0 ? 100.0 : 0.0;
    
    // Streak
    final streak = _calculateStreak(allWorkouts);
    
    // Consistency (last 30 days)
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final last30DaysWorkouts = allWorkouts.where((w) => 
      (w.endTime ?? w.createdAt).isAfter(thirtyDaysAgo)).toList();
    final daysWithWorkout = _countUniqueWorkoutDays(last30DaysWorkouts);
    final consistency = (daysWithWorkout / 30 * 100).round();
    
    return {
      'periodWorkouts': periodWorkouts,
      'periodVolume': periodVolume.round(),
      'totalWorkouts': totalWorkouts,
      'totalVolume': totalVolume,
      'volumeTrend': volumeTrend,
      'workoutTrend': workoutTrend,
      'currentStreak': streak,
      'consistency': consistency,
    };
  }
  
  int _countUniqueWorkoutDays(List<Workout> workouts) {
    final uniqueDays = <String>{};
    for (final workout in workouts) {
      uniqueDays.add(DateFormat('yyyy-MM-dd').format(workout.endTime ?? workout.createdAt));
    }
    return uniqueDays.length;
  }
  
  double _calculateTotalVolume(List<Workout> workouts) {
    double total = 0;
    for (final workout in workouts) {
      total += workout.exercises.fold(0.0, (sum, exercise) => sum + exercise.totalVolume);
    }
    return total;
  }
  
  int _calculateStreak(List<Workout> workouts) {
    if (workouts.isEmpty) return 0;
    
    final sortedWorkouts = workouts.toList()
      ..sort((a, b) => (b.endTime ?? b.createdAt).compareTo(a.endTime ?? a.createdAt));
    
    final uniqueDates = sortedWorkouts
        .map((w) => w.endTime ?? w.createdAt)
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList();
    
    if (uniqueDates.isEmpty) return 0;
    
    int streak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    if (uniqueDates.first == todayDate || uniqueDates.first == yesterday) {
        streak = 1;
        for (int i = 1; i < uniqueDates.length; i++) {
            if (uniqueDates[i-1].difference(uniqueDates[i]).inDays == 1) {
                streak++;
            } else {
                break;
            }
        }
    }
    
    return streak;
  }
  
  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k';
    }
    return volume.toStringAsFixed(0);
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
        final exercise = await widget.exerciseRepository.getExerciseById(activity.exerciseId);
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

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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
                      icon: const Icon(Icons.close),
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
                      ...muscleGroupStats.keys.map((group) => Padding(
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
                      )),
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
                    ? const Center(child: CircularProgressIndicator())
                    : filteredActivities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final activity = filteredActivities[index];
                              final muscleGroups = exerciseMuscleGroups[activity.id] ?? [];
                              return _buildDetailedActivityCard(context, activity, muscleGroups);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, ThemeData theme) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected 
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
  
  Widget _buildMuscleGroupStatCard(String group, MuscleGroupStats stats, ThemeData theme) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.workoutsCount(stats.workoutCount),
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
                _buildStatChip(Icons.fitness_center, l10n.exercisesCount(stats.exercises.length), theme),
                _buildStatChip(Icons.format_list_numbered, l10n.setsCount(stats.totalSets), theme),
                _buildStatChip(Icons.monitor_weight, '${stats.totalVolume.toStringAsFixed(0)} kg', theme),
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
  
  Widget _buildDetailedActivityCard(BuildContext context, ExerciseActivity activity, List<String> muscleGroups) {
    final theme = Theme.of(context);
    final volume = _calculateExerciseVolume(activity);
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(activity.createdAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          leading: Icon(
            Icons.fitness_center,
            color: theme.colorScheme.primary,
          ),
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
                  children: muscleGroups.map((group) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  )).toList(),
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
                                    Icon(
                                      Icons.fitness_center,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.repeat,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context).repsCount(reps),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).volumeWithValue(setVolume.toStringAsFixed(0)),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.speed,
                                            size: 12,
                                            color: theme.colorScheme.onSecondaryContainer,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            AppLocalizations.of(context).rpeWithValue(rpe.toString()),
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSecondaryContainer,
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
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        Icons.format_list_numbered,
                        AppLocalizations.of(context).setsCount(activity.sets.length),
                        theme,
                      ),
                      _buildSummaryItem(
                        Icons.fitness_center,
                        AppLocalizations.of(context).kgMax(_getMaxWeight(activity).toStringAsFixed(0)),
                        theme,
                      ),
                      _buildSummaryItem(
                        Icons.repeat,
                        AppLocalizations.of(context).repsCount(_getTotalReps(activity)),
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
        Icon(icon, size: 20, color: theme.colorScheme.primary),
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
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
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
  
  String _getMuscleGroupName(String code) {
    // Map muscle group codes to display names
    final muscleGroups = {
      'CHEST': 'Chest',
      'BACK': 'Back',
      'SHOULDERS': 'Shoulders',
      'ARMS': 'Arms',
      'BICEPS': 'Biceps',
      'TRICEPS': 'Triceps',
      'LEGS': 'Legs',
      'QUAD': 'Quadriceps',
      'HAMSTRINGS': 'Hamstrings',
      'GLUT': 'Glutes',
      'CALVES': 'Calves',
      'ABS': 'Abs',
      'CORE': 'Core',
      'CARDIO': 'Cardio',
      'TRAP': 'Traps',
      'LATS': 'Lats',
      'DELTS': 'Delts',
      'FOREARMS': 'Forearms',
      'OTHER': 'Other',
    };
    
    return muscleGroups[code.toUpperCase()] ?? code;
  }
}

// Stats class for muscle groups
class MuscleGroupStats {
  int workoutCount = 0;
  int totalSets = 0;
  double totalVolume = 0;
  Set<String> exercises = {};
}