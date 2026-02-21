import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/data/services/exercise_popularity_cache.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise_popularity_data.dart';

/// Service for downloading and loading exercise popularity data bundles
///
/// Data flow:
/// 1. Cloud Function generates bundle daily (3am) → uploads to Storage
/// 2. This service downloads bundle → loads into Firestore local cache
/// 3. Queries named query from bundle → converts to domain entities
/// 4. Updates Hive cache for zero-latency search access
///
/// Performance:
/// - Download: ~100KB for 1000 exercises
/// - Frequency: Max 1x/day (TTL check)
/// - Cost: ~$0.36/month for 30k downloads
///
/// @see docs/design/EXERCISE_POPULARITY_RANKING.md
class ExercisePopularityBundleService {

  ExercisePopularityBundleService({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required ExercisePopularityCache cache,
  })  : _firestore = firestore,
        _storage = storage,
        _cache = cache;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final ExercisePopularityCache _cache;

  static const String _bundlePath = 'bundles/latest.bundle';
  static const String _lastDownloadKey = 'popularity_bundle_last_download';

  /// Sync popularity data from bundle
  ///
  /// Steps:
  /// 1. Check if download needed (TTL check)
  /// 2. Download bundle from Storage
  /// 3. Load bundle into Firestore local cache
  /// 4. Query named query from bundle
  /// 5. Update Hive cache
  ///
  /// Graceful degradation: Logs errors but doesn't throw
  /// (app continues with existing cache if sync fails)
  Future<void> syncPopularityData() async {
    // Check if download is needed
    if (!await _needsDownload()) {
      debugPrint('Popularity bundle: Cache still fresh, skipping download');
      return;
    }

    try {
      debugPrint('Popularity bundle: Starting download...');

      // 1. Download bundle from Storage
      final ref = _storage.ref(_bundlePath);
      final bundleData = await ref.getData();

      if (bundleData == null) {
        debugPrint('Popularity bundle: Not found in Storage');
        return;
      }

      debugPrint('Popularity bundle: Downloaded ${bundleData.length} bytes');

      // 2. Load bundle into Firestore local cache
      final loadBundleTask = _firestore.loadBundle(bundleData);

      // Wait for completion
      await loadBundleTask.stream.last;

      debugPrint('Popularity bundle: Loaded into Firestore');

      // 3. Query the named query from bundle
      // namedQueryGet returns QuerySnapshot directly (not Query)
      final snapshot = await _firestore.namedQueryGet('exercise_popularity');

      if (snapshot.docs.isEmpty) {
        debugPrint('Popularity bundle: No documents in query result');
        return;
      }

      debugPrint('Popularity bundle: Queried ${snapshot.docs.length} documents');

      // 4. Convert to domain entities and cache in Hive
      final popularityData = snapshot.docs.map((doc) {
        final data = doc.data();
        return ExercisePopularityData(
          exerciseId: doc.id,
          count: data['count'] as int? ?? 0,
          lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ??
              DateTime.now(),
        );
      }).toList();

      await _cache.updateBatch(popularityData);

      // 5. Save download timestamp
      await _saveDownloadTimestamp();

      debugPrint('✅ Popularity bundle synced: ${popularityData.length} exercises');

    } on FirebaseException catch (e) {
      // object-not-found is expected if bundle hasn't been generated yet
      if (e.code == 'object-not-found') {
        debugPrint('ℹ️ Popularity bundle not found (not generated yet). '
            'Search will use default sorting.');
      } else {
        debugPrint('⚠️ Popularity bundle sync issue: ${e.code} - ${e.message}');
      }
      // Graceful degradation: app uses existing cache or default sorting
    } catch (e, stackTrace) {
      debugPrint('⚠️ Popularity bundle sync failed: $e');
      debugPrint(stackTrace.toString());
      // Graceful degradation: app uses existing cache
    }
  }

  /// Check if download is needed based on TTL
  ///
  /// Returns true if:
  /// - No previous download timestamp found
  /// - Last download was >1 day ago
  Future<bool> _needsDownload() async {
    final lastDownload = await _getLastDownloadTimestamp();

    if (lastDownload == null) return true;

    final daysSinceDownload = DateTime.now().difference(lastDownload).inDays;
    return daysSinceDownload >= 1;
  }

  /// Get last download timestamp from SharedPreferences
  Future<DateTime?> _getLastDownloadTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastDownloadKey);

    if (timestamp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Save current timestamp as last download
  Future<void> _saveDownloadTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastDownloadKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Force sync (bypasses TTL check)
  ///
  /// Useful for:
  /// - Debug/testing
  /// - Admin panel manual refresh
  /// - User-initiated refresh
  Future<void> forceSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastDownloadKey);
    await syncPopularityData();
  }

  /// Get sync status (for debugging/monitoring)
  Future<Map<String, dynamic>> getSyncStatus() async {
    final lastDownload = await _getLastDownloadTimestamp();
    final needsDownload = await _needsDownload();

    return {
      'lastDownload': lastDownload?.toIso8601String(),
      'needsDownload': needsDownload,
      'daysSinceDownload': lastDownload != null
          ? DateTime.now().difference(lastDownload).inDays
          : null,
      'cacheStats': _cache.getStats(),
    };
  }
}
