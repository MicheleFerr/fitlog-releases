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
  /// Threshold for neglected muscle (<5% of total volume)
  static const double neglectThreshold = 5.0;

  /// Critical threshold (<2% of total volume)
  static const double criticalThreshold = 2.0;

  /// High severity threshold (2-3.5%)
  static const double highSeverityThreshold = 3.5;

  /// Detect neglected muscles from balance metrics
  ///
  /// Returns list sorted by priority (most urgent first)
  List<NeglectedMuscle> detectNeglectedMuscles(MuscleBalanceMetrics balance) {
    final neglectedList = <NeglectedMuscle>[];

    // Check each muscle group
    for (final entry in balance.muscleVolumePercentages.entries) {
      final muscleName = entry.key;
      final volumePercent = entry.value;

      // Check if neglected (<5%)
      if (volumePercent < neglectThreshold) {
        final severity = _calculateSeverity(volumePercent);
        final priority = _calculatePriority(
          muscleName: muscleName,
          volumePercent: volumePercent,
          severity: severity,
          balance: balance,
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

  /// Calculate severity based on volume percentage
  NeglectSeverity _calculateSeverity(double volumePercent) {
    if (volumePercent < criticalThreshold) {
      return NeglectSeverity.critical;
    } else if (volumePercent < highSeverityThreshold) {
      return NeglectSeverity.high;
    } else {
      return NeglectSeverity.medium;
    }
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
    required MuscleBalanceMetrics balance,
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
      final antagonistVolume =
          balance.muscleVolumePercentages[antagonist] ?? 0.0;
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
    score += _calculatePostureRisk(muscleName, balance);

    return score.clamp(0.0, 10.0);
  }

  /// Get antagonist muscle for a given muscle
  ///
  /// Examples:
  /// - chest ↔ back
  /// - quads ↔ hamstrings
  /// - biceps ↔ triceps
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
    };

    return antagonistPairs[muscleName.toLowerCase()];
  }

  /// Calculate posture risk score (0-3)
  ///
  /// High risk scenarios:
  /// - Back neglected + chest high → rounded shoulders
  /// - Hamstrings neglected + quads high → knee issues
  /// - Rear delts neglected + front delts high → shoulder impingement
  double _calculatePostureRisk(
    String muscleName,
    MuscleBalanceMetrics balance,
  ) {
    final muscle = muscleName.toLowerCase();
    final volumes = balance.muscleVolumePercentages;

    // Back neglected + chest overdeveloped
    if (muscle == 'back') {
      final chestVolume = volumes['chest'] ?? 0.0;
      if (chestVolume > 15.0) {
        return 3.0; // High risk: rounded shoulders
      }
    }

    // Hamstrings neglected + quads overdeveloped
    if (muscle == 'hamstrings') {
      final quadsVolume = volumes['quads'] ?? 0.0;
      if (quadsVolume > 20.0) {
        return 3.0; // High risk: knee strain
      }
    }

    // Rear delts neglected + front/side delts overdeveloped
    if (muscle == 'rear_delts') {
      final shouldersVolume = volumes['shoulders'] ?? 0.0;
      if (shouldersVolume > 12.0) {
        return 2.5; // Moderate-high risk: shoulder impingement
      }
    }

    // Lower back neglected + abs overdeveloped
    if (muscle == 'lower_back') {
      final absVolume = volumes['abs'] ?? 0.0;
      if (absVolume > 10.0) {
        return 2.0; // Moderate risk: lower back weakness
      }
    }

    return 0.0; // No specific posture risk
  }
}
