import 'package:uuid/uuid.dart';

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String emoji;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final NotificationAction? action;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.emoji,
    required this.createdAt,
    this.isRead = false,
    this.data,
    this.action,
  });

  factory AppNotification.create({
    required NotificationType type,
    required String title,
    required String message,
    required String emoji,
    Map<String, dynamic>? data,
    NotificationAction? action,
  }) {
    return AppNotification(
      id: const Uuid().v4(),
      type: type,
      title: title,
      message: message,
      emoji: emoji,
      createdAt: DateTime.now(),
      data: data,
      action: action,
    );
  }

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    String? emoji,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
    NotificationAction? action,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      action: action ?? this.action,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: NotificationType.values.byName(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      action: json['action'] != null 
          ? NotificationAction.fromJson(json['action'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'data': data,
      'action': action?.toJson(),
    };
  }

  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Ora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m fa';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h fa';
    } else {
      return '${difference.inDays}g fa';
    }
  }
}

enum NotificationType {
  aiTip,
  achievement,
  milestone,
  reminder,
  progress,
  social,
  system,
}

class NotificationAction {
  final String label;
  final String route;
  final Map<String, dynamic>? parameters;

  const NotificationAction({
    required this.label,
    required this.route,
    this.parameters,
  });

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      label: json['label'] as String,
      route: json['route'] as String,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'route': route,
      'parameters': parameters,
    };
  }
}