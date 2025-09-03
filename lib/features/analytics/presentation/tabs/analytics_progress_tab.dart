import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/workout_frequency_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_stats_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/enhanced_volume_progress_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/premium_feature_overlay.dart';

class AnalyticsProgressTab extends ConsumerWidget {
  final List<ExerciseActivity> activities;
  final bool isPremium;
  
  const AnalyticsProgressTab({
    super.key,
    required this.activities,
    required this.isPremium,
  });

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
                      Icons.calendar_month,
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
                WorkoutFrequencyChart(activities: activities),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Top Exercises (Free)
        ExerciseStatsCard(
          activities: activities,
          userEmail: '', // We don't need email for display
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
                      Icons.show_chart,
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
                              Icons.lock,
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
                PremiumFeatureOverlay(
                  isPremium: isPremium,
                  featureName: 'Volume Progress',
                  height: 400,
                  child: EnhancedVolumeProgressChart(
                    activities: activities,
                    isPremium: isPremium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Personal Records Section
        _buildPersonalRecords(context, activities),
        
        const SizedBox(height: 100), // Space for bottom navigation
      ],
    );
  }
  
  Widget _buildPersonalRecords(BuildContext context, List<ExerciseActivity> activities) {
    final theme = Theme.of(context);
    final records = _calculatePersonalRecords(activities);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
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
                        Icons.emoji_events_outlined,
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
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.whatshot,
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
                  Icons.fitness_center,
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
  
  Map<String, Map<String, dynamic>> _calculatePersonalRecords(List<ExerciseActivity> activities) {
    final records = <String, Map<String, dynamic>>{};
    
    for (final activity in activities) {
      for (final set in activity.sets) {
        final weight = double.tryParse(set.weight) ?? 0;
        
        if (weight > 0) {
          if (!records.containsKey(activity.exerciseName) ||
              records[activity.exerciseName]!['weight'] as double < weight) {
            records[activity.exerciseName] = {
              'weight': weight,
              'date': activity.createdAt,
            };
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
}