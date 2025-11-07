/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets/smart_cta_button
/// 🎯 Feature: routine
/// 🔧 Type: enum
///
/// Smart CTA Button State
///
/// Defines the possible states of the context-aware CTA button
/// based on user's current training status.
///
/// States:
/// - activeWorkout: User has not completed workout today and has scheduled workout
/// - completedToday: User has completed workout today
/// - restDay: Today is a scheduled rest day
/// - noScheduled: No workout scheduled today and no workout completed
library;

/// Smart CTA Button State
///
/// Enum representing the possible states of the dynamic call-to-action button
/// on the home screen. The button adapts its appearance and action based on
/// the user's current training context.
enum SmartButtonState {
  /// User has not completed workout today and has scheduled workout
  ///
  /// Shows: "💪 Inizia [Workout Name]"
  /// Action: Navigate to workout session with scheduled template
  activeWorkout,

  /// User has completed workout today
  ///
  /// Shows: "✅ Visualizza Recap"
  /// Action: Navigate to today's workout summary/history
  completedToday,

  /// Today is a scheduled rest day
  ///
  /// Shows: "😌 Riposa. Prossimo: [date]"
  /// Action: Show recovery tips and next workout date
  restDay,

  /// No workout scheduled today and no workout completed
  ///
  /// Shows: "📅 Esplora Workout"
  /// Action: Navigate to workout library/exploration
  noScheduled,
}

/// Extension to get user-friendly description for each state
///
/// Provides human-readable descriptions for debugging and logging purposes.
extension SmartButtonStateExtension on SmartButtonState {
  /// Get user-friendly description of the button state
  String get description {
    switch (this) {
      case SmartButtonState.activeWorkout:
        return 'Active workout scheduled';
      case SmartButtonState.completedToday:
        return 'Workout completed today';
      case SmartButtonState.restDay:
        return 'Rest day scheduled';
      case SmartButtonState.noScheduled:
        return 'No workout scheduled';
    }
  }
}
