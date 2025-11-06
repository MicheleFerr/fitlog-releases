/// Volume range for analytics and progress tracking
class VolumeRange {

  const VolumeRange({
    required this.min,
    required this.optimal,
    required this.max,
    this.label = '',  // Optional label for display
  });
  final double min;
  final double optimal;  // Optimal/target volume
  final double max;
  final String label;

  /// Creates from JSON map
  factory VolumeRange.fromJson(Map<String, dynamic> json) {
    return VolumeRange(
      min: (json['min'] as num).toDouble(),
      optimal: (json['optimal'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      label: json['label'] as String? ?? '',
    );
  }

  /// Converts to JSON map
  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'optimal': optimal,
      'max': max,
      'label': label,
    };
  }
}
