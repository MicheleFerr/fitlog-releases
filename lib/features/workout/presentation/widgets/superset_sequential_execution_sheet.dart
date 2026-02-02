import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_edit_overlay_v2.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Widget per esecuzione SEQUENZIALE superset secondo metodologia scientifica
///
/// Flow corretto:
/// 1. User tap "Esegui Round" → apre RpeSelectorBottomSheet con tutti gli esercizi
/// 2. User completa Esercizio A → RPE + peso + reps
/// 3. User completa Esercizio B → RPE + peso + reps
/// 4. Salva round completato
/// 5. Avvia timer riposo (90sec default)
/// 6. Timer finisce → pronto per Round successivo
class SupersetSequentialExecutionSheet extends ConsumerStatefulWidget {
  const SupersetSequentialExecutionSheet({
    super.key,
    required this.superset,
    required this.roundIndex,
    required this.onRoundCompleted,
    this.onAllRoundsCompleted,
  });
  final SupersetExercise superset;
  final int roundIndex;
  final Function(SupersetSet completedRound) onRoundCompleted;
  final VoidCallback? onAllRoundsCompleted;

  /// Static method to show the sheet with proper sizing (like RPE selector)
  ///
  /// Content-based height, swipe down to close
  static Future<void> show({
    required BuildContext context,
    required SupersetExercise superset,
    required int roundIndex,
    required Function(SupersetSet completedRound) onRoundCompleted,
    VoidCallback? onAllRoundsCompleted,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => SupersetSequentialExecutionSheet(
        superset: superset,
        roundIndex: roundIndex,
        onRoundCompleted: onRoundCompleted,
        onAllRoundsCompleted: onAllRoundsCompleted,
      ),
    );
  }

  @override
  ConsumerState<SupersetSequentialExecutionSheet> createState() =>
      _SupersetSequentialExecutionSheetState();
}

class _SupersetSequentialExecutionSheetState
    extends ConsumerState<SupersetSequentialExecutionSheet> {
  bool get _isLastRound =>
      widget.roundIndex >= widget.superset.supersetSets.length - 1;

  /// Mostra RpeSelectorBottomSheet per completare tutti gli esercizi del round
  Future<void> _executeRound() async {
    // Ottieni configurazione del round corrente
    final currentRound = widget.superset.supersetSets[widget.roundIndex];

    // Prendi il primo esercizio per iniziare
    final firstExercise = widget.superset.exercises.first;
    final exerciseData = currentRound.exerciseData[firstExercise.id];

    if (exerciseData == null) {
      _showError(context.l10n.exerciseDataNotFound);
      return;
    }

    // Crea ExerciseSet per il primo esercizio (richiesto da RpeSelectorBottomSheet)
    final exerciseSet = ExerciseSet(
      id: firstExercise.id,
      setNumber: widget.roundIndex + 1,
      weight: exerciseData.actualWeight ?? exerciseData.targetWeight,
      reps: exerciseData.targetReps,
      isCompleted: false,
    );

    // ✅ FIX: Chiudi questo modal PRIMA di aprire il RPE selector
    // Altrimenti due modal sovrapposti causano freeze
    Navigator.of(context).pop();

    // Attendi un frame per permettere l'animazione di chiusura
    await Future.delayed(const Duration(milliseconds: 100));

    // Usa mounted check per evitare errori dopo pop
    if (!mounted) return;

    // Mostra RPE Selector con supporto superset
    await RpeSelectorBottomSheet.show(
      context: context,
      set: exerciseSet,
      targetReps: exerciseData.targetReps ?? 10,
      exercise: firstExercise,

      // ✅ SUPERSET MODE
      isPartOfSuperset: true,
      supersetName: widget.superset.name,
      supersetExercises: widget.superset.exercises,
      supersetSet: currentRound,
      currentExerciseIndex: 0,

      // ✅ Callback quando TUTTI gli esercizi sono completati
      onSupersetCompleteAll: (completeDataMap) {
        _handleRoundCompletion(completeDataMap);
      },

      // ✅ Callback per singolo esercizio (non usato in superset mode)
      onConfirm: (actualReps, actualWeight, rpe) {
        // Non usato quando isPartOfSuperset=true
      },
    );
  }

  /// Gestisce il completamento di tutti gli esercizi del round
  void _handleRoundCompletion(
    Map<int, SupersetExerciseCompleteData> completeDataMap,
  ) {
    // Converti i dati da index-based a ID-based
    final exerciseData = <String, SupersetExerciseData>{};

    for (var i = 0; i < widget.superset.exercises.length; i++) {
      final exercise = widget.superset.exercises[i];
      final data = completeDataMap[i];

      if (data != null) {
        final existing = widget
            .superset
            .supersetSets[widget.roundIndex]
            .exerciseData[exercise.id];

        exerciseData[exercise.id] = SupersetExerciseData(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          targetWeight: existing?.targetWeight ?? 0.0,
          targetReps: existing?.targetReps ?? 10,
          actualWeight: data.actualWeight,
          actualReps: data.actualReps,
          rpe: data.rpe,
          isCompleted: true,
        );
      }
    }

    // Crea SupersetSet completato
    final completedSet = SupersetSet(
      id: widget.superset.supersetSets[widget.roundIndex].id,
      setNumber: widget.roundIndex + 1,
      exerciseData: exerciseData,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    // Notifica completamento round
    widget.onRoundCompleted(completedSet);

    if (_isLastRound) {
      // Era l'ultimo round → completa tutto
      widget.onAllRoundsCompleted?.call();

      // ✅ FIX: Non chiudere modal (già chiuso), solo mostra feedback
      // Il SupersetSequentialExecutionSheet è già stato chiuso in _executeRound()
      if (mounted) {
        SnackBarService.showSuccess(context, context.l10n.supersetCompleted);
      }
    } else {
      // Avvia timer riposo tra round
      _startRestTimer();
    }
  }

  /// Avvia timer usando tier1TimerActions (stesso dell'app)
  Future<void> _startRestTimer() async {
    // Check mounted perché questo widget potrebbe essere già smontato
    if (!mounted) return;

    final timerActions = ref.read(tier1TimerActionsProvider);

    // Durata rest: usa quella del superset o default 90 sec
    final restDuration = widget.superset.restTime ?? 90;

    await timerActions.startExerciseRest(
      seconds: restDuration,
      exerciseName: context.l10n.supersetRestLabel(widget.superset.name),
      currentSet: widget.roundIndex + 2, // Prossimo round
      totalSets: widget.superset.supersetSets.length,
    );
  }

  void _showError(String message) {
    SnackBarService.showError(context, message);
  }

  /// ✅ FIX PROBLEMA 3: Show QuickEditOverlayV2 for editing exercise data
  void _showQuickEdit(Exercise exercise, SupersetExerciseData? exerciseData) {
    if (exerciseData == null) return;

    // Create ExerciseSet from SupersetExerciseData
    final exerciseSet = ExerciseSet(
      id: exercise.id,
      setNumber: widget.roundIndex + 1,
      weight: exerciseData.actualWeight ?? exerciseData.targetWeight ?? 0.0,
      reps: exerciseData.actualReps ?? exerciseData.targetReps ?? 10,
      isCompleted: exerciseData.isCompleted,
    );

    // Get render box for positioning
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final position = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    // Show QuickEditOverlayV2
    showDialog(
      context: context,
      barrierColor: context.colors.onSurface.withValues(alpha: 0.26),
      builder: (context) => Stack(
        children: [
          // Dismiss on tap outside
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: context.colors.surface.withValues(alpha: 0),
            ),
          ),
          // QuickEdit overlay
          QuickEditOverlayV2(
            exerciseSet: exerciseSet,
            exerciseName: exercise.name,
            position: position,
            onSave: (updatedSet) {
              _updateExerciseData(exercise.id, updatedSet);
              Navigator.of(context).pop();
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// ✅ FIX PROBLEMA 3: Update exercise data after QuickEdit
  void _updateExerciseData(String exerciseId, ExerciseSet updatedSet) {
    final currentRound = widget.superset.supersetSets[widget.roundIndex];
    final exerciseData = currentRound.exerciseData[exerciseId];

    if (exerciseData == null) return;

    // Update the exercise data with new values
    final updatedExerciseData = SupersetExerciseData(
      exerciseId: exerciseId,
      exerciseName: exerciseData.exerciseName,
      targetWeight: updatedSet.weight, // Update target with new value
      targetReps: updatedSet.reps, // Update target with new value
      actualWeight: exerciseData.actualWeight,
      actualReps: exerciseData.actualReps,
      rpe: exerciseData.rpe,
      isCompleted: exerciseData.isCompleted,
    );

    // Create updated round with modified exercise data
    final updatedExerciseDataMap = Map<String, SupersetExerciseData>.from(
      currentRound.exerciseData,
    );
    updatedExerciseDataMap[exerciseId] = updatedExerciseData;

    final updatedRound = SupersetSet(
      id: currentRound.id,
      setNumber: currentRound.setNumber,
      exerciseData: updatedExerciseDataMap,
      isCompleted: currentRound.isCompleted,
      completedAt: currentRound.completedAt,
    );

    // Update in provider
    ref
        .read(currentWorkoutProvider.notifier)
        .updateSupersetSet(widget.superset.id, updatedRound);

    // Force rebuild to show updated values
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentRound = widget.superset.supersetSets[widget.roundIndex];
    final completedExercises = currentRound.exerciseData.values
        .where((data) => data.isCompleted)
        .length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header con nome superset
            Row(
              children: [
                Icon(
                  AppIcons.repeat,
                  color: context.colors.secondary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.superset.name,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${context.l10n.round} ${widget.roundIndex + 1}/${widget.superset.supersetSets.length}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const SemanticIcon(
                    icon: AppIcons.close,
                    semanticLabel: 'Close',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ✅ FIX PROBLEMA 3: Lista esercizi con double-tap editing
            ...widget.superset.exercises.map((exercise) {
              final exerciseData = currentRound.exerciseData[exercise.id];
              final isCompleted = exerciseData?.isCompleted ?? false;

              return GestureDetector(
                onDoubleTap: () => _showQuickEdit(exercise, exerciseData),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? context.colors.secondaryContainer
                        : context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted
                          ? context.colors.secondary
                          : context.colors.outline.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted
                            ? AppIcons.checkCircle
                            : AppIcons.radioButtonUnchecked,
                        color: isCompleted
                            ? context.colors.secondary
                            : context.colors.outline,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    exercise.name,
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // ✅ Visual hint for double-tap
                                SemanticIcon(
                                  icon: AppIcons.edit,
                                  semanticLabel: 'Edit',
                                  size: AppIconSize.tiny,
                                  color: context.colors.outline.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            if (exerciseData != null)
                              Text(
                                '${context.l10n.target}: ${exerciseData.targetWeight?.toStringAsFixed(1) ?? '?'} kg × ${exerciseData.targetReps ?? '?'} reps',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.outline,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Info box metodologia
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.info,
                    semanticLabel: 'Information',
                    size: AppIconSize.small,
                    color: context.colors.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.executeAllSequentially,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pulsante per eseguire il round
            FilledButton.icon(
              onPressed: completedExercises > 0 ? null : _executeRound,
              icon: const SemanticIcon(
                icon: AppIcons.workout,
                semanticLabel: 'Workout',
              ),
              label: Text(
                completedExercises > 0
                    ? context.l10n.completed
                    : (_isLastRound
                          ? context.l10n.complete
                          : '${context.l10n.execute} ${context.l10n.round}'),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
