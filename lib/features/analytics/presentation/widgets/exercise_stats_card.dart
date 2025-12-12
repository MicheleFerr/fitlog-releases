import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:collection/collection.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

class ExerciseStatsCard extends StatelessWidget {

  const ExerciseStatsCard({
    super.key,
    required this.workouts,
  });
  final List<Workout> workouts;

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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No exercise data available',
                    style: TextStyle(color: context.colors.surfaceVariant),
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(0x4D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Exercise image or icon
          const CircleAvatar(
            radius: 20,
            child: Icon(Icons.fitness_center, size: 20),
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
      builder: (context) {
        final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.95);
        return DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: safeMax,
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
                  color: const Color(0xFFE0E0E0),
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
                            const CircleAvatar(
                              child: Icon(Icons.fitness_center),
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
      );
      },
    );
  }

  List<ExerciseStat> _calculateExerciseStats() {
    final allExercises = workouts.expand((workout) => workout.exercises).toList();

    final exercisesByName = groupBy(allExercises, (exercise) => exercise.name);

    final List<ExerciseStat> stats = [];

    for (final entry in exercisesByName.entries) {
      final exerciseName = entry.key;
      final exercises = entry.value;

      double maxWeight = 0;
      double totalVolume = 0;
      int totalSets = 0;
      final int sessions = workouts.where((w) => w.exercises.any((e) => e.name == exerciseName)).length;


      for (final exercise in exercises) {
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            final weight = set.weight ?? 0.0;
            final reps = set.actualReps ?? set.reps ?? 0;
            if (weight > maxWeight) {
              maxWeight = weight;
            }
            totalVolume += weight * reps;
            totalSets++;
          }
        }
      }

      stats.add(ExerciseStat(
        exerciseName: exerciseName,
        sessions: sessions,
        totalSets: totalSets,
        maxWeight: maxWeight,
        totalVolume: totalVolume,
      ));
    }

    // Sort by total volume descending
    stats.sort((a, b) => b.totalVolume.compareTo(a.totalVolume));

    return stats;
  }
}

class ExerciseStat {

  ExerciseStat({
    required this.exerciseName,
    required this.sessions,
    required this.totalSets,
    required this.maxWeight,
    required this.totalVolume,
  });
  final String exerciseName;
  final int sessions;
  final int totalSets;
  final double maxWeight;
  final double totalVolume;
}
