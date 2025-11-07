/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/application/services
/// 🎯 Feature: routine
/// 🔧 Type: service
///
/// Service per automatic routine day completion quando un workout viene completato.
/// Risolve il problema UX critico: "Non c'è auto-completion quando finisci workout".
///
/// **FUNZIONALITÀ**:
/// - Auto-detection routine attiva
/// - Match workout → scheduled day (per templateId)
/// - Multi-day support con UI selezione
/// - Feedback UI con toast
///
/// **UTILIZZO**:
/// ```dart
/// // Nel workout_provider dopo completamento
/// final autoCompletionService = ref.read(routineAutoCompletionServiceProvider);
/// await autoCompletionService.tryAutoCompleteRoutineDay(
///   completedWorkout: workout,
///   context: context, // Per UI feedback e date selection
/// );
/// ```
///
/// **COMPORTAMENTO**:
/// - Se routine attiva non trovata → skip silenzioso
/// - Se template non corrisponde → skip silenzioso
/// - Se single match → auto-complete con toast success
/// - Se multiple matches → mostra UI per selezione data
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/application/services/routine_matching_service.dart';
import 'package:gymbro_flutter_new/features/routine/application/services/routine_swap_flow.dart';
import 'package:gymbro_flutter_new/features/routine/application/services/routine_notification_service.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/flexible_routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_repository_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Result of routine auto-completion attempt
class RoutineAutoCompletionResult {

  const RoutineAutoCompletionResult({
    required this.completed,
    this.reason,
    this.candidateDates,
  });

  factory RoutineAutoCompletionResult.success(DateTime completedDate) {
    return RoutineAutoCompletionResult(
      completed: true,
      reason: 'Routine day auto-completed for ${completedDate.toLocal()}',
    );
  }

  factory RoutineAutoCompletionResult.skipped(String reason) {
    return RoutineAutoCompletionResult(
      completed: false,
      reason: reason,
    );
  }

  factory RoutineAutoCompletionResult.needsUserSelection(
      List<DateTime> candidates) {
    return RoutineAutoCompletionResult(
      completed: false,
      reason: 'Multiple candidate dates found, user selection required',
      candidateDates: candidates,
    );
  }
  final bool completed;
  final String? reason;
  final List<DateTime>? candidateDates;
}

/// Service for automatic routine day completion
class RoutineAutoCompletionService {
  RoutineAutoCompletionService(this._ref);

  final Ref _ref;

  /// Repository for routine operations
  FlexibleRoutineRepository get _repository =>
      _ref.read(flexibleRoutineRepositoryProvider);

  /// Notification service for routine completions
  final RoutineNotificationService _notificationService = RoutineNotificationService();

  /// Try to auto-complete routine day when workout is completed
  ///
  /// Returns:
  /// - RoutineAutoCompletionResult with completion status
  ///
  /// Behavior:
  /// - If no active routine → skip silently (return skipped)
  /// - If workout template doesn't match any scheduled day → skip silently
  /// - If single match → auto-complete and show success toast
  /// - If swap opportunity detected → show swap dialog
  /// - If multiple matches → return candidates for UI selection
  Future<RoutineAutoCompletionResult> tryAutoCompleteRoutineDay({
    required Workout completedWorkout,
    BuildContext? context,
  }) async {
    try {
      // 1. Get active routine (if exists)
      final activeRoutineAsync = _ref.read(activeFlexibleRoutineProvider);

      final activeRoutine = activeRoutineAsync.when(
        data: (routine) => routine,
        loading: () => null,
        error: (_, __) => null,
      );

      if (activeRoutine == null) {
        if (kDebugMode) {
          debugPrint(
            '🔍 [RoutineAutoCompletion] No active routine found, skipping auto-completion',
          );
        }
        return RoutineAutoCompletionResult.skipped('No active routine');
      }

      // 2. Analyze workout against routine using RoutineMatchingService
      final matchingService = RoutineMatchingService();
      final matchResult = await matchingService.analyzeWorkoutForRoutine(
        completedWorkout: completedWorkout,
        activeRoutine: activeRoutine,
        completionTime: completedWorkout.endTime ?? DateTime.now(),
      );

      // 3. Handle different matching results
      return await matchResult.when(
        noTemplate: () {
          if (kDebugMode) {
            debugPrint(
              '🔍 [RoutineAutoCompletion] Workout has no templateId, skipping',
            );
          }
          return Future.value(
            RoutineAutoCompletionResult.skipped('No workout template'),
          );
        },
        noMatch: () {
          if (kDebugMode) {
            debugPrint(
              '🔍 [RoutineAutoCompletion] No matching scheduled days found',
            );
          }
          return Future.value(
            RoutineAutoCompletionResult.skipped('No matching scheduled days'),
          );
        },
        simpleMatch: (matchedDate) async {
          if (kDebugMode) {
            debugPrint(
              '✅ [RoutineAutoCompletion] Simple match found, auto-completing: $matchedDate',
            );
          }

          await _repository.completeDayWorkout(
            routineId: activeRoutine.id,
            date: matchedDate,
            workoutId: completedWorkout.id,
          );

          // Send completion notification
          await _notificationService.sendRoutineDayCompletedNotification(
            routineName: activeRoutine.name,
            workoutName: completedWorkout.name,
          );

          // Show success toast if context available
          if (context != null && context.mounted) {
            SnackBarService.showSuccess(
              context,
              '${context.l10n.routineDayCompleted} ${_formatDate(matchedDate, context)}',
              duration: const Duration(seconds: 3),
            );
          }

          return RoutineAutoCompletionResult.success(matchedDate);
        },
        multipleMatches: (candidates) {
          if (kDebugMode) {
            debugPrint(
              '🔍 [RoutineAutoCompletion] Multiple candidates found: $candidates',
            );
          }
          return Future.value(
            RoutineAutoCompletionResult.needsUserSelection(candidates),
          );
        },
        swapOpportunity: (opportunity) async {
          if (kDebugMode) {
            debugPrint(
              '🔄 [RoutineAutoCompletion] Swap opportunity detected',
            );
          }

          // Se non abbiamo un context, non possiamo mostrare il dialog
          if (context == null || !context.mounted) {
            if (kDebugMode) {
              debugPrint(
                '⚠️ [RoutineAutoCompletion] No context for swap dialog, auto-completing with closest match',
              );
            }
            // Auto-complete il giorno futuro come fallback
            await _repository.completeDayWorkout(
              routineId: activeRoutine.id,
              date: opportunity.futureScheduledDay.date,
              workoutId: completedWorkout.id,
            );
            return RoutineAutoCompletionResult.success(
              opportunity.futureScheduledDay.date,
            );
          }

          // Mostra il dialog e ottieni la decisione dell'utente
          final swapFlow = RoutineSwapFlow(repository: _repository);
          final decision = await swapFlow.showAndHandleSwapDialog(
            context: context,
            swapOpportunity: opportunity,
            activeRoutine: activeRoutine,
          );

          // In base alla decisione dell'utente, auto-completa il giorno appropriato
          DateTime dayToComplete;
          switch (decision) {
            case SwapDecision.continueNormal:
              // L'utente ha scelto di non aggiornare la routine
              // Non completiamo nulla
              if (kDebugMode) {
                debugPrint(
                  '🔄 [RoutineAutoCompletion] User chose: Continue Normal',
                );
              }
              return RoutineAutoCompletionResult.skipped(
                'User chose to continue without routine update',
              );

            case SwapDecision.swapDays:
              // L'utente ha scelto di scambiare i giorni
              // Completa il giorno di oggi (che ora ha il template corretto)
              dayToComplete = opportunity.todayScheduledDay.date;
              if (kDebugMode) {
                debugPrint(
                  '🔄 [RoutineAutoCompletion] User chose: Swap Days, completing $dayToComplete',
                );
              }

            case SwapDecision.skipToday:
              // L'utente ha scelto di saltare il giorno di oggi
              // Completa il giorno futuro
              dayToComplete = opportunity.futureScheduledDay.date;
              if (kDebugMode) {
                debugPrint(
                  '🔄 [RoutineAutoCompletion] User chose: Skip Today, completing $dayToComplete',
                );
              }

            case null:
              // L'utente ha annullato il dialog
              if (kDebugMode) {
                debugPrint('🔄 [RoutineAutoCompletion] User cancelled swap dialog');
              }
              return RoutineAutoCompletionResult.skipped(
                'User cancelled swap dialog',
              );
          }

          // Completa il giorno selezionato
          await _repository.completeDayWorkout(
            routineId: activeRoutine.id,
            date: dayToComplete,
            workoutId: completedWorkout.id,
          );

          // Send completion notification
          await _notificationService.sendRoutineDayCompletedNotification(
            routineName: activeRoutine.name,
            workoutName: completedWorkout.name,
          );

          if (kDebugMode) {
            debugPrint(
              '✅ [RoutineAutoCompletion] Routine day completed after swap: $dayToComplete',
            );
          }

          return RoutineAutoCompletionResult.success(dayToComplete);
        },
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [RoutineAutoCompletion] Error during auto-completion: $e');
        debugPrint('📍 [RoutineAutoCompletion] Stack trace: $stackTrace');
      }

      return RoutineAutoCompletionResult.skipped('Error: $e');
    }
  }

  /// Manual completion with user-selected date
  ///
  /// Used when multiple candidate dates exist and user picks one.
  Future<void> completeRoutineDayManually({
    required String routineId,
    required DateTime selectedDate,
    required String workoutId,
    required String workoutName,
    required String routineName,
    BuildContext? context,
  }) async {
    try {
      await _repository.completeDayWorkout(
        routineId: routineId,
        date: selectedDate,
        workoutId: workoutId,
      );

      // Send completion notification
      await _notificationService.sendRoutineDayCompletedNotification(
        routineName: routineName,
        workoutName: workoutName,
      );

      if (kDebugMode) {
        debugPrint('✅ [RoutineAutoCompletion] Routine day manually completed: $selectedDate');
      }

      // Show success toast if context available
      if (context != null && context.mounted) {
        SnackBarService.showSuccess(
          context,
          '${context.l10n.routineDayCompleted} ${_formatDate(selectedDate, context)}',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [RoutineAutoCompletion] Error during manual completion: $e');
        debugPrint('📍 [RoutineAutoCompletion] Stack trace: $stackTrace');
      }

      // Show error toast if context available
      if (context != null && context.mounted) {
        SnackBarService.showError(
          context,
          context.l10n.routineDayCompletionFailed,
          duration: const Duration(seconds: 4),
        );
      }

      rethrow;
    }
  }

  /// Format date for UI display
  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final diff = dateOnly.difference(today).inDays;

    if (diff == 0) return context.l10n.today;
    if (diff == -1) return context.l10n.yesterday;
    if (diff == 1) return context.l10n.tomorrow;

    // Format as "Mon 15 Jan"
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('E d MMM', locale);
    return dateFormat.format(date);
  }

  String _monthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}

/// Provider for RoutineAutoCompletionService
final routineAutoCompletionServiceProvider = Provider<RoutineAutoCompletionService>((ref) {
  return RoutineAutoCompletionService(ref);
});
