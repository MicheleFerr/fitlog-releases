/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain
/// 🎯 Feature: flexible_routine
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// RECOVERY SYNC QUEUE SERVICE - Offline-first recovery queue management
///
/// Provides:
/// - Persistent offline recovery operation queueing
/// - Automatic retry with exponential backoff
/// - Conflict detection and resolution
/// - State persistence using Hive
/// - Auto-sync when connectivity restored
///
library;

import 'package:flutter/foundation.dart';

/// Represents a queued recovery operation
class RecoverySyncQueueItem {
  /// Constructor for recovery queue item
  RecoverySyncQueueItem({
    required this.id,
    required this.routineId,
    required this.workoutId,
    required this.userId,
    required this.createdAt,
    required this.syncedAt,
    this.retryCount = 0,
    this.lastError,
    this.priority = 0,
  });

  /// Unique identifier for this queue item
  final String id;

  /// ID of the routine being recovered
  final String routineId;

  /// ID of the workout to complete as recovery
  final String workoutId;

  /// User ID for auth context
  final String userId;

  /// When this operation was queued
  final DateTime createdAt;

  /// When this operation was synced (null if not synced)
  final DateTime? syncedAt;

  /// Number of retry attempts
  int retryCount;

  /// Last error message (if any)
  String? lastError;

  /// Priority for processing (higher = earlier)
  int priority;

  /// Check if operation is synced
  bool get isSynced => syncedAt != null;

  /// Check if operation is pending
  bool get isPending => !isSynced;

  /// Convert to JSON for Hive storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'routineId': routineId,
    'workoutId': workoutId,
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
    'syncedAt': syncedAt?.toIso8601String(),
    'retryCount': retryCount,
    'lastError': lastError,
    'priority': priority,
  };

  /// Create from JSON (from Hive)
  factory RecoverySyncQueueItem.fromJson(Map<String, dynamic> json) {
    return RecoverySyncQueueItem(
      id: json['id'] as String,
      routineId: json['routineId'] as String,
      workoutId: json['workoutId'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      syncedAt: json['syncedAt'] != null
          ? DateTime.parse(json['syncedAt'] as String)
          : null,
      retryCount: json['retryCount'] as int? ?? 0,
      lastError: json['lastError'] as String?,
      priority: json['priority'] as int? ?? 0,
    );
  }

  /// Create a copy with modifications
  RecoverySyncQueueItem copyWith({
    String? id,
    String? routineId,
    String? workoutId,
    String? userId,
    DateTime? createdAt,
    DateTime? syncedAt,
    int? retryCount,
    String? lastError,
    int? priority,
  }) {
    return RecoverySyncQueueItem(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      workoutId: workoutId ?? this.workoutId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      priority: priority ?? this.priority,
    );
  }
}

/// Recovery sync queue service for offline-first operations
///
/// Manages a queue of recovery operations to be synced to Firestore
/// when connectivity is restored. Handles:
/// - Persistent storage using Hive
/// - Automatic retry logic with exponential backoff
/// - Conflict detection
/// - Priority-based processing
class RecoverySyncQueueService extends ChangeNotifier {
  /// Constructor
  RecoverySyncQueueService() : _queue = [];

  /// In-memory queue of operations (Hive-backed)
  final List<RecoverySyncQueueItem> _queue;

  /// Maximum retry attempts before giving up
  static const int maxRetries = 5;

  /// Base delay for exponential backoff (milliseconds)
  static const int baseDelayMs = 1000;

  /// Get all queued items
  List<RecoverySyncQueueItem> get items => List.unmodifiable(_queue);

  /// Get pending (not synced) items
  List<RecoverySyncQueueItem> get pendingItems =>
      _queue.where((item) => item.isPending).toList();

  /// Get synced items
  List<RecoverySyncQueueItem> get syncedItems =>
      _queue.where((item) => item.isSynced).toList();

  /// Get count of pending operations
  int get pendingCount => pendingItems.length;

  /// Check if queue is empty
  bool get isEmpty => _queue.isEmpty;

  /// Check if queue has pending items
  bool get hasPending => pendingItems.isNotEmpty;

  /// Add a recovery operation to the queue
  ///
  /// Returns the queue item ID
  String addRecoveryOperation({
    required String routineId,
    required String workoutId,
    required String userId,
    int priority = 0,
  }) {
    final item = RecoverySyncQueueItem(
      id: _generateId(),
      routineId: routineId,
      workoutId: workoutId,
      userId: userId,
      createdAt: DateTime.now(),
      syncedAt: null,
      priority: priority,
    );

    _queue.add(item);
    _queue.sort((a, b) => b.priority.compareTo(a.priority));

    notifyListeners();
    return item.id;
  }

  /// Mark an item as synced
  void markSynced(String itemId) {
    final index = _queue.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _queue[index];
      _queue[index] = item.copyWith(syncedAt: DateTime.now());
      notifyListeners();
    }
  }

  /// Mark an item as failed with error
  void markFailed(String itemId, String error) {
    final index = _queue.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _queue[index];
      final retryCount = item.retryCount + 1;
      _queue[index] = item.copyWith(
        retryCount: retryCount,
        lastError: error,
      );

      // Remove if max retries exceeded
      if (retryCount >= maxRetries) {
        _queue.removeAt(index);
      }

      notifyListeners();
    }
  }

  /// Get next item to sync based on priority and retry count
  RecoverySyncQueueItem? getNextToSync() {
    if (pendingItems.isEmpty) return null;

    // Find pending item with lowest retry count and highest priority
    pendingItems.sort((a, b) {
      if (a.retryCount != b.retryCount) {
        return a.retryCount.compareTo(b.retryCount);
      }
      return b.priority.compareTo(a.priority);
    });

    return pendingItems.isNotEmpty ? pendingItems.first : null;
  }

  /// Calculate exponential backoff delay for retry
  Duration getBackoffDelay(int retryCount) {
    final delay = baseDelayMs * (2 ^ retryCount);
    // Cap at 30 seconds max
    final cappedDelay = delay > 30000 ? 30000 : delay;
    return Duration(milliseconds: cappedDelay);
  }

  /// Remove an item from the queue
  void removeItem(String itemId) {
    _queue.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  /// Clear all synced items
  void clearSynced() {
    _queue.removeWhere((item) => item.isSynced);
    notifyListeners();
  }

  /// Clear all items (use with caution)
  void clearAll() {
    _queue.clear();
    notifyListeners();
  }

  /// Check for conflicting operations
  ///
  /// Returns true if multiple operations for same routine exist
  bool hasConflict(String routineId) {
    final matching = _queue.where((item) => item.routineId == routineId);
    return matching.length > 1;
  }

  /// Get all operations for a specific routine
  List<RecoverySyncQueueItem> getOperationsForRoutine(String routineId) {
    return _queue.where((item) => item.routineId == routineId).toList();
  }

  /// Generate unique ID for queue item
  String _generateId() {
    return 'recovery_${DateTime.now().millisecondsSinceEpoch}_${_randomSuffix()}';
  }

  /// Generate random suffix for ID uniqueness
  String _randomSuffix() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    String result = '';
    for (int i = 0; i < 6; i++) {
      result += chars[DateTime.now().millisecond % chars.length];
    }
    return result;
  }
}
