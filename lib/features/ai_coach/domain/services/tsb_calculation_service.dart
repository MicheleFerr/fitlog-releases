/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/services
/// 🎯 Feature: ai_coach
/// 🔧 Type: service
///
/// TSB (Training Stress Balance) Calculation Service
///
/// **TSB Formula**: TSB = CTL - ATL
/// - **CTL (Chronic Training Load)**: 42-day fitness baseline
/// - **ATL (Acute Training Load)**: 7-day fatigue level
/// - **TSB**: Balance between fitness and fatigue
///
/// **Interpretation**:
/// - **TSB > +5**: Very fresh, potentially detraining
/// - **TSB 0 to +5**: Well-recovered, optimal for training
/// - **TSB -5 to 0**: Normal training load, good adaptation
/// - **TSB -10 to -5**: Moderate fatigue, monitor recovery
/// - **TSB -15 to -10**: High fatigue, consider deload
/// - **TSB < -15**: Very high fatigue, overtraining risk
///
/// **Resistance Training Adaptation**:
/// - Uses volume load (sets × reps × weight) as training stress proxy
/// - Accounts for different exercise intensities
/// - Smooths day-to-day variability with exponential weighted average
library;

import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// TSB Calculation Service for training load management
///
/// **Usage**:
/// ```dart
/// final service = TsbCalculationService();
/// final tsb = service.calculateTsb(workouts);
///
/// print('TSB: ${tsb.toStringAsFixed(1)}');
/// if (tsb < -10) {
///   print('Warning: High overtraining risk!');
/// }
/// ```
class TsbCalculationService {
  /// Chronic Training Load window (days) - Represents fitness
  static const int ctlWindowDays = 42;

  /// Acute Training Load window (days) - Represents fatigue
  static const int atlWindowDays = 7;

  /// Exponential decay constant for CTL (slower adaptation)
  static const double ctlDecayConstant = 42.0;

  /// Exponential decay constant for ATL (faster adaptation)
  static const double atlDecayConstant = 7.0;

  /// Calculate TSB (Training Stress Balance) from workout history
  ///
  /// **Formula**: TSB = CTL - ATL
  /// - Positive TSB: Recovered, fresh (CTL > ATL)
  /// - Negative TSB: Fatigued (ATL > CTL)
  ///
  /// **Parameters**:
  /// - `workouts`: List of completed workouts (minimum 7 days recommended)
  ///
  /// **Returns**: TSB score (typical range: -20 to +10)
  double calculateTsb(List<Workout> workouts) {
    if (workouts.isEmpty) return 0.0;

    // Calculate daily training stress scores
    final dailyStressScores = _calculateDailyStressScores(workouts);

    if (dailyStressScores.isEmpty) return 0.0;

    // Calculate CTL (Chronic Training Load) - 42-day fitness baseline
    final ctl = _calculateExponentialWeightedAverage(
      dailyStressScores,
      windowDays: ctlWindowDays,
      decayConstant: ctlDecayConstant,
    );

    // Calculate ATL (Acute Training Load) - 7-day fatigue level
    final atl = _calculateExponentialWeightedAverage(
      dailyStressScores,
      windowDays: atlWindowDays,
      decayConstant: atlDecayConstant,
    );

    // TSB = CTL - ATL
    final tsb = ctl - atl;

    return tsb;
  }

  /// Calculate individual components (CTL, ATL, TSB) for detailed analysis
  ///
  /// **Returns**: Map with 'ctl', 'atl', and 'tsb' keys
  Map<String, double> calculateComponents(List<Workout> workouts) {
    if (workouts.isEmpty) {
      return {'ctl': 0.0, 'atl': 0.0, 'tsb': 0.0};
    }

    final dailyStressScores = _calculateDailyStressScores(workouts);

    final ctl = _calculateExponentialWeightedAverage(
      dailyStressScores,
      windowDays: ctlWindowDays,
      decayConstant: ctlDecayConstant,
    );

    final atl = _calculateExponentialWeightedAverage(
      dailyStressScores,
      windowDays: atlWindowDays,
      decayConstant: atlDecayConstant,
    );

    final tsb = ctl - atl;

    return {
      'ctl': ctl,
      'atl': atl,
      'tsb': tsb,
    };
  }

  /// Assess training load status based on TSB value
  ///
  /// **Thresholds**:
  /// - TSB > +5: Very fresh (potential detraining)
  /// - TSB 0 to +5: Optimal (well-recovered)
  /// - TSB -5 to 0: Normal (good adaptation)
  /// - TSB -10 to -5: Moderate fatigue
  /// - TSB -15 to -10: High fatigue (deload recommended)
  /// - TSB < -15: Very high fatigue (overtraining risk)
  TrainingLoadStatus assessTrainingLoadStatus(double tsb) {
    if (tsb > 5) return TrainingLoadStatus.veryFresh;
    if (tsb > 0) return TrainingLoadStatus.optimal;
    if (tsb > -5) return TrainingLoadStatus.normal;
    if (tsb > -10) return TrainingLoadStatus.moderateFatigue;
    if (tsb > -15) return TrainingLoadStatus.highFatigue;
    return TrainingLoadStatus.veryHighFatigue;
  }

  /// Predict TSB for future date assuming no training
  ///
  /// **Logic**: ATL decreases faster than CTL during rest
  /// - ATL decays with 7-day half-life
  /// - CTL decays with 42-day half-life
  ///
  /// **Use Case**: Estimate recovery time needed to reach target TSB
  double predictTsbAfterRestDays({
    required double currentCtl,
    required double currentAtl,
    required int restDays,
  }) {
    // Exponential decay during rest
    final predictedAtl = currentAtl * _exponentialDecay(restDays, atlDecayConstant);
    final predictedCtl = currentCtl * _exponentialDecay(restDays, ctlDecayConstant);

    return predictedCtl - predictedAtl;
  }

  /// Calculate days of rest needed to reach target TSB
  ///
  /// **Use Case**: "How many rest days to recover to TSB = 0?"
  ///
  /// **Returns**: Number of rest days needed (or null if already at target)
  int? calculateRestDaysNeeded({
    required double currentTsb,
    required double currentCtl,
    required double currentAtl,
    required double targetTsb,
  }) {
    if (currentTsb >= targetTsb) return 0; // Already at target

    // Binary search for optimal rest days (max 14 days)
    for (int days = 1; days <= 14; days++) {
      final predictedTsb = predictTsbAfterRestDays(
        currentCtl: currentCtl,
        currentAtl: currentAtl,
        restDays: days,
      );

      if (predictedTsb >= targetTsb) {
        return days;
      }
    }

    return null; // More than 14 days needed
  }

  // ========================================================================
  // Private Helper Methods
  // ========================================================================

  /// Calculate daily training stress scores from workouts
  ///
  /// **Training Stress Score (TSS)**:
  /// - Based on volume load (sets × reps × weight)
  /// - Normalized by exercise difficulty
  /// - Grouped by day for smoothing
  Map<DateTime, double> _calculateDailyStressScores(List<Workout> workouts) {
    final dailyScores = <DateTime, double>{};

    for (final workout in workouts) {
      if (workout.startTime == null) continue;

      // Normalize to start of day
      final dayKey = DateTime(
        workout.startTime!.year,
        workout.startTime!.month,
        workout.startTime!.day,
      );

      // Calculate workout stress score (volume load)
      final workoutStress = _calculateWorkoutStress(workout);

      // Accumulate stress for the day
      dailyScores[dayKey] = (dailyScores[dayKey] ?? 0.0) + workoutStress;
    }

    return dailyScores;
  }

  /// Calculate training stress for a single workout
  ///
  /// **Formula**: Σ(sets × reps × weight × intensity_factor)
  /// - Intensity factor accounts for RPE/RIR (future enhancement)
  double _calculateWorkoutStress(Workout workout) {
    double totalStress = 0.0;

    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        final weight = set.weight ?? 0.0;
        final reps = set.actualReps ?? set.reps ?? 0;

        // Volume load for this set
        final setVolume = weight * reps;

        // TODO: Add intensity factor based on RPE/RIR (future enhancement)
        // For now, use raw volume load
        totalStress += setVolume;
      }
    }

    // Normalize to prevent extremely large numbers
    // Typical workout stress: 1000-5000 for moderate session
    return totalStress / 100.0;
  }

  /// Calculate exponentially weighted average (smoothing)
  ///
  /// **Formula**: EWA = Σ(value × weight) / Σ(weight)
  /// - Recent days have higher weight
  /// - Weight = e^(-days_ago / decay_constant)
  double _calculateExponentialWeightedAverage(
    Map<DateTime, double> dailyScores, {
    required int windowDays,
    required double decayConstant,
  }) {
    if (dailyScores.isEmpty) return 0.0;

    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: windowDays));

    double weightedSum = 0.0;
    double totalWeight = 0.0;

    dailyScores.forEach((date, score) {
      if (date.isBefore(cutoffDate)) return; // Skip old data

      final daysAgo = now.difference(date).inDays;

      // Exponential weight (recent days have higher weight)
      final weight = _exponentialDecay(daysAgo, decayConstant);

      weightedSum += score * weight;
      totalWeight += weight;
    });

    if (totalWeight == 0) return 0.0;

    return weightedSum / totalWeight;
  }

  /// Exponential decay function
  ///
  /// **Formula**: e^(-days / constant)
  double _exponentialDecay(int days, double constant) {
    // Approximation: e^x ≈ (1 + x/n)^n for large n
    // For better accuracy, use Taylor series
    final exponent = -days / constant;
    return _exp(exponent);
  }

  /// Simple exponential function (e^x) using Taylor series
  ///
  /// **Formula**: e^x = 1 + x + x²/2! + x³/3! + ...
  double _exp(double x) {
    if (x == 0) return 1.0;

    double result = 1.0;
    double term = 1.0;

    // Taylor series (10 terms for reasonable accuracy)
    for (int n = 1; n <= 10; n++) {
      term *= x / n;
      result += term;
    }

    return result;
  }
}

/// Training load status based on TSB value
enum TrainingLoadStatus {
  /// Very fresh (TSB > +5) - Potential detraining
  veryFresh,

  /// Optimal (TSB 0 to +5) - Well-recovered, ready to train
  optimal,

  /// Normal (TSB -5 to 0) - Good adaptation zone
  normal,

  /// Moderate fatigue (TSB -10 to -5) - Monitor recovery
  moderateFatigue,

  /// High fatigue (TSB -15 to -10) - Deload recommended
  highFatigue,

  /// Very high fatigue (TSB < -15) - Overtraining risk
  veryHighFatigue,
}

/// Extension on TrainingLoadStatus for convenience methods
extension TrainingLoadStatusExtension on TrainingLoadStatus {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case TrainingLoadStatus.veryFresh:
        return 'Very Fresh';
      case TrainingLoadStatus.optimal:
        return 'Optimal';
      case TrainingLoadStatus.normal:
        return 'Normal Load';
      case TrainingLoadStatus.moderateFatigue:
        return 'Moderate Fatigue';
      case TrainingLoadStatus.highFatigue:
        return 'High Fatigue';
      case TrainingLoadStatus.veryHighFatigue:
        return 'Very High Fatigue';
    }
  }

  /// Emoji representation
  String get emoji {
    switch (this) {
      case TrainingLoadStatus.veryFresh:
        return '🌟';
      case TrainingLoadStatus.optimal:
        return '✅';
      case TrainingLoadStatus.normal:
        return '💪';
      case TrainingLoadStatus.moderateFatigue:
        return '😐';
      case TrainingLoadStatus.highFatigue:
        return '⚠️';
      case TrainingLoadStatus.veryHighFatigue:
        return '🚨';
    }
  }

  /// Color for UI (semantic)
  String get colorName {
    switch (this) {
      case TrainingLoadStatus.veryFresh:
        return 'primary';
      case TrainingLoadStatus.optimal:
      case TrainingLoadStatus.normal:
        return 'success';
      case TrainingLoadStatus.moderateFatigue:
        return 'warning';
      case TrainingLoadStatus.highFatigue:
      case TrainingLoadStatus.veryHighFatigue:
        return 'error';
    }
  }

  /// Recommendation text
  String get recommendation {
    switch (this) {
      case TrainingLoadStatus.veryFresh:
        return 'Very low training load. Consider increasing volume to avoid detraining.';
      case TrainingLoadStatus.optimal:
        return 'Well-recovered! Excellent time for high-quality training.';
      case TrainingLoadStatus.normal:
        return 'Normal training load. Continue current programming.';
      case TrainingLoadStatus.moderateFatigue:
        return 'Moderate fatigue. Monitor recovery and consider light week if symptoms persist.';
      case TrainingLoadStatus.highFatigue:
        return 'High fatigue. Deload week recommended (50-60% volume reduction).';
      case TrainingLoadStatus.veryHighFatigue:
        return 'Very high fatigue. Take 3-5 days complete rest, then reassess.';
    }
  }
}
