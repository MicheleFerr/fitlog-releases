/// Stress Index Constants (RTS-based)
///
/// Based on:
/// - Helms et al. (2018): RPE-Based Training Load Monitoring
/// - Zourdos et al. (2016): Novel Resistance Training-Specific RPE Scale
/// - WHOOP Recovery Algorithm patterns
library;

/// Constants for Stress Index calculation
class StressIndexConstants {
  StressIndexConstants._();

  // === RPE TO INTENSITY CONVERSION ===
  // Based on Helms et al. (2018) and Zourdos et al. (2016)
  static const Map<int, double> rpeToIntensity = {
    5: 0.50, // Very Easy
    6: 0.60, // Easy
    7: 0.70, // Moderate
    8: 0.80, // Hard
    9: 0.90, // Very Hard
    10: 1.00, // Maximum
  };

  /// Default intensity when RPE is not available
  static const double defaultIntensity = 0.70;

  // === LOGARITHMIC SCALE PARAMETERS ===
  // For converting raw score to 0-100 logarithmic scale (like WHOOP)
  static const double logScaleBase = 10.0;
  static const double logScaleMax = 100.0;

  /// Raw score that maps to ~100 on logarithmic scale
  /// Based on typical heavy workout: 4 exercises × 4 sets × 100kg × 10 reps × 0.8 intensity
  static const double rawScoreForMax100 = 15000.0;

  // === RECOVERY TIME (hours) BY MUSCLE GROUP ===
  // Based on research and practical experience
  static const Map<String, int> muscleRecoveryHours = {
    'QUAD': 72, // Large muscle, compound movements
    'GLUT': 72, // Large muscle, compound movements
    'FEMOR': 72, // Hamstrings
    'LAT': 72, // Large back muscles
    'PETT': 72, // Chest
    // Deltoid portions (P0 fix: split DELT into ANT/LAT/POST)
    'DELT_ANT': 48, // Anterior deltoid (front raises, pressing)
    'DELT_LAT': 48, // Lateral deltoid (lateral raises)
    'DELT_POST': 48, // Posterior deltoid (rear delt work)
    'DELT': 48, // Generic shoulders (backward compatibility)
    'TRAP': 48, // Trapezius
    'BICI': 48, // Biceps
    'TRIC': 48, // Triceps
    'CORE': 48, // Core/Abs
    'AVA': 48, // Forearms
    'POLP': 48, // Calves
    'ADD': 48, // Adductors
    'ABDU': 48, // Abductors
    'LOMBAR': 72, // Lower back
    'COLLO': 24, // Neck (smaller muscle, faster recovery)
  };

  /// Default recovery hours for unknown muscle groups
  static const int defaultRecoveryHours = 48;

  // === CONFIDENCE THRESHOLDS ===
  /// High confidence: 80%+ sets have RPE data
  static const double highConfidenceThreshold = 0.80;

  /// Medium confidence: 50-80% sets have RPE data
  static const double mediumConfidenceThreshold = 0.50;

  // Below 50% = low confidence, show fallback prominently

  // === STRESS LEVEL THRESHOLDS ===
  /// Light session: 0-30
  static const double lightSessionMax = 30.0;

  /// Moderate session: 30-60
  static const double moderateSessionMax = 60.0;

  /// Hard session: 60-80
  static const double hardSessionMax = 80.0;

  // Very hard session: 80-100

  // === MUSCLE STRESS DISTRIBUTION WEIGHTS ===
  /// Weight for primary muscles (focus) - receives most stress
  static const double primaryMuscleWeight = 0.70;

  /// Weight for secondary muscles - receives less stress
  static const double secondaryMuscleWeight = 0.30;

  // === RECOVERY STATE THRESHOLDS (percentage) ===
  /// Fully recovered: 100%
  static const double fullyRecoveredMin = 100.0;

  /// Almost ready: 75-99%
  static const double almostReadyMin = 75.0;

  /// Recovering: 50-74%
  static const double recoveringMin = 50.0;

  /// Fatigued: 25-49%
  static const double fatiguedMin = 25.0;

  // Exhausted: 0-24%

  // === FITNESS-FATIGUE MODEL (FFM) CONSTANTS ===
  // Based on Banister et al. (1975) and Morton et al. (1990)
  //
  // Formula: Performance(t) = p* + Fitness(t) - Fatigue(t)
  // Where:
  //   Fitness(t) = k₁ × ∑(wᵢ × e^(-(t-tᵢ)/τ₁))
  //   Fatigue(t) = k₂ × ∑(wᵢ × e^(-(t-tᵢ)/τ₂))

  /// Baseline performance level (100% = fully recovered)
  static const double ffmBaseline = 100.0;

  /// Fitness time constant τ₁ (hours)
  /// Research suggests 30-50 days; using 42 days = 1008 hours
  /// Fitness builds slowly and decays slowly
  static const double fitnessTimeConstant = 1008.0; // 42 days in hours

  /// Fatigue time constant τ₂ (hours)
  /// Research suggests 7-15 days; using 10 days = 240 hours
  /// Fatigue builds quickly and decays relatively quickly
  static const double fatigueTimeConstant = 240.0; // 10 days in hours

  /// Fitness gain multiplier k₁
  /// How much each unit of training contributes to fitness
  /// Typical range: 0.8-1.5 (we start conservative)
  static const double fitnessGainK1 = 1.0;

  /// Fatigue gain multiplier k₂
  /// How much each unit of training contributes to fatigue
  /// k₂ > k₁ means initial dip in performance after training
  /// Typical range: 1.5-3.5
  /// NOTE: Increased from 2.0 to 3.5 to make workouts have more visible impact
  static const double fatigueGainK2 = 3.5;

  /// Muscle-specific τ₂ modifiers (fatigue decay)
  /// Large muscles fatigue longer, small muscles recover faster
  static const Map<String, double> muscleFatigueModifiers = {
    'QUAD': 1.2, // Large muscle, slower fatigue decay
    'GLUT': 1.2,
    'FEMOR': 1.1,
    'LAT': 1.1,
    'PETT': 1.0, // Reference
    'DELT_ANT': 0.9,
    'DELT_LAT': 0.9,
    'DELT_POST': 0.9,
    'DELT': 0.9, // Backward compatibility
    'TRAP': 0.9,
    'BICI': 0.8, // Small muscle, faster fatigue decay
    'TRIC': 0.8,
    'CORE': 0.7, // Core recovers relatively fast
    'AVA': 0.7,
    'POLP': 0.8,
    'ADD': 0.9,
    'ABDU': 0.9,
    'LOMBAR': 1.1, // Lower back is resilient but needs time
    'COLLO': 0.6, // Neck recovers quickly
  };

  /// Default fatigue modifier for unknown muscles
  static const double defaultFatigueModifier = 1.0;

  // === FFM PERFORMANCE THRESHOLDS ===

  /// Supercompensation threshold (above baseline)
  /// Performance peaks 1-3 days after fatigue dissipates
  static const double supercompensationThreshold = 102.0;

  /// Optimal training window lower bound
  /// Best time to train again for progressive overload
  static const double optimalTrainingMin = 95.0;

  /// Acceptable training threshold
  /// Below this, training is suboptimal but not harmful
  static const double acceptableTrainingMin = 85.0;

  /// Overtraining warning threshold
  /// Below this, risk of overtraining and injury increases
  static const double overtrainingWarning = 70.0;

  /// Critical fatigue threshold
  /// Below this, strongly recommend rest
  static const double criticalFatigue = 50.0;

  // === SLEEP IMPACT MODIFIERS ===
  // Based on:
  // - Res et al.: -22% Muscle Protein Synthesis with sleep deprivation
  // - Knowles et al.: Reduced strength output with <6h sleep
  // - AASM: 7-9h recommended for adults
  // - Skein et al. 2011: Cumulative decline with consecutive sleep restriction

  /// Sleep modifier for critical sleep (<6h)
  /// Research shows significant performance impact
  static const double sleepModifierCritical = 0.70; // -30% performance

  /// Sleep modifier for suboptimal sleep (6-7h)
  /// Moderate impact on recovery
  static const double sleepModifierSuboptimal = 0.85; // -15% performance

  /// Sleep modifier for optimal sleep (7-9h)
  /// No negative impact
  static const double sleepModifierOptimal = 1.0;

  /// Sleep modifier for excessive sleep (>9h)
  /// May indicate overtraining or illness
  static const double sleepModifierExcessive = 0.95; // -5%

  /// Sleep thresholds (hours)
  static const double sleepCriticalThreshold = 6.0;
  static const double sleepSuboptimalThreshold = 7.0;
  static const double sleepExcessiveThreshold = 9.0;

  /// Consecutive bad nights penalty
  /// 2 consecutive nights <6h
  static const double consecutiveBadNights2Penalty = 0.95; // -5%

  /// 3+ consecutive nights <6h
  static const double consecutiveBadNights3Penalty = 0.90; // -10%

  /// Default sleep hours when no data available
  /// Assumes user slept normally
  static const double defaultSleepHours = 7.5;
}
