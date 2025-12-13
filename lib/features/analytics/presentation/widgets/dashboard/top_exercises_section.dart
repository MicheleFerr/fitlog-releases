import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Data model for a top exercise with progressive overload context
class TopExerciseData {
  const TopExerciseData({
    required this.name,
    required this.sessionCount,
    required this.lastWeight,
    required this.lastReps,
    required this.weightDelta,
    required this.measurementUnit,
    this.isPR = false,
  });

  final String name;
  final int sessionCount;
  final double lastWeight;
  final int lastReps;
  final double weightDelta;
  final String measurementUnit;
  final bool isPR;
}

/// Widget showing top exercises with progressive overload context
class TopExercisesSection extends StatelessWidget {
  const TopExercisesSection({
    required this.exercises,
    this.maxVisible = 4,
    this.periodLabel = '7gg',
    this.onExerciseTap,
    this.onSeeAllTap,
    super.key,
  });

  final List<TopExerciseData> exercises;
  final int maxVisible;
  final String periodLabel;
  final void Function(String exerciseName)? onExerciseTap;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    final visibleExercises = exercises.take(maxVisible).toList();
    final hasMore = exercises.length > maxVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                AppIcons.workout,
                size: 20,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.yourExercises,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  periodLabel,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Exercise cards
        ...visibleExercises.map(
          (exercise) => _ExerciseCard(
            exercise: exercise,
            onTap: onExerciseTap != null ? () => onExerciseTap!(exercise.name) : null,
          ),
        ),

        // See all button
        if (hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: onSeeAllTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${context.l10n.seeAll} (${exercises.length}) →',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Individual exercise card showing session count, last set, and weight delta
class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    this.onTap,
  });

  final TopExerciseData exercise;
  final VoidCallback? onTap;

  String _formatWeight(double weight) {
    if (weight == weight.toInt()) {
      return weight.toInt().toString();
    }
    return weight.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.outlineVariant,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise name and PR badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (exercise.isPR)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🏆 PR',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Session count and last set
              Text(
                '${context.l10n.sessionsCount(exercise.sessionCount)} • ${context.l10n.lastSetInfo(_formatWeight(exercise.lastWeight), exercise.measurementUnit, exercise.lastReps)}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              // Weight delta indicator
              _WeightDeltaIndicator(
                weightDelta: exercise.weightDelta,
                measurementUnit: exercise.measurementUnit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Weight delta indicator with colored arrow and text
class _WeightDeltaIndicator extends StatelessWidget {
  const _WeightDeltaIndicator({
    required this.weightDelta,
    required this.measurementUnit,
  });

  final double weightDelta;
  final String measurementUnit;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;
    final String text;

    if (weightDelta > 0) {
      icon = AppIcons.trendUp;
      color = context.colors.success;
      text = '+${weightDelta.toStringAsFixed(1)}$measurementUnit ${context.l10n.vsLastWeek}';
    } else if (weightDelta < 0) {
      icon = AppIcons.trendDown;
      color = context.colors.error;
      text = '${weightDelta.toStringAsFixed(1)}$measurementUnit ${context.l10n.vsLastWeek}';
    } else {
      icon = AppIcons.trendFlat;
      color = context.colors.onSurfaceVariant;
      text = context.l10n.sameWeightDelta;
    }

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: context.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
