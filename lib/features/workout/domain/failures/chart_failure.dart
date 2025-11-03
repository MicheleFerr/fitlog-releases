/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/failures
/// 🎯 Feature: workout
/// 🔧 Type: failure (error handling)
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies: None (pure domain)
library;

/// Chart failure sealed class
///
/// Rappresenta tutti i possibili errori che possono verificarsi
/// durante il caricamento dei dati chart
sealed class ChartFailure {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const ChartFailure({
    required this.message,
    this.error,
    this.stackTrace,
  });

  /// Invalid input parameters
  const factory ChartFailure.invalidInput({
    required String message,
    String? details,
  }) = ChartInvalidInputFailure;

  /// Server/Firebase error
  const factory ChartFailure.serverFailure({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) = ChartServerFailure;

  /// Unknown/unexpected error
  const factory ChartFailure.unknown({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) = ChartUnknownFailure;
}

/// Invalid input failure (validation error)
final class ChartInvalidInputFailure extends ChartFailure {
  final String? details;

  const ChartInvalidInputFailure({
    required super.message,
    this.details,
  }) : super(error: null, stackTrace: null);

  @override
  String toString() => 'ChartInvalidInputFailure(message: $message, details: $details)';
}

/// Server failure (network, Firebase, etc.)
final class ChartServerFailure extends ChartFailure {
  const ChartServerFailure({
    required super.message,
    super.error,
    super.stackTrace,
  });

  @override
  String toString() => 'ChartServerFailure(message: $message, error: $error)';
}

/// Unknown failure (catch-all)
final class ChartUnknownFailure extends ChartFailure {
  const ChartUnknownFailure({
    required super.message,
    super.error,
    super.stackTrace,
  });

  @override
  String toString() => 'ChartUnknownFailure(message: $message, error: $error)';
}
