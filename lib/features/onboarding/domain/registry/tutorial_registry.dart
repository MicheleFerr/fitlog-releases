import 'package:gymbro_flutter_new/features/onboarding/domain/events/tutorial_event.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/models/tutorial_definition.dart';

/// Registry of all contextual tutorials.
///
/// Maps event types to tutorial definitions. When a TutorialEvent is fired,
/// the TriggerEngine looks up the corresponding tutorial in this registry.
///
/// ## Tutorials (15 total):
/// 1. **Logging Set** - First tap on set input
/// 2. **Rest Timer** - First timer start
/// 3. **Exercise Management** - First long-press on exercise
/// 4. **Workout Completion** - After first workout
/// 5. **Analytics Intro** - After 3+ workouts, opening analytics
/// 6. **Templates Intro** - First template menu open
/// 7. **Advanced Techniques** - First superset/dropset/rest-pause selection
/// 8. **Superset Builder** - First time opening superset builder
/// 9. **Exercise Database** - First time searching exercises
/// 10. **RPE Selector** - First time using RPE
/// 11. **Quick Edit** - First time using quick edit
/// 12. **History** - First time viewing workout history
/// 13. **Routine Center** - First time opening routine center
/// 14. **Settings** - First time opening settings
/// 15. **Export Data** - First time tapping export
///
/// ## Anti-Spam Rules:
/// - 2 minute cooldown between tutorials
/// - 24 hour cooldown after dismiss (for proactive hints)
/// - Max 1 proactive hint per session
class TutorialRegistry {
  TutorialRegistry._();

  /// Map of event type to tutorial definition.
  static final Map<Type, TutorialDefinition> _tutorials = {
    // ============ 1. LOGGING SET ============
    // Trigger: User taps on set input field for first time
    // Shows: How to log weight/reps
    SetInputTapped: TutorialDefinition(
      id: 'logging_set',
      titleKey: 'tutorial_logging_set_title',
      descriptionKey: 'tutorial_logging_set_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('logging_set'),
    ),

    // ============ 2. REST TIMER ============
    // Trigger: Rest timer starts for first time
    // Shows: Timer controls, skip, adjust duration
    TimerStarted: TutorialDefinition(
      id: 'rest_timer',
      titleKey: 'tutorial_rest_timer_title',
      descriptionKey: 'tutorial_rest_timer_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('rest_timer'),
    ),

    // ============ 3. EXERCISE MANAGEMENT ============
    // Trigger: User long-presses exercise card for first time
    // Shows: Reorder, delete, edit exercise options
    ExerciseLongPressed: TutorialDefinition(
      id: 'exercise_management',
      titleKey: 'tutorial_exercise_mgmt_title',
      descriptionKey: 'tutorial_exercise_mgmt_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('exercise_management'),
    ),

    // ============ 4. WORKOUT COMPLETION ============
    // Trigger: User completes first workout
    // Shows: Congrats + what happens next (analytics, history)
    WorkoutCompleted: TutorialDefinition(
      id: 'workout_completion',
      titleKey: 'tutorial_workout_complete_title',
      descriptionKey: 'tutorial_workout_complete_desc',
      type: TutorialType.behavior,
      condition: (state, event) {
        // Only show on FIRST workout completion
        if (event is! WorkoutCompleted) return false;
        return event.totalWorkouts == 1 && !state.hasSeen('workout_completion');
      },
    ),

    // ============ 5. ANALYTICS INTRO ============
    // Trigger: User opens Analytics tab after 3+ workouts
    // Shows: What analytics are available (charts, trends)
    AnalyticsTabOpened: TutorialDefinition(
      id: 'analytics_intro',
      titleKey: 'tutorial_analytics_title',
      descriptionKey: 'tutorial_analytics_desc',
      type: TutorialType.behavior,
      condition: (state, _) =>
          state.totalWorkouts >= 3 && !state.hasSeen('analytics_intro'),
    ),

    // ============ 6. TEMPLATES INTRO ============
    // Trigger: User opens template menu for first time
    // Shows: How to create/use workout templates
    TemplateMenuOpened: TutorialDefinition(
      id: 'templates_intro',
      titleKey: 'tutorial_templates_title',
      descriptionKey: 'tutorial_templates_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('templates_intro'),
    ),

    // ============ 7. ADVANCED TECHNIQUES ============
    // Trigger: User selects superset/dropset/rest-pause
    // Shows: How the advanced technique works
    AdvancedTechniqueSelected: TutorialDefinition(
      id: 'advanced_techniques',
      titleKey: 'tutorial_advanced_title',
      descriptionKey: 'tutorial_advanced_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('advanced_techniques'),
    ),

    // ============ 8. SUPERSET BUILDER ============
    // Trigger: User opens superset builder for first time
    // Shows: How to create supersets, pair exercises
    SupersetBuilderOpened: TutorialDefinition(
      id: 'superset_builder',
      titleKey: 'tutorial_superset_builder_title',
      descriptionKey: 'tutorial_superset_builder_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('superset_builder'),
    ),

    // ============ 9. EXERCISE DATABASE ============
    // Trigger: User opens exercise search/database for first time
    // Shows: Search, filter, favorites, custom exercises
    ExerciseDatabaseOpened: TutorialDefinition(
      id: 'exercise_database',
      titleKey: 'tutorial_exercise_db_title',
      descriptionKey: 'tutorial_exercise_db_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('exercise_database'),
    ),

    // ============ 10. RPE SELECTOR ============
    // Trigger: User opens RPE selector for first time
    // Shows: What is RPE, how to use it, scale explanation
    RpeSelectorOpened: TutorialDefinition(
      id: 'rpe_selector',
      titleKey: 'tutorial_rpe_title',
      descriptionKey: 'tutorial_rpe_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('rpe_selector'),
    ),

    // ============ 11. QUICK EDIT ============
    // Trigger: User opens quick edit overlay for first time
    // Shows: Fast weight/reps adjustment, increment buttons
    QuickEditOpened: TutorialDefinition(
      id: 'quick_edit',
      titleKey: 'tutorial_quick_edit_title',
      descriptionKey: 'tutorial_quick_edit_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('quick_edit'),
    ),

    // ============ 12. HISTORY ============
    // Trigger: User opens workout history for first time
    // Shows: View past workouts, stats, compare progress
    HistoryScreenOpened: TutorialDefinition(
      id: 'history',
      titleKey: 'tutorial_history_title',
      descriptionKey: 'tutorial_history_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('history'),
    ),

    // ============ 13. ROUTINE CENTER ============
    // Trigger: User opens routine center for first time
    // Shows: Create routines, manage templates, schedule
    RoutineCenterOpened: TutorialDefinition(
      id: 'routine_center',
      titleKey: 'tutorial_routine_center_title',
      descriptionKey: 'tutorial_routine_center_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('routine_center'),
    ),

    // ============ 14. SETTINGS ============
    // Trigger: User opens settings for first time
    // Shows: Customize timer, sounds, theme, units
    SettingsScreenOpened: TutorialDefinition(
      id: 'settings',
      titleKey: 'tutorial_settings_title',
      descriptionKey: 'tutorial_settings_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('settings'),
    ),

    // ============ 15. EXPORT DATA ============
    // Trigger: User taps export data for first time
    // Shows: Export formats, what data is included
    ExportDataTapped: TutorialDefinition(
      id: 'export_data',
      titleKey: 'tutorial_export_title',
      descriptionKey: 'tutorial_export_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('export_data'),
    ),
  };

  /// Find tutorial definition for a given event.
  /// Returns null if no tutorial is mapped to this event type.
  static TutorialDefinition? findTutorial(TutorialEvent event) {
    return _tutorials[event.runtimeType];
  }

  /// Get tutorial definition by ID.
  /// Returns null if no tutorial with this ID exists.
  static TutorialDefinition? findById(String id) {
    return _tutorials.values.where((t) => t.id == id).firstOrNull;
  }

  /// Get all registered tutorials.
  static List<TutorialDefinition> get allTutorials => _tutorials.values.toList();

  /// Get all tutorial IDs.
  static List<String> get allTutorialIds =>
      _tutorials.values.map((t) => t.id).toList();

  /// Get count of registered tutorials.
  static int get count => _tutorials.length;

  /// Check if a tutorial exists for the given event type.
  static bool hasTutorial(Type eventType) => _tutorials.containsKey(eventType);
}
