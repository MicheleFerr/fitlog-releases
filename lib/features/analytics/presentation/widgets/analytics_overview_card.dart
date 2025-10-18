import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/analytics_screen.dart';

class AnalyticsOverviewCard extends StatelessWidget {

  const AnalyticsOverviewCard({
    super.key,
    required this.stats,
  });
  final OverallStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stats Grid
            Row(
              children: [
                Expanded(child: _buildStatItem(
                  context,
                  '🏋️',
                  stats.totalWorkouts.toString(),
                  'Workouts',
                )),
                Expanded(child: _buildStatItem(
                  context,
                  '💪',
                  stats.totalExercises.toString(),
                  'Exercises',
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatItem(
                  context,
                  '🔢',
                  stats.totalSets.toString(),
                  'Total Sets',
                )),
                Expanded(child: _buildStatItem(
                  context,
                  '⚖️',
                  '${(stats.totalVolume / 1000).toStringAsFixed(1)}t',
                  'Total Volume',
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String emoji,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}