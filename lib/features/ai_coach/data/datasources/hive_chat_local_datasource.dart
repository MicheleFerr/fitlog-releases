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

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/conversation_tree.dart';

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
  static const String _treeBoxName = 'chat_trees'; // NEW: Tree persistence
  static const String _prefsBoxName = 'chat_prefs'; // NEW: User preferences (onboarding, etc.)
  static const int _maxMessagesPerUser = 500; // Prevent unbounded growth

  Box<Map<dynamic, dynamic>>? _box;
  Box<Map<dynamic, dynamic>>? _treeBox; // NEW: Tree box
  Box<Map<dynamic, dynamic>>? _prefsBox; // NEW: Preferences box

  /// Initialize Hive box (call once at app startup)
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Map>(_boxName);
    }
    if (_treeBox == null || !_treeBox!.isOpen) {
      _treeBox = await Hive.openBox<Map>(_treeBoxName);
    }
    if (_prefsBox == null || !_prefsBox!.isOpen) {
      _prefsBox = await Hive.openBox<Map>(_prefsBoxName);
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

  // ========================================================================
  // Conversation Tree Persistence (NEW)
  // ========================================================================

  /// Save conversation tree to Hive cache
  ///
  /// **Parameters**:
  /// - `tree`: ConversationTree to save
  ///
  /// **Storage Key**: `tree_{userId}`
  Future<void> saveTree(ConversationTree tree) async {
    await _ensureInitialized();

    final key = 'tree_${tree.userId}';
    final json = tree.toJson();

    await _treeBox!.put(key, json);
  }

  /// Load conversation tree from Hive cache
  ///
  /// **Parameters**:
  /// - `userId`: User ID to load tree for
  ///
  /// **Returns**: ConversationTree (empty if no tree exists)
  Future<ConversationTree> loadTree({required String userId}) async {
    await _ensureInitialized();

    final key = 'tree_$userId';
    final json = _treeBox!.get(key);

    if (json == null) {
      // No tree exists → return empty tree
      return ConversationTree.empty(userId: userId);
    }

    return ConversationTree.fromJson(Map<String, dynamic>.from(json));
  }

  /// Watch conversation tree for real-time updates
  ///
  /// **Parameters**:
  /// - `userId`: User ID to watch
  ///
  /// **Returns**: Stream of ConversationTree
  ///
  /// **Behavior**: Emits latest tree whenever it changes in Hive
  Stream<ConversationTree> watchTree({required String userId}) async* {
    await _ensureInitialized();

    final key = 'tree_$userId';

    // Emit initial tree
    yield await loadTree(userId: userId);

    // Watch for changes
    await for (final event in _treeBox!.watch(key: key)) {
      if (event.value == null) {
        // Tree deleted → emit empty
        yield ConversationTree.empty(userId: userId);
      } else {
        // Tree updated → emit new tree
        final json = Map<String, dynamic>.from(event.value as Map);
        yield ConversationTree.fromJson(json);
      }
    }
  }

  /// Clear conversation tree from Hive cache
  ///
  /// **Parameters**:
  /// - `userId`: User ID to clear tree for
  Future<void> clearTree({required String userId}) async {
    await _ensureInitialized();

    final key = 'tree_$userId';
    await _treeBox!.delete(key);
  }

  // ========================================================================
  // Onboarding & User Preferences (NEW - Phase 2.1)
  // ========================================================================

  /// Check if user has seen onboarding flow
  ///
  /// **Parameters**:
  /// - `userId`: User ID to check
  ///
  /// **Returns**: true if user has completed onboarding, false otherwise
  ///
  /// **Storage Key**: `onboarding_{userId}`
  Future<bool> hasSeenOnboarding({required String userId}) async {
    await _ensureInitialized();

    final key = 'onboarding_$userId';
    final value = _prefsBox!.get(key);

    return value?['seen'] == true;
  }

  /// Mark onboarding as seen for user
  ///
  /// **Parameters**:
  /// - `userId`: User ID to mark as seen
  ///
  /// **Side Effects**: Writes to preferences box
  ///
  /// **Use Case**: Call when user completes onboarding flow
  Future<void> markOnboardingSeen({required String userId}) async {
    await _ensureInitialized();

    final key = 'onboarding_$userId';
    await _prefsBox!.put(key, {
      'seen': true,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Close Hive box (call at app shutdown)
  Future<void> close() async {
    await _box?.close();
    _box = null;
    await _treeBox?.close();
    _treeBox = null;
    await _prefsBox?.close();
    _prefsBox = null;
  }

  /// Ensure Hive boxes are initialized
  Future<void> _ensureInitialized() async {
    await init();
  }
}
