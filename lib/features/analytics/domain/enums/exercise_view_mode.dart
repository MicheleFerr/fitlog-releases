/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/enums
/// 🎯 Feature: analytics
/// 🔧 Type: enum
///
/// ExerciseViewMode - View mode options for exercise detail screen
///
/// **Purpose**: Define different view modes for organizing/filtering exercise data
///
/// **Modes**:
/// - **compact**: Minimal view (no PR badges, chart, workout count)
/// - **detailed**: Full view with all information (default)
/// - **byMuscleGroup**: Group exercises by muscle group
/// - **byDate**: Organize workouts chronologically
/// - **byMajorWorkouts**: Filter/highlight significant workouts only
///
/// **Usage**:
/// ```dart
/// // In provider
/// final viewMode = ref.watch(exerciseViewModeProvider);
///
/// // In UI
/// if (viewMode == ExerciseViewMode.compact) {
///   // Hide PR badges and chart
/// }
/// ```
library;

/// Exercise detail view mode options
enum ExerciseViewMode {
  /// Compact view - minimal information
  /// Hides: PR badges, progress chart, workout count
  /// Shows: Exercise name, workout history (list only)
  compact,

  /// Detailed view - full information (default)
  /// Shows: Everything (PR badges, chart, workout count, history)
  detailed,

  /// Group by muscle group view
  /// Organizes workouts by primary muscle group targeted
  byMuscleGroup,

  /// Chronological date view
  /// Organizes workouts by date (timeline view)
  byDate,

  /// Major workouts only view
  /// Filters to show only significant/milestone workouts
  byMajorWorkouts,
}

/// Extension for ExerciseViewMode
extension ExerciseViewModeExtension on ExerciseViewMode {
  /// Get display name for view mode (localized - use context.l10n in UI)
  ///
  /// **Usage in UI**:
  /// ```dart
  /// // Get localized name
  /// final name = switch (viewMode) {
  ///   ExerciseViewMode.compact => context.l10n.viewModeCompact,
  ///   ExerciseViewMode.detailed => context.l10n.viewModeDetailed,
  ///   ExerciseViewMode.byMuscleGroup => context.l10n.viewModeByMuscleGroup,
  ///   ExerciseViewMode.byDate => context.l10n.viewModeByDate,
  ///   ExerciseViewMode.byMajorWorkouts => context.l10n.viewModeByMajorWorkouts,
  /// };
  /// ```

  /// Check if this mode should hide PR badges
  bool get shouldHidePrBadges {
    return this == ExerciseViewMode.compact;
  }

  /// Check if this mode should hide progress chart
  bool get shouldHideChart {
    return this == ExerciseViewMode.compact;
  }

  /// Check if this mode should hide workout count
  bool get shouldHideWorkoutCount {
    return this == ExerciseViewMode.compact;
  }
}
