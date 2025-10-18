/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/analytics
/// 🎯 Feature: analytics
/// 🔧 Type: constants
///
/// Analytics event names, parameters, and user properties
library;

/// Analytics event names
///
/// All event names follow Firebase Analytics naming conventions:
/// - Max 40 characters
/// - Lowercase with underscores
/// - Descriptive and consistent
///
/// Usage:
/// ```dart
/// await analytics.logEvent(
///   name: AnalyticsEvents.workoutCompleted,
///   parameters: {
///     AnalyticsParameters.duration: 3600,
///   },
/// );
/// ```
class AnalyticsEvents {
  AnalyticsEvents._(); // Private constructor to prevent instantiation

  // ===== APP LIFECYCLE =====

  /// App opened by user
  static const String appOpen = 'app_open';

  /// User signed in
  static const String signIn = 'sign_in';

  /// User signed out
  static const String signOut = 'sign_out';

  /// User signed up (new account)
  static const String signUp = 'sign_up';

  // ===== SCREEN VIEWS =====

  /// Screen view (automatically tracked by RouteObserver)
  static const String screenView = 'screen_view';

  // ===== WORKOUT EVENTS =====

  /// Workout started
  static const String workoutStarted = 'workout_started';

  /// Workout paused
  static const String workoutPaused = 'workout_paused';

  /// Workout resumed after pause
  static const String workoutResumed = 'workout_resumed';

  /// Workout completed successfully
  static const String workoutCompleted = 'workout_completed';

  /// Workout cancelled/abandoned
  static const String workoutCancelled = 'workout_cancelled';

  /// Workout saved to history
  static const String workoutSaved = 'workout_saved';

  /// Workout deleted
  static const String workoutDeleted = 'workout_deleted';

  // ===== EXERCISE EVENTS =====

  /// Exercise added to workout
  static const String exerciseAdded = 'exercise_added';

  /// Exercise removed from workout
  static const String exerciseRemoved = 'exercise_removed';

  /// Exercise reordered in workout
  static const String exerciseReordered = 'exercise_reordered';

  /// Exercise customized (sets/reps/weight changed)
  static const String exerciseCustomized = 'exercise_customized';

  /// Set completed
  static const String setCompleted = 'set_completed';

  /// Set skipped
  static const String setSkipped = 'set_skipped';

  // ===== PRESET EVENTS =====

  /// Rep range preset selected
  static const String repPresetSelected = 'rep_preset_selected';

  /// Set count preset selected
  static const String setCountPresetSelected = 'set_count_preset_selected';

  /// Rest time preset selected
  static const String restTimePresetSelected = 'rest_time_preset_selected';

  // ===== TIMER EVENTS =====

  /// Rest timer started
  static const String restTimerStarted = 'rest_timer_started';

  /// Rest timer completed
  static const String restTimerCompleted = 'rest_timer_completed';

  /// Rest timer cancelled
  static const String restTimerCancelled = 'rest_timer_cancelled';

  /// Rest timer skipped
  static const String restTimerSkipped = 'rest_timer_skipped';

  /// Custom timer duration set
  static const String customTimerSet = 'custom_timer_set';

  // ===== LIVE ACTIVITY EVENTS (iOS) =====

  /// Live Activity started
  static const String liveActivityStarted = 'live_activity_started';

  /// Live Activity stopped
  static const String liveActivityStopped = 'live_activity_stopped';

  /// Live Activity interacted with (from lock screen)
  static const String liveActivityInteraction = 'live_activity_interaction';

  // ===== TEMPLATE EVENTS =====

  /// Workout template created
  static const String templateCreated = 'template_created';

  /// Workout template used/loaded
  static const String templateUsed = 'template_used';

  /// Workout template edited
  static const String templateEdited = 'template_edited';

  /// Workout template deleted
  static const String templateDeleted = 'template_deleted';

  // ===== ROUTINE EVENTS =====

  /// Routine created
  static const String routineCreated = 'routine_created';

  /// Routine started
  static const String routineStarted = 'routine_started';

  /// Routine completed
  static const String routineCompleted = 'routine_completed';

  // ===== ANALYTICS & PROGRESS =====

  /// User viewed analytics dashboard
  static const String analyticsViewed = 'analytics_viewed';

  /// User viewed progress charts
  static const String progressViewed = 'progress_viewed';

  /// Personal record achieved
  static const String personalRecordAchieved = 'personal_record_achieved';

  // ===== SETTINGS EVENTS =====

  /// Settings changed
  static const String settingsChanged = 'settings_changed';

  /// Theme changed (dark/light)
  static const String themeChanged = 'theme_changed';

  /// Language changed
  static const String languageChanged = 'language_changed';

  /// Unit system changed (metric/imperial)
  static const String unitSystemChanged = 'unit_system_changed';

  // ===== SHARING & EXPORT =====

  /// Workout shared
  static const String workoutShared = 'workout_shared';

  /// Data exported
  static const String dataExported = 'data_exported';

  // ===== ERRORS & ISSUES =====

  /// Error occurred
  static const String error = 'error';

  /// Sync failed
  static const String syncFailed = 'sync_failed';

  // ===== ECOMMERCE =====

  /// In-app purchase
  static const String purchase = 'purchase';

  /// Premium subscription started
  static const String subscriptionStarted = 'subscription_started';
}

/// Analytics parameter keys
///
/// All parameter keys follow Firebase Analytics conventions:
/// - Max 40 characters
/// - Lowercase with underscores
/// - Descriptive values
///
/// Usage:
/// ```dart
/// await analytics.logEvent(
///   name: AnalyticsEvents.workoutCompleted,
///   parameters: {
///     AnalyticsParameters.duration: 3600,
///     AnalyticsParameters.exerciseCount: 8,
///     AnalyticsParameters.workoutType: 'strength',
///   },
/// );
/// ```
class AnalyticsParameters {
  AnalyticsParameters._();

  // ===== SCREEN PARAMETERS =====

  /// Screen name (e.g., 'WorkoutDetailScreen')
  static const String screenName = 'screen_name';

  /// Screen class (e.g., 'WorkoutDetailScreen')
  static const String screenClass = 'screen_class';

  // ===== WORKOUT PARAMETERS =====

  /// Workout ID
  static const String workoutId = 'workout_id';

  /// Workout name
  static const String workoutName = 'workout_name';

  /// Workout type (strength, cardio, hybrid)
  static const String workoutType = 'workout_type';

  /// Workout duration in seconds
  static const String duration = 'duration';

  /// Number of exercises in workout
  static const String exerciseCount = 'exercise_count';

  /// Total sets in workout
  static const String totalSets = 'total_sets';

  /// Total reps in workout
  static const String totalReps = 'total_reps';

  /// Total weight lifted (kg or lbs)
  static const String totalWeight = 'total_weight';

  /// Workout completion percentage (0-100)
  static const String completionRate = 'completion_rate';

  // ===== EXERCISE PARAMETERS =====

  /// Exercise ID
  static const String exerciseId = 'exercise_id';

  /// Exercise name
  static const String exerciseName = 'exercise_name';

  /// Exercise category (chest, back, legs, etc.)
  static const String exerciseCategory = 'exercise_category';

  /// Exercise type (compound, isolation, cardio)
  static const String exerciseType = 'exercise_type';

  /// Number of sets
  static const String sets = 'sets';

  /// Number of reps
  static const String reps = 'reps';

  /// Weight used (kg or lbs)
  static const String weight = 'weight';

  /// RPE (Rate of Perceived Exertion) 1-10
  static const String rpe = 'rpe';

  // ===== PRESET PARAMETERS =====

  /// Preset type (rep_range, set_count, rest_time)
  static const String presetType = 'preset_type';

  /// Preset ID (hypertrophy, strength, etc.)
  static const String presetId = 'preset_id';

  /// Preset value (e.g., 10 for reps, 90 for seconds)
  static const String presetValue = 'preset_value';

  // ===== TIMER PARAMETERS =====

  /// Timer duration in seconds
  static const String timerDuration = 'timer_duration';

  /// Timer type (rest, workout, custom)
  static const String timerType = 'timer_type';

  /// Timer completed flag (true/false)
  static const String timerCompleted = 'timer_completed';

  /// Timer skipped flag (true/false)
  static const String timerSkipped = 'timer_skipped';

  // ===== LIVE ACTIVITY PARAMETERS (iOS) =====

  /// Live Activity ID
  static const String liveActivityId = 'live_activity_id';

  /// Live Activity action (start, stop, pause, resume)
  static const String liveActivityAction = 'live_activity_action';

  // ===== TEMPLATE PARAMETERS =====

  /// Template ID
  static const String templateId = 'template_id';

  /// Template name
  static const String templateName = 'template_name';

  // ===== ROUTINE PARAMETERS =====

  /// Routine ID
  static const String routineId = 'routine_id';

  /// Routine name
  static const String routineName = 'routine_name';

  /// Routine week number
  static const String routineWeek = 'routine_week';

  /// Routine day number
  static const String routineDay = 'routine_day';

  // ===== SETTINGS PARAMETERS =====

  /// Setting name
  static const String settingName = 'setting_name';

  /// Setting old value
  static const String oldValue = 'old_value';

  /// Setting new value
  static const String newValue = 'new_value';

  // ===== ERROR PARAMETERS =====

  /// Error message
  static const String errorMessage = 'error_message';

  /// Error code
  static const String errorCode = 'error_code';

  /// Error type
  static const String errorType = 'error_type';

  // ===== SHARING PARAMETERS =====

  /// Share method (social, email, export)
  static const String shareMethod = 'share_method';

  /// Export format (pdf, csv, json)
  static const String exportFormat = 'export_format';

  // ===== ECOMMERCE PARAMETERS =====

  /// Product ID
  static const String productId = 'product_id';

  /// Product name
  static const String productName = 'product_name';

  /// Price
  static const String price = 'price';

  /// Currency (USD, EUR, etc.)
  static const String currency = 'currency';

  /// Transaction ID
  static const String transactionId = 'transaction_id';

  // ===== GENERAL PARAMETERS =====

  /// Source (where event originated)
  static const String source = 'source';

  /// Action (what action was performed)
  static const String action = 'action';

  /// Label (additional context)
  static const String label = 'label';

  /// Value (numeric value)
  static const String value = 'value';

  /// Success flag
  static const String success = 'success';
}

/// Analytics user properties
///
/// User properties describe segments of your user base.
/// They persist across sessions and are used for audience segmentation.
///
/// All property names follow Firebase Analytics conventions:
/// - Max 24 characters
/// - Lowercase with underscores
///
/// Usage:
/// ```dart
/// await analytics.setUserProperty(
///   name: AnalyticsUserProperties.preferredUnitSystem,
///   value: 'metric',
/// );
/// ```
class AnalyticsUserProperties {
  AnalyticsUserProperties._();

  // ===== USER PREFERENCES =====

  /// Preferred unit system (metric, imperial)
  static const String preferredUnitSystem = 'unit_system';

  /// Preferred theme (light, dark, system)
  static const String preferredTheme = 'theme';

  /// Preferred language (en, it, etc.)
  static const String preferredLanguage = 'language';

  // ===== USER EXPERIENCE =====

  /// User experience level (beginner, intermediate, advanced, expert)
  static const String experienceLevel = 'experience_level';

  /// Primary workout goal (strength, hypertrophy, endurance, weight_loss)
  static const String primaryGoal = 'primary_goal';

  /// Workout frequency per week
  static const String weeklyFrequency = 'weekly_frequency';

  // ===== USER BEHAVIOR =====

  /// Total workouts completed
  static const String totalWorkouts = 'total_workouts';

  /// Days since first workout
  static const String daysSinceFirst = 'days_since_first';

  /// Days since last workout
  static const String daysSinceLast = 'days_since_last';

  /// Average workout duration (minutes)
  static const String avgDuration = 'avg_duration';

  // ===== PREMIUM STATUS =====

  /// Premium subscription status (active, expired, none)
  static const String premiumStatus = 'premium_status';

  /// Subscription tier (basic, pro, elite)
  static const String subscriptionTier = 'subscription_tier';

  // ===== DEVICE & APP =====

  /// App version
  static const String appVersion = 'app_version';

  /// Platform (iOS, Android)
  static const String platform = 'platform';

  /// Device model (iPhone 14 Pro, etc.)
  static const String deviceModel = 'device_model';

  // ===== FEATURES USED =====

  /// Live Activities enabled (iOS only)
  static const String liveActivitiesEnabled = 'live_activities';

  /// Templates used count
  static const String templatesUsed = 'templates_used';

  /// Routines active count
  static const String activeRoutines = 'active_routines';
}

/// Analytics trace names for performance monitoring
///
/// Used with Firebase Performance to measure operation durations.
///
/// Usage:
/// ```dart
/// final traceId = await analytics.startTrace(AnalyticsTraces.saveWorkout);
/// try {
///   await saveWorkout();
/// } finally {
///   await analytics.stopTrace(traceId);
/// }
/// ```
class AnalyticsTraces {
  AnalyticsTraces._();

  // ===== WORKOUT OPERATIONS =====

  /// Save workout to database
  static const String saveWorkout = 'save_workout';

  /// Load workout from database
  static const String loadWorkout = 'load_workout';

  /// Delete workout from database
  static const String deleteWorkout = 'delete_workout';

  /// Sync workout to cloud
  static const String syncWorkout = 'sync_workout';

  // ===== EXERCISE OPERATIONS =====

  /// Add exercise to workout
  static const String addExercise = 'add_exercise';

  /// Remove exercise from workout
  static const String removeExercise = 'remove_exercise';

  /// Load exercise database
  static const String loadExercises = 'load_exercises';

  /// Search exercises
  static const String searchExercises = 'search_exercises';

  // ===== TEMPLATE OPERATIONS =====

  /// Save template
  static const String saveTemplate = 'save_template';

  /// Load template
  static const String loadTemplate = 'load_template';

  /// Apply template to workout
  static const String applyTemplate = 'apply_template';

  // ===== DATA OPERATIONS =====

  /// Export workout data
  static const String exportData = 'export_data';

  /// Import workout data
  static const String importData = 'import_data';

  /// Calculate analytics
  static const String calculateAnalytics = 'calculate_analytics';

  // ===== AUTH OPERATIONS =====

  /// Sign in operation
  static const String signIn = 'sign_in';

  /// Sign up operation
  static const String signUp = 'sign_up';

  /// Sign out operation
  static const String signOut = 'sign_out';
}
