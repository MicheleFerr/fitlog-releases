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
    'DELT': 48, // Shoulders
    'TRAP': 48, // Trapezius
    'BICI': 48, // Biceps
    'TRIC': 48, // Triceps
    'CORE': 48, // Core/Abs
    'AVA': 48, // Forearms
    'POLP': 48, // Calves
    'ADD': 48, // Adductors
    'ADDO': 48, // Adductors (alternative)
    'LOMBAR': 72, // Lower back
    'BIC': 48, // Biceps (typo variant)
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
}
