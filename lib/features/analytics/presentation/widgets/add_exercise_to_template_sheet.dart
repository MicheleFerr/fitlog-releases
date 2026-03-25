/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// Add Exercise to Template Sheet - Bottom sheet for selecting template to add exercise
///
/// **Design Research**:
/// - DraggableScrollableSheet with snap behavior
/// - Lists user's workout templates
/// - Adds suggested exercise to selected template
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_recommendation_service.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/utils/template_error_localizer.dart';

/// Add Exercise to Template Sheet
///
/// Shows user's workout templates and allows adding the suggested exercise
/// to a selected template.
///
/// **Usage**:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (context) => AddExerciseToTemplateSheet(
///     suggestion: suggestion,
///     onExerciseAdded: () => Navigator.pop(context),
///   ),
/// );
/// ```
class AddExerciseToTemplateSheet extends ConsumerStatefulWidget {
  const AddExerciseToTemplateSheet({
    required this.suggestion,
    required this.onExerciseAdded,
    super.key,
  });

  final ExerciseSuggestion suggestion;
  final VoidCallback onExerciseAdded;

  @override
  ConsumerState<AddExerciseToTemplateSheet> createState() =>
      _AddExerciseToTemplateSheetState();
}

class _AddExerciseToTemplateSheetState
    extends ConsumerState<AddExerciseToTemplateSheet> {
  bool _isAdding = false;
  String? _selectedTemplateId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.9);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: safeMax,
      snap: true,
      snapSizes: [0.4, 0.6, safeMax],
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              _buildDragHandle(context),
              // Header
              _buildHeader(context),
              // Content
              Expanded(
                child: templatesAsync.when(
                  loading: () => const Center(child: LoadingIndicator()),
                  error: (error, _) => Center(
                    child: Text(
                      l10n.errorLoadingTemplates,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                  data: (templates) {
                    if (templates.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return _buildTemplateList(
                      context,
                      templates,
                      scrollController,
                    );
                  },
                ),
              ),
              // Add button
              if (_selectedTemplateId != null) _buildAddButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    final colorScheme = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
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
                  AppIcons.fitnessCenter,
                  color: colorScheme.onPrimaryContainer,
                  size: AppIconSize.medium,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.addToTemplate,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.suggestion.exerciseName,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(AppIcons.close),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.selectTemplateToAddExercise,
            style: context.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.folderOutlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTemplatesFound,
              style: context.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createTemplateFirst,
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateList(
    BuildContext context,
    List<WorkoutTemplate> templates,
    ScrollController scrollController,
  ) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = _selectedTemplateId == template.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedTemplateId = template.id;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Template icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIcons.assignment,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      size: AppIconSize.medium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Template info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.exerciseCount(template.exercises.length),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Selection indicator
                  if (isSelected)
                    Icon(
                      AppIcons.checkCircle,
                      color: colorScheme.primary,
                      size: AppIconSize.medium,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isAdding ? null : _addExerciseToTemplate,
            icon: _isAdding
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: LoadingIndicator(),
                  )
                : const Icon(AppIcons.add),
            label: Text(_isAdding ? l10n.adding : l10n.addExerciseToTemplate),
          ),
        ),
      ),
    );
  }

  Future<void> _addExerciseToTemplate() async {
    if (_selectedTemplateId == null || _isAdding) return;

    setState(() => _isAdding = true);

    try {
      // Get the selected template
      final templates = await ref.read(customWorkoutTemplatesProvider.future);
      final selectedTemplate = templates.firstWhere(
        (t) => t.id == _selectedTemplateId,
      );

      // Calculate personalized volume based on user questionnaire
      final questionnaire = ref.read(userFitnessQuestionnaireProvider);
      const volumeService = VolumeRecommendationService();

      final VolumeRecommendation volume;
      if (questionnaire != null) {
        // Use personalized calculation
        volume = volumeService.calculate(
          experience: questionnaire.experienceLevel,
          goal: questionnaire.trainingGoal,
          hasInjuryHistory: questionnaire.hasInjuryHistory,
        );
      } else {
        // Fallback to default values
        volume = volumeService.calculateDefault();
      }

      // Create sets based on calculated volume
      final sets = List.generate(
        volume.sets,
        (index) => SetTemplate(setNumber: index + 1, targetReps: volume.reps),
      );

      // Create ExerciseTemplate from suggestion with personalized volume
      // Use the real exerciseId and countingMode from the database
      final newExercise = ExerciseTemplate(
        exerciseId: widget.suggestion.exerciseId,
        exerciseName: widget.suggestion.exerciseName,
        category: _mapMuscleToCategory(widget.suggestion.targetMuscle),
        type: ExerciseType.single,
        sets: sets,
        restTime: volume.restSeconds,
        countingMode: widget.suggestion.countingMode,
      );

      final repository = ref.read(workoutTemplateRepositoryProvider);
      final editableTemplate = await repository.ensureEditableTemplate(
        selectedTemplate,
      );

      // Add exercise to template or to a newly-created private draft.
      final updatedExercises = [...editableTemplate.exercises, newExercise];
      final updatedTemplate = editableTemplate.copyWith(
        exercises: updatedExercises,
        updatedAt: DateTime.now(),
      );

      // Save template
      await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .saveTemplate(updatedTemplate);

      // Notify success
      await HapticFeedback.mediumImpact();
      widget.onExerciseAdded();

      if (mounted) {
        if (editableTemplate.id != selectedTemplate.id) {
          SnackBarService.showInfo(
            context,
            context.l10n.templatePrivateDraftCreated(selectedTemplate.name),
          );
        }
        Navigator.of(context).pop();

        // Show success snackbar with personalized volume details
        final l10n = context.l10n;
        SnackBarService.showSuccess(
          context,
          l10n.exerciseAddedWithVolume(
            widget.suggestion.exerciseName,
            volume.sets,
            volume.reps,
            volume.restSeconds,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          localizeTemplateErrorMessage(context, e),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  /// Maps muscle name to ExerciseCategory
  ExerciseCategory _mapMuscleToCategory(String muscleName) {
    final lowerMuscle = muscleName.toLowerCase();

    // Chest muscles
    if (lowerMuscle.contains('chest') || lowerMuscle.contains('pec')) {
      return ExerciseCategory.chest;
    }

    // Back muscles
    if (lowerMuscle.contains('back') ||
        lowerMuscle.contains('lat') ||
        lowerMuscle.contains('trap') ||
        lowerMuscle.contains('rhomboid') ||
        lowerMuscle.contains('erector')) {
      return ExerciseCategory.back;
    }

    // Shoulder muscles
    if (lowerMuscle.contains('shoulder') ||
        lowerMuscle.contains('delt') ||
        lowerMuscle.contains('rear delt')) {
      return ExerciseCategory.shoulders;
    }

    // Arm muscles
    if (lowerMuscle.contains('bicep') ||
        lowerMuscle.contains('tricep') ||
        lowerMuscle.contains('forearm') ||
        lowerMuscle.contains('arm')) {
      return ExerciseCategory.arms;
    }

    // Leg muscles
    if (lowerMuscle.contains('quad') ||
        lowerMuscle.contains('hamstring') ||
        lowerMuscle.contains('glute') ||
        lowerMuscle.contains('calf') ||
        lowerMuscle.contains('leg')) {
      return ExerciseCategory.legs;
    }

    // Core muscles
    if (lowerMuscle.contains('ab') ||
        lowerMuscle.contains('core') ||
        lowerMuscle.contains('oblique')) {
      return ExerciseCategory.abs;
    }

    return ExerciseCategory.other;
  }
}
