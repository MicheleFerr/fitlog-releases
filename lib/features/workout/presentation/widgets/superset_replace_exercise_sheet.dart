import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    show ExerciseDefinition;
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Bottom sheet per sostituire un singolo esercizio all'interno di un superset.
///
/// Flow a 2 step:
/// 1. L'utente sceglie QUALE esercizio del superset vuole sostituire
/// 2. Si apre ExerciseSearchScreen in selectionMode (tap singolo, niente multi-select)
/// 3. Dialog di conferma "Sostituire X con Y?"
///
/// La sostituzione avviene in TUTTI i round del superset.
/// Opzione per mantenere peso e ripetizioni.
class SupersetReplaceExerciseSheet extends ConsumerStatefulWidget {
  const SupersetReplaceExerciseSheet({
    super.key,
    required this.superset,
    required this.onReplaceExercise,
  });

  final SupersetExercise superset;

  /// Callback con: esercizio da sostituire, nuovo esercizio, mantenere peso/reps
  final void Function(
    Exercise oldExercise,
    Exercise newExercise,
    bool keepWeightAndReps,
  ) onReplaceExercise;

  static Future<void> show({
    required BuildContext context,
    required SupersetExercise superset,
    required void Function(
      Exercise oldExercise,
      Exercise newExercise,
      bool keepWeightAndReps,
    ) onReplaceExercise,
  }) {
    return ModalService.showSheet<void>(context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.3,
          maxChildSize: 0.6,
          expand: false,
          snap: true,
          builder: (context, scrollController) =>
              SupersetReplaceExerciseSheet(
            superset: superset,
            onReplaceExercise: onReplaceExercise,
          ),
        ),
    );
  }

  @override
  ConsumerState<SupersetReplaceExerciseSheet> createState() =>
      _SupersetReplaceExerciseSheetState();
}

class _SupersetReplaceExerciseSheetState
    extends ConsumerState<SupersetReplaceExerciseSheet> {
  bool _keepWeightAndReps = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              l10n.selectExerciseToReplace,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Superset name subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.link,
                  semanticLabel: 'Superset',
                  size: AppIconSize.small,
                  color: context.colors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.superset.name,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Exercise chips - one per exercise in the superset
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: widget.superset.exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return _buildExerciseOption(context, exercise, index);
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Keep weight/reps toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.keepWeightAndReps,
                    style: context.textTheme.bodyMedium,
                  ),
                ),
                CNSwitch(
                  value: _keepWeightAndReps,
                  onChanged: (value) {
                    setState(() => _keepWeightAndReps = value);
                    HapticFeedback.lightImpact();
                  },
                  color: context.colors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildExerciseOption(
    BuildContext context,
    Exercise exercise,
    int index,
  ) {
    final letter = String.fromCharCode(65 + index); // A, B, C...

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _onExerciseSelected(exercise),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Letter badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Exercise name
                Expanded(
                  child: Text(
                    exercise.name,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Arrow icon
                SemanticIcon(
                  icon: AppIcons.chevronRight,
                  semanticLabel: context.l10n.replace,
                  size: AppIconSize.small,
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onExerciseSelected(Exercise exerciseToReplace) async {
    // Close this bottom sheet
    Navigator.of(context).pop();

    // Capture callback and state before async gap
    final onReplace = widget.onReplaceExercise;
    final keepWeightAndReps = _keepWeightAndReps;
    final rootContext = context;

    // Open ExerciseSearchScreen in selectionMode (single tap = select & return)
    final selectedDbExercise = await Navigator.of(rootContext).push<ExerciseDefinition>(
      MaterialPageRoute(
        builder: (_) => const ExerciseSearchScreen(
          selectionMode: true,
          showSupersetTemplates: false,
        ),
      ),
    );

    // User cancelled (pressed back)
    if (selectedDbExercise == null) return;
    if (!rootContext.mounted) return;

    // Convert DB exercise to workout exercise
    final newExercise = ExerciseConverter.fromDatabaseExercise(selectedDbExercise);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: rootContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.replaceExercise),
        content: Text(
          dialogContext.l10n.replaceExerciseConfirmation(
            exerciseToReplace.name,
            newExercise.name,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.l10n.replaceInAllRounds),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!rootContext.mounted) return;

    // Execute replacement
    onReplace(exerciseToReplace, newExercise, keepWeightAndReps);

    // Show success snackbar
    SnackBarService.showSuccess(
      rootContext,
      rootContext.l10n.exerciseReplacedSuccess(
        exerciseToReplace.name,
        newExercise.name,
      ),
    );
  }
}
