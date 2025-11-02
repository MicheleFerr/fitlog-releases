/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/failures
/// 🎯 Feature: workout
/// 🔧 Type: failure hierarchy (Chart Data)
/// 🌍 Localization: N/A (Error codes)
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - fpdart: Either pattern
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_failure.freezed.dart';

/// Base class per errori chart data
///
/// Freezed per type-safety e pattern matching.
/// Usato con Either<ChartFailure, T> per error handling funzionale.
///
/// Gerarchia:
/// - DataNotFound: Nessun dato disponibile
/// - InvalidInput: Input non valido (nome esercizio vuoto, metrica sconosciuta)
/// - CacheFailure: Errore cache/storage
/// - ServerFailure: Errore remoto (Firestore)
/// - UnknownFailure: Errore generico/inatteso
@freezed
class ChartFailure with _$ChartFailure {
  /// Nessun dato disponibile per parametri specificati
  ///
  /// Scenarios:
  /// - Esercizio mai eseguito
  /// - Periodo senza allenamenti
  /// - Metrica non tracciata
  const factory ChartFailure.dataNotFound({
    @Default('No data found for chart') String message,
  }) = DataNotFound;

  /// Input non valido
  ///
  /// Scenarios:
  /// - Exercise name vuoto
  /// - Metrica non supportata
  /// - Days <= 0
  const factory ChartFailure.invalidInput({
    @Default('Invalid input parameters') String message,
    String? details,
  }) = InvalidInput;

  /// Errore cache/local storage
  ///
  /// Scenarios:
  /// - Hive read/write error
  /// - Corrupted data
  const factory ChartFailure.cacheFailure({
    @Default('Cache error') String message,
    Object? error,
  }) = CacheFailure;

  /// Errore server/Firestore
  ///
  /// Scenarios:
  /// - Network error
  /// - Permission denied
  /// - Firestore timeout
  const factory ChartFailure.serverFailure({
    @Default('Server error') String message,
    Object? error,
  }) = ServerFailure;

  /// Errore generico/inatteso
  ///
  /// Fallback per errori non categorizzati
  const factory ChartFailure.unknown({
    @Default('Unknown error occurred') String message,
    Object? error,
    StackTrace? stackTrace,
  }) = UnknownFailure;
}
