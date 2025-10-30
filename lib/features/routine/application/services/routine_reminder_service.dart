import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/flexible_routine_repository.dart';

/// Service che gestisce reminder e skip tracking per routine
class RoutineReminderService {
  const RoutineReminderService({required this.repository});

  final FlexibleRoutineRepository repository;

  /// Controlla se ci sono giorni passati non completati e li marca come saltati
  /// Viene eseguito ogni mattina (via background task)
  Future<SkippedDaysSummary> markPastDaysAsSkipped({
    required FlexibleRoutine routine,
    DateTime? checkTime,
  }) async {
    final now = checkTime ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (kDebugMode) {
      debugPrint(
        '⏰ [RoutineReminder] Checking for past unfinished days at $today',
      );
    }

    final skippedDays = <DateTime>[];
    final updatedSchedule = Map<String, ScheduledDay>.from(routine.schedule);

    // Scorri tutti i giorni della routine
    for (final entry in routine.schedule.entries) {
      final key = entry.key;
      final scheduledDay = entry.value;

      // Normalizza le date per confronto
      final dayDate = DateTime(
        scheduledDay.date.year,
        scheduledDay.date.month,
        scheduledDay.date.day,
      );

      // Se il giorno è nel passato e non completato/saltato/riposo
      if (dayDate.isBefore(today)) {
        if (scheduledDay.status == DayStatus.scheduled) {
          if (kDebugMode) {
            debugPrint(
              '📝 [RoutineReminder] Marking past day as skipped: $dayDate',
            );
          }

          // Marca come saltato
          updatedSchedule[key] = scheduledDay.copyWith(
            status: DayStatus.skipped,
            skipReason: 'Auto-marked as skipped (not completed)',
          );

          skippedDays.add(dayDate);
        }
      }
    }

    // Se ci sono giorni marcati come saltati, salva su Firestore
    if (skippedDays.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          '💾 [RoutineReminder] Saving ${skippedDays.length} skipped days to Firestore',
        );
      }

      try {
        await repository.updateRoutine(
          routine.copyWith(
            schedule: updatedSchedule,
            updatedAt: DateTime.now(),
          ),
        );

        if (kDebugMode) {
          debugPrint('✅ [RoutineReminder] Skipped days saved successfully');
        }

        return SkippedDaysSummary(
          skippedDays: skippedDays,
          notificationNeeded: true,
        );
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ [RoutineReminder] Error saving skipped days: $e');
          debugPrintStack(stackTrace: stackTrace);
        }

        return SkippedDaysSummary(
          skippedDays: skippedDays,
          notificationNeeded: false,
          error: e.toString(),
        );
      }
    }

    if (kDebugMode) {
      debugPrint('ℹ️ [RoutineReminder] No past unfinished days found');
    }

    return const SkippedDaysSummary(
      skippedDays: [],
      notificationNeeded: false,
    );
  }

  /// Ottiene i giorni saltati che possono essere recuperati
  /// Filtri per: skipTracker.canRecover, entro finestra recovery, status = skipped
  Future<List<SkippableDay>> getRecoverableSkippedDays({
    required FlexibleRoutine routine,
    DateTime? referenceDate,
  }) async {
    final now = referenceDate ?? DateTime.now();
    final recoverableDays = <SkippableDay>[];

    if (kDebugMode) {
      debugPrint(
        '🔍 [RoutineReminder] Finding recoverable skipped days as of $now',
      );
    }

    // Scorri tutti i giorni saltati
    for (final entry in routine.schedule.entries) {
      final scheduledDay = entry.value;

      // Solo giorni saltati
      if (scheduledDay.status != DayStatus.skipped) continue;

      // Il giorno deve essere nel passato (per poterlo recuperare)
      final dayDate = DateTime(
        scheduledDay.date.year,
        scheduledDay.date.month,
        scheduledDay.date.day,
      );

      if (dayDate.isAfter(now)) continue;

      // Controlla se è entro la finestra di recovery (es: ultimi 30 giorni)
      final daysDifference = now.difference(dayDate).inDays;
      if (daysDifference > 30) {
        // Skip troppo vecchio, non è più recuperabile
        continue;
      }

      recoverableDays.add(
        SkippableDay(
          date: dayDate,
          templateId: scheduledDay.templateId,
          skipReason: scheduledDay.skipReason,
          daysAgo: daysDifference,
        ),
      );
    }

    if (kDebugMode) {
      debugPrint(
        '🔍 [RoutineReminder] Found ${recoverableDays.length} recoverable days',
      );
    }

    return recoverableDays;
  }

  /// Ottiene i giorni liberi (riposo) dove recuperare un skip
  /// Filtro per: status = rest, nel futuro
  Future<List<RecoveryDay>> getAvailableRecoveryDays({
    required FlexibleRoutine routine,
    DateTime? startFrom,
  }) async {
    final now = startFrom ?? DateTime.now();
    final recoveryDays = <RecoveryDay>[];

    if (kDebugMode) {
      debugPrint(
        '🔍 [RoutineReminder] Finding available recovery days starting from $now',
      );
    }

    // Scorri i prossimi 30 giorni
    for (int i = 0; i < 30; i++) {
      final checkDate = now.add(Duration(days: i));
      final checkDateNorm = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
      );

      // Cerca questo giorno nella routine
      final scheduledDay = routine.schedule.entries
          .firstWhere(
            (e) {
              final eDate = DateTime(e.value.date.year, e.value.date.month,
                  e.value.date.day);
              return eDate == checkDateNorm;
            },
            orElse: () => throw Exception('Not found'),
          )
          .value;

      // Se è un giorno di riposo, è disponibile per recovery
      if (scheduledDay.status == DayStatus.rest) {
        recoveryDays.add(
          RecoveryDay(
            date: checkDateNorm,
            daysFromNow: i,
          ),
        );
      }

      // Se non c'è niente schedulato, è disponibile
      if (scheduledDay.status == DayStatus.rest ||
          (scheduledDay.templateId == null)) {
        if (!recoveryDays.any((d) => d.date == checkDateNorm)) {
          recoveryDays.add(
            RecoveryDay(
              date: checkDateNorm,
              daysFromNow: i,
            ),
          );
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
        '🔍 [RoutineReminder] Found ${recoveryDays.length} available recovery days',
      );
    }

    return recoveryDays;
  }

  /// Recupera un giorno saltato spostando il workout in un giorno libero
  Future<bool> recoverSkippedDay({
    required FlexibleRoutine routine,
    required DateTime skippedDate,
    required DateTime recoveryDate,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔄 [RoutineReminder] Recovering skipped day $skippedDate → $recoveryDate',
      );
    }

    try {
      final updatedSchedule = Map<String, ScheduledDay>.from(routine.schedule);

      // Trova i due giorni
      String? skippedKey;
      String? recoveryKey;

      for (final entry in routine.schedule.entries) {
        final eDate = DateTime(
          entry.value.date.year,
          entry.value.date.month,
          entry.value.date.day,
        );

        if (eDate == DateTime(skippedDate.year, skippedDate.month, skippedDate.day)) {
          skippedKey = entry.key;
        }
        if (eDate == DateTime(recoveryDate.year, recoveryDate.month, recoveryDate.day)) {
          recoveryKey = entry.key;
        }
      }

      if (skippedKey == null || recoveryKey == null) {
        if (kDebugMode) {
          debugPrint('❌ [RoutineReminder] Could not find days for recovery');
        }
        return false;
      }

      final skippedDay = updatedSchedule[skippedKey]!;
      final recoveryDayObj = updatedSchedule[recoveryKey]!;

      // Contrassegna il giorno saltato come recuperato
      updatedSchedule[skippedKey] = skippedDay.copyWith(
        status: DayStatus.recovered,
        originalDate: null,
      );

      // Assegna il template al giorno di recovery
      updatedSchedule[recoveryKey] = recoveryDayObj.copyWith(
        status: DayStatus.scheduled,
        templateId: skippedDay.templateId,
        notes: 'Recovered from $skippedDate',
      );

      // Salva su Firestore
      await repository.updateRoutine(
        routine.copyWith(
          schedule: updatedSchedule,
          updatedAt: DateTime.now(),
        ),
      );

      if (kDebugMode) {
        debugPrint('✅ [RoutineReminder] Skip recovered successfully');
      }

      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [RoutineReminder] Error recovering skip: $e');
        debugPrintStack(stackTrace: stackTrace);
      }

      return false;
    }
  }
}

/// Rappresenta un giorno saltato che può essere recuperato
class SkippableDay {
  const SkippableDay({
    required this.date,
    required this.templateId,
    this.skipReason,
    required this.daysAgo,
  });

  final DateTime date;
  final String? templateId;
  final String? skipReason;
  final int daysAgo;

  @override
  String toString() => 'SkippableDay($date, $templateId, $daysAgo days ago)';
}

/// Rappresenta un giorno disponibile per recovery
class RecoveryDay {
  const RecoveryDay({
    required this.date,
    required this.daysFromNow,
  });

  final DateTime date;
  final int daysFromNow;

  @override
  String toString() => 'RecoveryDay($date, in $daysFromNow days)';
}

/// Summary della operazione di mark skip days
class SkippedDaysSummary {
  const SkippedDaysSummary({
    required this.skippedDays,
    required this.notificationNeeded,
    this.error,
  });

  final List<DateTime> skippedDays;
  final bool notificationNeeded;
  final String? error;

  bool get hasError => error != null;

  @override
  String toString() =>
      'SkippedDaysSummary(${skippedDays.length} days, notify=$notificationNeeded)';
}
