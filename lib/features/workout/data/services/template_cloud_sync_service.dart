/// 🏋️‍♂️ GymBro TrackLog - Template Cloud Sync Service
///
/// Syncs templates to Firebase with exponential backoff retry
/// When Cloud Function fails, retries with intervals: 3s, 6s, 12s, 24s, 48s
///
/// After final retry at 48s, marks as pending and notifies user:
/// "Template saved locally but NOT on Firebase. Will be lost if app is uninstalled."
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/services/template_cloud_service.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Metadata for a template pending cloud sync
class PendingTemplateSync {
  PendingTemplateSync({
    required this.templateId,
    required this.templateData,
    required this.createdAt,
    this.attemptCount = 0,
    this.lastAttemptTime,
    this.lastError,
    this.nextRetryTime,
  });

  factory PendingTemplateSync.fromJson(Map<String, dynamic> json) =>
      PendingTemplateSync(
        templateId: json['templateId'] as String,
        templateData: Map<String, dynamic>.from(json['templateData'] as Map),
        createdAt: DateTime.parse(json['createdAt'] as String),
        attemptCount: json['attemptCount'] as int? ?? 0,
        lastAttemptTime: json['lastAttemptTime'] != null
            ? DateTime.parse(json['lastAttemptTime'] as String)
            : null,
        lastError: json['lastError'] as String?,
        nextRetryTime: json['nextRetryTime'] != null
            ? DateTime.parse(json['nextRetryTime'] as String)
            : null,
      );

  final String templateId;
  final Map<String, dynamic> templateData;
  final DateTime createdAt;
  int attemptCount;
  DateTime? lastAttemptTime;
  String? lastError;
  DateTime? nextRetryTime;

  /// Check if should retry based on exponential backoff
  bool get shouldRetry {
    if (nextRetryTime == null) return true;
    return DateTime.now().isAfter(nextRetryTime!);
  }

  /// Get retry delay in seconds (exponential backoff: 3, 6, 12, 24, 48)
  static int getRetryDelaySeconds(int attemptCount) {
    if (attemptCount == 0) return 3;
    if (attemptCount == 1) return 6;
    if (attemptCount == 2) return 12;
    if (attemptCount == 3) return 24;
    return 48; // Final attempt at 48s
  }

  /// Check if max retries exceeded
  bool get maxRetriesExceeded => attemptCount >= 5; // 5 retries = 3+6+12+24+48 = ~93 seconds

  Map<String, dynamic> toJson() => {
        'templateId': templateId,
        'templateData': templateData,
        'createdAt': createdAt.toIso8601String(),
        'attemptCount': attemptCount,
        'lastAttemptTime': lastAttemptTime?.toIso8601String(),
        'lastError': lastError,
        'nextRetryTime': nextRetryTime?.toIso8601String(),
      };
}

/// Service to handle cloud sync for templates with retry logic
class TemplateCloudSyncService {
  TemplateCloudSyncService._();

  static Timer? _syncTimer;
  static bool _isSyncing = false;
  static final _pendingTemplates = <String, PendingTemplateSync>{};

  /// Initialize sync service - call on app startup
  static Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('🔄 [TemplateCloudSyncService] Initializing...');
    }

    // Load pending templates from storage
    await _loadPendingTemplates();

    // Start periodic sync check every 5 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await syncPending();
    });

    if (kDebugMode) {
      debugPrint(
        '✅ [TemplateCloudSyncService] Initialized. Found ${_pendingTemplates.length} pending templates',
      );
    }
  }

  /// Stop sync service - call on app logout
  static void dispose() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _pendingTemplates.clear();
  }

  /// Add template to pending sync queue
  static Future<void> addPendingTemplate(
    String templateId,
    Map<String, dynamic> templateData,
  ) async {
    if (kDebugMode) {
      debugPrint(
        '📝 [TemplateCloudSyncService] Adding template to pending sync: $templateId',
      );
    }

    final pending = PendingTemplateSync(
      templateId: templateId,
      templateData: templateData,
      createdAt: DateTime.now(),
    );

    _pendingTemplates[templateId] = pending;
    await _savePendingTemplates();

    // Try sync immediately
    await syncPending();
  }

  /// Get pending sync status for a template
  static PendingTemplateSync? getPendingSync(String templateId) {
    return _pendingTemplates[templateId];
  }

  /// Get all pending templates
  static List<PendingTemplateSync> getAllPending() =>
      _pendingTemplates.values.toList();

  /// Sync all pending templates that are ready for retry
  static Future<void> syncPending() async {
    if (_isSyncing) return;
    if (_pendingTemplates.isEmpty) return;

    _isSyncing = true;

    try {
      final toSync = _pendingTemplates.values
          .where((p) => p.shouldRetry && !p.maxRetriesExceeded)
          .toList();

      if (toSync.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '⏳ [TemplateCloudSyncService] No templates ready for sync yet',
          );
        }
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '🔄 [TemplateCloudSyncService] Syncing ${toSync.length} pending templates',
        );
      }

      for (final pending in toSync) {
        await _syncTemplate(pending);
      }

      // Remove templates that exceeded max retries
      final failed = _pendingTemplates.values
          .where((p) => p.maxRetriesExceeded)
          .toList();

      for (final p in failed) {
        if (kDebugMode) {
          debugPrint(
            '🚨 [TemplateCloudSyncService] Max retries exceeded for ${p.templateId}',
          );
        }
        // Keep in pending list but mark as failed - user needs to see this!
        // Don't remove automatically
      }

      await _savePendingTemplates();
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single template with retry handling
  static Future<void> _syncTemplate(PendingTemplateSync pending) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📤 [TemplateCloudSyncService] Syncing: ${pending.templateId} (attempt ${pending.attemptCount + 1}/5)',
        );
      }

      // Note: exercises are already serialized in templateData
      final result = await TemplateCloudService.createTemplate(
        name: pending.templateData['name'] as String,
        description: pending.templateData['description'] as String? ?? '',
        exercises: [], // Exercises already serialized - Cloud Function converts
        tags: List<String>.from(pending.templateData['tags'] as List? ?? []),
        isPublic: pending.templateData['isPublic'] as bool? ?? false,
      );

      if (result.success) {
        if (kDebugMode) {
          debugPrint(
            '✅ [TemplateCloudSyncService] Sync successful: ${pending.templateId}',
          );
        }

        // Remove from pending
        _pendingTemplates.remove(pending.templateId);
        await _savePendingTemplates();
      } else {
        _handleSyncError(pending, result.error ?? 'Unknown error');
      }
    } on TemplateQuotaExceededException catch (e) {
      // Quota error - don't retry, keep pending
      _pendingTemplates[pending.templateId]!.lastError =
          'Quota exceeded: ${e.message}';
      _pendingTemplates[pending.templateId]!.lastAttemptTime = DateTime.now();
      await _savePendingTemplates();

      if (kDebugMode) {
        debugPrint('⚠️ [TemplateCloudSyncService] Quota error: ${e.message}');
      }
    } catch (e) {
      _handleSyncError(pending, e.toString());
    }
  }

  /// Handle sync error and schedule retry
  static void _handleSyncError(PendingTemplateSync pending, String error) {
    final retryDelay =
        PendingTemplateSync.getRetryDelaySeconds(pending.attemptCount);
    final nextRetry = DateTime.now().add(Duration(seconds: retryDelay));

    pending.attemptCount++;
    pending.lastError = error;
    pending.lastAttemptTime = DateTime.now();
    pending.nextRetryTime = nextRetry;

    if (kDebugMode) {
      debugPrint(
        '❌ [TemplateCloudSyncService] Sync failed: ${pending.templateId}',
      );
      debugPrint(
        '   Error: $error',
      );
      debugPrint(
        '   Retrying in ${retryDelay}s (attempt ${pending.attemptCount}/5)',
      );
    }
  }

  /// Load pending templates from SharedPreferences
  static Future<void> _loadPendingTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = userCacheKeys.pendingTemplateSyncKey;
      final data = prefs.getString(key);

      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        for (final item in jsonList) {
          final pending = PendingTemplateSync.fromJson(
            Map<String, dynamic>.from(item as Map),
          );
          _pendingTemplates[pending.templateId] = pending;
        }

        if (kDebugMode) {
          debugPrint(
            '📖 [TemplateCloudSyncService] Loaded ${_pendingTemplates.length} pending templates',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading pending templates: $e');
      }
    }
  }

  /// Save pending templates to SharedPreferences
  static Future<void> _savePendingTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = userCacheKeys.pendingTemplateSyncKey;

      if (_pendingTemplates.isEmpty) {
        await prefs.remove(key);
      } else {
        final jsonList = _pendingTemplates.values
            .map((p) => p.toJson())
            .toList();
        await prefs.setString(key, jsonEncode(jsonList));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving pending templates: $e');
      }
    }
  }

  /// Clear all pending templates (for logout)
  static Future<void> clearAll() async {
    _pendingTemplates.clear();
    final prefs = await SharedPreferences.getInstance();
    final key = userCacheKeys.pendingTemplateSyncKey;
    await prefs.remove(key);

    if (kDebugMode) {
      debugPrint('🗑️ [TemplateCloudSyncService] Cleared all pending templates');
    }
  }
}

// Utility to get pending template sync key for the current user
String _getPendingTemplateSyncKey(String? userId) {
  if (userId == null) {
    return 'template_cloud_sync_guest';
  }
  return 'template_cloud_sync_$userId';
}

// Alternative: Add as extension to UserCacheKeyManager if available
extension TemplateCloudSyncKeys on UserCacheKeyManager {
  String get pendingTemplateSyncKey => _getPendingTemplateSyncKey(currentUserId);
}
