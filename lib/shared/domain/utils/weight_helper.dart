/// Helper class for weight-related utility functions
/// Supports both kg and lbs unit systems
class WeightHelper {
  WeightHelper._(); // Private constructor to prevent instantiation

  /// Get quick jump values based on current weight and unit
  /// Returns dynamic buttons that change based on weight value
  ///
  /// **For kg:**
  /// - At 0 kg: [+10, +20, +50, +100]
  /// - 0-10 kg: [-10, +20, +50, +100]
  /// - 10-20 kg: [-10, +20, +50, +100]
  /// - >20 kg: [-20, -10, +10, +20]
  ///
  /// **For lbs:**
  /// - At 0 lbs: [+5, +10, +25, +50]
  /// - 0-25 lbs: [-5, +10, +25, +50]
  /// - 25-50 lbs: [-10, +10, +25, +50]
  /// - >50 lbs: [-25, -10, +10, +25]
  static List<int> getQuickJumps(double weight, String unit) {
    if (unit == 'lbs') {
      // Pounds quick jumps
      if (weight == 0) {
        return [5, 10, 25, 50];
      } else if (weight <= 25) {
        return [-5, 10, 25, 50];
      } else if (weight <= 50) {
        return [-10, 10, 25, 50];
      } else {
        return [-25, -10, 10, 25];
      }
    } else {
      // Kilograms quick jumps
      if (weight == 0) {
        return [10, 20, 50, 100];
      } else if (weight <= 10) {
        return [-10, 20, 50, 100];
      } else if (weight <= 20) {
        return [-10, 20, 50, 100];
      } else {
        return [-20, -10, 10, 20];
      }
    }
  }

  /// Apply quick jump to current weight with bounds checking
  /// Ensures weight stays between 0 and max weight for the unit
  static double applyQuickJump({
    required double currentWeight,
    required int jump,
    required String unit,
  }) {
    final maxWeight = unit == 'lbs' ? 440.0 : 200.0;
    final newWeight = currentWeight + jump;
    return newWeight.clamp(0.0, maxWeight);
  }

  /// Convert weight index to actual weight value
  /// - kg: index / 4.0 (0.25 increments)
  /// - lbs: index / 2.0 (0.5 increments)
  static double indexToWeight(int index, String unit) {
    final divisor = unit == 'lbs' ? 2.0 : 4.0;
    return index / divisor;
  }

  /// Convert weight value to picker index
  /// - kg: weight * 4 (0.25 increments)
  /// - lbs: weight * 2 (0.5 increments)
  static int weightToIndex(double weight, String unit) {
    final multiplier = unit == 'lbs' ? 2.0 : 4.0;
    return (weight * multiplier).toInt();
  }

  /// Format weight for display in picker
  /// Shows integer if whole number, otherwise shows decimals
  static String formatPickerWeight(double weight, String unit) {
    if (weight == 0) {
      return '0';
    } else if (weight % 1 == 0) {
      return weight.toInt().toString();
    } else {
      // kg: 2 decimals, lbs: 1 decimal
      final decimals = unit == 'kg' ? 2 : 1;
      return weight.toStringAsFixed(decimals);
    }
  }

  /// Get standard plate weights for plate calculator
  /// Returns list of common weight plates/dumbbells
  static List<double> getStandardWeights(String unit) {
    if (unit == 'lbs') {
      // Common US weight plates and dumbbells (in lbs)
      return [
        0,
        5,
        10,
        15,
        20,
        25,
        30,
        35,
        40,
        45,
        50,
        55,
        60,
        65,
        70,
        75,
        80,
        85,
        90,
        100,
        115,
        135,
        155,
        185,
        205,
        225
      ];
    } else {
      // Common metric weight plates and dumbbells (in kg)
      return [
        0,
        2.5,
        5,
        7.5,
        10,
        12.5,
        15,
        17.5,
        20,
        22.5,
        25,
        30,
        35,
        40,
        45,
        50,
        60,
        70,
        80,
        90,
        100
      ];
    }
  }

  /// Convert kg to lbs
  static double kgToLbs(double kg) => kg * 2.20462;

  /// Convert lbs to kg
  static double lbsToKg(double lbs) => lbs / 2.20462;
}
