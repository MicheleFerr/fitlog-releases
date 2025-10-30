import 'package:gymbro_flutter_new/shared/domain/entities/weight_increment.dart';

/// Weight Settings Entity
///
/// Stores user preferences for weight increments and fractional plates.
class WeightSettings {
  const WeightSettings({
    required this.defaultIncrement,
    required this.customIncrement,
    required this.availablePlates,
    this.useCustomIncrement = false,
  });

  /// Factory: Default settings for kg
  factory WeightSettings.defaultKg() {
    return const WeightSettings(
      defaultIncrement: WeightIncrement.kg_2_5,
      customIncrement: WeightIncrement.kg_1_0,
      useCustomIncrement: false,
      availablePlates: PlateOption.standardKgPlates,
    );
  }

  /// Factory: Default settings for lbs
  factory WeightSettings.defaultLbs() {
    return const WeightSettings(
      defaultIncrement: WeightIncrement.lbs_5_0,
      customIncrement: WeightIncrement.lbs_2_5,
      useCustomIncrement: false,
      availablePlates: PlateOption.standardLbsPlates,
    );
  }

  /// Default increment for quick +/- buttons
  final WeightIncrement defaultIncrement;

  /// Custom increment set by user
  final WeightIncrement customIncrement;

  /// Whether to use custom increment instead of default
  final bool useCustomIncrement;

  /// Available plates in user's gym (for plate calculator)
  final List<PlateOption> availablePlates;

  /// Get active increment (custom or default)
  WeightIncrement get activeIncrement {
    return useCustomIncrement ? customIncrement : defaultIncrement;
  }

  WeightSettings copyWith({
    WeightIncrement? defaultIncrement,
    WeightIncrement? customIncrement,
    bool? useCustomIncrement,
    List<PlateOption>? availablePlates,
  }) {
    return WeightSettings(
      defaultIncrement: defaultIncrement ?? this.defaultIncrement,
      customIncrement: customIncrement ?? this.customIncrement,
      useCustomIncrement: useCustomIncrement ?? this.useCustomIncrement,
      availablePlates: availablePlates ?? this.availablePlates,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightSettings &&
        other.defaultIncrement == defaultIncrement &&
        other.customIncrement == customIncrement &&
        other.useCustomIncrement == useCustomIncrement;
  }

  @override
  int get hashCode {
    return Object.hash(
      defaultIncrement,
      customIncrement,
      useCustomIncrement,
    );
  }
}

/// Plate Option for Fractional Plate Calculator
class PlateOption {
  const PlateOption({
    required this.weight,
    required this.count,
  });

  final double weight; // Weight of single plate (kg or lbs)
  final int count; // Number of plates available

  /// Standard kg plates (pairs)
  static const List<PlateOption> standardKgPlates = [
    PlateOption(weight: 25.0, count: 8), // 4 pairs
    PlateOption(weight: 20.0, count: 6), // 3 pairs
    PlateOption(weight: 15.0, count: 4), // 2 pairs
    PlateOption(weight: 10.0, count: 6), // 3 pairs
    PlateOption(weight: 5.0, count: 4), // 2 pairs
    PlateOption(weight: 2.5, count: 4), // 2 pairs
    PlateOption(weight: 1.25, count: 2), // 1 pair (fractional)
    PlateOption(weight: 0.5, count: 2), // 1 pair (fractional)
  ];

  /// Standard lbs plates (pairs)
  static const List<PlateOption> standardLbsPlates = [
    PlateOption(weight: 45.0, count: 8), // 4 pairs
    PlateOption(weight: 35.0, count: 4), // 2 pairs
    PlateOption(weight: 25.0, count: 6), // 3 pairs
    PlateOption(weight: 10.0, count: 6), // 3 pairs
    PlateOption(weight: 5.0, count: 4), // 2 pairs
    PlateOption(weight: 2.5, count: 4), // 2 pairs
    PlateOption(weight: 1.25, count: 2), // 1 pair (fractional)
  ];

  PlateOption copyWith({
    double? weight,
    int? count,
  }) {
    return PlateOption(
      weight: weight ?? this.weight,
      count: count ?? this.count,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlateOption &&
        other.weight == weight &&
        other.count == count;
  }

  @override
  int get hashCode => Object.hash(weight, count);
}
