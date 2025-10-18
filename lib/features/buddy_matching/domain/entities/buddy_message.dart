/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: buddy_matching
/// 🔧 Type: entity
/// 🌍 Localization: N/A - Entity class
/// 🎨 Theme: N/A - Entity class
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: None
/// - Firebase: None
/// - Hive: None
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'buddy_message.freezed.dart';
part 'buddy_message.g.dart';

/// Type of message in buddy chat
enum MessageType {
  text,
  workoutInvite,
  workoutPlan,
  exerciseShare,
  systemNotification;

  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Messaggio';
      case MessageType.workoutInvite:
        return 'Invito Workout';
      case MessageType.workoutPlan:
        return 'Piano Workout';
      case MessageType.exerciseShare:
        return 'Condivisione Esercizio';
      case MessageType.systemNotification:
        return 'Notifica Sistema';
    }
  }
}

@freezed
class BuddyMessage with _$BuddyMessage {
  const factory BuddyMessage({
    required String id,
    required String matchId,
    required String senderId,
    required String receiverId,
    required MessageType type,
    required String content,
    // Metadata for different message types
    Map<String, dynamic>? metadata,
    @Default(false) bool isRead,
    DateTime? readAt,
    @Default(false) bool isDelivered,
    DateTime? deliveredAt,
    @Default(false) bool isEdited,
    DateTime? editedAt,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
    // Reply functionality
    String? replyToMessageId,
    String? replyToContent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BuddyMessage;

  factory BuddyMessage.fromJson(Map<String, dynamic> json) =>
      _$BuddyMessageFromJson(json);

  /// Create a text message
  factory BuddyMessage.text({
    required String matchId,
    required String senderId,
    required String receiverId,
    required String content,
    String? replyToMessageId,
    String? replyToContent,
  }) {
    final now = DateTime.now();
    return BuddyMessage(
      id: '', // Will be set by repository
      matchId: matchId,
      senderId: senderId,
      receiverId: receiverId,
      type: MessageType.text,
      content: content,
      replyToMessageId: replyToMessageId,
      replyToContent: replyToContent,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a workout invite message
  factory BuddyMessage.workoutInvite({
    required String matchId,
    required String senderId,
    required String receiverId,
    required String gymName,
    required DateTime proposedTime,
    String? notes,
  }) {
    final now = DateTime.now();
    return BuddyMessage(
      id: '',
      matchId: matchId,
      senderId: senderId,
      receiverId: receiverId,
      type: MessageType.workoutInvite,
      content: 'Invito workout da $gymName',
      metadata: {
        'gymName': gymName,
        'proposedTime': proposedTime.toIso8601String(),
        'notes': notes,
        'status': 'pending', // pending, accepted, declined
      },
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a workout plan share message
  factory BuddyMessage.workoutPlan({
    required String matchId,
    required String senderId,
    required String receiverId,
    required String workoutName,
    required List<String> exercises,
    String? description,
  }) {
    final now = DateTime.now();
    return BuddyMessage(
      id: '',
      matchId: matchId,
      senderId: senderId,
      receiverId: receiverId,
      type: MessageType.workoutPlan,
      content: 'Piano workout: $workoutName',
      metadata: {
        'workoutName': workoutName,
        'exercises': exercises,
        'description': description,
      },
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a system notification message
  factory BuddyMessage.systemNotification({
    required String matchId,
    required String content,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return BuddyMessage(
      id: '',
      matchId: matchId,
      senderId: 'system',
      receiverId: 'all',
      type: MessageType.systemNotification,
      content: content,
      metadata: metadata,
      isDelivered: true,
      deliveredAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create from Firestore document
  factory BuddyMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return BuddyMessage(
      id: doc.id,
      matchId: data['matchId'],
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      type: MessageType.values.firstWhere(
        (type) => type.name == data['type'],
        orElse: () => MessageType.text,
      ),
      content: data['content'] ?? '',
      metadata: data['metadata'] as Map<String, dynamic>?,
      isRead: data['isRead'] ?? false,
      readAt: data['readAt'] != null
          ? (data['readAt'] as Timestamp).toDate()
          : null,
      isDelivered: data['isDelivered'] ?? false,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      isEdited: data['isEdited'] ?? false,
      editedAt: data['editedAt'] != null
          ? (data['editedAt'] as Timestamp).toDate()
          : null,
      isDeleted: data['isDeleted'] ?? false,
      deletedAt: data['deletedAt'] != null
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
      replyToMessageId: data['replyToMessageId'] as String?,
      replyToContent: data['replyToContent'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}

extension BuddyMessageX on BuddyMessage {
  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'matchId': matchId,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type.name,
      'content': content,
      'metadata': metadata,
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'isDelivered': isDelivered,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'replyToMessageId': replyToMessageId,
      'replyToContent': replyToContent,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Check if message is from system
  bool get isSystemMessage => senderId == 'system';

  /// Check if message is a reply
  bool get isReply => replyToMessageId != null;

  /// Get time since message was sent
  String getTimeAgo() {
    if (createdAt == null) return '';
    
    final diff = DateTime.now().difference(createdAt!);
    
    if (diff.inMinutes < 1) return 'Ora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}g';
    
    return '${createdAt!.day}/${createdAt!.month}';
  }

  /// Get delivery status
  String getDeliveryStatus() {
    if (isDeleted) return 'Eliminato';
    if (isRead) return 'Letto';
    if (isDelivered) return 'Consegnato';
    return 'Invio...';
  }

  /// Check if message can be edited (text messages within 5 minutes)
  bool canEdit() {
    if (type != MessageType.text || isDeleted || createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inMinutes <= 5;
  }

  /// Check if message can be deleted (within 1 hour)
  bool canDelete() {
    if (isDeleted || createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inHours <= 1;
  }

  /// Get workout invite status
  String? getWorkoutInviteStatus() {
    if (type != MessageType.workoutInvite || metadata == null) return null;
    return metadata!['status'] as String?;
  }

  /// Get workout invite proposed time
  DateTime? getWorkoutInviteTime() {
    if (type != MessageType.workoutInvite || metadata == null) return null;
    final timeStr = metadata!['proposedTime'] as String?;
    return timeStr != null ? DateTime.tryParse(timeStr) : null;
  }

  /// Get message preview for chat list
  String getPreview() {
    switch (type) {
      case MessageType.text:
        return content.length > 50 ? '${content.substring(0, 50)}...' : content;
      case MessageType.workoutInvite:
        final status = getWorkoutInviteStatus();
        final statusText = status == 'pending' ? '' : ' ($status)';
        return '$content$statusText';
      case MessageType.workoutPlan:
        return content;
      case MessageType.exerciseShare:
        return content;
      case MessageType.systemNotification:
        return content;
    }
  }

  /// Check if message requires action (like workout invite)
  bool get requiresAction {
    return type == MessageType.workoutInvite && 
           getWorkoutInviteStatus() == 'pending';
  }
}