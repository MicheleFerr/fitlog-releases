/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/domain/enums
/// 🎯 Feature: unified_feedback
/// 🔧 Type: enum
///
/// Unified Feedback Type - Type discriminator for all feedback systems
library;

/// Type of feedback in the unified system
///
/// This enum acts as a discriminator to identify which type of feedback
/// a document represents in the unified Firestore collection.
enum UnifiedFeedbackType {
  /// Feedback on specific exercise (name, instructions, equipment, etc.)
  ///
  /// Former collection: `exercise_feedback`
  /// Example: "Exercise name has typo", "Video shows incorrect form"
  exercise('exercise'),

  /// Feedback on AI Coach insights (helpful/not helpful with reasons)
  ///
  /// Former collection: `ai_coach_feedback`
  /// Example: "Insight was helpful", "Recommendation incorrect"
  aiInsight('ai_insight'),

  /// Feedback on Analytics page usability and features
  ///
  /// Former collection: `analytics_page_feedback`
  /// Example: "Charts are helpful", "Missing weekly view"
  analytics('analytics'),

  /// User reports about other users (inappropriate content, harassment, etc.)
  ///
  /// Former collection: `buddy_reports`
  /// Example: "Inappropriate photos", "Spam messages"
  buddyReport('buddy_report'),

  /// General app feedback not tied to specific feature
  ///
  /// Former collection: `userFeedback`
  /// Example: "App is great", "Feature request: dark mode"
  general('general'),

  /// Exercise correction patches (linked to ExercisePatch system)
  ///
  /// Collection: `exercise_patches` (kept separate for now)
  /// This type is for reference/linking only - actual patches remain in dedicated collection
  exercisePatch('exercise_patch');

  const UnifiedFeedbackType(this.value);

  /// Firestore value (used in documents)
  final String value;

  /// Create from Firestore string value
  static UnifiedFeedbackType fromString(String value) {
    return UnifiedFeedbackType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown feedback type: $value'),
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case UnifiedFeedbackType.exercise:
        return 'Exercise Feedback';
      case UnifiedFeedbackType.aiInsight:
        return 'AI Insight Feedback';
      case UnifiedFeedbackType.analytics:
        return 'Analytics Feedback';
      case UnifiedFeedbackType.buddyReport:
        return 'User Report';
      case UnifiedFeedbackType.general:
        return 'General Feedback';
      case UnifiedFeedbackType.exercisePatch:
        return 'Exercise Patch';
    }
  }

  /// Icon for UI display
  String get icon {
    switch (this) {
      case UnifiedFeedbackType.exercise:
        return '🏋️';
      case UnifiedFeedbackType.aiInsight:
        return '🤖';
      case UnifiedFeedbackType.analytics:
        return '📊';
      case UnifiedFeedbackType.buddyReport:
        return '🚩';
      case UnifiedFeedbackType.general:
        return '💬';
      case UnifiedFeedbackType.exercisePatch:
        return '🔧';
    }
  }
}

/// Status of feedback in review workflow
enum UnifiedFeedbackStatus {
  /// Just submitted by user, awaiting review
  open('open'),

  /// Admin is currently reviewing
  reviewing('reviewing'),

  /// Admin reviewed and marked as resolved/fixed
  resolved('resolved'),

  /// Admin dismissed as not actionable
  dismissed('dismissed'),

  /// Automatically closed (e.g., expired, duplicate)
  closed('closed');

  const UnifiedFeedbackStatus(this.value);

  /// Firestore value (used in documents)
  final String value;

  /// Create from Firestore string value
  static UnifiedFeedbackStatus fromString(String value) {
    return UnifiedFeedbackStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => UnifiedFeedbackStatus.open,
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case UnifiedFeedbackStatus.open:
        return 'Open';
      case UnifiedFeedbackStatus.reviewing:
        return 'Reviewing';
      case UnifiedFeedbackStatus.resolved:
        return 'Resolved';
      case UnifiedFeedbackStatus.dismissed:
        return 'Dismissed';
      case UnifiedFeedbackStatus.closed:
        return 'Closed';
    }
  }

  /// Color for UI display (semantic colors)
  String get colorKey {
    switch (this) {
      case UnifiedFeedbackStatus.open:
        return 'warning'; // context.colors.warning
      case UnifiedFeedbackStatus.reviewing:
        return 'info'; // context.colors.tertiary
      case UnifiedFeedbackStatus.resolved:
        return 'success'; // context.colors.success
      case UnifiedFeedbackStatus.dismissed:
        return 'error'; // context.colors.error
      case UnifiedFeedbackStatus.closed:
        return 'onSurface'; // context.colors.onSurface (neutral)
    }
  }

  /// Whether this status indicates active/actionable feedback
  bool get isActionable {
    return this == UnifiedFeedbackStatus.open ||
        this == UnifiedFeedbackStatus.reviewing;
  }

  /// Whether this status indicates feedback is completed
  bool get isCompleted {
    return this == UnifiedFeedbackStatus.resolved ||
        this == UnifiedFeedbackStatus.dismissed ||
        this == UnifiedFeedbackStatus.closed;
  }
}

/// Severity level for feedback prioritization
enum FeedbackSeverity {
  /// Low priority - cosmetic issues, minor suggestions
  low(1, 'low'),

  /// Medium priority - usability issues, moderate impact
  medium(2, 'medium'),

  /// High priority - functional problems, major impact
  high(3, 'high'),

  /// Critical priority - app crashes, data loss, security issues
  critical(4, 'critical');

  const FeedbackSeverity(this.level, this.value);

  /// Numeric level (1-4) for sorting/filtering
  final int level;

  /// Firestore value (used in documents)
  final String value;

  /// Create from Firestore string value
  static FeedbackSeverity fromString(String value) {
    return FeedbackSeverity.values.firstWhere(
      (severity) => severity.value == value,
      orElse: () => FeedbackSeverity.medium,
    );
  }

  /// Create from numeric level
  static FeedbackSeverity fromLevel(int level) {
    return FeedbackSeverity.values.firstWhere(
      (severity) => severity.level == level,
      orElse: () => FeedbackSeverity.medium,
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case FeedbackSeverity.low:
        return 'Low';
      case FeedbackSeverity.medium:
        return 'Medium';
      case FeedbackSeverity.high:
        return 'High';
      case FeedbackSeverity.critical:
        return 'Critical';
    }
  }

  /// Color for UI display
  String get colorKey {
    switch (this) {
      case FeedbackSeverity.low:
        return 'success'; // context.colors.success
      case FeedbackSeverity.medium:
        return 'warning'; // context.colors.warning
      case FeedbackSeverity.high:
        return 'error'; // context.colors.error
      case FeedbackSeverity.critical:
        return 'error'; // context.colors.error (same as high, but bolder UI)
    }
  }

  /// Icon for UI display
  String get icon {
    switch (this) {
      case FeedbackSeverity.low:
        return '🟢';
      case FeedbackSeverity.medium:
        return '🟡';
      case FeedbackSeverity.high:
        return '🟠';
      case FeedbackSeverity.critical:
        return '🔴';
    }
  }
}
