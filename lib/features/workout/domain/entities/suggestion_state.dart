/// 🏋️‍♂️ GymBro TrackLog - Smart Workout Suggestion
///
/// 📁 Layer: features/workout/domain/entities
/// 🎯 Feature: Smart Workout Suggestion
/// 🔧 Type: entity (sealed union)
///
/// Union type per lo stato della Smart Workout Suggestion UI
/// Usa Dart 3 sealed classes per type-safe state handling
///
/// States:
/// - loading: Calcolo in corso
/// - restMode: Utente ha già allenato oggi
/// - insufficientData: <3 workouts in history
/// - ready: Suggestion pronta con template
/// - warning: Antagonist conflict detected
/// - error: Errore nel calcolo

import 'package:gymbro_flutter_new/features/workout/domain/entities/antagonist_conflict.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_suggestion.dart';

/// Stato della Smart Workout Suggestion
///
/// Sealed class per gestione type-safe degli stati UI
/// Ogni stato ha i dati necessari per renderizzare la UI appropriata
sealed class SuggestionState {
  const SuggestionState();

  /// Convenience getter per check rapidi
  bool get isLoading => this is SuggestionLoading;
  bool get isRestMode => this is SuggestionRestMode;
  bool get isInsufficientData => this is SuggestionInsufficientData;
  bool get isReady => this is SuggestionReady;
  bool get isWarning => this is SuggestionWarning;
  bool get isError => this is SuggestionError;

  /// Pattern matching helper
  T when<T>({
    required T Function() loading,
    required T Function(Workout todayWorkout) restMode,
    required T Function(int workoutCount, int requiredCount) insufficientData,
    required T Function(WorkoutSuggestion suggestion) ready,
    required T Function(WorkoutSuggestion suggestion, AntagonistConflict conflict) warning,
    required T Function(String message, Object? error) error,
  }) {
    return switch (this) {
      SuggestionLoading() => loading(),
      SuggestionRestMode(todayWorkout: final w) => restMode(w),
      SuggestionInsufficientData(workoutCount: final c, requiredCount: final r) => insufficientData(c, r),
      SuggestionReady(suggestion: final s) => ready(s),
      SuggestionWarning(suggestion: final s, conflict: final c) => warning(s, c),
      SuggestionError(message: final m, error: final e) => error(m, e),
    };
  }

  /// Pattern matching con fallback
  T maybeWhen<T>({
    T Function()? loading,
    T Function(Workout todayWorkout)? restMode,
    T Function(int workoutCount, int requiredCount)? insufficientData,
    T Function(WorkoutSuggestion suggestion)? ready,
    T Function(WorkoutSuggestion suggestion, AntagonistConflict conflict)? warning,
    T Function(String message, Object? error)? error,
    required T Function() orElse,
  }) {
    return switch (this) {
      SuggestionLoading() => loading?.call() ?? orElse(),
      SuggestionRestMode(todayWorkout: final w) => restMode?.call(w) ?? orElse(),
      SuggestionInsufficientData(workoutCount: final c, requiredCount: final r) => insufficientData?.call(c, r) ?? orElse(),
      SuggestionReady(suggestion: final s) => ready?.call(s) ?? orElse(),
      SuggestionWarning(suggestion: final s, conflict: final c) => warning?.call(s, c) ?? orElse(),
      SuggestionError(message: final m, error: final e) => error?.call(m, e) ?? orElse(),
    };
  }

  /// Estrai la suggestion se presente (Ready o Warning)
  WorkoutSuggestion? get suggestionOrNull {
    return switch (this) {
      SuggestionReady(suggestion: final s) => s,
      SuggestionWarning(suggestion: final s) => s,
      _ => null,
    };
  }
}

/// Stato: Calcolo in corso
class SuggestionLoading extends SuggestionState {
  const SuggestionLoading();

  @override
  String toString() => 'SuggestionLoading()';
}

/// Stato: L'utente ha già completato un workout oggi
///
/// UI: Mostra congratulazioni + stats del workout di oggi
class SuggestionRestMode extends SuggestionState {
  const SuggestionRestMode({
    required this.todayWorkout,
  });

  /// Il workout completato oggi
  final Workout todayWorkout;

  @override
  String toString() => 'SuggestionRestMode(workout: ${todayWorkout.name})';
}

/// Stato: Dati insufficienti per generare suggestion
///
/// UI: Mostra messaggio "Completa altri X workout per sbloccare"
/// Richiede minimo 3 workouts in history
class SuggestionInsufficientData extends SuggestionState {
  const SuggestionInsufficientData({
    required this.workoutCount,
    this.requiredCount = 3,
  });

  /// Numero di workout completati
  final int workoutCount;

  /// Numero minimo richiesto (default 3)
  final int requiredCount;

  /// Workout rimanenti per sbloccare
  int get remaining => (requiredCount - workoutCount).clamp(0, requiredCount);

  /// Percentuale di completamento (0-100)
  double get progressPercent => (workoutCount / requiredCount * 100).clamp(0, 100);

  @override
  String toString() => 'SuggestionInsufficientData(count: $workoutCount/$requiredCount)';
}

/// Stato: Suggestion pronta, nessun conflitto
///
/// UI: Mostra CTA con template suggerito + confidence
class SuggestionReady extends SuggestionState {
  const SuggestionReady({
    required this.suggestion,
  });

  /// La suggestion generata dall'algoritmo
  final WorkoutSuggestion suggestion;

  @override
  String toString() => 'SuggestionReady(template: ${suggestion.workoutName})';
}

/// Stato: Suggestion con warning (antagonist conflict)
///
/// UI: Mostra CTA con warning banner + opzione "procedi comunque"
class SuggestionWarning extends SuggestionState {
  const SuggestionWarning({
    required this.suggestion,
    required this.conflict,
  });

  /// La suggestion (potenzialmente rischiosa)
  final WorkoutSuggestion suggestion;

  /// Dettagli del conflitto antagonista
  final AntagonistConflict conflict;

  @override
  String toString() => 'SuggestionWarning(template: ${suggestion.workoutName}, conflict: ${conflict.pair.name})';
}

/// Stato: Errore nel calcolo della suggestion
///
/// UI: Mostra messaggio di errore + retry button
class SuggestionError extends SuggestionState {
  const SuggestionError({
    required this.message,
    this.error,
  });

  /// Messaggio di errore user-friendly
  final String message;

  /// Errore originale (per logging/debug)
  final Object? error;

  @override
  String toString() => 'SuggestionError(message: $message)';
}
