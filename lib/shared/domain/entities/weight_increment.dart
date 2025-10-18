/// Weight Increment Value Object
///
/// Represents a weight increment with validation and utility methods.
/// Supports both standard increments (2.5kg, 5kg) and fractional (0.5kg, 1.25kg).
class WeightIncrement {
  const WeightIncrement(this.value);

  final double value;

  /// Predefined standard increments
  static const WeightIncrement kg_0_5 = WeightIncrement(0.5);
  static const WeightIncrement kg_1_0 = WeightIncrement(1.0);
  static const WeightIncrement kg_1_25 = WeightIncrement(1.25);
  static const WeightIncrement kg_2_5 = WeightIncrement(2.5);
  static const WeightIncrement kg_5_0 = WeightIncrement(5.0);
  static const WeightIncrement kg_10_0 = WeightIncrement(10.0);

  /// Predefined standard increments (lbs)
  static const WeightIncrement lbs_1_0 = WeightIncrement(1.0);
  static const WeightIncrement lbs_2_5 = WeightIncrement(2.5);
  static const WeightIncrement lbs_5_0 = WeightIncrement(5.0);
  static const WeightIncrement lbs_10_0 = WeightIncrement(10.0);
  static const WeightIncrement lbs_25_0 = WeightIncrement(25.0);

  /// All standard kg increments
  static const List<WeightIncrement> standardKgIncrements = [
    kg_0_5,
    kg_1_0,
    kg_1_25,
    kg_2_5,
    kg_5_0,
    kg_10_0,
  ];

  /// All standard lbs increments
  static const List<WeightIncrement> standardLbsIncrements = [
    lbs_1_0,
    lbs_2_5,
    lbs_5_0,
    lbs_10_0,
    lbs_25_0,
  ];

  /// Validate increment value
  bool get isValid {
    return value > 0 && value <= 50; // Max 50kg/lbs increment
  }

  /// Check if this is a fractional increment (< 1)
  bool get isFractional {
    return value < 1.0;
  }

  /// Check if this is a microloading increment (< 2.5)
  bool get isMicroloading {
    return value < 2.5;
  }

  /// Format for display
  String format(String unit) {
    if (value == value.toInt()) {
      // Integer value
      return '${value.toInt()}$unit';
    } else {
      // Decimal value
      return '${value.toStringAsFixed(2)}$unit';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightIncrement && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'WeightIncrement($value)';
}
