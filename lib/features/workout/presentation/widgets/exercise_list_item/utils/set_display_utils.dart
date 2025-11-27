/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/presentation/widgets/exercise_list_item/utils
/// 🎯 Feature: Set Display Utils
/// 🔧 Type: Pure functions for set display formatting
///
/// Pure functions for formatting exercise set display including
/// weight formatting, set details based on counting mode, colors, and duration.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Pure functions for set display formatting
///
/// Provides utilities for:
/// - Formatting weight based on measurement unit (kg/lbs)
/// - Building set details widgets based on counting mode
/// - Getting colors for set backgrounds based on status
/// - Formatting duration for time-based exercises
class SetDisplayUtils {
  // Private constructor to prevent instantiation
  SetDisplayUtils._();

  /// Format weight based on measurement unit
  ///
  /// Converts weight to display unit (kg or lbs) with proper formatting.
  /// Uses 2 decimals for kg, 1 decimal for lbs, and shows integers when possible.
  ///
  /// Parameters:
  /// - [weight]: Weight value in kg (storage unit)
  /// - [unit]: Display unit ('kg' or 'lbs')
  ///
  /// Returns:
  /// - Formatted weight string with unit (e.g., "80 kg", "176.5 lbs")
  ///
  /// Example:
  /// ```dart
  /// final formatted = SetDisplayUtils.formatWeight(80.0, 'kg');
  /// // Returns: "80 kg"
  ///
  /// final formattedLbs = SetDisplayUtils.formatWeight(80.0, 'lbs');
  /// // Returns: "176.4 lbs"
  /// ```
  static String formatWeight(double? weight, String unit) {
    if (weight == null) return '0 $unit';
    return weight.formatWeight(unit);
  }

  /// Build set details based on counting mode
  ///
  /// Creates a list of widgets to display set details appropriate for the exercise type:
  /// - WEIGHTED: Shows "weight × reps" (e.g., "80 kg × 10 reps")
  /// - REPS: Shows only reps (e.g., "10 reps") for bodyweight exercises
  /// - TIME: Shows duration in seconds (e.g., "30s") for isometric exercises
  ///
  /// Parameters:
  /// - [context]: BuildContext for theme and localization
  /// - [set]: ExerciseSet containing set data
  /// - [mode]: ExerciseCountingMode determining display format
  /// - [unit]: Measurement unit for weight ('kg' or 'lbs')
  ///
  /// Returns:
  /// - List of widgets to display in a Row
  ///
  /// Example:
  /// ```dart
  /// Row(
  ///   children: SetDisplayUtils.buildSetDetails(
  ///     context,
  ///     set,
  ///     ExerciseCountingMode.weighted,
  ///     'kg',
  ///   ),
  /// )
  /// ```
  static List<Widget> buildSetDetails(
    BuildContext context,
    ExerciseSet set,
    ExerciseCountingMode mode,
    String unit,
  ) {
    switch (mode) {
      case ExerciseCountingMode.weighted:
        // Weighted: Show weight × reps
        return [
          if (set.weight != null) ...[
            Text(
              set.weight!.formatWeight(unit),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration:
                    set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(width: 4),
            Text('×', style: context.textTheme.bodySmall),
            const SizedBox(width: 4),
          ],
          if (set.reps != null)
            Text(
              set.actualReps != null && set.isCompleted
                  ? '${set.actualReps}/${set.reps} reps'
                  : '${set.reps} reps',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration:
                    set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
        ];

      case ExerciseCountingMode.reps:
        // Reps-only: Show reps only (bodyweight exercises)
        return [
          if (set.reps != null)
            Text(
              set.actualReps != null && set.isCompleted
                  ? '${set.actualReps}/${set.reps} reps'
                  : '${set.reps} reps',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration:
                    set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
        ];

      case ExerciseCountingMode.time:
        // Time-based: Show duration (isometric exercises)
        // Note: For TIME exercises, duration is stored in 'reps' field
        return [
          if (set.reps != null)
            Text(
              '${set.reps}s',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration:
                    set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          // Also show 'seconds' field if exists (for backward compatibility)
          if (set.seconds != null && set.reps == null)
            Text(
              '${set.seconds}s',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration:
                    set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
        ];
    }
  }

  /// Get color for set based on completion/warmup status
  ///
  /// Returns appropriate background color for set card based on:
  /// - Warmup status (amber/warning color with low opacity)
  /// - Completed status (tertiary color with low opacity)
  /// - Pending status (surface color with low opacity)
  ///
  /// Parameters:
  /// - [context]: BuildContext for theme colors
  /// - [set]: ExerciseSet containing status information
  ///
  /// Returns:
  /// - Color for set background
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     color: SetDisplayUtils.getSetBackgroundColor(context, set),
  ///     borderRadius: BorderRadius.circular(8),
  ///   ),
  /// )
  /// ```
  static Color getSetBackgroundColor(
    BuildContext context,
    ExerciseSet set,
  ) {
    if (set.isWarmup) {
      // Warmup sets: amber/warning color
      return context.warningContainer;
    } else if (set.isCompleted) {
      // Completed sets: tertiary color with low opacity
      return context.colors.tertiary.withValues(alpha: 0.1);
    } else {
      // Pending sets: surface color
      return context.colors.surfaceContainerHighest.withValues(alpha: 0.5);
    }
  }

  /// Get border color for set based on completion/warmup status
  ///
  /// Returns appropriate border color for set card based on:
  /// - Warmup status (warning color with medium opacity)
  /// - Completed status (tertiary color with low opacity)
  /// - Pending status (null - no border)
  ///
  /// Parameters:
  /// - [context]: BuildContext for theme colors
  /// - [set]: ExerciseSet containing status information
  ///
  /// Returns:
  /// - Color for set border, or null if no border needed
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     color: SetDisplayUtils.getSetBackgroundColor(context, set),
  ///     borderRadius: BorderRadius.circular(8),
  ///     border: SetDisplayUtils.getSetBorderColor(context, set) != null
  ///         ? Border.all(color: SetDisplayUtils.getSetBorderColor(context, set)!)
  ///         : null,
  ///   ),
  /// )
  /// ```
  static Color? getSetBorderColor(
    BuildContext context,
    ExerciseSet set,
  ) {
    if (set.isWarmup) {
      return context.warningColor.withValues(alpha: 0.3);
    } else if (set.isCompleted) {
      return context.colors.tertiary.withValues(alpha: 0.3);
    }
    return null; // No border for pending sets
  }

  /// Format duration for time-based exercises
  ///
  /// Converts milliseconds to human-readable duration format:
  /// - < 60s: "Xs" (e.g., "45s")
  /// - >= 60s: "XmYs" (e.g., "2m30s")
  ///
  /// Parameters:
  /// - [milliseconds]: Duration in milliseconds (can be null)
  ///
  /// Returns:
  /// - Formatted duration string, or "0s" if null
  ///
  /// Example:
  /// ```dart
  /// final duration = SetDisplayUtils.formatDuration(45000.0);
  /// // Returns: "45s"
  ///
  /// final longDuration = SetDisplayUtils.formatDuration(150000.0);
  /// // Returns: "2m30s"
  /// ```
  static String formatDuration(double? milliseconds) {
    if (milliseconds == null || milliseconds == 0) return '0s';

    final seconds = (milliseconds / 1000).round();

    if (seconds < 60) {
      return '${seconds}s';
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return '${minutes}m';
      } else {
        return '${minutes}m${remainingSeconds}s';
      }
    }
  }
}
