/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/services
/// 🎯 Feature: exercise_database
/// 🔧 Type: service
///
/// Service for managing local exercise patches in Hive
///
/// **Responsibilities**:
/// - Apply approved patches to local Hive cache (instant feedback)
/// - Remove patches when rejected or published globally
/// - Merge Firestore exercises with local patches
/// - Sync patch state between Hive and Firestore
library;

import 'package:hive/hive.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_patch.dart';

/// Local patch data stored in Hive
///
/// Separate from ExercisePatch to keep it simple (no Freezed overhead)
class LocalPatch {
  LocalPatch({
    required this.patchId,
    required this.exerciseId,
    required this.fieldName,
    required this.newValue,
    required this.appliedAt,
  });

  final String patchId;
  final String exerciseId;
  final String fieldName;
  final dynamic newValue;
  final DateTime appliedAt;

  Map<String, dynamic> toJson() => {
        'patchId': patchId,
        'exerciseId': exerciseId,
        'fieldName': fieldName,
        'newValue': newValue,
        'appliedAt': appliedAt.toIso8601String(),
      };

  factory LocalPatch.fromJson(Map<String, dynamic> json) => LocalPatch(
        patchId: json['patchId'] as String,
        exerciseId: json['exerciseId'] as String,
        fieldName: json['fieldName'] as String,
        newValue: json['newValue'],
        appliedAt: DateTime.parse(json['appliedAt'] as String),
      );
}

class PatchManagerService {
  PatchManagerService({
    required Box<dynamic> hiveBox,
  }) : _hiveBox = hiveBox;

  final Box<dynamic> _hiveBox;

  /// Key prefix for local patches in Hive
  static const String _patchPrefix = 'local_patch_';

  /// Apply a patch locally to Hive
  ///
  /// **Use case**: User submits patch → instant local correction
  ///
  /// **Steps**:
  /// 1. Store patch metadata in Hive (for tracking)
  /// 2. Modify exercise field in Hive cache
  ///
  /// **Returns**: true if successful, false otherwise
  Future<bool> applyPatchLocally({
    required String patchId,
    required String exerciseId,
    required String fieldName,
    required dynamic newValue,
  }) async {
    try {
      // 1. Store patch metadata
      final localPatch = LocalPatch(
        patchId: patchId,
        exerciseId: exerciseId,
        fieldName: fieldName,
        newValue: newValue,
        appliedAt: DateTime.now(),
      );

      await _hiveBox.put('$_patchPrefix$patchId', localPatch.toJson());

      // 2. Apply to exercise in Hive cache (if exists)
      final exercise = _hiveBox.get('exercise_$exerciseId') as Exercise?;
      if (exercise != null) {
        // Create updated exercise with new field value
        final updatedExercise = _applyFieldToExercise(
          exercise,
          fieldName,
          newValue,
        );
        await _hiveBox.put('exercise_$exerciseId', updatedExercise);
      }

      return true;
    } catch (e) {
      // Log error (use logger in production)
      return false;
    }
  }

  /// Remove a local patch from Hive
  ///
  /// **Use case**: Patch rejected by admin OR approved and published globally
  ///
  /// **Steps**:
  /// 1. Delete patch metadata from Hive
  /// 2. Revert exercise field to Firestore value (if needed)
  ///
  /// **Returns**: true if successful
  Future<bool> removePatchLocally({
    required String patchId,
    required String exerciseId,
    required String fieldName,
    required dynamic firestoreValue,
  }) async {
    try {
      // 1. Delete patch metadata
      await _hiveBox.delete('$_patchPrefix$patchId');

      // 2. Revert exercise field to Firestore value
      final exercise = _hiveBox.get('exercise_$exerciseId') as Exercise?;
      if (exercise != null) {
        final revertedExercise = _applyFieldToExercise(
          exercise,
          fieldName,
          firestoreValue,
        );
        await _hiveBox.put('exercise_$exerciseId', revertedExercise);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all local patches for an exercise
  ///
  /// **Use case**: Display "You have X pending changes" message
  ///
  /// **Returns**: List of LocalPatch objects
  Future<List<LocalPatch>> getLocalPatchesForExercise(
    String exerciseId,
  ) async {
    try {
      final patches = <LocalPatch>[];

      for (final key in _hiveBox.keys) {
        if (key.toString().startsWith(_patchPrefix)) {
          final patchData = _hiveBox.get(key) as Map<String, dynamic>?;
          if (patchData != null) {
            final patch = LocalPatch.fromJson(patchData);
            if (patch.exerciseId == exerciseId) {
              patches.add(patch);
            }
          }
        }
      }

      return patches;
    } catch (e) {
      return [];
    }
  }

  /// Clear all local patches
  ///
  /// **Use case**: User reinstalls app, or admin publishes new version
  ///
  /// **Warning**: This removes ALL local patches. Use carefully.
  Future<void> clearAllLocalPatches() async {
    try {
      final keysToDelete = <String>[];

      for (final key in _hiveBox.keys) {
        if (key.toString().startsWith(_patchPrefix)) {
          keysToDelete.add(key.toString());
        }
      }

      for (final key in keysToDelete) {
        await _hiveBox.delete(key);
      }
    } catch (e) {
      // Log error
    }
  }

  /// Sync local patches with Firestore patches
  ///
  /// **Use case**: App startup, or after network reconnection
  ///
  /// **Steps**:
  /// 1. Get all local patches from Hive
  /// 2. Get corresponding patches from Firestore (by patchId)
  /// 3. If Firestore patch is REJECTED or APPROVED → remove local patch
  /// 4. If Firestore patch is PENDING → keep local patch
  ///
  /// **Requires**: List of Firestore patches (from repository)
  Future<void> syncWithFirestorePatches(
    List<ExercisePatch> firestorePatches,
  ) async {
    try {
      final localPatchKeys = <String>[];

      // Get all local patch keys
      for (final key in _hiveBox.keys) {
        if (key.toString().startsWith(_patchPrefix)) {
          localPatchKeys.add(key.toString());
        }
      }

      // Check each local patch against Firestore
      for (final key in localPatchKeys) {
        final patchId = key.replaceFirst(_patchPrefix, '');
        final firestorePatch = firestorePatches
            .cast<ExercisePatch?>()
            .firstWhere(
              (p) => p?.id == patchId,
              orElse: () => null,
            );

        if (firestorePatch == null) {
          // Patch doesn't exist in Firestore → remove local
          await _hiveBox.delete(key);
        } else if (!firestorePatch.isPending) {
          // Patch is APPROVED/REJECTED/EXPIRED → remove local
          await _hiveBox.delete(key);
        }
        // If PENDING → keep local patch
      }
    } catch (e) {
      // Log error
    }
  }

  /// Apply a field value to an Exercise entity
  ///
  /// **Helper method**: Creates a new Exercise instance with updated field
  ///
  /// **Note**: Exercise is immutable (Equatable), so we create a new instance
  Exercise _applyFieldToExercise(
    Exercise exercise,
    String fieldName,
    dynamic newValue,
  ) {
    // Convert exercise to JSON, modify field, convert back
    final json = exercise.toJson();
    json[fieldName] = newValue;
    return Exercise.fromJson(json);
  }

  /// Get count of local patches for a user
  ///
  /// **Use case**: Badge counter on "My Patches" button
  Future<int> getLocalPatchCount() async {
    try {
      int count = 0;
      for (final key in _hiveBox.keys) {
        if (key.toString().startsWith(_patchPrefix)) {
          count++;
        }
      }
      return count;
    } catch (e) {
      return 0;
    }
  }
}
