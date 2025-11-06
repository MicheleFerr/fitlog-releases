/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/domain/entities
/// 🎯 Feature: Exercise Counting Mode
/// 🔧 Type: Enum with helper methods
///
/// Defines how exercises are counted/tracked during workouts
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Enum defining the three types of exercise counting modes
enum ExerciseCountingMode {
  /// Weighted exercises: require weight + reps (e.g., bench press, squats)
  weighted,

  /// Bodyweight exercises: require only reps (e.g., push-ups, pull-ups)
  reps,

  /// Time-based exercises: require time duration (e.g., plank, wall sit)
  time;

  // ========== VALIDATION HELPERS ==========

  /// Whether this exercise type requires weight input
  bool get requiresWeight => this == ExerciseCountingMode.weighted;

  /// Whether this exercise type requires reps input
  bool get requiresReps =>
      this == ExerciseCountingMode.weighted ||
      this == ExerciseCountingMode.reps;

  /// Whether this exercise type requires time input
  bool get requiresTime => this == ExerciseCountingMode.time;

  // ========== DISPLAY HELPERS ==========

  /// Get localized display name
  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case ExerciseCountingMode.weighted:
        return l10n.countingModeWeighted;
      case ExerciseCountingMode.reps:
        return l10n.countingModeReps;
      case ExerciseCountingMode.time:
        return l10n.countingModeTime;
    }
  }

  /// Get icon for this counting mode
  IconData get icon {
    switch (this) {
      case ExerciseCountingMode.weighted:
        return Icons.fitness_center; // Dumbbell icon
      case ExerciseCountingMode.reps:
        return Icons.repeat; // Repeat icon
      case ExerciseCountingMode.time:
        return Icons.timer; // Timer icon
    }
  }

  /// Get color for this counting mode
  Color getColor(ColorScheme colorScheme) {
    switch (this) {
      case ExerciseCountingMode.weighted:
        return colorScheme.primary;
      case ExerciseCountingMode.reps:
        return colorScheme.secondary;
      case ExerciseCountingMode.time:
        return colorScheme.tertiary;
    }
  }

  /// Get a short description for UI tooltips
  String getDescription(AppLocalizations l10n) {
    switch (this) {
      case ExerciseCountingMode.weighted:
        return 'Exercises with weight (kg/lb) and repetitions';
      case ExerciseCountingMode.reps:
        return 'Bodyweight exercises with repetitions only';
      case ExerciseCountingMode.time:
        return 'Isometric exercises measured in time duration';
    }
  }

  // ========== SERIALIZATION ==========

  /// Convert from JSON string
  static ExerciseCountingMode fromString(String? value) {
    if (value == null) return ExerciseCountingMode.weighted;

    try {
      return ExerciseCountingMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ExerciseCountingMode.weighted,
      );
    } catch (e) {
      return ExerciseCountingMode.weighted;
    }
  }

  /// Convert to JSON string
  String toJson() => name;
}
