import '../entities/unified_notification.dart';
import '../entities/unified_notification_state.dart';
import '../repositories/notification_repository.dart';

/// Use case for scheduling notifications with business logic validation
/// Handles smart scheduling, duplicate prevention, and preference checks
class ScheduleNotificationUseCase {
  final NotificationRepository _repository;

  ScheduleNotificationUseCase(this._repository);

  Future<ScheduleNotificationResult> execute(ScheduleNotificationParams params) async {
    try {
      // 1. Validate notification parameters
      final validationResult = await _validateNotification(params);
      if (!validationResult.isValid) {
        return ScheduleNotificationResult.failure(validationResult.error!);
      }

      // 2. Check user preferences
      final preferences = await _repository.getPreferences();
      if (!await _isNotificationAllowed(params, preferences)) {
        return ScheduleNotificationResult.blocked('Notification blocked by user preferences');
      }

      // 3. Apply smart scheduling logic
      final optimizedNotification = await _optimizeScheduling(params, preferences);

      // 4. Check for duplicates
      if (await _isDuplicateNotification(optimizedNotification)) {
        return ScheduleNotificationResult.duplicate('Duplicate notification prevented');
      }

      // 5. Schedule the notification
      final notificationId = await _repository.scheduleNotification(optimizedNotification);

      return ScheduleNotificationResult.success(notificationId, optimizedNotification);

    } catch (error) {
      return ScheduleNotificationResult.failure('Failed to schedule notification: $error');
    }
  }

  Future<ValidationResult> _validateNotification(ScheduleNotificationParams params) async {
    // Basic validation
    if (params.title.trim().isEmpty) {
      return ValidationResult.invalid('Title cannot be empty');
    }

    if (params.body.trim().isEmpty) {
      return ValidationResult.invalid('Body cannot be empty');
    }

    // Scheduled time validation
    if (params.scheduledTime != null && params.scheduledTime!.isBefore(DateTime.now())) {
      return ValidationResult.invalid('Cannot schedule notification in the past');
    }

    // Type-specific validation
    switch (params.type) {
      case NotificationType.timerComplete:
        if (params.workoutId == null && params.exerciseId == null) {
          return ValidationResult.invalid('Timer notifications require workout or exercise context');
        }
        break;
      case NotificationType.workoutReminder:
        if (params.scheduledTime == null) {
          return ValidationResult.invalid('Workout reminders must have a scheduled time');
        }
        break;
      case NotificationType.emergency:
        // Critical notifications always allowed
        break;
      default:
        break;
    }

    return ValidationResult.valid();
  }

  Future<bool> _isNotificationAllowed(ScheduleNotificationParams params, NotificationPreferences preferences) async {
    // Check if notifications are globally enabled
    if (!preferences.enabled) {
      return params.type == NotificationType.emergency; // Only emergency notifications when disabled
    }

    // Check type-specific preferences
    if (!(preferences.typePreferences[params.type] ?? true)) {
      return false;
    }

    // Check quiet hours
    if (params.scheduledTime != null && _isInQuietHours(params.scheduledTime!, preferences.quietHours)) {
      return params.priority == NotificationPriority.critical || params.type == NotificationType.emergency;
    }

    return true;
  }

  bool _isInQuietHours(DateTime scheduledTime, List<TimeRange> quietHours) {
    final timeOfDay = TimeOfDay(hour: scheduledTime.hour, minute: scheduledTime.minute);
    
    for (final range in quietHours) {
      if (_isTimeInRange(timeOfDay, range)) {
        return true;
      }
    }
    
    return false;
  }

  bool _isTimeInRange(TimeOfDay time, TimeRange range) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = range.start.hour * 60 + range.start.minute;
    final endMinutes = range.end.hour * 60 + range.end.minute;

    if (startMinutes <= endMinutes) {
      // Same day range
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Overnight range
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }

  Future<UnifiedNotification> _optimizeScheduling(ScheduleNotificationParams params, NotificationPreferences preferences) async {
    var scheduledTime = params.scheduledTime ?? DateTime.now();

    // Apply smart scheduling based on user preferences and behavior
    switch (params.type) {
      case NotificationType.workoutReminder:
        // Optimize workout reminders based on user's typical workout times
        scheduledTime = await _optimizeWorkoutReminderTime(scheduledTime, params.userId);
        break;
      case NotificationType.restReminder:
        // Ensure minimum rest time has passed
        scheduledTime = await _optimizeRestReminderTime(scheduledTime, params.userId);
        break;
      default:
        break;
    }

    // Create the optimized notification
    return UnifiedNotification(
      type: params.type,
      title: params.title,
      body: params.body,
      scheduledTime: scheduledTime,
      priority: params.priority,
      deliveryMethod: params.deliveryMethod,
      payload: params.payload,
      imageUrl: params.imageUrl,
      soundName: params.soundName ?? preferences.soundPreferences.name,
      actions: params.actions,
      userId: params.userId,
      workoutId: params.workoutId,
      exerciseId: params.exerciseId,
      tags: params.tags,
      personalization: params.personalization,
      iosConfig: params.iosConfig,
      androidConfig: params.androidConfig,
    );
  }

  Future<DateTime> _optimizeWorkoutReminderTime(DateTime requestedTime, String? userId) async {
    // TODO: Implement ML-based optimization based on user's workout history
    // For now, return the requested time
    return requestedTime;
  }

  Future<DateTime> _optimizeRestReminderTime(DateTime requestedTime, String? userId) async {
    // TODO: Implement smart rest timing based on workout intensity
    // For now, return the requested time
    return requestedTime;
  }

  Future<bool> _isDuplicateNotification(UnifiedNotification notification) async {
    // Check for duplicate notifications within a time window
    final existingNotifications = await _repository.getAllNotifications(
      since: DateTime.now().subtract(const Duration(minutes: 5)),
      types: [notification.type],
    );

    return existingNotifications.any((existing) =>
      existing.title == notification.title &&
      existing.body == notification.body &&
      existing.workoutId == notification.workoutId &&
      existing.exerciseId == notification.exerciseId
    );
  }
}

class ScheduleNotificationParams {
  final NotificationType type;
  final String title;
  final String body;
  final DateTime? scheduledTime;
  final NotificationPriority priority;
  final NotificationDeliveryMethod deliveryMethod;
  final Map<String, dynamic>? payload;
  final String? imageUrl;
  final String? soundName;
  final List<NotificationAction>? actions;
  final String? userId;
  final String? workoutId;
  final String? exerciseId;
  final List<String>? tags;
  final NotificationPersonalization? personalization;
  final IOSNotificationConfig? iosConfig;
  final AndroidNotificationConfig? androidConfig;

  ScheduleNotificationParams({
    required this.type,
    required this.title,
    required this.body,
    this.scheduledTime,
    this.priority = NotificationPriority.normal,
    this.deliveryMethod = NotificationDeliveryMethod.local,
    this.payload,
    this.imageUrl,
    this.soundName,
    this.actions,
    this.userId,
    this.workoutId,
    this.exerciseId,
    this.tags,
    this.personalization,
    this.iosConfig,
    this.androidConfig,
  });
}

class ScheduleNotificationResult {
  final bool isSuccess;
  final String? notificationId;
  final UnifiedNotification? notification;
  final String? error;
  final ScheduleNotificationStatus status;

  ScheduleNotificationResult._({
    required this.isSuccess,
    this.notificationId,
    this.notification,
    this.error,
    required this.status,
  });

  factory ScheduleNotificationResult.success(String notificationId, UnifiedNotification notification) {
    return ScheduleNotificationResult._(
      isSuccess: true,
      notificationId: notificationId,
      notification: notification,
      status: ScheduleNotificationStatus.scheduled,
    );
  }

  factory ScheduleNotificationResult.failure(String error) {
    return ScheduleNotificationResult._(
      isSuccess: false,
      error: error,
      status: ScheduleNotificationStatus.failed,
    );
  }

  factory ScheduleNotificationResult.blocked(String reason) {
    return ScheduleNotificationResult._(
      isSuccess: false,
      error: reason,
      status: ScheduleNotificationStatus.blocked,
    );
  }

  factory ScheduleNotificationResult.duplicate(String reason) {
    return ScheduleNotificationResult._(
      isSuccess: false,
      error: reason,
      status: ScheduleNotificationStatus.duplicate,
    );
  }
}

enum ScheduleNotificationStatus {
  scheduled,
  failed,
  blocked,
  duplicate,
}

class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult._(this.isValid, this.error);

  factory ValidationResult.valid() => ValidationResult._(true, null);
  factory ValidationResult.invalid(String error) => ValidationResult._(false, error);
}