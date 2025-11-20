/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/datasources
/// 🎯 Feature: ai_coach
/// 🔧 Type: local_datasource
///
/// Hive Chat Local Datasource - Offline message persistence
///
/// **Purpose**: Cache conversation messages locally with Hive
///
/// **Responsibilities**:
/// - Save messages to Hive box (instant local persistence)
/// - Retrieve conversation history (faster than Firebase)
/// - Watch for real-time updates (reactive streams)
/// - Clear conversation history
/// - Manage storage limits (max 500 messages per user)
///
/// **Hive Box Structure**:
/// - Box name: 'chat_messages'
/// - Key format: '{userId}_{timestamp_ms}'
/// - Value: JSON-encoded AIMessage
///
/// **Performance**:
/// - Write: ~1ms (instant)
/// - Read: ~2ms (faster than Firebase)
/// - Watch: Real-time updates via Stream
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';

/// Local datasource for chat message persistence
///
/// **Usage**:
/// ```dart
/// final datasource = HiveChatLocalDatasource();
/// await datasource.init(); // Initialize Hive box
///
/// // Save message
/// await datasource.saveMessage(userId: 'user123', message: aiMessage);
///
/// // Get history
/// final messages = await datasource.getMessages(userId: 'user123', limit: 50);
///
/// // Watch for updates
/// datasource.watchMessages(userId: 'user123').listen((messages) {
///   updateUI(messages);
/// });
/// ```
class HiveChatLocalDatasource {
  static const String _boxName = 'chat_messages';
  static const int _maxMessagesPerUser = 500; // Prevent unbounded growth

  Box<Map<dynamic, dynamic>>? _box;

  /// Initialize Hive box (call once at app startup)
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Map>(_boxName);
    }
  }

  /// Save message to Hive cache
  ///
  /// **Parameters**:
  /// - `userId`: User ID for namespacing
  /// - `message`: AIMessage to save
  ///
  /// **Side Effects**:
  /// - Writes to Hive box (~1ms)
  /// - Auto-prunes old messages if > 500 per user
  ///
  /// **Use Case**: Save message immediately after sending/receiving
  Future<void> saveMessage({
    required String userId,
    required AIMessage message,
  }) async {
    await init(); // Ensure box is open

    // Generate unique key: userId_timestamp_ms
    final key = '${userId}_${message.timestamp.millisecondsSinceEpoch}';

    // Save as JSON map
    await _box!.put(key, message.toJson());

    // Auto-prune if exceeds limit
    await _pruneOldMessagesIfNeeded(userId);
  }

  /// Get paginated conversation history
  ///
  /// **Parameters**:
  /// - `userId`: User ID to fetch messages for
  /// - `limit`: Max messages to return (default: 50)
  /// - `beforeTimestamp`: Optional pagination cursor
  ///
  /// **Returns**: List<AIMessage> in reverse chronological order (newest first)
  ///
  /// **Performance**: ~2ms for 50 messages
  ///
  /// **Use Case**: Load chat history when opening conversation screen
  Future<List<AIMessage>> getMessages({
    required String userId,
    int limit = 50,
    DateTime? beforeTimestamp,
  }) async {
    await init();

    // Get all keys for this user
    final userPrefix = '${userId}_';
    final allKeys = _box!.keys.where((key) => key.toString().startsWith(userPrefix));

    // Parse keys and filter by timestamp cursor
    final filteredKeys = allKeys.where((key) {
      if (beforeTimestamp == null) return true;

      final timestampStr = key.toString().split('_').last;
      final timestamp = int.tryParse(timestampStr);
      if (timestamp == null) return false;

      return timestamp < beforeTimestamp.millisecondsSinceEpoch;
    }).toList();

    // Sort by timestamp descending (newest first)
    filteredKeys.sort((a, b) {
      final aTime = int.parse(a.toString().split('_').last);
      final bTime = int.parse(b.toString().split('_').last);
      return bTime.compareTo(aTime); // Descending
    });

    // Take first N messages (limit)
    final limitedKeys = filteredKeys.take(limit);

    // Convert to AIMessage objects
    final messages = <AIMessage>[];
    for (final key in limitedKeys) {
      final json = _box!.get(key);
      if (json != null) {
        try {
          messages.add(AIMessage.fromJson(Map<String, dynamic>.from(json)));
        } catch (e) {
          // Skip corrupted messages
          continue;
        }
      }
    }

    return messages;
  }

  /// Watch conversation for real-time updates
  ///
  /// **Parameters**:
  /// - `userId`: User ID to watch
  ///
  /// **Returns**: Stream<List<AIMessage>> (emits on every add/update)
  ///
  /// **Use Case**: Reactive chat UI (auto-scroll to new messages)
  Stream<List<AIMessage>> watchMessages({
    required String userId,
  }) async* {
    await init();

    // Initial load
    yield await getMessages(userId: userId);

    // Watch for changes
    await for (final _ in _box!.watch()) {
      // Re-fetch messages on any change
      yield await getMessages(userId: userId);
    }
  }

  /// Clear all conversation history for user
  ///
  /// **Parameters**:
  /// - `userId`: User ID to clear history for
  ///
  /// **Side Effects**:
  /// - Deletes all messages from Hive box
  /// - Triggers watch stream update
  ///
  /// **Use Case**: "Start Fresh" button in chat settings
  Future<void> clearHistory({
    required String userId,
  }) async {
    await init();

    // Get all keys for this user
    final userPrefix = '${userId}_';
    final keysToDelete = _box!.keys
        .where((key) => key.toString().startsWith(userPrefix))
        .toList();

    // Delete all messages
    await _box!.deleteAll(keysToDelete);
  }

  /// Get message count for user
  ///
  /// **Use Case**: Display message count in settings
  Future<int> getMessageCount({
    required String userId,
  }) async {
    await init();

    final userPrefix = '${userId}_';
    return _box!.keys.where((key) => key.toString().startsWith(userPrefix)).length;
  }

  /// Prune old messages if exceeds limit
  ///
  /// **Strategy**: Keep newest 500 messages, delete older ones
  ///
  /// **Performance**: ~10ms for 1000 messages
  Future<void> _pruneOldMessagesIfNeeded(String userId) async {
    final messageCount = await getMessageCount(userId: userId);

    if (messageCount <= _maxMessagesPerUser) {
      return; // No pruning needed
    }

    // Get all messages sorted by timestamp
    final messages = await getMessages(
      userId: userId,
      limit: messageCount, // Get all
    );

    // Keep newest 500, delete rest
    final messagesToDelete = messages.skip(_maxMessagesPerUser);

    for (final message in messagesToDelete) {
      final key = '${userId}_${message.timestamp.millisecondsSinceEpoch}';
      await _box!.delete(key);
    }
  }

  /// Close Hive box (call at app shutdown)
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
