import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Trend direction for stat cards
/// (Moved here after enhanced_statistics_dashboard.dart was removed)
enum StatTrend {
  positive,
  negative,
  neutral,
}

/// Enhanced Stat Card with Material 3 styling
class EnhancedStatCard extends StatelessWidget {

  const EnhancedStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.trend,
    required this.subtitle,
    this.onTap,
  });
  final String title;
  final String value;
  final IconData icon;
  final StatTrend trend;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getIconBackgroundColor(colorScheme),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: _getIconColor(colorScheme),
                      size: 24,
                    ),
                  ),
                  _buildTrendIndicator(context, trend),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(BuildContext context, StatTrend trend) {
    IconData trendIcon;
    Color trendColor;

    switch (trend) {
      case StatTrend.positive:
        trendIcon = AppIcons.trendUp;
        trendColor = context.colors.success;
        break;
      case StatTrend.negative:
        trendIcon = AppIcons.trendDown;
        trendColor = context.colors.error;
        break;
      case StatTrend.neutral:
        trendIcon = AppIcons.trendFlat;
        trendColor = context.colors.surfaceContainerHighest;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        trendIcon,
        color: trendColor,
        size: 16,
      ),
    );
  }

  Color _getIconBackgroundColor(ColorScheme colorScheme) {
    return colorScheme.primaryContainer;
  }

  Color _getIconColor(ColorScheme colorScheme) {
    return colorScheme.onPrimaryContainer;
  }
}

/// Exercise Ranking Card showing top performing exercises
class EnhancedExerciseRankingCard extends StatelessWidget {

  const EnhancedExerciseRankingCard({
    super.key,
    required this.activities,
  });
  final List<ExerciseActivity> activities;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final topExercises = _getTopExercises();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.achievement,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.topExercises,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (topExercises.isEmpty)
              _buildEmptyState(context, localizations)
            else
              ...topExercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return _buildExerciseRankItem(
                  context,
                  index + 1,
                  exercise,
                  colorScheme,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseRankItem(
    BuildContext context,
    int rank,
    ExerciseRankData exercise,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank == 1 ? colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(rank, colorScheme),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.totalVolume.toStringAsFixed(0)}kg total volume',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${exercise.frequency}x',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                'performed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            SemanticIcon(
              icon: AppIcons.workout,
              semanticLabel: 'Workout',
              size: AppIconSize.xxlarge,
              color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.noExerciseData,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank, ColorScheme colorScheme) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return colorScheme.primary;
    }
  }

  List<ExerciseRankData> _getTopExercises() {
    final exerciseStats = <String, ExerciseRankData>{};

    for (final activity in activities) {
      final name = activity.exerciseName;
      final volume = activity.sets.fold<double>(0.0, (sum, set) {
        final weight = double.tryParse(set.weight) ?? 0.0;
        final reps = int.tryParse(set.reps) ?? 0;
        return sum + (weight * reps);
      });

      if (exerciseStats.containsKey(name)) {
        exerciseStats[name] = exerciseStats[name]!.copyWith(
          totalVolume: exerciseStats[name]!.totalVolume + volume,
          frequency: exerciseStats[name]!.frequency + 1,
        );
      } else {
        exerciseStats[name] = ExerciseRankData(
          name: name,
          totalVolume: volume,
          frequency: 1,
        );
      }
    }

    return exerciseStats.values.toList()
      ..sort((a, b) => b.totalVolume.compareTo(a.totalVolume))
      ..take(5).toList();
  }
}

/// Streak Card showing workout consistency
class EnhancedStreakCard extends StatelessWidget {

  const EnhancedStreakCard({
    super.key,
    required this.activities,
  });
  final List<ExerciseActivity> activities;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final streakData = _calculateStreak();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.streak,
                  color: context.colors.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.workoutStreak,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStreakDisplay(context, streakData, colorScheme),
            const SizedBox(height: 20),
            _buildStreakCalendar(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakDisplay(
    BuildContext context,
    StreakData streakData,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.secondary.withValues(alpha: 0.2),
            context.colors.error.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStreakStat(
                context,
                '${streakData.currentStreak}',
                'Current Streak',
                AppIcons.streak,
                context.colors.secondary,
              ),
              _buildStreakStat(
                context,
                '${streakData.longestStreak}',
                'Best Streak',
                AppIcons.achievement,
                context.colors.warning,
              ),
              _buildStreakStat(
                context,
                '${streakData.weeklyGoal}/${streakData.weeklyGoalTarget}',
                'Weekly Goal',
                AppIcons.flag,
                context.colors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCalendar(BuildContext context, ColorScheme colorScheme) {
    final workoutDays = _getWorkoutDaysInMonth();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Month',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: 31, // Max days in month
          itemBuilder: (context, index) {
            final day = index + 1;
            final hasWorkout = workoutDays.contains(day);
            final isToday = day == DateTime.now().day;
            
            return DecoratedBox(
              decoration: BoxDecoration(
                color: hasWorkout
                    ? context.colors.success
                    : colorScheme.surfaceContainerLow,
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: colorScheme.primary, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hasWorkout
                        ? context.colors.surface
                        : colorScheme.onSurfaceVariant,
                    fontWeight: hasWorkout ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  StreakData _calculateStreak() {
    final workoutDates = activities
        .map((a) => DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day))
        .toSet()
        .toList()
      ..sort();

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    // Calculate current streak
    DateTime checkDate = today;
    while (workoutDates.contains(DateTime(checkDate.year, checkDate.month, checkDate.day))) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // If no workout today, check if there was one yesterday
    if (currentStreak == 0 && workoutDates.contains(DateTime(yesterday.year, yesterday.month, yesterday.day))) {
      checkDate = yesterday;
      while (workoutDates.contains(DateTime(checkDate.year, checkDate.month, checkDate.day))) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    // Calculate longest streak
    for (int i = 0; i < workoutDates.length; i++) {
      if (i == 0 || workoutDates[i].difference(workoutDates[i - 1]).inDays == 1) {
        tempStreak++;
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    // Calculate weekly goal progress
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final weeklyWorkouts = workoutDates
        .where((date) => date.isAfter(thisWeekStart.subtract(const Duration(days: 1))))
        .length;

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      weeklyGoal: weeklyWorkouts,
      weeklyGoalTarget: 4, // Default goal of 4 workouts per week
    );
  }

  Set<int> _getWorkoutDaysInMonth() {
    final now = DateTime.now();
    return activities
        .where((activity) =>
            activity.createdAt.year == now.year &&
            activity.createdAt.month == now.month)
        .map((activity) => activity.createdAt.day)
        .toSet();
  }
}

// Data classes
class ExerciseRankData {

  ExerciseRankData({
    required this.name,
    required this.totalVolume,
    required this.frequency,
  });
  final String name;
  final double totalVolume;
  final int frequency;

  ExerciseRankData copyWith({
    String? name,
    double? totalVolume,
    int? frequency,
  }) {
    return ExerciseRankData(
      name: name ?? this.name,
      totalVolume: totalVolume ?? this.totalVolume,
      frequency: frequency ?? this.frequency,
    );
  }
}

class StreakData {

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyGoal,
    required this.weeklyGoalTarget,
  });
  final int currentStreak;
  final int longestStreak;
  final int weeklyGoal;
  final int weeklyGoalTarget;
}
