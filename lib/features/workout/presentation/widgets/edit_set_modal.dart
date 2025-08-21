import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../../../../shared/presentation/providers/app_config_provider.dart';
import '../../../../shared/domain/entities/app_config.dart';
import 'weight_picker_modal.dart';
import 'reps_picker_modal.dart';

class EditSetModal extends ConsumerStatefulWidget {
  final ExerciseSet exerciseSet;
  final Function(ExerciseSet) onSave;

  const EditSetModal({
    super.key,
    required this.exerciseSet,
    required this.onSave,
  });

  @override
  ConsumerState<EditSetModal> createState() => _EditSetModalState();
}

class _EditSetModalState extends ConsumerState<EditSetModal> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _actualRepsController;
  late TextEditingController _secondsController;
  late TextEditingController _notesController;
  
  bool _isCompleted = false;
  int? _selectedRpe;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.exerciseSet.isCompleted;
    _selectedRpe = widget.exerciseSet.rpe;
    
    _weightController = TextEditingController(
      text: widget.exerciseSet.weight?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.exerciseSet.reps?.toString() ?? '',
    );
    _actualRepsController = TextEditingController(
      text: widget.exerciseSet.actualReps?.toString() ?? '',
    );
    // Show tracked duration if available, otherwise show manual seconds input
    String durationText = '';
    if (widget.exerciseSet.setDurationMillis != null) {
      // Convert milliseconds to seconds,milliseconds format (e.g., "12,34" for 12.34 seconds)
      final totalMillis = widget.exerciseSet.setDurationMillis!.round();
      final seconds = totalMillis ~/ 1000;
      final millis = (totalMillis % 1000) ~/ 10; // Get centiseconds (2 decimal places)
      durationText = '$seconds,${millis.toString().padLeft(2, '0')}';
    } else if (widget.exerciseSet.seconds != null) {
      durationText = '${widget.exerciseSet.seconds},00';
    }
    
    _secondsController = TextEditingController(
      text: durationText,
    );
    _notesController = TextEditingController(
      text: widget.exerciseSet.notes ?? '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _actualRepsController.dispose();
    _secondsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header
          Row(
            children: [
              Text(
                'Edit Set ${widget.exerciseSet.setNumber}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Completion toggle
          Card(
            child: SwitchListTile(
              title: const Text('Mark as Completed'),
              subtitle: Text(_isCompleted ? 'This set is completed' : 'This set is not completed'),
              value: _isCompleted,
              onChanged: (value) {
                setState(() {
                  _isCompleted = value;
                });
              },
              secondary: Icon(
                _isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: _isCompleted 
                    ? Theme.of(context).colorScheme.tertiary 
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Weight and Reps row
          Row(
            children: [
              Expanded(
                child: _buildWeightSelector(context, config),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRepsSelector(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Actual Reps (if set is completed)
          if (_isCompleted) ...[
            _buildActualRepsField(context),
            const SizedBox(height: 16),
          ],
          
          // Duration (for timed exercises) - more compact
          _buildDurationField(context),
          const SizedBox(height: 16),
          
          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              labelText: 'Set Notes',
              hintText: 'RPE, form notes, difficulty...',
              prefixIcon: const Icon(Icons.note),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'Tap "Done" on keyboard to close',
              helperStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // RPE selector (if set is completed)
          if (_isCompleted) ...[
            Text(
              'RPE (Rate of Perceived Exertion)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(5, (index) {
                final rpe = index + 6; // RPE from 6 to 10
                final isSelected = _selectedRpe == rpe;
                
                return ChoiceChip(
                  label: Text('$rpe'),
                  selected: isSelected,
                  selectedColor: _getRpeChipColor(rpe),
                  onSelected: (selected) {
                    setState(() {
                      _selectedRpe = selected ? rpe : null;
                    });
                  },
                );
              }),
            ),
            if (_selectedRpe != null) ...[
              const SizedBox(height: 8),
              Text(
                'RIR: ${10 - _selectedRpe!} reps in reserve',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ] else ...[
            // Old quick RPE buttons for notes (when not completed)
            Text(
              'Quick RPE (add to notes)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(10, (index) {
                final rpe = index + 1;
                return FilterChip(
                  label: Text('$rpe'),
                  onSelected: (selected) {
                    if (selected) {
                      final currentNotes = _notesController.text;
                      final rpeNote = 'RPE: $rpe';
                      
                      // Replace existing RPE or add new one
                      if (currentNotes.contains('RPE:')) {
                        final updatedNotes = currentNotes.replaceAll(
                          RegExp(r'RPE:\s*\d+'),
                          rpeNote,
                        );
                        _notesController.text = updatedNotes;
                      } else {
                        _notesController.text = currentNotes.isEmpty 
                            ? rpeNote 
                            : '$currentNotes, $rpeNote';
                      }
                    }
                  },
                );
              }),
            ),
          ],
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _saveSet,
                  child: const Text('Save Set'),
                ),
              ),
            ],
          ),
          
          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
      ),
    );
  }

  void _saveSet() {
    try {
      final weight = double.tryParse(_weightController.text);
      final reps = int.tryParse(_repsController.text);
      final actualReps = int.tryParse(_actualRepsController.text);
      
      // Parse duration from format "seconds,centiseconds" (e.g., "12,34")
      double? setDurationMillis;
      int? seconds;
      final durationText = _secondsController.text.trim();
      
      if (durationText.isNotEmpty) {
        if (durationText.contains(',')) {
          // Format: "12,34" -> 12340 milliseconds
          final parts = durationText.split(',');
          if (parts.length == 2) {
            final secs = int.tryParse(parts[0]) ?? 0;
            final centis = int.tryParse(parts[1]) ?? 0;
            // Validate reasonable values
            if (secs >= 0 && secs < 3600 && centis >= 0 && centis <= 99) {
              setDurationMillis = (secs * 1000 + centis * 10).toDouble();
              seconds = secs; // For backward compatibility with seconds field
            }
          }
        } else {
          // Simple seconds format (backward compatibility)
          seconds = int.tryParse(durationText);
          if (seconds != null && seconds >= 0 && seconds < 3600) {
            setDurationMillis = seconds * 1000.0;
          }
        }
      } else if (widget.exerciseSet.setDurationMillis != null) {
        // Preserve original auto-tracked value if field is empty
        setDurationMillis = widget.exerciseSet.setDurationMillis;
        seconds = (setDurationMillis! / 1000).round();
      }
      
      final notes = _notesController.text.trim();

      // Ensure we have valid data before creating updated set
      if (widget.exerciseSet == null) {
        debugPrint('Error: exerciseSet is null');
        Navigator.pop(context);
        return;
      }

      final updatedSet = widget.exerciseSet.copyWith(
        weight: weight,
        reps: reps,
        actualReps: actualReps,
        rpe: _selectedRpe,
        seconds: seconds,
        notes: notes.isEmpty ? null : notes,
        isCompleted: _isCompleted,
        setDurationMillis: setDurationMillis,
        setStartedAt: widget.exerciseSet.setStartedAt, // Preserve start time
      );

      // Ensure onSave callback exists
      if (widget.onSave != null) {
        widget.onSave(updatedSet);
      }
      
      // Check if context is still mounted before navigation
      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Set ${widget.exerciseSet.setNumber} updated'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving set: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Show error message to user
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error updating set. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  Color _getRpeChipColor(int rpe) {
    if (rpe <= 6) return Colors.green;
    if (rpe <= 7) return Colors.lightGreen;
    if (rpe <= 8) return Colors.orange;
    if (rpe <= 9) return Colors.deepOrange;
    return Colors.red;
  }

  Widget _buildWeightSelector(BuildContext context, AppConfig config) {
    final currentWeight = double.tryParse(_weightController.text) ?? 0.0;
    final hasWeight = currentWeight > 0;
    
    return InkWell(
      onTap: () => _openWeightPicker(context, config),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasWeight 
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: hasWeight 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              size: 18,
              color: hasWeight 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasWeight 
                    ? '${currentWeight.toStringAsFixed(currentWeight % 1 == 0 ? 0 : 1)} ${config.measurementUnit}'
                    : 'Weight',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: hasWeight ? FontWeight.w600 : FontWeight.normal,
                  color: hasWeight 
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!hasWeight)
              Icon(
                Icons.add_circle_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  void _openWeightPicker(BuildContext context, AppConfig config) {
    final currentWeight = double.tryParse(_weightController.text) ?? 0.0;
    
    context.showWeightPicker(
      initialWeight: currentWeight,
      unit: config.measurementUnit,
      onWeightSelected: (selectedWeight) {
        setState(() {
          _weightController.text = selectedWeight.toString();
        });
      },
    );
  }

  Widget _buildRepsSelector(BuildContext context) {
    final currentReps = int.tryParse(_repsController.text) ?? 0;
    final hasReps = currentReps > 0;
    
    return InkWell(
      onTap: () => _openRepsPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasReps 
              ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: hasReps 
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.repeat,
              size: 18,
              color: hasReps 
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasReps 
                    ? '$currentReps reps'
                    : 'Reps',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: hasReps ? FontWeight.w600 : FontWeight.normal,
                  color: hasReps 
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!hasReps)
              Icon(
                Icons.add_circle_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  void _openRepsPicker(BuildContext context) {
    final currentReps = int.tryParse(_repsController.text) ?? 10;
    
    context.showRepsPicker(
      initialReps: currentReps,
      onRepsSelected: (selectedReps) {
        setState(() {
          _repsController.text = selectedReps.toString();
        });
      },
    );
  }

  Widget _buildActualRepsField(BuildContext context) {
    return TextField(
      controller: _actualRepsController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        labelText: 'Actual Reps Completed',
        hintText: 'How many reps did you actually complete?',
        prefixIcon: const Icon(Icons.fitness_center),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDurationField(BuildContext context) {
    final durationText = _secondsController.text;
    final hasDuration = durationText.isNotEmpty;
    final isAutoTracked = widget.exerciseSet.setDurationMillis != null;
    
    return TextField(
      controller: _secondsController,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        labelText: isAutoTracked ? 'Duration (auto-tracked)' : 'Duration (optional)',
        hintText: hasDuration ? null : 'ss,ms (e.g. 12,34)',
        prefixIcon: Icon(
          Icons.timer,
          size: 18,
          color: hasDuration 
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        suffixText: hasDuration ? 's' : null,
        helperText: isAutoTracked 
            ? '⏱️ Tracked automatically (seconds,centiseconds)' 
            : 'Format: seconds,centiseconds (e.g., 12,34 = 12.34s)',
        helperStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 11,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.number,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: hasDuration ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

// Extension for easy modal showing
extension EditSetModalExtension on BuildContext {
  Future<void> showEditSetModal(
    ExerciseSet? exerciseSet,
    Function(ExerciseSet)? onSave,
  ) async {
    // Validate inputs
    if (exerciseSet == null) {
      debugPrint('Error: Cannot show EditSetModal with null exerciseSet');
      ScaffoldMessenger.of(this).showSnackBar(
        const SnackBar(
          content: Text('Error: Unable to edit this set'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (onSave == null) {
      debugPrint('Error: Cannot show EditSetModal with null onSave callback');
      return;
    }
    
    try {
      await showModalBottomSheet(
        context: this,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => EditSetModal(
          exerciseSet: exerciseSet,
          onSave: onSave,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error showing EditSetModal: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(this).showSnackBar(
          const SnackBar(
            content: Text('Error opening edit dialog. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}