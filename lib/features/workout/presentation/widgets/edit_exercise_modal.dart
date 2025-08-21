import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../../../shared/presentation/widgets/error_boundary.dart';

class EditExerciseModal extends ConsumerStatefulWidget {
  final Exercise exercise;
  final Function(Exercise) onSave;

  const EditExerciseModal({
    super.key,
    required this.exercise,
    required this.onSave,
  });

  @override
  ConsumerState<EditExerciseModal> createState() => _EditExerciseModalState();
}

class _EditExerciseModalState extends ConsumerState<EditExerciseModal> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late TextEditingController _restTimeController;
  
  bool _useCustomRestTime = false;
  int? _selectedRestTime;

  // Predefined rest time options in seconds
  static const List<int> _predefinedRestTimes = [30, 60, 90, 120, 180, 240, 300];

  @override
  void initState() {
    super.initState();
    debugPrint('📝 EditExerciseModal.initState() - Starting initialization');
    
    try {
      debugPrint('📝 Exercise: ${widget.exercise.name}');
      debugPrint('📝 Rest time: ${widget.exercise.restTime}');
      
      _nameController = TextEditingController(text: widget.exercise.name);
      _notesController = TextEditingController(text: widget.exercise.notes ?? '');
      
      // Initialize rest time
      _selectedRestTime = widget.exercise.restTime;
      _useCustomRestTime = _selectedRestTime != null && !_predefinedRestTimes.contains(_selectedRestTime);
      _restTimeController = TextEditingController(
        text: _useCustomRestTime ? _selectedRestTime?.toString() ?? '' : ''
      );
      
      debugPrint('📝 Controllers initialized successfully');
      debugPrint('📝 Use custom rest time: $_useCustomRestTime');
      debugPrint('📝 Selected rest time: $_selectedRestTime');
    } catch (e, stack) {
      debugPrint('❌ Error in initState: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _restTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rimuovi il log qui per evitare spam
    
    try {
      final l10n = AppLocalizations.of(context);
      if (l10n == null) {
        debugPrint('❌ AppLocalizations is null!');
        throw Exception('AppLocalizations not found in context');
      }
      
      // NON wrappare con ErrorBoundary qui - causa loop infiniti
      return GestureDetector(
          onTap: () {
            debugPrint('📝 GestureDetector tapped - unfocusing keyboard');
            FocusScope.of(context).unfocus();
          },
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
                Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.editExercise,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Exercise name
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.exerciseName,
                prefixIcon: const Icon(Icons.fitness_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Exercise notes
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.notes,
                hintText: l10n.notesHint,
                prefixIcon: const Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Rest time section
            Text(
              l10n.exerciseRestTime,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.exerciseRestTimeDesc,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            
            // Default timer option
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.timer_outlined,
                  color: !_useCustomRestTime && _selectedRestTime == null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: Text(l10n.useDefaultRestTime),
                subtitle: const Text('120s'),
                trailing: Radio<bool>(
                  value: false,
                  groupValue: _useCustomRestTime || _selectedRestTime != null,
                  onChanged: (value) {
                    setState(() {
                      _selectedRestTime = null;
                      _useCustomRestTime = false;
                      _restTimeController.clear();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedRestTime = null;
                    _useCustomRestTime = false;
                    _restTimeController.clear();
                  });
                },
              ),
            ),
            
            // Predefined rest times
            Text(
              'Quick Timer Options',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _predefinedRestTimes.map((seconds) {
                final isSelected = _selectedRestTime == seconds && !_useCustomRestTime;
                return FilterChip(
                  label: Text('${seconds}s'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedRestTime = selected ? seconds : null;
                      _useCustomRestTime = false;
                      _restTimeController.clear();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Custom rest time
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.tune,
                      color: _useCustomRestTime
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    title: Text(l10n.customRestTime),
                    trailing: Radio<bool>(
                      value: true,
                      groupValue: _useCustomRestTime,
                      onChanged: (value) {
                        debugPrint('📝 Radio changed to: $value');
                        setState(() {
                          _useCustomRestTime = value ?? false;
                          if (_useCustomRestTime) {
                            _selectedRestTime = null;
                          }
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _useCustomRestTime = !_useCustomRestTime;
                        if (_useCustomRestTime) {
                          _selectedRestTime = null;
                        }
                      });
                    },
                  ),
                  if (_useCustomRestTime) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextField(
                        controller: _restTimeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: '${l10n.exerciseRestTime} (${l10n.restTimeSeconds})',
                          hintText: '90',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                          suffixText: 's',
                        ),
                        onChanged: (value) {
                          // Safely parse the value
                          if (value.isNotEmpty) {
                            final seconds = int.tryParse(value);
                            if (seconds != null && seconds > 0 && seconds <= 3600) {
                              setState(() {
                                _selectedRestTime = seconds;
                              });
                            }
                          } else {
                            setState(() {
                              _selectedRestTime = null;
                            });
                          }
                        },
                        onSubmitted: (_) {
                          // Dismiss keyboard when done
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveExercise,
                    child: Text(l10n.save),
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
    } catch (e, stack) {
      debugPrint('❌ Error in build method: $e');
      debugPrint('Stack: $stack');
      
      // Ritorna un widget di errore invece di crashare
      return Material(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Error loading exercise editor'),
              Text('Error: $e', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _saveExercise() {
    debugPrint('🔵 _saveExercise called');
    
    // Wrap everything in a try-catch to prevent any crash
    try {
      // Get localization before any async operations
      final l10n = AppLocalizations.of(context);
      debugPrint('🔵 Got localization');
      
      final name = _nameController.text.trim();
      debugPrint('🔵 Exercise name: $name');
      
      if (name.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.exerciseName} cannot be empty'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      final notes = _notesController.text.trim();
      debugPrint('🔵 Notes: $notes');
      int? restTime;

      debugPrint('🔵 Use custom rest time: $_useCustomRestTime');
      debugPrint('🔵 Rest time controller text: ${_restTimeController.text}');
      
      if (_useCustomRestTime) {
        // Validate custom rest time
        final customTime = int.tryParse(_restTimeController.text);
        debugPrint('🔵 Parsed custom time: $customTime');
        
        if (customTime != null && customTime > 0 && customTime <= 3600) {
          restTime = customTime;
          debugPrint('🔵 Valid custom time set: $restTime');
        } else if (_restTimeController.text.isNotEmpty) {
          debugPrint('🔵 Invalid custom time entered');
          // Invalid custom time entered
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter a valid rest time (1-3600 seconds)'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }
      } else if (_selectedRestTime != null) {
        restTime = _selectedRestTime;
      }

      // Validate exercise object exists
      if (widget.exercise == null) {
        debugPrint('Error: exercise is null');
        if (mounted) Navigator.pop(context);
        return;
      }

      debugPrint('🔵 Creating updated exercise...');
      final updatedExercise = widget.exercise.copyWith(
        name: name,
        notes: notes.isEmpty ? null : notes,
        restTime: restTime,
      );
      debugPrint('🔵 Updated exercise created with restTime: ${updatedExercise.restTime}');

      // Call the onSave callback directly
      if (widget.onSave != null) {
        debugPrint('🔵 Calling onSave callback...');
        try {
          widget.onSave(updatedExercise);
          debugPrint('🔵 onSave callback completed');
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Exercise "$name" updated'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                action: restTime != null 
                    ? SnackBarAction(
                        label: 'Timer: ${restTime}s',
                        textColor: Colors.white,
                        onPressed: () {},
                      )
                    : null,
              ),
            );
          }
        } catch (e) {
          debugPrint('❌ Error in onSave callback: $e');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving exercise: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Show error message to user
      if (mounted) {
        // Try to close modal if still open
        try {
          Navigator.pop(context);
        } catch (_) {
          // Ignore navigation errors
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error updating exercise. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

// Extension for easy modal showing
extension EditExerciseModalExtension on BuildContext {
  Future<void> showEditExerciseModal(
    Exercise? exercise,
    Function(Exercise)? onSave,
  ) async {
    // Validate inputs
    if (exercise == null) {
      debugPrint('Error: Cannot show EditExerciseModal with null exercise');
      ScaffoldMessenger.of(this).showSnackBar(
        const SnackBar(
          content: Text('Error: Unable to edit this exercise'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (onSave == null) {
      debugPrint('Error: Cannot show EditExerciseModal with null onSave callback');
      return;
    }
    
    try {
      debugPrint('📝 showEditExerciseModal - Starting');
      debugPrint('📝 Exercise to edit: ${exercise.name}');
      debugPrint('📝 Current context: $this');
      
      // Dismiss any open keyboard before showing modal
      FocusScope.of(this).unfocus();
      await Future.delayed(const Duration(milliseconds: 100)); // Piccolo delay per permettere alla tastiera di chiudersi
      
      debugPrint('📝 Showing modal bottom sheet...');
      
      await showModalBottomSheet(
        context: this,
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        backgroundColor: Theme.of(this).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (modalContext) {
          debugPrint('📝 Modal builder called');
          
          // Wrap in a safe widget per catturare errori
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: EditExerciseModal(
                exercise: exercise,
                onSave: onSave,
              ),
            ),
          );
        },
      );
      
      debugPrint('📝 Modal closed successfully');
    } catch (e, stackTrace) {
      debugPrint('Error showing EditExerciseModal: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(this).showSnackBar(
          const SnackBar(
            content: Text('Error opening exercise editor. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}