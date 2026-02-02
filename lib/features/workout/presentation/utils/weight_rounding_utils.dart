/// Utility functions for smart weight rounding based on equipment type
///
/// This utility handles rounding logic for DropSet weight calculations:
/// - Barbell exercises: realistic loading with 20kg bar + standard plates (1.25-25kg)
/// - Dumbbell exercises: 2.5kg increments (17.5, 20, 22.5, 25kg...)
/// - Machine exercises: 5kg base increments (no 0.5kg)
library;

enum EquipmentType { barbell, dumbbell, machine, unknown }

enum DumbbellIncrement {
  standard, // 2.5kg increments (17.5, 20, 22.5, 25, 27.5...)
  halfKg, // 0.5kg increments (17.5, 18, 18.5, 19...)
  oneKg, // 1kg increments (17, 18, 19, 20...)
  twoKg, // 2kg increments (16, 18, 20, 22...)
}

class WeightRoundingUtils {
  /// Detect equipment type from exercise name or attrezzatura field
  static EquipmentType detectEquipmentType({
    required String exerciseName,
    String? attrezzaturaField,
  }) {
    final nameLower = exerciseName.toLowerCase();
    final attrezzaturaLower = attrezzaturaField?.toLowerCase() ?? '';

    // Check attrezzatura field first (more reliable)
    if (attrezzaturaLower.contains('bilanciere')) {
      return EquipmentType.barbell;
    }
    if (attrezzaturaLower.contains('manubri') ||
        attrezzaturaLower.contains('manubrio')) {
      return EquipmentType.dumbbell;
    }
    if (attrezzaturaLower.contains('macchina') ||
        attrezzaturaLower.contains('macchinario') ||
        attrezzaturaLower.contains('cavo') ||
        attrezzaturaLower.contains('cable')) {
      return EquipmentType.machine;
    }

    // Check exercise name for keywords
    // Barbell keywords
    if (nameLower.contains('barbell') ||
        nameLower.contains('bb ') ||
        nameLower.contains(' bb') ||
        nameLower.contains('bilanciere')) {
      return EquipmentType.barbell;
    }

    // Dumbbell keywords
    if (nameLower.contains('dumbbell') ||
        nameLower.contains('db ') ||
        nameLower.contains(' db') ||
        nameLower.contains('manubri') ||
        nameLower.contains('manubrio')) {
      return EquipmentType.dumbbell;
    }

    // Machine keywords
    if (nameLower.contains('machine') ||
        nameLower.contains('cable') ||
        nameLower.contains('macchina') ||
        nameLower.contains('cavo') ||
        nameLower.contains('smith') ||
        nameLower.contains('leg press') ||
        nameLower.contains('lat pulldown') ||
        nameLower.contains('chest press')) {
      return EquipmentType.machine;
    }

    return EquipmentType.unknown;
  }

  /// Round weight for barbell exercises with realistic plate loading
  ///
  /// Considers:
  /// - 20kg Olympic barbell
  /// - Standard plates: 25kg, 20kg, 15kg, 10kg, 5kg, 2.5kg, 1.25kg (per side)
  /// - Minimum increment: 2.5kg (2×1.25kg plates)
  /// - Valid weights: 20kg, 22.5kg, 25kg, 27.5kg, 30kg...
  static double roundForBarbell(double weight) {
    const double barWeight = 20.0;

    // Minimum is bar only
    if (weight <= barWeight) {
      return barWeight;
    }

    // Calculate weight to load on bar (total - bar weight)
    final weightToLoad = weight - barWeight;

    // Round to nearest 2.5kg increment (minimum plate combo: 2×1.25kg)
    final roundedLoad = (weightToLoad / 2.5).round() * 2.5;

    // Return bar + rounded load
    return barWeight + roundedLoad;
  }

  /// Round weight for dumbbell exercises based on gym equipment
  ///
  /// Standard gym dumbbells typically come in 2.5kg increments:
  /// 17.5kg, 20kg, 22.5kg, 25kg, 27.5kg, 30kg...
  static double roundForDumbbell(double weight, DumbbellIncrement increment) {
    switch (increment) {
      case DumbbellIncrement.standard:
        // Standard gym increments: 2.5kg (17.5, 20, 22.5, 25, 27.5...)
        return (weight / 2.5).round() * 2.5;
      case DumbbellIncrement.halfKg:
        // Round to nearest 0.5kg
        return (weight / 0.5).round() * 0.5;
      case DumbbellIncrement.oneKg:
        // Round to nearest 1kg
        return weight.round().toDouble();
      case DumbbellIncrement.twoKg:
        // Round to nearest 2kg
        return (weight / 2).round() * 2.0;
    }
  }

  /// Round weight for machine exercises
  ///
  /// Machines typically use:
  /// - 5kg base increments (weight stack)
  /// - No 0.5kg increments allowed
  /// - Valid weights: 5kg, 10kg, 15kg, 20kg, 25kg...
  static double roundForMachine(double weight) {
    // Round to nearest 5kg
    return (weight / 5).round() * 5.0;
  }

  /// Calculate weight after percentage drop
  static double calculateDroppedWeight({
    required double currentWeight,
    required int dropPercentage, // e.g., 10, 15, 20, 25, 30
  }) {
    final multiplier = (100 - dropPercentage) / 100;
    return currentWeight * multiplier;
  }

  /// Calculate and round weight for next drop set stage
  static double calculateNextStageWeight({
    required double currentWeight,
    required int dropPercentage,
    required EquipmentType equipmentType,
    DumbbellIncrement dumbbellIncrement = DumbbellIncrement.standard,
  }) {
    // Calculate raw dropped weight
    final droppedWeight = calculateDroppedWeight(
      currentWeight: currentWeight,
      dropPercentage: dropPercentage,
    );

    // Round based on equipment type
    switch (equipmentType) {
      case EquipmentType.barbell:
        return roundForBarbell(droppedWeight);
      case EquipmentType.dumbbell:
        return roundForDumbbell(droppedWeight, dumbbellIncrement);
      case EquipmentType.machine:
        return roundForMachine(droppedWeight);
      case EquipmentType.unknown:
        // Default to standard 2.5kg rounding for unknown
        return roundForDumbbell(droppedWeight, DumbbellIncrement.standard);
    }
  }

  /// Get user-friendly name for equipment type
  static String getEquipmentTypeName(EquipmentType type) {
    switch (type) {
      case EquipmentType.barbell:
        return 'Barbell';
      case EquipmentType.dumbbell:
        return 'Dumbbell';
      case EquipmentType.machine:
        return 'Machine';
      case EquipmentType.unknown:
        return 'Unknown';
    }
  }

  /// Get user-friendly name for dumbbell increment
  static String getDumbbellIncrementName(DumbbellIncrement increment) {
    switch (increment) {
      case DumbbellIncrement.standard:
        return '2.5kg increments (17.5, 20, 22.5, 25...)';
      case DumbbellIncrement.halfKg:
        return '0.5kg increments (17.5, 18, 18.5...)';
      case DumbbellIncrement.oneKg:
        return '1kg increments (17, 18, 19...)';
      case DumbbellIncrement.twoKg:
        return '2kg increments (16, 18, 20...)';
    }
  }

  /// Suggested drop percentages for UI
  static const List<int> standardDropPercentages = [10, 15, 20, 25, 30];
}
