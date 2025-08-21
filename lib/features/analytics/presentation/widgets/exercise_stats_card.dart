import 'package:flutter/material.dart';
import '../../../workout/domain/entities/exercise_activity.dart';

class ExerciseStatsCard extends StatelessWidget {
  final List<ExerciseActivity> activities;
  final String userEmail;

  const ExerciseStatsCard({
    super.key,
    required this.activities,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseStats = _calculateExerciseStats();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.leaderboard,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Top Exercises',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showAllExercises(context, exerciseStats),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (exerciseStats.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No exercise data available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...exerciseStats.take(5).map((stat) => _buildExerciseStatItem(context, stat)),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseStatItem(BuildContext context, ExerciseStat stat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Exercise image or icon
          CircleAvatar(
            radius: 20,
            backgroundImage: stat.imageUrl != null 
                ? NetworkImage(stat.imageUrl!)
                : null,
            child: stat.imageUrl == null
                ? const Icon(Icons.fitness_center, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          
          // Exercise info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.exerciseName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${stat.totalSets} sets • ${stat.sessions} sessions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stat.maxWeight.toStringAsFixed(0)} kg',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                'max weight',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(stat.totalVolume / 1000).toStringAsFixed(1)}t',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Text(
                'volume',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllExercises(BuildContext context, List<ExerciseStat> stats) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Text(
                'All Exercises Statistics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Exercises list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: stats.length,
                  itemBuilder: (context, index) {
                    final stat = stats[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: stat.imageUrl != null 
                                  ? NetworkImage(stat.imageUrl!)
                                  : null,
                              child: stat.imageUrl == null
                                  ? const Icon(Icons.fitness_center)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stat.exerciseName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${stat.sessions} sessions • ${stat.totalSets} sets',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${stat.maxWeight.toStringAsFixed(0)} kg',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${(stat.totalVolume / 1000).toStringAsFixed(1)}t vol',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  List<ExerciseStat> _calculateExerciseStats() {
    final Map<String, List<ExerciseActivity>> exerciseGroups = {};
    
    // Group by exercise name
    for (final activity in activities) {
      exerciseGroups.putIfAbsent(activity.exerciseName, () => []).add(activity);
    }
    
    // Calculate stats for each exercise
    final List<ExerciseStat> stats = [];
    for (final entry in exerciseGroups.entries) {
      final exerciseName = entry.key;
      final exerciseActivities = entry.value;
      
      double maxWeight = 0;
      double totalVolume = 0;
      int totalSets = 0;
      String? imageUrl = exerciseActivities.first.exerciseImage;
      
      for (final activity in exerciseActivities) {
        for (final set in activity.sets) {
          if (set.done) {
            final weight = double.tryParse(set.weight) ?? 0;
            final reps = int.tryParse(set.reps) ?? 0;
            
            maxWeight = maxWeight > weight ? maxWeight : weight;
            totalVolume += weight * reps;
            totalSets++;
          }
        }
      }
      
      stats.add(ExerciseStat(
        exerciseName: exerciseName,
        sessions: exerciseActivities.length,
        totalSets: totalSets,
        maxWeight: maxWeight,
        totalVolume: totalVolume,
        imageUrl: imageUrl,
      ));
    }
    
    // Sort by total volume descending
    stats.sort((a, b) => b.totalVolume.compareTo(a.totalVolume));
    
    return stats;
  }
}

class ExerciseStat {
  final String exerciseName;
  final int sessions;
  final int totalSets;
  final double maxWeight;
  final double totalVolume;
  final String? imageUrl;

  ExerciseStat({
    required this.exerciseName,
    required this.sessions,
    required this.totalSets,
    required this.maxWeight,
    required this.totalVolume,
    this.imageUrl,
  });
}