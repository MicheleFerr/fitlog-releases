/// RPE/RIR-Based Autoregulation Service
///
/// Implements Protocol 2 from the research paper:
/// Adjusts training load based on Rate of Perceived Exertion (RPE)
/// or Repetitions in Reserve (RIR)
class RPEAutoregulationService {
  /// Calculate weight adjustment based on RPE
  ///
  /// Uses the scientifically validated Helms et al. (2018) formula:
  /// For every 0.5 RPE outside the target range, adjust load by 2%
  ///
  /// Example with target range 7-9 RPE:
  /// - RPE 6.0: +4% (1.0 below minimum)
  /// - RPE 6.5: +2% (0.5 below minimum)
  /// - RPE 7-9: No change (within range)
  /// - RPE 9.5: -2% (0.5 above maximum)
  /// - RPE 10: -4% (1.0 above maximum)
  ///
  /// Reference: Helms ER, et al. (2018). "Rating of Perceived Exertion as a Method
  /// of Volume Autoregulation Within a Periodized Program"
  static WeightAdjustment calculateRPEAdjustment({
    required double currentWeight,
    required double actualRPE,
    required double targetRPEMin,
    required double targetRPEMax,
  }) {
    double adjustmentPercent = 0;
    String reason = '';
    double deviation = 0;

    if (actualRPE < targetRPEMin) {
      // Below target range - increase weight
      deviation = targetRPEMin - actualRPE;
      // Formula: for every 0.5 RPE, adjust by 2%
      adjustmentPercent = (deviation / 0.5) * 2.0;

      if (deviation >= 2) {
        reason =
            'RPE significantly below target range (${deviation.toStringAsFixed(1)} points)';
      } else if (deviation >= 1) {
        reason =
            'RPE below target range (${deviation.toStringAsFixed(1)} points)';
      } else {
        reason =
            'RPE slightly below target (${deviation.toStringAsFixed(1)} points)';
      }
    } else if (actualRPE > targetRPEMax) {
      // Above target range - decrease weight
      deviation = actualRPE - targetRPEMax;
      // Formula: for every 0.5 RPE, adjust by 2%
      adjustmentPercent = -(deviation / 0.5) * 2.0;

      if (deviation >= 2) {
        reason =
            'RPE significantly above target range (${deviation.toStringAsFixed(1)} points)';
      } else if (deviation >= 1) {
        reason =
            'RPE above target range (${deviation.toStringAsFixed(1)} points)';
      } else {
        reason =
            'RPE slightly above target (${deviation.toStringAsFixed(1)} points)';
      }
    } else {
      // Within target range - maintain
      adjustmentPercent = 0;
      reason = 'RPE within target range ($targetRPEMin-$targetRPEMax)';
    }

    // Cap adjustment at reasonable limits (±20%)
    if (adjustmentPercent > 20) {
      adjustmentPercent = 20;
      reason += ' (capped at +20%)';
    } else if (adjustmentPercent < -20) {
      adjustmentPercent = -20;
      reason += ' (capped at -20%)';
    }

    final adjustedWeight = currentWeight * (1 + adjustmentPercent / 100);

    return WeightAdjustment(
      originalWeight: currentWeight,
      adjustedWeight: _roundWeight(adjustedWeight),
      adjustmentPercent: adjustmentPercent,
      reason: reason,
      actualRPE: actualRPE,
      targetRPERange: '$targetRPEMin-$targetRPEMax',
    );
  }

  /// Calculate weight adjustment based on RIR (Repetitions in Reserve)
  ///
  /// Uses a similar approach to RPE, adapted for RIR scale:
  /// Since RIR inversely correlates with RPE (lower RIR = higher effort),
  /// we apply the same 2% adjustment per 0.5 unit deviation principle
  ///
  /// Algorithm:
  /// - For each 1 RIR above target: decrease weight by 4% (too easy)
  /// - For each 1 RIR below target: increase weight by 4% (too hard)
  ///
  /// Example with target RIR = 2:
  /// - Actual RIR 4: -8% (2 RIR too easy)
  /// - Actual RIR 3: -4% (1 RIR too easy)
  /// - Actual RIR 2: No change (on target)
  /// - Actual RIR 1: +4% (1 RIR too hard)
  /// - Actual RIR 0: +8% (2 RIR too hard)
  static WeightAdjustment calculateRIRAdjustment({
    required double currentWeight,
    required int actualRIR,
    required int targetRIR,
  }) {
    final deviation = actualRIR - targetRIR;
    double adjustmentPercent = 0;
    String reason = '';

    if (deviation > 0) {
      // More reps in reserve than target (too easy) - increase weight
      adjustmentPercent = deviation * 4.0; // 4% per RIR

      if (deviation >= 3) {
        reason = 'Too many reps in reserve ($actualRIR vs target $targetRIR)';
      } else if (deviation >= 2) {
        reason = 'More reps in reserve than target ($actualRIR vs $targetRIR)';
      } else {
        reason = 'Slightly more RIR than target ($actualRIR vs $targetRIR)';
      }
    } else if (deviation < 0) {
      // Fewer reps in reserve than target (too hard) - decrease weight
      adjustmentPercent = deviation * 4.0; // -4% per RIR (negative)

      if (deviation <= -2) {
        reason = 'Too few reps in reserve ($actualRIR vs target $targetRIR)';
      } else {
        reason = 'Slightly fewer RIR than target ($actualRIR vs $targetRIR)';
      }
    } else {
      // Perfect match
      adjustmentPercent = 0;
      reason = 'RIR matches target ($targetRIR)';
    }

    // Cap adjustment at reasonable limits (±20%)
    if (adjustmentPercent > 20) {
      adjustmentPercent = 20;
      reason += ' (capped at +20%)';
    } else if (adjustmentPercent < -20) {
      adjustmentPercent = -20;
      reason += ' (capped at -20%)';
    }

    final adjustedWeight = currentWeight * (1 + adjustmentPercent / 100);

    return WeightAdjustment(
      originalWeight: currentWeight,
      adjustedWeight: _roundWeight(adjustedWeight),
      adjustmentPercent: adjustmentPercent,
      reason: reason,
      actualRIR: actualRIR,
      targetRIR: targetRIR,
    );
  }

  /// Convert RPE to RIR (approximate)
  /// RPE 10 = RIR 0
  /// RPE 9 = RIR 1
  /// RPE 8 = RIR 2
  /// RPE 7 = RIR 3
  /// RPE 6 = RIR 4+
  static int rpeToRIR(double rpe) {
    if (rpe >= 10) return 0;
    if (rpe >= 9) return 1;
    if (rpe >= 8) return 2;
    if (rpe >= 7) return 3;
    if (rpe >= 6) return 4;
    return 5; // RPE < 6 means 5+ RIR
  }

  /// Convert RIR to RPE (approximate)
  static double rirToRPE(int rir) {
    switch (rir) {
      case 0:
        return 10.0;
      case 1:
        return 9.0;
      case 2:
        return 8.0;
      case 3:
        return 7.0;
      case 4:
        return 6.0;
      default:
        return 5.0; // 5+ RIR
    }
  }

  /// Round weight to nearest 2.5kg increment
  static double _roundWeight(double weight) {
    return (weight / 2.5).round() * 2.5;
  }

  /// 🔄 Calculate rest time adjustment based on RPE
  ///
  /// Conservative approach: small adjustments to avoid disrupting workout flow.
  /// Based on general principles that higher exertion may benefit from
  /// slightly longer recovery, while easy sets can use shorter rest.
  ///
  /// Algorithm (conservative values):
  /// - RPE 10: +30s (failure/max effort)
  /// - RPE 9-9.5: +15s (very hard)
  /// - RPE 7-8.5: 0s (moderate to hard - optimal training zone)
  /// - RPE 5-7: -15s (easy to moderate)
  /// - RPE < 5: -30s (very easy)
  ///
  /// Returns adjustment in seconds (positive = more rest, negative = less rest)
  static RestTimeAdjustment calculateRestTimeAdjustment({
    required int baseRestSeconds,
    required double actualRPE,
  }) {
    int adjustmentSeconds = 0;
    String reason = '';

    if (actualRPE >= 10) {
      // Failure/max effort - moderate extra rest
      adjustmentSeconds = 30;
      reason = 'RPE max ($actualRPE) - adding 30s for recovery';
    } else if (actualRPE >= 9) {
      // Very hard - slight extra rest
      adjustmentSeconds = 15;
      reason = 'RPE very hard ($actualRPE) - adding 15s for recovery';
    } else if (actualRPE >= 7) {
      // Moderate to hard - standard rest (optimal training zone)
      adjustmentSeconds = 0;
      reason = 'RPE moderate ($actualRPE) - using standard rest time';
    } else if (actualRPE >= 5) {
      // Easy to moderate - slightly reduced rest
      adjustmentSeconds = -15;
      reason = 'RPE low ($actualRPE) - reducing rest by 15s';
    } else {
      // Very easy - can reduce rest more
      adjustmentSeconds = -30;
      reason = 'RPE very low ($actualRPE) - reducing rest by 30s';
    }

    // Ensure minimum rest of 30 seconds
    final adjustedRest = (baseRestSeconds + adjustmentSeconds).clamp(30, 600);

    // Recalculate actual adjustment (may be capped)
    final actualAdjustment = adjustedRest - baseRestSeconds;

    return RestTimeAdjustment(
      baseRestSeconds: baseRestSeconds,
      adjustedRestSeconds: adjustedRest,
      adjustmentSeconds: actualAdjustment,
      reason: reason,
      actualRPE: actualRPE,
    );
  }
}

/// Rest time adjustment result
class RestTimeAdjustment {
  const RestTimeAdjustment({
    required this.baseRestSeconds,
    required this.adjustedRestSeconds,
    required this.adjustmentSeconds,
    required this.reason,
    required this.actualRPE,
  });

  final int baseRestSeconds;
  final int adjustedRestSeconds;
  final int adjustmentSeconds;
  final String reason;
  final double actualRPE;

  bool get hasAdjustment => adjustmentSeconds != 0;
  bool get needsMoreRest => adjustmentSeconds > 0;
  bool get needsLessRest => adjustmentSeconds < 0;
}

/// Weight adjustment result
class WeightAdjustment {
  const WeightAdjustment({
    required this.originalWeight,
    required this.adjustedWeight,
    required this.adjustmentPercent,
    required this.reason,
    this.actualRPE,
    this.targetRPERange,
    this.actualRIR,
    this.targetRIR,
  });
  final double originalWeight;
  final double adjustedWeight;
  final double adjustmentPercent;
  final String reason;
  final double? actualRPE;
  final String? targetRPERange;
  final int? actualRIR;
  final int? targetRIR;

  bool get shouldIncrease => adjustmentPercent > 0;
  bool get shouldDecrease => adjustmentPercent < 0;
  bool get shouldMaintain => adjustmentPercent == 0;
}
