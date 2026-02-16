/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/services
/// 🎯 Feature: analytics
/// 🔧 Type: service
///
/// Neglected Muscle Detector - Identifies under-trained muscle groups
///
/// **Algorithm**:
/// - Threshold: <5% of total volume = neglected
/// - Priority scoring based on deviation from optimal
/// - Contextual warnings (e.g., chest high + back low = posture risk)
library;

import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_balance_calculator.dart';

/// Neglected Muscle Result - Contains muscle name and severity
class NeglectedMuscle {
  const NeglectedMuscle({
    required this.muscleName,
    required this.volumePercentage,
    required this.severity,
    required this.priority,
  });

  /// Muscle group name (lowercase)
  final String muscleName;

  /// Current volume percentage (0-100)
  final double volumePercentage;

  /// Severity: critical (<2%), high (2-3.5%), medium (3.5-5%)
  final NeglectSeverity severity;

  /// Priority score (0-10) - higher = more urgent
  /// Based on: severity + imbalance with antagonist + posture risk
  final double priority;
}

/// Neglect Severity Levels
enum NeglectSeverity {
  critical, // <2% volume
  high, // 2-3.5% volume
  medium, // 3.5-5% volume
}

/// Neglected Muscle Detector Service
///
/// **Usage**:
/// ```dart
/// final detector = NeglectedMuscleDetector();
/// final neglected = detector.detectNeglectedMuscles(balance);
///
/// for (final muscle in neglected) {
///   print('${muscle.muscleName}: ${muscle.volumePercentage}% (${muscle.severity})');
/// }
/// ```
class NeglectedMuscleDetector {
  /// Mappa abbreviazioni JSON → chiavi detector
  ///
  /// Normalizza le chiavi abbreviate lowercase del MuscleBalanceCalculator
  /// (es. "glut", "femo", "quad") alle chiavi inglesi del detector
  /// (es. "glutes", "hamstrings", "quads").
  ///
  /// Grouping logic:
  /// - trap → back (upper back is part of back group)
  /// - add/abdu → glutes (hip complex)
  /// - coll → shoulders (neck training often uses shoulder exercises)
  static const Map<String, String> _abbrToDetectorKey = {
    'pett': 'chest',
    'lat': 'back',
    'trap': 'back', // traps group con back
    'lomb': 'lower_back',
    'lombar': 'lower_back',
    'delt': 'shoulders',
    'delt_ant': 'shoulders',
    'delt_lat': 'shoulders',
    'delt_post': 'rear_delts',
    'bici': 'biceps',
    'tric': 'triceps',
    'ava': 'forearms',
    'quad': 'quads',
    'femo': 'hamstrings',
    'glut': 'glutes',
    'polp': 'calves',
    'core': 'abs',
    'obl': 'abs',
    'add': 'glutes', // adductors group con glutes
    'abdu': 'glutes', // abductors group con glutes
    'coll': 'shoulders', // neck → shoulders
  };

  /// Soglie di neglect per gruppo muscolare.
  ///
  /// Basate su distribuzione naturale del volume:
  /// - Muscoli grandi (back, quads): range naturale 12-25%
  /// - Muscoli medi (chest, hamstrings): range 8-15%
  /// - Muscoli piccoli (biceps, calves): range 3-8%
  static const Map<String, double> neglectThresholds = {
    // Grandi
    'back': 8.0,
    'quads': 8.0,
    // Medi
    'chest': 6.0,
    'hamstrings': 5.0,
    'glutes': 5.0,
    'shoulders': 5.0,
    // Piccoli
    'biceps': 3.0,
    'triceps': 3.0,
    'calves': 2.5,
    'forearms': 2.0,
    'abs': 3.0,
    'lower_back': 2.5,
    'rear_delts': 2.0,
  };

  /// Fallback se muscolo non in mappa
  static const double defaultNeglectThreshold = 5.0;

  /// Detect neglected muscles from balance metrics
  ///
  /// Returns list sorted by priority (most urgent first)
  List<NeglectedMuscle> detectNeglectedMuscles(MuscleBalanceMetrics balance) {
    final neglectedList = <NeglectedMuscle>[];

    // Normalize abbreviated keys to detector keys
    final normalizedVolumes = <String, double>{};
    for (final entry in balance.muscleVolumePercentages.entries) {
      final rawKey = entry.key.toLowerCase();
      final detectorKey = _abbrToDetectorKey[rawKey] ?? rawKey;
      // Aggregate volumes for keys that map to the same detector key (e.g., trap + lat → back)
      normalizedVolumes[detectorKey] =
          (normalizedVolumes[detectorKey] ?? 0.0) + entry.value;
    }

    // Iterate over normalized volumes instead of raw balance data
    for (final entry in normalizedVolumes.entries) {
      final muscleName = entry.key;
      final volumePercent = entry.value;
      final threshold =
          neglectThresholds[muscleName] ?? defaultNeglectThreshold;

      if (volumePercent < threshold) {
        final severity = _calculateSeverity(volumePercent, threshold);
        final priority = _calculatePriority(
          muscleName: muscleName,
          volumePercent: volumePercent,
          severity: severity,
          normalizedVolumes: normalizedVolumes,
        );

        neglectedList.add(
          NeglectedMuscle(
            muscleName: muscleName,
            volumePercentage: volumePercent,
            severity: severity,
            priority: priority,
          ),
        );
      }
    }

    // Sort by priority (highest first)
    neglectedList.sort((a, b) => b.priority.compareTo(a.priority));

    return neglectedList;
  }

  /// Calculate severity based on ratio of volume to muscle-specific threshold
  ///
  /// - ratio < 0.4 = critical (less than 40% of expected minimum)
  /// - ratio < 0.7 = high (40-70% of expected minimum)
  /// - else = medium (70-100% of expected minimum)
  NeglectSeverity _calculateSeverity(double volumePercent, double threshold) {
    final ratio = threshold > 0 ? volumePercent / threshold : 0.0;
    if (ratio < 0.4) return NeglectSeverity.critical;
    if (ratio < 0.7) return NeglectSeverity.high;
    return NeglectSeverity.medium;
  }

  /// Calculate priority score (0-10)
  ///
  /// Factors:
  /// 1. Severity (0-4 points)
  /// 2. Antagonist imbalance (0-3 points)
  /// 3. Posture risk (0-3 points)
  double _calculatePriority({
    required String muscleName,
    required double volumePercent,
    required NeglectSeverity severity,
    required Map<String, double> normalizedVolumes,
  }) {
    double score = 0;

    // 1. Severity score (0-4)
    switch (severity) {
      case NeglectSeverity.critical:
        score += 4.0;
        break;
      case NeglectSeverity.high:
        score += 3.0;
        break;
      case NeglectSeverity.medium:
        score += 2.0;
        break;
    }

    // 2. Antagonist imbalance score (0-3)
    final antagonist = _getAntagonist(muscleName);
    if (antagonist != null) {
      final antagonistVolume = normalizedVolumes[antagonist] ?? 0.0;
      final imbalanceRatio = antagonistVolume > 0
          ? (antagonistVolume / volumePercent)
          : 1.0;

      if (imbalanceRatio > 3.0) {
        score += 3.0; // Severe imbalance
      } else if (imbalanceRatio > 2.0) {
        score += 2.0; // High imbalance
      } else if (imbalanceRatio > 1.5) {
        score += 1.0; // Moderate imbalance
      }
    }

    // 3. Posture risk score (0-3)
    score += _calculatePostureRisk(muscleName, normalizedVolumes);

    return score.clamp(0.0, 10.0);
  }

  /// Get antagonist muscle for a given muscle
  ///
  /// Examples:
  /// - chest ↔ back
  /// - quads ↔ hamstrings
  /// - biceps ↔ triceps
  /// - rear_delts ↔ shoulders
  /// - glutes ↔ hip_flexors
  String? _getAntagonist(String muscleName) {
    const antagonistPairs = {
      'chest': 'back',
      'back': 'chest',
      'quads': 'hamstrings',
      'hamstrings': 'quads',
      'biceps': 'triceps',
      'triceps': 'biceps',
      'abs': 'lower_back',
      'lower_back': 'abs',
      'rear_delts': 'shoulders',
      'shoulders': 'rear_delts',
      'glutes': 'hip_flexors',
      'hip_flexors': 'glutes',
    };

    return antagonistPairs[muscleName.toLowerCase()];
  }

  /// Calculate posture risk score (0-3) using relative ratios
  ///
  /// Uses agonist/antagonist volume ratio instead of absolute percentages,
  /// making detection independent of total training volume.
  ///
  /// High risk scenarios:
  /// - Back neglected + chest/back ratio > 2.0 → rounded shoulders
  /// - Hamstrings neglected + quads/hamstrings ratio > 2.5 → knee issues
  /// - Rear delts neglected + shoulders/rear_delts ratio > 3.0 → shoulder impingement
  /// - Lower back neglected + abs/lower_back ratio > 2.5 → lower back weakness
  double _calculatePostureRisk(
    String muscleName,
    Map<String, double> normalizedVolumes,
  ) {
    final muscle = muscleName.toLowerCase();

    // Back neglected: rischio rounded shoulders se chest/back ratio alto
    if (muscle == 'back') {
      final chestVol = normalizedVolumes['chest'] ?? 0.0;
      final backVol = normalizedVolumes['back'] ?? 0.01;
      if (chestVol / backVol > 2.0) return 3.0;
      if (chestVol / backVol > 1.5) return 2.0;
    }

    // Hamstrings neglected: rischio ginocchia se quads/hamstrings ratio alto
    if (muscle == 'hamstrings') {
      final quadsVol = normalizedVolumes['quads'] ?? 0.0;
      final hamVol = normalizedVolumes['hamstrings'] ?? 0.01;
      if (quadsVol / hamVol > 2.5) return 3.0;
      if (quadsVol / hamVol > 1.8) return 2.0;
    }

    // Rear delts neglected: rischio shoulder impingement
    if (muscle == 'rear_delts') {
      final shouldersVol = normalizedVolumes['shoulders'] ?? 0.0;
      final rearVol = normalizedVolumes['rear_delts'] ?? 0.01;
      if (shouldersVol / rearVol > 3.0) return 2.5;
      if (shouldersVol / rearVol > 2.0) return 1.5;
    }

    // Lower back neglected: rischio debolezza lombare
    if (muscle == 'lower_back') {
      final absVol = normalizedVolumes['abs'] ?? 0.0;
      final lbVol = normalizedVolumes['lower_back'] ?? 0.01;
      if (absVol / lbVol > 2.5) return 2.0;
    }

    return 0.0;
  }
}
