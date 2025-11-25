import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

// Import core entities
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

// Import modal widgets
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/unified_set_input_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/enhanced_add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_options_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Admin-only modal tester widget with collapsible sections
class AdminModalTesterWidget extends ConsumerWidget {
  const AdminModalTesterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = ref.watch(showDebugSectionsProvider);

    // Don't show if not admin
    if (!isAdmin) {
      return const SizedBox.shrink();
    }

    final debugStates = ref.watch(debugSectionStatesProvider);
    final isMainCollapsed = debugStates['modal_tester'] ?? true;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with collapse button
            InkWell(
              onTap: () {
                ref.read(debugSectionStatesProvider.notifier).toggle('modal_tester');
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isMainCollapsed ? AppIcons.expandMore : AppIcons.expandLess,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Icon(AppIcons.bugReport,
                      color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🧪 MODAL TESTER - Debug Mode',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (isMainCollapsed)
                            Text(
                              'Tap to expand debug sections',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ADMIN',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Collapsible content
            if (!isMainCollapsed) ...[
              const SizedBox(height: 8),
              Text(
                'Test all workout modals to identify duplicates and determine which ones to keep',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Input Data Modals Section
              _CollapsibleSection(
                sectionId: 'input_data',
                title: 'INPUT DATA MODALS',
                children: [
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
                ],
              ),

              const SizedBox(height: 12),

              // Add Exercise Modals Section
              _CollapsibleSection(
                sectionId: 'add_exercise',
                title: 'ADD EXERCISE MODALS',
                children: [
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
                ],
              ),

              const SizedBox(height: 12),

              // Edit & Options Modals Section
              _CollapsibleSection(
                sectionId: 'edit_options',
                title: 'EDIT & OPTIONS MODALS',
                children: [
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
                ],
              ),

              const SizedBox(height: 16),

              // Collapse All button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(debugSectionStatesProvider.notifier).collapseAll();
                  },
                  icon: const SemanticIcon(
  icon: AppIcons.unfoldLess,
  semanticLabel: 'Collapse',
),
                  label: const Text('Collapse All Sections'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Mock data for tests
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

  // Test methods
  void _testUnifiedSetInputModal(BuildContext context) {
    UnifiedSetInputModal.show(
      context: context,
      exerciseSet: _getMockExerciseSet(),
      exerciseName: 'Test Exercise',
      onSave: (set) {
        SnackBarService.showSuccess(context, '✅ UnifiedSetInputModal - WORKING');
      },
    );
  }

  void _testWeightPickerModal(BuildContext context) {
    _showPlaceholderMessage(context, 'WeightPickerModal - Need implementation');
  }

  void _testRepsPickerModal(BuildContext context) {
    _showPlaceholderMessage(context, 'RepsPickerModal - Need implementation');
  }

  void _testRpeSelectorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => RpeSelectorBottomSheet(
        set: _getMockExerciseSet(),
        targetReps: 10,
        onConfirm: (actualReps, actualWeight, rpe) {
          Navigator.of(context).pop();
          SnackBarService.showSuccess(context, '✅ RpeSelectorBottomSheet - RPE: $rpe');
        },
      ),
    );
  }

  void _testAddExerciseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddExerciseModal(),
    );
  }

  void _testEnhancedAddExerciseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const EnhancedAddExerciseModal(),
    );
  }

  void _testExerciseOptionsModal(BuildContext context) {
    ExerciseOptionsModal.show(
      context,
      _getMockExercise(),
      onHistory: () {
        SnackBarService.showInfo(context, '📊 History tapped');
      },
      onEdit: () {
        SnackBarService.showInfo(context, '✏️ Edit tapped');
      },
    );
  }

  void _testEditExerciseModal(BuildContext context) {
    _showPlaceholderMessage(context, 'EditExerciseModal');
  }

  void _testEditSetModal(BuildContext context) {
    _showPlaceholderMessage(context, 'EditSetModal');
  }

  void _showPlaceholderMessage(BuildContext context, String modalName) {
    SnackBarService.showWarning(context, '🚧 $modalName - Need to implement');
  }
}

/// Collapsible section widget
class _CollapsibleSection extends ConsumerWidget {

  const _CollapsibleSection({
    required this.sectionId,
    required this.title,
    required this.children,
  });
  final String sectionId;
  final String title;
  final List<_ModalTestButton> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCollapsed = ref.watch(debugSectionStatesProvider.select(
      (state) => state[sectionId] ?? true
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            ref.read(debugSectionStatesProvider.notifier).toggle(sectionId);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCollapsed ? AppIcons.chevronRight : AppIcons.expandMore,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${children.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isCollapsed) ...[
          const SizedBox(height: 8),
          ...children.map((button) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: button.onPressed,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      button.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      button.description,
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
      ],
    );
  }
}

class _ModalTestButton {
  _ModalTestButton(this.name, this.onPressed, this.description);

  final String name;
  final VoidCallback onPressed;
  final String description;
}
