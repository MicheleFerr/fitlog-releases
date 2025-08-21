import 'package:flutter/material.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../../workout/domain/entities/exercise_activity.dart';

/// Enhanced Progress Ring Indicator
class EnhancedProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;

  const EnhancedProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveProgressColor = progressColor ?? colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.outline.withOpacity(0.2);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveBackgroundColor),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, _) {
                return CircularProgressIndicator(
                  value: animatedProgress,
                  strokeWidth: strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          // Center content
          if (child != null)
            Center(child: child!),
        ],
      ),
    );
  }
}

/// Enhanced Linear Progress Bar
class EnhancedLinearProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;
  final String? label;
  final String? value;

  const EnhancedLinearProgress({
    super.key,
    required this.progress,
    this.height = 8,
    this.progressColor,
    this.backgroundColor,
    this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveProgressColor = progressColor ?? colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surfaceContainerLow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || value != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (value != null)
                Text(
                  value!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        if (label != null || value != null) const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: animatedProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        effectiveProgressColor,
                        effectiveProgressColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Enhanced Progress Indicator for specific activities
class EnhancedProgressIndicator extends StatelessWidget {
  final ExerciseActivity activity;
  final bool showDetailedMetrics;

  const EnhancedProgressIndicator({
    super.key,
    required this.activity,
    this.showDetailedMetrics = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progressData = _calculateProgress();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.exerciseName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(activity.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _buildProgressBadge(context, progressData),
            ],
          ),
          const SizedBox(height: 20),
          
          // Volume Progress
          EnhancedLinearProgress(
            progress: progressData.volumeProgress,
            label: 'Volume Progress',
            value: '${progressData.currentVolume.toStringAsFixed(0)}kg',
            progressColor: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          
          if (showDetailedMetrics) ...[
            // Sets Progress
            EnhancedLinearProgress(
              progress: progressData.setsProgress,
              label: 'Sets Completed',
              value: '${progressData.completedSets}/${progressData.targetSets}',
              progressColor: colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            
            // Intensity Progress
            EnhancedLinearProgress(
              progress: progressData.intensityProgress,
              label: 'Intensity',
              value: '${(progressData.intensityProgress * 100).toStringAsFixed(0)}%',
              progressColor: colorScheme.tertiary,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    context,
                    'Sets',
                    '${progressData.completedSets}',
                    Icons.format_list_numbered,
                    colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMiniStat(
                    context,
                    'Volume',
                    '${progressData.currentVolume.toStringAsFixed(0)}kg',
                    Icons.bar_chart,
                    colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBadge(BuildContext context, ProgressData progressData) {
    final colorScheme = Theme.of(context).colorScheme;
    final isImproving = progressData.volumeProgress > 0.7;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isImproving 
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isImproving ? Icons.trending_up : Icons.trending_flat,
            color: isImproving ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isImproving ? 'Improving' : 'Steady',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isImproving ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ProgressData _calculateProgress() {
    final sets = activity.sets;
    final totalVolume = sets.fold<double>(0.0, (sum, set) {
      final weight = double.tryParse(set.weight) ?? 0.0;
      final reps = int.tryParse(set.reps) ?? 0;
      return sum + (weight * reps);
    });

    // Calculate progress based on some target metrics
    // This is a simplified calculation - in a real app, you'd compare against
    // previous performances, goals, or standards
    final completedSets = sets.length;
    final targetSets = 4; // Example target
    final setsProgress = (completedSets / targetSets).clamp(0.0, 1.0);
    
    // Volume progress based on a target volume (this would be more sophisticated in reality)
    final targetVolume = 2000.0; // Example target in kg
    final volumeProgress = (totalVolume / targetVolume).clamp(0.0, 1.0);
    
    // Intensity progress (simplified calculation)
    final averageWeight = sets.isEmpty ? 0.0 : sets
        .map((set) => double.tryParse(set.weight) ?? 0.0)
        .reduce((a, b) => a + b) / sets.length;
    final intensityProgress = (averageWeight / 100).clamp(0.0, 1.0); // Assuming 100kg is high intensity

    return ProgressData(
      currentVolume: totalVolume,
      volumeProgress: volumeProgress,
      completedSets: completedSets,
      targetSets: targetSets,
      setsProgress: setsProgress,
      intensityProgress: intensityProgress,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Goal Progress Widget
class GoalProgressWidget extends StatelessWidget {
  final String title;
  final double currentValue;
  final double targetValue;
  final String unit;
  final IconData icon;
  final Color? color;

  const GoalProgressWidget({
    super.key,
    required this.title,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;
    final progress = (currentValue / targetValue).clamp(0.0, 1.0);
    final isCompleted = currentValue >= targetValue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: effectiveColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${currentValue.toStringAsFixed(0)} / ${targetValue.toStringAsFixed(0)} $unit',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            EnhancedProgressRing(
              progress: progress,
              size: 100,
              strokeWidth: 10,
              progressColor: effectiveColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: effectiveColor,
                    ),
                  ),
                  Text(
                    'Complete',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Weekly Progress Summary
class WeeklyProgressSummary extends StatelessWidget {
  final List<ExerciseActivity> activities;

  const WeeklyProgressSummary({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final weeklyData = _calculateWeeklyData();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.weeklyProgress,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GoalProgressWidget(
                    title: localizations.workoutGoal,
                    currentValue: weeklyData.workoutsCompleted.toDouble(),
                    targetValue: 4.0,
                    unit: 'workouts',
                    icon: Icons.fitness_center,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GoalProgressWidget(
                    title: localizations.volumeGoal,
                    currentValue: weeklyData.totalVolume,
                    targetValue: 10000.0,
                    unit: 'kg',
                    icon: Icons.bar_chart,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  WeeklyData _calculateWeeklyData() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final weeklyActivities = activities.where((activity) {
      return activity.createdAt.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).toList();

    final workoutsCompleted = weeklyActivities
        .map((a) => a.schedaName)
        .toSet()
        .length;

    final totalVolume = weeklyActivities.fold<double>(0.0, (sum, activity) {
      return sum + activity.sets.fold<double>(0.0, (setSum, set) {
        final weight = double.tryParse(set.weight) ?? 0.0;
        final reps = int.tryParse(set.reps) ?? 0;
        return setSum + (weight * reps);
      });
    });

    return WeeklyData(
      workoutsCompleted: workoutsCompleted,
      totalVolume: totalVolume,
    );
  }
}

// Data classes
class ProgressData {
  final double currentVolume;
  final double volumeProgress;
  final int completedSets;
  final int targetSets;
  final double setsProgress;
  final double intensityProgress;

  ProgressData({
    required this.currentVolume,
    required this.volumeProgress,
    required this.completedSets,
    required this.targetSets,
    required this.setsProgress,
    required this.intensityProgress,
  });
}

class WeeklyData {
  final int workoutsCompleted;
  final double totalVolume;

  WeeklyData({
    required this.workoutsCompleted,
    required this.totalVolume,
  });
}