import 'package:gymbro_flutter_new/shared/domain/entities/weight_settings.dart';

/// Plate Calculator Service
///
/// Calculates optimal plate combination to reach target weight.
class PlateCalculatorService {
  /// Calculate plates needed for target weight
  ///
  /// Returns PlateCalculation with exact combination or closest approximation.
  PlateCalculation calculatePlates({
    required double targetWeight,
    required double barWeight,
    required List<PlateOption> availablePlates,
  }) {
    // Weight per side (excluding bar)
    final weightPerSide = (targetWeight - barWeight) / 2;

    if (weightPerSide <= 0) {
      return PlateCalculation(
        targetWeight: targetWeight,
        actualWeight: barWeight,
        platesPerSide: [],
        isExact: true,
      );
    }

    // Sort plates from heaviest to lightest
    final sortedPlates = List<PlateOption>.from(availablePlates)
      ..sort((a, b) => b.weight.compareTo(a.weight));

    // Greedy algorithm: use heaviest plates first
    double remainingWeight = weightPerSide;
    final platesUsed = <PlateUsage>[];
    final availableCounts = { for (var p in sortedPlates) (p).weight : (p).count };

    for (final plate in sortedPlates) {
      if (remainingWeight <= 0) break;

      final maxPlates = availableCounts[plate.weight] ?? 0;
      final platesNeeded = (remainingWeight / plate.weight).floor();
      final platesToUse = platesNeeded < maxPlates ? platesNeeded : maxPlates;

      if (platesToUse > 0) {
        platesUsed.add(PlateUsage(
          weight: plate.weight,
          count: platesToUse,
        ));
        remainingWeight -= platesToUse * plate.weight;
        availableCounts[plate.weight] = maxPlates - platesToUse;
      }
    }

    // Calculate actual weight achieved
    final actualWeightPerSide = platesUsed.fold<double>(
      0,
      (sum, usage) => sum + (usage.weight * usage.count),
    );
    final actualTotalWeight = barWeight + (actualWeightPerSide * 2);

    // Check if exact match
    final isExact = (actualTotalWeight - targetWeight).abs() < 0.01;

    return PlateCalculation(
      targetWeight: targetWeight,
      actualWeight: actualTotalWeight,
      platesPerSide: platesUsed,
      isExact: isExact,
    );
  }
}

/// Result of plate calculation
class PlateCalculation {
  const PlateCalculation({
    required this.targetWeight,
    required this.actualWeight,
    required this.platesPerSide,
    required this.isExact,
  });

  final double targetWeight;
  final double actualWeight;
  final List<PlateUsage> platesPerSide;
  final bool isExact;

  /// Difference from target
  double get difference => actualWeight - targetWeight;

  /// Whether target was achievable
  bool get isAchievable => isExact || difference.abs() < 2.5;
}

/// Represents plates used per side
class PlateUsage {
  const PlateUsage({
    required this.weight,
    required this.count,
  });

  final double weight;
  final int count;

  @override
  String toString() => '${count}x ${weight}kg';
}
