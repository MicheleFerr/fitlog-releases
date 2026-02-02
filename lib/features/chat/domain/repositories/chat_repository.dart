/// Chat Repository Interface
///
/// Abstract repository for chat operations.
/// Handles conversations and messages between coach and athlete.
///
/// **Layer**: Domain
/// **Feature**: Chat
library;

import 'dart:io';

import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_conversation.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_message.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';

/// Repository interface for chat operations
abstract class ChatRepository {
  // ============================================================
  // CONVERSATIONS
  // ============================================================

  /// Watch all conversations for the current user
  ///
  /// Returns a stream of conversations sorted by lastMessageAt (descending)
  Stream<List<ChatConversation>> watchConversations();

  /// Get or create a conversation between coach and athlete
  ///
  /// If conversation exists, returns it. Otherwise creates new one.
  Future<ChatConversation> getOrCreateConversation({
    required String coachId,
    required String athleteId,
    required String coachName,
    required String athleteName,
  });

  /// Get a single conversation by ID
  Future<ChatConversation?> getConversation(String conversationId);

  // ============================================================
  // MESSAGES
  // ============================================================

  /// Watch messages for a conversation (paginated, real-time)
  ///
  /// [limit] - Number of messages to fetch (default 50)
  /// [before] - Fetch messages before this timestamp (for pagination)
  Stream<List<ChatMessage>> watchMessages({
    required String conversationId,
    int limit = 50,
    DateTime? before,
  });

  /// Send a text message
  Future<ChatMessage> sendTextMessage({
    required String conversationId,
    required String text,
  });

  /// Send an image message (for form check photos)
  ///
  /// Compresses and uploads image to Firebase Storage
  Future<ChatMessage> sendImageMessage({
    required String conversationId,
    required File imageFile,
    String? caption,
  });

  /// Send a workout link message
  ///
  /// Links to a completed workout for context
  Future<ChatMessage> sendWorkoutLink({
    required String conversationId,
    required WorkoutHistoryDetail workout,
    String? comment,
  });

  // ============================================================
  // READ RECEIPTS
  // ============================================================

  /// Mark messages as read
  ///
  /// Updates readAt timestamp and decrements unread count
  Future<void> markAsRead({
    required String conversationId,
    required List<String> messageIds,
  });

  /// Mark all messages in conversation as read
  Future<void> markAllAsRead(String conversationId);

  // ============================================================
  // UNREAD COUNTS
  // ============================================================

  /// Watch total unread count across all conversations
  ///
  /// Used for badge on tab bar
  Stream<int> watchTotalUnreadCount();

  // ============================================================
  // DELETION
  // ============================================================

  /// Soft delete a message
  ///
  /// Sets isDeleted flag, doesn't remove from database
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  });
}

/// Upload progress for image messages
class ChatImageUploadProgress {
  const ChatImageUploadProgress({
    required this.messageId,
    required this.progress,
    required this.status,
    this.errorMessage,
  });

  final String messageId;
  final double progress; // 0.0 to 1.0
  final ChatUploadStatus status;
  final String? errorMessage;
}

/// Upload status for image messages
enum ChatUploadStatus { pending, compressing, uploading, completed, failed }
