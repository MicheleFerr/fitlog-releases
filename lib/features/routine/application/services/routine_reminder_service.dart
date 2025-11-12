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
      if (dayDate.isBefore(today) && scheduledDay.status == DayStatus.scheduled) {
        // Marca come saltato
        updatedSchedule[key] = scheduledDay.copyWith(
          status: DayStatus.skipped,
          skipReason: 'Auto-marked as skipped (not completed)',
        );
        skippedDays.add(dayDate);
      }
    }

    // Se ci sono giorni marcati come saltati, salva su Firestore
    if (skippedDays.isNotEmpty) {
      try {
        await repository.updateRoutine(
          routine.copyWith(
            schedule: updatedSchedule,
            updatedAt: DateTime.now(),
          ),
        );

        return SkippedDaysSummary(
          skippedDays: skippedDays,
          notificationNeeded: true,
        );
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ [RoutineReminder] Error saving skipped days: $e');
          debugPrintStack(stackTrace: stackTrace);
        }

        // ✅ FIX: Se save fallisce, ritorna lista VUOTA
        // perché i giorni NON sono stati effettivamente marcati come skipped
        return SkippedDaysSummary(
          skippedDays: [], // ✅ Vuoto = nessun giorno salvato
          notificationNeeded: false,
          error: e.toString(),
        );
      }
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
    final nowRaw = referenceDate ?? DateTime.now();
    // ✅ FIX: Normalizza "now" a mezzanotte per confronto corretto con dayDate
    final now = DateTime(nowRaw.year, nowRaw.month, nowRaw.day);
    final recoverableDays = <SkippableDay>[];

    // Scorri tutti i giorni saltati
    for (final entry in routine.schedule.entries) {
      final scheduledDay = entry.value;

      // Solo giorni saltati CON workout (templateId non null)
      // ✅ FIX: Escludi rest days (templateId null) - non c'è workout da recuperare
      if (scheduledDay.status != DayStatus.skipped) continue;
      if (scheduledDay.templateId == null) continue; // ✅ Skip rest days

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

    return recoverableDays;
  }

  /// Ottiene i giorni futuri disponibili per il recovery (rest days)
  /// Ritorna giorni liberi nei prossimi 30 giorni dove si possono recuperare workout
  Future<List<RecoveryDay>> getAvailableRecoveryDays({
    required FlexibleRoutine routine,
    DateTime? referenceDate,
  }) async {
    final now = referenceDate ?? DateTime.now();
    final availableDays = <RecoveryDay>[];

    // Cerca nei prossimi 30 giorni
    for (var i = 0; i < 30; i++) {
      final checkDate = now.add(Duration(days: i));
      final dateOnly = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final dateKey = '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';

      final scheduledDay = routine.schedule[dateKey];

      // Il giorno è disponibile se:
      // 1. Non è schedulato (null) - giorno non definito nella routine
      // 2. OPPURE è un rest day esplicito (status == DayStatus.rest)
      // 3. OPPURE è scheduled ma senza workout (templateId == null && status == scheduled)
      //    (giorno in attesa di assignment, può essere usato per recovery)
      if (scheduledDay == null ||
          scheduledDay.status == DayStatus.rest ||
          (scheduledDay.status == DayStatus.scheduled &&
              scheduledDay.templateId == null)) {
        availableDays.add(
          RecoveryDay(
            date: dateOnly,
            daysFromNow: i,
          ),
        );
      }
    }

    return availableDays;
  }

  /// Recupera un giorno saltato spostando il workout in un giorno libero
  Future<bool> recoverSkippedDay({
    required FlexibleRoutine routine,
    required DateTime skippedDate,
    required DateTime recoveryDate,
  }) async {
    try {
      final updatedSchedule = Map<String, ScheduledDay>.from(routine.schedule);

      // ✅ FIX: Genera chiavi direttamente invece di loop O(n)
      // Usa stesso formato di flexible_routine.dart:718
      final skippedKey = '${skippedDate.year}-${skippedDate.month.toString().padLeft(2, '0')}-${skippedDate.day.toString().padLeft(2, '0')}';
      final recoveryKey = '${recoveryDate.year}-${recoveryDate.month.toString().padLeft(2, '0')}-${recoveryDate.day.toString().padLeft(2, '0')}';

      // Verifica che entrambi i giorni esistano nel schedule
      if (!routine.schedule.containsKey(skippedKey) ||
          !routine.schedule.containsKey(recoveryKey)) {
        if (kDebugMode) {
          debugPrint('❌ [RoutineReminder] Could not find days for recovery');
          debugPrint('   Skipped key: $skippedKey (exists: ${routine.schedule.containsKey(skippedKey)})');
          debugPrint('   Recovery key: $recoveryKey (exists: ${routine.schedule.containsKey(recoveryKey)})');
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
        originalDate: skippedDay.date, // Salva la data originale del workout skippato
      );

      // Salva su Firestore
      await repository.updateRoutine(
        routine.copyWith(
          schedule: updatedSchedule,
          updatedAt: DateTime.now(),
        ),
      );

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
