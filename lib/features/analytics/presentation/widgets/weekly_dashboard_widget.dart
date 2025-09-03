import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/models/progressive_overload_data.dart';
import '../../../../features/workout/domain/entities/exercise_activity.dart';
import 'contextual_training_advisor.dart';

class WeeklyDashboardWidget extends StatefulWidget {
  final List<ExerciseActivity> activities;
  final bool isPremium;
  final Function(ProgressiveOverloadData)? onDataSync;

  const WeeklyDashboardWidget({
    super.key,
    required this.activities,
    this.isPremium = false,
    this.onDataSync,
  });

  @override
  State<WeeklyDashboardWidget> createState() => _WeeklyDashboardWidgetState();
}

class _WeeklyDashboardWidgetState extends State<WeeklyDashboardWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  ProgressiveOverloadData? _currentWeekData;
  ProgressiveOverloadData? _previousWeekData;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _calculateWeeklyData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateWeeklyData() {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStart(now);
    final currentWeekEnd = currentWeekStart.add(const Duration(days: 6));
    final previousWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    
    // Calculate current week data
    final currentWeekActivities = widget.activities.where((activity) {
      return activity.createdAt.isAfter(currentWeekStart) &&
             activity.createdAt.isBefore(currentWeekEnd.add(const Duration(days: 1)));
    }).toList();
    
    // Calculate previous week data
    final previousWeekActivities = widget.activities.where((activity) {
      return activity.createdAt.isAfter(previousWeekStart) &&
             activity.createdAt.isBefore(currentWeekStart);
    }).toList();
    
    if (currentWeekActivities.isNotEmpty) {
      _currentWeekData = _createWeekData(
        currentWeekActivities,
        currentWeekStart,
        currentWeekEnd,
        _calculatePreviousScore(previousWeekActivities),
      );
    }
    
    if (previousWeekActivities.isNotEmpty) {
      _previousWeekData = _createWeekData(
        previousWeekActivities,
        previousWeekStart,
        currentWeekStart.subtract(const Duration(days: 1)),
        0, // No previous score needed for display
      );
    }
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(
      date.year,
      date.month,
      date.day - (weekday - 1),
    );
  }

  double _calculatePreviousScore(List<ExerciseActivity> activities) {
    if (activities.isEmpty) return 0;
    
    final volume = _calculateTotalVolume(activities);
    final intensity = _calculateAvgIntensity(activities);
    return volume * intensity;
  }

  double _calculateTotalVolume(List<ExerciseActivity> activities) {
    return activities.fold(0.0, (sum, activity) {
      return sum + activity.sets.fold(0.0, (setSum, set) {
        final weight = double.tryParse(set.weight) ?? 0.0;
        final reps = int.tryParse(set.reps) ?? 0;
        return setSum + (weight * reps);
      });
    });
  }

  double _calculateAvgIntensity(List<ExerciseActivity> activities) {
    if (activities.isEmpty) return 7.0; // Default RPE 7
    
    // Calculate average RPE from sets
    int totalSets = 0;
    double totalRPE = 0.0;
    
    for (final activity in activities) {
      for (final set in activity.sets) {
        // effort is stored as 1-10, but RPE scale is 6-10
        // Convert: if effort <= 5, use RPE 6-7, if effort > 5, map to RPE 7-10
        final effort = set.effort ?? 7;
        final rpe = effort <= 5 
            ? 6.0 + (effort / 5.0) // Maps 1-5 to 6-7
            : 7.0 + ((effort - 5) / 5.0 * 3); // Maps 6-10 to 7-10
        
        totalRPE += rpe;
        totalSets++;
      }
    }
    
    if (totalSets == 0) return 7.0; // Default RPE 7
    
    // Return average RPE (will be between 6-10)
    return (totalRPE / totalSets).clamp(6.0, 10.0);
  }

  ProgressiveOverloadData _createWeekData(
    List<ExerciseActivity> activities,
    DateTime weekStart,
    DateTime weekEnd,
    double previousScore,
  ) {
    final volume = _calculateTotalVolume(activities);
    final intensity = _calculateAvgIntensity(activities);
    final currentScore = volume * intensity;
    final poScore = previousScore > 0 ? currentScore / previousScore : 1.0;
    
    // Calculate e1RM for each exercise
    final e1RMProgression = <String, double>{};
    final exerciseGroups = <String, List<ExerciseActivity>>{};
    
    for (final activity in activities) {
      exerciseGroups.putIfAbsent(activity.exerciseName, () => []).add(activity);
    }
    
    for (final entry in exerciseGroups.entries) {
      double maxE1RM = 0;
      for (final activity in entry.value) {
        for (final set in activity.sets) {
          final weight = double.tryParse(set.weight) ?? 0.0;
          final reps = int.tryParse(set.reps) ?? 0;
          if (weight > 0 && reps > 0) {
            final e1rm = BestSetPerformance.calculateE1RM(weight, reps);
            if (e1rm > maxE1RM) {
              maxE1RM = e1rm;
            }
          }
        }
      }
      if (maxE1RM > 0) {
        e1RMProgression[entry.key] = maxE1RM;
      }
    }
    
    // Find best set of the week
    BestSetPerformance? bestSet;
    double maxE1RM = 0;
    
    for (final activity in activities) {
      for (final set in activity.sets) {
        final weight = double.tryParse(set.weight) ?? 0.0;
        final reps = int.tryParse(set.reps) ?? 0;
        if (weight > 0 && reps > 0) {
          final e1rm = BestSetPerformance.calculateE1RM(weight, reps);
          if (e1rm > maxE1RM) {
            maxE1RM = e1rm;
            bestSet = BestSetPerformance(
              exerciseName: activity.exerciseName,
              weight: weight,
              reps: reps,
              e1RM: e1rm,
              performedAt: activity.createdAt,
              isPR: false, // TODO: Check against historical data
            );
          }
        }
      }
    }
    
    // Calculate effective volume
    final effectiveVolume = volume * 0.85; // Simplified calculation
    
    return ProgressiveOverloadData(
      userId: '', // TODO: Get from auth
      weekStart: weekStart,
      weekEnd: weekEnd,
      weekNumber: _getWeekNumber(weekStart),
      year: weekStart.year,
      totalVolume: volume,
      avgIntensity: intensity,
      progressiveOverloadScore: poScore,
      previousWeekScore: previousScore,
      e1RMProgression: e1RMProgression,
      effectiveVolume: effectiveVolume,
      bestSet: bestSet,
      fatigueRatings: [],
      avgMuscleEfficiency: 0,
      createdAt: DateTime.now(),
      isPremiumData: widget.isPremium,
    );
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_currentWeekData == null) {
      return _buildEmptyState(theme);
    }
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with PO Score
              _buildPOScoreCard(theme),
              const SizedBox(height: 16),
              
              // Weekly Stats Grid
              _buildStatsGrid(theme),
              const SizedBox(height: 16),
              
              // e1RM Tracker Chart
              _buildE1RMChart(theme),
              const SizedBox(height: 16),
              
              // Best Set Performance
              if (_currentWeekData!.bestSet != null) ...[
                _buildBestSetCard(theme),
                const SizedBox(height: 16),
              ],
              
              // Premium sync button
              if (widget.isPremium) _buildSyncButton(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPOScoreCard(ThemeData theme) {
    if (_currentWeekData == null) return const SizedBox.shrink();
    
    // Get current week activities for workout count and last workout date
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(
      Duration(days: now.weekday - 1),
    );
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final currentWeekActivities = widget.activities.where((activity) {
      return activity.createdAt.isAfter(weekStart) && 
             activity.createdAt.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
    
    // Get last workout date
    final lastWorkout = widget.activities.isEmpty 
        ? DateTime.now().subtract(const Duration(days: 7))
        : widget.activities.reduce((a, b) => 
            a.createdAt.isAfter(b.createdAt) ? a : b).createdAt;
    
    return ContextualTrainingAdvisor(
      currentWeekVolume: _currentWeekData!.totalVolume,
      previousWeekVolume: _currentWeekData!.previousWeekScore,
      avgIntensity: _currentWeekData!.avgIntensity,
      fatigueHistory: _currentWeekData!.fatigueRatings,
      workoutCount: currentWeekActivities.length,
      lastWorkoutDate: lastWorkout,
      isPremium: widget.isPremium,
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Total Volume',
          '${(_currentWeekData!.totalVolume / 1000).toStringAsFixed(1)}k kg',
          Icons.fitness_center,
          theme.colorScheme.primary,
          theme,
        ),
        _buildStatCard(
          'Effective Volume',
          '${(_currentWeekData!.effectiveVolume / 1000).toStringAsFixed(1)}k kg',
          Icons.check_circle,
          Colors.green,
          theme,
        ),
        _buildStatCard(
          'Avg Intensity',
          '${_currentWeekData!.avgIntensity.toStringAsFixed(1)}/10',
          Icons.local_fire_department,
          Colors.orange,
          theme,
        ),
        _buildStatCard(
          'Exercises',
          '${_currentWeekData!.e1RMProgression.length}',
          Icons.format_list_numbered,
          theme.colorScheme.secondary,
          theme,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildE1RMChart(ThemeData theme) {
    final e1rmData = _currentWeekData!.e1RMProgression.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (e1rmData.isEmpty) {
      return const SizedBox();
    }
    
    // Take top 5 exercises
    final topExercises = e1rmData.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'e1RM Tracker - Top Exercises',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...topExercises.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(1)} kg',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: entry.value / (topExercises.first.value + 10),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBestSetCard(ThemeData theme) {
    final bestSet = _currentWeekData!.bestSet!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.tertiary.withValues(alpha: 0.1),
            theme.colorScheme.tertiary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Text(
                'Best Set of the Week',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (bestSet.isPR) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PR!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bestSet.exerciseName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.fitness_center, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                '${bestSet.weight.toStringAsFixed(1)} kg × ${bestSet.reps} reps',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.rocket_launch, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                'e1RM: ${bestSet.e1RM.toStringAsFixed(1)} kg',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton(ThemeData theme) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          if (_currentWeekData != null) {
            HapticFeedback.lightImpact();
            widget.onDataSync?.call(_currentWeekData!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data synced to cloud'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Sync to Cloud'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No workout data this week',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete workouts to see your progress',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}