import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// One-time migration script to upgrade all V1 SupersetExerciseData to V2
///
/// **IMPORTANT**: This script is OPTIONAL. Migration happens automatically
/// via lazy migration when data is read. Only use this if you want to
/// force-migrate all data immediately.
///
/// Usage:
/// 1. Get your userId from Firebase Auth
/// 2. Uncomment the main() function
/// 3. Run in debug mode: flutter run
/// 4. Call SupersetDataMigrationV1ToV2.migrateUser(userId) from your app
/// 5. Check Firestore console to verify _schemaVersion: 2
///
/// Safety:
/// - ✅ Non-destructive (adds fields, doesn't remove)
/// - ✅ Dry-run mode available
/// - ✅ Detailed logging
/// - ✅ Rollback friendly (V2 is backward compatible)
class SupersetDataMigrationV1ToV2 {
  final FirebaseFirestore _firestore;
  final String userId;
  final bool dryRun;

  SupersetDataMigrationV1ToV2({
    required this.userId,
    FirebaseFirestore? firestore,
    this.dryRun = true, // Safe default: dry-run mode
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Public API: Migrate all workouts for a user
  static Future<MigrationResult> migrateUser(
    String userId, {
    bool dryRun = true,
  }) async {
    final migration = SupersetDataMigrationV1ToV2(
      userId: userId,
      dryRun: dryRun,
    );
    return migration._execute();
  }

  /// Execute migration
  Future<MigrationResult> _execute() async {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('  SupersetExerciseData V1 → V2 Migration');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('  Mode: ${dryRun ? "DRY-RUN (no changes)" : "LIVE (will update)"}');
      debugPrint('  User: $userId');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('');
    }

    try {
      // Get all workouts for user
      final workoutsSnapshot = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .get();

      if (kDebugMode) {
        debugPrint('📊 Found ${workoutsSnapshot.docs.length} workouts to scan');
        debugPrint('');
      }

      int totalWorkouts = 0;
      int workoutsUpdated = 0;
      int workoutsSkipped = 0;
      int supersetsUpdated = 0;
      int setsUpdated = 0;
      final List<String> updatedWorkoutIds = [];
      final List<String> errors = [];

      for (final doc in workoutsSnapshot.docs) {
        totalWorkouts++;

        try {
          final result = await _migrateWorkout(doc);

          if (result.needsUpdate) {
            workoutsUpdated++;
            supersetsUpdated += result.supersetsUpdated;
            setsUpdated += result.setsUpdated;
            updatedWorkoutIds.add(doc.id);

            if (kDebugMode) {
              debugPrint('✅ ${doc.id}: ${result.supersetsUpdated} supersets, ${result.setsUpdated} sets');
            }
          } else {
            workoutsSkipped++;
            if (kDebugMode) {
              debugPrint('⏭️  ${doc.id}: Already V2 or no supersets');
            }
          }
        } catch (e, stackTrace) {
          errors.add('Workout ${doc.id}: $e');
          if (kDebugMode) {
            debugPrint('❌ Error migrating ${doc.id}: $e');
            debugPrint(stackTrace.toString());
          }
        }
      }

      if (kDebugMode) {
        debugPrint('');
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('  Migration ${dryRun ? "DRY-RUN" : "COMPLETE"}');
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('  Total Workouts: $totalWorkouts');
        debugPrint('  Updated: $workoutsUpdated');
        debugPrint('  Skipped: $workoutsSkipped');
        debugPrint('  Supersets Updated: $supersetsUpdated');
        debugPrint('  Sets Updated: $setsUpdated');
        debugPrint('  Errors: ${errors.length}');
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('');

        if (dryRun) {
          debugPrint('ℹ️  This was a DRY-RUN. No changes were made.');
          debugPrint('   To apply changes, run with dryRun: false');
          debugPrint('');
        }
      }

      return MigrationResult(
        totalWorkouts: totalWorkouts,
        workoutsUpdated: workoutsUpdated,
        workoutsSkipped: workoutsSkipped,
        supersetsUpdated: supersetsUpdated,
        setsUpdated: setsUpdated,
        updatedWorkoutIds: updatedWorkoutIds,
        errors: errors,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Fatal migration error: $e');
        debugPrint(stackTrace.toString());
      }
      rethrow;
    }
  }

  /// Migrate a single workout document
  Future<_WorkoutMigrationResult> _migrateWorkout(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();
    if (data == null) {
      return _WorkoutMigrationResult(needsUpdate: false);
    }

    final exercises = data['exercises'] as List<dynamic>?;
    if (exercises == null || exercises.isEmpty) {
      return _WorkoutMigrationResult(needsUpdate: false);
    }

    bool needsUpdate = false;
    int supersetsUpdated = 0;
    int setsUpdated = 0;

    final updatedExercises = exercises.map((ex) {
      final exerciseData = ex as Map<String, dynamic>;

      // Only process supersets
      if (exerciseData['type'] != 'superset') {
        return exerciseData;
      }

      final supersetSets = exerciseData['supersetSets'] as List<dynamic>?;
      if (supersetSets == null || supersetSets.isEmpty) {
        return exerciseData;
      }

      bool supersetNeedsUpdate = false;
      final updatedSets = supersetSets.map((set) {
        final setData = set as Map<String, dynamic>;
        final exerciseDataMap = setData['exerciseData'] as Map<String, dynamic>?;

        if (exerciseDataMap == null || exerciseDataMap.isEmpty) {
          return setData;
        }

        bool setNeedsUpdate = false;
        final updatedExerciseDataMap = <String, dynamic>{};

        for (final entry in exerciseDataMap.entries) {
          final exData = entry.value as Map<String, dynamic>;
          final schemaVersion = exData['_schemaVersion'] as int? ?? 1;

          if (schemaVersion == 1) {
            // V1 → V2 migration
            setNeedsUpdate = true;
            updatedExerciseDataMap[entry.key] = _upgradeToV2(exData);
          } else {
            // Already V2, preserve as-is
            updatedExerciseDataMap[entry.key] = exData;
          }
        }

        if (setNeedsUpdate) {
          setsUpdated++;
          supersetNeedsUpdate = true;
          return {
            ...setData,
            'exerciseData': updatedExerciseDataMap,
          };
        }

        return setData;
      }).toList();

      if (supersetNeedsUpdate) {
        supersetsUpdated++;
        needsUpdate = true;
        return {
          ...exerciseData,
          'supersetSets': updatedSets,
        };
      }

      return exerciseData;
    }).toList();

    // Update Firestore if needed (and not in dry-run mode)
    if (needsUpdate && !dryRun) {
      await doc.reference.update({
        'exercises': updatedExercises,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return _WorkoutMigrationResult(
      needsUpdate: needsUpdate,
      supersetsUpdated: supersetsUpdated,
      setsUpdated: setsUpdated,
    );
  }

  /// Upgrade V1 data to V2 schema
  Map<String, dynamic> _upgradeToV2(Map<String, dynamic> v1Data) {
    return {
      ...v1Data,
      '_schemaVersion': 2,
      'countingMode': 'weighted', // Default for V1
      'targetSeconds': null,
      'actualSeconds': null,
    };
  }
}

/// Result of migrating a single workout
class _WorkoutMigrationResult {
  final bool needsUpdate;
  final int supersetsUpdated;
  final int setsUpdated;

  _WorkoutMigrationResult({
    required this.needsUpdate,
    this.supersetsUpdated = 0,
    this.setsUpdated = 0,
  });
}

/// Result of complete migration
class MigrationResult {
  final int totalWorkouts;
  final int workoutsUpdated;
  final int workoutsSkipped;
  final int supersetsUpdated;
  final int setsUpdated;
  final List<String> updatedWorkoutIds;
  final List<String> errors;

  MigrationResult({
    required this.totalWorkouts,
    required this.workoutsUpdated,
    required this.workoutsSkipped,
    required this.supersetsUpdated,
    required this.setsUpdated,
    required this.updatedWorkoutIds,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get success => errors.isEmpty && workoutsUpdated > 0;

  @override
  String toString() {
    return 'MigrationResult('
        'total: $totalWorkouts, '
        'updated: $workoutsUpdated, '
        'skipped: $workoutsSkipped, '
        'supersets: $supersetsUpdated, '
        'sets: $setsUpdated, '
        'errors: ${errors.length})';
  }
}

// ══════════════════════════════════════════════════════════════════════════
// USAGE EXAMPLE (Uncomment to use)
// ══════════════════════════════════════════════════════════════════════════

/*
void main() async {
  // 1. Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 2. Get current user ID
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    debugPrint('❌ No user logged in');
    return;
  }

  // 3. Run DRY-RUN first to see what would change
  debugPrint('🔍 Running DRY-RUN...');
  final dryRunResult = await SupersetDataMigrationV1ToV2.migrateUser(
    user.uid,
    dryRun: true, // Safe: no changes
  );
  debugPrint(dryRunResult.toString());

  // 4. If dry-run looks good, run LIVE migration
  if (dryRunResult.workoutsUpdated > 0) {
    debugPrint('');
    debugPrint('💾 Running LIVE migration...');
    final liveResult = await SupersetDataMigrationV1ToV2.migrateUser(
      user.uid,
      dryRun: false, // CAUTION: will update Firestore
    );
    debugPrint(liveResult.toString());
  }
}
*/
