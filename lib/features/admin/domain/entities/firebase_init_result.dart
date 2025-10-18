/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/domain/entities
/// 🎯 Feature: admin
/// 🔧 Type: entity
///
/// Entità che rappresenta il risultato dell'inizializzazione Firebase
library;

import 'package:equatable/equatable.dart';

class FirebaseInitResult extends Equatable {

  const FirebaseInitResult._({
    required this.success,
    required this.message,
    required this.duration,
    this.exerciseCount,
    this.batchCount,
    this.error,
    this.details,
  });

  /// Costruttore per risultato di successo
  factory FirebaseInitResult.success({
    required int exerciseCount,
    required int batchCount,
    required Duration duration,
    required String message,
    Map<String, dynamic>? details,
  }) {
    return FirebaseInitResult._(
      success: true,
      message: message,
      duration: duration,
      exerciseCount: exerciseCount,
      batchCount: batchCount,
      details: details,
    );
  }

  /// Costruttore per risultato di fallimento
  factory FirebaseInitResult.failure(
    String error,
    Duration duration, {
    Map<String, dynamic>? details,
  }) {
    return FirebaseInitResult._(
      success: false,
      message: error,
      duration: duration,
      error: error,
      details: details,
    );
  }
  final bool success;
  final String message;
  final Duration duration;
  final int? exerciseCount;
  final int? batchCount;
  final String? error;
  final Map<String, dynamic>? details;

  /// Getter per statistiche formattate
  String get formattedStats {
    if (!success) return 'Operation failed: $message';

    final buffer = StringBuffer();
    buffer.writeln('✅ Operation completed successfully');
    buffer.writeln('📚 Exercises: ${exerciseCount ?? 0}');
    buffer.writeln('📦 Batches: ${batchCount ?? 0}');
    buffer.writeln('⏱️ Duration: ${duration.inSeconds}s');

    if (details != null && details!.isNotEmpty) {
      buffer.writeln('📋 Details:');
      details!.forEach((key, value) {
        buffer.writeln('   • $key: $value');
      });
    }

    return buffer.toString();
  }

  /// Getter per summary breve
  String get summary {
    if (!success) return 'Failed: $message';

    return 'Success: ${exerciseCount ?? 0} exercises in ${duration.inSeconds}s';
  }

  /// Converte in JSON per logging
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'duration_ms': duration.inMilliseconds,
      'exercise_count': exerciseCount,
      'batch_count': batchCount,
      'error': error,
      'details': details,
    };
  }

  @override
  List<Object?> get props => [
        success,
        message,
        duration,
        exerciseCount,
        batchCount,
        error,
        details,
      ];

  @override
  String toString() {
    return 'FirebaseInitResult(success: $success, message: $message, duration: ${duration.inSeconds}s)';
  }
}