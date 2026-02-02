/// Coach Template Editor Screen
///
/// Screen for creating or editing coach templates.
/// Supports:
/// - Template name and description
/// - Estimated duration
/// - Difficulty level
/// - Tags
/// - Exercise list with reordering
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_template.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/providers/coach_providers.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/draggable_action_button.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Screen for creating/editing coach templates
class CoachTemplateEditorScreen extends ConsumerStatefulWidget {
  const CoachTemplateEditorScreen({this.template, super.key});

  /// Template to edit (null for creating new)
  final CoachTemplate? template;

  @override
  ConsumerState<CoachTemplateEditorScreen> createState() =>
      _CoachTemplateEditorScreenState();
}

class _CoachTemplateEditorScreenState
    extends ConsumerState<CoachTemplateEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late List<ExerciseTemplate> _exercises;
  late int _estimatedDuration;
  late List<String> _tags;
  String? _difficulty;
  bool _isLoading = false;
  bool _hasChanges = false;

  bool get _isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    _nameController = TextEditingController(text: template?.name ?? '');
    _descriptionController = TextEditingController(
      text: template?.description ?? '',
    );
    _notesController = TextEditingController(text: template?.coachNotes ?? '');
    _exercises = List.from(template?.exercises ?? []);
    _estimatedDuration = template?.estimatedDuration ?? 45;
    _tags = List.from(template?.tags ?? []);
    _difficulty = template?.difficulty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasChanges) {
          _showDiscardChangesDialog();
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          title: Text(
            _isEditing ? context.l10n.edit : context.l10n.newTemplate,
          ),
          actions: [
            if (_hasChanges || !_isEditing)
              // Accessibility: Save button with semantic label
              Semantics(
                label: context.l10n.save,
                button: true,
                enabled: !_isLoading,
                child: TextButton(
                  onPressed: _isLoading ? null : _saveTemplate,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: LoadingIndicator(),
                        )
                      : Text(context.l10n.save),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Template name
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.templateNameLabel,
                      hintText: context.l10n.templateNameHint,
                      border: const OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => _markAsChanged(),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Description
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: context.l10n.templateDescriptionOptional,
                      hintText: context.l10n.templateDescriptionHint,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => _markAsChanged(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Duration slider
                  _buildDurationSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Difficulty selector
                  _buildDifficultySection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Tags
                  _buildTagsSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Coach notes
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: context.l10n.coachNotes,
                      hintText: context.l10n.coachNotesHint,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (_) => _markAsChanged(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Exercises section
                  _buildExercisesSection(),

                  // Bottom padding for FAB
                  const SizedBox(height: 100),
                ],
              ),
            ),
            // DraggableActionButton for consistent FAB style
            DraggableActionButton(
              onPressed: _showAddExercise,
              icon: AppIcons.add,
              label: context.l10n.addExercise,
              positionKey: 'coach_template_editor',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.duration,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_estimatedDuration min',
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Slider(
          value: _estimatedDuration.toDouble(),
          min: 15,
          max: 120,
          divisions: 21,
          label: '$_estimatedDuration min',
          onChanged: (value) {
            setState(() => _estimatedDuration = value.toInt());
            _markAsChanged();
          },
        ),
      ],
    );
  }

  Widget _buildDifficultySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.difficulty,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<String?>(
          segments: [
            ButtonSegment(
              value: 'beginner',
              label: Text(context.l10n.beginner),
              icon: const Icon(AppIcons.accessibility, size: 18),
            ),
            ButtonSegment(
              value: 'intermediate',
              label: Text(context.l10n.intermediate),
              icon: const Icon(AppIcons.workout, size: 18),
            ),
            ButtonSegment(
              value: 'advanced',
              label: Text(context.l10n.advanced),
              icon: const Icon(AppIcons.whatshot, size: 18),
            ),
          ],
          selected: _difficulty != null ? {_difficulty} : {},
          emptySelectionAllowed: true,
          onSelectionChanged: (selection) {
            setState(() => _difficulty = selection.firstOrNull);
            _markAsChanged();
          },
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    final availableTags = [
      'push',
      'pull',
      'legs',
      'upper',
      'lower',
      'full-body',
      'cardio',
      'strength',
      'hypertrophy',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.tags,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: availableTags.map((tag) {
            final isSelected = _tags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _tags.add(tag);
                  } else {
                    _tags.remove(tag);
                  }
                });
                _markAsChanged();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExercisesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.exercises,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_exercises.length}',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        if (_exercises.isEmpty)
          _buildEmptyExercisesState()
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exercises.length,
            onReorder: _reorderExercises,
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) => _buildExerciseCard(index),
          ),
      ],
    );
  }

  Widget _buildEmptyExercisesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.fitnessCenterOutlined,
            size: 48,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.noExercisesYet,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.tapToAddExercise,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int index) {
    final exercise = _exercises[index];

    return Padding(
      key: Key('exercise_$index'),
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: Key('dismissible_$index'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: context.colors.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(AppIcons.delete, color: context.colors.onError),
        ),
        onDismissed: (_) {
          setState(() => _exercises.removeAt(index));
          _markAsChanged();
        },
        child: Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: ReorderableDragStartListener(
              index: index,
              child: Icon(
                AppIcons.dragHandle,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            title: Text(
              exercise.exerciseName,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              _formatExerciseSubtitle(exercise),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(AppIcons.edit),
              onPressed: () => _editExercise(index),
              visualDensity: VisualDensity.compact,
              tooltip: context.l10n.edit,
            ),
          ),
        ),
      ),
    );
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final exercise = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, exercise);
    });
    _markAsChanged();
  }

  Future<void> _showAddExercise() async {
    final result = await showModalBottomSheet<ExerciseTemplate>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddExerciseModal(),
    );

    if (result != null && mounted) {
      setState(() => _exercises.add(result));
      _markAsChanged();
    }
  }

  Future<void> _editExercise(int index) async {
    // For now, just show a snackbar indicating edit is not yet implemented
    // TODO: Implement exercise editing with a dedicated modal
    SnackBarService.showInfo(context, 'Edit exercise coming soon');
  }

  String _formatExerciseSubtitle(ExerciseTemplate exercise) {
    final sets = exercise.sets;
    if (sets.isEmpty) return '—';

    final setsCount = sets.length;
    final firstSet = sets.first;
    final reps = firstSet.targetReps ?? 0;
    final rest = exercise.restTime ?? 60;

    return '$setsCount x $reps • ${rest}s rest';
  }

  Future<void> _showDiscardChangesDialog() async {
    final discard = await ModalService.showConfirmDialog(
      context,
      title: context.l10n.discardChanges,
      message: context.l10n.discardChangesMessage,
      isDangerous: true,
    );

    if (discard == true && mounted) {
      context.pop();
    }
  }

  Future<void> _saveTemplate() async {
    // Validate
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      SnackBarService.showError(context, context.l10n.templateNameRequired);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final actions = ref.read(coachTemplateActionsProvider.notifier);
      final now = DateTime.now();

      if (_isEditing) {
        // Update existing
        final updated = widget.template!.copyWith(
          name: name,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          exercises: _exercises,
          estimatedDuration: _estimatedDuration,
          tags: _tags,
          difficulty: _difficulty,
          coachNotes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          updatedAt: now,
        );
        await actions.updateTemplate(updated);

        if (mounted) {
          SnackBarService.showSuccess(context, context.l10n.templateSaved);
          context.pop();
        }
      } else {
        // Create new
        final newTemplate = CoachTemplate(
          id: '', // Will be assigned by Firestore
          coachId: '', // Will be set by provider
          name: name,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          exercises: _exercises,
          estimatedDuration: _estimatedDuration,
          tags: _tags,
          difficulty: _difficulty,
          coachNotes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );

        final id = await actions.createTemplate(newTemplate);
        if (id != null && mounted) {
          SnackBarService.showSuccess(context, context.l10n.templateCreated);
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, '${context.l10n.error}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
