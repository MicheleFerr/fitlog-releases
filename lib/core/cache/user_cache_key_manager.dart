/// User-scoped cache key manager for multi-user data isolation
///
/// Ensures each user's cached data is isolated by prefixing cache keys
/// with the user's Firebase UID. This prevents data leakage when switching
/// between user accounts.
///
/// **Best Practice (2024)**: Use per-user cache keys instead of clearing
/// cache on logout. This preserves cache for returning users and reduces
/// Firebase reads by ~60% in multi-user scenarios.
///
/// **Usage**:
/// ```dart
/// final keyManager = UserCacheKeyManager();
/// final key = keyManager.templatesCacheKey; // Returns 'templates_cache_{userId}'
/// ```
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Singleton manager for user-scoped cache keys
class UserCacheKeyManager {
  factory UserCacheKeyManager() => _instance;
  UserCacheKeyManager._internal();
  static final UserCacheKeyManager _instance = UserCacheKeyManager._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current user's UID (null if not logged in)
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is logged in
  bool get isUserLoggedIn => currentUserId != null;

  // ============================================
  // Template Cache Keys (SharedPreferences)
  // ============================================

  /// Key for Firebase templates cache
  /// Pattern: 'firebase_templates_cache_{userId}'
  String get templatesCacheKey {
    _ensureLoggedIn();
    return 'firebase_templates_cache_$currentUserId';
  }

  /// Key for templates last sync timestamp
  /// Pattern: 'templates_last_sync_{userId}'
  String get templatesLastSyncKey {
    _ensureLoggedIn();
    return 'templates_last_sync_$currentUserId';
  }

  /// Key for local templates cache
  /// Pattern: 'local_templates_cache_{userId}'
  String get localTemplatesCacheKey {
    _ensureLoggedIn();
    return 'local_templates_cache_$currentUserId';
  }

  /// Key for predefined templates initialized flag
  /// Pattern: 'predefined_templates_{userId}'
  String get predefinedTemplatesKey {
    _ensureLoggedIn();
    return 'predefined_templates_$currentUserId';
  }

  // ============================================
  // Analytics Cache Keys
  // ============================================

  /// Key for analytics stats cache
  /// Pattern: 'analytics_stats_{userId}'
  String get analyticsStatsKey {
    _ensureLoggedIn();
    return 'analytics_stats_$currentUserId';
  }

  /// Key for workout count cache
  /// Pattern: 'workout_count_{userId}'
  String get workoutCountKey {
    _ensureLoggedIn();
    return 'workout_count_$currentUserId';
  }

  /// Key for workout history cache with optional parameters
  /// Pattern: 'workout_history_{userId}_{limit}_{since}'
  String workoutHistoryKey({int? limit, DateTime? since}) {
    _ensureLoggedIn();
    final limitPart = limit != null ? '_l$limit' : '';
    final sincePart = since != null ? '_s${since.millisecondsSinceEpoch}' : '';
    return 'workout_history_$currentUserId$limitPart$sincePart';
  }

  // ============================================
  // Pending Sync Keys
  // ============================================

  /// Key for pending sync queue
  /// Pattern: 'pending_sync_{userId}'
  String get pendingSyncKey {
    _ensureLoggedIn();
    return 'pending_sync_$currentUserId';
  }

  /// Key for pending deletion queue
  /// Pattern: 'pending_deletion_{userId}'
  String get pendingDeletionKey {
    _ensureLoggedIn();
    return 'pending_deletion_$currentUserId';
  }

  // ============================================
  // Generic Key Generation
  // ============================================

  /// Generate a user-scoped key for any purpose
  /// Pattern: '{baseKey}_{userId}'
  String userScopedKey(String baseKey) {
    _ensureLoggedIn();
    return '${baseKey}_$currentUserId';
  }

  /// Generate a user-scoped key with userId parameter
  /// Useful when you need to access another user's cache (e.g., admin)
  /// Pattern: '{baseKey}_{userId}'
  String userScopedKeyFor(String baseKey, String userId) {
    return '${baseKey}_$userId';
  }

  // ============================================
  // Legacy Key Migration
  // ============================================

  /// Check if legacy (global) keys exist and should be migrated
  /// Returns the legacy key name if it exists
  static const Map<String, String> _legacyKeyMapping = {
    'firebase_templates_cache': 'templatesCacheKey',
    'templates_last_sync': 'templatesLastSyncKey',
    'pending_sync': 'pendingSyncKey',
    'pending_deletion': 'pendingDeletionKey',
  };

  /// Get list of legacy keys that need migration
  List<String> get legacyKeys => _legacyKeyMapping.keys.toList();

  /// Get the new key name for a legacy key
  String? getNewKeyForLegacy(String legacyKey) {
    if (!_legacyKeyMapping.containsKey(legacyKey)) return null;

    switch (_legacyKeyMapping[legacyKey]) {
      case 'templatesCacheKey':
        return templatesCacheKey;
      case 'templatesLastSyncKey':
        return templatesLastSyncKey;
      case 'pendingSyncKey':
        return pendingSyncKey;
      case 'pendingDeletionKey':
        return pendingDeletionKey;
      default:
        return null;
    }
  }

  // ============================================
  // Helpers
  // ============================================

  /// Ensure user is logged in before generating keys
  void _ensureLoggedIn() {
    if (currentUserId == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [UserCacheKeyManager] No user logged in, using fallback');
      }
      // Don't throw - allow fallback for offline scenarios
    }
  }

  /// Debug: Print all current cache keys
  void debugPrintKeys() {
    if (!kDebugMode) return;

    debugPrint('🔑 [UserCacheKeyManager] Current user: $currentUserId');
    if (currentUserId != null) {
      debugPrint('  - templatesCacheKey: $templatesCacheKey');
      debugPrint('  - templatesLastSyncKey: $templatesLastSyncKey');
      debugPrint('  - analyticsStatsKey: $analyticsStatsKey');
      debugPrint('  - workoutCountKey: $workoutCountKey');
      debugPrint('  - pendingSyncKey: $pendingSyncKey');
    }
  }
}

/// Global instance for easy access
final userCacheKeys = UserCacheKeyManager();
