import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

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

  bool _useCustomRestTime = false;
  int? _selectedRestTime;

  // Predefined rest time options in seconds
  static const List<int> _predefinedRestTimes = [
    30,
    60,
    90,
    120,
    180,
    240,
    300,
  ];

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('📝 EditExerciseModal.initState() - Starting initialization');
    }

    try {
      if (kDebugMode) {
        debugPrint('📝 Exercise: ${widget.exercise.name}');
      }
      debugPrint('📝 Rest time: ${widget.exercise.restTime}');

      _nameController = TextEditingController(text: widget.exercise.name);
      _notesController = TextEditingController(
        text: widget.exercise.notes ?? '',
      );

      // Initialize rest time
      _selectedRestTime = widget.exercise.restTime;
      _useCustomRestTime =
          _selectedRestTime != null &&
          !_predefinedRestTimes.contains(_selectedRestTime);
      _restTimeController = TextEditingController(
        text: _useCustomRestTime ? _selectedRestTime?.toString() ?? '' : '',
      );

      if (kDebugMode) {
        debugPrint('📝 Controllers initialized successfully');
      }
      debugPrint('📝 Use custom rest time: $_useCustomRestTime');
      if (kDebugMode) {
        debugPrint('📝 Selected rest time: $_selectedRestTime');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Error in initState: $e');
      }
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
      final l10n = context.l10n;

      // NON wrappare con ErrorBoundary qui - causa loop infiniti
      return GestureDetector(
        onTap: () {
          if (kDebugMode) {
            debugPrint('📝 GestureDetector tapped - unfocusing keyboard');
          }
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
                    color: context.colors.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Icon(
                    AppIcons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.editExercise,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
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
              const SizedBox(height: 20),

              // Exercise name
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.exerciseName,
                  prefixIcon: const SemanticIcon(
                    icon: AppIcons.workout,
                    semanticLabel: 'Workout',
                  ),
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
                  prefixIcon: const SemanticIcon(
                    icon: AppIcons.note,
                    semanticLabel: 'Note',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Rest time section
              Text(
                l10n.exerciseRestTime,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                          color:
                              !_useCustomRestTime && _selectedRestTime == null
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        title: Text(l10n.useDefaultRestTime),
                        subtitle: const Text('120s'),
                        trailing: const Radio<bool>(value: false),
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
                        final isSelected =
                            _selectedRestTime == seconds && !_useCustomRestTime;
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
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                            title: Text(l10n.customRestTime),
                            trailing: const Radio<bool>(value: true),
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
                                  labelText:
                                      '${l10n.exerciseRestTime} (${l10n.restTimeSeconds})',
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
                                    if (seconds != null &&
                                        seconds > 0 &&
                                        seconds <= 3600) {
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
      if (kDebugMode) {
        debugPrint('❌ Error in build method: $e');
      }
      debugPrint('Stack: $stack');

      // Ritorna un widget di errore invece di crashare
      return Material(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.error, color: context.colors.error, size: 48),
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

  void _saveExercise() {
    if (kDebugMode) {
      debugPrint('🔵 _saveExercise called');
    }

    // Wrap everything in a try-catch to prevent any crash
    try {
      // Get localization before any async operations
      final l10n = context.l10n;
      if (kDebugMode) {
        debugPrint('🔵 Got localization');
      }

      final name = _nameController.text.trim();
      if (kDebugMode) {
        debugPrint('🔵 Exercise name: $name');
      }

      if (name.isEmpty) {
        if (mounted) {
          SnackBarService.showError(
            context,
            l10n.exerciseNameCannotBeEmpty(l10n.exerciseName),
          );
        }
        return;
      }

      final notes = _notesController.text.trim();
      if (kDebugMode) {
        debugPrint('🔵 Notes: $notes');
      }
      int? restTime;

      if (kDebugMode) {
        debugPrint('🔵 Use custom rest time: $_useCustomRestTime');
      }
      debugPrint('🔵 Rest time controller text: ${_restTimeController.text}');

      if (_useCustomRestTime) {
        // Validate custom rest time
        final customTime = int.tryParse(_restTimeController.text);
        if (kDebugMode) {
          debugPrint('🔵 Parsed custom time: $customTime');
        }

        if (customTime != null && customTime > 0 && customTime <= 3600) {
          restTime = customTime;
          if (kDebugMode) {
            debugPrint('🔵 Valid custom time set: $restTime');
          }
        } else if (_restTimeController.text.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('🔵 Invalid custom time entered');
          }
          // Invalid custom time entered
          if (mounted) {
            SnackBarService.showError(context, l10n.invalidRestTimeError);
          }
          return;
        }
      } else if (_selectedRestTime != null) {
        restTime = _selectedRestTime;
      }

      if (kDebugMode) {
        debugPrint('🔵 Creating updated exercise...');
      }
      final updatedExercise = widget.exercise.copyWith(
        name: name,
        notes: notes.isEmpty ? null : notes,
        restTime: restTime,
      );
      if (kDebugMode) {
        debugPrint(
          '🔵 Updated exercise created with restTime: ${updatedExercise.restTime}',
        );
      }

      // Call the onSave callback directly
      if (kDebugMode) {
        debugPrint('🔵 Calling onSave callback...');
      }
      try {
        widget.onSave(updatedExercise);
        if (kDebugMode) {
          debugPrint('🔵 onSave callback completed');
        }

        // Show success message
        if (mounted) {
          SnackBarService.showSuccess(context, l10n.exerciseUpdated(name));
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error in onSave callback: $e');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error saving exercise: $e');
      }
      debugPrint('Stack trace: $stackTrace');

      // Show error message to user
      if (mounted) {
        // Try to close modal if still open
        try {
          Navigator.pop(context);
        } catch (_) {
          // Ignore navigation errors
        }

        SnackBarService.showError(context, context.l10n.errorUpdatingExercise);
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
      if (kDebugMode) {
        debugPrint('Error: Cannot show EditExerciseModal with null exercise');
      }
      SnackBarService.showError(this, l10n.errorEditExercise);
      return;
    }

    if (onSave == null) {
      if (kDebugMode) {
        debugPrint(
          'Error: Cannot show EditExerciseModal with null onSave callback',
        );
      }
      return;
    }

    try {
      if (kDebugMode) {
        debugPrint('📝 showEditExerciseModal - Starting');
      }
      debugPrint('📝 Exercise to edit: ${exercise.name}');
      if (kDebugMode) {
        debugPrint('📝 Current context: $this');
      }

      // Dismiss any open keyboard before showing modal
      FocusScope.of(this).unfocus();
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Piccolo delay per permettere alla tastiera di chiudersi

      if (kDebugMode) {
        debugPrint('📝 Showing modal bottom sheet...');
      }

      await ModalService.showSheet(this,
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        backgroundColor: Theme.of(this).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (modalContext) {
          if (kDebugMode) {
            debugPrint('📝 Modal builder called');
          }

          // Wrap in a safe widget per catturare errori
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: EditExerciseModal(exercise: exercise, onSave: onSave),
            ),
          );
        },
      );

      if (kDebugMode) {
        debugPrint('📝 Modal closed successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error showing EditExerciseModal: $e');
      }
      debugPrint('Stack trace: $stackTrace');

      // Show error message to user
      if (mounted) {
        SnackBarService.showError(this, l10n.errorOpeningExerciseEditor);
      }
    }
  }
}
