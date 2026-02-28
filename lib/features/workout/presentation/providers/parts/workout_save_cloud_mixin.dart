part of '../workout_provider.dart';

mixin WorkoutSaveCloudMixin on Notifier<Workout?> {
  /// Track workout with SnapshotSyncService and queue for batch cloud sync.
  ///
  /// Called after local save completes successfully. Non-blocking: failures
  /// are logged but do not affect the local save result.
  Future<void> _syncWorkoutToCloud({
    required WorkoutHistoryDetail workoutHistoryDetail,
    required BuildContext? context,
  }) async {
    // 3. Track entity with SnapshotSyncService for differential sync
    try {
      final snapshotSync = ref.read(snapshotSyncServiceProvider.notifier);

      await snapshotSync.trackEntity(
        collection: 'workouts',
        documentId: workoutHistoryDetail.id,
        data: workoutHistoryDetail.toFirestoreMap(),
      );

      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '📸 [WorkoutProvider] Workout tracked for differential sync',
        );
      }
    } catch (snapshotError) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '⚠️ [WorkoutProvider] Failed to track workout snapshot: $snapshotError',
        );
      }
      // Non-critical: continue with batch sync anyway
    }

    // 4. Queue operation for cloud sync (NON-BLOCKING)
    // The batch queue will auto-flush after 3s or 10 ops
    try {
      final batchWriter = ref.read(firestoreBatchWriterProvider.notifier);

      await batchWriter.addOperation(
        BatchOperation(
          collection: 'workouts',
          documentId: workoutHistoryDetail.id,
          type: BatchOperationType.set,
          data: workoutHistoryDetail.toFirestoreMap(),
          setOptions: SetOptions(merge: true),
        ),
      );

      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '✅ [WorkoutProvider] Workout queued for batch cloud sync',
        );
      }

      // UI Feedback: Show final success toast with motivation
      // Local save complete + cloud sync queued = workout saved successfully
      if (context != null && context.mounted) {
        SyncStatusToast.showWorkoutCompletedWithMotivation(context);
      }
    } catch (batchError) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '⚠️ [WorkoutProvider] Failed to queue cloud sync: $batchError',
        );
      }

      // UI Feedback: Show warning that cloud sync failed to queue
      // But workout is safe locally
      if (context != null && context.mounted) {
        SyncStatusToast.showCloudSyncQueued(context);
      }

      // Non-critical: workout already saved locally
      // The batch queue will retry or sync on next flush
    }
  }

  /// Update user stats in Firestore using a transaction to prevent lost updates.
  ///
  /// Updates totalWorkouts, lastWorkoutDate, totalVolume, and monthlyWorkouts.
  /// Non-critical: failures are logged but do not affect the workout save result.
  Future<void> _updateUserFirestoreStats({
    required String userId,
    required WorkoutHistoryDetail workoutHistoryDetail,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(userId);

      // CRITICAL FIX: Use transaction to prevent lost updates from concurrent workouts
      await firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        // Initialize stats if document doesn't exist
        if (!userDoc.exists) {
          transaction.set(userRef, {
            'stats': {
              'totalWorkouts': 1,
              'lastWorkoutDate': FieldValue.serverTimestamp(),
              'totalVolume': workoutHistoryDetail.totalVolume,
              'monthlyWorkouts': 1,
            },
          }, SetOptions(merge: true));
          return;
        }

        // Get current stats or initialize
        final data = userDoc.data();
        final stats = data?['stats'] as Map<String, dynamic>? ?? {};
        final currentTotalWorkouts = stats['totalWorkouts'] as int? ?? 0;
        final currentTotalVolume = stats['totalVolume'] as num? ?? 0;
        final currentMonthlyWorkouts = stats['monthlyWorkouts'] as int? ?? 0;

        // Update with transactional safety
        transaction.update(userRef, {
          'stats.totalWorkouts': currentTotalWorkouts + 1,
          'stats.lastWorkoutDate': FieldValue.serverTimestamp(),
          'stats.totalVolume':
              currentTotalVolume + workoutHistoryDetail.totalVolume,
          'stats.monthlyWorkouts': currentMonthlyWorkouts + 1,
        });
      });
      debugLog(
        LogCategory.workout,
        '✅ [WorkoutProvider] User stats updated atomically',
      );
    } catch (statsError) {
      debugLog(
        LogCategory.workout,
        '⚠️ [WorkoutProvider] Failed to update stats: $statsError',
      );
      // Non-critical - workout is already saved
    }
  }

  /// Export workout data to JSON file and share.
  ///
  /// Creates a JSON file with complete workout data (exercises, sets, reps, etc.)
  /// and shares it using the system share dialog.
  ///
  /// Use Cases:
  /// - Backup workout data when local save fails
  /// - Manual data export for external analysis
  /// - Data migration between devices
  ///
  /// File Format:
  /// - JSON format with pretty printing
  /// - Filename: workout_YYYY-MM-DD_HH-MM-SS.json
  /// - Contains: workout name, exercises, sets, timestamps, stats
  Future<void> _exportWorkoutData(Workout workout) async {
    try {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '📁 [WorkoutProvider] Exporting workout data: ${workout.name}',
        );
      }

      // 1. Convert workout to JSON
      final workoutJson = workout.toJson();
      final prettyJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(workoutJson);

      // 2. Create filename with timestamp
      final timestamp = DateTime.now();
      final filename =
          'workout_'
          '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}_'
          '${timestamp.hour.toString().padLeft(2, '0')}-${timestamp.minute.toString().padLeft(2, '0')}-${timestamp.second.toString().padLeft(2, '0')}'
          '.json';

      // 3. Get temporary directory and create file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsString(prettyJson);

      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '📁 [WorkoutProvider] Created file: ${file.path}',
        );
        debugLog(
          LogCategory.workout,
          '📊 [WorkoutProvider] File size: ${await file.length()} bytes',
        );
      }

      // 4. Share file using share_plus
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Workout: ${workout.name}',
        text: 'Workout data export from GymBro TrackLog',
      );

      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '✅ [WorkoutProvider] Share result: ${result.status}',
        );
      }

      // 5. Clean up temporary file after short delay
      Future.delayed(const Duration(seconds: 5), () async {
        try {
          if (await file.exists()) {
            await file.delete();
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '🗑️ [WorkoutProvider] Cleaned up temporary file',
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to delete temp file: $e',
            );
          }
        }
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error exporting workout: $e',
        );
        debugLog(
          LogCategory.workout,
          '📍 [WorkoutProvider] Stack trace: $stackTrace',
        );
      }
      // Rethrow to allow caller to handle error
      rethrow;
    }
  }

  /// Maps shared PRType to domain-layer PRType.
  ///
  /// Service layer (pr_tracker.dart) PersonalRecord uses shared PRType enum,
  /// while domain layer personal_record.dart uses its own PRType with different values.
  /// This method bridges the two type systems.
  domain_pr.PRType _mapSharedPRTypeToDomain(PRType sharedType) {
    switch (sharedType) {
      case PRType.weight:
        return domain_pr.PRType.weight;
      case PRType.volume:
        return domain_pr.PRType.volume;
      case PRType.reps:
        return domain_pr.PRType.reps;
      case PRType.oneRM:
        return domain_pr.PRType.oneRM;
      case PRType.totalSets:
        return domain_pr.PRType.totalSets;
      case PRType.duration:
        return domain_pr.PRType.time; // Map duration → time
    }
  }
}
