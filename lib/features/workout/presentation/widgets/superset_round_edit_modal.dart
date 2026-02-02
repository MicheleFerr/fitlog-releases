import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Modal per modificare un singolo round di superset
/// Permette di inserire peso, ripetizioni e RPE per ogni esercizio del round
class SupersetRoundEditModal extends ConsumerStatefulWidget {
  const SupersetRoundEditModal({
    super.key,
    required this.superset,
    required this.supersetSet,
    required this.roundNumber,
    required this.onSetUpdate,
  });
  final SupersetExercise superset;
  final SupersetSet supersetSet;
  final int roundNumber;
  final Function(SupersetSet) onSetUpdate;

  @override
  ConsumerState<SupersetRoundEditModal> createState() =>
      _SupersetRoundEditModalState();
}

class _SupersetRoundEditModalState
    extends ConsumerState<SupersetRoundEditModal> {
  late Map<String, SupersetExerciseData> _editingData;
  late Map<String, TextEditingController> _weightControllers;
  late Map<String, TextEditingController> _repsControllers;
  late Map<String, TextEditingController> _rpeControllers;
  late Map<String, bool> _completedStates;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _editingData = Map.from(widget.supersetSet.exerciseData);
    _weightControllers = {};
    _repsControllers = {};
    _rpeControllers = {};
    _completedStates = {};

    for (final exercise in widget.superset.exercises) {
      final exerciseData = _editingData[exercise.id];

      _weightControllers[exercise.id] = TextEditingController(
        text: exerciseData?.actualWeight?.toString() ?? '',
      );

      _repsControllers[exercise.id] = TextEditingController(
        text: exerciseData?.actualReps?.toString() ?? '',
      );

      _rpeControllers[exercise.id] = TextEditingController(
        text: exerciseData?.rpe?.toString() ?? '',
      );

      _completedStates[exercise.id] = exerciseData?.isCompleted ?? false;

      // Ensure exercise data exists
      if (exerciseData == null) {
        _editingData[exercise.id] = SupersetExerciseData(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          targetWeight: null,
          targetReps: 12, // Default target reps
          actualWeight: null,
          actualReps: null,
          rpe: null,
          isCompleted: false,
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _weightControllers.values) {
      controller.dispose();
    }
    for (final controller in _repsControllers.values) {
      controller.dispose();
    }
    for (final controller in _rpeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.superset.name} - ${l10n.roundNumber(widget.roundNumber)}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.editRoundData,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Exercise list
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: widget.superset.exercises.map((exercise) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildExerciseEditCard(context, l10n, exercise),
                  );
                }).toList(),
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseEditCard(
    BuildContext context,
    AppLocalizations l10n,
    Exercise exercise,
  ) {
    final exerciseData = _editingData[exercise.id]!;
    final isCompleted = _completedStates[exercise.id] ?? false;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.category.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Completed checkbox
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _completedStates[exercise.id] = value ?? false;
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Input fields
            Row(
              children: [
                // Weight input
                Expanded(
                  child: _buildInputField(
                    context: context,
                    label: l10n.weightKg,
                    controller: _weightControllers[exercise.id]!,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    suffixText: 'kg',
                  ),
                ),

                const SizedBox(width: 12),

                // Reps input
                Expanded(
                  child: _buildInputField(
                    context: context,
                    label: l10n.reps,
                    controller: _repsControllers[exercise.id]!,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),

                const SizedBox(width: 12),

                // RPE input
                Expanded(
                  child: _buildInputField(
                    context: context,
                    label: 'RPE',
                    controller: _rpeControllers[exercise.id]!,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _RPETextInputFormatter(),
                    ],
                    helperText: '1-10',
                  ),
                ),
              ],
            ),

            // Target info (if available)
            if (exerciseData.targetWeight != null ||
                exerciseData.targetReps != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${l10n.target}: ${exerciseData.targetReps ?? 12} ${l10n.reps}${exerciseData.targetWeight != null ? ' • ${exerciseData.targetWeight}kg' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required List<TextInputFormatter> inputFormatters,
    String? suffixText,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffixText,
        helperText: helperText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onTap: () => controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      ),
    );
  }

  void _saveChanges() {
    // Update exercise data with current input values
    final updatedExerciseData = <String, SupersetExerciseData>{};

    for (final exercise in widget.superset.exercises) {
      final originalData = _editingData[exercise.id]!;
      final weightText = _weightControllers[exercise.id]!.text.trim();
      final repsText = _repsControllers[exercise.id]!.text.trim();
      final rpeText = _rpeControllers[exercise.id]!.text.trim();
      final isCompleted = _completedStates[exercise.id] ?? false;

      updatedExerciseData[exercise.id] = SupersetExerciseData(
        exerciseId: originalData.exerciseId,
        exerciseName: originalData.exerciseName,
        targetWeight: originalData.targetWeight,
        targetReps: originalData.targetReps,
        actualWeight: weightText.isNotEmpty
            ? double.tryParse(weightText)
            : null,
        actualReps: repsText.isNotEmpty ? int.tryParse(repsText) : null,
        rpe: rpeText.isNotEmpty ? int.tryParse(rpeText) : null,
        isCompleted: isCompleted,
        notes: originalData.notes,
      );
    }

    // Create updated superset set
    final updatedSet = SupersetSet(
      id: widget.supersetSet.id,
      setNumber: widget.supersetSet.setNumber,
      exerciseData: updatedExerciseData,
      isCompleted: updatedExerciseData.values.every((data) => data.isCompleted),
      completedAt: updatedExerciseData.values.every((data) => data.isCompleted)
          ? DateTime.now()
          : null,
      setDurationMillis: widget.supersetSet.setDurationMillis,
      setStartedAt: widget.supersetSet.setStartedAt,
      isWarmup: widget.supersetSet.isWarmup,
      notes: widget.supersetSet.notes,
    );

    // Call the update callback
    widget.onSetUpdate(updatedSet);

    // Close modal
    Navigator.of(context).pop();

    // Show success feedback
    SnackBarService.showInfo(context, context.l10n.setUpdated);
  }
}

/// Custom input formatter for RPE values (limits to 1-10)
class _RPETextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final value = int.tryParse(newValue.text);
    if (value == null) {
      return oldValue;
    }

    // Limit to 1-10 range
    if (value < 1 || value > 10) {
      return oldValue;
    }

    return newValue;
  }
}
