import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import core entities
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

// Import modal widgets
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/unified_set_input_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/enhanced_add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_options_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';


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
                Icon(Icons.bug_report, 
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
                'UnifiedSetInputModal',
                () => _testUnifiedSetInputModal(context),
                'Primary modal for weight/reps/RPE',
              ),
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

  // Test methods per ogni modal
  void _testUnifiedSetInputModal(BuildContext context) {
    UnifiedSetInputModal.show(
      context: context,
      exerciseSet: _getMockExerciseSet(),
      exerciseName: 'Test Exercise',
      onSave: (set) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.modalTestSuccess('UnifiedSetInputModal'))),
        );
      },
    );
  }
  
  void _testWeightPickerModal(BuildContext context) {
    _showPlaceholderMessage(context, 'WeightPickerModal - Extension method not found');
  }
  
  void _testRepsPickerModal(BuildContext context) {
    _showPlaceholderMessage(context, 'RepsPickerModal - Extension method not found');
  }
  
  void _testRpeSelectorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => RpeSelectorBottomSheet(
        set: _getMockExerciseSet(),
        targetReps: 10,
        onConfirm: (actualReps, actualWeight, rpe) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.modalTestRpeSuccess(rpe.toString()))),
          );
        },
      ),
    );
  }
  
  void _testAddExerciseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddExerciseModal(),
    ).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.modalTestOpened('AddExerciseModal'))),
        );
      }
    }).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.modalTestError('AddExerciseModal', e.toString()))),
        );
      }
    });
  }
  
  void _testEnhancedAddExerciseModal(BuildContext context) {
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => const EnhancedAddExerciseModal(),
      ).then((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.modalTestOpened('EnhancedAddExerciseModal'))),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.modalTestError('EnhancedAddExerciseModal', e.toString()))),
      );
    }
  }
  
  void _testExerciseOptionsModal(BuildContext context) {
    ExerciseOptionsModal.show(
      context,
      _getMockExercise(),
      onHistory: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.historyButtonTapped)),
        );
      },
      onEdit: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.editButtonTapped)),
        );
      },
    );
  }
  
  // Placeholder methods for other modals (to be implemented if they exist)
  void _testEditExerciseModal(BuildContext context) {
    _showPlaceholderMessage(context, 'EditExerciseModal');
  }
  
  void _testEditSetModal(BuildContext context) {
    _showPlaceholderMessage(context, 'EditSetModal');
  }
  
  void _testCreateTemplateModal(BuildContext context) {
    _showPlaceholderMessage(context, 'CreateTemplateModal');
  }
  
  void _testExerciseReplacementModal(BuildContext context) {
    _showPlaceholderMessage(context, 'ExerciseReplacementModal');
  }
  
  void _testExerciseReplacementDialog(BuildContext context) {
    _showPlaceholderMessage(context, 'ExerciseReplacementDialog');
  }
  
  void _testWorkoutCustomizationModal(BuildContext context) {
    _showPlaceholderMessage(context, 'WorkoutCustomizationModal');
  }
  
  void _testRestTimePickerModal(BuildContext context) {
    _showPlaceholderMessage(context, 'RestTimePickerModal');
  }
  
  void _testSupersetQuickEditModal(BuildContext context) {
    _showPlaceholderMessage(context, 'SupersetQuickEditModal');
  }
  
  void _testSupersetRoundEditModal(BuildContext context) {
    _showPlaceholderMessage(context, 'SupersetRoundEditModal');
  }
  
  void _testSupersetExecutionSheet(BuildContext context) {
    _showPlaceholderMessage(context, 'SupersetExecutionSheet');
  }
  
  void _testSupersetExecutionSheetV2(BuildContext context) {
    _showPlaceholderMessage(context, 'SupersetExecutionSheetV2');
  }
  
  void _testDropsetExecutionSheet(BuildContext context) {
    _showPlaceholderMessage(context, 'DropsetExecutionSheet');
  }
  
  void _testRestpauseExecutionSheet(BuildContext context) {
    _showPlaceholderMessage(context, 'RestpauseExecutionSheet');
  }
  
  void _showPlaceholderMessage(BuildContext context, String modalName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚧 $modalName - Need to implement test'),
        backgroundColor: context.colors.secondary,
      ),
    );
  }
}

class _ModalTestButton {
  _ModalTestButton(this.name, this.onPressed, this.description);
  
  final String name;
  final VoidCallback onPressed;
  final String description;
}