
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/reps_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rest_time_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/weight_picker_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/template_view_screen.dart';

class EditTemplateScreen extends ConsumerStatefulWidget {

  const EditTemplateScreen({
    super.key,
    required this.template,
  });
  final WorkoutTemplate template;

  @override
  ConsumerState<EditTemplateScreen> createState() => _EditTemplateScreenState();
}

class _EditTemplateScreenState extends ConsumerState<EditTemplateScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<ExerciseTemplate> _exercises;
  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isPublic = false;

  // Track which exercises are expanded
  final Map<int, bool> _expandedExercises = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template.name);
    _descriptionController =
        TextEditingController(text: widget.template.description);
    _exercises = List.from(widget.template.exercises);
    _isPublic = widget.template.isPublic;

    // Start first exercise expanded for immediate feedback
    if (_exercises.isNotEmpty) {
      _expandedExercises[0] = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
        appBar: AppBar(
          title: Text(context.l10n.edit),
          actions: [
            // View mode button (presentation mode)
            IconButton(
              onPressed: _navigateToViewMode,
              icon: const SemanticIcon(
                icon: AppIcons.visibility,
                semanticLabel: 'View mode',
                size: AppIconSize.medium,
              ),
              tooltip: context.l10n.templateViewMode,
            ),
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveTemplate,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: LoadingIndicator(),
                      )
                    : Text(context.l10n.save),
              ),
          ],
        ),
        body: Column(
          children: [
            // Header con info template
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.templateName,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => _markAsChanged(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: context.l10n.description,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (_) => _markAsChanged(),
                  ),
                  const SizedBox(height: 12),
                  // Toggle pubblico/privato
                  /* Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isPublic ? AppIcons.public : AppIcons.lock,
                                size: 20,
                                color: _isPublic
                                    ? context.colors.primary
                                    : context.colors.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                              SizedBox(width: 8),
                              Text(
                                _isPublic
                                    ? 'Template Pubblico'
                                    : 'Template Privato',
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: _isPublic,
                                onChanged: (value) {
                                  setState(() {
                                    _isPublic = value;
                                  });
                                  _markAsChanged();
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            _isPublic
                                ? 'Altri utenti potranno trovare e utilizzare questo template'
                                : 'Solo tu puoi vedere e utilizzare questo template',
                            style: context.textTheme.bodySmall?.copyWith(
                              color:
                                  context.colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          if (_isPublic) ...[
                            SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.colors.primaryContainer
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: context.colors.primary
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SemanticIcon(
  icon: AppIcons.info,
  semanticLabel: 'Information',
  size: AppIconSize.tiny,
  color: context.colors.primary,
),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Assicurati che il template sia completo e ben descritto',
                                      style: context.textTheme.labelSmall?.copyWith(
                                        color:
                                            context.colors.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ), */
                ],
              ),
            ),

            // Lista esercizi con riordinamento
            Expanded(
              child: _exercises.isEmpty
                  ? _buildEmptyState()
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _exercises.length,
                      onReorder: _reorderExercises,
                      buildDefaultDragHandles: false,
                      itemBuilder: (context, index) {
                        return _buildExerciseCard(context, index);
                      },
                    ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddExercise,
          child: const SemanticIcon(
  icon: AppIcons.add,
  semanticLabel: 'Add',
),
        ),

      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
  icon: AppIcons.fitnessCenterOutlined,
  semanticLabel: 'Fitness center outlined',
  size: AppIconSize.medium,
  color: context.colors.onSurface.withValues(alpha: 0.3,
),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noExercisesYet,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tapToAddExercise,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showAddExercise,
            icon: const SemanticIcon(
  icon: AppIcons.add,
  semanticLabel: 'Add',
),
            label: Text(context.l10n.addExercise),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, int index) {
    final exerciseTemplate = _exercises[index];
    final isExpanded = _expandedExercises[index] ?? false;

    return Padding(
      key: Key('exercise_$index'),
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key('dismissible_exercise_$index'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: context.colors.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.delete, color: context.colors.surface, size: 28),
              const SizedBox(height: 4),
              Text(
                context.l10n.delete,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.surface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await ModalService.showConfirmDialog(
            context,
            title: context.l10n.removeExercise,
            message:
                context.l10n.confirmRemoveExercise(exerciseTemplate.exerciseName),
            isDangerous: true,
          );
        },
        onDismissed: (direction) => _removeExercise(index),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise header
              InkWell(
                onTap: () => _toggleExpanded(index),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Drag handle
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          AppIcons.dragHandle,
                          color: context.colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Exercise info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exerciseTemplate.exerciseName,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  // ✅ FIX: For superset, show "X round x Y exercises" instead of "X set"
                                  exerciseTemplate.type == ExerciseType.superset &&
                                  exerciseTemplate.subExercises != null &&
                                  exerciseTemplate.subExercises!.isNotEmpty
                                      ? '${exerciseTemplate.sets.length} round × ${exerciseTemplate.subExercises!.length} esercizi • ${exerciseTemplate.category.name}'
                                      : '${exerciseTemplate.sets.length} set • ${exerciseTemplate.category.name}',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                if (exerciseTemplate.restTime != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: context.colors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: context.colors.primary
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SemanticIcon(
  icon: AppIcons.timer,
  semanticLabel: 'Timer',
  size: AppIconSize.medium,
  color: context.colors.primary,
),
                                        const SizedBox(width: 2),
                                        Text(
                                          _formatRestTime(
                                              exerciseTemplate.restTime!),
                                          style: context.textTheme.labelSmall?.copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: context.colors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Rest timer button
                      IconButton.filledTonal(
                        onPressed: () => _showRestTimePicker(index),
                        icon: const SemanticIcon(
  icon: AppIcons.timer,
  semanticLabel: 'Timer',
),
                        iconSize: 20,
                        tooltip: context.l10n.restTimer,
                      ),
                      const SizedBox(width: 8),
                      // Expand/collapse icon
                      Icon(
                        isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                        color: context.colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              // Expanded sets editor
              if (isExpanded) _buildSetsEditor(index, exerciseTemplate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetsEditor(
      int exerciseIndex, ExerciseTemplate exerciseTemplate) {
    // ✅ FIX: For superset, show different UI - click to edit all exercises in round
    final isSupersetWithSubExercises = exerciseTemplate.type == ExerciseType.superset &&
        exerciseTemplate.subExercises != null &&
        exerciseTemplate.subExercises!.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: context.colors.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Sets/Rounds list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: exerciseTemplate.sets.length,
            itemBuilder: (context, setIndex) {
              final set = exerciseTemplate.sets[setIndex];

              // ✅ For superset: show round card that opens edit modal
              if (isSupersetWithSubExercises) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _editSupersetRound(exerciseIndex, setIndex),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Round number badge
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${set.setNumber}',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Round info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.roundNumber(set.setNumber),
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${exerciseTemplate.subExercises!.length} ${context.l10n.exercises}',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Edit icon
                          Icon(
                            AppIcons.edit,
                            size: 20,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: 4),
                          // Remove round button
                          if (exerciseTemplate.sets.length > 1)
                            IconButton(
                              onPressed: () => _removeSet(exerciseIndex, setIndex),
                              icon: const SemanticIcon(
                                icon: AppIcons.removeCircleOutline,
                                semanticLabel: 'Remove round',
                              ),
                              color: context.colors.error,
                              iconSize: 20,
                              tooltip: context.l10n.removeRound,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // ✅ For standard exercise: show weight/reps pickers
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Set number
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context.colors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${set.setNumber}',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Weight Picker Button
                    Expanded(
                      child: _buildPickerButton(
                        label: context.l10n.weight,
                        value: set.targetWeight == 0
                            ? '-'
                            : '${set.targetWeight?.toStringAsFixed(1)} kg',
                        icon: AppIcons.workout,
                        color: context.colors.primary,
                        onTap: () async {
                          final newWeight = await WeightPickerModal.show(
                            context,
                            initialWeight: set.targetWeight ?? 0,
                          );
                          if (newWeight != null) {
                            _updateSetWeight(exerciseIndex, setIndex, newWeight);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('×', style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    // Reps Picker Button
                    Expanded(
                      child: _buildPickerButton(
                        label: context.l10n.reps,
                        value: '${set.targetReps ?? 0}',
                        icon: AppIcons.repeat,
                        color: context.colors.secondary,
                        onTap: () async {
                          final newReps = await RepsPickerModal.show(
                            context,
                            initialReps: set.targetReps ?? 0,
                          );
                          if (newReps != null) {
                            _updateSetReps(exerciseIndex, setIndex, newReps);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Remove set button
                    if (exerciseTemplate.sets.length > 1)
                      IconButton(
                        onPressed: () => _removeSet(exerciseIndex, setIndex),
                        icon: const SemanticIcon(
  icon: AppIcons.removeCircleOutline,
  semanticLabel: 'Remove circle outline',
),
                        color: context.colors.error,
                        iconSize: 20,
                        tooltip: context.l10n.removeSet,
                      ),
                  ],
                ),
              );
            },
          ),
          // Add set/round button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () => _addSet(exerciseIndex),
              icon: const SemanticIcon(
  icon: AppIcons.add,
  semanticLabel: 'Add',
),
              label: Text(
                isSupersetWithSubExercises ? context.l10n.addRound : context.l10n.addSet,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _toggleExpanded(int index) {
    setState(() {
      _expandedExercises[index] = !(_expandedExercises[index] ?? false);
    });
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final exercise = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, exercise);
    });
    _markAsChanged();
  }

  void _addSet(int exerciseIndex) {
    final exerciseTemplate = _exercises[exerciseIndex];
    final newSetNumber = exerciseTemplate.sets.length + 1;

    final newSet = SetTemplate(
      setNumber: newSetNumber,
      targetWeight: exerciseTemplate.sets.lastOrNull?.targetWeight ?? 0,
      targetReps: exerciseTemplate.sets.lastOrNull?.targetReps ?? 0,
    );

    setState(() {
      _exercises[exerciseIndex] = exerciseTemplate.copyWith(
        sets: [...exerciseTemplate.sets, newSet],
      );
    });
    _markAsChanged();
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    final exerciseTemplate = _exercises[exerciseIndex];

    final updatedSets = List<SetTemplate>.from(exerciseTemplate.sets);
    updatedSets.removeAt(setIndex);

    // Renumber sets
    for (int i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = SetTemplate(
        setNumber: i + 1,
        targetWeight: updatedSets[i].targetWeight,
        targetReps: updatedSets[i].targetReps,
        targetRpe: updatedSets[i].targetRpe,
        notes: updatedSets[i].notes,
      );
    }

    setState(() {
      _exercises[exerciseIndex] = exerciseTemplate.copyWith(sets: updatedSets);
    });
    _markAsChanged();
  }

  void _updateSetWeight(int exerciseIndex, int setIndex, double weight) {
    final exerciseTemplate = _exercises[exerciseIndex];
    final updatedSets = List<SetTemplate>.from(exerciseTemplate.sets);
    updatedSets[setIndex] = SetTemplate(
      setNumber: updatedSets[setIndex].setNumber,
      targetWeight: weight,
      targetReps: updatedSets[setIndex].targetReps,
      targetRpe: updatedSets[setIndex].targetRpe,
      notes: updatedSets[setIndex].notes,
    );

    setState(() {
      _exercises[exerciseIndex] = exerciseTemplate.copyWith(sets: updatedSets);
    });
    _markAsChanged();
  }

  void _updateSetReps(int exerciseIndex, int setIndex, int reps) {
    final exerciseTemplate = _exercises[exerciseIndex];
    final updatedSets = List<SetTemplate>.from(exerciseTemplate.sets);
    updatedSets[setIndex] = SetTemplate(
      setNumber: updatedSets[setIndex].setNumber,
      targetWeight: updatedSets[setIndex].targetWeight,
      targetReps: reps,
      targetRpe: updatedSets[setIndex].targetRpe,
      notes: updatedSets[setIndex].notes,
    );

    setState(() {
      _exercises[exerciseIndex] = exerciseTemplate.copyWith(sets: updatedSets);
    });
    _markAsChanged();
  }

  /// ✅ Edit superset round - opens modal to set target weight/reps for all exercises in round
  void _editSupersetRound(int exerciseIndex, int roundIndex) async {
    final exerciseTemplate = _exercises[exerciseIndex];
    final round = exerciseTemplate.sets[roundIndex];

    // Show modal with weight/reps pickers for this round
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface.withValues(alpha: 0),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.roundNumber(round.setNumber),
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const SemanticIcon(
                          icon: AppIcons.close,
                          semanticLabel: 'Close',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.editRoundData,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Exercises list
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.exercises,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...?exerciseTemplate.subExercises?.map((subExercise) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              subExercise.exerciseName,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  // Weight/Reps pickers
                  Row(
                    children: [
                      Expanded(
                        child: _buildPickerButton(
                          label: context.l10n.weight,
                          value: round.targetWeight == 0
                              ? '-'
                              : '${round.targetWeight?.toStringAsFixed(1)} kg',
                          icon: AppIcons.workout,
                          color: context.colors.primary,
                          onTap: () async {
                            final newWeight = await WeightPickerModal.show(
                              context,
                              initialWeight: round.targetWeight ?? 0,
                            );
                            if (newWeight != null) {
                              _updateSetWeight(exerciseIndex, roundIndex, newWeight);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '×',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPickerButton(
                          label: context.l10n.reps,
                          value: '${round.targetReps ?? 0}',
                          icon: AppIcons.repeat,
                          color: context.colors.secondary,
                          onTap: () async {
                            final newReps = await RepsPickerModal.show(
                              context,
                              initialReps: round.targetReps ?? 0,
                            );
                            if (newReps != null) {
                              _updateSetReps(exerciseIndex, roundIndex, newReps);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddExercise() {
    // ✅ UX: Use the new static show method for proper sizing
    AddExerciseModal.show(
      context,
      onExerciseAdded: (exercise) {
        _addExercise(exercise);
      },
    );
  }

  void _addExercise(Exercise exercise) {
    // ✅ FIX: Use factory method instead of manual conversion
    // ExerciseTemplate.fromExercise() handles all exercise types (standard, superset, dropset, restpause)
    final exerciseTemplate = ExerciseTemplate.fromExercise(exercise);

    setState(() {
      _exercises.add(exerciseTemplate);
    });
    _markAsChanged();
  }

  void _removeExercise(int index) {
    if (index >= 0 && index < _exercises.length) {
      setState(() {
        _exercises.removeAt(index);
      });
      _markAsChanged();
    }
  }

  /// Navigate to presentation/view mode
  void _navigateToViewMode() {
    // If there are unsaved changes, warn the user
    if (_hasChanges) {
      ModalService.showConfirmDialog(
        context,
        title: context.l10n.unsavedChangesTitle,
        message: context.l10n.unsavedChangesMessage,
        confirmText: context.l10n.continueText,
      ).then((confirmed) {
        if (confirmed && mounted) {
          _openViewMode();
        }
      });
    } else {
      _openViewMode();
    }
  }

  void _openViewMode() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TemplateViewScreen(templateId: widget.template.id),
      ),
    );
  }

  Future<void> _saveTemplate() async {
    if (_nameController.text.trim().isEmpty) {
      SnackBarService.showError(context, context.l10n.templateNameRequired);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ensure userId is set (safety net for templates created without it)
      final currentUserId = ref.read(currentUserIdProvider);
      final templateToSave = widget.template.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        exercises: _exercises,
        updatedAt: DateTime.now(),
        userId: widget.template.userId ?? currentUserId, // ✅ Safety net for Firestore rules
      );

      await ref.read(workoutTemplateNotifierProvider.notifier).saveTemplate(templateToSave);

      ref.invalidate(customWorkoutTemplatesProvider);

      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });

      if (mounted) {
        SnackBarService.showSuccess(context, context.l10n.templateSaved);
        context.pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        SnackBarService.showError(context, context.l10n.error);
      }
    }
  }

  Future<void> _showDiscardChangesDialog() async {
    final confirmed = await ModalService.showConfirmDialog(
      context,
      title: context.l10n.unsavedChanges,
      message: context.l10n.discardChangesMessage,
      isDangerous: true,
    );

    if (confirmed && mounted) {
      context.pop();
    }
  }

  void _showRestTimePicker(int exerciseIndex) {
    final exerciseTemplate = _exercises[exerciseIndex];

    ModalService.showBottomSheet(
      context,
      child: RestTimePickerModal(
        initialRestTime: exerciseTemplate.restTime,
        onRestTimeSelected: (restTime) {
          setState(() {
            _exercises[exerciseIndex] = exerciseTemplate.copyWith(
              restTime: restTime,
            );
          });
          _markAsChanged();
        },
      ),
    );
  }

  String _formatRestTime(int seconds) {
    if (seconds == 0) return '0s';

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes == 0) {
      return '${seconds}s';
    } else if (remainingSeconds == 0) {
      return '${minutes}min';
    } else {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
}
