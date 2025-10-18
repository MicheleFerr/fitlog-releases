/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/home/domain/services
/// 🎯 Feature: home
/// 🔧 Type: service
///
/// Servizio che rileva anomalie nei dati di allenamento
/// Implementa validazioni scientificamente accurate per garantire data quality
library;

import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/home/domain/entities/data_anomaly.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

/// Servizio per validazione e rilevamento anomalie nei dati
class DataValidationService {
  /// Limiti realistici per pesi (in kg) per categoria di esercizio
  static const Map<String, double> _maxWeightLimits = {
    'legs': 500.0,      // Squat, Leg Press, Deadlift
    'upper': 300.0,     // Bench, Row, Pull-up
    'isolation': 100.0, // Bicep curl, Lateral raise, etc.
    'default': 250.0,   // Default per esercizi non categorizzati
  };

  /// Massimo numero di ripetizioni realistico
  static const int _maxReps = 50;

  /// Minimo peso significativo (sotto questo = probabilmente errore di input)
  static const double _minSignificantWeight = 0.5;

  /// Soglia per weight jump estremo (percentuale)
  static const double _extremeWeightJumpThreshold = 0.40; // 40%

  /// Analizza una lista di attività e rileva tutte le anomalie
  static List<DataAnomaly> detectAnomalies(
    List<ExerciseActivity> activities,
    Map<String, Exercise> exerciseDatabase,
  ) {
    final anomalies = <DataAnomaly>[];

    // Raggruppa per esercizio per analisi temporali
    final exerciseGroups = <String, List<ExerciseActivity>>{};
    for (final activity in activities) {
      exerciseGroups.putIfAbsent(activity.exerciseName, () => []).add(activity);
    }

    // Analizza ogni gruppo di esercizio
    for (final entry in exerciseGroups.entries) {
      final exerciseName = entry.key;
      final exerciseActivities = entry.value
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Ottieni esercizio dal database per categoria
      final exercise = exerciseDatabase[exerciseName];

      // Analizza ogni attività singolarmente
      for (final activity in exerciseActivities) {
        anomalies.addAll(_validateActivity(activity, exercise));
      }

      // Analisi temporale (weight jumps, outliers)
      if (exerciseActivities.length >= 2) {
        anomalies.addAll(_detectWeightJumps(exerciseActivities));
      }

      if (exerciseActivities.length >= 5) {
        anomalies.addAll(_detectVolumeOutliers(exerciseActivities));
      }
    }

    // Rileva duplicati
    anomalies.addAll(_detectDuplicates(activities));

    return anomalies;
  }

  /// Valida una singola attività
  static List<DataAnomaly> _validateActivity(
    ExerciseActivity activity,
    Exercise? exercise,
  ) {
    final anomalies = <DataAnomaly>[];

    // Check per data futura
    if (activity.createdAt.isAfter(DateTime.now())) {
      anomalies.add(DataAnomaly(
        id: '${activity.id}_future_date',
        type: AnomalyType.futureDate,
        severity: AnomalySeverity.critical,
        exerciseName: activity.exerciseName,
        activityId: activity.id,
        detectedAt: DateTime.now(),
        anomalousData: {
          'date': activity.createdAt.toIso8601String(),
        },
        description: 'Activity date is in the future',
        recommendation: 'Verify and correct the date',
        suggestedCorrection: {
          'date': DateTime.now().toIso8601String(),
        },
        suggestedAction: AnomalyAction.correct,
      ));
    }

    // Determina limite peso per questo esercizio
    final weightLimit = _getWeightLimit(exercise);

    // Valida ogni set
    for (var i = 0; i < activity.sets.length; i++) {
      final set = activity.sets[i];
      if (!set.done) continue; // Salta set non completati

      final weight = _parseWeight(set.weight);
      final reps = _parseReps(set.reps);

      // Check peso negativo
      if (weight < 0) {
        anomalies.add(DataAnomaly(
          id: '${activity.id}_set_${i}_negative_weight',
          type: AnomalyType.negativeValues,
          severity: AnomalySeverity.critical,
          exerciseName: activity.exerciseName,
          activityId: activity.id,
          detectedAt: DateTime.now(),
          anomalousData: {
            'setIndex': i,
            'weight': weight,
            'reps': reps,
          },
          description: 'Negative weight detected in set ${i + 1}',
          recommendation: 'Weight cannot be negative. Correct the value.',
          suggestedCorrection: {
            'weight': weight.abs(), // Suggerisci valore assoluto
          },
          suggestedAction: AnomalyAction.correct,
        ));
      }

      // Check ripetizioni negative
      if (reps < 0) {
        anomalies.add(DataAnomaly(
          id: '${activity.id}_set_${i}_negative_reps',
          type: AnomalyType.negativeValues,
          severity: AnomalySeverity.critical,
          exerciseName: activity.exerciseName,
          activityId: activity.id,
          detectedAt: DateTime.now(),
          anomalousData: {
            'setIndex': i,
            'weight': weight,
            'reps': reps,
          },
          description: 'Negative reps detected in set ${i + 1}',
          recommendation: 'Reps cannot be negative. Correct the value.',
          suggestedCorrection: {
            'reps': reps.abs(),
          },
          suggestedAction: AnomalyAction.correct,
        ));
      }

      // Check peso impossibile
      if (weight > weightLimit) {
        anomalies.add(DataAnomaly(
          id: '${activity.id}_set_${i}_impossible_weight',
          type: AnomalyType.impossibleWeight,
          severity: AnomalySeverity.warning,
          exerciseName: activity.exerciseName,
          activityId: activity.id,
          detectedAt: DateTime.now(),
          anomalousData: {
            'setIndex': i,
            'weight': weight,
            'reps': reps,
            'limit': weightLimit,
          },
          description: 'Weight ${weight.toStringAsFixed(1)}kg exceeds realistic limit (${weightLimit.toStringAsFixed(0)}kg)',
          recommendation: 'Verify the weight. This is above typical human performance.',
          suggestedAction: AnomalyAction.verify,
        ));
      }

      // Check ripetizioni impossibili
      if (reps > _maxReps) {
        anomalies.add(DataAnomaly(
          id: '${activity.id}_set_${i}_impossible_reps',
          type: AnomalyType.impossibleReps,
          severity: AnomalySeverity.warning,
          exerciseName: activity.exerciseName,
          activityId: activity.id,
          detectedAt: DateTime.now(),
          anomalousData: {
            'setIndex': i,
            'weight': weight,
            'reps': reps,
            'limit': _maxReps,
          },
          description: '${reps.toStringAsFixed(0)} reps is unusually high',
          recommendation: 'Verify the rep count. Consider if this is accurate.',
          suggestedAction: AnomalyAction.verify,
        ));
      }

      // Check zero values (peso o reps = 0 su set completato)
      if (weight == 0 && reps > 0) {
        anomalies.add(DataAnomaly(
          id: '${activity.id}_set_${i}_zero_weight',
          type: AnomalyType.zeroValues,
          severity: AnomalySeverity.warning,
          exerciseName: activity.exerciseName,
          activityId: activity.id,
          detectedAt: DateTime.now(),
          anomalousData: {
            'setIndex': i,
            'weight': weight,
            'reps': reps,
          },
          description: 'Weight is zero but reps are recorded',
          recommendation: 'Bodyweight exercise? Verify if weight should be recorded.',
          suggestedAction: AnomalyAction.verify,
        ));
      }
    }

    return anomalies;
  }

  /// Rileva salti di peso estremi tra sessioni
  static List<DataAnomaly> _detectWeightJumps(
    List<ExerciseActivity> sortedActivities,
  ) {
    final anomalies = <DataAnomaly>[];

    for (var i = 1; i < sortedActivities.length; i++) {
      final prevActivity = sortedActivities[i - 1];
      final currActivity = sortedActivities[i];

      final prevWeight = _getMaxWeight(prevActivity);
      final currWeight = _getMaxWeight(currActivity);

      if (prevWeight > _minSignificantWeight && currWeight > prevWeight) {
        final increase = (currWeight - prevWeight) / prevWeight;
        final absoluteIncrease = currWeight - prevWeight;

        // Soglia adattiva: più tollerante per pesi bassi
        final isLowWeight = prevWeight < 20;
        final threshold = isLowWeight ? 0.50 : _extremeWeightJumpThreshold;

        if (increase > threshold && absoluteIncrease > 5) {
          anomalies.add(DataAnomaly(
            id: '${currActivity.id}_extreme_weight_jump',
            type: AnomalyType.extremeWeightJump,
            severity: AnomalySeverity.warning,
            exerciseName: currActivity.exerciseName,
            activityId: currActivity.id,
            detectedAt: DateTime.now(),
            anomalousData: {
              'previousWeight': prevWeight,
              'currentWeight': currWeight,
              'increase': increase,
              'absoluteIncrease': absoluteIncrease,
              'threshold': threshold,
            },
            description: 'Weight increased by ${(increase * 100).toStringAsFixed(0)}% (${absoluteIncrease.toStringAsFixed(1)}kg)',
            recommendation: 'Large weight jump detected. Verify accuracy and check form.',
            suggestedCorrection: {
              // Suggerisci incremento più conservativo (10%)
              'weight': prevWeight * 1.10,
            },
            suggestedAction: AnomalyAction.verify,
          ));
        }
      }
    }

    return anomalies;
  }

  /// Rileva outlier di volume rispetto alla media dell'esercizio
  static List<DataAnomaly> _detectVolumeOutliers(
    List<ExerciseActivity> sortedActivities,
  ) {
    final anomalies = <DataAnomaly>[];

    // Calcola volumi
    final volumes = sortedActivities.map(_calculateActivityVolume).toList();

    // Calcola media e deviazione standard
    final mean = volumes.reduce((a, b) => a + b) / volumes.length;
    final variance = volumes
        .map((v) => (v - mean) * (v - mean))
        .reduce((a, b) => a + b) / volumes.length;
    final stdDev = variance > 0 ? variance.sqrt() : 0.0;

    // Identifica outlier (>3 deviazioni standard dalla media)
    for (var i = 0; i < sortedActivities.length; i++) {
      final activity = sortedActivities[i];
      final volume = volumes[i];

      if (stdDev > 0 && (volume - mean).abs() > 3 * stdDev) {
        final isHigh = volume > mean;
        anomalies.add(DataAnomaly(
          id: '${activity.id}_volume_outlier',
          type: AnomalyType.outlierVolume,
          severity: AnomalySeverity.info,
          exerciseName: activity.exerciseName,
          activityId: activity.id,
          detectedAt: DateTime.now(),
          anomalousData: {
            'volume': volume,
            'mean': mean,
            'stdDev': stdDev,
            'isHigh': isHigh,
          },
          description: 'Volume is ${isHigh ? "much higher" : "much lower"} than typical (${volume.toStringAsFixed(0)} vs avg ${mean.toStringAsFixed(0)})',
          recommendation: 'Verify if this workout was unusually ${isHigh ? "intense" : "light"}.',
          suggestedAction: AnomalyAction.verify,
        ));
      }
    }

    return anomalies;
  }

  /// Rileva entry duplicate (stesso esercizio, peso, reps nello stesso minuto)
  static List<DataAnomaly> _detectDuplicates(List<ExerciseActivity> activities) {
    final anomalies = <DataAnomaly>[];
    final seen = <String, ExerciseActivity>{};

    for (final activity in activities) {
      // Crea fingerprint dell'attività
      final maxWeight = _getMaxWeight(activity);
      final totalSets = activity.sets.where((s) => s.done).length;
      final dateMinute = DateTime(
        activity.createdAt.year,
        activity.createdAt.month,
        activity.createdAt.day,
        activity.createdAt.hour,
        activity.createdAt.minute,
      );

      final fingerprint = '${activity.exerciseName}_${maxWeight}_${totalSets}_${dateMinute.millisecondsSinceEpoch}';

      if (seen.containsKey(fingerprint)) {
        final duplicate = seen[fingerprint]!;
        anomalies.add(DataAnomaly(
          id: '${activity.id}_duplicate',
          type: AnomalyType.duplicateEntry,
          severity: AnomalySeverity.warning,
          exerciseName: activity.exerciseName,
          activityId: activity.id,
          detectedAt: DateTime.now(),
          anomalousData: {
            'duplicateId': duplicate.id,
            'maxWeight': maxWeight,
            'totalSets': totalSets,
            'date': dateMinute.toIso8601String(),
          },
          description: 'Possible duplicate entry with same exercise, weight, and timestamp',
          recommendation: 'Review if this is a duplicate. Consider removing.',
          suggestedAction: AnomalyAction.verify,
        ));
      } else {
        seen[fingerprint] = activity;
      }
    }

    return anomalies;
  }

  /// Ottieni limite peso per categoria esercizio
  static double _getWeightLimit(Exercise? exercise) {
    if (exercise == null) return _maxWeightLimits['default']!;

    // Determina categoria in base a muscle group
    final primaryMuscle = exercise.muscleGroups.isNotEmpty
        ? exercise.muscleGroups.first
        : '';

    if (['QUAD', 'FEMOR', 'GLUT'].contains(primaryMuscle)) {
      return _maxWeightLimits['legs']!;
    }

    // Esercizi di isolamento (singolo muscolo, bodyweight, cables)
    if (exercise.equipment.contains('Cables') ||
        exercise.equipment.contains('Machine') ||
        exercise.muscleGroups.length == 1 && ['BRAC', 'TRIC', 'DELT'].contains(primaryMuscle)) {
      return _maxWeightLimits['isolation']!;
    }

    return _maxWeightLimits['upper']!;
  }

  /// Calcola volume totale di un'attività
  static double _calculateActivityVolume(ExerciseActivity activity) {
    double volume = 0;
    for (final set in activity.sets) {
      if (set.done) {
        final weight = _parseWeight(set.weight);
        final reps = _parseReps(set.reps);
        volume += weight * reps;
      }
    }
    return volume;
  }

  /// Ottieni peso massimo usato in un'attività
  static double _getMaxWeight(ExerciseActivity activity) {
    double maxWeight = 0;
    for (final set in activity.sets) {
      if (set.done) {
        final weight = _parseWeight(set.weight);
        if (weight > maxWeight) {
          maxWeight = weight;
        }
      }
    }
    return maxWeight;
  }

  /// Parse peso in modo sicuro
  static double _parseWeight(dynamic weight) {
    if (weight == null) return 0.0;
    if (weight is double) return weight;
    if (weight is int) return weight.toDouble();
    if (weight is String) return double.tryParse(weight) ?? 0.0;
    return 0.0;
  }

  /// Parse reps in modo sicuro
  static double _parseReps(dynamic reps) {
    if (reps == null) return 0.0;
    if (reps is double) return reps;
    if (reps is int) return reps.toDouble();
    if (reps is String) return double.tryParse(reps) ?? 0.0;
    return 0.0;
  }
}

/// Extension per calcolare sqrt
extension on double {
  double sqrt() => this < 0 ? 0 : _sqrtImpl(this);

  static double _sqrtImpl(double x) {
    if (x == 0) return 0;
    double z = x;
    double prev;
    do {
      prev = z;
      z = (z + x / z) / 2;
    } while ((z - prev).abs() > 0.0001);
    return z;
  }
}
