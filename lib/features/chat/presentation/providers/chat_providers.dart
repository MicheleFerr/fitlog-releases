/// Chat Providers
///
/// Riverpod providers for chat functionality.
/// Handles conversations, messages, and unread counts.
///
/// **Layer**: Presentation
/// **Feature**: Chat
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_conversation.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_message.dart';
import 'package:gymbro_flutter_new/features/chat/domain/repositories/chat_repository.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';

// ============================================================
// REPOSITORY PROVIDER
// ============================================================

/// Provider for the chat repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl();
});

// ============================================================
// CONVERSATIONS
// ============================================================

/// Stream provider for all conversations
///
/// Watches conversations for the current user in real-time.
/// Sorted by lastMessageAt (most recent first).
final conversationsProvider = StreamProvider.autoDispose<List<ChatConversation>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchConversations();
});

/// Provider to get or create a conversation
///
/// Usage:
/// ```dart
/// final conversation = await ref.read(getOrCreateConversationProvider({
///   'coachId': coachId,
///   'athleteId': athleteId,
///   'coachName': coachName,
///   'athleteName': athleteName,
/// }).future);
/// ```
final getOrCreateConversationProvider =
    FutureProvider.autoDispose.family<ChatConversation, Map<String, String>>((ref, params) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getOrCreateConversation(
    coachId: params['coachId']!,
    athleteId: params['athleteId']!,
    coachName: params['coachName']!,
    athleteName: params['athleteName']!,
  );
});

/// Provider to get a single conversation by ID
final conversationProvider =
    FutureProvider.autoDispose.family<ChatConversation?, String>((ref, conversationId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getConversation(conversationId);
});

// ============================================================
// MESSAGES
// ============================================================

/// Stream provider for messages in a conversation
///
/// Watches messages in real-time with pagination support.
/// [params] should contain 'conversationId' and optionally 'limit'.
final messagesProvider =
    StreamProvider.autoDispose.family<List<ChatMessage>, String>((ref, conversationId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(
    conversationId: conversationId,
    limit: 50,
  );
});

/// Extended messages provider with pagination
final paginatedMessagesProvider =
    StreamProvider.autoDispose.family<List<ChatMessage>, MessagesPaginationParams>((ref, params) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(
    conversationId: params.conversationId,
    limit: params.limit,
    before: params.before,
  );
});

/// Parameters for paginated messages
class MessagesPaginationParams {
  const MessagesPaginationParams({
    required this.conversationId,
    this.limit = 50,
    this.before,
  });

  final String conversationId;
  final int limit;
  final DateTime? before;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessagesPaginationParams &&
          runtimeType == other.runtimeType &&
          conversationId == other.conversationId &&
          limit == other.limit &&
          before == other.before;

  @override
  int get hashCode => Object.hash(conversationId, limit, before);
}

// ============================================================
// UNREAD COUNT
// ============================================================

/// Stream provider for total unread message count
///
/// Used for badge on navigation tab.
final totalUnreadCountProvider = StreamProvider.autoDispose<int>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchTotalUnreadCount();
});

// ============================================================
// ACTIONS NOTIFIER
// ============================================================

/// Notifier for chat actions (sending messages, marking as read)
final chatActionsProvider = Provider<ChatActionsNotifier>((ref) {
  return ChatActionsNotifier(ref.watch(chatRepositoryProvider));
});

/// Notifier class for chat actions
class ChatActionsNotifier {
  ChatActionsNotifier(this._repository);

  final ChatRepository _repository;

  /// Send a text message
  Future<ChatMessage> sendTextMessage({
    required String conversationId,
    required String text,
  }) async {
    return _repository.sendTextMessage(
      conversationId: conversationId,
      text: text,
    );
  }

  /// Send an image message
  Future<ChatMessage> sendImageMessage({
    required String conversationId,
    required File imageFile,
    String? caption,
  }) async {
    return _repository.sendImageMessage(
      conversationId: conversationId,
      imageFile: imageFile,
      caption: caption,
    );
  }

  /// Send a workout link
  Future<ChatMessage> sendWorkoutLink({
    required String conversationId,
    required WorkoutHistoryDetail workout,
    String? comment,
  }) async {
    return _repository.sendWorkoutLink(
      conversationId: conversationId,
      workout: workout,
      comment: comment,
    );
  }

  /// Mark specific messages as read
  Future<void> markAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    return _repository.markAsRead(
      conversationId: conversationId,
      messageIds: messageIds,
    );
  }

  /// Mark all messages in conversation as read
  Future<void> markAllAsRead(String conversationId) async {
    return _repository.markAllAsRead(conversationId);
  }

  /// Delete a message
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    return _repository.deleteMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }
}
