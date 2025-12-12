import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import core entities
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

// Import modal widgets
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/enhanced_add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_options_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/weight_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/reps_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/edit_set_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/edit_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/create_template_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rest_time_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_replacement_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_customization_modal_v3.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_round_edit_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/dropset_execution_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_sequential_execution_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';


/// Widget per testare tutti i modal identificati nell'analisi
/// Permette di capire quali sono funzionanti e quali sono duplicati
class ModalTesterWidget extends ConsumerWidget {
  const ModalTesterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.bugReport, 
                  color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '🧪 MODAL TESTER - Debug Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Test all workout modals to identify duplicates and determine which ones to keep',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildModalSection(context, 'INPUT DATA MODALS', [
              _ModalTestButton(
                'WeightPickerModal',
                () => _testWeightPickerModal(context),
                'Dedicated weight selection',
              ),
              _ModalTestButton(
                'RepsPickerModal',
                () => _testRepsPickerModal(context), 
                'Dedicated reps selection',
              ),
              _ModalTestButton(
                'RPE Selector Bottom Sheet',
                () => _testRpeSelectorBottomSheet(context),
                'RPE scale with colors',
              ),
            ]),
            
            const SizedBox(height: 12),
            
            _buildModalSection(context, 'ADD EXERCISE MODALS', [
              _ModalTestButton(
                'AddExerciseModal',
                () => _testAddExerciseModal(context),
                'Original add exercise with 4 tabs',
              ),
              _ModalTestButton(
                'EnhancedAddExerciseModal',
                () => _testEnhancedAddExerciseModal(context),
                'Enhanced version - POSSIBLE DUPLICATE?',
              ),
            ]),
            
            const SizedBox(height: 12),
            
            _buildModalSection(context, 'EXECUTION SHEETS', [
              _ModalTestButton(
                'SupersetExecutionSheet',
                () => _testSupersetExecutionSheet(context),
                'Superset guided execution',
              ),
              _ModalTestButton(
                'SupersetExecutionSheet V2',
                () => _testSupersetExecutionSheetV2(context),
                'V2 - POSSIBLE DUPLICATE?',
              ),
              _ModalTestButton(
                'DropsetExecutionSheet',
                () => _testDropsetExecutionSheet(context),
                'Drop set execution',
              ),
              _ModalTestButton(
                'RestpauseExecutionSheet',
                () => _testRestpauseExecutionSheet(context),
                'Rest-pause execution',
              ),
            ]),
            
            const SizedBox(height: 12),
            
            _buildModalSection(context, 'EDIT & OPTIONS MODALS', [
              _ModalTestButton(
                'ExerciseOptionsModal',
                () => _testExerciseOptionsModal(context),
                'Full options menu for exercises',
              ),
              _ModalTestButton(
                'EditExerciseModal',
                () => _testEditExerciseModal(context),
                'Edit exercise name/notes',
              ),
              _ModalTestButton(
                'EditSetModal',
                () => _testEditSetModal(context),
                'Edit single set data',
              ),
              _ModalTestButton(
                'ExerciseReplacementModal',
                () => _testExerciseReplacementModal(context),
                'Replace exercises with alternatives',
              ),
              _ModalTestButton(
                'ExerciseReplacementDialog',
                () => _testExerciseReplacementDialog(context),
                'Replacement confirmation dialog',
              ),
            ]),
            
            const SizedBox(height: 12),
            
            _buildModalSection(context, 'CONFIGURATION MODALS', [
              _ModalTestButton(
                'CreateTemplateModal',
                () => _testCreateTemplateModal(context),
                'Create workout template',
              ),
              _ModalTestButton(
                'WorkoutCustomizationModal',
                () => _testWorkoutCustomizationModal(context),
                'Workout settings customization',
              ),
              _ModalTestButton(
                'RestTimePickerModal',
                () => _testRestTimePickerModal(context),
                'Rest time selection',
              ),
            ]),
            
            const SizedBox(height: 12),
            
            _buildModalSection(context, 'SUPERSET QUICK ACTIONS', [
              _ModalTestButton(
                'SupersetQuickEditModal',
                () => _testSupersetQuickEditModal(context),
                'Quick edit for superset',
              ),
              _ModalTestButton(
                'SupersetRoundEditModal', 
                () => _testSupersetRoundEditModal(context),
                'Edit superset rounds',
              ),
            ]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModalSection(BuildContext context, String title, List<_ModalTestButton> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...buttons.map((button) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: button.onPressed,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(button.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(button.description, 
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  // Mock data per i test
  ExerciseSet _getMockExerciseSet() {
    return ExerciseSet(
      setNumber: 1,
      weight: 20.0,
      reps: 10,
      actualReps: 10,
      rpe: 7,
      isCompleted: false,
      notes: 'Test set',
    );
  }
  
  Exercise _getMockExercise() {
    return Exercise(
      name: 'Test Exercise',
      type: ExerciseType.single,
      category: ExerciseCategory.chest,
      sets: [_getMockExerciseSet()],
      notes: 'Mock exercise for testing',
    );
  }

  /// Mock superset exercise for testing superset modals
  SupersetExercise _getMockSupersetExercise() {
    final exercise1 = Exercise(
      name: 'Bench Press',
      type: ExerciseType.single,
      category: ExerciseCategory.chest,
      sets: [_getMockExerciseSet()],
    );
    final exercise2 = Exercise(
      name: 'Bent Over Row',
      type: ExerciseType.single,
      category: ExerciseCategory.back,
      sets: [_getMockExerciseSet()],
    );

    return SupersetExercise(
      name: 'Test Superset',
      exercises: [exercise1, exercise2],
      supersetSets: [
        SupersetSet(
          setNumber: 1,
          exerciseData: {
            exercise1.id: SupersetExerciseData(
              exerciseId: exercise1.id,
              exerciseName: exercise1.name,
              targetWeight: 60.0,
              targetReps: 10,
            ),
            exercise2.id: SupersetExerciseData(
              exerciseId: exercise2.id,
              exerciseName: exercise2.name,
              targetWeight: 50.0,
              targetReps: 12,
            ),
          },
        ),
        SupersetSet(
          setNumber: 2,
          exerciseData: {
            exercise1.id: SupersetExerciseData(
              exerciseId: exercise1.id,
              exerciseName: exercise1.name,
              targetWeight: 60.0,
              targetReps: 10,
            ),
            exercise2.id: SupersetExerciseData(
              exerciseId: exercise2.id,
              exerciseName: exercise2.name,
              targetWeight: 50.0,
              targetReps: 12,
            ),
          },
        ),
      ],
    );
  }

  /// Mock dropset exercise for testing dropset modals
  DropSetExercise _getMockDropsetExercise() {
    return DropSetExercise(
      name: 'Test Dropset - Dumbbell Curl',
      category: ExerciseCategory.arms,
      stages: [
        DropSetStage(
          weight: 15.0,
          reps: 8,
        ),
        DropSetStage(
          weight: 12.0,
          reps: 8,
        ),
        DropSetStage(
          weight: 8.0,
          reps: 10,
        ),
      ],
    );
  }

  // Test methods per ogni modal
  void _testWeightPickerModal(BuildContext context) async {
    final result = await WeightPickerModal.show(context, initialWeight: 20.0);
    if (result != null && context.mounted) {
      SnackBarService.showSuccess(context, '✅ WeightPickerModal - Selected: ${result.toStringAsFixed(1)} kg');
    } else if (context.mounted) {
      SnackBarService.showInfo(context, '⚪ WeightPickerModal - Cancelled');
    }
  }

  void _testRepsPickerModal(BuildContext context) async {
    final result = await RepsPickerModal.show(context, initialReps: 10);
    if (result != null && context.mounted) {
      SnackBarService.showSuccess(context, '✅ RepsPickerModal - Selected: $result reps');
    } else if (context.mounted) {
      SnackBarService.showInfo(context, '⚪ RepsPickerModal - Cancelled');
    }
  }
  
  void _testRpeSelectorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => RpeSelectorBottomSheet(
        set: _getMockExerciseSet(),
        targetReps: 10,
        onConfirm: (actualReps, actualWeight, rpe) {
          Navigator.of(ctx).pop();
          if (context.mounted) {
            SnackBarService.showSuccess(
              context,
              '✅ RpeSelectorBottomSheet - RPE: $rpe, Reps: $actualReps, Weight: $actualWeight',
            );
          }
        },
      ),
    );
  }
  
  void _testAddExerciseModal(BuildContext context) {
    // ✅ UX: Use the new static show method
    AddExerciseModal.show(context).then((_) {
      if (context.mounted) {
        SnackBarService.showInfo(context, '✅ AddExerciseModal - Closed');
      }
    }).catchError((e) {
      if (context.mounted) {
        SnackBarService.showError(context, '❌ AddExerciseModal error: $e');
      }
    });
  }

  void _testEnhancedAddExerciseModal(BuildContext context) {
    try {
      final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.98);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.9,
          maxChildSize: safeMax,
          expand: false,
          snap: true,
          builder: (context, scrollController) => EnhancedAddExerciseModal(
            scrollController: scrollController,
          ),
        ),
      ).then((_) {
        if (context.mounted) {
          SnackBarService.showInfo(context, '✅ EnhancedAddExerciseModal - Closed');
        }
      });
    } catch (e) {
      SnackBarService.showError(context, '❌ EnhancedAddExerciseModal error: $e');
    }
  }

  void _testExerciseOptionsModal(BuildContext context) {
    ExerciseOptionsModal.show(
      context,
      _getMockExercise(),
      onHistory: () {
        SnackBarService.showInfo(context, '📊 History button tapped');
      },
      onEdit: () {
        SnackBarService.showInfo(context, '✏️ Edit button tapped');
      },
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // EDIT & OPTIONS MODALS
  // ═══════════════════════════════════════════════════════════════

  void _testEditExerciseModal(BuildContext context) {
    context.showEditExerciseModal(
      _getMockExercise(),
      (updatedExercise) {
        SnackBarService.showSuccess(
          context,
          '✅ EditExerciseModal - Updated: ${updatedExercise.name}',
        );
      },
    );
  }

  void _testEditSetModal(BuildContext context) {
    context.showEditSetModal(
      _getMockExerciseSet(),
      (updatedSet) {
        SnackBarService.showSuccess(
          context,
          '✅ EditSetModal - Updated: ${updatedSet.weight}kg × ${updatedSet.reps} reps',
        );
      },
      exercise: _getMockExercise(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CONFIGURATION MODALS
  // ═══════════════════════════════════════════════════════════════

  void _testCreateTemplateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateTemplateModal(),
    ).then((_) {
      if (context.mounted) {
        SnackBarService.showInfo(context, '✅ CreateTemplateModal - Closed');
      }
    });
  }

  void _testExerciseReplacementModal(BuildContext context) {
    ExerciseReplacementModal.show(
      context,
      _getMockExercise(),
      (replacementExercise) {
        SnackBarService.showSuccess(
          context,
          '✅ ExerciseReplacementModal - Replaced with: ${replacementExercise.name}',
        );
      },
    );
  }

  void _testExerciseReplacementDialog(BuildContext context) {
    // This is the same as ExerciseReplacementModal
    _testExerciseReplacementModal(context);
  }

  void _testWorkoutCustomizationModal(BuildContext context) {
    WorkoutCustomizationModalV3.show(context).then((_) {
      if (context.mounted) {
        SnackBarService.showSuccess(context, '✅ WorkoutCustomizationModalV3 - Settings saved');
      }
    });
  }

  void _testRestTimePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => RestTimePickerModal(
        initialRestTime: 90,
        onRestTimeSelected: (seconds) {
          Navigator.of(ctx).pop();
          if (context.mounted) {
            if (seconds != null) {
              SnackBarService.showSuccess(context, '✅ RestTimePickerModal - Selected: ${seconds}s');
            } else {
              SnackBarService.showInfo(context, '⚪ RestTimePickerModal - Default timer');
            }
          }
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SUPERSET & ADVANCED EXECUTION SHEETS
  // ═══════════════════════════════════════════════════════════════

  void _testSupersetQuickEditModal(BuildContext context) {
    // SupersetQuickEditModal doesn't exist - it's been replaced by SupersetRoundEditModal
    SnackBarService.showWarning(context, '⚠️ SupersetQuickEditModal replaced by SupersetRoundEditModal');
  }

  void _testSupersetRoundEditModal(BuildContext context) {
    final mockSuperset = _getMockSupersetExercise();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SupersetRoundEditModal(
        superset: mockSuperset,
        supersetSet: mockSuperset.supersetSets.first,
        roundNumber: 1,
        onSetUpdate: (updatedSet) {
          Navigator.of(ctx).pop();
          if (context.mounted) {
            SnackBarService.showSuccess(context, '✅ SupersetRoundEditModal - Round updated');
          }
        },
      ),
    );
  }

  void _testSupersetExecutionSheet(BuildContext context) {
    // SupersetExecutionSheet has been replaced by SupersetSequentialExecutionSheet
    _testSupersetExecutionSheetV2(context);
  }

  void _testSupersetExecutionSheetV2(BuildContext context) {
    final mockSuperset = _getMockSupersetExercise();
    SupersetSequentialExecutionSheet.show(
      context: context,
      superset: mockSuperset,
      roundIndex: 0,
      onRoundCompleted: (completedRound) {
        SnackBarService.showSuccess(context, '✅ SupersetSequentialExecutionSheet - Round completed');
      },
      onAllRoundsCompleted: () {
        SnackBarService.showSuccess(context, '🎉 All superset rounds completed!');
      },
    );
  }

  void _testDropsetExecutionSheet(BuildContext context) {
    final mockDropset = _getMockDropsetExercise();
    DropSetExecutionModal.show(
      context: context,
      exercise: mockDropset,
    ).then((_) {
      if (context.mounted) {
        SnackBarService.showInfo(context, '✅ DropSetExecutionModal - Closed');
      }
    });
  }

  void _testRestpauseExecutionSheet(BuildContext context) {
    // RestPause uses the same execution pattern as DropSet
    SnackBarService.showWarning(context, '⚠️ RestPauseExecutionSheet - Uses DropSet pattern (not separate modal)');
  }
}

class _ModalTestButton {
  _ModalTestButton(this.name, this.onPressed, this.description);
  
  final String name;
  final VoidCallback onPressed;
  final String description;
}