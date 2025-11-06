import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/onerm_calculation_config.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';

/// 🐛 DEBUG FLAG: Enable verbose APRE calculation logs
/// Set to true only when debugging APRE weight calculations
const bool kEnableApreDebugLogs = false;

/// Livelli di confidenza per calcolo 1RM basati su qualità e quantità dati
enum CalculationConfidence {
  /// ≥10 set, < 7 giorni, SD ≤ 5%
  veryHigh,

  /// 7-9 set, < 14 giorni, SD ≤ 8%
  high,

  /// 4-6 set, < 30 giorni, SD ≤ 12%
  medium,

  /// 1-3 set, < 60 giorni
  low,

  /// 0 set - richiede input manuale
  unknown,
}

/// Estensione per helper text (colors nel presentation layer)
extension ConfidenceHelper on CalculationConfidence {
  String get description {
    switch (this) {
      case CalculationConfidence.veryHigh:
        return 'Eccellente: dati ampi e consistenti';
      case CalculationConfidence.high:
        return 'Buono: dati sufficienti';
      case CalculationConfidence.medium:
        return 'Moderato: dati limitati';
      case CalculationConfidence.low:
        return 'Basso: pochi dati';
      case CalculationConfidence.unknown:
        return 'Non disponibile: richiesto input manuale';
    }
  }

  String get emoji {
    switch (this) {
      case CalculationConfidence.veryHigh:
      case CalculationConfidence.high:
        return '✅';
      case CalculationConfidence.medium:
        return '⚠️';
      case CalculationConfidence.low:
        return '⚠️';
      case CalculationConfidence.unknown:
        return '❌';
    }
  }
}

/// Service to handle APRE (Autoregulatory Progressive Resistance Exercise) protocol
/// This service manages automatic protocol selection, weight calculations, and caching
class APREAutoRegulationService {
  /// Formula scientifica usata per calcolo 1RM da storico
  static const String used1RMFormula = 'Brzycki';

  /// Descrizione della formula Brzycki
  static const String formulaDescription =
      'Brzycki (1-10 reps): 1RM = weight × (36 / (37 - reps))';

  /// Range di validità della formula
  static const int minFormulaReps = 1;
  static const int maxFormulaReps = 10;

  /// Cache validity period (7 days)
  static const int cacheValidityDays = 7;

  /// Automatically selects APRE protocol based on target reps
  /// Protocol determines adjustment aggressiveness and rest time:
  /// - 1-5 reps → APRE 3 (strength focus, aggressive adjustments, 3min rest)
  /// - 6-10 reps → APRE 6 (hypertrophy focus, moderate adjustments, 2min rest)
  /// - 11+ reps → APRE 10 (endurance focus, conservative adjustments, 1min rest)
  ///
  /// Note: Adjustments are always relative to YOUR target reps, not fixed values
  static int selectProtocolFromTargetReps(int targetReps) {
    if (targetReps <= 5) {
      return 3; // Strength protocol
    } else if (targetReps <= 10) {
      return 6; // Hypertrophy protocol
    } else {
      return 10; // Endurance protocol
    }
  }

  /// Determines appropriate rest time based on APRE protocol
  static int getRestTimeForProtocol(int protocol, {
    int strengthRestTime = 180,
    int hypertrophyRestTime = 120,
    int enduranceRestTime = 60,
    int defaultRestTime = 90,
  }) {
    switch (protocol) {
      case 3:
        return strengthRestTime; // 3 minutes for strength
      case 6:
        return hypertrophyRestTime; // 2 minutes for hypertrophy
      case 10:
        return enduranceRestTime; // 1 minute for endurance
      default:
        return defaultRestTime; // 90 seconds default
    }
  }

  /// Calculates all APRE weight values from historical data with enhanced metadata
  /// Returns a map with calculated RMs and detailed statistical metadata
  ///
  /// The [config] parameter determines which strategy to use for selecting
  /// historical sets for calculation. Defaults to [OneRMCalculationConfig.topFiveSets].
  ///
  /// Note: The actual filtering logic for [config] will be implemented in T3.2.
  /// Currently, this parameter is accepted but not yet used in filtering.
  static Map<String, dynamic> calculateAPREWeights({
    required List<dynamic> historicalSets,
    required int protocol,
    bool useMetricSystem = true,
    int? maxSetsToUse = 10,
    OneRMCalculationConfig config = OneRMCalculationConfig.topFiveSets,
  }) {
    if (kEnableApreDebugLogs) {
      debugPrint('[APRE] Calculating weights from ${historicalSets.length} historical sets');
    }

    // HANDLE: Empty history
    if (historicalSets.isEmpty) {
      if (kEnableApreDebugLogs) {
        debugPrint('[APRE] No historical data available');
      }
      return {
        'calculated1RM': null,
        'calculated3RM': null,
        'calculated6RM': null,
        'calculated10RM': null,
        'confidence': CalculationConfidence.unknown,
        'dataPoints': 0,
        'formula': used1RMFormula,
        'metadata': 'Nessuno storico disponibile - richiesto input manuale',
        'requiresManualInput': true,
        'standardDeviation': 0.0,
        'dataAge': Duration.zero,
      };
    }

    // Filter valid sets (weight > 0, reps between 1-15)
    final validSets = historicalSets
        .where((set) =>
            set.weight != null &&
            set.reps != null &&
            set.weight! > 0 &&
            set.reps! > 0 &&
            set.reps! <= 15)
        .toList();

    if (validSets.isEmpty) {
      if (kEnableApreDebugLogs) {
        debugPrint('[APRE] No valid sets found for calculation');
      }
      return {
        'calculated1RM': null,
        'calculated3RM': null,
        'calculated6RM': null,
        'calculated10RM': null,
        'confidence': CalculationConfidence.unknown,
        'dataPoints': 0,
        'formula': used1RMFormula,
        'metadata': 'Nessuno storico disponibile - richiesto input manuale',
        'requiresManualInput': true,
        'standardDeviation': 0.0,
        'dataAge': Duration.zero,
      };
    }

    // STEP 1: Sort by weight (top N sets) - FIX: Use .toList()..sort() instead of .sorted()
    final sortedByWeight = validSets.toList()
      ..sort((a, b) {
        final a1RM = OneRMCalculator.calculateAverage(a.weight!, a.reps!);
        final b1RM = OneRMCalculator.calculateAverage(b.weight!, b.reps!);
        return b1RM.compareTo(a1RM);
      });
    final topSets = sortedByWeight.take(maxSetsToUse ?? 10).toList();

    // Log top sets for debugging
    if (kEnableApreDebugLogs) {
      debugPrint('[APRE] Top ${topSets.length} sets for calculation:');
      for (final set in topSets.take(3)) {
        final est1RM = OneRMCalculator.calculateAverage(set.weight!, set.reps!);
        debugPrint('  ${set.weight}kg x ${set.reps} reps → ${est1RM.toStringAsFixed(1)}kg 1RM');
      }
    }

    // STEP 2: Calculate 1RM for each set using Brzycki
    final estimates1RM = topSets.map((set) {
      return OneRMCalculator.calculateBrzycki(
        set.weight as double,
        set.reps as int,
      );
    }).toList();

    // STEP 3: Calculate statistical data
    final dataAge = _calculateDataAge(topSets);
    final stdDev = _calculateStandardDeviation(estimates1RM);
    final robustAvgEstimates = _robustAverage(estimates1RM);

    final calculated1RM = robustAvgEstimates.isNotEmpty
        ? robustAvgEstimates.fold(0.0, (sum, v) => sum + v) / robustAvgEstimates.length
        : estimates1RM.fold(0.0, (sum, v) => sum + v) / estimates1RM.length;

    // STEP 4: Calculate confidence
    final confidence = _calculateConfidence(
      dataPoints: topSets.length,
      dataAge: dataAge,
      standardDeviation: stdDev,
      estimated1RM: calculated1RM,
    );

    // Calculate weight for each rep range using Brzycki formula for consistency
    final weight3RM = OneRMCalculator.calculateWeightForReps(calculated1RM, 3);
    final weight6RM = OneRMCalculator.calculateWeightForReps(calculated1RM, 6);
    final weight10RM = OneRMCalculator.calculateWeightForReps(calculated1RM, 10);

    // Round to nearest 2.5kg (or 5lbs if imperial)
    final roundingFactor = useMetricSystem ? 2.5 : 5.0;
    final rounded3RM = (weight3RM / roundingFactor).round() * roundingFactor;
    final rounded6RM = (weight6RM / roundingFactor).round() * roundingFactor;
    final rounded10RM = (weight10RM / roundingFactor).round() * roundingFactor;

    if (kEnableApreDebugLogs) {
      debugPrint('[APRE] Calculation complete:');
      debugPrint('  1RM: ${calculated1RM.toStringAsFixed(1)}kg');
      debugPrint('  3RM: ${rounded3RM.toStringAsFixed(1)}kg');
      debugPrint('  6RM: ${rounded6RM.toStringAsFixed(1)}kg');
      debugPrint('  10RM: ${rounded10RM.toStringAsFixed(1)}kg');
      debugPrint('  Confidence: ${confidence.name}');
      debugPrint('  SD: ${stdDev.toStringAsFixed(1)}kg');
      debugPrint('  Data Age: ${dataAge.inDays} days');
    }

    // STEP 5: Return enhanced metadata
    return {
      'calculated1RM': calculated1RM,
      'calculated3RM': rounded3RM,
      'calculated6RM': rounded6RM,
      'calculated10RM': rounded10RM,
      'baseWeight': protocol == 3 ? rounded3RM : protocol == 6 ? rounded6RM : rounded10RM,
      'confidence': confidence,
      'dataPoints': topSets.length,
      'formula': used1RMFormula,
      'standardDeviation': stdDev,
      'dataAge': dataAge,
      'metadata': 'Based on ${topSets.length} sets (Formula: $used1RMFormula, '
          'Confidence: ${confidence.name}, ±${stdDev.toStringAsFixed(1)}kg)',
      'requiresManualInput': false,
    };
  }

  /// Updates exercise with APRE configuration and cached calculations
  static Exercise configureAPREForExercise({
    required Exercise exercise,
    required Map<String, dynamic> calculations,
    required int protocol,
    required int restTime,
  }) {
    return exercise.copyWith(
      autoAdjustmentType: AutoAdjustmentType.apre,
      useAPRE: true,
      apreProtocol: protocol,
      apreBaseWeight: calculations['baseWeight']?.toDouble(),
      calculated1RM: calculations['calculated1RM']?.toDouble(),
      calculated3RM: calculations['calculated3RM']?.toDouble(),
      calculated6RM: calculations['calculated6RM']?.toDouble(),
      calculated10RM: calculations['calculated10RM']?.toDouble(),
      lastCalculationDate: DateTime.now(),
      calculationMetadata: calculations['metadata'],
      restTime: restTime,
    );
  }

  /// Checks if calculations are stale and need refresh
  /// Returns true if calculations are older than 7 days
  static bool shouldRecalculate(Exercise exercise) {
    if (exercise.lastCalculationDate == null) return true;

    final daysSinceCalculation = DateTime.now()
        .difference(exercise.lastCalculationDate!)
        .inDays;

    return daysSinceCalculation > 7;
  }

  /// Gets the appropriate base weight for current protocol
  static double? getBaseWeightForProtocol(Exercise exercise) {
    if (!exercise.useAPRE) return null;

    switch (exercise.apreProtocol) {
      case 3:
        return exercise.calculated3RM ?? exercise.apreBaseWeight;
      case 6:
        return exercise.calculated6RM ?? exercise.apreBaseWeight;
      case 10:
        return exercise.calculated10RM ?? exercise.apreBaseWeight;
      default:
        return exercise.apreBaseWeight;
    }
  }

  /// Adjusts weight based on APRE protocol performance
  /// This is called after completing a set to determine next set's weight
  /// Uses targetReps as baseline for adjustment decisions
  static double calculateNextSetWeight({
    required int protocol,
    required double currentWeight,
    required int targetReps,
    required int actualReps,
  }) {
    // Calculate performance relative to target
    final repsDifference = actualReps - targetReps;
    double adjustment = 0;

    debugPrint('[APRE-ADJUST] Protocol: $protocol, Target: $targetReps, Actual: $actualReps, Diff: $repsDifference');

    // Adjustment based on how far from target (relative to protocol)
    // More aggressive adjustments for strength (protocol 3), less for endurance (protocol 10)
    if (repsDifference <= -3) {
      // Severely under target (e.g., 2 reps when target is 5)
      adjustment = protocol == 3 ? -5.0 : -7.5; // Decrease significantly
    } else if (repsDifference == -2) {
      // Moderately under target (e.g., 3 reps when target is 5)
      adjustment = -2.5; // Decrease moderately
    } else if (repsDifference == -1) {
      // Slightly under target (e.g., 4 reps when target is 5)
      adjustment = protocol == 3 ? -2.5 : 0; // Small decrease or maintain
    } else if (repsDifference == 0) {
      // Hit target exactly - perfect!
      adjustment = 0; // Maintain weight
    } else if (repsDifference == 1) {
      // Slightly over target (e.g., 6 reps when target is 5)
      adjustment = 2.5; // Small increase
    } else if (repsDifference == 2) {
      // Moderately over target (e.g., 7 reps when target is 5)
      adjustment = protocol == 10 ? 2.5 : 5.0; // Moderate increase
    } else {
      // Significantly over target (e.g., 8+ reps when target is 5)
      adjustment = protocol == 10 ? 5.0 : 7.5; // Large increase
    }

    debugPrint('[APRE-ADJUST] Adjustment: ${adjustment >= 0 ? "+" : ""}${adjustment}kg');

    final newWeight = currentWeight + adjustment;

    // Round to nearest 2.5kg and ensure minimum weight
    final roundedWeight = ((newWeight / 2.5).round() * 2.5).clamp(2.5, double.infinity);

    debugPrint('[APRE-ADJUST] Weight: ${currentWeight}kg → ${roundedWeight}kg');

    return roundedWeight;
  }

  /// Generates APRE protocol description for UI
  static String getProtocolDescription(int protocol) {
    switch (protocol) {
      case 3:
        return 'APRE 3 - Strength Protocol (1-5 reps)';
      case 6:
        return 'APRE 6 - Hypertrophy Protocol (6-10 reps)';
      case 10:
        return 'APRE 10 - Endurance Protocol (11+ reps)';
      default:
        return 'APRE Protocol';
    }
  }

  // ============================================================================
  // SET SELECTION STRATEGIES
  // ============================================================================

  /// Selects subset of sets based on configuration strategy
  ///
  /// Implementation will be added in T3.2 - Top Set Selection Logic.
  /// For now, this returns all sets without filtering to maintain
  /// current behavior while allowing the config parameter to be used.
  ///
  /// Future implementation will filter sets based on:
  /// - [OneRMCalculationConfig.topThreeSets] → Most recent 3 sets
  /// - [OneRMCalculationConfig.topFiveSets] → Most recent 5 sets (default)
  /// - [OneRMCalculationConfig.allSetsInWindow] → All sets (no filtering)
  /// - [OneRMCalculationConfig.medianOfTop5] → Median of top 5 sets
  // ignore: unused_element (T3.2 placeholder - will be used when filtering logic is implemented)
  static List<dynamic> _selectTopSets(
    List<dynamic> allSets,
    OneRMCalculationConfig config,
  ) {
    // TODO(T3.2): Implement filtering logic based on config
    // For now, return all sets to maintain current behavior
    return allSets;
  }

  // ============================================================================
  // METADATA CALCULATION HELPERS
  // ============================================================================

  /// Calcola livello di confidenza basato su qualità e quantità dati
  static CalculationConfidence _calculateConfidence({
    required int dataPoints,
    required Duration dataAge,
    required double standardDeviation,
    required double estimated1RM,
  }) {
    if (dataPoints == 0) {
      return CalculationConfidence.unknown;
    }

    // Calcola SD percentuale rispetto a 1RM
    final sdPercent = (standardDeviation / estimated1RM) * 100;

    // Soglie variabili per confidence
    if (dataPoints >= 10 && dataAge.inDays <= 7 && sdPercent <= 5) {
      return CalculationConfidence.veryHigh;
    } else if (dataPoints >= 7 && dataAge.inDays <= 14 && sdPercent <= 8) {
      return CalculationConfidence.high;
    } else if (dataPoints >= 4 && dataAge.inDays <= 30 && sdPercent <= 12) {
      return CalculationConfidence.medium;
    } else if (dataPoints >= 1) {
      return CalculationConfidence.low;
    } else {
      return CalculationConfidence.unknown;
    }
  }

  /// Calcola età mediana dei dati (restituisce tempo trascorso dalla data mediana)
  static Duration _calculateDataAge(List<dynamic> sets) {
    if (sets.isEmpty) return Duration.zero;

    final now = DateTime.now();

    // Estrai le date e ordina
    final dates = sets
        .where((s) => s.date != null)
        .map((s) => s.date as DateTime)
        .toList()
      ..sort();

    if (dates.isEmpty) return Duration.zero;

    // Prendi la data mediana
    final midIndex = dates.length ~/ 2;
    return now.difference(dates[midIndex]);
  }

  /// Calcola deviazione standard dei valori
  static double _calculateStandardDeviation(List<double> values) {
    if (values.length < 2) return 0;

    final mean = values.fold(0.0, (sum, v) => sum + v) / values.length;
    final variance = values
            .map((v) => pow(v - mean, 2) as double)
            .fold(0.0, (sum, v) => sum + v) /
        values.length;

    return sqrt(variance);
  }

  /// Filtra outlier usando metodo IQR (Interquartile Range)
  /// Rimuove valori che sono troppo distanti dalla distribuzione centrale
  static List<double> _robustAverage(List<double> values) {
    if (values.isEmpty) return [];
    if (values.length == 1) return values;

    // Ordina i valori
    final sorted = List<double>.from(values)..sort();

    // Calcola quartili per IQR
    final q1Index = (sorted.length / 4).floor();
    final q3Index = ((sorted.length * 3) / 4).floor();
    final q1 = sorted[q1Index];
    final q3 = sorted[q3Index];
    final iqr = q3 - q1;

    // Rimuovi outlier (valori oltre 1.5 * IQR dai quartili)
    final filtered = sorted
        .where((v) => v >= (q1 - 1.5 * iqr) && v <= (q3 + 1.5 * iqr))
        .toList();

    return filtered;
  }
}