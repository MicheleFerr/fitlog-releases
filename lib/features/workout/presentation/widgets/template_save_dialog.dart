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
import 'package:flutter/services.dart';
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
  saveAsNew,
  keepOriginal,
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
/// Returns [TemplateSaveResult] with the user's choice, or null if dismissed
Future<TemplateSaveResult?> showTemplateSaveDialog({
  required BuildContext context,
  required Workout completedWorkout,
  required WorkoutTemplate originalTemplate,
}) {
  return showModalBottomSheet<TemplateSaveResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TemplateSaveDialogContent(
      completedWorkout: completedWorkout,
      originalTemplate: originalTemplate,
    ),
  );
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
  TemplateSaveOption _selectedOption = TemplateSaveOption.keepOriginal;
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = '${widget.originalTemplate.name} (2)';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changes = _detectChanges();

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SemanticIcon(
                    icon: AppIcons.save,
                    semanticLabel: context.l10n.saveTemplate,
                    size: AppIconSize.large,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.saveTemplateChanges,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.workoutModifiedFromTemplate(
                    widget.originalTemplate.name,
                  ),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Changes summary
          if (changes.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.changesDetected,
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...changes.map(
                    (change) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          SemanticIcon(
                            icon: AppIcons.checkCircle,
                            semanticLabel: change,
                            size: AppIconSize.tiny,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              change,
                              style: context.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                _buildOptionTile(
                  option: TemplateSaveOption.updateTemplate,
                  icon: AppIcons.edit,
                  title: context.l10n.updateTemplate,
                  subtitle: context.l10n.updateTemplateDescription,
                ),
                const SizedBox(height: 8),
                _buildOptionTile(
                  option: TemplateSaveOption.saveAsNew,
                  icon: AppIcons.add,
                  title: context.l10n.saveAsNewTemplate,
                  subtitle: context.l10n.saveAsNewTemplateDescription,
                ),
                const SizedBox(height: 8),
                _buildOptionTile(
                  option: TemplateSaveOption.keepOriginal,
                  icon: AppIcons.close,
                  title: context.l10n.keepOriginal,
                  subtitle: context.l10n.keepOriginalDescription,
                ),
              ],
            ),
          ),

          // New template name field (only when saveAsNew is selected)
          if (_selectedOption == TemplateSaveOption.saveAsNew)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.templateName,
                  hintText: context.l10n.enterTemplateName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: SemanticIcon(
                    icon: AppIcons.listAlt,
                    semanticLabel: context.l10n.templateName,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(context.l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _handleConfirm,
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.colors.onPrimary,
                            ),
                          )
                        : Text(context.l10n.confirm),
                  ),
                ),
              ],
            ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required TemplateSaveOption option,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedOption == option;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          safeSetState(() => _selectedOption = option);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.primary.withValues(alpha: 0.1)
                : context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? context.colors.primary
                  : context.colors.outlineVariant.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary.withValues(alpha: 0.2)
                      : context.colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SemanticIcon(
                  icon: icon,
                  semanticLabel: title,
                  size: AppIconSize.medium,
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                SemanticIcon(
                  icon: AppIcons.checkCircle,
                  semanticLabel: context.l10n.selected,
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
            ],
          ),
        ),
      ),
    );
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

  Future<void> _handleConfirm() async {
    safeSetState(() => _isLoading = true);

    try {
      switch (_selectedOption) {
        case TemplateSaveOption.updateTemplate:
          await _updateTemplate();
          break;
        case TemplateSaveOption.saveAsNew:
          await _saveAsNewTemplate();
          break;
        case TemplateSaveOption.keepOriginal:
          // Nothing to do - just close
          break;
      }

      if (mounted) {
        Navigator.pop(
          context,
          TemplateSaveResult(
            option: _selectedOption,
            newTemplateName: _selectedOption == TemplateSaveOption.saveAsNew
                ? _nameController.text
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          context.l10n.failedToSaveTemplate,
        );
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isLoading = false);
      }
    }
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

  Future<void> _saveAsNewTemplate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      SnackBarService.showError(context, context.l10n.pleaseEnterTemplateName);
      return;
    }

    await ref.read(workoutTemplateNotifierProvider.notifier).createTemplateFromWorkout(
      name: name,
      description: '', // Empty description for now
      exercises: widget.completedWorkout.exercises,
    );

    if (mounted) {
      SnackBarService.showSuccess(
        context,
        context.l10n.templateCreated,
      );
    }
  }
}
