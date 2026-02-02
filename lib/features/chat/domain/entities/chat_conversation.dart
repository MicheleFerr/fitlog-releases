import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_conversation.freezed.dart';
part 'chat_conversation.g.dart';

/// A conversation between coach and athlete
@freezed
abstract class ChatConversation with _$ChatConversation {
  const factory ChatConversation({
    /// Unique conversation ID (format: {coachId}_{athleteId})
    required String id,

    /// Coach user ID
    required String coachId,

    /// Athlete user ID
    required String athleteId,

    /// Coach display name (denormalized)
    required String coachName,

    /// Athlete display name (denormalized)
    required String athleteName,

    /// Preview of last message (max 100 chars)
    String? lastMessage,

    /// When the last message was sent
    DateTime? lastMessageAt,

    /// Who sent the last message
    String? lastMessageSenderId,

    /// Unread count for coach
    @Default(0) int coachUnreadCount,

    /// Unread count for athlete
    @Default(0) int athleteUnreadCount,

    /// When the conversation was created
    required DateTime createdAt,

    /// When the conversation was last updated
    required DateTime updatedAt,
  }) = _ChatConversation;

  /// Private constructor for instance methods
  const ChatConversation._();

  /// Get unread count for a specific user
  int unreadCountFor(String userId) {
    if (userId == coachId) return coachUnreadCount;
    if (userId == athleteId) return athleteUnreadCount;
    return 0;
  }

  /// Check if user is the coach in this conversation
  bool isCoach(String userId) => userId == coachId;

  /// Check if user is the athlete in this conversation
  bool isAthlete(String userId) => userId == athleteId;

  /// Check if user is a participant
  bool isParticipant(String userId) => userId == coachId || userId == athleteId;

  /// Get the other participant's name
  String otherParticipantName(String myUserId) {
    return myUserId == coachId ? athleteName : coachName;
  }

  /// Get the other participant's ID
  String otherParticipantId(String myUserId) {
    return myUserId == coachId ? athleteId : coachId;
  }

  /// Check if the last message was sent by me
  bool lastMessageFromMe(String myUserId) => lastMessageSenderId == myUserId;

  /// Check if conversation has unread messages for user
  bool hasUnreadFor(String userId) => unreadCountFor(userId) > 0;

  /// Generate conversation ID from coach and athlete IDs
  static String generateId(String coachId, String athleteId) {
    return '${coachId}_$athleteId';
  }

  /// Parse participant IDs from conversation ID
  static (String coachId, String athleteId)? parseId(String conversationId) {
    final parts = conversationId.split('_');
    if (parts.length != 2) return null;
    return (parts[0], parts[1]);
  }

  /// Create from Firestore document
  factory ChatConversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatConversation(
      id: doc.id,
      coachId: data['coachId'] as String? ?? '',
      athleteId: data['athleteId'] as String? ?? '',
      coachName: data['coachName'] as String? ?? '',
      athleteName: data['athleteName'] as String? ?? '',
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: data['lastMessageAt'] is Timestamp
          ? (data['lastMessageAt'] as Timestamp).toDate()
          : data['lastMessageAt'] != null
          ? DateTime.tryParse(data['lastMessageAt'] as String? ?? '')
          : null,
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      coachUnreadCount: data['coachUnreadCount'] as int? ?? 0,
      athleteUnreadCount: data['athleteUnreadCount'] as int? ?? 0,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['createdAt'] as String? ?? '') ??
                DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['updatedAt'] as String? ?? '') ??
                DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'coachId': coachId,
      'athleteId': athleteId,
      'coachName': coachName,
      'athleteName': athleteName,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageAt != null)
        'lastMessageAt': Timestamp.fromDate(lastMessageAt!),
      if (lastMessageSenderId != null)
        'lastMessageSenderId': lastMessageSenderId,
      'coachUnreadCount': coachUnreadCount,
      'athleteUnreadCount': athleteUnreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      _$ChatConversationFromJson(json);
}
