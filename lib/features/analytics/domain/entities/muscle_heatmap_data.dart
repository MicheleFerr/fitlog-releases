/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// Muscle Heatmap Data - Defines body diagram with muscle regions and heat values
///
/// **Design Inspiration**:
/// - Hevy App: Front/back body view with color-coded muscles
/// - Fitbod: Muscle group distribution heat map
/// - Boostcamp: Anatomically accurate muscle overlays
library;

import 'dart:ui';

/// Body view orientation
enum BodyView {
  front,
  back,
}

/// Muscle Heatmap Data - Contains muscle regions with coordinates and heat values
///
/// **Usage**:
/// ```dart
/// final heatmap = MuscleHeatmapData.fromVolumePercentages(
///   muscleVolumePercentages: {'chest': 25.5, 'back': 22.0, ...},
/// );
///
/// final chestHeat = heatmap.getMuscleHeat('chest', BodyView.front);
/// ```
class MuscleHeatmapData {
  const MuscleHeatmapData({
    required this.muscleRegions,
    required this.muscleHeatValues,
  });

  /// Factory: Create from muscle volume percentages (0-100)
  factory MuscleHeatmapData.fromVolumePercentages({
    required Map<String, double> muscleVolumePercentages,
  }) {
    // Normalize percentages to 0-100 heat scale
    final maxVolume = muscleVolumePercentages.values.fold<double>(
      0,
      (max, val) => val > max ? val : max,
    );

    final heatValues = muscleVolumePercentages.map((muscle, percentage) {
      // Normalize: 0% = 0 heat, maxVolume% = 100 heat
      final heat = maxVolume > 0 ? (percentage / maxVolume) * 100 : 0.0;
      return MapEntry(muscle.toLowerCase(), heat);
    });

    return MuscleHeatmapData(
      muscleRegions: _defaultMuscleRegions,
      muscleHeatValues: heatValues,
    );
  }

  /// Muscle regions with coordinates (front and back views)
  final Map<String, List<MuscleRegion>> muscleRegions;

  /// Heat values per muscle group (0-100 scale)
  /// Higher value = more trained (warmer color)
  final Map<String, double> muscleHeatValues;

  /// Get heat value for a specific muscle (0-100)
  double getMuscleHeat(String muscleName) {
    return muscleHeatValues[muscleName.toLowerCase()] ?? 0.0;
  }

  /// Get color for muscle heat value
  /// Cold (blue) → Medium (yellow) → Hot (red)
  Color getHeatColor(double heatValue) {
    final normalizedHeat = heatValue.clamp(0.0, 100.0) / 100.0;

    // Color gradient:
    // 0.0 = Blue (#2196F3)
    // 0.5 = Yellow (#FFC107)
    // 1.0 = Red (#F44336)
    if (normalizedHeat < 0.5) {
      // Blue → Yellow
      return Color.lerp(
        const Color(0xFF2196F3), // Blue
        const Color(0xFFFFC107), // Yellow
        normalizedHeat * 2, // 0.0-0.5 → 0.0-1.0
      )!;
    } else {
      // Yellow → Red
      return Color.lerp(
        const Color(0xFFFFC107), // Yellow
        const Color(0xFFF44336), // Red
        (normalizedHeat - 0.5) * 2, // 0.5-1.0 → 0.0-1.0
      )!;
    }
  }
}

/// Muscle Region - Defines a clickable region on the body diagram
///
/// **Properties**:
/// - name: Muscle group name (lowercase)
/// - view: Front or back view
/// - path: Polygon path defining the region (percentage-based 0-100)
/// - center: Center point for labels (x%, y%)
class MuscleRegion {
  const MuscleRegion({
    required this.name,
    required this.view,
    required this.pathPoints,
    required this.center,
  });

  /// Muscle group name (lowercase)
  final String name;

  /// Body view (front/back)
  final BodyView view;

  /// Polygon path points (x%, y% - 0-100 range)
  /// Example: [(10, 20), (15, 25), (15, 35), (10, 40)]
  final List<Offset> pathPoints;

  /// Center point for label placement (x%, y% - 0-100 range)
  final Offset center;

  /// Check if a tap at (x%, y%) is inside this region
  bool containsPoint(Offset point) {
    // Ray casting algorithm for point-in-polygon test
    int intersections = 0;
    for (int i = 0; i < pathPoints.length; i++) {
      final p1 = pathPoints[i];
      final p2 = pathPoints[(i + 1) % pathPoints.length];

      if ((p1.dy > point.dy) != (p2.dy > point.dy) &&
          point.dx < (p2.dx - p1.dx) * (point.dy - p1.dy) / (p2.dy - p1.dy) + p1.dx) {
        intersections++;
      }
    }

    return intersections % 2 == 1; // Odd = inside, Even = outside
  }
}

/// Default muscle regions for front and back views
///
/// **Coordinate System**: (x%, y%) where (0, 0) = top-left, (100, 100) = bottom-right
/// **Body proportions**: Head ~10%, Torso ~40%, Legs ~50%
final Map<String, List<MuscleRegion>> _defaultMuscleRegions = {
  // ============================================================================
  // FRONT VIEW - Upper Body
  // ============================================================================
  'chest': [
    const MuscleRegion(
      name: 'chest',
      view: BodyView.front,
      pathPoints: [
        Offset(35, 18), // Top left (below neck)
        Offset(65, 18), // Top right
        Offset(60, 32), // Bottom right
        Offset(40, 32), // Bottom left
      ],
      center: Offset(50, 25),
    ),
  ],
  'shoulders': [
    // Left shoulder
    const MuscleRegion(
      name: 'shoulders',
      view: BodyView.front,
      pathPoints: [
        Offset(20, 15), // Top outer
        Offset(35, 15), // Top inner
        Offset(35, 25), // Bottom inner
        Offset(25, 25), // Bottom outer
      ],
      center: Offset(27, 20),
    ),
    // Right shoulder
    const MuscleRegion(
      name: 'shoulders',
      view: BodyView.front,
      pathPoints: [
        Offset(65, 15), // Top inner
        Offset(80, 15), // Top outer
        Offset(75, 25), // Bottom outer
        Offset(65, 25), // Bottom inner
      ],
      center: Offset(73, 20),
    ),
  ],
  'arms': [
    // Left bicep
    const MuscleRegion(
      name: 'arms',
      view: BodyView.front,
      pathPoints: [
        Offset(20, 25), // Top
        Offset(30, 25), // Top inner
        Offset(32, 40), // Bottom inner
        Offset(22, 40), // Bottom outer
      ],
      center: Offset(26, 32),
    ),
    // Right bicep
    const MuscleRegion(
      name: 'arms',
      view: BodyView.front,
      pathPoints: [
        Offset(70, 25), // Top inner
        Offset(80, 25), // Top outer
        Offset(78, 40), // Bottom outer
        Offset(68, 40), // Bottom inner
      ],
      center: Offset(74, 32),
    ),
  ],
  'abs': [
    const MuscleRegion(
      name: 'abs',
      view: BodyView.front,
      pathPoints: [
        Offset(40, 32), // Top left
        Offset(60, 32), // Top right
        Offset(58, 50), // Bottom right (waist)
        Offset(42, 50), // Bottom left (waist)
      ],
      center: Offset(50, 41),
    ),
  ],

  // ============================================================================
  // FRONT VIEW - Lower Body
  // ============================================================================
  'quads': [
    // Left quad
    const MuscleRegion(
      name: 'quads',
      view: BodyView.front,
      pathPoints: [
        Offset(35, 50), // Top inner (hip)
        Offset(42, 50), // Top outer
        Offset(44, 75), // Bottom outer (knee)
        Offset(38, 75), // Bottom inner
      ],
      center: Offset(40, 62),
    ),
    // Right quad
    const MuscleRegion(
      name: 'quads',
      view: BodyView.front,
      pathPoints: [
        Offset(58, 50), // Top inner (hip)
        Offset(65, 50), // Top outer
        Offset(62, 75), // Bottom outer (knee)
        Offset(56, 75), // Bottom inner
      ],
      center: Offset(60, 62),
    ),
  ],
  'calves': [
    // Left calf
    const MuscleRegion(
      name: 'calves',
      view: BodyView.front,
      pathPoints: [
        Offset(38, 75), // Top inner (knee)
        Offset(44, 75), // Top outer
        Offset(42, 92), // Bottom outer (ankle)
        Offset(40, 92), // Bottom inner
      ],
      center: Offset(41, 83),
    ),
    // Right calf
    const MuscleRegion(
      name: 'calves',
      view: BodyView.front,
      pathPoints: [
        Offset(56, 75), // Top inner (knee)
        Offset(62, 75), // Top outer
        Offset(60, 92), // Bottom outer (ankle)
        Offset(58, 92), // Bottom inner
      ],
      center: Offset(59, 83),
    ),
  ],

  // ============================================================================
  // BACK VIEW - Upper Body
  // ============================================================================
  'back': [
    const MuscleRegion(
      name: 'back',
      view: BodyView.back,
      pathPoints: [
        Offset(35, 18), // Top left (below neck)
        Offset(65, 18), // Top right
        Offset(60, 45), // Bottom right (waist)
        Offset(40, 45), // Bottom left (waist)
      ],
      center: Offset(50, 31),
    ),
  ],
  'traps': [
    const MuscleRegion(
      name: 'traps',
      view: BodyView.back,
      pathPoints: [
        Offset(42, 15), // Top left (neck)
        Offset(58, 15), // Top right
        Offset(55, 22), // Bottom right
        Offset(45, 22), // Bottom left
      ],
      center: Offset(50, 18),
    ),
  ],
  'triceps': [
    // Left tricep
    const MuscleRegion(
      name: 'triceps',
      view: BodyView.back,
      pathPoints: [
        Offset(22, 25), // Top outer
        Offset(32, 25), // Top inner
        Offset(33, 40), // Bottom inner
        Offset(23, 40), // Bottom outer
      ],
      center: Offset(27, 32),
    ),
    // Right tricep
    const MuscleRegion(
      name: 'triceps',
      view: BodyView.back,
      pathPoints: [
        Offset(68, 25), // Top inner
        Offset(78, 25), // Top outer
        Offset(77, 40), // Bottom outer
        Offset(67, 40), // Bottom inner
      ],
      center: Offset(73, 32),
    ),
  ],

  // ============================================================================
  // BACK VIEW - Lower Body
  // ============================================================================
  'glutes': [
    const MuscleRegion(
      name: 'glutes',
      view: BodyView.back,
      pathPoints: [
        Offset(40, 45), // Top left (waist)
        Offset(60, 45), // Top right
        Offset(58, 55), // Bottom right (hip)
        Offset(42, 55), // Bottom left (hip)
      ],
      center: Offset(50, 50),
    ),
  ],
  'hamstrings': [
    // Left hamstring
    const MuscleRegion(
      name: 'hamstrings',
      view: BodyView.back,
      pathPoints: [
        Offset(35, 55), // Top inner (hip)
        Offset(42, 55), // Top outer
        Offset(44, 75), // Bottom outer (knee)
        Offset(38, 75), // Bottom inner
      ],
      center: Offset(40, 65),
    ),
    // Right hamstring
    const MuscleRegion(
      name: 'hamstrings',
      view: BodyView.back,
      pathPoints: [
        Offset(58, 55), // Top inner (hip)
        Offset(65, 55), // Top outer
        Offset(62, 75), // Bottom outer (knee)
        Offset(56, 75), // Bottom inner
      ],
      center: Offset(60, 65),
    ),
  ],
};
