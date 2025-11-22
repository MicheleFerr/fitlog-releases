/// Firestore Collection and Field Name Constants
///
/// Centralizes all Firestore collection names and field names to:
/// - Prevent typos and inconsistencies
/// - Enable compile-time checking (instead of runtime errors)
/// - Simplify refactoring (change in one place)
/// - Document data structure
///
/// Created: 2025-01-18
/// Status: Active
library;

// ============================================================================
// COLLECTION NAMES
// ============================================================================

/// Top-level collections
class FirestoreCollections {
  FirestoreCollections._(); // Private constructor to prevent instantiation

  // ==================== USER & AUTH ====================
  static const String users = 'users';

  // ==================== WORKOUT & EXERCISE ====================
  static const String workouts = 'workouts';
  static const String workoutTemplates = 'workout_templates';
  static const String exercises = 'exercises';
  static const String exercisesMetadata = 'exercises_metadata';
  static const String flexibleRoutines = 'flexibleRoutines';

  // ==================== ANALYTICS & METRICS ====================
  static const String analytics = 'analytics';
  static const String workoutMetrics = 'workoutMetrics';
  static const String achievements = 'achievements';

  // ==================== AI COACH & RECOVERY ====================
  static const String recoveryHistory = 'recovery_history';
  static const String hrvReadings = 'hrv_readings';
  static const String prCelebrations = 'pr_celebrations';
  static const String feedback = 'feedback';
  static const String insightFeedback = 'insight_feedback';

  // ==================== COMMUNITY & SOCIAL ====================
  static const String communityContributions = 'community_contributions';
  static const String userContributionStats = 'user_contribution_stats';
  static const String userSavedContributions = 'user_saved_contributions';
  static const String contributionReports = 'contribution_reports';
  static const String workoutsTogether = 'workouts_together';

  // ==================== VERIFICATION & MODERATION ====================
  static const String verificationRequests = 'verification_requests';
  static const String photoVerificationRequests = 'photo_verification_requests';

  // ==================== TEMPLATES & REVIEWS ====================
  static const String templateReviews = 'template_reviews';
  static const String templateComments = 'template_comments';
  static const String programDownloads = 'programDownloads';

  // ==================== PUBLIC DATA ====================
  static const String italianCities = 'italian_cities';
  static const String iceBreakers = 'ice_breakers';

  // ==================== SYSTEM & UTILITY ====================
  static const String connectivityCheck = '_connectivity_check';

  // ==================== LEGACY (DEPRECATED) ====================
  // ⚠️ DO NOT USE - These collections no longer exist in Firebase
  // Keeping for reference during migration period

  /// @deprecated Use 'workouts' instead
  @Deprecated('Collection removed. Use workouts with nested exercises[] array')
  static const String exerciseActivitiesLegacy = 'exerciseActivities';

  /// @deprecated Use 'workouts' instead
  @Deprecated('Collection removed. Use workouts with nested exercises[] array')
  static const String dropSetsActivityLegacy = 'dropSetsActivity';

  /// @deprecated Use 'workouts' instead
  @Deprecated('Collection removed. Use workouts with nested exercises[] array')
  static const String restPauseSetsActivityLegacy = 'restPauseSetsActivity';
}

/// User subcollections (nested under /users/{userId}/)
class FirestoreUserSubcollections {
  FirestoreUserSubcollections._();

  static const String prCelebrations = 'pr_celebrations';
  static const String recoveryHistory = 'recovery_history';
  static const String hrvReadings = 'hrv_readings';
  static const String notificationSettings = 'notificationSettings';
  static const String notificationHistory = 'notificationHistory';
}

// ============================================================================
// FIELD NAMES
// ============================================================================

/// Common field names used across multiple collections
class FirestoreFields {
  FirestoreFields._();

  // ==================== IDENTITY & TIMESTAMPS ====================

  /// User identifier (Firebase Auth UID)
  static const String userId = 'userId';

  /// User email address
  static const String email = 'email';

  /// User display name
  static const String userName = 'userName';

  /// User display name (alternative)
  static const String displayName = 'displayName';

  /// Document creation timestamp
  static const String createdAt = 'createdAt';

  /// Document last update timestamp
  static const String updatedAt = 'updatedAt';

  /// Workout/Activity completion timestamp
  static const String completedAt = 'completedAt';

  // ==================== WORKOUT & EXERCISE FIELDS ====================

  /// Workout name/title
  static const String workoutName = 'workoutName';

  /// Exercise name
  static const String exerciseName = 'exerciseName';

  /// Array of exercises in workout
  static const String exercises = 'exercises';

  /// Array of sets in exercise
  static const String sets = 'sets';

  /// Whether exercise/set is completed
  static const String isCompleted = 'isCompleted';

  /// Whether set is marked as done
  static const String done = 'done';

  /// Whether set is warmup
  static const String isWarmup = 'isWarmup';

  /// Weight value (string or number)
  static const String weight = 'weight';

  /// Repetitions count
  static const String reps = 'reps';

  /// Rest duration in seconds
  static const String rest = 'rest';

  /// Duration in seconds
  static const String duration = 'duration';

  // ==================== METRICS & ANALYTICS ====================

  /// Total volume (weight × reps)
  static const String totalVolume = 'totalVolume';

  /// Total sets count
  static const String totalSets = 'totalSets';

  /// Total reps count
  static const String totalReps = 'totalReps';

  /// Maximum weight lifted
  static const String maxWeight = 'maxWeight';

  /// Statistics object
  static const String stats = 'stats';

  // ==================== SOCIAL & COMMUNITY ====================

  /// Author user ID
  static const String authorId = 'authorId';

  /// Author name
  static const String authorName = 'authorName';

  /// Author email
  static const String authorEmail = 'authorEmail';

  /// Target user ID (for actions/reports)
  static const String targetUserId = 'targetUserId';

  /// Reporter user ID
  static const String reporterId = 'reporterId';

  /// User IDs in pair (buddy matches, workouts together)
  static const String userId1 = 'userId1';
  static const String userId2 = 'userId2';

  // ==================== CONTENT & METADATA ====================

  /// Title/heading
  static const String title = 'title';

  /// Description/body text
  static const String description = 'description';

  /// Content body
  static const String body = 'body';

  /// Category classification
  static const String category = 'category';

  /// Tags array
  static const String tags = 'tags';

  /// Difficulty level
  static const String difficulty = 'difficulty';

  /// Public visibility flag
  static const String isPublic = 'isPublic';

  // ==================== RATINGS & REVIEWS ====================

  /// Rating value (1-5)
  static const String rating = 'rating';

  /// Review text
  static const String review = 'review';

  /// Review timestamp
  static const String reviewedAt = 'reviewedAt';

  /// Upvotes count
  static const String upvotes = 'upvotes';

  /// Downvotes count
  static const String downvotes = 'downvotes';

  /// Upvoted by user IDs array
  static const String upvotedBy = 'upvotedBy';

  /// Downvoted by user IDs array
  static const String downvotedBy = 'downvotedBy';

  // ==================== STATUS & STATE ====================

  /// Status field (pending, active, completed, etc.)
  static const String status = 'status';

  /// Read status flag
  static const String isRead = 'isRead';

  /// Type/kind classification
  static const String type = 'type';

  /// Timestamp field (generic)
  static const String timestamp = 'timestamp';

  // ==================== HEALTH & RECOVERY ====================

  /// Heart Rate Variability value
  static const String hrv = 'hrv';

  /// Resting heart rate
  static const String restingHeartRate = 'restingHeartRate';

  /// Sleep hours
  static const String sleepHours = 'sleepHours';

  /// Stress level (1-10)
  static const String stressLevel = 'stressLevel';

  /// Muscle soreness level
  static const String muscleSoreness = 'muscleSoreness';

  /// Fatigue level
  static const String fatigueLevel = 'fatigueLevel';

  // ==================== NOTIFICATIONS ====================

  /// Notification type
  static const String notificationType = 'notificationType';

  /// Enable workout reminders
  static const String enableWorkoutReminders = 'enableWorkoutReminders';

  /// Enable recovery alerts
  static const String enableRecoveryAlerts = 'enableRecoveryAlerts';

  /// Settings version number
  static const String settingsVersion = 'settingsVersion';

  // ==================== LEGACY (DEPRECATED) ====================

  /// @deprecated Use 'userId' instead (2025-01-18)
  @Deprecated('Field renamed. Use userId for consistency')
  static const String emailLegacy = 'email';

  /// @deprecated Use 'completedAt' instead (2025-01-18)
  @Deprecated('Field renamed. Use completedAt for workout completions')
  static const String createdAtLegacy = 'createdAt';
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Helper to build user subcollection path
String userSubcollectionPath(String userId, String subcollection) {
  return '${FirestoreCollections.users}/$userId/$subcollection';
}

/// Helper to validate collection name exists
bool isValidCollection(String collectionName) {
  // Use reflection or manual check
  // For now, return true (can be enhanced with code generation)
  return collectionName.isNotEmpty;
}

// ============================================================================
// QUERY HELPERS
// ============================================================================

/// Common query field combinations
class FirestoreQueryFields {
  FirestoreQueryFields._();

  /// User workouts query: where userId = X, orderBy completedAt desc
  static const List<String> userWorkoutsQuery = [
    FirestoreFields.userId,
    FirestoreFields.completedAt,
  ];

  /// User exercises query: where userId = X, where exerciseName = Y, orderBy completedAt desc
  static const List<String> userExercisesQuery = [
    FirestoreFields.userId,
    FirestoreFields.exerciseName,
    FirestoreFields.completedAt,
  ];

  /// Community contributions query: where status = X, orderBy createdAt desc
  static const List<String> communityContributionsQuery = [
    FirestoreFields.status,
    FirestoreFields.createdAt,
  ];

  /// Buddy profiles query: where userId != X (open for matching)
  static const List<String> buddyProfilesQuery = [
    FirestoreFields.userId,
  ];
}
