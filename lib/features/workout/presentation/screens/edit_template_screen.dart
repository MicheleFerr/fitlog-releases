import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../../../shared/presentation/widgets/premium_action_button.dart';
import '../../domain/entities/workout_template.dart';
import '../../domain/entities/exercise.dart';
import '../providers/workout_template_provider.dart';
import '../widgets/add_exercise_modal.dart';
import '../widgets/rest_time_picker_modal.dart';

class EditTemplateScreen extends ConsumerStatefulWidget {
  final WorkoutTemplate template;

  const EditTemplateScreen({
    super.key,
    required this.template,
  });

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template.name);
    _descriptionController = TextEditingController(text: widget.template.description);
    _exercises = List.from(widget.template.exercises);
    _isPublic = widget.template.isPublic;
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
          title: Text(AppLocalizations.of(context)!.edit),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveTemplate,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(AppLocalizations.of(context)!.save),
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
                  Card(
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
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isPublic ? 'Template Pubblico' : 'Template Privato',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          if (_isPublic) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Assicurati che il template sia completo e ben descritto',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                  ),
                ],
              ),
            ),
            
            // Lista esercizi
            Expanded(
              child: _exercises.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _exercises.length,
                      itemBuilder: (context, index) {
                        final exerciseTemplate = _exercises[index];
                        
                        // Converte ExerciseTemplate in Exercise per la UI
                        final exercise = Exercise(
                          id: exerciseTemplate.exerciseId,
                          name: exerciseTemplate.exerciseName,
                          category: exerciseTemplate.category,
                          type: exerciseTemplate.type ?? ExerciseType.single,
                          sets: exerciseTemplate.sets.map((setTemplate) {
                            return ExerciseSet(
                              setNumber: setTemplate.setNumber,
                              weight: setTemplate.targetWeight,
                              reps: setTemplate.targetReps,
                              notes: setTemplate.notes,
                            );
                          }).toList(),
                          notes: exerciseTemplate.notes,
                          restTime: exerciseTemplate.restTime,
                        );
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key('exercise_${exercise.id}_$index'),
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
                                  const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!.delete,
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
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(AppLocalizations.of(context)!.removeExercise),
                                  content: Text(AppLocalizations.of(context)!.confirmRemoveExercise(exercise.name)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text(AppLocalizations.of(context)!.cancel),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text(AppLocalizations.of(context)!.delete),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              _removeExercise(index);
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            exercise.name,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        // Pulsante timer dedicato
                                        IconButton.filledTonal(
                                          onPressed: () => _showRestTimePicker(index),
                                          icon: const Icon(Icons.timer),
                                          iconSize: 20,
                                          tooltip: 'Timer Recupero',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          '${exercise.sets.length} set • ${exercise.category.name}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                          ),
                                        ),
                                        if (exerciseTemplate.restTime != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.timer,
                                                  size: 12,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  _formatRestTime(exerciseTemplate.restTime!),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Mostra set in formato verticale
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: exercise.sets.map((set) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${set.setNumber}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Theme.of(context).colorScheme.primary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    '${set.weight ?? 0}kg × ${set.reps ?? 0} reps',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PremiumActionButton(
            onPressed: _showAddExercise,
            icon: Icons.add,
            label: AppLocalizations.of(context)!.addExercise,
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
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noExercisesYet,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tapToAddExercise,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showAddExercise,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addExercise),
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

  void _showAddExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddExerciseModal(
        onExerciseAdded: (exercise) {
          _addExercise(exercise);
        },
      ),
    );
  }

  void _addExercise(Exercise exercise) {
    final exerciseTemplate = ExerciseTemplate(
      exerciseId: exercise.name.toLowerCase().replaceAll(' ', '_'),
      exerciseName: exercise.name,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Il nome del template è obbligatorio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedTemplate = widget.template.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        exercises: _exercises,
        isPublic: _isPublic,
      );

      await ref.read(workoutTemplateNotifierProvider.notifier).saveTemplate(updatedTemplate);

      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template salvato con successo'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel salvataggio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifiche non salvate'),
        content: const Text('Hai delle modifiche non salvate. Vuoi scartarle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Scarta'),
          ),
        ],
      ),
    );
  }

  void _showRestTimePicker(int exerciseIndex) {
    final exerciseTemplate = _exercises[exerciseIndex];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RestTimePickerModal(
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