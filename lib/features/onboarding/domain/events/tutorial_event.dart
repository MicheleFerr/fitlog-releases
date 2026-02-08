/// Sealed class for tutorial trigger events.
///
/// Events are emitted by widgets when user performs actions that
/// might trigger a contextual tutorial. The TriggerEngine listens
/// for these events and shows appropriate tutorials.
///
/// Event types:
/// - Workout events: SetInputTapped, TimerStarted, WorkoutOpened, WorkoutCompleted, QuickEditOpened
/// - Exercise events: ExerciseLongPressed, ExerciseDatabaseOpened
/// - Analytics events: AnalyticsTabOpened
/// - Template events: TemplateMenuOpened
/// - Advanced technique events: AdvancedTechniqueSelected, SupersetBuilderOpened
/// - UI events: RpeSelectorOpened, HistoryScreenOpened, RoutineCenterOpened
/// - Settings events: SettingsScreenOpened, ExportDataTapped
sealed class TutorialEvent {
  const TutorialEvent();
}

// ============ WORKOUT EVENTS ============

/// Triggered when user taps on a set input field for the first time.
/// Shows: "How to log a set" tutorial
class SetInputTapped extends TutorialEvent {
  const SetInputTapped();
}

/// Triggered when rest timer starts.
/// Shows: "Rest timer" tutorial
class TimerStarted extends TutorialEvent {
  const TimerStarted();
}

/// Triggered when workout screen is opened.
/// Carries exerciseCount for conditional logic.
class WorkoutOpened extends TutorialEvent {
  const WorkoutOpened({required this.exerciseCount});
  final int exerciseCount;
}

/// Triggered when a workout is completed.
/// Carries totalWorkouts for conditional logic (e.g., first workout).
class WorkoutCompleted extends TutorialEvent {
  const WorkoutCompleted({required this.totalWorkouts});
  final int totalWorkouts;
}

// ============ EXERCISE EVENTS ============

/// Triggered when user long-presses on an exercise card.
/// Shows: "Exercise management" tutorial (reorder, delete, etc.)
class ExerciseLongPressed extends TutorialEvent {
  const ExerciseLongPressed({required this.exerciseIndex});
  final int exerciseIndex;
}

// ============ ANALYTICS EVENTS ============

/// Triggered when user opens the Analytics tab.
/// Shows: "Analytics intro" tutorial (only after 3+ workouts)
class AnalyticsTabOpened extends TutorialEvent {
  const AnalyticsTabOpened();
}

// ============ TEMPLATE EVENTS ============

/// Triggered when user opens the template menu.
/// Shows: "Templates" tutorial
class TemplateMenuOpened extends TutorialEvent {
  const TemplateMenuOpened();
}

// ============ ADVANCED TECHNIQUE EVENTS ============

/// Triggered when user selects an advanced technique.
/// Shows: "Advanced techniques" tutorial (superset, dropset, rest-pause)
class AdvancedTechniqueSelected extends TutorialEvent {
  const AdvancedTechniqueSelected({required this.technique});
  /// The technique type: 'superset', 'dropset', 'restpause'
  final String technique;
}

/// Triggered when user opens the superset builder.
/// Shows: "Superset builder" tutorial
class SupersetBuilderOpened extends TutorialEvent {
  const SupersetBuilderOpened();
}

// ============ EXERCISE DATABASE EVENTS ============

/// Triggered when user opens the exercise database/search.
/// Shows: "Exercise database" tutorial (search, filter, favorites)
class ExerciseDatabaseOpened extends TutorialEvent {
  const ExerciseDatabaseOpened();
}

// ============ RPE EVENTS ============

/// Triggered when user opens the RPE selector.
/// Shows: "RPE" tutorial (what is RPE, how to use it)
class RpeSelectorOpened extends TutorialEvent {
  const RpeSelectorOpened();
}

// ============ QUICK EDIT EVENTS ============

/// Triggered when user opens quick edit overlay.
/// Shows: "Quick edit" tutorial (fast weight/reps adjustment)
class QuickEditOpened extends TutorialEvent {
  const QuickEditOpened();
}

// ============ HISTORY EVENTS ============

/// Triggered when user opens workout history screen.
/// Shows: "History" tutorial (view past workouts, stats)
class HistoryScreenOpened extends TutorialEvent {
  const HistoryScreenOpened();
}

// ============ ROUTINE EVENTS ============

/// Triggered when user opens routine center.
/// Shows: "Routine center" tutorial (create, manage routines)
class RoutineCenterOpened extends TutorialEvent {
  const RoutineCenterOpened();
}

// ============ SETTINGS EVENTS ============

/// Triggered when user opens settings screen.
/// Shows: "Settings" tutorial (customize timer, sounds, theme)
class SettingsScreenOpened extends TutorialEvent {
  const SettingsScreenOpened();
}

/// Triggered when user taps export data button.
/// Shows: "Export data" tutorial (how to export workout data)
class ExportDataTapped extends TutorialEvent {
  const ExportDataTapped();
}
