import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Service che analizza workout completati e rileva opportunità di swap
/// nella routine attiva.
class RoutineMatchingService {
  /// Risultato dell'analisi di matching
  Future<RoutineMatchResult> analyzeWorkoutForRoutine({
    required Workout completedWorkout,
    required FlexibleRoutine activeRoutine,
    required DateTime completionTime,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔍 [RoutineMatching] Analyzing workout: ${completedWorkout.templateId}',
      );
    }

    // Validazione: il workout ha un template?
    if (completedWorkout.templateId == null ||
        completedWorkout.templateId!.isEmpty) {
      if (kDebugMode) {
        debugPrint('ℹ️ [RoutineMatching] Workout has no templateId, skipping');
      }
      return const RoutineMatchResult.noTemplate();
    }

    // Trova tutti i giorni che corrispondono a questo template
    final matchingDays = _findMatchingDays(
      routine: activeRoutine,
      templateId: completedWorkout.templateId!,
      completionTime: completionTime,
    );

    if (kDebugMode) {
      debugPrint(
        '🔍 [RoutineMatching] Found ${matchingDays.length} matching days',
      );
    }

    // Nessun match
    if (matchingDays.isEmpty) {
      return const RoutineMatchResult.noMatch();
    }

    // Un match perfetto - auto-complete
    if (matchingDays.length == 1) {
      if (kDebugMode) {
        debugPrint('✅ [RoutineMatching] Single match found, auto-completing');
      }
      return RoutineMatchResult.simpleMatch(matchingDays.first);
    }

    // Multipli match - controlla se c'è un'opportunità di swap
    if (kDebugMode) {
      debugPrint('⚠️ [RoutineMatching] Multiple matches found, checking swap');
    }

    final swapOpportunity = _detectSwapOpportunity(
      routine: activeRoutine,
      completedWorkout: completedWorkout,
      matchingDays: matchingDays,
      completionTime: completionTime,
    );

    if (swapOpportunity != null) {
      if (kDebugMode) {
        debugPrint(
          '🔄 [RoutineMatching] Swap opportunity detected: swap ${swapOpportunity.todayScheduledDay.date} with ${swapOpportunity.futureScheduledDay.date}',
        );
      }
      return RoutineMatchResult.swapOpportunity(swapOpportunity);
    }

    // Multipli match ma nessuno è "oggi" - user needs to select
    if (kDebugMode) {
      debugPrint(
        '❓ [RoutineMatching] Multiple matches but no swap - need user selection',
      );
    }
    return RoutineMatchResult.multipleMatches(matchingDays);
  }

  /// Trova tutti i giorni nella routine che hanno questo template
  /// entro una finestra temporale ragionevole (±14 giorni)
  List<DateTime> _findMatchingDays({
    required FlexibleRoutine routine,
    required String templateId,
    required DateTime completionTime,
  }) {
    final candidates = <DateTime>[];

    for (final entry in routine.schedule.entries) {
      final scheduledDay = entry.value;

      // Filtro 1: Il templateId deve corrispondere
      if (scheduledDay.templateId != templateId) {
        continue;
      }

      // Filtro 2: Status deve essere "actionable" (scheduled, skipped, recovered)
      if (scheduledDay.status != DayStatus.scheduled &&
          scheduledDay.status != DayStatus.skipped &&
          scheduledDay.status != DayStatus.recovered) {
        continue;
      }

      // Filtro 3: Finestra temporale ±14 giorni
      final daysDifference =
          scheduledDay.date.difference(completionTime).inDays.abs();
      if (daysDifference > 14) {
        continue;
      }

      candidates.add(scheduledDay.date);
    }

    // Ordina per vicinanza alla completion time
    candidates.sort((a, b) {
      final diffA = a.difference(completionTime).inDays.abs();
      final diffB = b.difference(completionTime).inDays.abs();
      return diffA.compareTo(diffB);
    });

    return candidates;
  }

  /// Rileva un'opportunità di swap intelligente
  /// Situazione: Oggi dovrebbe fare X, ma vuole fare Y (schedulato per domani)
  RoutineSwapOpportunity? _detectSwapOpportunity({
    required FlexibleRoutine routine,
    required Workout completedWorkout,
    required List<DateTime> matchingDays,
    required DateTime completionTime,
  }) {
    // Normalizza la completion time a mezzanotte (per confronto giornaliero)
    final completionDate = DateTime(
      completionTime.year,
      completionTime.month,
      completionTime.day,
    );

    // Cosa dovrebbe fare oggi la routine?
    final todayScheduledDay = routine.schedule.entries
        .where((e) {
          final dayDate = DateTime(
            e.value.date.year,
            e.value.date.month,
            e.value.date.day,
          );
          return dayDate == completionDate;
        })
        .map((e) => e.value)
        .firstOrNull;

    if (todayScheduledDay == null) {
      if (kDebugMode) {
        debugPrint(
          '❌ [Swap Detection] No scheduled day for today, cannot swap',
        );
      }
      return null;
    }

    // Il template di oggi è diverso da quello completato?
    if (todayScheduledDay.templateId == completedWorkout.templateId) {
      if (kDebugMode) {
        debugPrint(
          '❌ [Swap Detection] Today template matches completed workout, no swap needed',
        );
      }
      return null;
    }

    // Cerca un giorno futuro che contenga il template completato
    // e che sia "actionable"
    final futureSwapDay = matchingDays.firstWhereOrNull((candidateDate) {
      final candidateDateNormalized = DateTime(
        candidateDate.year,
        candidateDate.month,
        candidateDate.day,
      );
      // Deve essere nel futuro
      return candidateDateNormalized.isAfter(completionDate);
    });

    if (futureSwapDay == null) {
      if (kDebugMode) {
        debugPrint('❌ [Swap Detection] No future matching day found');
      }
      return null;
    }

    // Retrieve lo ScheduledDay futuro
    final futureScheduledDay = routine.schedule.entries
        .firstWhere((e) {
          final eDate = DateTime(
            e.value.date.year,
            e.value.date.month,
            e.value.date.day,
          );
          final fDate = DateTime(
            futureSwapDay.year,
            futureSwapDay.month,
            futureSwapDay.day,
          );
          return eDate == fDate;
        })
        .value;

    if (kDebugMode) {
      debugPrint(
        '✅ [Swap Detection] Swap opportunity: ${todayScheduledDay.date} (${todayScheduledDay.templateId}) ↔ ${futureScheduledDay.date} (${futureScheduledDay.templateId})',
      );
    }

    return RoutineSwapOpportunity(
      todayScheduledDay: todayScheduledDay,
      futureScheduledDay: futureScheduledDay,
      completedWorkoutTemplate: completedWorkout.templateId!,
    );
  }
}

/// Risultato dell'analisi di matching
sealed class RoutineMatchResult {
  const RoutineMatchResult();

  const factory RoutineMatchResult.noTemplate() = _NoTemplate;
  const factory RoutineMatchResult.noMatch() = _NoMatch;
  const factory RoutineMatchResult.simpleMatch(DateTime matchedDate) =
      _SimpleMatch;
  const factory RoutineMatchResult.multipleMatches(List<DateTime> candidates) =
      _MultipleMatches;
  const factory RoutineMatchResult.swapOpportunity(
      RoutineSwapOpportunity opportunity) = _SwapOpportunity;

  T when<T>({
    required T Function() noTemplate,
    required T Function() noMatch,
    required T Function(DateTime matchedDate) simpleMatch,
    required T Function(List<DateTime> candidates) multipleMatches,
    required T Function(RoutineSwapOpportunity opportunity) swapOpportunity,
  }) {
    return switch (this) {
      _NoTemplate() => noTemplate(),
      _NoMatch() => noMatch(),
      _SimpleMatch(:final matchedDate) => simpleMatch(matchedDate),
      _MultipleMatches(:final candidates) => multipleMatches(candidates),
      _SwapOpportunity(:final opportunity) => swapOpportunity(opportunity),
    };
  }

  bool get isSimpleMatch => this is _SimpleMatch;
  bool get hasSwapOpportunity => this is _SwapOpportunity;
  bool get hasMultipleCandidates => this is _MultipleMatches;
}

class _NoTemplate extends RoutineMatchResult {
  const _NoTemplate();
}

class _NoMatch extends RoutineMatchResult {
  const _NoMatch();
}

class _SimpleMatch extends RoutineMatchResult {
  const _SimpleMatch(this.matchedDate);
  final DateTime matchedDate;
}

class _MultipleMatches extends RoutineMatchResult {
  const _MultipleMatches(this.candidates);
  final List<DateTime> candidates;
}

class _SwapOpportunity extends RoutineMatchResult {
  const _SwapOpportunity(this.opportunity);
  final RoutineSwapOpportunity opportunity;
}

/// Rappresenta un'opportunità di swap tra due giorni della routine
class RoutineSwapOpportunity {
  const RoutineSwapOpportunity({
    required this.todayScheduledDay,
    required this.futureScheduledDay,
    required this.completedWorkoutTemplate,
  });

  /// Il giorno di oggi (dovrebbe avere un template diverso)
  final ScheduledDay todayScheduledDay;

  /// Il giorno futuro (dovrebbe avere il template del workout completato)
  final ScheduledDay futureScheduledDay;

  /// Il template del workout appena completato
  final String completedWorkoutTemplate;

  @override
  String toString() =>
      'SwapOpportunity: ${todayScheduledDay.date} ↔ ${futureScheduledDay.date}';
}
