import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Service che analizza workout completati e rileva opportunità di swap
/// nella routine attiva.
///
/// ⚠️ **v2.0 STUB**: This service is temporarily stubbed out for v2.0 simplified schema.
/// The v1.0 complex features (ScheduledDay, DayStatus, swap opportunities) don't exist in v2.0.
/// TODO: Reimplement when v2.0 adds advanced tracking features.
class RoutineMatchingService {
  /// Risultato dell'analisi di matching
  ///
  /// **v2.0 STUB**: Always returns `noMatch` - advanced matching not implemented in v2.0
  Future<RoutineMatchResult> analyzeWorkoutForRoutine({
    required Workout completedWorkout,
    required FlexibleRoutine activeRoutine,
    required DateTime completionTime,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔍 [RoutineMatching v2.0 STUB] analyzeWorkoutForRoutine called - returning noMatch (feature not implemented in v2.0)',
      );
    }

    // v2.0 simplified schema doesn't support day-level tracking
    // Return noMatch to skip complex swap logic
    return const RoutineMatchResult.noMatch();
  }
}

/// Risultato dell'analisi di matching tra workout e routine
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
///
/// **v2.0 STUB**: This class is kept for compatibility but never instantiated in v2.0
class RoutineSwapOpportunity {
  const RoutineSwapOpportunity({
    required this.todayTemplateId,
    required this.futureTemplateId,
    required this.completedWorkoutTemplate,
  });

  /// Il template ID di oggi (dovrebbe essere diverso da quello completato)
  final String todayTemplateId;

  /// Il template ID futuro (dovrebbe corrispondere al workout completato)
  final String futureTemplateId;

  /// Il template del workout appena completato
  final String completedWorkoutTemplate;

  @override
  String toString() =>
      'SwapOpportunity: $todayTemplateId ↔ $futureTemplateId';
}
