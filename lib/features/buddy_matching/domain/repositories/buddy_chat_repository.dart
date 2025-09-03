/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: domain
 * 🎯 Feature: buddy_matching
 * 🔧 Type: repository interface
 * 🌍 Localization: N/A - Repository interface
 * 🎨 Theme: N/A - Repository interface
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod: None
 * - Firebase: None (abstract interface)
 * - Hive: None (abstract interface)
 */

import '../entities/buddy_message.dart';

/// Repository interface for buddy chat operations
abstract class BuddyChatRepository {
  // Message Management
  Future<String> sendMessage(BuddyMessage message);
  Future<void> updateMessage(BuddyMessage message);
  Future<void> deleteMessage(String messageId, String userId);
  Future<BuddyMessage?> getMessage(String messageId);

  // Message Streams
  Stream<List<BuddyMessage>> getMatchMessages(String matchId, {
    int limit = 50,
    String? lastMessageId,
  });
  
  Stream<List<BuddyMessage>> getUserRecentChats(String userId, {
    int limit = 20,
  });

  // Message Status
  Future<void> markMessageAsRead(String messageId, String userId);
  Future<void> markMessageAsDelivered(String messageId);
  Future<void> markAllMessagesAsRead(String matchId, String userId);
  
  // Unread Counts
  Future<int> getUnreadMessageCount(String matchId, String userId);
  Future<Map<String, int>> getAllUnreadCounts(String userId);
  Stream<int> watchUnreadMessageCount(String matchId, String userId);

  // Message Search
  Future<List<BuddyMessage>> searchMessages(String matchId, String query, {
    int limit = 20,
  });

  // Typing Indicators
  Future<void> setTyping(String matchId, String userId, bool isTyping);
  Stream<bool> watchTypingStatus(String matchId, String otherUserId);

  // Message Reactions (future feature)
  Future<void> addReaction(String messageId, String userId, String reaction);
  Future<void> removeReaction(String messageId, String userId, String reaction);

  // Media Messages (future feature)
  Future<String> uploadMessageMedia(String matchId, String filePath);
  
  // Message Templates
  Future<List<String>> getMessageTemplates(MessageType type);
  Future<void> saveMessageTemplate(String template, MessageType type);

  // Chat Settings
  Future<void> updateChatSettings(String matchId, String userId, Map<String, dynamic> settings);
  Future<Map<String, dynamic>?> getChatSettings(String matchId, String userId);

  // Message History
  Future<void> clearChatHistory(String matchId, String userId);
  Future<void> exportChatHistory(String matchId, String userId);
}