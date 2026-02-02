/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/domain/services
/// Feature: analytics
/// Type: service
///
/// Volume Recommendation Service - Calculates personalized training volume
///
/// **Evidence-based design**:
/// - RP Strength volume landmarks (Israetel et al.)
/// - Rep ranges by goal (Schoenfeld 2017, NSCA guidelines)
/// - Progressive overload principles
///
/// **Sources**:
/// - Renaissance Periodization: MEV/MAV/MRV concepts
/// - Schoenfeld BJ (2017): Rep ranges for hypertrophy
/// - NSCA Essentials of Strength Training (4th ed)
library;

import 'dart:math';

import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';

/// Volume recommendation result with calculated sets, reps, and rest time
class VolumeRecommendation {
  const VolumeRecommendation({
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.rationale,
  });

  /// Number of sets recommended
  final int sets;

  /// Target reps per set
  final int reps;

  /// Rest time between sets in seconds
  final int restSeconds;

  /// Human-readable explanation of the recommendation
  final String? rationale;

  @override
  String toString() =>
      'VolumeRecommendation($sets sets x $reps reps, ${restSeconds}s rest)';
}

/// Service for calculating personalized training volume recommendations
///
/// Uses user questionnaire data (experience, goal, injury history) to
/// calculate appropriate sets, reps, and rest times for new exercises.
///
/// **Algorithm Summary**:
/// - Base sets: 3 (intermediate)
/// - Beginner modifier: -1 set (2 sets)
/// - Advanced modifier: +1 set (4 sets)
/// - Injury modifier: -1 set (minimum 2)
/// - Rep range: Based on training goal
/// - Rest time: Based on training goal
class VolumeRecommendationService {
  const VolumeRecommendationService();

  /// Default values when no user data available
  static const int defaultSets = 3;
  static const int defaultReps = 10;
  static const int defaultRestSeconds = 90;

  /// Calculate personalized volume recommendation
  ///
  /// [experience] - User's training experience level
  /// [goal] - User's primary training goal
  /// [hasInjuryHistory] - Whether user has reported injuries
  ///
  /// Returns a [VolumeRecommendation] with sets, reps, rest time, and rationale
  VolumeRecommendation calculate({
    required ExperienceLevel experience,
    required TrainingGoal goal,
    required bool hasInjuryHistory,
  }) {
    // Start with base sets for intermediate level
    int sets = 3;

    // Apply experience modifier
    // Research: Beginners need less volume to progress, advanced need more
    switch (experience) {
      case ExperienceLevel.untrained:
      case ExperienceLevel.novice:
        sets -= 1; // 2 sets - sufficient for neural adaptations
      case ExperienceLevel.intermediate:
        break; // 3 sets - standard hypertrophy range
      case ExperienceLevel.advanced:
      case ExperienceLevel.elite:
        sets += 1; // 4 sets - higher volume for continued progress
    }

    // Apply injury modifier
    // Conservative approach: reduce volume for users with injury history
    if (hasInjuryHistory) {
      sets = max(2, sets - 1);
    }

    // Determine reps and rest based on goal
    // Rep ranges from NSCA guidelines and Schoenfeld meta-analyses
    final (reps, restSeconds) = switch (goal) {
      TrainingGoal.strength => (5, 180), // Strength: heavy, longer rest
      TrainingGoal.hypertrophy => (
        10,
        90,
      ), // Hypertrophy: moderate, medium rest
      TrainingGoal.endurance => (15, 60), // Endurance: light, short rest
    };

    // Build rationale string
    final rationale = _buildRationale(
      experience: experience,
      goal: goal,
      hasInjuryHistory: hasInjuryHistory,
      sets: sets,
      reps: reps,
    );

    return VolumeRecommendation(
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      rationale: rationale,
    );
  }

  /// Calculate with default values (for users without questionnaire)
  VolumeRecommendation calculateDefault() {
    return const VolumeRecommendation(
      sets: defaultSets,
      reps: defaultReps,
      restSeconds: defaultRestSeconds,
      rationale: 'Standard recommendation (3x10)',
    );
  }

  /// Build human-readable explanation
  String _buildRationale({
    required ExperienceLevel experience,
    required TrainingGoal goal,
    required bool hasInjuryHistory,
    required int sets,
    required int reps,
  }) {
    final parts = <String>[];

    // Experience explanation
    switch (experience) {
      case ExperienceLevel.untrained:
      case ExperienceLevel.novice:
        parts.add('2 set per principianti');
      case ExperienceLevel.intermediate:
        parts.add('3 set standard');
      case ExperienceLevel.advanced:
      case ExperienceLevel.elite:
        parts.add('4 set per avanzati');
    }

    // Goal explanation
    switch (goal) {
      case TrainingGoal.strength:
        parts.add('5 rep per forza');
      case TrainingGoal.hypertrophy:
        parts.add('10 rep per ipertrofia');
      case TrainingGoal.endurance:
        parts.add('15 rep per resistenza');
    }

    // Injury note
    if (hasInjuryHistory) {
      parts.add('volume ridotto per sicurezza');
    }

    return parts.join(' - ');
  }
}
