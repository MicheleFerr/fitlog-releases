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
}
