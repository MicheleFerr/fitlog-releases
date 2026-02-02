import 'package:freezed_annotation/freezed_annotation.dart';

part 'strength_standard.freezed.dart';
part 'strength_standard.g.dart';

/// Represents a strength standard for a specific exercise with bodyweight-based tables.
///
/// Contains data from sources like ExRx.net and SymmetricStrength to provide
/// reference 1RM values for different experience levels and bodyweights.
@freezed
abstract class StrengthStandard with _$StrengthStandard {
  const factory StrengthStandard({
    /// Unique identifier (e.g., "barbell_bench_press")
    required String id,

    /// Display name (e.g., "Barbell Bench Press")
    required String name,

    /// Search keywords for semantic matching (Italian + English)
    required List<String> keywords,

    /// Equipment type (e.g., "Bilanciere", "Manubri")
    required String equipment,

    /// Target muscle groups (codes + full names, e.g., ["PETT", "Pectorals"])
    required List<String> muscleGroups,

    /// Data source identifier (e.g., "exrx_net", "estimated_from_benchmarks")
    required String dataSource,

    /// Bodyweight table: kg → level → 1RM (kg)
    /// Example: {"60": {"novice": 57.5, "intermediate": 70.0}}
    /// Optional - some exercises only have estimated multipliers
    Map<String, Map<String, double>>? bodyweightTable,

    /// Bodyweight multipliers: level → multiplier
    /// Example: {"novice": 0.93, "intermediate": 1.13}
    /// Optional - some exercises only have estimated multipliers
    Map<String, double>? bodyweightMultipliers,

    /// Estimated multipliers for exercises derived from main lifts
    /// Example: {"untrained": 0.60, "novice": 0.75, "intermediate": 0.90}
    /// Used when no exact bodyweightTable is available
    Map<String, double>? estimatedMultipliers,

    /// Whether this is bodyweight exercise (reps-based instead of weight)
    @Default(false) bool isBodyweightExercise,
  }) = _StrengthStandard;

  factory StrengthStandard.fromJson(Map<String, dynamic> json) =>
      _$StrengthStandardFromJson(json);
}

/// Experience levels for strength standards
enum ExperienceLevel {
  @JsonValue('untrained')
  untrained('Principiante', 'Untrained'),

  @JsonValue('novice')
  novice('Base', 'Novice'),

  @JsonValue('intermediate')
  intermediate('Intermedio', 'Intermediate'),

  @JsonValue('advanced')
  advanced('Avanzato', 'Advanced'),

  @JsonValue('elite')
  elite('Elite', 'Elite');

  const ExperienceLevel(this.labelIT, this.labelEN);

  final String labelIT;
  final String labelEN;

  String getLabel(String locale) => locale.startsWith('it') ? labelIT : labelEN;
}

/// Extension to help with strength standard calculations
extension StrengthStandardExtension on StrengthStandard {
  /// Get the effective multipliers (bodyweightMultipliers or estimatedMultipliers)
  Map<String, double> get effectiveMultipliers =>
      bodyweightMultipliers ?? estimatedMultipliers ?? {};

  /// Get 1RM estimate for a given bodyweight and experience level
  double? getOneRepMax({
    required double bodyweightKg,
    required ExperienceLevel level,
  }) {
    final levelKey = level.name;
    final multipliers = effectiveMultipliers;

    // If no bodyweightTable, use multipliers directly
    if (bodyweightTable == null || bodyweightTable!.isEmpty) {
      final multiplier = multipliers[levelKey];
      if (multiplier == null) return null;
      return bodyweightKg * multiplier;
    }

    // Try exact bodyweight match first
    final bodyweightKey = bodyweightKg.round().toString();

    if (bodyweightTable!.containsKey(bodyweightKey)) {
      return bodyweightTable![bodyweightKey]?[levelKey];
    }

    // Interpolate between nearest bodyweights
    final availableWeights =
        bodyweightTable!.keys
            .map((k) => double.tryParse(k))
            .whereType<double>()
            .toList()
          ..sort();

    if (availableWeights.isEmpty) {
      // Fallback to multiplier if no table data
      return bodyweightKg * (multipliers[levelKey] ?? 1.0);
    }

    // Find closest weights for interpolation
    double? lowerWeight;
    double? upperWeight;

    for (final weight in availableWeights) {
      if (weight <= bodyweightKg) {
        lowerWeight = weight;
      }
      if (weight >= bodyweightKg && upperWeight == null) {
        upperWeight = weight;
        break;
      }
    }

    // Edge cases: extrapolation
    if (lowerWeight == null) {
      // Below all table values, use multiplier
      return bodyweightKg * (multipliers[levelKey] ?? 1.0);
    }

    if (upperWeight == null) {
      // Above all table values, use highest + multiplier scaling
      final highestWeight = availableWeights.last;
      final highestValue =
          bodyweightTable![highestWeight.toString()]?[levelKey] ?? 0;
      final multiplier = multipliers[levelKey] ?? 1.0;
      return highestValue + (bodyweightKg - highestWeight) * multiplier;
    }

    // Linear interpolation
    final lowerValue =
        bodyweightTable![lowerWeight.toString()]?[levelKey] ?? 0.0;
    final upperValue =
        bodyweightTable![upperWeight.toString()]?[levelKey] ?? 0.0;

    final ratio = (bodyweightKg - lowerWeight) / (upperWeight - lowerWeight);
    return lowerValue + (upperValue - lowerValue) * ratio;
  }

  /// Get suggested working weight for hypertrophy (70% of 1RM)
  double? getSuggestedWorkingWeight({
    required double bodyweightKg,
    required ExperienceLevel level,
    double intensityFactor = 0.70, // 70% of 1RM for 8-12 reps
  }) {
    final oneRM = getOneRepMax(bodyweightKg: bodyweightKg, level: level);

    return oneRM != null ? oneRM * intensityFactor : null;
  }
}
