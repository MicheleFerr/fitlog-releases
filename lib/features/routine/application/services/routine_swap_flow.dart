import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/routine/application/services/routine_matching_service.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/flexible_routine_repository.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Gestisce il flow di swap: mostra dialog, ottiene la decisione dell'utente,
/// esegue lo swap su Firestore
class RoutineSwapFlow {
  const RoutineSwapFlow({required this.repository});

  final FlexibleRoutineRepository repository;

  /// Mostra il dialog di conferma swap e gestisce la decisione
  Future<SwapDecision?> showAndHandleSwapDialog({
    required BuildContext context,
    required RoutineSwapOpportunity swapOpportunity,
    required FlexibleRoutine activeRoutine,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔄 [SwapFlow] Showing swap dialog for ${swapOpportunity.todayScheduledDay.date}',
      );
    }

    final decision = await _showSwapDialog(context, swapOpportunity);

    if (kDebugMode) {
      debugPrint('🔄 [SwapFlow] User decision: $decision');
    }

    if (decision == null) {
      if (kDebugMode) {
        debugPrint('🔄 [SwapFlow] User cancelled, no swap');
      }
      return null;
    }

    // Esegui l'azione basata sulla decisione
    if (!context.mounted) return null;
    return _executeDecision(
      context: context,
      decision: decision,
      swapOpportunity: swapOpportunity,
      activeRoutine: activeRoutine,
    );
  }

  /// Mostra il dialog e ritorna la decisione dell'utente
  Future<SwapDecision?> _showSwapDialog(
    BuildContext context,
    RoutineSwapOpportunity swapOpportunity,
  ) async {
    return showDialog<SwapDecision>(
      context: context,
      builder: (context) => _SwapConfirmationDialog(swapOpportunity),
    );
  }

  /// Esegue l'azione della decisione
  Future<SwapDecision> _executeDecision({
    required BuildContext context,
    required SwapDecision decision,
    required RoutineSwapOpportunity swapOpportunity,
    required FlexibleRoutine activeRoutine,
  }) async {
    switch (decision) {
      case SwapDecision.continueNormal:
        if (kDebugMode) {
          debugPrint(
            '🔄 [SwapFlow] User chose: Continue Normal (no routine update)',
          );
        }
        if (context.mounted) {
          SnackBarService.showInfo(
            context,
            context.l10n.workoutCompletedButRoutineNotUpdated,
          );
        }
        return decision;

      case SwapDecision.swapDays:
        if (kDebugMode) {
          debugPrint('🔄 [SwapFlow] User chose: Swap Days (RECOMMENDED)');
        }
        await _performSwap(
          context: context,
          swapOpportunity: swapOpportunity,
          activeRoutine: activeRoutine,
        );
        return decision;

      case SwapDecision.skipToday:
        if (kDebugMode) {
          debugPrint('🔄 [SwapFlow] User chose: Skip Today');
        }
        await _markTodayAsSkipped(
          context: context,
          swapOpportunity: swapOpportunity,
          activeRoutine: activeRoutine,
        );
        return decision;
    }
  }

  /// Esegue lo swap effettivo su Firestore
  Future<void> _performSwap({
    required BuildContext context,
    required RoutineSwapOpportunity swapOpportunity,
    required FlexibleRoutine activeRoutine,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔄 [SwapFlow] Performing swap: ${swapOpportunity.todayScheduledDay.date} ↔ ${swapOpportunity.futureScheduledDay.date}',
      );
    }

    try {
      // Crea le nuove versioni dei giorni scambiati
      final todayAfterSwap = swapOpportunity.todayScheduledDay.copyWith(
        templateId: swapOpportunity.futureScheduledDay.templateId,
        notes:
            'Swapped with ${swapOpportunity.futureScheduledDay.date} on ${DateTime.now()}',
      );

      final futureAfterSwap = swapOpportunity.futureScheduledDay.copyWith(
        templateId: swapOpportunity.todayScheduledDay.templateId,
        notes:
            'Swapped with ${swapOpportunity.todayScheduledDay.date} on ${DateTime.now()}',
      );

      // Aggiorna la routine localmente prima di inviare a Firebase
      final updatedSchedule = Map<String, ScheduledDay>.from(
        activeRoutine.schedule,
      );

      // Trova le chiavi per i due giorni
      String? todayKey;
      String? futureKey;

      for (final entry in activeRoutine.schedule.entries) {
        if (entry.value.date.year == swapOpportunity.todayScheduledDay.date.year &&
            entry.value.date.month ==
                swapOpportunity.todayScheduledDay.date.month &&
            entry.value.date.day == swapOpportunity.todayScheduledDay.date.day) {
          todayKey = entry.key;
        }
        if (entry.value.date.year ==
                swapOpportunity.futureScheduledDay.date.year &&
            entry.value.date.month ==
                swapOpportunity.futureScheduledDay.date.month &&
            entry.value.date.day ==
                swapOpportunity.futureScheduledDay.date.day) {
          futureKey = entry.key;
        }
      }

      if (todayKey != null && futureKey != null) {
        updatedSchedule[todayKey] = todayAfterSwap;
        updatedSchedule[futureKey] = futureAfterSwap;

        // Salva su Firestore
        await repository.updateRoutine(
          activeRoutine.copyWith(
            schedule: updatedSchedule,
            updatedAt: DateTime.now(),
          ),
        );

        if (kDebugMode) {
          debugPrint('✅ [SwapFlow] Swap completed successfully');
        }

        if (context.mounted) {
          SnackBarService.showSuccess(
            context,
            '${context.l10n.daysSwappedSuccessfully} ${swapOpportunity.completedWorkoutTemplate} oggi',
          );
        }
      } else {
        throw Exception('Could not find schedule keys for swap');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [SwapFlow] Error performing swap: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (context.mounted) {
        SnackBarService.showError(context, context.l10n.errorSwappingDays);
      }
    }
  }

  /// Marca il giorno di oggi come "skipped"
  Future<void> _markTodayAsSkipped({
    required BuildContext context,
    required RoutineSwapOpportunity swapOpportunity,
    required FlexibleRoutine activeRoutine,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔄 [SwapFlow] Marking today as skipped: ${swapOpportunity.todayScheduledDay.date}',
      );
    }

    try {
      final updatedSchedule = Map<String, ScheduledDay>.from(
        activeRoutine.schedule,
      );

      // Trova la chiave per il giorno di oggi
      String? todayKey;
      for (final entry in activeRoutine.schedule.entries) {
        if (entry.value.date.year == swapOpportunity.todayScheduledDay.date.year &&
            entry.value.date.month ==
                swapOpportunity.todayScheduledDay.date.month &&
            entry.value.date.day == swapOpportunity.todayScheduledDay.date.day) {
          todayKey = entry.key;
          break;
        }
      }

      if (todayKey != null) {
        final updatedDay = swapOpportunity.todayScheduledDay.copyWith(
          status: DayStatus.skipped,
          skipReason: 'Skipped to do ${swapOpportunity.completedWorkoutTemplate}',
        );

        updatedSchedule[todayKey] = updatedDay;

        // Salva su Firestore
        await repository.updateRoutine(
          activeRoutine.copyWith(
            schedule: updatedSchedule,
            updatedAt: DateTime.now(),
          ),
        );

        if (kDebugMode) {
          debugPrint('✅ [SwapFlow] Day marked as skipped successfully');
        }

        if (context.mounted) {
          SnackBarService.showSuccess(
            context,
            '${swapOpportunity.todayScheduledDay.templateId} marked as skipped\nYou can recover it later',
          );
        }
      } else {
        throw Exception('Could not find today\'s schedule entry');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [SwapFlow] Error marking day as skipped: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (context.mounted) {
        SnackBarService.showError(
          context,
          context.l10n.errorMarkingDayAsSkipped,
        );
      }
    }
  }
}

/// Le possibili decisioni dell'utente nel swap dialog
enum SwapDecision {
  continueNormal, // 1. Fai il workout, non aggiornare routine
  swapDays, // 2. Scambia i giorni (Consigliato)
  skipToday, // 3. Salta il giorno di oggi
}

/// Dialog di conferma dello swap
class _SwapConfirmationDialog extends StatelessWidget {
  const _SwapConfirmationDialog(this.swapOpportunity);

  final RoutineSwapOpportunity swapOpportunity;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.swapDaysTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.swapDaysDescription,
              style: context.textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            // Today's scheduled day
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oggi (${_formatDate(swapOpportunity.todayScheduledDay.date, context)})',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    swapOpportunity.todayScheduledDay.templateId ?? 'N/A',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Center(
              child: Text(
                '↔',
                style: context.textTheme.headlineSmall?.copyWith(
                  color: context.colors.outline,
                ),
              ),
            ),
            SizedBox(height: 12),
            // Future scheduled day
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.secondaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(swapOpportunity.futureScheduledDay.date, context),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.secondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    swapOpportunity.futureScheduledDay.templateId ?? 'N/A',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, SwapDecision.continueNormal),
          child: Text(context.l10n.continueNormal),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, SwapDecision.skipToday),
          child: Text(context.l10n.skipToday),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, SwapDecision.swapDays),
          child: Text(context.l10n.swapDaysButtonLabel),
        ),
      ],
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('E d/M', locale);
    return dateFormat.format(date);
  }
}
