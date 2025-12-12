/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// Template Save Dialog - Shown after completing a workout that was started from a template
/// Allows user to: Update template, Save as new, or Keep original
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/mixins/safe_set_state_mixin.dart';

/// Dialog options for template save
enum TemplateSaveOption {
  updateTemplate,
  discardChanges,
}

/// Result from the template save dialog
class TemplateSaveResult {
  const TemplateSaveResult({
    required this.option,
    this.newTemplateName,
  });

  final TemplateSaveOption option;
  final String? newTemplateName;
}

/// Shows a dialog after workout completion to let user choose template save option
///
/// Returns [TemplateSaveResult] with the user's choice
///
/// Close behavior: When dismissed without explicit choice, defaults to save changes
/// to prevent accidental data loss.
Future<TemplateSaveResult?> showTemplateSaveDialog({
  required BuildContext context,
  required Workout completedWorkout,
  required WorkoutTemplate originalTemplate,
}) async {
  final result = await showModalBottomSheet<TemplateSaveResult>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TemplateSaveDialogContent(
      completedWorkout: completedWorkout,
      originalTemplate: originalTemplate,
    ),
  );

  // If dismissed without choice (swipe to close), default to update template
  // to prevent accidental data loss
  return result ?? const TemplateSaveResult(option: TemplateSaveOption.updateTemplate);
}

class _TemplateSaveDialogContent extends ConsumerStatefulWidget {
  const _TemplateSaveDialogContent({
    required this.completedWorkout,
    required this.originalTemplate,
  });

  final Workout completedWorkout;
  final WorkoutTemplate originalTemplate;

  @override
  ConsumerState<_TemplateSaveDialogContent> createState() =>
      _TemplateSaveDialogContentState();
}

class _TemplateSaveDialogContentState
    extends ConsumerState<_TemplateSaveDialogContent>
    with SafeSetStateMixin {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final changes = _detectChanges();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Compact header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SemanticIcon(
                  icon: AppIcons.save,
                  semanticLabel: context.l10n.saveTemplate,
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.saveTemplateChanges,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.originalTemplate.name,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Compact changes summary
          if (changes.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.info,
                    semanticLabel: context.l10n.changesDetected,
                    size: AppIconSize.small,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      changes.join(' • '),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Two clear action buttons
          FilledButton.icon(
            onPressed: _isLoading ? null : () => _handleChoice(TemplateSaveOption.updateTemplate),
            icon: _isLoading
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.onPrimary,
                    ),
                  )
                : SemanticIcon(
                    icon: AppIcons.save,
                    semanticLabel: context.l10n.updateTemplate,
                    size: AppIconSize.small,
                    color: context.colors.onPrimary,
                  ),
            label: Text(context.l10n.updateTemplate),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),

          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _handleChoice(TemplateSaveOption.discardChanges),
            icon: SemanticIcon(
              icon: AppIcons.close,
              semanticLabel: context.l10n.keepOriginal,
              size: AppIconSize.small,
              color: context.colors.onSurfaceVariant,
            ),
            label: Text(context.l10n.keepOriginal),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: context.colors.onSurfaceVariant,
            ),
          ),

          // Hint about swipe behavior
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              context.l10n.swipeDownToSave,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Future<void> _handleChoice(TemplateSaveOption option) async {
    if (option == TemplateSaveOption.discardChanges) {
      // Discard - just close without saving
      Navigator.pop(
        context,
        const TemplateSaveResult(option: TemplateSaveOption.discardChanges),
      );
      return;
    }

    // Save changes
    safeSetState(() => _isLoading = true);

    try {
      await _updateTemplate();
      if (mounted) {
        Navigator.pop(
          context,
          const TemplateSaveResult(option: TemplateSaveOption.updateTemplate),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          context.l10n.failedToSaveTemplate,
        );
        safeSetState(() => _isLoading = false);
      }
    }
  }

  List<String> _detectChanges() {
    final changes = <String>[];
    final original = widget.originalTemplate;
    final completed = widget.completedWorkout;

    // Check exercise count
    final originalExerciseCount = original.exercises.length;
    final completedExerciseCount = completed.exercises.length;

    if (completedExerciseCount > originalExerciseCount) {
      changes.add(context.l10n.exercisesAdded(
        completedExerciseCount - originalExerciseCount,
      ));
    } else if (completedExerciseCount < originalExerciseCount) {
      changes.add(context.l10n.exercisesRemoved(
        originalExerciseCount - completedExerciseCount,
      ));
    }

    // Check for modified exercises (different names or set counts)
    final originalNames = original.exercises.map((e) => e.exerciseName).toSet();
    final completedNames = completed.exercises.map((e) => e.name).toSet();

    final addedNames = completedNames.difference(originalNames);
    final removedNames = originalNames.difference(completedNames);

    if (addedNames.isNotEmpty && changes.isEmpty) {
      changes.add(context.l10n.newExercisesAdded);
    }
    if (removedNames.isNotEmpty && changes.length < 2) {
      changes.add(context.l10n.exercisesReplaced);
    }

    // Check set count changes
    int totalOriginalSets = 0;
    int totalCompletedSets = 0;

    for (final ex in original.exercises) {
      totalOriginalSets += ex.sets.length;
    }
    for (final ex in completed.exercises) {
      totalCompletedSets += ex.sets.length;
    }

    if (totalCompletedSets != totalOriginalSets) {
      changes.add(context.l10n.setCountChanged);
    }

    return changes;
  }

  Future<void> _updateTemplate() async {
    final updatedTemplate = widget.originalTemplate.copyWith(
      exercises: widget.completedWorkout.exercises.map((ex) {
        // Generate exerciseId from exercise name (lowercase, snake_case)
        final exerciseId = ex.name.toLowerCase().replaceAll(' ', '_');
        return ExerciseTemplate(
          exerciseId: exerciseId,
          exerciseName: ex.name,
          type: ex.type,
          category: ex.category,
          sets: ex.sets.map((set) {
            return SetTemplate(
              setNumber: set.setNumber,
              targetReps: set.reps,
              targetWeight: set.weight,
            );
          }).toList(),
        );
      }).toList(),
      updatedAt: DateTime.now(),
    );

    await ref
        .read(workoutTemplateNotifierProvider.notifier)
        .saveTemplate(updatedTemplate);

    if (mounted) {
      SnackBarService.showSuccess(
        context,
        context.l10n.templateUpdated,
      );
    }
  }
}
