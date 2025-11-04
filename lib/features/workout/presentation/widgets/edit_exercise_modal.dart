import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class EditExerciseModal extends ConsumerStatefulWidget {

  const EditExerciseModal({
    super.key,
    required this.exercise,
    required this.onSave,
  });
  final Exercise exercise;
  final Function(Exercise) onSave;

  @override
  ConsumerState<EditExerciseModal> createState() => _EditExerciseModalState();
}

class _EditExerciseModalState extends ConsumerState<EditExerciseModal> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late TextEditingController _restTimeController;
  late TextEditingController _apreBaseWeightController;

  bool _useCustomRestTime = false;
  int? _selectedRestTime;

  // APRE configuration
  bool _useAPRE = false;
  int _apreProtocol = 6; // Default to APRE 6

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

      // Initialize APRE configuration
      _useAPRE = widget.exercise.useAPRE ?? false;
      _apreProtocol = widget.exercise.apreProtocol ?? 6;
      _apreBaseWeightController = TextEditingController(
        text: widget.exercise.apreBaseWeight?.toString() ?? ''
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
    _apreBaseWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rimuovi il log qui per evitare spam
    
    try {
      final l10n = AppLocalizations.of(context);
      
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
                  color: Colors.grey.withValues(alpha: 0.3),
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

            RadioGroup<bool>(
              groupValue: _useCustomRestTime,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _useCustomRestTime = value;
                    if (!value) {
                      _selectedRestTime = null;
                      _restTimeController.clear();
                    } else {
                      _selectedRestTime = null;
                    }
                  });
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Default timer option
                  Card(
                    child: ListTile(
                      leading: Icon(
                        AppIcons.timer,
                        color: !_useCustomRestTime && _selectedRestTime == null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: Text(l10n.useDefaultRestTime),
                      subtitle: const Text('120s'),
                      trailing: const Radio<bool>(
                        value: false,
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
                  const SizedBox(height: 16),

                  // Predefined rest times
                  Text(
                    l10n.quickTimerOptions,
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
                            AppIcons.tune,
                            color: _useCustomRestTime
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          title: Text(l10n.customRestTime),
                          trailing: const Radio<bool>(
                            value: true,
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
                ],
              ),
            ),
            const SizedBox(height: 20),

            // APRE Configuration Section
            _buildAPRESection(l10n),
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
              Text(context.l10n.errorLoadingEditor),
              Text('Error: $e', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.close),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildAPRESection(AppLocalizations l10n) {
    return Card(
      color: _useAPRE
        ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1)
        : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // APRE Toggle
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.apreAutoregulation,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.apreAutoregulationDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _useAPRE,
                  onChanged: (value) {
                    setState(() {
                      _useAPRE = value;
                      if (!value) {
                        _apreBaseWeightController.clear();
                      }
                    });
                  },
                ),
              ],
            ),

            // APRE Configuration (shown when enabled)
            if (_useAPRE) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Protocol Selection
              Text(
                l10n.apreProtocolSelect,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment<int>(
                    value: 3,
                    label: Text('APRE 3'),
                    icon: Icon(Icons.looks_3),
                  ),
                  ButtonSegment<int>(
                    value: 6,
                    label: Text('APRE 6'),
                    icon: Icon(Icons.looks_6),
                  ),
                  ButtonSegment<int>(
                    value: 10,
                    label: Text('APRE 10'),
                    icon: Icon(Icons.looks),
                  ),
                ],
                selected: {_apreProtocol},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _apreProtocol = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Protocol Description
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getProtocolDescription(l10n),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Base Weight Input
              TextField(
                controller: _apreBaseWeightController,
                decoration: InputDecoration(
                  labelText: l10n.apreBaseWeight,
                  hintText: l10n.apreBaseWeightHint,
                  prefixIcon: const Icon(Icons.fitness_center),
                  suffixText: 'kg',
                  helperText: _getBaseWeightHelper(l10n),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getProtocolDescription(AppLocalizations l10n) {
    switch (_apreProtocol) {
      case 3:
        return l10n.apreProtocol3Description;
      case 6:
        return l10n.apreProtocol6Description;
      case 10:
        return l10n.apreProtocol10Description;
      default:
        return '';
    }
  }

  String _getBaseWeightHelper(AppLocalizations l10n) {
    switch (_apreProtocol) {
      case 3:
        return l10n.apreProtocol3Helper;
      case 6:
        return l10n.apreProtocol6Helper;
      case 10:
        return l10n.apreProtocol10Helper;
      default:
        return '';
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
              content: Text(l10n.exerciseNameCannotBeEmpty(l10n.exerciseName)),
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
                content: Text(l10n.invalidRestTimeError),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }
      } else if (_selectedRestTime != null) {
        restTime = _selectedRestTime;
      }

      // Parse APRE base weight
      double? apreBaseWeight;
      if (_useAPRE && _apreBaseWeightController.text.isNotEmpty) {
        apreBaseWeight = double.tryParse(_apreBaseWeightController.text.trim());
        if (apreBaseWeight == null || apreBaseWeight <= 0) {
          debugPrint('🔵 Invalid APRE base weight');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.invalidApreBaseWeight),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }
      }

      debugPrint('🔵 Creating updated exercise...');
      final updatedExercise = widget.exercise.copyWith(
        name: name,
        notes: notes.isEmpty ? null : notes,
        restTime: restTime,
        useAPRE: _useAPRE,
        apreProtocol: _useAPRE ? _apreProtocol : null,
        apreBaseWeight: _useAPRE ? apreBaseWeight : null,
      );
      debugPrint('🔵 Updated exercise created with restTime: ${updatedExercise.restTime}');
      debugPrint('🔵 APRE enabled: ${updatedExercise.useAPRE}, Protocol: ${updatedExercise.apreProtocol}, Base weight: ${updatedExercise.apreBaseWeight}');

      // Call the onSave callback directly
      debugPrint('🔵 Calling onSave callback...');
      try {
        widget.onSave(updatedExercise);
        debugPrint('🔵 onSave callback completed');
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.exerciseUpdated(name)),
              backgroundColor: Theme.of(context).colorScheme.primary,
              action: restTime != null
                  ? SnackBarAction(
                      label: '${l10n.timerLabel}: ${restTime}s',
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
            content: Text(context.l10n.errorUpdatingExercise),
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