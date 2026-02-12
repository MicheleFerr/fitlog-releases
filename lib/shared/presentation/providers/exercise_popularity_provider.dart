import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/data/services/exercise_popularity_cache.dart';
import 'package:gymbro_flutter_new/shared/data/services/exercise_popularity_bundle_service.dart';

/// Provider for exercise popularity cache (local Hive storage)
///
/// Singleton cache instance for zero-latency popularity lookups.
/// Must be initialized during app startup (see main.dart).
final exercisePopularityCacheProvider = Provider<ExercisePopularityCache>(
  (ref) {
    return ExercisePopularityCache();
  },
  name: 'exercisePopularityCacheProvider',
);

/// Provider for exercise popularity bundle service
///
/// Handles downloading and syncing popularity data from Firebase Storage.
/// Syncs max 1x/day (24h TTL).
final exercisePopularityBundleServiceProvider =
    Provider<ExercisePopularityBundleService>(
  (ref) {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    final cache = ref.watch(exercisePopularityCacheProvider);

    return ExercisePopularityBundleService(
      firestore: firestore,
      storage: storage,
      cache: cache,
    );
  },
  name: 'exercisePopularityBundleServiceProvider',
);

/// Provider to trigger manual sync (for debug/admin)
///
/// Usage:
/// ```dart
/// ref.read(syncPopularityProvider.future);
/// ```
///
/// Or with loading state:
/// ```dart
/// final syncState = ref.watch(syncPopularityProvider);
/// syncState.when(
///   data: (_) => Text('Synced'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
final syncPopularityProvider = FutureProvider.autoDispose<void>(
  (ref) async {
    final service = ref.watch(exercisePopularityBundleServiceProvider);
    await service.syncPopularityData();
  },
  name: 'syncPopularityProvider',
);

/// Provider to force sync (bypasses TTL check)
///
/// Useful for:
/// - Manual refresh button in admin panel
/// - Testing after Cloud Function deployment
/// - Debug mode forced refresh
final forceSyncPopularityProvider = FutureProvider.autoDispose<void>(
  (ref) async {
    final service = ref.watch(exercisePopularityBundleServiceProvider);
    await service.forceSync();
  },
  name: 'forceSyncPopularityProvider',
);

/// Provider to check if cache needs sync
///
/// Returns true if:
/// - Cache is empty
/// - Oldest entry is >24h old
final popularityCacheNeedsSyncProvider = Provider<bool>(
  (ref) {
    final cache = ref.watch(exercisePopularityCacheProvider);
    return cache.needsSync();
  },
  name: 'popularityCacheNeedsSyncProvider',
);

/// Provider for sync status (debug/monitoring)
///
/// Returns status map with:
/// - lastDownload: ISO8601 timestamp
/// - needsDownload: bool
/// - daysSinceDownload: int
/// - cacheStats: cache statistics
final popularitySyncStatusProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) async {
    final service = ref.watch(exercisePopularityBundleServiceProvider);
    return await service.getSyncStatus();
  },
  name: 'popularitySyncStatusProvider',
);
