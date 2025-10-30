
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/data/repositories/unified_template_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/unified_workout_template.dart' as unified;
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
import 'package:gymbro_flutter_new/features/workout/presentation/providers/firebase_template_provider.dart';

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
                    decoration: const InputDecoration(
                      labelText: 'Nome Template',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _markAsChanged(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrizione',
                      border: OutlineInputBorder(),
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
                                _isPublic ? Icons.public : Icons.lock,
                                size: 20,
                                color: _isPublic
                                    ? context.colors.primary
                                    : context.colors.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 8),
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
                          const SizedBox(height: 8),
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
                            const SizedBox(height: 8),
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
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: context.colors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Assicurati che il template sia completo e ben descritto',
                                      style: TextStyle(
                                        fontSize: 12,
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
          child: const Icon(Icons.add),
        ),

      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: context.colors.onSurface.withValues(alpha: 0.3),
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
            icon: const Icon(Icons.add),
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
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delete, color: Colors.white, size: 28),
              const SizedBox(height: 4),
              Text(
                context.l10n.delete,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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
                          Icons.drag_handle,
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
                                  '${exerciseTemplate.sets.length} set • ${exerciseTemplate.category.name}',
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
                                        Icon(
                                          Icons.timer,
                                          size: 12,
                                          color: context.colors.primary,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          _formatRestTime(
                                              exerciseTemplate.restTime!),
                                          style: TextStyle(
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
                        icon: const Icon(Icons.timer),
                        iconSize: 20,
                        tooltip: 'Timer Recupero',
                      ),
                      const SizedBox(width: 8),
                      // Expand/collapse icon
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
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
    return Container(
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
          // Sets list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: exerciseTemplate.sets.length,
            itemBuilder: (context, setIndex) {
              final set = exerciseTemplate.sets[setIndex];
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
                          style: TextStyle(
                            fontSize: 14,
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
                        icon: Icons.fitness_center,
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
                    const Text('×', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    // Reps Picker Button
                    Expanded(
                      child: _buildPickerButton(
                        label: context.l10n.reps,
                        value: '${set.targetReps ?? 0}',
                        icon: Icons.repeat,
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
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.red,
                        iconSize: 20,
                        tooltip: context.l10n.removeSet,
                      ),
                  ],
                ),
              );
            },
          ),
          // Add set button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () => _addSet(exerciseIndex),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.addSet),
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

  void _showAddExercise() {
    ModalService.showBottomSheet(
      context,
      child: AddExerciseModal(
        onExerciseAdded: (exercise) {
          _addExercise(exercise);
        },
      ),
    );
  }

  void _addExercise(Exercise exercise) {
    final exerciseTemplate = ExerciseTemplate(
      exerciseId: exercise.id,  // ✅ Use original ID (e.g., "barbell_bench_press")
      exerciseName: exercise.name,  // Exercise name
      category: exercise.category,
      type: exercise.type,
      sets: exercise.sets.map((set) {
        return SetTemplate(
          setNumber: set.setNumber,
          targetWeight: set.weight,
          targetReps: set.reps,
          notes: set.notes,
        );
      }).toList(),
      notes: exercise.notes,
      restTime: exercise.restTime,
    );

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

  Future<void> _saveTemplate() async {
    if (_nameController.text.trim().isEmpty) {
      SnackBarService.showError(context, 'Il nome del template è obbligatorio');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final unifiedRepository = ref.read(unifiedTemplateRepositoryProvider);
      final existingTemplate =
          await unifiedRepository.getTemplateById(widget.template.id);

      final unified.UnifiedWorkoutTemplate templateToSave;

      if (existingTemplate != null) {
        // Template exists in unified repo, update it
        templateToSave = existingTemplate.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          exercisesRaw: _exercises.map((e) => e.toJson()).toList(),
          isPublic: _isPublic,
          visibility: _isPublic
              ? unified.UnifiedTemplateVisibility.public
              : unified.UnifiedTemplateVisibility.private,
          updatedAt: DateTime.now(),
          version: (existingTemplate.version ?? 0) + 1,
        );
      } else {
        // Template not found, this is a legacy template being migrated.
        // Create a new UnifiedWorkoutTemplate from the screen data.
        final user = ref.read(authStateProvider).value;
        templateToSave = unified.UnifiedWorkoutTemplate(
          id: widget.template.id, // IMPORTANT: Keep the original ID
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          exercisesRaw: _exercises.map((e) => e.toJson()).toList(),
          isPublic: _isPublic,
          visibility: _isPublic
              ? unified.UnifiedTemplateVisibility.public
              : unified.UnifiedTemplateVisibility.private,
          createdAt: widget.template.createdAt,
          updatedAt: DateTime.now(),
          version: 1,
          isCustom: widget.template.isCustom,
          userId: widget.template.userId ?? user?.uid,
          authorName: widget.template.authorName,
          source: unified.TemplateSource.legacy, // Mark as migrated
          // Copy other relevant fields from the legacy template
          tags: widget.template.tags,
          estimatedDuration: widget.template.estimatedDuration,
          usageCount: widget.template.usageCount,
          downloadCount: widget.template.downloadCount,
          averageRating: widget.template.averageRating,
          reviewCount: widget.template.reviewCount,
          difficulty: widget.template.difficulty,
          imageUrl: widget.template.imageUrl,
        );
      }

      await unifiedRepository.updateTemplate(templateToSave);

      ref.invalidate(userTemplatesProvider);
      ref.invalidate(customWorkoutTemplatesProvider); // Invalidate this too

      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });

      if (mounted) {
        SnackBarService.showSuccess(context, 'Template salvato con successo');
        context.pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        SnackBarService.showError(context, 'Errore nel salvataggio: $e');
      }
    }
  }

  Future<void> _showDiscardChangesDialog() async {
    final confirmed = await ModalService.showConfirmDialog(
      context,
      title: 'Modifiche non salvate',
      message: 'Hai delle modifiche non salvate. Vuoi scartarle?',
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
