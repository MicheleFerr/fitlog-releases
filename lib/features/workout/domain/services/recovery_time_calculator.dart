import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/pattern_detection_service.dart';

/// Calcola il tempo di recupero ottimale tra allenamenti
///
/// Basato su principi scientifici di recovery muscolare:
/// - Push (Petto/Spalle/Tricipiti): 48-72 ore
/// - Pull (Schiena/Bicipiti): 48-72 ore
/// - Legs (Gambe): 72-96 ore (recupero più lungo)
/// - Full Body: 48 ore minimo
class RecoveryTimeCalculator {

  /// Calcola se un workout type è adeguatamente recuperato
  ///
  /// Returns:
  /// - `isRecovered`: true se il tempo di recupero è passato
  /// - `hoursUntilRecovered`: ore rimanenti prima del recupero completo (0 se già recuperato)
  /// - `recoveryPercentage`: percentuale di recupero (0.0-1.0)
  RecoveryStatus calculateRecoveryStatus({
    required String workoutType,
    required DateTime lastWorkoutTime,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final hoursSinceWorkout = currentTime.difference(lastWorkoutTime).inHours;

    // Determina tempo di recupero minimo in base al tipo di workout
    final minRecoveryHours = _getMinRecoveryHours(workoutType);
    final optimalRecoveryHours = _getOptimalRecoveryHours(workoutType);

    // Calcola percentuale di recupero
    final recoveryPercentage = (hoursSinceWorkout / optimalRecoveryHours).clamp(0.0, 1.0);

    // Considera recuperato se ha passato il tempo minimo
    final isRecovered = hoursSinceWorkout >= minRecoveryHours;

    // Ore rimanenti fino al recupero ottimale
    final hoursUntilOptimal = (optimalRecoveryHours - hoursSinceWorkout).clamp(0, double.infinity).toInt();

    if (kDebugMode) {
      debugPrint('💪 Recovery Status for $workoutType:');
      debugPrint('   Hours since: $hoursSinceWorkout');
      debugPrint('   Min recovery: $minRecoveryHours hours');
      debugPrint('   Optimal recovery: $optimalRecoveryHours hours');
      debugPrint('   Recovery %: ${(recoveryPercentage * 100).toStringAsFixed(0)}%');
      debugPrint('   Is recovered: $isRecovered');
    }

    return RecoveryStatus(
      isRecovered: isRecovered,
      hoursUntilRecovered: hoursUntilOptimal,
      recoveryPercentage: recoveryPercentage,
      workoutType: workoutType,
      hoursSinceWorkout: hoursSinceWorkout,
    );
  }

  /// Calcola recovery status per tutti i workout type nel pattern
  ///
  /// Supporta sia nomi normalizzati (PUSH, PULL) che nomi custom (Pippo, Giovanni)
  /// Se [useExactNames] = true, confronta per nome esatto invece di normalizzare
  ///
  /// Utile per determinare quale workout è meglio recuperato
  Map<String, RecoveryStatus> calculateAllRecoveryStatuses({
    required List<String> workoutTypes,
    required List<WorkoutModel> recentWorkouts,
    DateTime? now,
    bool useExactNames = false, // NUOVO: supporto nomi custom
  }) {
    final currentTime = now ?? DateTime.now();
    final recoveryStatuses = <String, RecoveryStatus>{};

    for (final workoutType in workoutTypes) {
      // Trova l'ultimo workout di questo tipo
      final lastWorkout = recentWorkouts.firstWhere(
        (w) {
          if (useExactNames) {
            // Confronta nomi esatti (case-insensitive)
            return w.name.trim().toLowerCase() == workoutType.trim().toLowerCase();
          } else {
            // Usa normalizzazione per categorie
            return PatternDetectionService.normalizeWorkoutType(w.name) == workoutType;
          }
        },
        orElse: () => WorkoutModel(
          id: 'dummy',
          name: 'dummy',
          exercises: const [],
          status: 'completed',
          startTime: currentTime.subtract(const Duration(days: 365)), // Very old
          createdAt: currentTime.subtract(const Duration(days: 365)),
          updatedAt: currentTime.subtract(const Duration(days: 365)),
        ),
      );

      if (lastWorkout.id != 'dummy' && lastWorkout.startTime != null) {
        recoveryStatuses[workoutType] = calculateRecoveryStatus(
          workoutType: workoutType,
          lastWorkoutTime: lastWorkout.startTime!,
          now: currentTime,
        );
      } else {
        // Nessun workout di questo tipo trovato - considera completamente recuperato
        recoveryStatuses[workoutType] = RecoveryStatus(
          isRecovered: true,
          hoursUntilRecovered: 0,
          recoveryPercentage: 1.0,
          workoutType: workoutType,
          hoursSinceWorkout: 999,
        );
      }
    }

    return recoveryStatuses;
  }

  /// Trova il workout type meglio recuperato da una lista
  ///
  /// Utile quando hai più opzioni e vuoi scegliere quella più recovered
  String? findBestRecoveredWorkout({
    required Map<String, RecoveryStatus> recoveryStatuses,
  }) {
    if (recoveryStatuses.isEmpty) return null;

    // Filtra solo quelli recuperati
    final recovered = recoveryStatuses.entries
        .where((e) => e.value.isRecovered)
        .toList();

    if (recovered.isEmpty) return null;

    // Ordina per percentuale di recupero (più recuperato prima)
    recovered.sort((a, b) => b.value.recoveryPercentage.compareTo(a.value.recoveryPercentage));

    return recovered.first.key;
  }

  /// Boost di confidenza basato sul recovery status
  ///
  /// - Completamente recuperato (100%): +0.15
  /// - Ben recuperato (80-99%): +0.10
  /// - Adeguatamente recuperato (60-79%): +0.05
  /// - Sotto-recuperato (<60%): -0.10
  double getRecoveryConfidenceBoost(RecoveryStatus status) {
    if (status.recoveryPercentage >= 1.0) {
      return 0.15; // Completamente recuperato
    } else if (status.recoveryPercentage >= 0.8) {
      return 0.10; // Ben recuperato
    } else if (status.recoveryPercentage >= 0.6) {
      return 0.05; // Adeguatamente recuperato
    } else if (status.isRecovered) {
      return 0.0; // Recuperato ma non ottimale
    } else {
      return -0.10; // Sotto-recuperato - penalizza
    }
  }

  /// Tempo minimo di recupero in ore per workout type
  ///
  /// Supporta sia categorie standard (PUSH, PULL, LEGS) che nomi custom
  int _getMinRecoveryHours(String workoutType) {
    final normalized = workoutType.toUpperCase();

    switch (normalized) {
      case 'PUSH':
      case 'PULL':
      case 'UPPER':
        return 48; // 2 giorni

      case 'LEGS':
      case 'LOWER':
        return 72; // 3 giorni

      case 'FULL_BODY':
        return 48; // 2 giorni

      case 'CHEST':
      case 'BACK':
      case 'SHOULDERS':
        return 48; // 2 giorni

      case 'ARMS':
      case 'CORE':
        return 36; // 1.5 giorni (recupero più veloce)

      default:
        // Workout custom (es: "Pippo", "Giovanni") - usa default sicuro
        if (kDebugMode) {
          debugPrint('⚙️ Using default recovery time for custom workout: $workoutType');
        }
        return 48; // Default sicuro per workout custom
    }
  }

  /// Tempo ottimale di recupero in ore per workout type
  ///
  /// Supporta sia categorie standard (PUSH, PULL, LEGS) che nomi custom
  int _getOptimalRecoveryHours(String workoutType) {
    final normalized = workoutType.toUpperCase();

    switch (normalized) {
      case 'PUSH':
      case 'PULL':
      case 'UPPER':
        return 72; // 3 giorni ottimale

      case 'LEGS':
      case 'LOWER':
        return 96; // 4 giorni ottimale

      case 'FULL_BODY':
        return 72; // 3 giorni

      case 'CHEST':
      case 'BACK':
      case 'SHOULDERS':
        return 72; // 3 giorni

      case 'ARMS':
      case 'CORE':
        return 48; // 2 giorni

      default:
        // Workout custom - usa default 72 ore (3 giorni)
        return 72; // Default sicuro
    }
  }
}

/// Stato di recupero per un tipo di workout
class RecoveryStatus {
  const RecoveryStatus({
    required this.isRecovered,
    required this.hoursUntilRecovered,
    required this.recoveryPercentage,
    required this.workoutType,
    required this.hoursSinceWorkout,
  });

  /// True se il tempo minimo di recupero è passato
  final bool isRecovered;

  /// Ore rimanenti fino al recupero ottimale (0 se già ottimale)
  final int hoursUntilRecovered;

  /// Percentuale di recupero (0.0 = appena fatto, 1.0 = completamente recuperato)
  final double recoveryPercentage;

  /// Tipo di workout (PUSH, PULL, LEGS, etc.)
  final String workoutType;

  /// Ore passate dall'ultimo workout di questo tipo
  final int hoursSinceWorkout;

  /// Descrizione human-readable dello stato
  String get description {
    if (recoveryPercentage >= 1.0) {
      return 'Completamente recuperato';
    } else if (recoveryPercentage >= 0.8) {
      return 'Ben recuperato';
    } else if (isRecovered) {
      return 'Adeguatamente recuperato';
    } else {
      return 'In recupero ($hoursUntilRecovered ore rimanenti)';
    }
  }

  /// Emoji che rappresenta lo stato di recupero
  String get emoji {
    if (recoveryPercentage >= 1.0) {
      return '💪'; // Completamente recuperato
    } else if (recoveryPercentage >= 0.8) {
      return '✅'; // Ben recuperato
    } else if (isRecovered) {
      return '👍'; // Adeguatamente recuperato
    } else {
      return '⏳'; // In recupero
    }
  }

  @override
  String toString() {
    return 'RecoveryStatus($workoutType: ${(recoveryPercentage * 100).toStringAsFixed(0)}%, '
           'recovered: $isRecovered, hours: $hoursSinceWorkout)';
  }
}
