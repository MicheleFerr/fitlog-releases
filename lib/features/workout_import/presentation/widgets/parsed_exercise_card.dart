/// Parsed Exercise Card
///
/// Displays a single parsed exercise with match badge,
/// set info, and change button.
///
/// **Layer**: Presentation - Widget
/// **Feature**: Workout Import
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout_import/domain/entities/parsed_workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ParsedExerciseCard extends StatelessWidget {
  const ParsedExerciseCard({
    required this.exercise,
    required this.onChangeExercise,
    super.key,
  });

  final ParsedExerciseLine exercise;
  final VoidCallback onChangeExercise;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final matchLevel = exercise.matchLevel;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _borderColor(context, matchLevel),
          width: matchLevel == MatchLevel.none ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name + badge row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.matchedExerciseName ?? exercise.rawName,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (exercise.matchedExerciseName != null &&
                        exercise.matchedExerciseName != exercise.rawName)
                      Text(
                        exercise.rawName,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildBadge(context, matchLevel, l10n),
            ],
          ),
          const SizedBox(height: 8),
          // Sets info row
          Row(
            children: [
              Icon(
                AppIcons.workout,
                size: AppIconSize.tiny,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                _buildSetsDescription(exercise.sets, l10n),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              // Change button
              TextButton.icon(
                onPressed: onChangeExercise,
                icon: Icon(
                  AppIcons.edit,
                  size: AppIconSize.tiny,
                  color: context.colors.primary,
                ),
                label: Text(
                  l10n.workoutImportChangeExercise,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _borderColor(BuildContext context, MatchLevel level) {
    return switch (level) {
      MatchLevel.confident => context.colors.primary.withValues(alpha: 0.4),
      MatchLevel.suggested => context.colors.warning.withValues(alpha: 0.4),
      MatchLevel.none => context.colors.outline.withValues(alpha: 0.2),
    };
  }

  Widget _buildBadge(
    BuildContext context,
    MatchLevel level,
    dynamic l10n,
  ) {
    final (color, text, icon) = switch (level) {
      MatchLevel.confident => (
          context.colors.primary,
          l10n.workoutImportConfidentMatch as String,
          AppIcons.check,
        ),
      MatchLevel.suggested => (
          context.colors.warning,
          l10n.workoutImportSuggestedMatch as String,
          AppIcons.info,
        ),
      MatchLevel.none => (
          context.colors.error,
          l10n.workoutImportNoMatch as String,
          AppIcons.warning,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.tiny, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _buildSetsDescription(List<ParsedSet> sets, dynamic l10n) {
    if (sets.isEmpty) return '';

    final count = sets.length;
    final firstSet = sets.first;

    final parts = <String>[l10n.workoutImportSets(count) as String];

    if (firstSet.isMaxReps) {
      parts.add(l10n.workoutImportMaxReps as String);
    } else if (firstSet.reps != null) {
      parts.add(l10n.workoutImportReps(firstSet.reps!) as String);
    } else if (firstSet.minReps != null && firstSet.maxReps != null) {
      parts.add('${firstSet.minReps}-${firstSet.maxReps} reps');
    }

    if (firstSet.weight != null && firstSet.weight! > 0) {
      final weightStr = firstSet.weight! == firstSet.weight!.roundToDouble()
          ? firstSet.weight!.toInt().toString()
          : firstSet.weight!.toStringAsFixed(1);
      parts.add(l10n.workoutImportKg(weightStr) as String);
    }

    return parts.join(' - ');
  }
}
