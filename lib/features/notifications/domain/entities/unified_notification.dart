import 'package:uuid/uuid.dart';

/// Core notification entity that consolidates all notification types
/// This replaces the fragmented notification system with a single, unified model
class UnifiedNotification {

  UnifiedNotification({
    String? id,
    required this.type,
    required this.title,
    required this.body,
    DateTime? scheduledTime,
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
    this.status = NotificationDeliveryStatus.pending,
    DateTime? createdAt,
    this.deliveredAt,
    this.readAt,
    this.errorMessage,
    this.retryCount = 0,
    this.localization,
    this.personalization,
    this.iosConfig,
    this.androidConfig,
  }) : 
    id = id ?? const Uuid().v4(),
    scheduledTime = scheduledTime ?? DateTime.now(),
    createdAt = createdAt ?? DateTime.now();
  
  factory UnifiedNotification.fromJson(Map<String, dynamic> json) {
    return UnifiedNotification(
      id: json['id'] as String,
      type: NotificationType.values.byName(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      priority: NotificationPriority.values.byName(json['priority'] as String),
      deliveryMethod: NotificationDeliveryMethod.values.byName(json['deliveryMethod'] as String),
      payload: json['payload'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      soundName: json['soundName'] as String?,
      actions: (json['actions'] as List<dynamic>?)?.map((a) => NotificationAction.fromJson(a as Map<String, dynamic>)).toList(),
      userId: json['userId'] as String?,
      workoutId: json['workoutId'] as String?,
      exerciseId: json['exerciseId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      status: NotificationDeliveryStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt'] as String) : null,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      errorMessage: json['errorMessage'] as String?,
      retryCount: json['retryCount'] as int,
      localization: (json['localization'] as Map<String, dynamic>?)?.cast<String, String>(),
      personalization: json['personalization'] != null ? NotificationPersonalization.fromJson(json['personalization'] as Map<String, dynamic>) : null,
      iosConfig: json['iosConfig'] != null ? IOSNotificationConfig.fromJson(json['iosConfig'] as Map<String, dynamic>) : null,
      androidConfig: json['androidConfig'] != null ? AndroidNotificationConfig.fromJson(json['androidConfig'] as Map<String, dynamic>) : null,
    );
  }
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final NotificationPriority priority;
  final NotificationDeliveryMethod deliveryMethod;
  
  // Content and media
  final Map<String, dynamic>? payload;
  final String? imageUrl;
  final String? soundName;
  final List<NotificationAction>? actions;
  
  // Targeting and context
  final String? userId;
  final String? workoutId;
  final String? exerciseId;
  final List<String>? tags;
  
  // Delivery and tracking
  final NotificationDeliveryStatus status;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String? errorMessage;
  final int retryCount;
  
  // Personalization
  final Map<String, String>? localization;
  final NotificationPersonalization? personalization;
  
  // Platform-specific
  final IOSNotificationConfig? iosConfig;
  final AndroidNotificationConfig? androidConfig;

  // Computed properties
  bool get isPending => status == NotificationDeliveryStatus.pending;
  bool get isDelivered => status == NotificationDeliveryStatus.delivered;
  bool get isFailed => status == NotificationDeliveryStatus.failed;
  bool get isRead => readAt != null;
  bool get isOverdue => DateTime.now().isAfter(scheduledTime) && isPending;
  bool get canRetry => isFailed && retryCount < 3;
  
  Duration get timeToDelivery => scheduledTime.difference(DateTime.now());
  Duration? get deliveryLatency => deliveredAt?.difference(scheduledTime);
  
  // State transitions
  UnifiedNotification markAsDelivered() {
    return copyWith(
      status: NotificationDeliveryStatus.delivered,
      deliveredAt: DateTime.now(),
    );
  }
  
  UnifiedNotification markAsFailed(String error) {
    return copyWith(
      status: NotificationDeliveryStatus.failed,
      errorMessage: error,
    );
  }
  
  UnifiedNotification markAsRead() {
    return copyWith(readAt: DateTime.now());
  }
  
  UnifiedNotification incrementRetry() {
    return copyWith(
      retryCount: retryCount + 1,
      status: NotificationDeliveryStatus.pending,
      scheduledTime: DateTime.now().add(Duration(minutes: retryCount * 5)),
    );
  }

  UnifiedNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? scheduledTime,
    NotificationPriority? priority,
    NotificationDeliveryMethod? deliveryMethod,
    Map<String, dynamic>? payload,
    String? imageUrl,
    String? soundName,
    List<NotificationAction>? actions,
    String? userId,
    String? workoutId,
    String? exerciseId,
    List<String>? tags,
    NotificationDeliveryStatus? status,
    DateTime? createdAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    String? errorMessage,
    int? retryCount,
    Map<String, String>? localization,
    NotificationPersonalization? personalization,
    IOSNotificationConfig? iosConfig,
    AndroidNotificationConfig? androidConfig,
  }) {
    return UnifiedNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      priority: priority ?? this.priority,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      payload: payload ?? this.payload,
      imageUrl: imageUrl ?? this.imageUrl,
      soundName: soundName ?? this.soundName,
      actions: actions ?? this.actions,
      userId: userId ?? this.userId,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      localization: localization ?? this.localization,
      personalization: personalization ?? this.personalization,
      iosConfig: iosConfig ?? this.iosConfig,
      androidConfig: androidConfig ?? this.androidConfig,
    );
  }

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
      'priority': priority.name,
      'deliveryMethod': deliveryMethod.name,
      'payload': payload,
      'imageUrl': imageUrl,
      'soundName': soundName,
      'actions': actions?.map((a) => a.toJson()).toList(),
      'userId': userId,
      'workoutId': workoutId,
      'exerciseId': exerciseId,
      'tags': tags,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'retryCount': retryCount,
      'localization': localization,
      'personalization': personalization?.toJson(),
      'iosConfig': iosConfig?.toJson(),
      'androidConfig': androidConfig?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnifiedNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UnifiedNotification(id: $id, type: $type, title: $title, status: $status, scheduled: $scheduledTime)';
  }
}

// Enums and supporting classes
enum NotificationType {
  timerComplete,
  workoutReminder,
  restReminder,
  achievementUnlocked,
  progressMilestone,
  workoutSummary,
  streakReminder,
  friendActivity,
  coachMessage,
  systemUpdate,
  promotional,
  emergency,
}

enum NotificationPriority {
  low,
  normal,
  high,
  critical,
}

enum NotificationDeliveryMethod {
  local,
  push,
  hybrid,
}

enum NotificationDeliveryStatus {
  pending,
  delivered,
  failed,
  cancelled,
  expired,
}

class NotificationAction {

  NotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.payload,
    this.destructive = false,
  });

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
      destructive: json['destructive'] as bool,
    );
  }
  final String id;
  final String title;
  final String? icon;
  final Map<String, dynamic>? payload;
  final bool destructive;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'payload': payload,
      'destructive': destructive,
    };
  }
}

class NotificationPersonalization {

  NotificationPersonalization({
    this.userName,
    this.preferredLanguage,
    this.timezone,
    this.userData,
  });

  factory NotificationPersonalization.fromJson(Map<String, dynamic> json) {
    return NotificationPersonalization(
      userName: json['userName'] as String?,
      preferredLanguage: json['preferredLanguage'] as String?,
      timezone: json['timezone'] as String?,
      userData: json['userData'] as Map<String, dynamic>?,
    );
  }
  final String? userName;
  final String? preferredLanguage;
  final String? timezone;
  final Map<String, dynamic>? userData;

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'preferredLanguage': preferredLanguage,
      'timezone': timezone,
      'userData': userData,
    };
  }
}

class IOSNotificationConfig {

  IOSNotificationConfig({
    this.critical = false,
    this.volume,
    this.categoryId,
    this.threadId,
    this.targetContentId,
    this.badge,
    this.mutable,
  });

  factory IOSNotificationConfig.fromJson(Map<String, dynamic> json) {
    return IOSNotificationConfig(
      critical: json['critical'] as bool,
      volume: json['volume'] as double?,
      categoryId: json['categoryId'] as String?,
      threadId: json['threadId'] as String?,
      targetContentId: json['targetContentId'] as String?,
      badge: json['badge'] as int?,
      mutable: json['mutable'] as bool?,
    );
  }
  final bool critical;
  final double? volume;
  final String? categoryId;
  final String? threadId;
  final String? targetContentId;
  final int? badge;
  final bool? mutable;

  Map<String, dynamic> toJson() {
    return {
      'critical': critical,
      'volume': volume,
      'categoryId': categoryId,
      'threadId': threadId,
      'targetContentId': targetContentId,
      'badge': badge,
      'mutable': mutable,
    };
  }
}

class AndroidNotificationConfig {

  AndroidNotificationConfig({
    this.channelId,
    this.channelName,
    this.channelDescription,
    this.color,
    this.smallIcon,
    this.largeIcon,
    this.autoCancel,
    this.ongoing,
    this.group,
    this.groupSummary,
  });

  factory AndroidNotificationConfig.fromJson(Map<String, dynamic> json) {
    return AndroidNotificationConfig(
      channelId: json['channelId'] as String?,
      channelName: json['channelName'] as String?,
      channelDescription: json['channelDescription'] as String?,
      color: json['color'] as int?,
      smallIcon: json['smallIcon'] as String?,
      largeIcon: json['largeIcon'] as String?,
      autoCancel: json['autoCancel'] as bool?,
      ongoing: json['ongoing'] as bool?,
      group: json['group'] as String?,
      groupSummary: json['groupSummary'] as bool?,
    );
  }
  final String? channelId;
  final String? channelName;
  final String? channelDescription;
  final int? color;
  final String? smallIcon;
  final String? largeIcon;
  final bool? autoCancel;
  final bool? ongoing;
  final String? group;
  final bool? groupSummary;

  Map<String, dynamic> toJson() {
    return {
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'color': color,
      'smallIcon': smallIcon,
      'largeIcon': largeIcon,
      'autoCancel': autoCancel,
      'ongoing': ongoing,
      'group': group,
      'groupSummary': groupSummary,
    };
  }
}