/// Centralized box name constants for all Hive boxes in the app.
///
/// Benefits:
/// - ✅ No typos (compile-time checking)
/// - ✅ Easy refactoring (rename in one place)
/// - ✅ Version tracking for migrations
/// - ✅ Clear ownership per feature
///
/// Naming Convention:
/// - Format: `app.{feature}.{box_type}.v{version}`
/// - Example: `app.workout.data.v1`
///
/// Usage:
/// ```dart
/// final box = await manager.openBox<Map>(HiveBoxNames.workouts);
/// ```
class HiveBoxNames {
  HiveBoxNames._(); // Private constructor (utility class)

  // ═══════════════════════════════════════════════════════════
  // 🏋️ WORKOUT FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Main workouts data box
  /// Contains: Completed workout records
  static const String workouts = 'workouts';

  /// Workout drafts (in-progress workouts)
  static const String workoutDrafts = 'workout_drafts';

  /// Recovered drafts (after app crash)
  static const String recoveredDrafts = 'recovered_drafts';

  /// Workout summaries (aggregated data)
  static const String workoutSummaries = 'workout_summaries';

  /// Exercise activities within workouts
  static const String exerciseActivities = 'exercise_activities';

  /// Workout sync queue (pending Firebase sync)
  static const String workoutSyncQueue = 'workout_sync_queue';

  /// Workout metrics for analytics
  static const String workoutMetrics = 'workoutMetrics';

  /// Workout template cache
  static const String templateCache = 'template_cache';

  /// Workout previous data cache (last workout sets/reps for suggestions)
  static const String workoutPreviousDataCache = 'workout_previous_data_cache';

  // ═══════════════════════════════════════════════════════════
  // 📋 WORKOUT TEMPLATES FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Workout templates
  static const String templates = 'templates';

  /// Template sync queue (pending Firebase sync)
  static const String templateSyncQueue = 'template_sync_queue';

  // ═══════════════════════════════════════════════════════════
  // 💪 EXERCISE DATABASE FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Exercise database cache
  static const String exercises = 'exercises_cache';

  /// Exercise metadata (version, last update, etc.)
  static const String exercisesMetadata = 'exercises_metadata';

  /// Exercise sync queue
  static const String exercisesSyncQueue = 'exercises_sync_queue';

  /// Exercise usage tracking
  static const String exerciseUsage = 'exercise_usage';

  /// Exercise version service cache
  static const String exerciseVersionCache = 'exercise_version_cache';

  // ═══════════════════════════════════════════════════════════
  // 🎨 CUSTOM EXERCISES FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Custom exercises created by users
  static const String customExercises = 'custom_exercises';

  /// Custom exercises sync queue (Premium users)
  static const String customExercisesSyncQueue = 'custom_exercises_sync_queue';

  // ═══════════════════════════════════════════════════════════
  // 📈 STRESS INDEX FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Stress index results data
  static const String stressIndexData = 'stress_index_data';

  // ═══════════════════════════════════════════════════════════
  // 📊 ANALYTICS FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Skip analytics data
  static const String skipAnalytics = 'skip_analytics';

  /// Questionnaire analytics
  static const String questionnaireAnalytics = 'questionnaire_analytics';

  /// Suggestion accuracy tracking (strength standards)
  static const String suggestionAccuracy = 'suggestion_accuracy';

  // ═══════════════════════════════════════════════════════════
  // 📜 HISTORY FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Workout history
  static const String workoutHistory = 'workout_history';

  /// History sync queue
  static const String historySyncQueue = 'history_sync_queue';

  /// History metadata
  static const String historyMetadata = 'history_metadata';

  /// History view settings
  static const String historyViewSettings = 'history_view_settings';

  // ═══════════════════════════════════════════════════════════
  // 📊 STRENGTH STANDARDS FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Fitness profile data
  static const String fitnessProfile = 'fitness_profile';

  /// Medical clearance data
  static const String medicalClearance = 'medical_clearance';

  // ═══════════════════════════════════════════════════════════
  // ⏱️ TIMER FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Timer state storage (for persistence across restarts)
  static const String timerStorage = 'timer_storage';

  // ═══════════════════════════════════════════════════════════
  // 🔔 NOTIFICATIONS FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Cached notifications
  static const String cachedNotifications = 'cached_notifications';

  /// Notification records (anti-spam tracking)
  static const String notificationRecords = 'notification_records';

  /// Notification stats (aggregate notification data)
  static const String notificationStats = 'notification_stats';

  // ═══════════════════════════════════════════════════════════
  // 📅 SCHEDULING FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Scheduled workouts (workout planning)
  static const String scheduledWorkouts = 'scheduled_workouts';

  // ═══════════════════════════════════════════════════════════
  // 🏆 ACHIEVEMENTS FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Achievements cache (badges, milestones)
  static const String analyticsCache = 'analytics_cache';

  // ═══════════════════════════════════════════════════════════
  // ⚙️ SETTINGS & CONFIG
  // ═══════════════════════════════════════════════════════════

  /// App configuration
  static const String appConfig = 'app_config';

  /// App settings
  static const String appSettings = 'app_settings';

  /// Sync preferences
  static const String syncPreferences = 'sync_preferences';

  /// Feedback settings
  static const String feedbackSettings = 'feedback_settings';

  /// Weight settings
  static const String weightSettings = 'weight_settings';

  /// Generic settings box (contains multiple setting keys)
  /// Used by: HistoryViewSettingsDataSource, and others
  static const String settingsBox = 'settings_box';

  // ═══════════════════════════════════════════════════════════
  // 🔐 PRIVACY & CONSENT
  // ═══════════════════════════════════════════════════════════

  /// User consent data (GDPR)
  static const String userConsent = 'user_consent';

  // ═══════════════════════════════════════════════════════════
  // 👶 ONBOARDING
  // ═══════════════════════════════════════════════════════════

  /// Onboarding state
  static const String onboardingState = 'onboarding_state';

  // ═══════════════════════════════════════════════════════════
  // 👑 ADMIN FEATURE
  // ═══════════════════════════════════════════════════════════

  /// Admin preferences
  static const String adminPreferences = 'admin_preferences';

  // ═══════════════════════════════════════════════════════════
  // 💾 CLOUD SYNC DATA (Temporary boxes for sync operations)
  // ═══════════════════════════════════════════════════════════

  /// Workouts data for cloud sync
  static const String workoutsData = 'workouts_data';

  /// Templates data for cloud sync
  static const String templatesData = 'templates_data';

  /// Exercises data for cloud sync
  static const String exercisesData = 'exercises_data';

  /// Personal records data for cloud sync
  static const String personalRecordsData = 'personal_records_data';

  /// User profile cache
  static const String userProfileCache = 'user_profile_cache';

  // ═══════════════════════════════════════════════════════════
  // 🔧 HELPERS
  // ═══════════════════════════════════════════════════════════

  /// Get all box names (useful for debugging)
  static List<String> get allBoxNames => [
        // Workout
        workouts,
        workoutDrafts,
        recoveredDrafts,
        workoutSummaries,
        exerciseActivities,
        workoutSyncQueue,
        workoutMetrics,
        templateCache,
        workoutPreviousDataCache,
        // Templates
        templates,
        templateSyncQueue,
        // Exercise Database
        exercises,
        exercisesMetadata,
        exercisesSyncQueue,
        exerciseUsage,
        exerciseVersionCache,
        // Custom Exercises
        customExercises,
        customExercisesSyncQueue,
        // Stress Index
        stressIndexData,
        // Analytics
        skipAnalytics,
        questionnaireAnalytics,
        suggestionAccuracy,
        // History
        workoutHistory,
        historySyncQueue,
        historyMetadata,
        historyViewSettings,
        // Strength Standards
        fitnessProfile,
        medicalClearance,
        // Timer
        timerStorage,
        // Notifications
        cachedNotifications,
        notificationRecords,
        notificationStats,
        // Scheduling
        scheduledWorkouts,
        // Achievements
        analyticsCache,
        // Settings
        appConfig,
        appSettings,
        syncPreferences,
        feedbackSettings,
        weightSettings,
        settingsBox,
        // Privacy
        userConsent,
        // Onboarding
        onboardingState,
        // Admin
        adminPreferences,
        // Cloud Sync
        workoutsData,
        templatesData,
        exercisesData,
        personalRecordsData,
        userProfileCache,
      ];

  /// Get box name for a feature's sync queue
  /// Example: getSyncQueueName('workout') → 'workout_sync_queue'
  static String getSyncQueueName(String featureName) =>
      '${featureName}_sync_queue';

  /// Get box name for a feature's data
  /// Example: getDataBoxName('workout') → 'workout_data'
  static String getDataBoxName(String featureName) => '${featureName}_data';

  /// Check if a box name exists in the registry
  static bool isValidBoxName(String name) => allBoxNames.contains(name);
}
