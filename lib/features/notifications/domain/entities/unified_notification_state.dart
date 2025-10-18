import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';

/// Unified state for the entire notification system
/// Similar to UnifiedTimerState but for notifications management
class UnifiedNotificationState {

  const UnifiedNotificationState({
    required this.notifications,
    required this.deliveryStatus,
    required this.preferences,
    required this.metrics,
    required this.systemStatus,
    required this.lastSyncTime,
    this.error,
    required this.activeFilters,
    required this.sortOrder,
    required this.unreadCount,
    required this.pendingQueue,
    required this.retryQueue,
    required this.scheduledTasks,
  });

  factory UnifiedNotificationState.initial() {
    return UnifiedNotificationState(
      notifications: const [],
      deliveryStatus: const {},
      preferences: NotificationPreferences.defaults(),
      metrics: NotificationMetrics.empty(),
      systemStatus: NotificationSystemStatus.initializing,
      lastSyncTime: DateTime.now(),
      activeFilters: const [],
      sortOrder: NotificationSortOrder.newestFirst,
      unreadCount: 0,
      pendingQueue: const [],
      retryQueue: const [],
      scheduledTasks: const {},
    );
  }
  final List<UnifiedNotification> notifications;
  final Map<String, NotificationDeliveryReceipt> deliveryStatus;
  final NotificationPreferences preferences;
  final NotificationMetrics metrics;
  final NotificationSystemStatus systemStatus;
  final DateTime lastSyncTime;
  final String? error;
  
  // Filters and organization
  final List<NotificationFilter> activeFilters;
  final NotificationSortOrder sortOrder;
  final int unreadCount;
  
  // Batching and queue management
  final List<UnifiedNotification> pendingQueue;
  final List<UnifiedNotification> retryQueue;
  final Map<String, DateTime> scheduledTasks;

  // Computed properties
  bool get isInitialized => systemStatus != NotificationSystemStatus.initializing;
  bool get hasError => error != null;
  bool get hasUnreadNotifications => unreadCount > 0;
  bool get isPending => pendingQueue.isNotEmpty;
  bool get hasRetries => retryQueue.isNotEmpty;
  
  List<UnifiedNotification> get unreadNotifications => 
    notifications.where((n) => !n.isRead).toList();
    
  List<UnifiedNotification> get todayNotifications =>
    notifications.where((n) {
      final today = DateTime.now();
      final notificationDate = n.createdAt;
      return notificationDate.year == today.year &&
             notificationDate.month == today.month &&
             notificationDate.day == today.day;
    }).toList();

  // State transitions
  UnifiedNotificationState addNotification(UnifiedNotification notification) {
    final updatedNotifications = [...notifications, notification];
    final updatedUnreadCount = notification.isRead ? unreadCount : unreadCount + 1;
    
    return copyWith(
      notifications: updatedNotifications,
      unreadCount: updatedUnreadCount,
      lastSyncTime: DateTime.now(),
    );
  }
  
  UnifiedNotificationState updateNotification(UnifiedNotification notification) {
    final updatedNotifications = notifications.map((n) => 
      n.id == notification.id ? notification : n).toList();
    
    // Recalculate unread count
    final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;
    
    return copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
      lastSyncTime: DateTime.now(),
    );
  }
  
  UnifiedNotificationState removeNotification(String notificationId) {
    final notification = notifications.firstWhere((n) => n.id == notificationId);
    final updatedNotifications = notifications.where((n) => n.id != notificationId).toList();
    final updatedUnreadCount = notification.isRead ? unreadCount : unreadCount - 1;
    
    return copyWith(
      notifications: updatedNotifications,
      unreadCount: updatedUnreadCount,
      lastSyncTime: DateTime.now(),
    );
  }
  
  UnifiedNotificationState markAsRead(String notificationId) {
    final updatedNotifications = notifications.map((n) {
      if (n.id == notificationId && !n.isRead) {
        return n.markAsRead();
      }
      return n;
    }).toList();
    
    return copyWith(
      notifications: updatedNotifications,
      unreadCount: unreadCount - 1,
      lastSyncTime: DateTime.now(),
    );
  }
  
  UnifiedNotificationState markAllAsRead() {
    final updatedNotifications = notifications.map((n) => 
      n.isRead ? n : n.markAsRead()).toList();
    
    return copyWith(
      notifications: updatedNotifications,
      unreadCount: 0,
      lastSyncTime: DateTime.now(),
    );
  }
  
  UnifiedNotificationState updateMetrics(NotificationMetrics newMetrics) {
    return copyWith(
      metrics: newMetrics,
      lastSyncTime: DateTime.now(),
    );
  }
  
  UnifiedNotificationState updateSystemStatus(NotificationSystemStatus status) {
    return copyWith(
      systemStatus: status,
      lastSyncTime: DateTime.now(),
    );
  }
  
  UnifiedNotificationState setError(String errorMessage) {
    return copyWith(
      error: errorMessage,
      systemStatus: NotificationSystemStatus.error,
      lastSyncTime: DateTime.now(),
    );
  }
  
  UnifiedNotificationState clearError() {
    return copyWith(
      error: null,
      systemStatus: NotificationSystemStatus.ready,
      lastSyncTime: DateTime.now(),
    );
  }

  UnifiedNotificationState copyWith({
    List<UnifiedNotification>? notifications,
    Map<String, NotificationDeliveryReceipt>? deliveryStatus,
    NotificationPreferences? preferences,
    NotificationMetrics? metrics,
    NotificationSystemStatus? systemStatus,
    DateTime? lastSyncTime,
    String? error,
    List<NotificationFilter>? activeFilters,
    NotificationSortOrder? sortOrder,
    int? unreadCount,
    List<UnifiedNotification>? pendingQueue,
    List<UnifiedNotification>? retryQueue,
    Map<String, DateTime>? scheduledTasks,
  }) {
    return UnifiedNotificationState(
      notifications: notifications ?? this.notifications,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      preferences: preferences ?? this.preferences,
      metrics: metrics ?? this.metrics,
      systemStatus: systemStatus ?? this.systemStatus,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      error: error,
      activeFilters: activeFilters ?? this.activeFilters,
      sortOrder: sortOrder ?? this.sortOrder,
      unreadCount: unreadCount ?? this.unreadCount,
      pendingQueue: pendingQueue ?? this.pendingQueue,
      retryQueue: retryQueue ?? this.retryQueue,
      scheduledTasks: scheduledTasks ?? this.scheduledTasks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnifiedNotificationState && 
           other.lastSyncTime == lastSyncTime &&
           other.unreadCount == unreadCount;
  }

  @override
  int get hashCode => Object.hash(lastSyncTime, unreadCount);

  @override
  String toString() {
    return 'UnifiedNotificationState('
           'notifications: ${notifications.length}, '
           'unread: $unreadCount, '
           'status: $systemStatus, '
           'pending: ${pendingQueue.length})';
  }
}

// Supporting classes and enums
enum NotificationSystemStatus {
  initializing,
  ready,
  syncing,
  error,
  disabled,
}

enum NotificationSortOrder {
  newestFirst,
  oldestFirst,
  priorityHigh,
  unreadFirst,
}

class NotificationDeliveryReceipt {

  NotificationDeliveryReceipt({
    required this.notificationId,
    required this.status,
    required this.timestamp,
    this.errorMessage,
    this.platformData,
  });

  factory NotificationDeliveryReceipt.fromJson(Map<String, dynamic> json) {
    return NotificationDeliveryReceipt(
      notificationId: json['notificationId'] as String,
      status: NotificationDeliveryStatus.values.byName(json['status'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      errorMessage: json['errorMessage'] as String?,
      platformData: json['platformData'] as Map<String, dynamic>?,
    );
  }
  final String notificationId;
  final NotificationDeliveryStatus status;
  final DateTime timestamp;
  final String? errorMessage;
  final Map<String, dynamic>? platformData;

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'errorMessage': errorMessage,
      'platformData': platformData,
    };
  }
}

class NotificationPreferences {

  const NotificationPreferences({
    required this.enabled,
    required this.typePreferences,
    required this.quietHours,
    required this.soundPreferences,
    required this.vibrationEnabled,
    required this.frequency,
    this.language,
  });

  factory NotificationPreferences.defaults() {
    return NotificationPreferences(
      enabled: true,
      typePreferences: {
        for (var type in NotificationType.values) type: true
      },
      quietHours: [
        const TimeRange(start: TimeOfDay(hour: 22, minute: 0), 
                 end: TimeOfDay(hour: 8, minute: 0)),
      ],
      soundPreferences: NotificationSound.defaults(),
      vibrationEnabled: true,
      frequency: NotificationFrequency.normal,
    );
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enabled: json['enabled'] as bool,
      typePreferences: (json['typePreferences'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(NotificationType.values.byName(k), v as bool)),
      quietHours: (json['quietHours'] as List<dynamic>)
          .map((t) => TimeRange.fromJson(t as Map<String, dynamic>))
          .toList(),
      soundPreferences: NotificationSound.fromJson(json['soundPreferences'] as Map<String, dynamic>),
      vibrationEnabled: json['vibrationEnabled'] as bool,
      frequency: NotificationFrequency.values.byName(json['frequency'] as String),
      language: json['language'] as String?,
    );
  }
  final bool enabled;
  final Map<NotificationType, bool> typePreferences;
  final List<TimeRange> quietHours;
  final NotificationSound soundPreferences;
  final bool vibrationEnabled;
  final NotificationFrequency frequency;
  final String? language;

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'typePreferences': typePreferences.map((k, v) => MapEntry(k.name, v)),
      'quietHours': quietHours.map((t) => t.toJson()).toList(),
      'soundPreferences': soundPreferences.toJson(),
      'vibrationEnabled': vibrationEnabled,
      'frequency': frequency.name,
      'language': language,
    };
  }
}

class NotificationMetrics {

  const NotificationMetrics({
    required this.totalScheduled,
    required this.totalDelivered,
    required this.totalFailed,
    required this.totalRead,
    required this.duplicatesPrevented,
    required this.deliveryByType,
    required this.recentErrors,
    this.lastCleanupTime,
    required this.averageSchedulingLatency,
    required this.averageDeliveryLatency,
    required this.batteryImpact,
  });

  factory NotificationMetrics.empty() {
    return const NotificationMetrics(
      totalScheduled: 0,
      totalDelivered: 0,
      totalFailed: 0,
      totalRead: 0,
      duplicatesPrevented: 0,
      deliveryByType: {},
      recentErrors: [],
      averageSchedulingLatency: Duration.zero,
      averageDeliveryLatency: Duration.zero,
      batteryImpact: 0.0,
    );
  }
  final int totalScheduled;
  final int totalDelivered;
  final int totalFailed;
  final int totalRead;
  final int duplicatesPrevented;
  final Map<NotificationType, int> deliveryByType;
  final List<NotificationError> recentErrors;
  final DateTime? lastCleanupTime;
  final Duration averageSchedulingLatency;
  final Duration averageDeliveryLatency;
  final double batteryImpact;

  // Performance indicators
  double get deliveryRate => totalScheduled > 0 ? totalDelivered / totalScheduled : 0.0;
  double get errorRate => totalScheduled > 0 ? totalFailed / totalScheduled : 0.0;
  double get readRate => totalDelivered > 0 ? totalRead / totalDelivered : 0.0;
  bool get isHealthy => deliveryRate > 0.95 && errorRate < 0.05;

  Map<String, dynamic> toJson() {
    return {
      'totalScheduled': totalScheduled,
      'totalDelivered': totalDelivered,
      'totalFailed': totalFailed,
      'totalRead': totalRead,
      'duplicatesPrevented': duplicatesPrevented,
      'deliveryByType': deliveryByType.map((k, v) => MapEntry(k.name, v)),
      'recentErrors': recentErrors.map((e) => e.toJson()).toList(),
      'lastCleanupTime': lastCleanupTime?.toIso8601String(),
      'averageSchedulingLatency': averageSchedulingLatency.inMilliseconds,
      'averageDeliveryLatency': averageDeliveryLatency.inMilliseconds,
      'batteryImpact': batteryImpact,
    };
  }
}

// Supporting classes
class TimeRange {

  const TimeRange({required this.start, required this.end});

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: TimeOfDay(
        hour: json['start']['hour'] as int,
        minute: json['start']['minute'] as int,
      ),
      end: TimeOfDay(
        hour: json['end']['hour'] as int,
        minute: json['end']['minute'] as int,
      ),
    );
  }
  final TimeOfDay start;
  final TimeOfDay end;

  Map<String, dynamic> toJson() {
    return {
      'start': {'hour': start.hour, 'minute': start.minute},
      'end': {'hour': end.hour, 'minute': end.minute},
    };
  }
}

class TimeOfDay {

  const TimeOfDay({required this.hour, required this.minute});
  final int hour;
  final int minute;
}

class NotificationSound {

  const NotificationSound({
    required this.name,
    required this.volume,
    required this.enabled,
  });

  factory NotificationSound.defaults() {
    return const NotificationSound(
      name: 'timer_complete',
      volume: 1.0,
      enabled: true,
    );
  }

  factory NotificationSound.fromJson(Map<String, dynamic> json) {
    return NotificationSound(
      name: json['name'] as String,
      volume: json['volume'] as double,
      enabled: json['enabled'] as bool,
    );
  }
  final String name;
  final double volume;
  final bool enabled;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'volume': volume,
      'enabled': enabled,
    };
  }
}

class NotificationError {

  NotificationError({
    required this.message,
    required this.timestamp,
    this.notificationId,
    this.context,
  });

  factory NotificationError.fromJson(Map<String, dynamic> json) {
    return NotificationError(
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notificationId: json['notificationId'] as String?,
      context: json['context'] as Map<String, dynamic>?,
    );
  }
  final String message;
  final DateTime timestamp;
  final String? notificationId;
  final Map<String, dynamic>? context;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'notificationId': notificationId,
      'context': context,
    };
  }
}

class NotificationFilter {

  NotificationFilter({required this.name, required this.predicate});
  final String name;
  final bool Function(UnifiedNotification) predicate;
}

enum NotificationFrequency {
  low,
  normal,
  high,
}