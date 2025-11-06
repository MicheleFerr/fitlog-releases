import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as wt;
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/hybrid_exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/intelligent_notification_service.dart';
// Achievement notification service for PR, streak, and volume notifications
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/achievement_notification_provider.dart';
// MIGRATION: Using bridge provider for backward compatibility while migrating to unified system
// import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_provider_bridge.dart'; // REMOVED: cleanup
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/screen_wakelock_provider.dart';
// Auto-sync for cached progress stats
import 'package:gymbro_flutter_new/features/progress/presentation/providers/cached_progress_provider.dart';
// Progress providers for streak and volume tracking
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';
// App config for default APRE settings
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
// APRE auto-regulation
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_auto_regulation_service.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/providers/apre_calculation_config_provider.dart';
// 🔒 Security: Input sanitization
import 'package:gymbro_flutter_new/shared/domain/services/input_sanitizer.dart';
// Haptic feedback
import 'package:gymbro_flutter_new/shared/presentation/services/haptic_feedback_service.dart';
// ⏱️ Unified Timer for rest timer auto-start
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';
// 🔄 Firestore Batch Writer for optimized cloud sync
import 'package:gymbro_flutter_new/shared/data/services/firestore_batch_writer.dart';
// 📸 Snapshot Sync Service for differential cloud sync
import 'package:gymbro_flutter_new/shared/data/services/snapshot_sync_service.dart';
// 📢 Sync Status Toast for user feedback during save flow
import 'package:gymbro_flutter_new/shared/presentation/widgets/sync_status_toast.dart';
// 🔄 Routine Auto-Completion Service for automatic day completion
// 💾 Workout Repository for fetching workout data
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';
import 'package:gymbro_flutter_new/features/routine/application/services/routine_auto_completion_service.dart';
// 📊 Analytics Tracking for workout events & PR detection
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/workout_analytics_repository_impl.dart';
import 'package:gymbro_flutter_new/core/analytics/trackers/workout_event_tracker.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
// 💾 Template Cache Service for auto-saving modifications
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_template_cache_service.dart';
// 🔒 Session Timeout: Record activity to prevent auto-logout during workouts
import 'package:gymbro_flutter_new/shared/domain/auth/providers/security_providers.dart';
// 🐛 Debug Log Manager for categorized logging
import 'package:gymbro_flutter_new/shared/data/services/debug_log_manager.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/log_category.dart';

// Hive datasource provider
final hiveWorkoutDataSourceProvider = Provider<HiveWorkoutDataSource>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return HiveWorkoutDataSource(boxManager);
});

// Hybrid Exercise Activity Repository provider
final hybridExerciseActivityRepositoryProvider = Provider<HybridExerciseActivityRepository>((ref) {
  final localDataSource = ref.watch(hiveWorkoutDataSourceProvider);
  return HybridExerciseActivityRepository(localDataSource: localDataSource);
});

// Exercise Activity Repository provider (kept for backward compatibility)
final exerciseActivityRepositoryProvider = Provider<ExerciseActivityRepository>((ref) {
  return ExerciseActivityRepository();
});

// NOTE: WorkoutHistoryRepository removed - using unified HybridWorkoutRepository instead

// Current workout state provider
final currentWorkoutProvider = StateNotifierProvider<CurrentWorkoutNotifier, Workout?>(
  (ref) {
    final notifier = CurrentWorkoutNotifier(ref);
    notifier._startCleanupTimer();

    ref.onDispose(() {
      notifier._cleanupTimer?.cancel();
    });

    return notifier;
  },
);

class CurrentWorkoutNotifier extends StateNotifier<Workout?> {
  CurrentWorkoutNotifier(this.ref) : super(null);

  final Ref ref;

  // CRITICAL FIX: Track disposal state to prevent operations after dispose
  bool _isDisposed = false;

  // CRITICAL FIX: Atomic flag to prevent concurrent APRE calculations
  bool _apreCalculationInProgress = false;

  // 💾 Track current template ID for auto-save
  String? _currentTemplateId;

  // 🧹 Cleanup timer fields
  Timer? _cleanupTimer;
  bool _timerPaused = false;

  // 💾 Helper method to auto-save modifications
  void _autoSaveIfNeeded() {
    if (_currentTemplateId != null && state != null) {
      final cacheService = ref.read(workoutTemplateCacheServiceProvider);
      cacheService.saveWorkoutModifications(
        templateId: _currentTemplateId!,
        workout: state!,
      );
    }
  }

  /// Creates workout from routine with pre-loaded exercises
  Future<void> createWorkoutFromRoutine({
    required String routineName,
    required List<Exercise> exercises,
    required String sessionId,
    String? templateId, // ✅ FIX #6: Accept templateId for auto-save
  }) async {
    // ✅ FIX #6: Store template ID for auto-save functionality
    _currentTemplateId = templateId;

    final workout = Workout(
      id: const Uuid().v4(),
      name: routineName,
      exercises: exercises,
      status: WorkoutStatus.planned,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPreloaded: true, // Flag to identify pre-loaded state
      preloadExpiry: DateTime.now().add(const Duration(minutes: 15)), // 15-min timeout
      sessionId: sessionId, // Analytics tracking
      templateId: templateId, // ✅ FIX #6: Link workout to template
    );

    state = workout;
    _autoSaveIfNeeded();
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_timerPaused) return; // Skip if paused

      final workout = state;
      if (workout?.isPreloaded == true && workout!.isExpired) {
        state = null; // Cleanup expired workout
        if (kDebugMode) debugPrint('🧹 Preloaded workout expired and removed');
      }
    });
  }

  void pauseCleanupTimer() {
    _timerPaused = true;
    if (kDebugMode) debugPrint('⏸️ Cleanup timer paused');
  }

  void resumeCleanupTimer() {
    _timerPaused = false;
    if (kDebugMode) debugPrint('▶️ Cleanup timer resumed');
  }

  Future<void> replaceExercisesFromTemplate(wt.WorkoutTemplate template) async {
    final workout = state;
    if (workout == null) return;

    // Convert ExerciseTemplate list to Exercise list
    final exercises = template.exercises.map((templateExercise) {
      return Exercise(
        name: templateExercise.exerciseName,
        type: templateExercise.type,
        category: templateExercise.category,
        sets: templateExercise.sets.map((templateSet) {
          return ExerciseSet(
            setNumber: templateSet.setNumber,
            weight: templateSet.targetWeight,
            reps: templateSet.targetReps,
          );
        }).toList(),
      );
    }).toList();

    state = workout.copyWith(
      name: template.name,
      exercises: exercises,
      isPreloaded: false, // No longer pre-loaded
      exercisesModified: true, // Track modification
    );

    _autoSaveIfNeeded();
  }

  void createWorkout(String name) {
    state = Workout(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _currentTemplateId = null; // Reset template ID for manual workouts
  }

  void startFromTemplate(wt.WorkoutTemplate workoutTemplate) async {
    try {
      // 💾 Store template ID for auto-save
      _currentTemplateId = workoutTemplate.id;

      // Check if APRE is enabled globally
      final config = ref.read(appConfigProvider);
      final isApreEnabled = config.enableApre ?? false;

      // 💾 Check if there's a cached version of this template
      final cacheService = ref.read(workoutTemplateCacheServiceProvider);
      final cachedWorkout = await cacheService.getCachedWorkout(workoutTemplate.id);

      Workout workout;

      if (cachedWorkout != null) {
        // Use cached version with modifications
        if (kDebugMode) {
          debugLog(LogCategory.workout, '💾 [WorkoutProvider] Loading cached workout for template: ${workoutTemplate.name}');
        }
        workout = cachedWorkout;
      } else {
        if (kDebugMode) {
          debugLog(LogCategory.workout, '[APRE] Starting workout from template: ${workoutTemplate.name}');
          debugLog(LogCategory.workout, '[APRE] APRE system enabled: $isApreEnabled');
        }

        // Crea un nuovo workout dal template
        workout = Workout(
        id: const Uuid().v4(),
        name: workoutTemplate.name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        templateId: workoutTemplate.id, // ✅ CRITICAL FIX: Pass templateId for routine auto-detection
        exercises: workoutTemplate.exercises.map((templateExercise) {
          // Crea l'esercizio con i set predefiniti dal template
          var exercise = Exercise(
            name: templateExercise.exerciseName,
            type: templateExercise.type,
            category: templateExercise.category,
            sets: templateExercise.sets.map((templateSet) {
              return ExerciseSet(
                setNumber: templateSet.setNumber,
                weight: templateSet.targetWeight,
                reps: templateSet.targetReps,
              );
            }).toList(),
          );

          // Apply APRE configuration if enabled globally
          if (isApreEnabled && exercise.type == ExerciseType.single && exercise.sets.isNotEmpty) {
            // Auto-select protocol based on target reps of first set
            final targetReps = exercise.sets.first.reps ?? 6;
            final protocol = APREAutoRegulationService.selectProtocolFromTargetReps(targetReps);

            if (kDebugMode) {
              debugLog(LogCategory.workout, '[APRE] Auto-selected protocol $protocol for ${exercise.name} (target reps: $targetReps)');
            }

            // Get appropriate rest time for protocol
            final restTime = APREAutoRegulationService.getRestTimeForProtocol(
              protocol,
              strengthRestTime: config.strengthRestTime,
              hypertrophyRestTime: config.hypertrophyRestTime,
              enduranceRestTime: config.enduranceRestTime,
              defaultRestTime: config.defaultRestTime,
            );

            exercise = exercise.copyWith(
              autoAdjustmentType: AutoAdjustmentType.apre,
              useAPRE: true,
              apreProtocol: protocol,
              restTime: restTime,
            );

            // Calculate base weight from history in background
            _calculateAndSetBaseWeight(exercise);
          }

          return exercise;
        }).toList(),
      );
      }

      // Imposta il workout e lo avvia automaticamente
      state = workout.startWorkout();

      // 📊 Track workout started from template
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackWorkoutStarted(
        workoutId: workout.id,
        workoutType: 'strength', // Default type
        workoutName: workout.name,
        source: 'template',
        templateId: workoutTemplate.id,
      );

      // Pre-calculate APRE weights for all exercises with APRE enabled
      if (isApreEnabled) {
        if (kDebugMode) {
          debugLog(LogCategory.workout, '[APRE] Triggering pre-calculation of APRE weights for all exercises');
        }
        _preCalculateAllAPREWeights();
      }

      // Attiva wakelock se abilitato nelle impostazioni
      ref.read(screenWakelockProvider.notifier).startWakelock();

      // Incrementa il contatore di utilizzo del template
      // Questo verrà gestito dal template provider
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error starting workout from template: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Ensure we don't leave the app in a bad state
      state = null;
      rethrow; // Allow UI to handle the error
    }
  }

  void startWorkout() {
    if (state != null) {
      // 📊 Track workout started
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackWorkoutStarted(
        workoutId: state!.id,
        workoutType: 'strength', // Default type
        workoutName: state!.name,
        source: 'manual_start',
      );

      state = state!.startWorkout();

      // Pre-calculate APRE weights for all exercises with APRE enabled
      _preCalculateAllAPREWeights();

      // Attiva wakelock se abilitato nelle impostazioni
      ref.read(screenWakelockProvider.notifier).startWakelock();
    }
  }

  /// Complete workout with optional UI feedback
  ///
  /// Pass [context] to show sync status toasts during save flow.
  /// If [context] is null, saves silently without UI feedback.
  void completeWorkout([BuildContext? context]) {
    if (state != null) {
      final workout = state!;

      // 📊 Track workout completed with full stats
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      // Calculate stats
      final totalExercises = workout.exercises.length;
      final totalSetsCount = workout.exercises.fold<int>(
        0,
        (total, ex) => total + ex.sets.length,
      );
      final completedSets = workout.exercises.fold<int>(
        0,
        (total, ex) => total + ex.sets.where((s) => s.isCompleted).length,
      );
      final totalWeight = workout.exercises.fold<double>(
        0.0,
        (total, ex) => total + ex.sets.fold<double>(
          0.0,
          (exTotal, set) {
            if (!set.isCompleted) return exTotal;
            final weight = set.weight ?? 0;
            final reps = set.reps ?? 0;
            return exTotal + (weight.toDouble() * reps.toDouble());
          },
        ),
      );

      tracker.trackWorkoutCompleted(
        workoutId: workout.id,
        workoutType: 'strength',
        exerciseCount: totalExercises,
        totalSets: totalSetsCount,
        totalWeight: totalWeight,
        duration: workout.duration?.inSeconds ?? 0,
        completionRate: totalSetsCount > 0
            ? ((completedSets / totalSetsCount) * 100).round()
            : 0,
        sessionId: workout.sessionId, // ✅ FIX #8: Add sessionId for funnel correlation
      );

      state = state!.completeWorkout();

      // Haptic feedback for workout completion
      HapticFeedbackService.workoutCompletion(ref);

      // 💾 Clear cache after workout completion (start fresh next time)
      if (_currentTemplateId != null) {
        final cacheService = ref.read(workoutTemplateCacheServiceProvider);
        cacheService.clearCache(_currentTemplateId!);
        _currentTemplateId = null;
      }

      // Salva automaticamente il workout completato in Firestore
      _saveCompletedWorkoutToFirestore(context);

      // Disattiva wakelock quando il workout è completato
      ref.read(screenWakelockProvider.notifier).stopWakelock();
    }
  }

  /// Salva il workout completato localmente e in Firestore
  ///
  /// Pass [context] to show sync status toasts during save flow.
  /// If [context] is null, saves silently without UI feedback.
  Future<void> _saveCompletedWorkoutToFirestore([BuildContext? context]) async {
    final workout = state;
    if (workout == null || !workout.isCompleted) {
      return;
    }

    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;
    if (currentUser == null) {
      return;
    }

    // 📢 UI Feedback: Show "Saving workout..." toast
    if (context != null) {
      SyncStatusToast.showSavingWorkout(context);
    }

    try {
      // 🔒 SECURITY: Sanitize user input to prevent XSS/injection attacks
      final sanitizedWorkoutName = InputSanitizer.sanitizeName(workout.name);
      final sanitizedWorkoutNotes = InputSanitizer.sanitizeText(workout.notes ?? '');

      // Validate workout data before save
      final validation = InputSanitizer.validateWorkoutData(
        workoutName: sanitizedWorkoutName,
        notes: sanitizedWorkoutNotes,
        exerciseNames: workout.exercises.map((e) => e.name).toList(),
      );

      if (!validation.isValid) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Validation failed: ${validation.errors.join(', ')}');
        // Don't throw - log error but continue with sanitized data
      }

      // 1. Convert Workout to WorkoutHistoryDetail (with sanitized data)
      final exercisesHistory = workout.exercises.map((exercise) {
        // 🔒 Sanitize exercise data
        final sanitizedExerciseName = InputSanitizer.sanitizeName(exercise.name);
        final sanitizedExerciseNotes = InputSanitizer.sanitizeText(exercise.notes ?? '', maxLength: 500);

        final setsHistory = exercise.sets.map((set) {
          // 🔒 Sanitize set notes
          final sanitizedSetNotes = set.notes != null
              ? InputSanitizer.sanitizeText(set.notes!, maxLength: 200)
              : null;

          return SetHistoryDetail(
            setNumber: set.setNumber,
            weight: double.tryParse(set.weight.toString()) ?? 0.0,
            reps: int.tryParse(set.reps.toString()) ?? 0,
            rpe: set.rpe ?? 0,
            notes: sanitizedSetNotes,
            isWarmup: set.isWarmup,
            // ✅ TUT & Advanced Tracking Fields
            setDurationMillis: set.setDurationMillis,
            setStartedAt: set.setStartedAt,
            completedAt: set.completedAt,
            actualReps: set.actualReps,
          );
        }).toList();

        return ExerciseHistoryDetail(
          id: exercise.id,
          name: sanitizedExerciseName,
          category: exercise.category.name,
          notes: sanitizedExerciseNotes,
          sets: setsHistory,
          exerciseData: {},
        );
      }).toList();

      final workoutHistoryDetail = WorkoutHistoryDetail(
        id: workout.id,
        userId: currentUser.uid,
        name: sanitizedWorkoutName,
        description: sanitizedWorkoutNotes,
        createdAt: workout.createdAt,
        startedAt: workout.startTime ?? workout.createdAt,
        completedAt: workout.endTime ?? DateTime.now(),
        updatedAt: workout.updatedAt,
        duration: workout.duration ?? Duration.zero,
        exercises: exercisesHistory,
        metadata: {'source': 'app_completion'},
        templateId: workout.templateId, // ✅ CRITICAL FIX: Pass templateId for routine auto-detection
      );

      // 2. SEMPRE salvare localmente PRIMA (BLOCKING ma veloce ~50ms)
      // Questo garantisce che i dati siano persistenti anche se cloud sync fallisce
      try {
        final hiveDataSource = ref.read(hiveWorkoutDataSourceProvider);
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          final workoutModel = WorkoutModel.fromDomain(workout);
          await hiveDataSource.saveWorkout(workoutModel, userId);

          if (kDebugMode) {
            debugLog(LogCategory.workout, '✅ [WorkoutProvider] Workout saved to Hive local storage');
          }

          // 💾 CACHING: Invalidate analytics cache after workout completion
          try {
            final analyticsRepo = ref.read(workoutAnalyticsRepositoryProvider);
            if (analyticsRepo is WorkoutAnalyticsRepositoryImpl) {
              await analyticsRepo.invalidateAnalyticsCache(userId);
              if (kDebugMode) {
                debugLog(LogCategory.workout, '🗑️ [WorkoutProvider] Analytics cache invalidated for user: $userId');
              }
            }
          } catch (cacheError) {
            // Non-critical error - log but don't fail workout save
            if (kDebugMode) {
              debugLog(LogCategory.workout, '⚠️ [WorkoutProvider] Failed to invalidate analytics cache: $cacheError');
            }
          }

          // 📢 UI Feedback: Show "Workout saved locally" toast
          if (context != null) {
            SyncStatusToast.showWorkoutSavedLocally(context);
          }
        }
      } catch (saveError, stackTrace) {
        if (kDebugMode) {
          debugLog(LogCategory.workout, '❌ [WorkoutProvider] CRITICAL: Failed to save workout locally: $saveError');
          debugLog(LogCategory.workout, '📍 [WorkoutProvider] Stack trace: $stackTrace');
        }

        // 📢 UI Feedback: Show CRITICAL error toast with retry/export options
        if (context != null) {
          SyncStatusToast.showLocalSaveFailed(
            context,
            onRetry: () {
              // Retry local save
              _saveCompletedWorkoutToFirestore(context);
            },
            onExport: () async {
              // Export workout data to JSON and share
              try {
                await _exportWorkoutData(workout);
                if (kDebugMode) {
                  debugLog(LogCategory.workout, '✅ [WorkoutProvider] Workout data exported successfully');
                }
              } catch (e) {
                if (kDebugMode) {
                  debugLog(LogCategory.workout, '❌ [WorkoutProvider] Failed to export workout data: $e');
                }
              }
            },
          );
        }

        // CRITICAL: Se fallisce il save locale, rilanciamo l'errore
        // Non possiamo permettere che i dati vadano persi
        rethrow;
      }

      // CRITICAL FIX: Check disposal after local save
      if (_isDisposed) {
        if (kDebugMode) {
          debugLog(LogCategory.workout, '⚠️ [WorkoutProvider] Provider disposed after local save - aborting cloud sync');
        }
        return;
      }

      // 3. Track entity con SnapshotSyncService per differential sync
      // Calcola checksum e confronta con cloud per determinare se serve sync
      try {
        final snapshotSync = ref.read(snapshotSyncServiceProvider.notifier);

        await snapshotSync.trackEntity(
          collection: 'workouts',
          documentId: workoutHistoryDetail.id,
          data: workoutHistoryDetail.toFirestoreMap(),
        );

        if (kDebugMode) {
          debugLog(LogCategory.workout, '📸 [WorkoutProvider] Workout tracked for differential sync');
        }
      } catch (snapshotError) {
        if (kDebugMode) {
          debugLog(LogCategory.workout, '⚠️ [WorkoutProvider] Failed to track workout snapshot: $snapshotError');
        }
        // Non-critical: continua comunque con batch sync
      }

      // 4. Accoda operazione per cloud sync (NON-BLOCKING)
      // La batch queue gestirà il flush automaticamente dopo 3s o 10 ops
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
          debugLog(LogCategory.workout, '✅ [WorkoutProvider] Workout queued for batch cloud sync');
        }

        // 📢 UI Feedback: Show final success toast
        // Local save complete + cloud sync queued = workout saved successfully
        if (context != null) {
          SyncStatusToast.showWorkoutSaved(context);
        }
      } catch (batchError) {
        if (kDebugMode) {
          debugLog(LogCategory.workout, '⚠️ [WorkoutProvider] Failed to queue cloud sync: $batchError');
        }

        // 📢 UI Feedback: Show warning that cloud sync failed to queue
        // But workout is safe locally
        if (context != null) {
          SyncStatusToast.showCloudSyncQueued(context);
        }

        // Non-critical: workout già salvato localmente
        // La batch queue riproverà o farà sync al prossimo flush
      }

      // 5. Update user stats with transaction to prevent lost updates
      try {
        final firestore = FirebaseFirestore.instance;
        final userRef = firestore.collection('users').doc(currentUser.uid);

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
              }
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
            'stats.totalVolume': currentTotalVolume + workoutHistoryDetail.totalVolume,
            'stats.monthlyWorkouts': currentMonthlyWorkouts + 1,
          });
        });
        debugLog(LogCategory.workout, '✅ [WorkoutProvider] User stats updated atomically');
      } catch (statsError) {
        debugLog(LogCategory.workout, '⚠️ [WorkoutProvider] Failed to update stats: $statsError');
        // Non-critical - workout is already saved
      }

      // CRITICAL FIX: Check disposal after stats update
      if (_isDisposed) {
        debugLog(LogCategory.workout, '⚠️ [WorkoutProvider] Provider disposed after stats update - aborting remaining operations');
        return;
      }

      // 5. Update cached progress stats
      try {
        final cacheRepo = ref.read(progressCacheRepositoryProvider);
        final workoutDate = workout.startTime ?? DateTime.now();
        final dateKey =
            '${workoutDate.year}-${workoutDate.month.toString().padLeft(2, '0')}-${workoutDate.day.toString().padLeft(2, '0')}';
        await cacheRepo.incrementWorkout(dateKey);
        ref.invalidate(cachedProgressProvider);
      } catch (cacheError) {
        ref.invalidate(cachedProgressProvider);
      }

      // 6. Generate intelligent notifications + Achievement notifications
      try {
        final intelligentService = ref.read(intelligentNotificationServiceProvider);
        final notifications = await intelligentService.analyzeWorkoutCompletion(workout);

        // CRITICAL FIX: Check disposal after notification generation
        if (_isDisposed) {
          debugLog(LogCategory.workout, '⚠️ [WorkoutProvider] Provider disposed after notification generation - skipping notification addition');
          return;
        }

        // ✅ NEW: Achievement Notifications with BATCHING (Anti-Spam)
        // Collects all achievements for 3 seconds then sends ONE notification
        try {
          final achievementService = ref.read(achievementNotificationServiceProvider);
          // 1. Detect Personal Records and queue them
          final prUseCase = ref.read(detectPersonalRecordsUseCaseProvider);
          final prs = await prUseCase.execute(currentUser.uid, workout);

          if (prs.isNotEmpty) {
            final queuedCount = await achievementService.notifyMultiplePRs(prs, workoutId: workout.id);
            debugLog(LogCategory.workout, '📦 [Batching] Queued $queuedCount PRs for batch ${workout.id}');
          }

          // 2. Queue Streak Milestone
          final streakAsync = await ref.read(currentStreakProvider.future);
          if (streakAsync > 0) {
            await achievementService.queueStreakAchievement(streakAsync, workoutId: workout.id);
            debugLog(LogCategory.workout, '📦 [Batching] Queued streak milestone: $streakAsync days');
          }

          // 3. Queue Volume Milestone
          final progressData = await ref.read(progressDataProvider.future);
          if (progressData != null && progressData.totalVolume > 0) {
            await achievementService.queueVolumeAchievement(progressData.totalVolume, workoutId: workout.id);
            debugLog(LogCategory.workout, '📦 [Batching] Queued volume milestone: ${progressData.totalVolume}kg');
          }

          debugLog(LogCategory.workout, '📦 [Batching] All achievements queued - will send 1 notification in 3s');
                } catch (achievementError) {
          debugLog(LogCategory.workout, '⚠️ [Achievements] Failed to queue achievement notifications: $achievementError');
          // Non-critical - continue with other operations
        }

        // REMOVED: notification provider bridge (cleanup)
        // Old AI notifications code removed during cleanup
      } catch (notificationError) {
        // Non-critical
      }

      // 7. Auto-complete routine day if applicable
      try {
        final didAutoComplete = await _autoCompleteRoutineDay(workout, context);
        if (didAutoComplete) {
          debugLog(LogCategory.workout, '✅ [Routine] Auto-completed routine day');
        }
      } catch (routineError) {
        debugLog(LogCategory.workout, '⚠️ [Routine] Failed to auto-complete day: $routineError');
        // Non-critical - workout is already saved
      }

      // 8. Navigate to workout completion summary screen (if context available)
      if (context != null) {
        // Use pushNamed to navigate to summary screen
        context.pushNamed(
          'workout-completion-summary',
          extra: workout,
        );

        if (kDebugMode) {
          debugLog(LogCategory.workout, '📊 [WorkoutProvider] Navigated to completion summary screen');
        }
      }

    } catch (e, stackTrace) {
      debugLog(LogCategory.workout, '❌ Critical error saving workout: $e');
      debugLog(LogCategory.workout, 'Stack: $stackTrace');
    }
  }

  /// Auto-complete routine day if workout matches scheduled template
  ///
  /// Uses RoutineAutoCompletionService for robust auto-completion with multi-day support.
  /// Returns true if a routine day was auto-completed, false otherwise.
  Future<bool> _autoCompleteRoutineDay(Workout workout, BuildContext? context) async {
    final autoCompletionService = ref.read(routineAutoCompletionServiceProvider);

    final result = await autoCompletionService.tryAutoCompleteRoutineDay(
      completedWorkout: workout,
      context: context,
    );

    // If multiple candidate dates found, show UI for user selection
    // (For now, we skip this case - will implement UI in next task)
    if (result.candidateDates != null && result.candidateDates!.isNotEmpty) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, 'ℹ️ [WorkoutProvider] Multiple candidate dates found, but UI selection not yet implemented');
        debugLog(LogCategory.workout, '   Candidates: ${result.candidateDates}');
      }
      // TODO: Show DaySelectionBottomSheet for user to pick date
      return false;
    }

    return result.completed;
  }

  /// 📁 Export workout data to JSON file and share
  ///
  /// Creates a JSON file with complete workout data (exercises, sets, reps, etc.)
  /// and shares it using the system share dialog.
  ///
  /// **Use Cases:**
  /// - Backup workout data when local save fails
  /// - Manual data export for external analysis
  /// - Data migration between devices
  ///
  /// **File Format:**
  /// - JSON format with pretty printing
  /// - Filename: workout_YYYY-MM-DD_HH-MM-SS.json
  /// - Contains: workout name, exercises, sets, timestamps, stats
  Future<void> _exportWorkoutData(Workout workout) async {
    try {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '📁 [WorkoutProvider] Exporting workout data: ${workout.name}');
      }

      // 1. Convert workout to JSON
      final workoutJson = workout.toJson();
      final prettyJson = const JsonEncoder.withIndent('  ').convert(workoutJson);

      // 2. Create filename with timestamp
      final timestamp = DateTime.now();
      final filename = 'workout_'
          '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}_'
          '${timestamp.hour.toString().padLeft(2, '0')}-${timestamp.minute.toString().padLeft(2, '0')}-${timestamp.second.toString().padLeft(2, '0')}'
          '.json';

      // 3. Get temporary directory and create file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsString(prettyJson);

      if (kDebugMode) {
        debugLog(LogCategory.workout, '📁 [WorkoutProvider] Created file: ${file.path}');
        debugLog(LogCategory.workout, '📊 [WorkoutProvider] File size: ${await file.length()} bytes');
      }

      // 4. Share file using share_plus
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Workout: ${workout.name}',
        text: 'Workout data export from GymBro TrackLog',
      );

      if (kDebugMode) {
        debugLog(LogCategory.workout, '✅ [WorkoutProvider] Share result: ${result.status}');
      }

      // 5. Clean up temporary file after short delay
      Future.delayed(const Duration(seconds: 5), () async {
        try {
          if (await file.exists()) {
            await file.delete();
            if (kDebugMode) {
              debugLog(LogCategory.workout, '🗑️ [WorkoutProvider] Cleaned up temporary file');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugLog(LogCategory.workout, '⚠️ [WorkoutProvider] Failed to delete temp file: $e');
          }
        }
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error exporting workout: $e');
        debugLog(LogCategory.workout, '📍 [WorkoutProvider] Stack trace: $stackTrace');
      }
      // Rethrow to allow caller to handle error
      rethrow;
    }
  }

  void pauseWorkout() {
    if (state != null) {
      // 📊 Track workout paused
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackWorkoutPaused(
        workoutId: state!.id,
        elapsedSeconds: state!.duration?.inSeconds ?? 0,
      );

      state = state!.pauseWorkout();
    }
  }

  void resumeWorkout() {
    if (state != null) {
      // 📊 Track workout resumed
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackWorkoutResumed(
        workoutId: state!.id,
        pausedSeconds: state!.duration?.inSeconds ?? 0,
      );

      state = state!.resumeWorkout();
    }
  }

  void addExercise(Exercise exercise) {
    if (state == null) return;

    // 🔒 SESSION: Record activity to prevent auto-logout during workout
    ref.read(sessionActivityRecorderProvider);

    try {
      // Check if APRE is enabled globally and exercise doesn't have APRE configured yet
      final config = ref.read(appConfigProvider);
      final isApreEnabled = config.enableApre ?? false;

      Exercise exerciseToAdd = exercise;

      // Apply default APRE settings if enabled and exercise doesn't already have auto-adjustment
      if (isApreEnabled && exercise.autoAdjustmentType == null && exercise.type == ExerciseType.single) {
        // Auto-select protocol based on target reps
        final targetReps = exercise.sets.isNotEmpty ? (exercise.sets.first.reps ?? 6) : 6;
        final protocol = APREAutoRegulationService.selectProtocolFromTargetReps(targetReps);

        if (kDebugMode) {
          debugLog(LogCategory.workout, '[APRE] Auto-selected protocol $protocol for ${exercise.name} (target reps: $targetReps)');
        }

        // Get appropriate rest time for protocol
        final restTime = APREAutoRegulationService.getRestTimeForProtocol(
          protocol,
          strengthRestTime: config.strengthRestTime,
          hypertrophyRestTime: config.hypertrophyRestTime,
          enduranceRestTime: config.enduranceRestTime,
          defaultRestTime: config.defaultRestTime,
        );

        exerciseToAdd = exercise.copyWith(
          autoAdjustmentType: AutoAdjustmentType.apre,
          useAPRE: true,
          apreProtocol: protocol,
          restTime: restTime,
        );

        // Calculate base weight from history in background
        _calculateAndSetBaseWeight(exerciseToAdd);
      }

      state = state!.addExercise(exerciseToAdd);

      // 💾 Auto-save modifications
      _autoSaveIfNeeded();

      // 📊 Track exercise added
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackExerciseAdded(
        workoutId: state!.id,
        exerciseId: exerciseToAdd.id,
        exerciseName: exerciseToAdd.name,
        exerciseCategory: exerciseToAdd.category.name,
        sets: exerciseToAdd.sets.length,
        source: 'add_exercise_modal',
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error adding exercise: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void removeExercise(String exerciseId) {
    if (state != null) {
      // 🔒 SESSION: Record activity to prevent auto-logout during workout
      ref.read(sessionActivityRecorderProvider);

      // Find exercise before removing for analytics
      final exercise = state!.exercises.firstWhere(
        (ex) => ex.id == exerciseId,
        orElse: () => Exercise(
          name: 'Unknown',
          type: ExerciseType.single,
          category: ExerciseCategory.other,
          sets: [],
        ),
      );

      state = state!.removeExercise(exerciseId);

      // 💾 Auto-save modifications
      _autoSaveIfNeeded();

      // 📊 Track exercise removed
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackExerciseRemoved(
        workoutId: state!.id,
        exerciseId: exerciseId,
        exerciseName: exercise.name,
      );
    }
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (state == null) return;

    try {
      // Validate indices
      if (oldIndex < 0 || oldIndex >= state!.exercises.length ||
          newIndex < 0 || newIndex >= state!.exercises.length) {
        if (kDebugMode) {
          debugLog(LogCategory.workout, '⚠️ [WorkoutProvider] Invalid reorder indices: old=$oldIndex, new=$newIndex, exercises=${state!.exercises.length}');
        }
        return;
      }

      // Adjust newIndex if moving down
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final exercises = List<Exercise>.from(state!.exercises);
      final exercise = exercises.removeAt(oldIndex);
      exercises.insert(newIndex, exercise);

      state = state!.copyWith(exercises: exercises);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error reordering exercises: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void updateExercise(String exerciseId, Exercise updatedExercise) {
    if (state == null) return;

    try {
      state = state!.updateExercise(exerciseId, updatedExercise);

      // 💾 Auto-save modifications
      _autoSaveIfNeeded();

      // 📊 Track exercise customized
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackExerciseCustomized(
        workoutId: state!.id,
        exerciseId: updatedExercise.id,
        fieldChanged: 'exercise_data',
        oldValue: 'previous_state',
        newValue: 'updated_state',
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error updating exercise: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// Check if an exercise has completed sets
  /// Returns number of completed sets
  int getCompletedSetsCount(String exerciseId) {
    if (state == null) return 0;

    try {
      final exercise = state!.exercises.firstWhere(
        (e) => e.id == exerciseId,
        orElse: () => throw Exception('Exercise not found'),
      );

      return exercise.sets.where((set) => set.isCompleted).length;
    } catch (e) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error checking completed sets: $e');
      }
      return 0;
    }
  }

  /// Change the counting mode of an exercise (weighted/reps/time)
  /// Used when user needs to fix template counting format during workout
  void changeExerciseCountingMode(
    String exerciseId,
    ExerciseCountingMode newMode,
  ) {
    if (state == null) return;

    try {
      // Find exercise
      final exercise = state!.exercises.firstWhere(
        (e) => e.id == exerciseId,
        orElse: () => throw Exception('Exercise not found'),
      );

      // Create updated exercise with new counting mode
      final updatedExercise = exercise.copyWith(
        countingMode: newMode,
        updatedAt: DateTime.now(),
      );

      // Update exercise in state
      updateExercise(exerciseId, updatedExercise);

      // 📊 Track counting mode changed
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackExerciseCustomized(
        workoutId: state!.id,
        exerciseId: exerciseId,
        fieldChanged: 'counting_mode',
        oldValue: exercise.countingMode.name,
        newValue: newMode.name,
      );

      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '✅ [WorkoutProvider] Counting mode changed: ${exercise.name} → ${newMode.name}',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error changing counting mode: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void updateExerciseOnly(Exercise updatedExercise) {
    // print('🔄 updateExerciseOnly called with exercise: ${updatedExercise.name}');

    if (state == null) {
      // print('⚠️ State is null, cannot update exercise');
      return;
    }
    
    try {
      // print('🔄 Current exercises count: ${state!.exercises.length}');
      
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == updatedExercise.id) {
          // print('✅ Found matching exercise to update: ${exercise.name} -> ${updatedExercise.name}');
          return updatedExercise;
        }
        return exercise;
      }).toList();

      // print('🔄 Updated exercises count: ${updatedExercises.length}');
      state = state!.copyWith(exercises: updatedExercises);

      // 💾 Auto-save modifications
      _autoSaveIfNeeded();

      // print('✅ State updated successfully');
    } catch (e) {
      // print('❌ Error updating exercise: $e');
      // print('Stack: $stackTrace');
    }
  }

  void completeSet(String exerciseId, String setId) {
    if (state == null) return;

    // 🔒 SESSION: Record activity to prevent auto-logout during workout
    ref.read(sessionActivityRecorderProvider);

    try {
      // Track which exercise and set were completed for auto-timer
      Exercise? targetExercise;
      int completedSetNumber = 0;
      int totalSets = 0;
      ExerciseSet? completedSet;

      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId) {
          targetExercise = exercise;
          totalSets = exercise.sets.length;

          final updatedSets = exercise.sets.map((set) {
            if (set.id == setId) {
              completedSetNumber = set.setNumber;
              completedSet = set;
              return set.copyWith(isCompleted: true);
            }
            return set;
          }).toList();
          return exercise.copyWith(sets: updatedSets);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      // 📊 Track set completed
      if (targetExercise != null && completedSet != null) {
        final analytics = ref.read(analyticsServiceProvider);
        final tracker = WorkoutEventTracker(analytics);

        tracker.trackSetCompleted(
          workoutId: state!.id,
          exerciseId: targetExercise!.id,
          setNumber: completedSetNumber,
          reps: completedSet!.reps ?? 0,
          weight: completedSet!.weight?.toDouble(),
          rpe: completedSet!.rpe,
        );
      }

      // ✅ BUG #2 FIX: Auto-start rest timer after completing a set
      if (targetExercise != null && completedSetNumber > 0) {
        // Check if not the last set
        final isLastSet = completedSetNumber >= totalSets;

        if (!isLastSet) {
          // Get rest time from exercise (default 90 seconds)
          final restTime = targetExercise!.restTime ?? 90;
          final nextSetNumber = completedSetNumber + 1;

          if (kDebugMode) {
            debugLog(LogCategory.workout, '⏰ [AUTO-TIMER] Starting rest timer after set $completedSetNumber/$totalSets');
            debugLog(LogCategory.workout, '⏰ [AUTO-TIMER] Duration: ${restTime}s for next set $nextSetNumber');
          }

          // Start the timer automatically
          ref.read(unifiedTimerProvider.notifier).startTimer(
            durationSeconds: restTime,
            exerciseName: targetExercise!.name,
            currentSet: nextSetNumber,
            totalSets: totalSets,
            exerciseId: targetExercise!.id,
          );
        } else {
          if (kDebugMode) {
            debugLog(LogCategory.workout, '⏰ [AUTO-TIMER] Last set completed - no timer started');
          }
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error completing set: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void updateExerciseSet(String exerciseId, ExerciseSet updatedSet) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId) {
          final updatedSets = exercise.sets.map((set) {
            if (set.id == updatedSet.id) {
              return updatedSet;
            }
            return set;
          }).toList();
          return exercise.copyWith(sets: updatedSets);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      // 💾 Auto-save modifications
      _autoSaveIfNeeded();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error updating exercise set: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void updateSupersetSet(String exerciseId, SupersetSet updatedSupersetSet) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId && exercise is SupersetExercise) {
          final updatedSupersetSets = exercise.supersetSets.map((set) {
            // ✅ FIX: Usa setNumber invece di id per identificare il round
            // Tutti i round creati insieme hanno lo stesso ID (timestamp),
            // ma setNumber è univoco (1, 2, 3, etc.)
            if (set.setNumber == updatedSupersetSet.setNumber) {
              return updatedSupersetSet;
            }
            return set;
          }).toList();
          return exercise.copyWith(supersetSets: updatedSupersetSets);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error updating superset set: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void addSetToExercise(String exerciseId) {
    if (state == null) return;

    // 🔒 SESSION: Record activity to prevent auto-logout during workout
    ref.read(sessionActivityRecorderProvider);

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId) {
          final newSetNumber = exercise.sets.length + 1;
          final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;

          final newSet = ExerciseSet(
            setNumber: newSetNumber,
            weight: lastSet?.weight ?? 0,
            reps: lastSet?.reps ?? 10,
          );

          return exercise.copyWith(sets: [...exercise.sets, newSet]);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error adding set to exercise: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void removeSetFromExercise(String exerciseId, String setId) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId) {
          final updatedSets = exercise.sets.where((set) => set.id != setId).toList();

          // Prevent removing last set
          if (updatedSets.isEmpty) {
            if (kDebugMode) {
              debugLog(LogCategory.workout, '⚠️ [WorkoutProvider] Cannot remove last set from exercise');
            }
            return exercise;
          }

          // Renumber sets
          for (int i = 0; i < updatedSets.length; i++) {
            updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
          }

          return exercise.copyWith(sets: updatedSets);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error removing set from exercise: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// Aggiunge un nuovo round a un superset
  void addRoundToSuperset(String supersetId) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == supersetId && exercise is SupersetExercise) {
          final newRoundNumber = exercise.supersetSets.length + 1;
          final lastRound = exercise.supersetSets.isNotEmpty
              ? exercise.supersetSets.last
              : null;

          // Crea exerciseData per tutti gli esercizi del superset
          final Map<String, SupersetExerciseData> exerciseData = {};

          for (final ex in exercise.exercises) {
            // Usa i dati dell'ultimo round come template, o valori di default
            final lastData = lastRound?.exerciseData[ex.id];
            exerciseData[ex.id] = SupersetExerciseData(
              exerciseId: ex.id,
              exerciseName: ex.name,
              targetWeight: lastData?.targetWeight ?? lastData?.actualWeight ?? 0.0,
              targetReps: lastData?.targetReps ?? lastData?.actualReps ?? 10,
              actualWeight: null,
              actualReps: null,
              rpe: null,
              isCompleted: false,
              notes: null,
            );
          }

          // ✅ FIX: Genera ID univoco per il nuovo round
          final newRound = SupersetSet(
            id: 'superset_round_${DateTime.now().millisecondsSinceEpoch}_$newRoundNumber',
            setNumber: newRoundNumber,
            exerciseData: exerciseData,
            isCompleted: false,
          );

          return exercise.copyWith(
            supersetSets: [...exercise.supersetSets, newRound]
          );
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error adding round to superset: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// Rimuove un round da un superset
  void removeRoundFromSuperset(String supersetId, String roundId) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == supersetId && exercise is SupersetExercise) {
          final updatedRounds = exercise.supersetSets
              .where((round) => round.id != roundId)
              .toList();

          // Prevent removing last round
          if (updatedRounds.isEmpty) {
            if (kDebugMode) {
              debugLog(LogCategory.workout, '⚠️ [WorkoutProvider] Cannot remove last round from superset');
            }
            return exercise;
          }

          // Renumber rounds
          for (int i = 0; i < updatedRounds.length; i++) {
            updatedRounds[i] = updatedRounds[i].copyWith(setNumber: i + 1);
          }

          return exercise.copyWith(supersetSets: updatedRounds);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error removing round from superset: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// 🔄 Undo workout completion - restore to "in progress" state
  ///
  /// Reverts a completed workout back to active state, allowing user to continue.
  /// Used for the undo pattern after workout completion.
  void undoCompletion() {
    if (state != null && state!.isCompleted) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '🔄 [WorkoutProvider] Undoing workout completion: ${state!.name}');
      }

      // Restore workout to active state
      state = state!.copyWith(
        status: WorkoutStatus.inProgress,
        endTime: null,
      );

      // Haptic feedback for undo action
      HapticFeedbackService.exerciseCompletion(ref);

      // Re-enable wakelock
      ref.read(screenWakelockProvider.notifier).startWakelock();

      // 📊 Track undo action
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackWorkoutResumed(
        workoutId: state!.id,
        pausedSeconds: state!.duration?.inSeconds ?? 0,
      );
    }
  }

  void clearWorkout() {
    try {
      // 💾 DEFENSIVE FIX: Force save any pending template modifications before clearing
      // This acts as a safety net in case clearWorkout is called directly
      if (_currentTemplateId != null && state != null) {
        final cacheService = ref.read(workoutTemplateCacheServiceProvider);
        cacheService.forceSave(); // Non-blocking, triggers immediate save
      }

      // 📊 Track workout cancelled if there was an active workout
      if (state != null) {
        final analytics = ref.read(analyticsServiceProvider);
        final tracker = WorkoutEventTracker(analytics);

        tracker.trackWorkoutCancelled(
          workoutId: state!.id,
          elapsedSeconds: state!.duration?.inSeconds ?? 0,
          exerciseCount: state!.exercises.length,
        );
      }

      state = null;

      // Disattiva wakelock quando si cancella il workout
      ref.read(screenWakelockProvider.notifier).stopWakelock();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error clearing workout: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Ensure state is cleared even if wakelock fails
      state = null;
    }
  }

  /// Pre-calculate APRE weights for all exercises when starting workout
  Future<void> _preCalculateAllAPREWeights() async {
    if (state == null) return;

    // CRITICAL FIX: Prevent concurrent APRE calculations
    if (_apreCalculationInProgress) {
      debugLog(LogCategory.workout, '[APRE] ⚠️ Calculation already in progress - skipping duplicate request');
      return;
    }

    _apreCalculationInProgress = true;
    debugLog(LogCategory.workout, '[APRE] 🔒 Calculation started - locking concurrent access');

    try {
      await _preCalculateAllAPREWeightsInternal();
    } finally {
      _apreCalculationInProgress = false;
      debugLog(LogCategory.workout, '[APRE] 🔓 Calculation complete - unlocking');
    }
  }

  /// Internal method for APRE calculation (called with lock held)
  Future<void> _preCalculateAllAPREWeightsInternal() async {
    debugLog(LogCategory.workout, '[APRE] Pre-calculating weights for all APRE exercises...');

    // Get all exercises with APRE enabled that need calculation
    final apreExercises = state!.exercises
        .where((ex) => ex.useAPRE && ex.type == ExerciseType.single)
        .toList();

    if (apreExercises.isEmpty) {
      debugLog(LogCategory.workout, '[APRE] No APRE exercises to calculate');
      return;
    }

    debugLog(LogCategory.workout, '[APRE] Found ${apreExercises.length} APRE exercises to process');
    for (final ex in apreExercises) {
      debugLog(LogCategory.workout, '[APRE]   - ${ex.name}: protocol=${ex.apreProtocol}, cached1RM=${ex.calculated1RM?.toStringAsFixed(1)}');
    }

    // Calculate weights for each exercise in parallel
    final futures = apreExercises.map((exercise) async {
      // Skip if calculations are recent AND values exist
      if (exercise.calculated1RM != null &&
          !APREAutoRegulationService.shouldRecalculate(exercise)) {
        debugLog(LogCategory.workout, '[APRE] Skipping ${exercise.name} - calculations are recent and exist');
        debugLog(LogCategory.workout, '[APRE]   Existing 1RM: ${exercise.calculated1RM?.toStringAsFixed(1)}kg');
        return null;
      }

      try {
        // Get exercise history
        final historyData = await ref.read(exerciseHistoryFromWorkoutsProvider(exercise.name).future);

        if (historyData.isEmpty) {
          debugLog(LogCategory.workout, '[APRE] No history for ${exercise.name}');
          return null;
        }

        // Calculate APRE weights with user's preferred config
        final config = await ref.read(apreCalculationConfigProvider.future);
        final calculations = APREAutoRegulationService.calculateAPREWeights(
          historicalSets: historyData,
          protocol: exercise.apreProtocol ?? 6,
          useMetricSystem: true,
          config: config,
        );

        if (calculations.isEmpty) {
          debugLog(LogCategory.workout, '[APRE] No calculations returned for ${exercise.name}');
          return null;
        }

        debugLog(LogCategory.workout, '[APRE] Calculations for ${exercise.name}:');
        debugLog(LogCategory.workout, '[APRE]   1RM: ${calculations['calculated1RM']?.toStringAsFixed(1)}kg');
        debugLog(LogCategory.workout, '[APRE]   3RM: ${calculations['calculated3RM']?.toStringAsFixed(1)}kg');
        debugLog(LogCategory.workout, '[APRE]   6RM: ${calculations['calculated6RM']?.toStringAsFixed(1)}kg');
        debugLog(LogCategory.workout, '[APRE]   10RM: ${calculations['calculated10RM']?.toStringAsFixed(1)}kg');

        // Return updated exercise
        return exercise.copyWith(
          apreBaseWeight: calculations['baseWeight']?.toDouble(),
          calculated1RM: calculations['calculated1RM']?.toDouble(),
          calculated3RM: calculations['calculated3RM']?.toDouble(),
          calculated6RM: calculations['calculated6RM']?.toDouble(),
          calculated10RM: calculations['calculated10RM']?.toDouble(),
          lastCalculationDate: DateTime.now(),
          calculationMetadata: calculations['metadata'],
        );
      } catch (e) {
        debugLog(LogCategory.workout, '[APRE] Error calculating for ${exercise.name}: $e');
        return null;
      }
    });

    // Wait for all calculations to complete
    final results = await Future.wait(futures);

    // CRITICAL FIX: Check disposal state before updating state
    if (_isDisposed) {
      debugLog(LogCategory.workout, '[APRE] ⚠️ Provider disposed during calculations - aborting state update');
      return;
    }

    // Update state with calculated exercises
    if (state != null) {
      final updatedExercises = state!.exercises.map((exercise) {
        // Find if this exercise was updated
        final updatedExercise = results.firstWhere(
          (result) => result != null && result.id == exercise.id,
          orElse: () => null,
        );
        return updatedExercise ?? exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);
      debugLog(LogCategory.workout, '[APRE] Pre-calculation complete for ${results.where((r) => r != null).length} exercises');
    }
  }

  /// Calculate and set base weight for APRE from exercise history
  Future<void> _calculateAndSetBaseWeight(Exercise exercise) async {
    try {
      // Skip if calculations are recent AND values exist
      if (exercise.calculated1RM != null &&
          !APREAutoRegulationService.shouldRecalculate(exercise)) {
        debugLog(LogCategory.workout, '[APRE] Using cached calculations for ${exercise.name}');
        debugLog(LogCategory.workout, '[APRE]   Cached 1RM: ${exercise.calculated1RM?.toStringAsFixed(1)}kg');
        return;
      }

      // Get exercise history from Firebase
      final historyData = await ref.read(exerciseHistoryFromWorkoutsProvider(exercise.name).future);

      if (historyData.isEmpty) {
        debugLog(LogCategory.workout, '⚠️ [APRE] No history for ${exercise.name}, skipping base weight calculation');
        return;
      }

      // Calculate APRE weights using the service with user's preferred config
      final config = await ref.read(apreCalculationConfigProvider.future);
      final calculations = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: historyData,
        protocol: exercise.apreProtocol ?? 6,
        useMetricSystem: true, // TODO: Get from user settings
        config: config,
      );

      if (calculations.isEmpty) {
        debugLog(LogCategory.workout, '⚠️ [APRE] Could not calculate weights for ${exercise.name}');
        return;
      }

      // CRITICAL FIX: Check disposal state before updating state
      if (_isDisposed) {
        debugLog(LogCategory.workout, '[APRE] ⚠️ Provider disposed during calculation - aborting state update');
        return;
      }

      // Update exercise with calculated values
      if (state != null) {
        final updatedExercises = state!.exercises.map((ex) {
          if (ex.id == exercise.id) {
            return ex.copyWith(
              apreBaseWeight: calculations['baseWeight']?.toDouble(),
              calculated1RM: calculations['calculated1RM']?.toDouble(),
              calculated3RM: calculations['calculated3RM']?.toDouble(),
              calculated6RM: calculations['calculated6RM']?.toDouble(),
              calculated10RM: calculations['calculated10RM']?.toDouble(),
              lastCalculationDate: DateTime.now(),
              calculationMetadata: calculations['metadata'],
            );
          }
          return ex;
        }).toList();

        state = state!.copyWith(exercises: updatedExercises);
      }
    } catch (e) {
      debugLog(LogCategory.workout, '❌ [APRE] Error calculating base weight for ${exercise.name}: $e');
    }
  }

  @override
  void dispose() {
    // CRITICAL FIX: Mark as disposed to prevent async operations from modifying state
    _isDisposed = true;
    debugLog(LogCategory.workout, '🔒 [WorkoutProvider] Provider disposed - blocking future async operations');

    // Cancel cleanup timer
    _cleanupTimer?.cancel();

    super.dispose();
  }
}

// Workout history provider (for future implementation)
final workoutHistoryProvider = StateNotifierProvider<WorkoutHistoryNotifier, List<Workout>>((ref) {
  return WorkoutHistoryNotifier();
});

class WorkoutHistoryNotifier extends StateNotifier<List<Workout>> {
  WorkoutHistoryNotifier() : super([]);

  void addCompletedWorkout(Workout workout) {
    if (workout.isCompleted) {
      state = [workout, ...state];
    }
  }

  void removeWorkout(String workoutId) {
    state = state.where((w) => w.id != workoutId).toList();
  }

  List<Workout> getWorkoutsByDateRange(DateTime start, DateTime end) {
    return state.where((workout) {
      if (workout.startTime == null) return false;
      return workout.startTime!.isAfter(start) && workout.startTime!.isBefore(end);
    }).toList();
  }
}

// Exercise templates provider
final exerciseTemplatesProvider = Provider<Map<ExerciseCategory, List<String>>>((ref) {
  return WorkoutTemplate.exerciseDatabase;
});

// Exercise search provider
final exerciseSearchProvider = StateProvider<String>((ref) => '');

final filteredExercisesProvider = Provider<List<String>>((ref) {
  final searchQuery = ref.watch(exerciseSearchProvider);
  
  if (searchQuery.isEmpty) {
    return [];
  }
  
  return WorkoutTemplate.searchExercises(searchQuery);
});

// Selected exercise category for modal
final selectedExerciseCategoryProvider = StateProvider<ExerciseCategory>((ref) {
  return ExerciseCategory.chest;
});

// Selected exercise type for modal
final selectedExerciseTypeProvider = StateProvider<ExerciseType>((ref) {
  return ExerciseType.single;
});

/// Provider for fetching workouts from the last N days
///
/// Usage: ref.watch(recentWorkoutsProvider(7)) → Last 7 days
///
/// Returns: List of Workout filtered by:
/// - startTime is not null
/// - startTime is after cutoff date (now - N days)
///
/// Throws: Exception if repository fetch fails
final recentWorkoutsProvider = FutureProvider.family<List<Workout>, int>(
  (ref, days) async {
    final repository = ref.watch(workoutRepositoryProvider);
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    final result = await repository.getWorkouts(limit: 50);

    return result.fold(
      (failure) => throw Exception('Failed to load workouts: ${failure.message}'),
      (workouts) => workouts.where((w) =>
        w.startTime != null &&
        w.startTime!.isAfter(cutoffDate)
      ).toList(),
    );
  },
);