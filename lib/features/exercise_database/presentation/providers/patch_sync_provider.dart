/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/presentation/providers
/// 🎯 Feature: exercise_database
/// 🔧 Type: provider
///
/// Provider for syncing exercise patches on app startup
library;

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/patch_manager_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/exercise_patch_review_provider.dart';

/// Provider per sincronizzare patch all'avvio dell'app
///
/// Si auto-inizializza quando watchato nell'app root
/// Gestisce errori gracefully senza bloccare l'app
///
/// **Workflow**:
/// 1. Fetch user's patches from Firestore (via repository)
/// 2. Sync local Hive patches with Firestore state (via service)
/// 3. Remove local patches that are approved/rejected/expired
/// 4. Keep local patches that are still pending
final patchSyncProvider = FutureProvider.autoDispose<void>((ref) async {
  if (kDebugMode) {
    debugPrint('🔄 [PATCH SYNC] Starting patch sync on app startup...');
  }

  try {
    final patchManager = await ref.watch(patchManagerServiceProvider.future);
    final repository = ref.watch(exercisePatchRepositoryProvider);

    // 1. Fetch user's patches from Firestore
    // Note: In Phase 1, we use placeholder userId. In Phase 2, we'll use actual auth userId
    final result = await repository.getUserPatches('current_user');

    await result.fold(
      (failure) async {
        if (kDebugMode) {
          debugPrint('⚠️ [PATCH SYNC] Failed to fetch patches: ${failure.message}');
        }
        // Don't throw - graceful degradation
      },
      (firestorePatches) async {
        // 2. Sync local patches with Firestore state
        await patchManager.syncWithFirestorePatches(firestorePatches);

        if (kDebugMode) {
          debugPrint('✅ [PATCH SYNC] Synced ${firestorePatches.length} patches');
        }
      },
    );

    if (kDebugMode) {
      debugPrint('✅ [PATCH SYNC] Patch sync completed successfully');
    }
  } catch (error, stackTrace) {
    // Log error but don't rethrow - let app continue
    if (kDebugMode) {
      debugPrint('⚠️ [PATCH SYNC] Sync failed: $error');
      debugPrint('   Stack trace: $stackTrace');
    }
    // Don't throw - graceful degradation
    // User can still submit patches, they just won't see existing ones
  }
});
