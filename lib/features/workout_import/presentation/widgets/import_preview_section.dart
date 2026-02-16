/// Import Preview Section
///
/// Shows the parsed workout preview with day grouping,
/// exercise cards, and a create button.
///
/// **Layer**: Presentation - Widget
/// **Feature**: Workout Import
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout_import/domain/entities/parsed_workout.dart';
import 'package:gymbro_flutter_new/features/workout_import/presentation/providers/workout_import_provider.dart';
import 'package:gymbro_flutter_new/features/workout_import/presentation/widgets/exercise_match_picker.dart';
import 'package:gymbro_flutter_new/features/workout_import/presentation/widgets/parsed_exercise_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ImportPreviewSection extends ConsumerWidget {
  const ImportPreviewSection({
    required this.workout,
    required this.onCreateTemplates,
    super.key,
  });

  final ParsedWorkout workout;
  final VoidCallback onCreateTemplates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    final totalExercises = workout.days.fold<int>(
      0,
      (sum, day) => sum + day.exercises.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                AppIcons.check,
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.workoutImportPreviewTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      workout.hasMultipleDays
                          ? l10n.workoutImportDaysFound(workout.days.length)
                          : l10n.workoutImportExercisesFound(totalExercises),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Exercise list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: workout.days.length,
            itemBuilder: (context, dayIndex) {
              final day = workout.days[dayIndex];
              return _buildDaySection(context, ref, day, dayIndex);
            },
          ),
        ),

        // Create button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onCreateTemplates,
              icon: const Icon(AppIcons.check),
              label: Text(
                workout.hasMultipleDays
                    ? l10n.workoutImportCreateTemplates
                    : l10n.workoutImportCreateSingleTemplate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySection(
    BuildContext context,
    WidgetRef ref,
    ParsedDay day,
    int dayIndex,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (workout.hasMultipleDays) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              day.name,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.primary,
              ),
            ),
          ),
        ],
        ...day.exercises.asMap().entries.map((entry) {
          final exerciseIndex = entry.key;
          final exercise = entry.value;

          return ParsedExerciseCard(
            exercise: exercise,
            onChangeExercise: () => _showExercisePicker(
              context,
              ref,
              exercise,
              dayIndex,
              exerciseIndex,
            ),
          );
        }),
      ],
    );
  }

  Future<void> _showExercisePicker(
    BuildContext context,
    WidgetRef ref,
    ParsedExerciseLine exercise,
    int dayIndex,
    int exerciseIndex,
  ) async {
    final result = await ModalService.showSheet<ExercisePickResult>(
      context,
      isScrollControlled: true,
      builder: (context) => ExerciseMatchPicker(
        initialQuery: exercise.rawName,
      ),
    );

    if (result != null) {
      ref.read(workoutImportProvider.notifier).updateExerciseMatch(
            dayIndex: dayIndex,
            exerciseIndex: exerciseIndex,
            exerciseId: result.exerciseId,
            exerciseName: result.exerciseName,
            category: ExerciseCategory.other, // Will be inferred from DB
          );
    }
  }
}
