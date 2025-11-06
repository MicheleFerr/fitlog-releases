import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/workout_frequency_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_stats_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/lazy_chart_wrapper.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class AnalyticsProgressTab extends ConsumerWidget {
  
  const AnalyticsProgressTab({
    super.key,
    required this.workouts,
    required this.isPremium,
  });
  final List<Workout> workouts;
  final bool isPremium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Workout Frequency (Free)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.calendarMonth,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Workout Frequency',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LazyChartWrapper(
                  skeletonHeight: 180,
                  showLegend: true,
                  delayMs: 200,
                  child: WorkoutFrequencyChart(
                    workouts: workouts,
                    onWeekTap: (weekStart, count, workoutsInWeek) {
                      _showWeekDetailsBottomSheet(context, weekStart, count, workoutsInWeek);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Top Exercises (Free)
        ExerciseStatsCard(
          workouts: workouts,
        ),
        const SizedBox(height: 16),
        
        // Volume Progress (Premium)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.lineChart,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Volume Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.lock,
                              size: 12,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PREMIUM',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // PremiumFeatureOverlay(
                //   isPremium: isPremium,
                //   featureName: 'Volume Progress',
                //   height: 400,
                //   child: EnhancedVolumeProgressChart(
                //     workouts: workouts,
                //     isPremium: isPremium,
                //   ),
                // ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Personal Records Section
        _buildPersonalRecords(context, workouts),
        
        const SizedBox(height: 100), // Space for bottom navigation
      ],
    );
  }
  
  Widget _buildPersonalRecords(BuildContext context, List<Workout> workouts) {
    final theme = Theme.of(context);
    final records = _calculatePersonalRecords(workouts);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  AppIcons.achievement,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Personal Records',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (records.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        AppIcons.emojiEventsOutlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No personal records yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ...records.entries.map((entry) => _buildRecordItem(
                context,
                entry.key,
                entry.value['weight'] as double,
                entry.value['date'] as DateTime,
              )),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecordItem(BuildContext context, String exercise, double weight, DateTime date) {
    final theme = Theme.of(context);
    final daysAgo = DateTime.now().difference(date).inDays;
    final isRecent = daysAgo < 7;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRecent 
              ? Colors.amber.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRecent
                ? Colors.amber.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            if (isRecent)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.whatshot,
                  size: 16,
                  color: Colors.white,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.workout,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    daysAgo == 0 ? 'Today' : 
                    daysAgo == 1 ? 'Yesterday' : 
                    '$daysAgo days ago',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${weight.toStringAsFixed(1)} kg',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isRecent ? Colors.amber : theme.colorScheme.primary,
                  ),
                ),
                if (isRecent)
                  Text(
                    'NEW PR!',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Map<String, Map<String, dynamic>> _calculatePersonalRecords(List<Workout> workouts) {
    final records = <String, Map<String, dynamic>>{};

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        for (final set in exercise.sets) {
          final weight = set.weight ?? 0.0;
          if (set.isCompleted && weight > 0) {
            if (!records.containsKey(exercise.name) ||
                records[exercise.name]!['weight'] as double < weight) {
              records[exercise.name] = {
                'weight': weight,
                'date': workout.endTime ?? workout.createdAt,
              };
            }
          }
        }
      }
    }
    
    // Sort by weight descending and take top 5
    final sortedEntries = records.entries.toList()
      ..sort((a, b) => (b.value['weight'] as double)
          .compareTo(a.value['weight'] as double));
    
    return Map.fromEntries(sortedEntries.take(5));
  }

  void _showWeekDetailsBottomSheet(
    BuildContext context,
    DateTime weekStart,
    int count,
    List<Workout> workoutsInWeek,
  ) {
    final theme = Theme.of(context);
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Calculate stats for the week
    final totalVolume = workoutsInWeek.fold<double>(0, (sum, workout) {
      return sum + workout.exercises.fold<double>(0, (exSum, exercise) {
        return exSum + exercise.sets.fold<double>(0, (setSum, set) {
          if (!set.isCompleted) return setSum;
          final weight = set.weight ?? 0;
          final reps = set.actualReps ?? set.reps ?? 0;
          return setSum + (weight * reps);
        });
      });
    });

    final totalSets = workoutsInWeek.fold<int>(0, (sum, workout) {
      return sum + workout.exercises.fold<int>(0, (exSum, exercise) {
        return exSum + exercise.sets.where((s) => s.isCompleted).length;
      });
    });

    final avgDuration = workoutsInWeek.isEmpty
        ? 0
        : workoutsInWeek
                .where((w) => w.endTime != null)
                .map((w) => w.endTime!.difference(w.createdAt).inMinutes)
                .fold<int>(0, (sum, dur) => sum + dur) ~/
            workoutsInWeek.where((w) => w.endTime != null).length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Row(
              children: [
                Icon(
                  AppIcons.calendarMonth,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week of ${_formatDate(weekStart)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats grid
            Row(
              children: [
                _buildStatItem(
                  context,
                  'Workouts',
                  count.toString(),
                  AppIcons.workout,
                  theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  context,
                  'Total Sets',
                  totalSets.toString(),
                  AppIcons.repeat,
                  theme.colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem(
                  context,
                  'Volume',
                  '${(totalVolume / 1000).toStringAsFixed(1)}k kg',
                  AppIcons.analytics,
                  theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  context,
                  'Avg Duration',
                  '$avgDuration min',
                  AppIcons.timer,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Workouts list
            Text(
              'Workouts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...workoutsInWeek.map((workout) => _buildWorkoutItem(context, workout)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
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
      ),
    );
  }

  Widget _buildWorkoutItem(BuildContext context, Workout workout) {
    final theme = Theme.of(context);
    final duration = workout.endTime != null
        ? workout.endTime!.difference(workout.createdAt).inMinutes
        : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                AppIcons.workout,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${workout.exercises.length} exercises • $duration min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
