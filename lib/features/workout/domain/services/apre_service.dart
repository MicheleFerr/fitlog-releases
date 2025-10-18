/// APRE (Autoregulatory Progressive Resistance Exercise) Service
/// Based on Dr. Bryan Mann's research
///
/// Provides automatic load adjustments based on performance
library;

class APREService {
  /// APRE adjustment for a specific rep range
  static APREAdjustment? getAdjustment(int protocol, int repsCompleted) {
    switch (protocol) {
      case 3:
        return _getAPRE3Adjustment(repsCompleted);
      case 6:
        return _getAPRE6Adjustment(repsCompleted);
      case 10:
        return _getAPRE10Adjustment(repsCompleted);
      default:
        return null;
    }
  }

  /// APRE-3 Protocol (Max Strength - 92% 1RM)
  static APREAdjustment? _getAPRE3Adjustment(int reps) {
    if (reps <= 1) {
      return const APREAdjustment(
        set4Adjustment: -10.0,
        nextSessionAdjustment: -10.0,
        description: 'Too heavy - decrease significantly',
        repsRange: '0-1',
      );
    } else if (reps <= 3) {
      return const APREAdjustment(
        set4Adjustment: 0.0,
        nextSessionAdjustment: 0.0,
        description: 'Perfect weight - maintain',
        repsRange: '2-3',
      );
    } else if (reps <= 5) {
      return const APREAdjustment(
        set4Adjustment: 5.0,
        nextSessionAdjustment: 5.0,
        description: 'Good strength - increase moderately',
        repsRange: '4-5',
      );
    } else {
      return const APREAdjustment(
        set4Adjustment: 10.0,
        nextSessionAdjustment: 10.0,
        description: 'Too easy - increase significantly',
        repsRange: '6+',
      );
    }
  }

  /// APRE-6 Protocol (Strength-Hypertrophy - 83% 1RM)
  static APREAdjustment? _getAPRE6Adjustment(int reps) {
    if (reps <= 2) {
      return const APREAdjustment(
        set4Adjustment: -10.0,
        nextSessionAdjustment: -10.0,
        description: 'Too heavy - decrease significantly',
        repsRange: '0-2',
      );
    } else if (reps <= 4) {
      return const APREAdjustment(
        set4Adjustment: -5.0,
        nextSessionAdjustment: -5.0,
        description: 'Slightly heavy - decrease slightly',
        repsRange: '3-4',
      );
    } else if (reps <= 7) {
      return const APREAdjustment(
        set4Adjustment: 0.0,
        nextSessionAdjustment: 0.0,
        description: 'Perfect weight - maintain',
        repsRange: '5-7',
      );
    } else if (reps <= 12) {
      return const APREAdjustment(
        set4Adjustment: 5.0,
        nextSessionAdjustment: 5.0,
        description: 'Good strength - increase moderately',
        repsRange: '8-12',
      );
    } else {
      return const APREAdjustment(
        set4Adjustment: 10.0,
        nextSessionAdjustment: 10.0,
        description: 'Too easy - increase significantly',
        repsRange: '13+',
      );
    }
  }

  /// APRE-10 Protocol (Hypertrophy-Endurance - 75% 1RM)
  static APREAdjustment? _getAPRE10Adjustment(int reps) {
    if (reps <= 7) {
      return const APREAdjustment(
        set4Adjustment: -10.0,
        nextSessionAdjustment: -10.0,
        description: 'Too heavy - decrease significantly',
        repsRange: '0-7',
      );
    } else if (reps <= 12) {
      return const APREAdjustment(
        set4Adjustment: 0.0,
        nextSessionAdjustment: 0.0,
        description: 'Perfect weight - maintain',
        repsRange: '8-12',
      );
    } else if (reps <= 17) {
      return const APREAdjustment(
        set4Adjustment: 5.0,
        nextSessionAdjustment: 5.0,
        description: 'Good endurance - increase moderately',
        repsRange: '13-17',
      );
    } else {
      return const APREAdjustment(
        set4Adjustment: 10.0,
        nextSessionAdjustment: 10.0,
        description: 'Too easy - increase significantly',
        repsRange: '18+',
      );
    }
  }

  /// Calculate the next weight based on APRE protocol
  static double calculateNextWeight(
    double currentWeight,
    int repsCompleted,
    int protocol, {
    bool isForSet4 = true,
    bool useKilograms = true,
  }) {
    final adjustment = getAdjustment(protocol, repsCompleted);
    if (adjustment == null) return currentWeight;

    final weightChange = isForSet4
        ? adjustment.set4Adjustment
        : adjustment.nextSessionAdjustment;

    // Convert lbs to kg if needed (APRE originally uses lbs)
    final actualChange = useKilograms ? weightChange * 0.453592 : weightChange;

    // Round to nearest 2.5kg or 5lbs
    final newWeight = currentWeight + actualChange;
    if (useKilograms) {
      return (newWeight / 2.5).round() * 2.5;
    } else {
      return (newWeight / 5).round() * 5.0;
    }
  }

  /// Get APRE protocol description
  static String getProtocolDescription(int protocol) {
    switch (protocol) {
      case 3:
        return 'APRE-3: Maximum Strength (3RM @ 92%)';
      case 6:
        return 'APRE-6: Strength-Hypertrophy (6RM @ 83%)';
      case 10:
        return 'APRE-10: Hypertrophy-Endurance (10RM @ 75%)';
      default:
        return 'Unknown protocol';
    }
  }

  /// Get the recommended set structure for APRE
  static List<APRESetTemplate> getAPRESetStructure(
    int protocol,
    double baseWeight,
  ) {
    return [
      APRESetTemplate(
        setNumber: 1,
        percentage: 50,
        weight: baseWeight * 0.5,
        targetReps: 10,
        description: 'Warm-up',
      ),
      APRESetTemplate(
        setNumber: 2,
        percentage: 75,
        weight: baseWeight * 0.75,
        targetReps: protocol,
        description: 'Preparation',
      ),
      APRESetTemplate(
        setNumber: 3,
        percentage: 100,
        weight: baseWeight,
        targetReps: null, // MAX reps
        description: 'Max effort - do as many as possible',
      ),
      const APRESetTemplate(
        setNumber: 4,
        percentage: null, // Adjusted based on set 3
        weight: null, // Will be calculated
        targetReps: null, // MAX reps
        description: 'Adjusted weight - max effort',
      ),
    ];
  }

  /// Check if this is an APRE key set (Set 3 or 4)
  static bool isAPREKeySet(int setNumber) {
    return setNumber == 3 || setNumber == 4;
  }

  /// Get human-readable adjustment reason
  static String getAdjustmentReason(int protocol, int targetReps, int actualReps) {
    final difference = actualReps - targetReps;

    if (difference >= 3) {
      return 'You completed $difference more reps than target - you\'re stronger than expected!';
    } else if (difference >= 1) {
      return 'Good performance - slightly above target';
    } else if (difference == 0) {
      return 'Perfect execution at target reps';
    } else if (difference >= -2) {
      return 'Slightly below target - minor adjustment needed';
    } else {
      return 'Significantly below target - weight too heavy';
    }
  }
}

/// APRE Adjustment data
class APREAdjustment {             // Rep range for this adjustment

  const APREAdjustment({
    required this.set4Adjustment,
    required this.nextSessionAdjustment,
    required this.description,
    required this.repsRange,
  });
  final double set4Adjustment;        // Weight change for set 4 (in lbs)
  final double nextSessionAdjustment; // Weight change for next session
  final String description;           // Human-readable description
  final String repsRange;

  /// Convert adjustment to kilograms
  double get set4AdjustmentKg => set4Adjustment * 0.453592;
  double get nextSessionAdjustmentKg => nextSessionAdjustment * 0.453592;
}

/// Template for an APRE set
class APRESetTemplate {

  const APRESetTemplate({
    required this.setNumber,
    this.percentage,
    this.weight,
    this.targetReps,
    required this.description,
  });
  final int setNumber;
  final int? percentage;      // Percentage of base weight
  final double? weight;        // Calculated weight
  final int? targetReps;       // Target reps (null = max)
  final String description;
}