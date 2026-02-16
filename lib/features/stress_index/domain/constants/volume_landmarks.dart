/// Volume Landmarks Constants
///
/// Defines MEV/MAV/MRV thresholds for each muscle group
/// based on RP Strength research (Mike Israetel et al.)
///
/// **Definitions**:
/// - MV (Maintenance Volume): Weekly sets needed to maintain muscle mass
/// - MEV (Minimum Effective Volume): Minimum sets for growth
/// - MAV (Maximum Adaptive Volume): Optimal range for hypertrophy
/// - MRV (Maximum Recoverable Volume): Maximum before overtraining
///
/// **Source**: Israetel et al., Renaissance Periodization
library;

/// Volume landmarks for a single muscle group (weekly set counts)
class VolumeLandmarks {
  const VolumeLandmarks({
    required this.mv,
    required this.mev,
    required this.mavLow,
    required this.mavHigh,
    required this.mrv,
  });

  /// Maintenance Volume - sets to maintain current muscle mass
  final int mv;

  /// Minimum Effective Volume - minimum sets for growth
  final int mev;

  /// Maximum Adaptive Volume (low end) - start of optimal range
  final int mavLow;

  /// Maximum Adaptive Volume (high end) - end of optimal range
  final int mavHigh;

  /// Maximum Recoverable Volume - beyond this risks overtraining
  final int mrv;
}

/// Volume landmarks map by muscle group (using standard abbreviations)
///
/// **Keys**: Muscle abbreviations (PETT, LAT, QUAD, etc.)
/// **Values**: VolumeLandmarks with MEV/MAV/MRV thresholds
///
/// **Note**: Based on RP Strength research for intermediate lifters
const volumeLandmarks = <String, VolumeLandmarks>{
  // Upper Body - Push
  'PETT': VolumeLandmarks(mv: 6, mev: 10, mavLow: 14, mavHigh: 20, mrv: 22),

  // Upper Body - Pull
  'LAT': VolumeLandmarks(mv: 6, mev: 12, mavLow: 16, mavHigh: 24, mrv: 28),
  'DORS': VolumeLandmarks(mv: 6, mev: 12, mavLow: 16, mavHigh: 24, mrv: 28),

  // Shoulders
  'DELT': VolumeLandmarks(mv: 4, mev: 10, mavLow: 14, mavHigh: 20, mrv: 22),
  'DELT_ANT':
      VolumeLandmarks(mv: 4, mev: 10, mavLow: 14, mavHigh: 20, mrv: 22),
  'DELT_LAT':
      VolumeLandmarks(mv: 4, mev: 10, mavLow: 14, mavHigh: 20, mrv: 22),
  'DELT_POST':
      VolumeLandmarks(mv: 4, mev: 10, mavLow: 14, mavHigh: 20, mrv: 22),
  'TRAP': VolumeLandmarks(mv: 4, mev: 8, mavLow: 12, mavHigh: 18, mrv: 22),

  // Arms
  'BICI': VolumeLandmarks(mv: 4, mev: 8, mavLow: 12, mavHigh: 18, mrv: 22),
  'TRIC': VolumeLandmarks(mv: 4, mev: 8, mavLow: 12, mavHigh: 18, mrv: 22),
  'AVA': VolumeLandmarks(mv: 2, mev: 4, mavLow: 8, mavHigh: 14, mrv: 18),

  // Lower Body - Quads & Glutes
  'QUAD': VolumeLandmarks(mv: 6, mev: 10, mavLow: 14, mavHigh: 20, mrv: 24),
  'GLUT': VolumeLandmarks(mv: 4, mev: 8, mavLow: 12, mavHigh: 18, mrv: 22),

  // Lower Body - Posterior Chain
  'FEMO': VolumeLandmarks(mv: 4, mev: 8, mavLow: 12, mavHigh: 18, mrv: 22),
  'POLP': VolumeLandmarks(mv: 4, mev: 10, mavLow: 14, mavHigh: 18, mrv: 20),

  // Core & Lower Back
  'CORE': VolumeLandmarks(mv: 0, mev: 0, mavLow: 6, mavHigh: 12, mrv: 16),
  'OBL': VolumeLandmarks(mv: 0, mev: 0, mavLow: 6, mavHigh: 12, mrv: 16),
  'LOMB': VolumeLandmarks(mv: 4, mev: 6, mavLow: 10, mavHigh: 14, mrv: 18),

  // Secondary Muscles
  'ROMB': VolumeLandmarks(mv: 4, mev: 8, mavLow: 12, mavHigh: 18, mrv: 22),
  'ADD': VolumeLandmarks(mv: 2, mev: 4, mavLow: 8, mavHigh: 14, mrv: 18),
  'ABDU': VolumeLandmarks(mv: 2, mev: 4, mavLow: 8, mavHigh: 14, mrv: 18),
  'COLL': VolumeLandmarks(mv: 0, mev: 2, mavLow: 4, mavHigh: 8, mrv: 12),
};

/// Default volume landmarks for unknown muscle groups
const defaultVolumeLandmarks =
    VolumeLandmarks(mv: 4, mev: 8, mavLow: 12, mavHigh: 18, mrv: 22);
