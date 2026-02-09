/// Represents a weight calculation result
class PlateCalculation {
  const PlateCalculation({
    required this.totalWeight,
    required this.barbellWeight,
    required this.platesPerSide,
    required this.isExact,
  });

  /// Total weight achieved (barbell + plates)
  final double totalWeight;

  /// Weight of the barbell
  final double? barbellWeight;

  /// Map of plate weight to count per side
  final Map<double, int> platesPerSide;

  /// Whether the exact target weight was achieved
  final bool isExact;

  /// Calculate the weight difference from a target
  double differenceFrom(double target) => totalWeight - target;

  /// Get a formatted string of plates per side
  String get platesDescription {
    if (platesPerSide.isEmpty) {
      return barbellWeight != null ? 'Only barbell' : 'No plates';
    }

    final parts = <String>[];
    platesPerSide.forEach((weight, count) {
      parts.add('${count}x${weight}kg');
    });
    return parts.join(' + ');
  }
}

/// Service for calculating plate distributions and alternatives
class PlateCalculatorService {
  /// Calculate the optimal plate distribution for a target weight
  ///
  /// [targetWeight] - The total weight to achieve
  /// [barbellWeight] - Weight of the barbell (null for no barbell)
  /// [availablePlates] - List of available plate weights (sorted descending)
  /// [excludedPlates] - Plates to exclude from calculation
  static PlateCalculation calculatePlates({
    required double targetWeight,
    required double? barbellWeight,
    required List<double> availablePlates,
    Set<double> excludedPlates = const {},
  }) {
    final platesPerSide = <double, int>{};

    if (targetWeight <= 0) {
      return PlateCalculation(
        totalWeight: 0,
        barbellWeight: barbellWeight,
        platesPerSide: platesPerSide,
        isExact: true,
      );
    }

    // Start with barbell weight
    double remainingWeight = targetWeight;
    if (barbellWeight != null && barbellWeight > 0) {
      remainingWeight -= barbellWeight;
    }

    if (remainingWeight <= 0) {
      return PlateCalculation(
        totalWeight: barbellWeight ?? 0,
        barbellWeight: barbellWeight,
        platesPerSide: platesPerSide,
        isExact: remainingWeight == 0,
      );
    }

    // Weight per side (plates are mirrored)
    double weightPerSide = remainingWeight / 2;

    // Filter out excluded plates
    final activePlates = availablePlates
        .where((p) => !excludedPlates.contains(p))
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    if (activePlates.isEmpty) {
      return PlateCalculation(
        totalWeight: barbellWeight ?? 0,
        barbellWeight: barbellWeight,
        platesPerSide: platesPerSide,
        isExact: false,
      );
    }

    // Greedy algorithm
    double usedWeight = 0;
    for (final plate in activePlates) {
      final count = (weightPerSide / plate).floor();
      if (count > 0) {
        platesPerSide[plate] = count;
        usedWeight += count * plate;
        weightPerSide -= count * plate;
      }
    }

    // Calculate actual achieved weight
    final achievedWeight = (barbellWeight ?? 0) + (usedWeight * 2);
    final isExact = (achievedWeight - targetWeight).abs() < 0.01;

    return PlateCalculation(
      totalWeight: achievedWeight,
      barbellWeight: barbellWeight,
      platesPerSide: platesPerSide,
      isExact: isExact,
    );
  }

  /// Find alternative weights when exact target cannot be achieved
  ///
  /// Returns up to [maxAlternatives] alternatives, sorted by closeness to target
  static List<PlateCalculation> findAlternatives({
    required double targetWeight,
    required double? barbellWeight,
    required List<double> availablePlates,
    Set<double> excludedPlates = const {},
    int maxAlternatives = 3,
    double searchRange = 10.0, // ±10kg
  }) {
    // First, try exact calculation
    final exact = calculatePlates(
      targetWeight: targetWeight,
      barbellWeight: barbellWeight,
      availablePlates: availablePlates,
      excludedPlates: excludedPlates,
    );

    if (exact.isExact) {
      return [exact];
    }

    // Find alternatives within range
    final alternatives = <PlateCalculation>[];
    final seenWeights = <double>{};

    // Filter active plates
    final activePlates = availablePlates
        .where((p) => !excludedPlates.contains(p))
        .toList();

    if (activePlates.isEmpty) {
      return [];
    }

    // Smallest plate determines step
    final smallestPlate = activePlates
        .reduce((a, b) => a < b ? a : b);
    final step = smallestPlate;

    // Search in increments of smallest plate
    for (double delta = -searchRange; delta <= searchRange; delta += step) {
      if (delta == 0) continue; // Skip exact (already tried)

      final testWeight = targetWeight + delta;
      if (testWeight <= 0) continue;

      final result = calculatePlates(
        targetWeight: testWeight,
        barbellWeight: barbellWeight,
        availablePlates: availablePlates,
        excludedPlates: excludedPlates,
      );

      // Only add if exact and not already seen
      if (result.isExact && !seenWeights.contains(result.totalWeight)) {
        seenWeights.add(result.totalWeight);
        alternatives.add(result);
      }
    }

    // Sort by closeness to target
    alternatives.sort((a, b) {
      final diffA = (a.totalWeight - targetWeight).abs();
      final diffB = (b.totalWeight - targetWeight).abs();
      return diffA.compareTo(diffB);
    });

    // Return top alternatives
    return alternatives.take(maxAlternatives).toList();
  }

  /// Check if exact weight is achievable with current configuration
  static bool isExactWeightAchievable({
    required double targetWeight,
    required double? barbellWeight,
    required List<double> availablePlates,
    Set<double> excludedPlates = const {},
  }) {
    final result = calculatePlates(
      targetWeight: targetWeight,
      barbellWeight: barbellWeight,
      availablePlates: availablePlates,
      excludedPlates: excludedPlates,
    );
    return result.isExact;
  }
}
