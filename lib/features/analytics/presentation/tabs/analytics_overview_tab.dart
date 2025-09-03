import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/compact_stat_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/hero_stat_card.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/json_exercise_repository.dart';

enum TimePeriod { week, month, year, all }

// Provider for exercise repository
final exerciseRepositoryProvider = Provider((ref) => JsonExerciseRepository());

class AnalyticsOverviewTab extends ConsumerStatefulWidget {
  final List<ExerciseActivity> activities;
  
  const AnalyticsOverviewTab({
    super.key,
    required this.activities,
  });

  @override
  ConsumerState<AnalyticsOverviewTab> createState() => _AnalyticsOverviewTabState();
}

class _AnalyticsOverviewTabState extends ConsumerState<AnalyticsOverviewTab> {
  TimePeriod _selectedPeriod = TimePeriod.week;
  
  List<ExerciseActivity> get filteredActivities {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case TimePeriod.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        return widget.activities.where((a) => a.createdAt.isAfter(weekAgo)).toList();
      case TimePeriod.month:
        final monthAgo = now.subtract(const Duration(days: 30));
        return widget.activities.where((a) => a.createdAt.isAfter(monthAgo)).toList();
      case TimePeriod.year:
        final yearAgo = now.subtract(const Duration(days: 365));
        return widget.activities.where((a) => a.createdAt.isAfter(yearAgo)).toList();
      case TimePeriod.all:
        return widget.activities;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _calculateStats(filteredActivities, _selectedPeriod);
    
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
            title: _getPeriodTitle(),
            value: '${stats['periodWorkouts']}',
            subtitle: '${stats['periodVolume']} kg total volume',
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
                value: '${stats['totalWorkouts']}',
                label: 'Total Workouts',
                icon: Icons.calendar_today,
                color: Colors.blue,
                subtitle: _getPeriodSubtitle(),
                trend: _buildTrend(stats['workoutTrend'] as double),
              ),
              CompactStatCard(
                value: _formatVolume(stats['totalVolume'] as double),
                label: 'Total Volume',
                icon: Icons.fitness_center,
                color: Colors.orange,
                subtitle: _getPeriodSubtitle(),
                trend: _buildTrend(stats['volumeTrend'] as double),
              ),
              CompactStatCard(
                value: '${stats['currentStreak']}',
                label: 'Day Streak',
                icon: Icons.local_fire_department,
                color: Colors.red,
                subtitle: stats['currentStreak'] as int > 0 ? 'Keep it up!' : 'Start today',
              ),
              CompactStatCard(
                value: '${stats['consistency']}%',
                label: 'Consistency',
                icon: Icons.insights,
                color: Colors.green,
                subtitle: 'Last 30 days',
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Recent Activities Section
          _buildRecentActivities(context, filteredActivities),
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
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton(context, 'Week', _selectedPeriod == TimePeriod.week, TimePeriod.week),
          _buildPeriodButton(context, 'Month', _selectedPeriod == TimePeriod.month, TimePeriod.month),
          _buildPeriodButton(context, 'Year', _selectedPeriod == TimePeriod.year, TimePeriod.year),
          _buildPeriodButton(context, 'All', _selectedPeriod == TimePeriod.all, TimePeriod.all),
        ],
      ),
    );
  }
  
  Widget _buildPeriodButton(BuildContext context, String label, bool isSelected, TimePeriod period) {
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
  
  Widget _buildRecentActivities(BuildContext context, List<ExerciseActivity> activities) {
    final theme = Theme.of(context);
    final recent = activities.take(3).toList();
    
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
                  'No recent workouts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a workout to see your progress',
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
                  'Recent Activities',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full activities list
                    _showAllActivities(context);
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recent.map((activity) => _buildActivityItem(context, activity)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityItem(BuildContext context, ExerciseActivity activity) {
    final theme = Theme.of(context);
    final timeAgo = _getTimeAgo(activity.createdAt);
    
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
                  activity.exerciseName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${activity.sets.length} sets • $timeAgo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_calculateExerciseVolume(activity).toStringAsFixed(0)} kg',
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
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/workout');
            },
            icon: const Icon(Icons.add),
            label: const Text('Start Workout'),
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
            label: const Text('View Stats'),
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
  
  void _showAllActivities(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _AllActivitiesModal(
        activities: filteredActivities,
        exerciseRepository: ref.read(exerciseRepositoryProvider),
      ),
    );
  }
  
  String _getPeriodTitle() {
    switch (_selectedPeriod) {
      case TimePeriod.week:
        return 'This Week Progress';
      case TimePeriod.month:
        return 'This Month Progress';
      case TimePeriod.year:
        return 'This Year Progress';
      case TimePeriod.all:
        return 'All Time Progress';
    }
  }
  
  String _getPeriodSubtitle() {
    switch (_selectedPeriod) {
      case TimePeriod.week:
        return 'Last 7 days';
      case TimePeriod.month:
        return 'Last 30 days';
      case TimePeriod.year:
        return 'Last 365 days';
      case TimePeriod.all:
        return 'All time';
    }
  }
  
  Map<String, dynamic> _calculateStats(List<ExerciseActivity> activities, TimePeriod period) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    
    // Period stats
    final periodWorkouts = _countUniqueWorkoutDays(activities);
    final periodVolume = _calculateTotalVolume(activities);
    
    // Total stats (using all activities if not already 'all')
    final allActivities = period == TimePeriod.all ? activities : widget.activities;
    final totalWorkouts = _countUniqueWorkoutDays(activities);
    final totalVolume = _calculateTotalVolume(activities);
    
    // Trends (comparing to previous period)
    List<ExerciseActivity> prevPeriodActivities;
    switch (period) {
      case TimePeriod.week:
        final prevWeekStart = weekStart.subtract(const Duration(days: 7));
        prevPeriodActivities = widget.activities.where((a) => 
          a.createdAt.isAfter(prevWeekStart) && a.createdAt.isBefore(weekStart)).toList();
      case TimePeriod.month:
        final prevMonthStart = monthStart.subtract(const Duration(days: 30));
        prevPeriodActivities = widget.activities.where((a) => 
          a.createdAt.isAfter(prevMonthStart) && a.createdAt.isBefore(monthStart)).toList();
      case TimePeriod.year:
        final prevYearStart = DateTime(now.year - 1);
        prevPeriodActivities = widget.activities.where((a) => 
          a.createdAt.isAfter(prevYearStart) && a.createdAt.isBefore(DateTime(now.year))).toList();
      case TimePeriod.all:
        prevPeriodActivities = [];
    }
    
    final prevPeriodVolume = _calculateTotalVolume(prevPeriodActivities);
    final volumeTrend = prevPeriodVolume > 0 
        ? ((periodVolume - prevPeriodVolume) / prevPeriodVolume * 100)
        : 0.0;
    
    final prevPeriodWorkouts = _countUniqueWorkoutDays(prevPeriodActivities);
    final workoutTrend = prevPeriodWorkouts > 0
        ? ((periodWorkouts - prevPeriodWorkouts) / prevPeriodWorkouts * 100)
        : 0.0;
    
    // Streak
    final streak = _calculateStreak(activities);
    
    // Consistency (last 30 days)
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final last30DaysActivities = activities.where((a) => 
      a.createdAt.isAfter(thirtyDaysAgo)).toList();
    final daysWithWorkout = _countUniqueWorkoutDays(last30DaysActivities);
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
  
  int _countUniqueWorkoutDays(List<ExerciseActivity> activities) {
    final uniqueDays = <String>{};
    for (final activity in activities) {
      uniqueDays.add(DateFormat('yyyy-MM-dd').format(activity.createdAt));
    }
    return uniqueDays.length;
  }
  
  double _calculateTotalVolume(List<ExerciseActivity> activities) {
    double total = 0;
    for (final activity in activities) {
      total += _calculateExerciseVolume(activity);
    }
    return total;
  }
  
  double _calculateExerciseVolume(ExerciseActivity activity) {
    double volume = 0;
    for (final set in activity.sets) {
      final weight = double.tryParse(set.weight) ?? 0;
      final reps = int.tryParse(set.reps) ?? 0;
      volume += weight * reps;
    }
    return volume;
  }
  
  int _calculateStreak(List<ExerciseActivity> activities) {
    if (activities.isEmpty) return 0;
    
    final sortedActivities = activities.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    int streak = 0;
    DateTime? lastDate;
    final today = DateTime.now();
    
    for (final activity in sortedActivities) {
      final activityDate = DateTime(
        activity.createdAt.year,
        activity.createdAt.month,
        activity.createdAt.day,
      );
      
      if (lastDate == null) {
        // First activity
        final todayDate = DateTime(today.year, today.month, today.day);
        final diff = todayDate.difference(activityDate).inDays;
        
        if (diff <= 1) {
          streak = 1;
          lastDate = activityDate;
        } else {
          break;
        }
      } else {
        final diff = lastDate.difference(activityDate).inDays;
        
        if (diff == 1) {
          streak++;
          lastDate = activityDate;
        } else if (diff == 0) {
          // Same day, continue
          continue;
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
  
  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }
}

// Enhanced modal with muscle group filters
class _AllActivitiesModal extends StatefulWidget {
  final List<ExerciseActivity> activities;
  final JsonExerciseRepository exerciseRepository;
  
  const _AllActivitiesModal({
    required this.activities,
    required this.exerciseRepository,
  });
  
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
          exerciseMuscleGroups[activity.id] = exercise.focus;
          
          // Calculate stats for each muscle group
          for (final muscleGroup in exercise.focus) {
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
      print('Error loading exercise data: $e');
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
    
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
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
                      'All Activities (${filteredActivities.length})',
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
                        'All',
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
                      'Muscle Group Statistics',
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
                                      ? 'No activities in this period'
                                      : 'No activities for selected muscle groups',
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
                    '${stats.workoutCount} workouts',
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
                _buildStatChip(Icons.fitness_center, '${stats.exercises.length} exercises', theme),
                _buildStatChip(Icons.format_list_numbered, '${stats.totalSets} sets', theme),
                _buildStatChip(Icons.monitor_weight, '${stats.totalVolume.toStringAsFixed(0)} kg', theme),
              ],
            ),
            if (stats.exercises.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Exercises: ${stats.exercises.take(3).join(', ')}${stats.exercises.length > 3 ? '...' : ''}',
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
      child: InkWell(
        onTap: () {
          // Could navigate to detailed view if needed
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.exerciseName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
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
                ],
              ),
              const SizedBox(height: 12),
              // Muscle groups tags
              if (muscleGroups.isNotEmpty) ...[
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
                const SizedBox(height: 8),
              ],
              // Sets summary
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatChip(Icons.format_list_numbered, '${activity.sets.length} sets', theme),
                  if (activity.sets.isNotEmpty) ...[
                    _buildStatChip(
                      Icons.fitness_center, 
                      '${_getMaxWeight(activity)} kg max', 
                      theme
                    ),
                    _buildStatChip(
                      Icons.repeat, 
                      '${_getTotalReps(activity)} total reps', 
                      theme
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
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
    double volume = 0;
    for (final set in activity.sets) {
      final weight = double.tryParse(set.weight) ?? 0;
      final reps = int.tryParse(set.reps) ?? 0;
      volume += weight * reps;
    }
    return volume;
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