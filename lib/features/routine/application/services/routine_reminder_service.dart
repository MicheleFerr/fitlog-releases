import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/flexible_routine_repository.dart';

/// Service che gestisce reminder e skip tracking per routine
///
/// ⚠️ **v2.0 STUB**: This service is temporarily stubbed out for v2.0 simplified schema.
/// The v1.0 complex features (ScheduledDay, DayStatus, skip tracking) don't exist in v2.0.
/// TODO: Reimplement when v2.0 adds advanced tracking features.
class RoutineReminderService {
  const RoutineReminderService({required this.repository});

  final FlexibleRoutineRepository repository;

  /// Controlla se ci sono giorni passati non completati e li marca come saltati
  /// Viene eseguito ogni mattina (via background task)
  ///
  /// **v2.0 STUB**: Always returns empty summary - skip tracking not implemented in v2.0
  Future<SkippedDaysSummary> markPastDaysAsSkipped({
    required FlexibleRoutine routine,
    DateTime? checkTime,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔍 [RoutineReminder v2.0 STUB] markPastDaysAsSkipped called - returning empty (feature not implemented in v2.0)',
      );
    }

    // v2.0 simplified schema doesn't support day-level skip tracking
    return const SkippedDaysSummary(
      skippedDays: [],
      totalSkipped: 0,
      message: 'v2.0 simplified schema - skip tracking not implemented',
    );
  }

  /// Ottiene reminder programmati per una routine
  ///
  /// **v2.0 STUB**: Always returns empty list - reminders not implemented in v2.0
  Future<List<ScheduledReminder>> getScheduledReminders({
    required FlexibleRoutine routine,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔍 [RoutineReminder v2.0 STUB] getScheduledReminders called - returning empty (feature not implemented in v2.0)',
      );
    }

    return [];
  }
}

/// Rappresenta il riepilogo dei giorni saltati
class SkippedDaysSummary {
  const SkippedDaysSummary({
    required this.skippedDays,
    required this.totalSkipped,
    required this.message,
  });

  final List<DateTime> skippedDays;
  final int totalSkipped;
  final String message;

  @override
  String toString() =>
      'SkippedDaysSummary: $totalSkipped days skipped - $message';
}

/// Rappresenta un reminder programmato per un giorno della routine
///
/// **v2.0 STUB**: This class is kept for compatibility but never used in v2.0
class ScheduledReminder {
  const ScheduledReminder({
    required this.date,
    required this.templateId,
    required this.reminderTime,
  });

  final DateTime date;
  final String templateId;
  final DateTime reminderTime;

  @override
  String toString() =>
      'ScheduledReminder: $date - template: $templateId at $reminderTime';
}
