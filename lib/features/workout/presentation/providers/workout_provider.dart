import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';
import 'dart:async';
import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart'
    as wt;
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/hybrid_exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/screen_wakelock_provider.dart';
// Auto-sync for cached progress stats
import 'package:gymbro_flutter_new/features/progress/presentation/providers/cached_progress_provider.dart';
// Progress providers for streak and volume tracking
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';
// App config for workout settings
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
// Exercise history provider
// 🔒 Feature Flags
// 🔒 Security: Input validation & sanitization (consolidated)
import 'package:gymbro_flutter_new/shared/domain/services/input_validator.dart';
// Haptic feedback
import 'package:gymbro_flutter_new/shared/presentation/services/haptic_feedback_service.dart';
// ⏱️ Unified Timer for rest timer auto-start
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_extensions.dart';
// 🏋️ TimerType enum for inter-exercise timer
import 'package:gymbro_flutter_new/features/timer/domain/models/unified_timer_state.dart';
// 🔄 Firestore Batch Writer for optimized cloud sync
import 'package:gymbro_flutter_new/shared/data/services/firestore_batch_writer.dart';
// 📸 Snapshot Sync Service for differential cloud sync
import 'package:gymbro_flutter_new/shared/data/services/snapshot_sync_service.dart';
// 📢 Sync Status Toast for user feedback during save flow
import 'package:gymbro_flutter_new/shared/presentation/widgets/sync_status_toast.dart';
// ⚠️ ROUTINE FEATURE DISABLED (v2.0 API migration pending)
// 🔄 Routine Auto-Completion Service for automatic day completion (disabled)
// 💾 Workout Repository for fetching workout data
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';
// import 'package:gymbro_flutter_new/features/routine/application/services/routine_auto_completion_service.dart';
// ✅ NEW: Recovery detection for missed workouts (disabled)
// import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
// 📊 Analytics Tracking for workout events & PR detection
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/workout_analytics_repository_impl.dart';
// 📊 Exercise Records Cache for Exercise Detail Screen
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_records_provider.dart';
// 📊 Analytics Repository for updating analytics collection
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
// 📈 Stress Index for training load tracking
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
// 📊 Workout to Analytics Converter utility
import 'package:gymbro_flutter_new/features/analytics/data/converters/workout_to_analytics_converter.dart';
import 'package:gymbro_flutter_new/core/analytics/trackers/workout_event_tracker.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
// 💾 Template Cache Service for auto-saving modifications
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_template_cache_service.dart';
// 🔒 Session Timeout: Record activity to prevent auto-logout during workouts
import 'package:gymbro_flutter_new/shared/domain/auth/providers/security_providers.dart';
// 🐛 Debug Log Manager for categorized logging
import 'package:gymbro_flutter_new/shared/data/services/debug_log_manager.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/log_category.dart';
// 💾 BUG FIX #5: Auto-save provider for draft recovery
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_auto_save_provider.dart';
// 🏆 PR Celebration for workout completion achievements
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart'
    as service_pr
    show PersonalRecord;
// 🔔 NOTIFICATIONS: Import for retention notification scheduling
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/personal_record.dart'
    as domain_pr;
import 'package:gymbro_flutter_new/features/analytics/domain/entities/pr_celebration.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
// 📝 Form Cues for Apple Watch
import 'package:gymbro_flutter_new/features/workout/presentation/providers/user_exercise_preferences_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/achievement_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
// 🎮 Gamification: XP awarding on workout completion
import 'package:gymbro_flutter_new/features/home/providers/user_xp_provider.dart';
// ⌚ Apple Watch Connectivity for workout companion updates
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/watch_connectivity_provider.dart';
// 🍎 HealthKit Integration for Apple Fitness / Activity rings sync
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_permission_provider.dart';
// 📏 Body Measurements for bodyweight exercise volume calculation
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_sync_provider.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
// 📚 Exercise Database for real TUT lookup
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
// 📱 iOS 17+ Workout Session Live Activity
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_session_la_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/workout_session_la_service.dart'
    show WorkoutSessionMode;

// Hybrid Exercise Activity Repository provider
final hybridExerciseActivityRepositoryProvider =
    Provider<HybridExerciseActivityRepository>((ref) {
      final localDataSource = ref.watch(hiveWorkoutDataSourceProvider);
      return HybridExerciseActivityRepository(localDataSource: localDataSource);
    });

// Exercise Activity Repository provider (kept for backward compatibility)
final exerciseActivityRepositoryProvider = Provider<ExerciseActivityRepository>(
  (ref) {
    return ExerciseActivityRepository();
  },
);

// NOTE: WorkoutHistoryRepository removed - using unified HybridWorkoutRepository instead

// Current workout state provider
final currentWorkoutProvider =
    NotifierProvider<CurrentWorkoutNotifier, Workout?>(
      CurrentWorkoutNotifier.new,
    );

class CurrentWorkoutNotifier extends Notifier<Workout?> {
  @override
  Workout? build() {
    // 🔒 CRITICAL FIX: Keep provider alive even when no widgets are listening!
    // Without this, the provider is disposed when user navigates away from WorkoutScreen,
    // causing workout data loss. This is the ROOT CAUSE of the workout loss bug.
    // See: https://codewithandrea.com/articles/flutter-riverpod-data-caching-providers-lifecycle/
    ref.keepAlive();

    _startCleanupTimer();
    ref.onDispose(() {
      _isDisposed = true;
      _cleanupTimer?.cancel();
    });
    return null;
  }

  // CRITICAL FIX: Track disposal state to prevent operations after dispose
  bool _isDisposed = false;

  // 💾 Track current template ID for auto-save
  String? _currentTemplateId;

  // 🧹 Cleanup timer fields
  Timer? _cleanupTimer;
  bool _timerPaused = false;

  // ⌚ Debounce for Watch set completion (prevents duplicate processing)
  DateTime? _lastWatchSetCompletion;
  String? _lastCompletedSetId;

  // 💾 Helper method to auto-save modifications
  void _autoSaveIfNeeded() {
    // Save to template cache (for template modifications)
    if (_currentTemplateId != null && state != null) {
      final cacheService = ref.read(workoutTemplateCacheServiceProvider);
      cacheService.saveWorkoutModifications(
        templateId: _currentTemplateId!,
        workout: state!,
      );
    }

    // 💾 BUG FIX #5: Also save to draft repository for crash recovery
    // This prevents losing workout data if app crashes or is killed
    if (state != null && state!.status == WorkoutStatus.inProgress) {
      ref.read(workoutAutoSaveProvider.notifier).triggerSave(state!);
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
      preloadExpiry: DateTime.now().add(
        const Duration(minutes: 15),
      ), // 15-min timeout
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

    // ✅ FIX: Use toWorkoutExercise() to properly handle superset/dropset types
    final exercises = template.exercises.map((templateExercise) {
      return templateExercise.toWorkoutExercise();
    }).toList();

    state = workout.copyWith(
      name: template.name,
      exercises: exercises,
      isPreloaded: false, // No longer pre-loaded
      exercisesModified: true, // Track modification
    );

    _autoSaveIfNeeded();
  }

  void createWorkout(String name, {String? templateId}) {
    state = Workout(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      templateId: templateId, // ✅ FIX: Pass templateId for duration tracking
    );
    _currentTemplateId =
        templateId; // Set template ID for auto-save (null for manual workouts)
  }

  void startFromTemplate(wt.WorkoutTemplate workoutTemplate) async {
    try {
      // 💾 Store template ID for auto-save
      _currentTemplateId = workoutTemplate.id;

      // 💾 Check if there's a cached version of this template
      final cacheService = ref.read(workoutTemplateCacheServiceProvider);
      final cachedWorkout = await cacheService.getCachedWorkout(
        workoutTemplate.id,
      );

      Workout workout;

      if (cachedWorkout != null) {
        // Use cached version with modifications
        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '💾 [WorkoutProvider] Loading cached workout for template: ${workoutTemplate.name}',
          );
        }
        workout = cachedWorkout;
      } else {
        // Crea un nuovo workout dal template
        // ✅ FIX: Use toWorkoutExercise() to properly handle superset/dropset types
        workout = Workout(
          id: const Uuid().v4(),
          name: workoutTemplate.name,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          templateId: workoutTemplate
              .id, // ✅ CRITICAL FIX: Pass templateId for routine auto-detection
          exercises: workoutTemplate.exercises.map((templateExercise) {
            return templateExercise.toWorkoutExercise();
          }).toList(),
        );
      }

      // Imposta il workout e lo avvia automaticamente
      state = workout.startWorkout();

      // 📊 Track workout started from template
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      unawaited(
        tracker.trackWorkoutStarted(
        workoutId: workout.id,
        workoutType: 'strength', // Default type
        workoutName: workout.name,
        source: 'template',
        templateId: workoutTemplate.id,
        ),
      );

      // Attiva wakelock se abilitato nelle impostazioni
      unawaited(
        ref.read(screenWakelockProvider.notifier).startWakelock(),
      );

      // ⌚ Notify Apple Watch about workout start
      _notifyWatchWorkoutStarted();

      // 📱 Start iOS 17+ Workout Session Live Activity
      if (Platform.isIOS) {
        debugPrint(
          '[WorkoutProvider] 📱 Starting LA for template workout: ${state!.name}',
        );
        unawaited(
          ref.read(workoutSessionLAProvider.notifier).startLiveActivity(state!),
        );
      }

      // Incrementa il contatore di utilizzo del template
      // Questo verrà gestito dal template provider
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error starting workout from template: $e',
        );
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

      // 💾 BUG FIX #5: Start auto-save when workout starts
      ref.read(workoutAutoSaveProvider.notifier).startAutoSave(state!);

      // Attiva wakelock se abilitato nelle impostazioni
      ref.read(screenWakelockProvider.notifier).startWakelock();

      // ⌚ Notify Apple Watch about workout start
      _notifyWatchWorkoutStarted();

      // 📱 Start iOS 17+ Workout Session Live Activity
      if (Platform.isIOS) {
        ref.read(workoutSessionLAProvider.notifier).startLiveActivity(state!);
      }
    }
  }

  /// ⌚ Notify Apple Watch that workout has started
  void _notifyWatchWorkoutStarted() {
    debugPrint('⌚ [FLUTTER DEBUG] _notifyWatchWorkoutStarted called');

    if (state == null) {
      debugPrint('⌚ [FLUTTER DEBUG] ❌ state is null, returning');
      return;
    }

    final workout = state!;
    final firstExercise = workout.exercises.isNotEmpty
        ? workout.exercises.first
        : null;

    debugPrint('⌚ [FLUTTER DEBUG] Workout: ${workout.name}');
    debugPrint(
      '⌚ [FLUTTER DEBUG] First exercise: ${firstExercise?.name ?? "none"}',
    );
    debugPrint('⌚ [FLUTTER DEBUG] Exercise count: ${workout.exercises.length}');

    // ⌚ Setup callbacks for Watch → iPhone communication
    final watchNotifier = ref.read(watchConnectivityProvider.notifier);
    watchNotifier.onSetCompletedFromWatch = completeCurrentSetFromWatch;
    watchNotifier.onSkipRestFromWatch = _skipRestFromWatch;
    watchNotifier.onHealthMetricsFromWatch = _handleHealthMetricsFromWatch;
    watchNotifier.onEndWorkoutFromWatch = _endWorkoutFromWatch;
    watchNotifier.onEditCompletedSetRepsFromWatch =
        _editCompletedSetRepsFromWatch;
    watchNotifier.onUncompleteSetFromWatch = _uncompleteSetFromWatch;
    watchNotifier.onSetModificationFromWatch = _updateCurrentSetTargetFromWatch;
    watchNotifier.onSupersetRoundCompletedFromWatch =
        _completeSupersetRoundFromWatch;
    // 🔥 DROPSET: Register callbacks
    watchNotifier.onDropsetStageCompletedFromWatch =
        _completeDropsetStageFromWatch;
    watchNotifier.onDropsetCompletedFromWatch = _completeDropsetFromWatch;
    // 🔥 REST-PAUSE: Register callbacks
    watchNotifier.onRestPauseSetCompletedFromWatch =
        _completeRestPauseSetFromWatch;
    watchNotifier.onRestPauseCompletedFromWatch = _completeRestPauseFromWatch;
    // 🔄 Navigation & Copy callbacks from Watch
    watchNotifier.onJumpToExerciseFromWatch = _jumpToExerciseFromWatch;
    watchNotifier.onJumpToSetFromWatch = _jumpToSetFromWatch;
    watchNotifier.onCopyToAllSetsFromWatch = _copyToAllSetsFromWatch;
    watchNotifier.onCopyFromPreviousSetFromWatch =
        _copyFromPreviousSetFromWatch;
    watchNotifier.onStartNewTimerFromWatch = _startNewTimerFromWatch;
    debugPrint('⌚ [FLUTTER DEBUG] ✅ Watch callbacks registered');

    // Get RPE tracking settings from app config
    final appConfig = ref.read(appConfigProvider);
    final rpeTrackingEnabled = appConfig.rpeTracking ?? false;
    final effortScale = appConfig.effortScale;
    // Get locale for Watch UI strings
    final locale = ref.read(localeProvider).languageCode;
    debugPrint(
      '⌚ [FLUTTER DEBUG] RPE Settings: enabled=$rpeTrackingEnabled, scale=$effortScale, locale=$locale',
    );

    if (firstExercise != null) {
      // 🔥 SUPERSET HANDLING at workout start
      if (firstExercise is SupersetExercise) {
        _handleSupersetWatchStartup(
          superset: firstExercise,
          rpeTrackingEnabled: rpeTrackingEnabled,
          effortScale: effortScale,
          locale: locale,
        );
      } else {
        // 📝 Get Form Cues for the exercise (async, fire and forget)
        // ⌚ Use actual TUT or generate default (same logic as UI)
        final effectiveTut = firstExercise.tut ?? _getDefaultTut(firstExercise);

        // ✅ FIX: Build allSets list for Watch navigation (include actualReps for edit mode)
        final allSets = firstExercise.sets
            .map(
              (s) => {
                'weight': s.weight?.toDouble() ?? 0.0,
                'reps': s.reps ?? 0,
                'actualReps':
                    s.actualReps, // ✅ Reps effettive (null se non completato)
                'isCompleted': s.isCompleted, // ✅ Stato completamento
              },
            )
            .toList();

        _getFormCuesAndNotifyWatch(
          exerciseName: firstExercise.name,
          exerciseId: firstExercise.id,
          currentSet: 1,
          totalSets: firstExercise.sets.length,
          targetWeight: firstExercise.sets.isNotEmpty
              ? firstExercise.sets.first.weight
              : null,
          targetReps: firstExercise.sets.isNotEmpty
              ? firstExercise.sets.first.reps
              : null,
          setsCompleted: 0,
          rpeTrackingEnabled: rpeTrackingEnabled,
          effortScale: effortScale,
          locale: locale,
          tut: effectiveTut, // ⌚ TUT with fallback to default
          isStartup: true,
          allSets: allSets, // ✅ FIX: All sets for Watch navigation
        );
      }
    } else {
      debugPrint('⌚ [FLUTTER DEBUG] No first exercise, using workout name');
      watchNotifier.notifyWorkoutStarted(
        exerciseName: workout.name,
        currentSet: 1,
        totalSets: 1,
        setsCompleted: 0,
        rpeTrackingEnabled: rpeTrackingEnabled,
        effortScale: effortScale,
        locale: locale,
      );
    }
  }

  /// ⌚ Get default TUT based on exercise type (same logic as UI)
  String _getDefaultTut(Exercise exercise) {
    switch (exercise.type) {
      case ExerciseType.single:
        return exercise.category == ExerciseCategory.legs
            ? '3-0-1-0'
            : '2-1-2-0';
      case ExerciseType.superset:
        return '2-0-1-0';
      case ExerciseType.dropset:
        return '2-1-2-0';
      case ExerciseType.restPause:
        return '2-1-2-1';
    }
  }

  /// Helper to get Form Cues and notify Watch
  Future<void> _getFormCuesAndNotifyWatch({
    required String exerciseName,
    String? exerciseId,
    required int currentSet,
    required int totalSets,
    double? targetWeight,
    int? targetReps,
    required int setsCompleted,
    int?
    setsCompletedInExercise, // ✅ Sets completed in current exercise (for edit UI)
    int? lastCompletedReps, // ✅ Actual reps of last completed set (for edit UI)
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
    String? tut, // ⌚ BUG FIX #3: Time Under Tension (e.g., "3-1-2-0")
    bool isStartup = false,
    List<Map<String, dynamic>>? allSets, // ✅ FIX: All sets for Watch navigation
    // 🔄 Exercise navigation support
    List<String>? exerciseNames, // All exercise names in workout
    int currentExerciseIndex = 0, // 0-indexed current exercise position
    // ✅ FIX: Rest time for Watch optimistic timer
    int? restTime, // Rest time in seconds for current exercise
    // 🔥 SUPERSET SUPPORT
    bool isSuperset = false,
    String? supersetName,
    List<String>? supersetExercises,
    int currentExerciseInSuperset = 0,
    int totalExercisesInSuperset = 0,
    int supersetRound = 0,
    int totalSupersetRounds = 0,
    // 🔥 DROPSET SUPPORT
    bool isDropset = false,
    List<Map<String, dynamic>>? dropsetStages,
    int currentDropsetStage = 0,
    int totalDropsetStages = 0,
    // 🔥 REST-PAUSE SUPPORT
    bool isRestPause = false,
    double? restPauseWeight,
    int? restPauseTargetReps,
    List<Map<String, dynamic>>? restPauseSets,
    int currentRestPauseSet = 0,
    int totalRestPauseSets = 0,
  }) async {
    final watchNotifier = ref.read(watchConnectivityProvider.notifier);
    final prefsRepo = ref.read(userExercisePreferencesRepositoryProvider);

    // Fetch Form Cues asynchronously
    String? formCues;
    try {
      formCues = await prefsRepo.getFormCues(exerciseId, exerciseName);
    } catch (e) {
      debugPrint('⌚ [FLUTTER DEBUG] ⚠️ Failed to fetch Form Cues: $e');
    }

    // 📚 Look up real TUT and noteTecniche from exercise database
    String? effectiveTut = tut;
    String? effectiveFormCues = formCues;
    try {
      final exercises = await ref.read(allExercisesProvider.future);
      // Find by name (case-insensitive)
      final normalizedName = exerciseName.toLowerCase().trim();
      final dbExercise = exercises.cast<dynamic>().firstWhere(
        (e) => (e.nome as String?)?.toLowerCase().trim() == normalizedName,
        orElse: () => null,
      );
      if (dbExercise != null) {
        // 📚 TUT from database (tempoEsecuzione)
        if (dbExercise.tempoEsecuzione != null) {
          effectiveTut = dbExercise.tempoEsecuzione as String;
          debugPrint(
            '⌚ [FLUTTER DEBUG] 📚 Found real TUT from database: $effectiveTut',
          );
        } else {
          debugPrint(
            '⌚ [FLUTTER DEBUG] 📚 No database TUT found, using fallback: $tut',
          );
        }
        // 📝 Form Cues fallback from database (noteTecniche)
        if (effectiveFormCues == null && dbExercise.noteTecniche != null) {
          final noteTecniche = dbExercise.noteTecniche as String;
          // Truncate for Watch display (max 500 chars, preserve first steps)
          if (noteTecniche.length > 500) {
            effectiveFormCues = '${noteTecniche.substring(0, 497)}...';
          } else {
            effectiveFormCues = noteTecniche;
          }
          debugPrint(
            '⌚ [FLUTTER DEBUG] 📝 Using noteTecniche as Form Cues fallback',
          );
        }
      } else {
        debugPrint(
          '⌚ [FLUTTER DEBUG] 📚 Exercise not found in database: $exerciseName',
        );
      }
    } catch (e) {
      debugPrint('⌚ [FLUTTER DEBUG] ⚠️ Failed to fetch from database: $e');
    }

    debugPrint(
      '⌚ [FLUTTER DEBUG] Form Cues for $exerciseName: ${effectiveFormCues != null ? "${effectiveFormCues.length} chars (from db: ${effectiveFormCues != formCues})" : "none"}',
    );

    if (isStartup) {
      debugPrint('⌚ [FLUTTER DEBUG] Calling notifyWorkoutStarted with:');
      debugPrint('   - exerciseName: $exerciseName');
      debugPrint('   - currentSet: $currentSet');
      debugPrint('   - totalSets: $totalSets');
      debugPrint(
        '   - formCues: ${effectiveFormCues != null ? "${effectiveFormCues.length} chars" : "none"}',
      );
      debugPrint(
        '   - tut: ${effectiveTut ?? "none"} (from db: ${effectiveTut != tut})',
      );
      debugPrint('   - allSets: ${allSets?.length ?? 0} sets');
      if (isSuperset) {
        debugPrint(
          '   - 🔥 SUPERSET: $supersetName, Ex $currentExerciseInSuperset/$totalExercisesInSuperset, Round $supersetRound/$totalSupersetRounds',
        );
      }
      unawaited(
        watchNotifier.notifyWorkoutStarted(
          exerciseName: exerciseName,
        currentSet: currentSet,
        totalSets: totalSets,
        targetWeight: targetWeight,
        targetReps: targetReps,
        setsCompleted: setsCompleted,
        setsCompletedInExercise: setsCompletedInExercise ?? 0, // ✅ NEW
        lastCompletedReps: lastCompletedReps, // ✅ NEW
        rpeTrackingEnabled: rpeTrackingEnabled,
        effortScale: effortScale,
        locale: locale,
        formCues: effectiveFormCues, // 📝 User saved or noteTecniche fallback
        tut: effectiveTut, // ⌚ Real TUT from database or fallback
        allSets: allSets, // ✅ FIX: All sets for Watch navigation
        // 🔄 Exercise navigation support
        exerciseNames: exerciseNames,
        currentExerciseIndex: currentExerciseIndex,
        // 🔥 SUPERSET SUPPORT
        isSuperset: isSuperset,
        supersetName: supersetName,
        supersetExercises: supersetExercises,
        currentExerciseInSuperset: currentExerciseInSuperset,
        totalExercisesInSuperset: totalExercisesInSuperset,
        supersetRound: supersetRound,
        totalSupersetRounds: totalSupersetRounds,
        // 🔥 DROPSET SUPPORT
        isDropset: isDropset,
        dropsetStages: dropsetStages,
        currentDropsetStage: currentDropsetStage,
        totalDropsetStages: totalDropsetStages,
        // 🔥 REST-PAUSE SUPPORT
        isRestPause: isRestPause,
        restPauseWeight: restPauseWeight,
        restPauseTargetReps: restPauseTargetReps,
        restPauseSets: restPauseSets,
        currentRestPauseSet: currentRestPauseSet,
        totalRestPauseSets: totalRestPauseSets,
        ),
      );
      debugPrint(
        '⌚ [FLUTTER DEBUG] ✅ notifyWorkoutStarted called successfully',
      );
    } else {
      if (isSuperset) {
        debugPrint(
          '⌚ [FLUTTER DEBUG] 🔥 SUPERSET Update: $supersetName, Ex $currentExerciseInSuperset/$totalExercisesInSuperset, Round $supersetRound/$totalSupersetRounds',
        );
      } else if (isDropset) {
        debugPrint(
          '⌚ [FLUTTER DEBUG] 🔥 DROPSET Update: $exerciseName, Stage $currentDropsetStage/$totalDropsetStages',
        );
      } else if (isRestPause) {
        debugPrint(
          '⌚ [FLUTTER DEBUG] 🔥 REST-PAUSE Update: $exerciseName, Set $currentRestPauseSet/$totalRestPauseSets',
        );
      }
      unawaited(
        watchNotifier.sendWorkoutUpdate(
          exerciseName: exerciseName,
        currentSet: currentSet,
        totalSets: totalSets,
        targetWeight: targetWeight,
        targetReps: targetReps,
        setsCompleted: setsCompleted,
        setsCompletedInExercise: setsCompletedInExercise ?? 0, // ✅ NEW
        lastCompletedReps: lastCompletedReps, // ✅ NEW
        rpeTrackingEnabled: rpeTrackingEnabled,
        effortScale: effortScale,
        locale: locale,
        formCues: effectiveFormCues, // 📝 User saved or noteTecniche fallback
        tut: effectiveTut, // ⌚ Real TUT from database or fallback
        allSets: allSets, // ✅ FIX: All sets for Watch navigation
        // 🔄 Exercise navigation support
        exerciseNames: exerciseNames,
        currentExerciseIndex: currentExerciseIndex,
        // ✅ FIX: Rest time for Watch optimistic timer
        restTime: restTime,
        // 🔥 SUPERSET SUPPORT
        isSuperset: isSuperset,
        supersetName: supersetName,
        supersetExercises: supersetExercises,
        currentExerciseInSuperset: currentExerciseInSuperset,
        totalExercisesInSuperset: totalExercisesInSuperset,
        supersetRound: supersetRound,
        totalSupersetRounds: totalSupersetRounds,
        // 🔥 DROPSET SUPPORT
        isDropset: isDropset,
        dropsetStages: dropsetStages,
        currentDropsetStage: currentDropsetStage,
        totalDropsetStages: totalDropsetStages,
        // 🔥 REST-PAUSE SUPPORT
        isRestPause: isRestPause,
        restPauseWeight: restPauseWeight,
        restPauseTargetReps: restPauseTargetReps,
        restPauseSets: restPauseSets,
        currentRestPauseSet: currentRestPauseSet,
        totalRestPauseSets: totalRestPauseSets,
        ),
      );
    }
  }

  /// ⌚ Notify Apple Watch about workout update (exercise/set change)
  void _notifyWatchWorkoutUpdate() {
    if (state == null) return;

    final workout = state!;

    // Get RPE tracking settings from app config
    final appConfig = ref.read(appConfigProvider);
    final rpeTrackingEnabled = appConfig.rpeTracking ?? false;
    final effortScale = appConfig.effortScale;
    // Get locale for Watch UI strings
    final locale = ref.read(localeProvider).languageCode;

    // 🔥 Find current exercise - handle all exercise types (regular, superset, dropset, rest-pause)
    Exercise? currentExercise;
    for (final exercise in workout.exercises) {
      if (exercise is SupersetExercise) {
        // For superset: check if any round is incomplete
        if (exercise.supersetSets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      } else if (exercise is DropSetExercise) {
        // 🔥 FIX: For dropset: check if any STAGE is incomplete (not sets!)
        if (exercise.stages.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      } else if (exercise is RestPauseExercise) {
        // 🔥 FIX: For rest-pause: check if any REST-PAUSE SET is incomplete
        if (exercise.restPauseSets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      } else {
        // For regular exercise: check if any set is incomplete
        if (exercise.sets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      }
    }

    // Calculate total completed sets (including superset rounds, dropset stages, rest-pause sets)
    final completedSets = workout.exercises.fold<int>(0, (total, e) {
      if (e is SupersetExercise) {
        return total + e.supersetSets.where((s) => s.isCompleted).length;
      } else if (e is DropSetExercise) {
        // 🔥 FIX: Count completed STAGES for dropset
        return total + e.stages.where((s) => s.isCompleted).length;
      } else if (e is RestPauseExercise) {
        // 🔥 FIX: Count completed REST-PAUSE SETS
        return total + e.restPauseSets.where((s) => s.isCompleted).length;
      }
      return total + e.sets.where((s) => s.isCompleted).length;
    });

    if (currentExercise == null) return;

    // 🔥 SUPERSET HANDLING
    if (currentExercise is SupersetExercise) {
      _handleSupersetWatchUpdate(
        superset: currentExercise,
        completedSets: completedSets,
        rpeTrackingEnabled: rpeTrackingEnabled,
        effortScale: effortScale,
        locale: locale,
      );
      return;
    }

    // 🔥 DROPSET HANDLING
    if (currentExercise is DropSetExercise) {
      _handleDropSetWatchUpdate(
        dropset: currentExercise,
        completedSets: completedSets,
        rpeTrackingEnabled: rpeTrackingEnabled,
        effortScale: effortScale,
        locale: locale,
      );
      return;
    }

    // 🔥 REST-PAUSE HANDLING
    if (currentExercise is RestPauseExercise) {
      _handleRestPauseWatchUpdate(
        restPause: currentExercise,
        completedSets: completedSets,
        rpeTrackingEnabled: rpeTrackingEnabled,
        effortScale: effortScale,
        locale: locale,
      );
      return;
    }

    // Regular exercise handling
    final currentSetIndex = currentExercise.sets.indexWhere(
      (s) => !s.isCompleted,
    );
    final currentSet = currentSetIndex >= 0
        ? currentExercise.sets[currentSetIndex]
        : null;
    // ⌚ Use actual TUT or generate default (same logic as UI)
    final effectiveTut = currentExercise.tut ?? _getDefaultTut(currentExercise);

    // ✅ FIX: Calculate sets completed IN CURRENT EXERCISE (not total workout)
    final setsCompletedInExercise = currentExercise.sets
        .where((s) => s.isCompleted)
        .length;

    // ✅ FIX: Get actualReps of last completed set in current exercise
    int? lastCompletedReps;
    for (int i = currentExercise.sets.length - 1; i >= 0; i--) {
      if (currentExercise.sets[i].isCompleted) {
        lastCompletedReps =
            currentExercise.sets[i].actualReps ?? currentExercise.sets[i].reps;
        break;
      }
    }

    // ✅ FIX: Build allSets list for Watch navigation (include actualReps for edit mode)
    final allSets = currentExercise.sets
        .map(
          (s) => {
            'weight': s.weight?.toDouble() ?? 0.0,
            'reps': s.reps ?? 0,
            'actualReps':
                s.actualReps, // ✅ Reps effettive (null se non completato)
            'isCompleted': s.isCompleted, // ✅ Stato completamento
          },
        )
        .toList();

    // 🔄 Build exercise names list and find current index for Watch navigation
    final exerciseNames = workout.exercises.map((e) => e.name).toList();
    final currentExerciseIdx = workout.exercises.indexWhere(
      (e) => e.id == currentExercise!.id,
    );

    // 📝 Use async helper to fetch Form Cues and send update
    _getFormCuesAndNotifyWatch(
      exerciseName: currentExercise.name,
      exerciseId: currentExercise.id,
      currentSet: currentSetIndex >= 0
          ? currentSetIndex + 1
          : currentExercise.sets.length,
      totalSets: currentExercise.sets.length,
      targetWeight: currentSet?.weight,
      targetReps: currentSet?.reps,
      setsCompleted: completedSets,
      setsCompletedInExercise: setsCompletedInExercise, // ✅ NEW
      lastCompletedReps: lastCompletedReps, // ✅ NEW
      rpeTrackingEnabled: rpeTrackingEnabled,
      effortScale: effortScale,
      locale: locale,
      tut: effectiveTut, // ⌚ TUT with fallback to default
      isStartup: false,
      allSets: allSets, // ✅ FIX: All sets for Watch navigation
      // 🔄 Exercise navigation support
      exerciseNames: exerciseNames,
      currentExerciseIndex: currentExerciseIdx >= 0 ? currentExerciseIdx : 0,
      // ✅ FIX: Rest time for Watch optimistic timer
      restTime: currentExercise.restTime,
    );
  }

  /// 🔥 Handle superset-specific Watch update
  void _handleSupersetWatchUpdate({
    required SupersetExercise superset,
    required int completedSets,
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
  }) {
    // Find current round (first incomplete)
    final currentRoundIndex = superset.supersetSets.indexWhere(
      (s) => !s.isCompleted,
    );
    if (currentRoundIndex < 0) return;

    final currentRound = superset.supersetSets[currentRoundIndex];
    final totalRounds = superset.supersetSets.length;

    // Find current exercise within the round (first without actualReps)
    int currentExerciseIndex = 0;
    String currentExerciseName = superset.exercises.isNotEmpty
        ? superset.exercises.first.name
        : superset.name;
    String? currentExerciseId;
    double? targetWeight;
    int? targetReps;

    for (int i = 0; i < superset.exercises.length; i++) {
      final ex = superset.exercises[i];
      final data = currentRound.exerciseData[ex.id];
      if (data != null && data.actualReps == null) {
        // This exercise hasn't been completed yet in this round
        currentExerciseIndex = i;
        currentExerciseName = ex.name;
        currentExerciseId = ex.id;
        targetWeight = data.targetWeight;
        targetReps = data.targetReps;
        break;
      }
    }

    // Build exercise names list for Watch display
    final supersetExerciseNames = superset.exercises
        .map((e) => e.name)
        .toList();

    // Rounds completed in this superset
    final roundsCompletedInSuperset = superset.supersetSets
        .where((s) => s.isCompleted)
        .length;

    debugPrint('⌚ [FLUTTER DEBUG] 🔥 SUPERSET Watch Update:');
    debugPrint('   - Superset: ${superset.name}');
    debugPrint('   - Exercises: ${supersetExerciseNames.join(", ")}');
    debugPrint(
      '   - Current Exercise: $currentExerciseName (${currentExerciseIndex + 1}/${superset.exercises.length})',
    );
    debugPrint('   - Round: ${currentRoundIndex + 1}/$totalRounds');

    // Send update with superset info
    _getFormCuesAndNotifyWatch(
      exerciseName: currentExerciseName, // Current sub-exercise name
      exerciseId: currentExerciseId,
      currentSet: currentRoundIndex + 1, // Use round as "set" for Watch display
      totalSets: totalRounds,
      targetWeight: targetWeight,
      targetReps: targetReps,
      setsCompleted: completedSets,
      setsCompletedInExercise: roundsCompletedInSuperset,
      lastCompletedReps: null, // Could calculate if needed
      rpeTrackingEnabled: rpeTrackingEnabled,
      effortScale: effortScale,
      locale: locale,
      tut: superset.tut ?? '2-0-1-0', // Superset default TUT
      isStartup: false,
      allSets: [], // Superset doesn't use allSets navigation
      // 🔥 SUPERSET SUPPORT
      isSuperset: true,
      supersetName: superset.name,
      supersetExercises: supersetExerciseNames,
      currentExerciseInSuperset:
          currentExerciseIndex + 1, // 1-indexed for display
      totalExercisesInSuperset: superset.exercises.length,
      supersetRound: currentRoundIndex + 1, // 1-indexed for display
      totalSupersetRounds: totalRounds,
    );
  }

  /// 🔥 Handle superset-specific Watch startup notification
  void _handleSupersetWatchStartup({
    required SupersetExercise superset,
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
  }) {
    if (superset.supersetSets.isEmpty) {
      debugPrint(
        '⌚ [FLUTTER DEBUG] ⚠️ Superset has no rounds, skipping Watch notification',
      );
      return;
    }

    // Use first round for startup
    final firstRound = superset.supersetSets.first;
    final totalRounds = superset.supersetSets.length;

    // Use first exercise for initial display
    final firstExerciseName = superset.exercises.isNotEmpty
        ? superset.exercises.first.name
        : superset.name;
    final firstExerciseId = superset.exercises.isNotEmpty
        ? superset.exercises.first.id
        : null;

    // Get target from first exercise in first round
    double? targetWeight;
    int? targetReps;
    if (superset.exercises.isNotEmpty) {
      final firstEx = superset.exercises.first;
      final data = firstRound.exerciseData[firstEx.id];
      if (data != null) {
        targetWeight = data.targetWeight;
        targetReps = data.targetReps;
      }
    }

    // Build exercise names list for Watch display
    final supersetExerciseNames = superset.exercises
        .map((e) => e.name)
        .toList();

    debugPrint('⌚ [FLUTTER DEBUG] 🔥 SUPERSET Watch Startup:');
    debugPrint('   - Superset: ${superset.name}');
    debugPrint('   - Exercises: ${supersetExerciseNames.join(", ")}');
    debugPrint('   - First Exercise: $firstExerciseName');
    debugPrint('   - Total Rounds: $totalRounds');

    // Send startup notification with superset info
    _getFormCuesAndNotifyWatch(
      exerciseName: firstExerciseName, // First sub-exercise name
      exerciseId: firstExerciseId,
      currentSet: 1, // First round
      totalSets: totalRounds,
      targetWeight: targetWeight,
      targetReps: targetReps,
      setsCompleted: 0,
      setsCompletedInExercise: 0,
      lastCompletedReps: null,
      rpeTrackingEnabled: rpeTrackingEnabled,
      effortScale: effortScale,
      locale: locale,
      tut: superset.tut ?? '2-0-1-0', // Superset default TUT
      isStartup: true, // This is startup, not update
      allSets: [], // Superset doesn't use allSets navigation
      // 🔥 SUPERSET SUPPORT
      isSuperset: true,
      supersetName: superset.name,
      supersetExercises: supersetExerciseNames,
      currentExerciseInSuperset: 1, // Start at first exercise
      totalExercisesInSuperset: superset.exercises.length,
      supersetRound: 1, // Start at first round
      totalSupersetRounds: totalRounds,
    );
  }

  /// 🔥 Handle dropset-specific Watch update
  void _handleDropSetWatchUpdate({
    required DropSetExercise dropset,
    required int completedSets,
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
  }) {
    // Find current stage (first incomplete)
    final currentStageIndex = dropset.stages.indexWhere(
      (s) => !s.isCompleted,
    );
    if (currentStageIndex < 0) return;

    final currentStage = dropset.stages[currentStageIndex];
    final totalStages = dropset.stages.length;

    // Stages completed in this dropset
    final stagesCompletedInDropset = dropset.stages
        .where((s) => s.isCompleted)
        .length;

    // Build stages data for Watch
    final dropsetStagesData = dropset.stages.asMap().entries.map((entry) {
      final stage = entry.value;
      return {
        'weight': stage.weight,
        'reps': stage.reps,
        'actualReps': stage.actualReps,
        'isCompleted': stage.isCompleted,
      };
    }).toList();

    debugPrint('⌚ [FLUTTER DEBUG] 🔥 DROPSET Watch Update:');
    debugPrint('   - Dropset: ${dropset.name}');
    debugPrint('   - Current Stage: ${currentStageIndex + 1}/$totalStages');
    debugPrint('   - Stage Weight: ${currentStage.weight}kg × ${currentStage.reps} reps');

    // Send update with dropset info
    _getFormCuesAndNotifyWatch(
      exerciseName: dropset.name,
      exerciseId: dropset.id,
      currentSet: currentStageIndex + 1, // Use stage as "set" for Watch display
      totalSets: totalStages,
      targetWeight: currentStage.weight,
      targetReps: currentStage.reps,
      setsCompleted: completedSets,
      setsCompletedInExercise: stagesCompletedInDropset,
      lastCompletedReps: currentStageIndex > 0
          ? dropset.stages[currentStageIndex - 1].actualReps
          : null,
      rpeTrackingEnabled: rpeTrackingEnabled,
      effortScale: effortScale,
      locale: locale,
      tut: dropset.tut ?? '2-1-2-0', // Dropset default TUT
      isStartup: false,
      allSets: [], // Dropset uses stages, not allSets
      restTime: dropset.restTime,
      // 🔥 DROPSET SUPPORT
      isDropset: true,
      dropsetStages: dropsetStagesData,
      currentDropsetStage: currentStageIndex + 1, // 1-indexed for display
      totalDropsetStages: totalStages,
    );
  }

  /// 🔥 Handle rest-pause-specific Watch update
  void _handleRestPauseWatchUpdate({
    required RestPauseExercise restPause,
    required int completedSets,
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
  }) {
    // Find current mini-set (first incomplete)
    final currentSetIndex = restPause.restPauseSets.indexWhere(
      (s) => !s.isCompleted,
    );
    if (currentSetIndex < 0) return;

    final currentSet = restPause.restPauseSets[currentSetIndex];
    final totalSets = restPause.restPauseSets.length;

    // Sets completed in this rest-pause
    final setsCompletedInRestPause = restPause.restPauseSets
        .where((s) => s.isCompleted)
        .length;

    // Build sets data for Watch
    final restPauseSetsData = restPause.restPauseSets.asMap().entries.map((entry) {
      final set = entry.value;
      return {
        'reps': set.reps,
        'actualReps': set.actualReps,
        'restSeconds': set.restSeconds,
        'isCompleted': set.isCompleted,
      };
    }).toList();

    debugPrint('⌚ [FLUTTER DEBUG] 🔥 REST-PAUSE Watch Update:');
    debugPrint('   - Rest-Pause: ${restPause.name}');
    debugPrint('   - Current Set: ${currentSetIndex + 1}/$totalSets');
    debugPrint('   - Weight: ${restPause.weight}kg, Target Reps: ${restPause.targetReps}');

    // Send update with rest-pause info
    _getFormCuesAndNotifyWatch(
      exerciseName: restPause.name,
      exerciseId: restPause.id,
      currentSet: currentSetIndex + 1, // Use mini-set as "set" for Watch display
      totalSets: totalSets,
      targetWeight: restPause.weight,
      targetReps: currentSet.reps,
      setsCompleted: completedSets,
      setsCompletedInExercise: setsCompletedInRestPause,
      lastCompletedReps: currentSetIndex > 0
          ? restPause.restPauseSets[currentSetIndex - 1].actualReps
          : null,
      rpeTrackingEnabled: rpeTrackingEnabled,
      effortScale: effortScale,
      locale: locale,
      tut: restPause.tut ?? '2-1-2-1', // Rest-pause default TUT
      isStartup: false,
      allSets: [], // Rest-pause uses restPauseSets, not allSets
      restTime: restPause.restTime,
      // 🔥 REST-PAUSE SUPPORT
      isRestPause: true,
      restPauseWeight: restPause.weight,
      restPauseTargetReps: restPause.targetReps,
      restPauseSets: restPauseSetsData,
      currentRestPauseSet: currentSetIndex + 1, // 1-indexed for display
      totalRestPauseSets: totalSets,
    );
  }

  /// 📱 Update Live Activity if active (iOS only)
  /// Called when workout structure changes (exercises/sets added/removed)
  void _updateLiveActivityIfActive() {
    if (!Platform.isIOS) return;
    if (state == null) return;

    final laState = ref.read(workoutSessionLAProvider);
    if (!laState.isActive) return;

    // ✅ FIX: Don't call transitionToExercise during RPE or REST mode
    // During RPE selection: the user is confirming effort, then completeSet will handle transition
    // During REST: the timer will handle the transition back to exercise mode
    // This prevents race condition where updateExercise calls transitionToExercise
    // BEFORE completeSet calls transitionToRest, causing iOS to show wrong mode
    if (laState.mode == WorkoutSessionMode.rpe ||
        laState.mode == WorkoutSessionMode.rest) {
      debugPrint(
        '[WorkoutProvider] 📱 Skipping LA update - mode is ${laState.mode} (will transition after)',
      );
      return;
    }

    final workout = state!;

    // Find current exercise (first with incomplete sets)
    final currentExercise = workout.exercises.cast<Exercise?>().firstWhere(
      (e) => e != null && e.sets.any((s) => !s.isCompleted),
      orElse: () => null,
    );

    if (currentExercise != null) {
      final completedExercises = workout.exercises
          .where((e) => e.sets.every((s) => s.isCompleted))
          .length;

      ref
          .read(workoutSessionLAProvider.notifier)
          .updateExercise(
            currentExercise,
            completedExercises,
            workout.exercises.length,
          );
    }
  }

  /// 💾 BUG FIX #6: Restore workout from draft (after app killed by OS)
  ///
  /// Called when app resumes and finds a saved draft in local storage.
  /// This restores the full workout state including all exercises and sets.
  void restoreFromDraft(Workout workout) {
    if (kDebugMode) {
      debugPrint(
        '🔄 [WorkoutProvider] Restoring workout from draft: ${workout.name}',
      );
      debugPrint('   - Exercises: ${workout.exercises.length}');
      debugPrint('   - Status: ${workout.status}');
    }

    // Restore the workout state
    state = workout;

    // Start auto-save for the restored workout
    if (workout.isActive) {
      ref.read(workoutAutoSaveProvider.notifier).startAutoSave(workout);

      // Re-enable wakelock if workout is active
      ref.read(screenWakelockProvider.notifier).startWakelock();

      // ⌚ Notify Apple Watch about workout restore
      _notifyWatchWorkoutStarted();

      // 📱 Start iOS 17+ Workout Session Live Activity
      if (Platform.isIOS) {
        debugPrint(
          '[WorkoutProvider] 📱 Starting LA for restored workout: ${workout.name}',
        );
        ref.read(workoutSessionLAProvider.notifier).startLiveActivity(workout);
      }
    }

    // Track restoration event
    final analytics = ref.read(analyticsServiceProvider);
    final tracker = WorkoutEventTracker(analytics);
    tracker.trackWorkoutStarted(
      workoutId: workout.id,
      workoutType: 'strength',
      workoutName: workout.name,
      source: 'draft_recovery',
    );
  }

  /// Update workout duration by setting a new endTime
  ///
  /// Use this when the user wants to adjust the recorded workout time,
  /// e.g., when actual time < total rest time.
  ///
  /// [newDuration] is the desired workout duration from startTime.
  void updateWorkoutDuration(Duration newDuration) {
    if (state == null || state!.startTime == null) return;

    final newEndTime = state!.startTime!.add(newDuration);
    state = state!.copyWith(endTime: newEndTime, updatedAt: DateTime.now());

    if (kDebugMode) {
      debugPrint(
        '⏱️ [WorkoutProvider] Duration updated to: ${newDuration.inMinutes}m',
      );
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
        (total, ex) =>
            total +
            ex.sets.fold<double>(0.0, (exTotal, set) {
              if (!set.isCompleted) return exTotal;
              final weight = set.weight ?? 0;
              final reps = set.reps ?? 0;
              return exTotal + (weight.toDouble() * reps.toDouble());
            }),
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
        sessionId:
            workout.sessionId, // ✅ FIX #8: Add sessionId for funnel correlation
      );

      state = state!.completeWorkout();

      // Haptic feedback for workout completion
      HapticFeedbackService.workoutCompletion(ref);

      // ⌚ Notify Apple Watch that workout ended
      ref.read(watchConnectivityProvider.notifier).notifyWorkoutEnded();

      // 📱 End iOS 17+ Workout Session Live Activity (show completion for 5s)
      if (Platform.isIOS) {
        ref
            .read(workoutSessionLAProvider.notifier)
            .endLiveActivity(dismissPolicy: 'after_5s');
      }

      // 💾 Clear cache after workout completion (start fresh next time)
      if (_currentTemplateId != null) {
        final cacheService = ref.read(workoutTemplateCacheServiceProvider);
        cacheService.clearCache(_currentTemplateId!);
        _currentTemplateId = null;
      }

      // 💾 BUG FIX #5: Stop auto-save and clear draft after completion
      // Workout is now saved to Firestore, so draft is no longer needed
      ref.read(workoutAutoSaveProvider.notifier).stopAutoSave(clearDraft: true);

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

    // 🔧 FIX CASE 3: Don't return early if user not authenticated
    // Instead, use a fallback userId for local save (workout won't be lost)
    // Firebase sync will be skipped, but local save will work
    final effectiveUserId = currentUser?.uid ?? 'anonymous_${workout.id}';
    final isAuthenticated = currentUser != null;

    if (!isAuthenticated && kDebugMode) {
      debugLog(
        LogCategory.workout,
        '⚠️ [WorkoutProvider] User not authenticated - workout will be saved locally only',
      );
    }

    // 📢 UI Feedback: Show "Saving workout..." toast
    if (context != null) {
      SyncStatusToast.showSavingWorkout(context);
    }

    try {
      // 🔒 SECURITY: Sanitize user input to prevent XSS/injection attacks
      final sanitizedWorkoutName = InputValidator.sanitizeName(workout.name);
      final sanitizedWorkoutNotes = InputValidator.sanitizeText(
        workout.notes ?? '',
      );

      // Validate workout data before save
      final validation = InputValidator.validateWorkoutData(
        workoutName: sanitizedWorkoutName,
        notes: sanitizedWorkoutNotes,
        exerciseNames: workout.exercises.map((e) => e.name).toList(),
      );

      if (!validation.isValid) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Validation failed: ${validation.errors.join(', ')}',
        );
        // Don't throw - log error but continue with sanitized data
      }

      // 1. Convert Workout to WorkoutHistoryDetail (with sanitized data)
      final exercisesHistory = workout.exercises.map((exercise) {
        // 🔒 Sanitize exercise data
        final sanitizedExerciseName = InputValidator.sanitizeName(
          exercise.name,
        );
        final sanitizedExerciseNotes = InputValidator.sanitizeText(
          exercise.notes ?? '',
          maxLength: 500,
        );

        final setsHistory = exercise.sets.map((set) {
          // 🔒 Sanitize set notes
          final sanitizedSetNotes = set.notes != null
              ? InputValidator.sanitizeText(set.notes!, maxLength: 200)
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
          exerciseData: {
            // 🔧 FIX: Preserve countingMode for bodyweight volume calculation
            'countingMode': exercise.countingMode.name,
          },
        );
      }).toList();

      final workoutHistoryDetail = WorkoutHistoryDetail(
        id: workout.id,
        userId:
            effectiveUserId, // 🔧 FIX CASE 3: Use effectiveUserId for local save
        name: sanitizedWorkoutName,
        description: sanitizedWorkoutNotes,
        createdAt: workout.createdAt,
        startedAt: workout.startTime ?? workout.createdAt,
        completedAt: workout.endTime ?? DateTime.now(),
        updatedAt: workout.updatedAt,
        duration: workout.duration ?? Duration.zero,
        exercises: exercisesHistory,
        metadata: {'source': 'app_completion'},
        templateId: workout
            .templateId, // ✅ CRITICAL FIX: Pass templateId for routine auto-detection
      );

      // 2. SEMPRE salvare localmente PRIMA (BLOCKING ma veloce ~50ms)
      // Questo garantisce che i dati siano persistenti anche se cloud sync fallisce
      // 🔧 FIX CASE 3: Now saves ALWAYS, even without authenticated user
      try {
        final hiveDataSource = ref.read(hiveWorkoutDataSourceProvider);
        // Use effectiveUserId instead of FirebaseAuth check - workout ALWAYS saved locally
        final workoutModel = WorkoutModel.fromDomain(workout);
        await hiveDataSource.saveWorkout(workoutModel, effectiveUserId);

        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '✅ [WorkoutProvider] Workout saved to Hive local storage',
          );
        }

        // 📜 HISTORY: Salva anche nel box workout_history_enhanced per la cronologia
        // FIX: La cronologia legge da questo box, non da 'workouts'
        // Senza questo, il workout non appare nella history finché Firebase non sincronizza
        // 🔧 FIX: Key format MUST match repository format: workout_{userId}_{workoutId}
        // Without userId in key, repository's _getLocalWorkouts() won't find it!
        try {
          final boxManager = ref.read(hiveBoxManagerProvider);
          final historyBox = await boxManager.openBox(
            'workout_history_enhanced',
          );
          final historyKey =
              'workout_${effectiveUserId}_${workoutHistoryDetail.id}';
          await historyBox.put(historyKey, workoutHistoryDetail.toMap());

          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '✅ [WorkoutProvider] Workout saved to history box (key: $historyKey)',
            );
          }

          // 🔧 FIX: Notify history provider that new workout was added
          // Without this, UI won't update until Firebase sync completes
          try {
            final historyRepo = ref.read(workoutHistoryRepositoryProvider);
            await historyRepo.notifyLocalWorkoutAdded();
          } catch (notifyError) {
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '⚠️ [WorkoutProvider] Failed to notify history: $notifyError',
              );
            }
          }
        } catch (historyBoxError) {
          // Non-critical: la cronologia verrà popolata dal sync Firebase
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to save to history box: $historyBoxError',
            );
          }
        }

        // 📊 ANALYTICS: Update analytics collection for each exercise
        // Uses WorkoutToAnalyticsConverter utility to centralize conversion logic
        // This populates users/{userId}/analytics/{exerciseName} for efficient querying
        try {
          final analyticsRepo = ref.read(analyticsRepositoryProvider);

          // 🏋️ Get user body weight for bodyweight exercise volume calculation
          double? userBodyWeightKg;
          try {
            final weightMeasurements = await ref.read(
              bodyMeasurementsProvider(HealthDataType.bodyWeight).future,
            );
            if (weightMeasurements.isNotEmpty) {
              final latestWeight = weightMeasurements.first;
              userBodyWeightKg = latestWeight.unit == MeasurementUnit.pounds
                  ? latestWeight.value *
                        0.453592 // lbs to kg
                  : latestWeight.value;
              if (kDebugMode) {
                debugLog(
                  LogCategory.workout,
                  '📏 [WorkoutProvider] User body weight for analytics: ${userBodyWeightKg.toStringAsFixed(1)}kg',
                );
              }
            }
          } catch (weightError) {
            // Non-critical: bodyweight exercises will have volume = 0
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '⚠️ [WorkoutProvider] Could not fetch body weight: $weightError',
              );
            }
          }

          final analyticsData = WorkoutToAnalyticsConverter.convert(
            workout,
            userBodyWeightKg: userBodyWeightKg,
          );

          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '📊 [WorkoutProvider] Converting ${analyticsData.length} exercises to analytics',
            );
          }

          // Update analytics for each exercise
          for (final data in analyticsData) {
            await analyticsRepo.updateExerciseHistory(
              userId: effectiveUserId,
              exerciseId: data.exerciseId,
              exerciseName: data.exerciseName,
              muscleGroup: data.muscleGroup,
              session: data.session,
            );
          }

          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '✅ [WorkoutProvider] Analytics updated for ${analyticsData.length} exercises',
            );
          }
        } catch (analyticsError) {
          // Non-critical error - log but don't fail workout save
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to update analytics: $analyticsError',
            );
          }
        }

        // 💾 CACHING: Invalidate analytics cache after workout completion
        try {
          final analyticsRepo = ref.read(workoutAnalyticsRepositoryProvider);
          if (analyticsRepo is WorkoutAnalyticsRepositoryImpl) {
            await analyticsRepo.invalidateAnalyticsCache(effectiveUserId);
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '🗑️ [WorkoutProvider] Analytics cache invalidated for user: $effectiveUserId',
              );
            }
          }
        } catch (cacheError) {
          // Non-critical error - log but don't fail workout save
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to invalidate analytics cache: $cacheError',
            );
          }
        }

        // 💾 CACHING: Clear exercise records cache for Exercise Detail Screen
        try {
          clearRecordsCache();
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '🗑️ [WorkoutProvider] Exercise records cache cleared (Exercise Detail Screen will refresh)',
            );
          }
        } catch (recordsCacheError) {
          // Non-critical error - log but don't fail workout save
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to clear exercise records cache: $recordsCacheError',
            );
          }
        }

        // 📢 UI Feedback: Show "Workout saved locally" toast
        if (context != null && context.mounted) {
          SyncStatusToast.showWorkoutSavedLocally(context);
        }

        // 🍎 HEALTHKIT: Export workout to Apple Fitness / Activity rings
        // This enables the workout to count toward the Exercise ring
        if (Platform.isIOS &&
            workout.startTime != null &&
            workout.endTime != null) {
          try {
            final healthRemote = ref.read(healthRemoteDatasourceProvider);
            final success = await healthRemote.writeWorkout(
              startTime: workout.startTime!,
              endTime: workout.endTime!,
              workoutName: workout.name,
            );

            if (kDebugMode) {
              if (success) {
                debugLog(
                  LogCategory.workout,
                  '🍎 [WorkoutProvider] ✅ Workout exported to Apple Fitness',
                );
                debugLog(
                  LogCategory.workout,
                  '🍎 [WorkoutProvider] Exercise ring should update with workout duration',
                );
              } else {
                debugLog(
                  LogCategory.workout,
                  '🍎 [WorkoutProvider] ⚠️ Failed to export workout to Apple Fitness',
                );
              }
            }
          } catch (healthKitError) {
            // Non-critical: HealthKit export failure shouldn't affect workout save
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '🍎 [WorkoutProvider] ⚠️ HealthKit export error: $healthKitError',
              );
            }
          }
        }

        // 🏆 PR CELEBRATION: Check for new personal records after successful save
        // Records PRs to repository for future celebration and tracking
        bool hasNewPersonalRecords = false; // Tracked for XP bonus
        try {
          final prTracker = ref.read(prTrackerProvider);
          final prCelebrationRepo = ref.read(prCelebrationRepositoryProvider);
          final allNewPRs = <service_pr.PersonalRecord>[];

          // Check each exercise for new PRs
          for (final exercise in workout.exercises) {
            // Skip exercises with no completed sets
            if (!exercise.sets.any((s) => s.isCompleted)) continue;

            // Convert Exercise to ExerciseActivity
            final activity = ExerciseActivity.fromExercise(
              exercise: exercise,
              userEmail: currentUser?.email ?? effectiveUserId,
              workoutName: workout.name,
              workoutDate: workout.endTime ?? DateTime.now(),
            );

            // Check for PRs in this exercise
            // ✅ FIX: Pass Firebase UID for correct Firestore permissions
            final exercisePRs = await prTracker.checkAndUpdatePRs(
              activity,
              userId: effectiveUserId,
            );
            allNewPRs.addAll(exercisePRs);
          }

          if (allNewPRs.isNotEmpty) {
            hasNewPersonalRecords = true; // For XP bonus calculation
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '🎉 [WorkoutProvider] ${allNewPRs.length} new PR(s) detected!',
              );
              for (final pr in allNewPRs) {
                debugLog(
                  LogCategory.workout,
                  '   - ${pr.exerciseName}: ${pr.type.name} = ${pr.value}',
                );
              }
            }

            // Record celebrations for all PRs and prepare for UI display
            final celebrations = <PRCelebration>[];

            for (final pr in allNewPRs) {
              // Convert service PR to domain PR for repository
              final domainPR = domain_pr.PersonalRecord(
                id: pr.id,
                exerciseName: pr.exerciseName,
                exerciseId: pr.exerciseId,
                type: _mapSharedPRTypeToDomain(pr.type),
                value: pr.value,
                reps: null,
                weight: null,
                achievedAt: pr.achievedAt,
                workoutId: workout.id,
              );

              // Record celebration to Firestore
              await prCelebrationRepo.recordCelebration(
                effectiveUserId,
                domainPR,
              );

              // Create PRCelebration object for UI display
              // Note: previousValue will be fetched from repository in recordCelebration
              final celebration = PRCelebration(
                id: '${effectiveUserId}_${pr.id}_${DateTime.now().millisecondsSinceEpoch}',
                userId: effectiveUserId,
                prId: pr.id,
                prType: pr.type, // Already shared PRType
                celebratedAt: DateTime.now(),
                engagement: CelebrationEngagement.viewed, // Default to viewed
                previousValue: pr.previousValue ?? 0.0,
                newValue: pr.value,
                exerciseName: pr.exerciseName,
              );

              celebrations.add(celebration);
            }

            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '✅ [WorkoutProvider] ${celebrations.length} PR celebrations recorded to Firestore',
              );
            }

            // 🎉 Populate newly detected PRs for UI to display celebration modal
            ref.read(newlyDetectedPRsProvider.notifier).state = celebrations;

            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '✅ [WorkoutProvider] PR celebrations ready for UI display',
              );
            }

            // 🔔 NOTIFICATIONS: Schedule PR notification for first PR in list
            // Only schedule for the first PR to avoid notification spam
            try {
              final isNotificationInitialized = ref.read(
                notificationInitializedProvider,
              );
              if (isNotificationInitialized && allNewPRs.isNotEmpty) {
                final scheduler = ref.read(notificationSchedulerProvider);
                final l10n = ref.read(appLocalizationsProvider);
                await scheduler.schedulePrNotification(
                  exerciseName: allNewPRs.first.exerciseName,
                  l10n: l10n,
                );
                if (kDebugMode) {
                  debugLog(
                    LogCategory.workout,
                    '🔔 [WorkoutProvider] PR notification scheduled for ${allNewPRs.first.exerciseName}',
                  );
                }
              }
            } catch (notificationError) {
              if (kDebugMode) {
                debugLog(
                  LogCategory.workout,
                  '⚠️ [WorkoutProvider] Failed to schedule PR notification: $notificationError',
                );
              }
            }
          } else if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              'ℹ️ [WorkoutProvider] No new PRs detected',
            );
          }
        } catch (prError) {
          // Non-critical error - log but don't fail workout save
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to check PR achievements: $prError',
            );
          }
        }

        // 🔔 NOTIFICATIONS: Reset inactivity sequence after successful workout completion
        // This ensures user won't get inactivity reminders after completing a workout
        try {
          final isNotificationInitialized = ref.read(
            notificationInitializedProvider,
          );
          if (isNotificationInitialized) {
            final scheduler = ref.read(notificationSchedulerProvider);
            await scheduler.resetInactivitySequence();
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '🔔 [WorkoutProvider] Inactivity notification sequence reset',
              );
            }
          }
        } catch (notificationError) {
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to reset inactivity sequence: $notificationError',
            );
          }
        }

        // 📈 STRESS INDEX: Calculate and save training stress for this workout
        // Non-critical feature - failure won't affect workout save
        try {
          final stressNotifier = ref.read(stressIndexNotifierProvider.notifier);
          final stressResult = await stressNotifier.calculateAndSave(workout);

          if (stressResult != null && kDebugMode) {
            debugLog(
              LogCategory.workout,
              '📈 [WorkoutProvider] Stress index calculated: ${stressResult.displayScore.toStringAsFixed(0)} '
              '(${stressResult.stressLevel.name}, ${(stressResult.confidence * 100).toStringAsFixed(0)}% confidence)',
            );
          }
        } catch (stressError) {
          // Non-critical error - log but don't fail workout save
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to calculate stress index: $stressError',
            );
          }
        }

        // 🎮 XP AWARDING: Calculate and award XP for completed workout
        // Non-critical feature - failure won't affect workout save
        try {
          // Calculate total volume (weight × reps for all completed sets)
          double totalVolume = 0;
          for (final exercise in workout.exercises) {
            for (final set in exercise.sets) {
              if (set.isCompleted) {
                final weight = double.tryParse(set.weight.toString()) ?? 0;
                final reps = int.tryParse(set.reps.toString()) ?? 0;
                totalVolume += weight * reps;
              }
            }
          }

          // Get workout duration in minutes
          final durationMinutes = workout.duration?.inMinutes ?? 0;

          // Get current streak from progress provider
          final streakAsync = ref.read(currentStreakProvider);
          final streakDays = streakAsync.value ?? 0;

          // Award XP through central provider
          final xpAwarded = await ref
              .read(userXPProvider.notifier)
              .addWorkoutXP(
                workoutId: workout.id,
                durationMinutes: durationMinutes,
                exerciseCount: workout.exercises.length,
                totalVolume: totalVolume,
                isPersonalRecord: hasNewPersonalRecords,
                streakDays: streakDays,
              );

          if (kDebugMode && xpAwarded > 0) {
            debugLog(
              LogCategory.workout,
              '🎮 [WorkoutProvider] XP awarded: +$xpAwarded XP '
              '(duration: ${durationMinutes}min, exercises: ${workout.exercises.length}, '
              'volume: ${totalVolume.toStringAsFixed(0)}kg, PR: $hasNewPersonalRecords, streak: $streakDays)',
            );
          }
        } catch (xpError) {
          // Non-critical error - log but don't fail workout save
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to award XP: $xpError',
            );
          }
        }
        // 🔧 FIX CASE 3: Removed closing brace of old `if (userId != null)` block
        // Local save now runs unconditionally with effectiveUserId
      } catch (saveError, stackTrace) {
        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '❌ [WorkoutProvider] CRITICAL: Failed to save workout locally: $saveError',
          );
          debugLog(
            LogCategory.workout,
            '📍 [WorkoutProvider] Stack trace: $stackTrace',
          );
        }

        // 📢 UI Feedback: Show CRITICAL error toast with retry/export options
        if (context != null && context.mounted) {
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
                  debugLog(
                    LogCategory.workout,
                    '✅ [WorkoutProvider] Workout data exported successfully',
                  );
                }
              } catch (e) {
                if (kDebugMode) {
                  debugLog(
                    LogCategory.workout,
                    '❌ [WorkoutProvider] Failed to export workout data: $e',
                  );
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
          debugLog(
            LogCategory.workout,
            '⚠️ [WorkoutProvider] Provider disposed after local save - aborting cloud sync',
          );
        }
        return;
      }

      // 🔧 FIX CASE 3: Only run Firebase operations if user is authenticated
      // Unauthenticated workouts are saved locally and will sync when user logs in
      if (!isAuthenticated) {
        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '⚠️ [WorkoutProvider] Skipping cloud sync - user not authenticated',
          );
        }
        // Show success toast for local-only save
        if (context != null && context.mounted) {
          SyncStatusToast.showWorkoutCompletedWithMotivation(context);
        }
        return; // Skip all Firebase operations
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
          debugLog(
            LogCategory.workout,
            '✅ [WorkoutProvider] Workout queued for batch cloud sync',
          );
        }

        // 📢 UI Feedback: Show final success toast with motivation
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

        // 📢 UI Feedback: Show warning that cloud sync failed to queue
        // But workout is safe locally
        if (context != null && context.mounted) {
          SyncStatusToast.showCloudSyncQueued(context);
        }

        // Non-critical: workout già salvato localmente
        // La batch queue riproverà o farà sync al prossimo flush
      }

      // 5. Update user stats with transaction to prevent lost updates
      // Note: currentUser is guaranteed non-null here because of isAuthenticated check above
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

      // CRITICAL FIX: Check disposal after stats update
      if (_isDisposed) {
        debugLog(
          LogCategory.workout,
          '⚠️ [WorkoutProvider] Provider disposed after stats update - aborting remaining operations',
        );
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

      // TODO: Re-implement intelligent notifications when notification system is rebuilt

      // ⚠️ ROUTINE FEATURE DISABLED (v2.0 API migration pending)
      // 7. Auto-complete routine day if applicable (disabled)
      // try {
      //   final didAutoComplete = await _autoCompleteRoutineDay(workout, context);
      //   if (didAutoComplete) {
      //     debugLog(LogCategory.workout, '✅ [Routine] Auto-completed routine day');
      //   }
      // } catch (routineError) {
      //   debugLog(LogCategory.workout, '⚠️ [Routine] Failed to auto-complete day: $routineError');
      //   // Non-critical - workout is already saved
      // }

      // 7b. ✅ NEW: Check if this workout is a recovery for yesterday's skipped workout (disabled)
      // try {
      //   if (workout.templateId != null) {
      //     final activeRoutineAsync = ref.read(activeFlexibleRoutineProvider);
      //     final activeRoutine = activeRoutineAsync.maybeWhen(
      //       data: (routine) => routine,
      //       orElse: () => null,
      //     );
      //
      //     if (activeRoutine != null) {
      //       // ⚠️ v2.0 STUB: Recovery detection not implemented in v2.0 simplified schema
      //       // final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
      //       // final isRecovery = await notifier.autoDetectAndMarkAsRecovery(
      //       //   routineId: activeRoutine.id,
      //       //   completedTemplateId: workout.templateId!,
      //       //   completionDate: workout.endTime ?? DateTime.now(),
      //       // );
      //
      //       const isRecovery = false; // v2.0: Always false (feature not implemented)
      //
      //       if (isRecovery) {
      //         debugLog(LogCategory.workout, '🔄 [Recovery] Detected and marked as recovery workout');
      //
      //         // ✅ FIX: Force refresh from Firestore server (not cache)
      //         // Wait 500ms to ensure Firestore write has propagated
      //         await Future.delayed(const Duration(milliseconds: 500));
      //
      //         // Invalidate BOTH providers to force fresh fetch
      //         ref.invalidate(activeFlexibleRoutineProvider);
      //         ref.invalidate(userFlexibleRoutinesProvider);
      //
      //         debugLog(LogCategory.workout, '🔄 [Recovery] Providers invalidated, forcing server refresh');
      //       }
      //     }
      //   }
      // } catch (recoveryError) {
      //   debugLog(LogCategory.workout, '⚠️ [Recovery] Failed to detect recovery: $recoveryError');
      //   // Non-critical - workout is already saved
      // }

      // 8. Navigate to workout completion summary screen (if context available)
      if (context != null && context.mounted) {
        // Use pushNamed to navigate to summary screen
        unawaited(
          context.pushNamed('workout-completion-summary', extra: workout),
        );

        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '📊 [WorkoutProvider] Navigated to completion summary screen',
          );
        }
      }
    } catch (e, stackTrace) {
      debugLog(LogCategory.workout, '❌ Critical error saving workout: $e');
      debugLog(LogCategory.workout, 'Stack: $stackTrace');
    }
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

      // 💾 BUG FIX #5: Force save when pausing (user expects data saved)
      _autoSaveIfNeeded();
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

    if (kDebugMode) {
      debugPrint(
        '🔍 [WorkoutProvider] addExercise RECEIVED: name=${exercise.name}, countingMode=${exercise.countingMode}',
      );
    }

    // 🔒 SESSION: Record activity to prevent auto-logout during workout
    ref.read(sessionActivityRecorderProvider);

    try {
      state = state!.addExercise(exercise);

      if (kDebugMode) {
        debugPrint(
          '🔍 [WorkoutProvider] addExercise FINAL exercise.countingMode=${exercise.countingMode}',
        );
      }

      // 💾 Auto-save modifications
      _autoSaveIfNeeded();

      // ⌚ Sync to Watch
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();

      // 📊 Track exercise added
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackExerciseAdded(
        workoutId: state!.id,
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        exerciseCategory: exercise.category.name,
        sets: exercise.sets.length,
        source: 'add_exercise_modal',
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error adding exercise: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// Insert exercise at specific position (before another exercise)
  void insertExerciseAt(int index, Exercise exercise) {
    if (state == null) return;

    if (kDebugMode) {
      debugPrint(
        '🔍 [WorkoutProvider] insertExerciseAt index=$index, name=${exercise.name}',
      );
    }

    // Record session activity
    ref.read(sessionActivityRecorderProvider);

    try {
      state = state!.insertExerciseAt(index, exercise);

      // Auto-save
      _autoSaveIfNeeded();

      // ⌚ Sync to Watch
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();

      // Track analytics
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackExerciseAdded(
        workoutId: state!.id,
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        exerciseCategory: exercise.category.name,
        sets: exercise.sets.length,
        source: 'warmup_suggestion',
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error inserting exercise: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
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

      // ⌚ Sync to Watch
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();

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
      if (oldIndex < 0 ||
          oldIndex >= state!.exercises.length ||
          newIndex < 0 ||
          newIndex >= state!.exercises.length) {
        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '⚠️ [WorkoutProvider] Invalid reorder indices: old=$oldIndex, new=$newIndex, exercises=${state!.exercises.length}',
          );
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

      // 💾 BUG FIX #5: Save after reordering
      _autoSaveIfNeeded();

      // ⌚ Sync to Watch
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error reordering exercises: $e',
        );
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

      // ⌚ Sync to Watch
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();

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
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error updating exercise: $e',
        );
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
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error checking completed sets: $e',
        );
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
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error changing counting mode: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void updateExerciseOnly(Exercise updatedExercise) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == updatedExercise.id) {
          return updatedExercise;
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      // 💾 Auto-save modifications
      _autoSaveIfNeeded();

      // ⌚ Sync to Watch
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error in updateExerciseOnly: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// ⌚ Complete current set when triggered from Apple Watch
  /// - effort: Optional effort value (RPE 6-10 or RIR 0-4)
  /// - effortScale: "rpe" or "rir" to indicate how to interpret the effort value
  void completeCurrentSetFromWatch({int? effort, String? effortScale}) {
    debugPrint('⌚ [FLUTTER] completeCurrentSetFromWatch called');
    if (effort != null) {
      debugPrint(
        '⌚ [FLUTTER] Effort from Watch: $effort (${effortScale ?? "rpe"})',
      );
    }

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ❌ No active workout');
      return;
    }

    final workout = state!;

    // Find current exercise (first with incomplete sets)
    final currentExercise = workout.exercises.cast<Exercise?>().firstWhere(
      (e) => e != null && e.sets.any((s) => !s.isCompleted),
      orElse: () => null,
    );

    if (currentExercise == null) {
      debugPrint('⌚ [FLUTTER] ❌ No exercise with incomplete sets');
      return;
    }

    // Find first incomplete set
    final currentSet = currentExercise.sets.cast<ExerciseSet?>().firstWhere(
      (s) => s != null && !s.isCompleted,
      orElse: () => null,
    );

    if (currentSet == null) {
      debugPrint('⌚ [FLUTTER] ❌ No incomplete set found');
      return;
    }

    // ✅ DEDUPLICATION: Prevent duplicate processing from sendMessage + transferUserInfo
    // Both are sent for reliability, but we only want to process once
    final now = DateTime.now();
    if (_lastCompletedSetId == currentSet.id &&
        _lastWatchSetCompletion != null &&
        now.difference(_lastWatchSetCompletion!).inSeconds < 3) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ Duplicate message ignored (set ${currentSet.id} already completed)',
      );
      return;
    }
    _lastWatchSetCompletion = now;
    _lastCompletedSetId = currentSet.id;

    debugPrint(
      '⌚ [FLUTTER] ✅ Completing set ${currentSet.setNumber} of ${currentExercise.name}',
    );
    debugPrint(
      '⌚ [FLUTTER] Exercise ID: ${currentExercise.id}, Set ID: ${currentSet.id}',
    );

    // Convert RIR to RPE if needed (RIR 0-4 → RPE 10-6)
    int? rpeValue = effort;
    if (effort != null && effortScale == 'rir') {
      // RIR 0 = failure = RPE 10
      // RIR 1 = RPE 9
      // RIR 2 = RPE 8
      // RIR 3 = RPE 7
      // RIR 4+ = RPE 6
      rpeValue = (10 - effort).clamp(6, 10);
      debugPrint('⌚ [FLUTTER] Converted RIR $effort to RPE $rpeValue');
    }

    // If we have an effort value, update the set with RPE before completing
    if (rpeValue != null) {
      // Update set with RPE value
      final updatedSet = currentSet.copyWith(rpe: rpeValue);
      final setIndex = currentExercise.sets.indexWhere(
        (s) => s.id == currentSet.id,
      );
      if (setIndex >= 0) {
        final updatedSets = List<ExerciseSet>.from(currentExercise.sets);
        updatedSets[setIndex] = updatedSet;
        final updatedExercise = currentExercise.copyWith(sets: updatedSets);
        final exerciseIndex = workout.exercises.indexWhere(
          (e) => e.id == currentExercise.id,
        );
        if (exerciseIndex >= 0) {
          final updatedExercises = List<Exercise>.from(workout.exercises);
          updatedExercises[exerciseIndex] = updatedExercise;
          state = workout.copyWith(exercises: updatedExercises);
          debugPrint('⌚ [FLUTTER] ✅ Updated set with RPE $rpeValue');
        }
      }
    }

    // Use existing completeSet method
    debugPrint('⌚ [FLUTTER] 🎯 Calling completeSet...');
    completeSet(currentExercise.id, currentSet.id);
    debugPrint('⌚ [FLUTTER] ✅ completeSet finished');

    // Update Watch with new state
    _notifyWatchWorkoutUpdate();
  }

  /// ⌚ Skip rest timer when triggered from Apple Watch
  void _skipRestFromWatch() {
    debugPrint('⌚ [FLUTTER] ⏭️ Skipping rest timer from Watch');

    // Skip the timer using the unified timer provider
    ref.read(unifiedTimerProvider.notifier).skipTimer();

    if (kDebugMode) {
      debugPrint('⌚ [FLUTTER] ✅ Rest timer skipped via Watch');
    }
  }

  /// ⌚ Handle health metrics from Apple Watch (HR, calories)
  void _handleHealthMetricsFromWatch(
    double heartRate,
    double calories,
    double elapsedTime,
  ) {
    debugPrint(
      '⌚ [FLUTTER] Health metrics from Watch: HR=${heartRate.toInt()}, Cal=${calories.toInt()}, Time=${elapsedTime.toInt()}s',
    );
    // TODO: Store/display these metrics in the workout UI
    // For now, we just log them - can be integrated into WorkoutHeader or a dedicated widget
  }

  /// ⌚ End workout when triggered from Apple Watch
  /// [save] - if true, save the workout; if false, discard it
  void _endWorkoutFromWatch({bool save = true}) {
    debugPrint('⌚ [FLUTTER] 🏁 Ending workout from Watch (save: $save)');

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout to end');
      return;
    }

    if (save) {
      // Complete the workout (saves and clears state)
      completeWorkout();
      if (kDebugMode) {
        debugPrint('⌚ [FLUTTER] ✅ Workout saved via Watch');
      }
    } else {
      // Discard the workout without saving
      clearWorkout();
      if (kDebugMode) {
        debugPrint('⌚ [FLUTTER] 🗑️ Workout discarded via Watch');
      }
    }
  }

  /// ⌚ Edit a SPECIFIC completed set's reps when triggered from Apple Watch
  /// - setIndex: 0-indexed position within completed sets of current exercise
  ///   (0 = first completed set, 1 = second completed set, etc.)
  /// - newReps: The new reps value to set
  void _editCompletedSetRepsFromWatch(int setIndex, int newReps) {
    debugPrint(
      '⌚ [FLUTTER] ✏️ Editing completed set at index $setIndex to: $newReps reps',
    );

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Find the current exercise (first with incomplete sets, or last exercise if all complete)
    Exercise? currentExercise;
    for (final exercise in workout.exercises) {
      final hasIncompleteSets = exercise.sets.any((s) => !s.isCompleted);
      if (hasIncompleteSets) {
        currentExercise = exercise;
        break;
      }
    }

    // If all exercises are complete, use the last exercise
    currentExercise ??= workout.exercises.isNotEmpty
        ? workout.exercises.last
        : null;

    if (currentExercise == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No exercise found');
      return;
    }

    // Build list of completed sets with their original indices
    final completedSets = <({ExerciseSet set, int originalIndex})>[];
    for (int i = 0; i < currentExercise.sets.length; i++) {
      if (currentExercise.sets[i].isCompleted) {
        completedSets.add((set: currentExercise.sets[i], originalIndex: i));
      }
    }

    // Validate setIndex
    if (setIndex < 0 || setIndex >= completedSets.length) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ Invalid setIndex $setIndex (have ${completedSets.length} completed sets)',
      );
      return;
    }

    // Get the target set
    final target = completedSets[setIndex];
    final targetSet = target.set;
    final originalIndex = target.originalIndex;

    debugPrint(
      '⌚ [FLUTTER] Found target set: #${targetSet.setNumber} at index $originalIndex (actualReps: ${targetSet.actualReps} → $newReps)',
    );

    // Update the set with new actualReps
    final updatedSet = targetSet.copyWith(actualReps: newReps);
    final updatedSets = List<ExerciseSet>.from(currentExercise.sets);
    updatedSets[originalIndex] = updatedSet;
    final updatedExercise = currentExercise.copyWith(sets: updatedSets);

    // Find and update exercise in workout
    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == currentExercise!.id,
    );
    if (exerciseIndex >= 0) {
      final updatedExercises = List<Exercise>.from(workout.exercises);
      updatedExercises[exerciseIndex] = updatedExercise;
      state = workout.copyWith(
        exercises: updatedExercises,
        updatedAt: DateTime.now(),
      );

      debugPrint(
        '⌚ [FLUTTER] ✅ Updated set ${targetSet.setNumber} actualReps to $newReps',
      );

      // Trigger auto-save
      _autoSaveIfNeeded();

      // Update Watch with new state
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    }
  }

  /// ⌚ Uncomplete (undo) a completed set from Watch
  /// - Parameter setIndex: 0-indexed position in completed sets list
  void _uncompleteSetFromWatch(int setIndex) {
    debugPrint('⌚ [FLUTTER] ↩️ Uncompleting set at index $setIndex');

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Find the current exercise (first with incomplete sets, or last exercise if all complete)
    Exercise? currentExercise;
    for (final exercise in workout.exercises) {
      final hasIncompleteSets = exercise.sets.any((s) => !s.isCompleted);
      if (hasIncompleteSets) {
        currentExercise = exercise;
        break;
      }
    }

    // If all exercises are complete, use the last exercise
    currentExercise ??= workout.exercises.isNotEmpty
        ? workout.exercises.last
        : null;

    if (currentExercise == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No exercise found');
      return;
    }

    // Build list of completed sets with their original indices
    final completedSets = <({ExerciseSet set, int originalIndex})>[];
    for (int i = 0; i < currentExercise.sets.length; i++) {
      if (currentExercise.sets[i].isCompleted) {
        completedSets.add((set: currentExercise.sets[i], originalIndex: i));
      }
    }

    // Validate setIndex
    if (setIndex < 0 || setIndex >= completedSets.length) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ Invalid setIndex $setIndex (have ${completedSets.length} completed sets)',
      );
      return;
    }

    // Get the target set
    final target = completedSets[setIndex];
    final targetSet = target.set;
    final originalIndex = target.originalIndex;

    debugPrint(
      '⌚ [FLUTTER] Found target set: #${targetSet.setNumber} at index $originalIndex - marking as incomplete',
    );

    // ✅ FIX: Create new set directly instead of copyWith (copyWith can't set null values)
    final updatedSet = ExerciseSet(
      id: targetSet.id,
      setNumber: targetSet.setNumber,
      weight: targetSet.weight,
      reps: targetSet.reps,
      actualReps: null, // ✅ Reset to null
      rpe: null, // ✅ Reset to null
      restTime: targetSet.restTime,
      seconds: targetSet.seconds,
      distance: targetSet.distance,
      isCompleted: false, // ✅ Mark as incomplete
      notes: targetSet.notes,
      completedAt: null, // ✅ Reset to null
      setDurationMillis: null, // ✅ Reset to null
      setStartedAt: null, // ✅ Reset to null
      isWarmup: targetSet.isWarmup,
    );
    final updatedSets = List<ExerciseSet>.from(currentExercise.sets);
    updatedSets[originalIndex] = updatedSet;
    final updatedExercise = currentExercise.copyWith(sets: updatedSets);

    // Find and update exercise in workout
    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == currentExercise!.id,
    );
    if (exerciseIndex >= 0) {
      final updatedExercises = List<Exercise>.from(workout.exercises);
      updatedExercises[exerciseIndex] = updatedExercise;
      state = workout.copyWith(
        exercises: updatedExercises,
        updatedAt: DateTime.now(),
      );

      debugPrint('⌚ [FLUTTER] ✅ Uncompleted set ${targetSet.setNumber}');

      // Trigger auto-save
      _autoSaveIfNeeded();

      // Update Watch with new state
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    }
  }

  /// ⌚ Update current set target (weight/reps) from Watch
  /// Called when user edits the target using Digital Crown before completing
  /// [setNumber] - 1-indexed set number being modified
  /// [isSuperset] - true if editing a superset exercise
  /// [exerciseIndexInSuperset] - 0-indexed position of exercise within superset
  void _updateCurrentSetTargetFromWatch(
    double weight,
    int reps, {
    required int setNumber,
    bool isSuperset = false,
    int? exerciseIndexInSuperset,
  }) {
    debugPrint(
      '⌚ [FLUTTER] ✏️ Updating set #$setNumber target: ${weight}kg × $reps reps (superset: $isSuperset, exerciseIndex: $exerciseIndexInSuperset)',
    );

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Find the current exercise (first with incomplete sets)
    Exercise? currentExercise;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      // For superset, check supersetSets; for others, check sets
      final hasIncompleteSets = exercise is SupersetExercise
          ? exercise.supersetSets.any((s) => !s.isCompleted)
          : exercise.sets.any((s) => !s.isCompleted);
      if (hasIncompleteSets) {
        currentExercise = exercise;
        exerciseIndex = i;
        break;
      }
    }

    if (currentExercise == null || exerciseIndex < 0) {
      debugPrint('⌚ [FLUTTER] ⚠️ No exercise with incomplete sets found');
      return;
    }

    // 🔥 SUPERSET: Handle superset set modification
    if (isSuperset &&
        currentExercise is SupersetExercise &&
        exerciseIndexInSuperset != null) {
      _updateSupersetTargetFromWatch(
        workout: workout,
        superset: currentExercise,
        exerciseIndex: exerciseIndex,
        exerciseIndexInSuperset: exerciseIndexInSuperset,
        weight: weight,
        reps: reps,
      );
      return;
    }

    // ✅ FIX: Use setNumber from Watch instead of finding first incomplete set
    // setNumber is 1-indexed, convert to 0-indexed
    final currentSetIndex = setNumber - 1;

    // Validate index bounds
    if (currentSetIndex < 0 || currentSetIndex >= currentExercise.sets.length) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ Invalid set index: $currentSetIndex (setNumber: $setNumber, total sets: ${currentExercise.sets.length})',
      );
      return;
    }

    final currentSet = currentExercise.sets[currentSetIndex];
    debugPrint(
      '⌚ [FLUTTER] ✅ Targeting set #$setNumber at index $currentSetIndex',
    );

    // Update the set with new weight and reps
    final updatedSet = currentSet.copyWith(weight: weight, reps: reps);

    final updatedSets = List<ExerciseSet>.from(currentExercise.sets);
    updatedSets[currentSetIndex] = updatedSet;
    final updatedExercise = currentExercise.copyWith(sets: updatedSets);

    // Update exercise in workout
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;
    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint(
      '⌚ [FLUTTER] ✅ Updated set ${currentSet.setNumber} target to ${weight}kg × $reps reps',
    );

    // ✅ DEBUG: Verify the state was updated correctly
    final verifyExercise = state!.exercises[exerciseIndex];
    final verifySet = verifyExercise.sets[currentSetIndex];
    debugPrint(
      '⌚ [FLUTTER] 🔍 VERIFY: Exercise "${verifyExercise.name}" Set #${verifySet.setNumber}',
    );
    debugPrint(
      '⌚ [FLUTTER] 🔍 VERIFY: weight=${verifySet.weight}, reps=${verifySet.reps}',
    );

    // Trigger auto-save
    _autoSaveIfNeeded();

    // Update Watch with new state (confirms the change)
    _notifyWatchWorkoutUpdate();
  }

  /// 🔥 SUPERSET: Update target weight/reps for a specific exercise within a superset
  void _updateSupersetTargetFromWatch({
    required Workout workout,
    required SupersetExercise superset,
    required int exerciseIndex,
    required int exerciseIndexInSuperset,
    required double weight,
    required int reps,
  }) {
    debugPrint(
      '⌚🔥 [FLUTTER] Updating superset target: exerciseIndex=$exerciseIndexInSuperset, weight=$weight, reps=$reps',
    );

    // Find the current round (first incomplete SupersetSet)
    int currentRoundIndex = -1;
    for (int i = 0; i < superset.supersetSets.length; i++) {
      if (!superset.supersetSets[i].isCompleted) {
        currentRoundIndex = i;
        break;
      }
    }

    if (currentRoundIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ⚠️ No incomplete superset round found');
      return;
    }

    // Validate exercise index
    if (exerciseIndexInSuperset < 0 ||
        exerciseIndexInSuperset >= superset.exercises.length) {
      debugPrint(
        '⌚🔥 [FLUTTER] ⚠️ Invalid exercise index: $exerciseIndexInSuperset (max: ${superset.exercises.length - 1})',
      );
      return;
    }

    // Get the exercise ID from the exercises list
    final targetExerciseId = superset.exercises[exerciseIndexInSuperset].id;
    final targetExerciseName = superset.exercises[exerciseIndexInSuperset].name;
    debugPrint(
      '⌚🔥 [FLUTTER] Target exercise: "$targetExerciseName" (id: $targetExerciseId)',
    );

    // Get current round and update the exercise data
    final currentRound = superset.supersetSets[currentRoundIndex];
    final existingData = currentRound.exerciseData[targetExerciseId];

    if (existingData == null) {
      debugPrint(
        '⌚🔥 [FLUTTER] ⚠️ No exercise data found for id: $targetExerciseId',
      );
      return;
    }

    // Update target weight and reps
    final updatedExerciseData = existingData.copyWith(
      targetWeight: weight,
      targetReps: reps,
    );

    // Create updated exerciseData map
    final updatedDataMap = Map<String, SupersetExerciseData>.from(
      currentRound.exerciseData,
    );
    updatedDataMap[targetExerciseId] = updatedExerciseData;

    // Create updated round
    final updatedRound = currentRound.copyWith(exerciseData: updatedDataMap);

    // Create updated supersetSets list
    final updatedSupersetSets = List<SupersetSet>.from(superset.supersetSets);
    updatedSupersetSets[currentRoundIndex] = updatedRound;

    // Create updated superset
    final updatedSuperset = superset.copyWith(
      supersetSets: updatedSupersetSets,
    );

    // Update exercise in workout
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedSuperset;
    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint(
      '⌚🔥 [FLUTTER] ✅ Updated superset exercise "$targetExerciseName" target to ${weight}kg × $reps reps',
    );

    // Trigger auto-save
    _autoSaveIfNeeded();

    // Update Watch with new state (confirms the change)
    _notifyWatchWorkoutUpdate();
  }

  /// 🧪 TEST ONLY: Public wrapper for testing superset target updates
  /// DO NOT use in production code - use the Watch callback system instead
  @visibleForTesting
  void updateSupersetTargetFromWatchTest({
    required int exerciseIndexInSuperset,
    required double weight,
    required int reps,
  }) {
    _updateCurrentSetTargetFromWatch(
      weight,
      reps,
      setNumber:
          1, // Not used for superset (uses exerciseIndexInSuperset instead)
      isSuperset: true,
      exerciseIndexInSuperset: exerciseIndexInSuperset,
    );
  }

  /// ⌚ 🔥 SUPERSET: Complete an entire round when triggered from Apple Watch
  /// This is called when the user taps "Completa Round" on the Watch
  /// - roundNumber: 1-indexed round that was completed
  /// - totalRounds: Total rounds in the superset
  /// - exercises: List of exercise names in the round
  /// - effort: Optional effort value (RPE 6-10 or RIR 0-4) for the entire round
  /// - effortScale: "rpe" or "rir" to indicate how to interpret the effort value
  void _completeSupersetRoundFromWatch({
    required int roundNumber,
    required int totalRounds,
    required List<String> exercises,
    int? effort,
    String? effortScale,
  }) {
    debugPrint('⌚🔥 [FLUTTER] _completeSupersetRoundFromWatch called');
    debugPrint(
      '⌚🔥 [FLUTTER] Round $roundNumber/$totalRounds, exercises: $exercises',
    );
    if (effort != null) {
      debugPrint('⌚🔥 [FLUTTER] Effort: $effort (${effortScale ?? "rpe"})');
    }

    if (state == null) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No active workout');
      return;
    }

    final workout = state!;

    // Find current superset exercise (first superset with incomplete rounds)
    SupersetExercise? currentSuperset;
    int supersetIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is SupersetExercise) {
        if (exercise.supersetSets.any((s) => !s.isCompleted)) {
          currentSuperset = exercise;
          supersetIndex = i;
          break;
        }
      }
    }

    if (currentSuperset == null || supersetIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No superset with incomplete rounds found');
      return;
    }

    // Find the current round (first incomplete)
    final currentRoundIndex = currentSuperset.supersetSets.indexWhere(
      (s) => !s.isCompleted,
    );
    if (currentRoundIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No incomplete round found');
      return;
    }

    final currentRound = currentSuperset.supersetSets[currentRoundIndex];
    debugPrint(
      '⌚🔥 [FLUTTER] Found round ${currentRoundIndex + 1} to complete',
    );

    // ✅ DEDUPLICATION: Prevent duplicate processing from sendMessage + transferUserInfo
    final now = DateTime.now();
    final roundKey = '${currentSuperset.id}_round_$currentRoundIndex';
    if (_lastCompletedSetId == roundKey &&
        _lastWatchSetCompletion != null &&
        now.difference(_lastWatchSetCompletion!).inSeconds < 3) {
      debugPrint(
        '⌚🔥 [FLUTTER] ⚠️ Duplicate message ignored (round already completed)',
      );
      return;
    }
    _lastWatchSetCompletion = now;
    _lastCompletedSetId = roundKey;

    // Convert RIR to RPE if needed
    int? rpeValue = effort;
    if (effort != null && effortScale == 'rir') {
      rpeValue = (10 - effort).clamp(6, 10);
      debugPrint('⌚🔥 [FLUTTER] Converted RIR $effort to RPE $rpeValue');
    }

    // Build completed exercise data for all exercises in the round
    final Map<String, SupersetExerciseData> completedExerciseData = {};
    for (final ex in currentSuperset.exercises) {
      final existingData = currentRound.exerciseData[ex.id];
      completedExerciseData[ex.id] = SupersetExerciseData(
        exerciseId: ex.id,
        exerciseName: ex.name,
        targetWeight: existingData?.targetWeight ?? 0.0,
        targetReps: existingData?.targetReps ?? 10,
        // Use actual values if already set, otherwise use target values
        actualWeight:
            existingData?.actualWeight ?? existingData?.targetWeight ?? 0.0,
        actualReps: existingData?.actualReps ?? existingData?.targetReps ?? 10,
        rpe: rpeValue, // Apply RPE to all exercises in the round
        isCompleted: true,
      );
    }

    // Create completed SupersetSet
    final completedSet = SupersetSet(
      id: currentRound.id,
      setNumber: currentRound.setNumber,
      exerciseData: completedExerciseData,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    debugPrint(
      '⌚🔥 [FLUTTER] ✅ Created completed SupersetSet for round ${currentRound.setNumber}',
    );

    // Update the superset with the completed round
    final updatedSupersetSets = currentSuperset.supersetSets.map((set) {
      if (set.setNumber == completedSet.setNumber) {
        return completedSet;
      }
      return set;
    }).toList();

    final updatedSuperset = currentSuperset.copyWith(
      supersetSets: updatedSupersetSets,
    );
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[supersetIndex] = updatedSuperset;

    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint('⌚🔥 [FLUTTER] ✅ Updated workout state with completed round');

    // Check if this was the last round
    final remainingRounds = updatedSuperset.supersetSets
        .where((s) => !s.isCompleted)
        .length;
    final isLastRound = remainingRounds == 0;

    debugPrint(
      '⌚🔥 [FLUTTER] Remaining rounds: $remainingRounds, isLastRound: $isLastRound',
    );

    // 💾 Auto-save
    _autoSaveIfNeeded();

    // ⌚ Update Watch with new state
    _notifyWatchWorkoutUpdate();

    // 📱 Sync Live Activity (iOS)
    _updateLiveActivityIfActive();

    // ⏱️ Start rest timer if not last round
    if (!isLastRound) {
      final restDuration = currentSuperset.restTime ?? 90;
      debugPrint('⌚🔥 [FLUTTER] ⏱️ Starting rest timer: ${restDuration}s');

      // Use tier1TimerActions to start rest timer (same as UI)
      final timerActions = ref.read(tier1TimerActionsProvider);
      timerActions.startExerciseRest(
        seconds: restDuration,
        exerciseName:
            '${currentSuperset.name} - Round ${currentRoundIndex + 2}',
        currentSet: currentRoundIndex + 2,
        totalSets: currentSuperset.supersetSets.length,
      );
    } else {
      debugPrint('⌚🔥 [FLUTTER] 🏁 Superset completed! Checking for next exercise...');

      // Start inter-exercise timer if there's a next exercise
      final nextExercise = _getNextIncompleteExercise(state!, currentSuperset);
      if (nextExercise != null) {
        final interExerciseRest = _resolveInterExerciseRest(currentSuperset);
        final nextExerciseTotalSets = _getExerciseTotalSets(nextExercise);

        debugPrint(
          '⏰ [TIMER] 🏋️ Starting INTER-EXERCISE timer after superset: ${interExerciseRest}s before ${nextExercise.name}',
        );

        ref
            .read(unifiedTimerProvider.notifier)
            .startTimer(
              durationSeconds: interExerciseRest,
              type: TimerType.interExercise,
              exerciseName: nextExercise.name,
              currentSet: 1,
              totalSets: nextExerciseTotalSets,
              exerciseId: nextExercise.id,
            );

        // 📱 iOS: Transition Live Activity
        if (Platform.isIOS) {
          ref
              .read(workoutSessionLAProvider.notifier)
              .transitionToRest(
                restDurationSeconds: interExerciseRest,
                nextExercise: nextExercise,
                nextSetIndex: 1,
              );
        }
      } else {
        debugPrint('⌚🔥 [FLUTTER] 🏁 Last exercise completed - workout finished!');
      }
    }
  }

  // ============================================================
  // 🔥 DROPSET: Watch handlers
  // ============================================================

  /// Handle dropset stage completion from Watch
  void _completeDropsetStageFromWatch({
    required int stageIndex,
    required int totalStages,
    required int actualReps,
    int? effort,
    String? effortScale,
  }) {
    debugPrint('⌚🔥 [FLUTTER] _completeDropsetStageFromWatch called');
    debugPrint(
      '⌚🔥 [FLUTTER] Stage ${stageIndex + 1}/$totalStages, reps: $actualReps',
    );

    if (state == null) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No active workout');
      return;
    }

    final workout = state!;

    // Find current dropset exercise (first dropset with incomplete stages)
    DropSetExercise? currentDropset;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is DropSetExercise) {
        if (exercise.stages.any((s) => !s.isCompleted)) {
          currentDropset = exercise;
          exerciseIndex = i;
          break;
        }
      }
    }

    if (currentDropset == null || exerciseIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No dropset with incomplete stages found');
      return;
    }

    // Find the target stage (should match stageIndex or first incomplete)
    final targetStageIndex = currentDropset.stages.indexWhere(
      (s) => !s.isCompleted,
    );
    if (targetStageIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No incomplete stage found');
      return;
    }

    // ✅ DEDUPLICATION: Prevent duplicate processing
    final now = DateTime.now();
    final stageKey = '${currentDropset.id}_stage_$targetStageIndex';
    if (_lastCompletedSetId == stageKey &&
        _lastWatchSetCompletion != null &&
        now.difference(_lastWatchSetCompletion!).inSeconds < 3) {
      debugPrint('⌚🔥 [FLUTTER] ⚠️ Duplicate message ignored');
      return;
    }
    _lastWatchSetCompletion = now;
    _lastCompletedSetId = stageKey;

    // Convert RIR to RPE if needed
    int? rpeValue = effort;
    if (effort != null && effortScale == 'rir') {
      rpeValue = (10 - effort).clamp(6, 10);
    }

    // Update the stage
    final currentStage = currentDropset.stages[targetStageIndex];
    final updatedStages = List<DropSetStage>.from(currentDropset.stages);
    updatedStages[targetStageIndex] = currentStage.copyWith(
      actualReps: actualReps,
      rpe: rpeValue,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    // Create updated exercise
    final updatedExercise = DropSetExercise(
      id: currentDropset.id,
      name: currentDropset.name,
      category: currentDropset.category,
      stages: updatedStages,
      notes: currentDropset.notes,
      restTime: currentDropset.restTime,
    );

    // Update workout state
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;
    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint(
      '⌚🔥 [FLUTTER] ✅ Dropset stage ${targetStageIndex + 1} completed',
    );

    // Check if there are more stages
    final remainingStages = updatedExercise.stages
        .where((s) => !s.isCompleted)
        .length;
    final isLastStage = remainingStages == 0;

    // 💾 Auto-save
    _autoSaveIfNeeded();

    // ⌚ Update Watch with new state
    _notifyWatchWorkoutUpdate();

    // 📱 Sync Live Activity (iOS)
    _updateLiveActivityIfActive();

    // Dropset stages are typically done without rest between them
    // (the "drop" is immediate), but we check for inter-exercise timer after LAST stage
    if (isLastStage) {
      debugPrint('⌚🔥 [FLUTTER] 🏁 Dropset completed! Checking for next exercise...');

      // Start inter-exercise timer if there's a next exercise
      final nextExercise = _getNextIncompleteExercise(state!, currentDropset);
      if (nextExercise != null) {
        final interExerciseRest = _resolveInterExerciseRest(currentDropset);
        final nextExerciseTotalSets = _getExerciseTotalSets(nextExercise);

        debugPrint(
          '⏰ [TIMER] 🏋️ Starting INTER-EXERCISE timer after dropset: ${interExerciseRest}s before ${nextExercise.name}',
        );

        ref
            .read(unifiedTimerProvider.notifier)
            .startTimer(
              durationSeconds: interExerciseRest,
              type: TimerType.interExercise,
              exerciseName: nextExercise.name,
              currentSet: 1,
              totalSets: nextExerciseTotalSets,
              exerciseId: nextExercise.id,
            );

        // 📱 iOS: Transition Live Activity
        if (Platform.isIOS) {
          ref
              .read(workoutSessionLAProvider.notifier)
              .transitionToRest(
                restDurationSeconds: interExerciseRest,
                nextExercise: nextExercise,
                nextSetIndex: 1,
              );
        }
      } else {
        debugPrint('⌚🔥 [FLUTTER] 🏁 Last exercise completed - workout finished!');
      }
    }
  }

  /// Handle entire dropset completion from Watch (all stages done at once)
  void _completeDropsetFromWatch({
    required int totalStages,
    int? effort,
    String? effortScale,
  }) {
    debugPrint('⌚🔥 [FLUTTER] _completeDropsetFromWatch called');
    debugPrint('⌚🔥 [FLUTTER] Total stages: $totalStages');

    if (state == null) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No active workout');
      return;
    }

    final workout = state!;

    // Find current dropset exercise
    DropSetExercise? currentDropset;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is DropSetExercise) {
        if (exercise.stages.any((s) => !s.isCompleted)) {
          currentDropset = exercise;
          exerciseIndex = i;
          break;
        }
      }
    }

    if (currentDropset == null || exerciseIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No dropset with incomplete stages found');
      return;
    }

    // Convert RIR to RPE if needed
    int? rpeValue = effort;
    if (effort != null && effortScale == 'rir') {
      rpeValue = (10 - effort).clamp(6, 10);
    }

    // Mark all remaining stages as completed
    final updatedStages = currentDropset.stages.map((stage) {
      if (!stage.isCompleted) {
        return stage.copyWith(
          actualReps: stage.reps, // Use target reps as actual
          rpe: rpeValue,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      return stage;
    }).toList();

    // Create updated exercise using copyWith to preserve all fields
    final updatedExercise = currentDropset.copyWith(
      stages: updatedStages,
    );

    // Update workout state
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;
    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint('⌚🔥 [FLUTTER] ✅ Entire dropset completed');

    // 💾 Auto-save
    _autoSaveIfNeeded();

    // ⌚ Update Watch with new state
    _notifyWatchWorkoutUpdate();

    // 📱 Sync Live Activity (iOS)
    _updateLiveActivityIfActive();

    // Start rest timer after completing dropset
    if (currentDropset.restTime != null) {
      final timerActions = ref.read(tier1TimerActionsProvider);
      timerActions.startExerciseRest(
        seconds: currentDropset.restTime!,
        exerciseName: currentDropset.name,
        currentSet: 1,
        totalSets: 1,
      );
    }
  }

  // ============================================================
  // 🔥 REST-PAUSE: Watch handlers
  // ============================================================

  /// Handle rest-pause set completion from Watch
  void _completeRestPauseSetFromWatch({
    required int setIndex,
    required int totalSets,
    required int actualReps,
    required double weight,
    int? effort,
    String? effortScale,
  }) {
    debugPrint('⌚🔥 [FLUTTER] _completeRestPauseSetFromWatch called');
    debugPrint(
      '⌚🔥 [FLUTTER] Set ${setIndex + 1}/$totalSets, reps: $actualReps, weight: $weight',
    );

    if (state == null) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No active workout');
      return;
    }

    final workout = state!;

    // Find current rest-pause exercise (first with incomplete sets)
    RestPauseExercise? currentRestPause;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is RestPauseExercise) {
        if (exercise.restPauseSets.any((s) => !s.isCompleted)) {
          currentRestPause = exercise;
          exerciseIndex = i;
          break;
        }
      }
    }

    if (currentRestPause == null || exerciseIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No rest-pause with incomplete sets found');
      return;
    }

    // Find the target set (should match setIndex or first incomplete)
    final targetSetIndex = currentRestPause.restPauseSets.indexWhere(
      (s) => !s.isCompleted,
    );
    if (targetSetIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No incomplete set found');
      return;
    }

    // ✅ DEDUPLICATION: Prevent duplicate processing
    final now = DateTime.now();
    final setKey = '${currentRestPause.id}_set_$targetSetIndex';
    if (_lastCompletedSetId == setKey &&
        _lastWatchSetCompletion != null &&
        now.difference(_lastWatchSetCompletion!).inSeconds < 3) {
      debugPrint('⌚🔥 [FLUTTER] ⚠️ Duplicate message ignored');
      return;
    }
    _lastWatchSetCompletion = now;
    _lastCompletedSetId = setKey;

    // Convert RIR to RPE if needed
    int? rpeValue = effort;
    if (effort != null && effortScale == 'rir') {
      rpeValue = (10 - effort).clamp(6, 10);
    }

    // Update the set
    final currentSet = currentRestPause.restPauseSets[targetSetIndex];
    final updatedSets = List<RestPauseSet>.from(currentRestPause.restPauseSets);
    updatedSets[targetSetIndex] = currentSet.copyWith(
      actualReps: actualReps,
      rpe: rpeValue,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    // Create updated exercise using copyWith to preserve all fields
    final updatedExercise = currentRestPause.copyWith(
      restPauseSets: updatedSets,
    );

    // Update workout state
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;
    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint(
      '⌚🔥 [FLUTTER] ✅ Rest-Pause set ${targetSetIndex + 1} completed',
    );

    // Check if there are more sets
    final remainingSets = updatedExercise.restPauseSets
        .where((s) => !s.isCompleted)
        .length;
    final isLastSet = remainingSets == 0;

    // 💾 Auto-save
    _autoSaveIfNeeded();

    // ⌚ Update Watch with new state
    _notifyWatchWorkoutUpdate();

    // 📱 Sync Live Activity (iOS)
    _updateLiveActivityIfActive();

    // Start short rest timer between rest-pause sets (not the full rest)
    if (!isLastSet) {
      // Use the rest seconds from the NEXT set (if available)
      final nextSetIndex = targetSetIndex + 1;
      if (nextSetIndex < updatedExercise.restPauseSets.length) {
        final nextSet = updatedExercise.restPauseSets[nextSetIndex];
        final restSeconds = nextSet.restSeconds > 0
            ? nextSet.restSeconds
            : 15; // Default 15s

        final timerActions = ref.read(tier1TimerActionsProvider);
        timerActions.startExerciseRest(
          seconds: restSeconds,
          exerciseName: '${currentRestPause.name} - Set ${nextSetIndex + 1}',
          currentSet: nextSetIndex + 1,
          totalSets: updatedExercise.restPauseSets.length,
        );
      }
    } else if (currentRestPause.restTime != null) {
      // Last set - start full rest timer
      final timerActions = ref.read(tier1TimerActionsProvider);
      timerActions.startExerciseRest(
        seconds: currentRestPause.restTime!,
        exerciseName: currentRestPause.name,
        currentSet: 1,
        totalSets: 1,
      );
    }
  }

  /// Handle entire rest-pause completion from Watch (all sets done at once)
  void _completeRestPauseFromWatch({
    required int totalSets,
    required double weight,
    int? effort,
    String? effortScale,
  }) {
    debugPrint('⌚🔥 [FLUTTER] _completeRestPauseFromWatch called');
    debugPrint('⌚🔥 [FLUTTER] Total sets: $totalSets, weight: $weight');

    if (state == null) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No active workout');
      return;
    }

    final workout = state!;

    // Find current rest-pause exercise
    RestPauseExercise? currentRestPause;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is RestPauseExercise) {
        if (exercise.restPauseSets.any((s) => !s.isCompleted)) {
          currentRestPause = exercise;
          exerciseIndex = i;
          break;
        }
      }
    }

    if (currentRestPause == null || exerciseIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No rest-pause with incomplete sets found');
      return;
    }

    // Convert RIR to RPE if needed
    int? rpeValue = effort;
    if (effort != null && effortScale == 'rir') {
      rpeValue = (10 - effort).clamp(6, 10);
    }

    // Mark all remaining sets as completed
    final updatedSets = currentRestPause.restPauseSets.map((set) {
      if (!set.isCompleted) {
        return set.copyWith(
          actualReps: set.reps, // Use target reps as actual
          rpe: rpeValue,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      return set;
    }).toList();

    // Create updated exercise using copyWith to preserve all fields
    final updatedExercise = currentRestPause.copyWith(
      restPauseSets: updatedSets,
    );

    // Update workout state
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;
    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint('⌚🔥 [FLUTTER] ✅ Entire rest-pause completed');

    // 💾 Auto-save
    _autoSaveIfNeeded();

    // ⌚ Update Watch with new state
    _notifyWatchWorkoutUpdate();

    // 📱 Sync Live Activity (iOS)
    _updateLiveActivityIfActive();

    // Start inter-exercise timer if there's a next exercise
    debugPrint('⌚🔥 [FLUTTER] 🏁 Rest-Pause completed! Checking for next exercise...');

    final nextExercise = _getNextIncompleteExercise(state!, currentRestPause);
    if (nextExercise != null) {
      final interExerciseRest = _resolveInterExerciseRest(currentRestPause);
      final nextExerciseTotalSets = _getExerciseTotalSets(nextExercise);

      debugPrint(
        '⏰ [TIMER] 🏋️ Starting INTER-EXERCISE timer after rest-pause: ${interExerciseRest}s before ${nextExercise.name}',
      );

      ref
          .read(unifiedTimerProvider.notifier)
          .startTimer(
            durationSeconds: interExerciseRest,
            type: TimerType.interExercise,
            exerciseName: nextExercise.name,
            currentSet: 1,
            totalSets: nextExerciseTotalSets,
            exerciseId: nextExercise.id,
          );

      // 📱 iOS: Transition Live Activity
      if (Platform.isIOS) {
        ref
            .read(workoutSessionLAProvider.notifier)
            .transitionToRest(
              restDurationSeconds: interExerciseRest,
              nextExercise: nextExercise,
              nextSetIndex: 1,
            );
      }
    } else {
      debugPrint('⌚🔥 [FLUTTER] 🏁 Last exercise completed - workout finished!');
    }
  }

  // ============================================================
  // 🔄 NAVIGATION & COPY METHODS (from Watch)
  // ============================================================

  /// ⌚ Jump to a specific exercise when triggered from Apple Watch
  /// - exerciseIndex: 0-indexed position in the exercises list
  void _jumpToExerciseFromWatch(int exerciseIndex) {
    debugPrint('⌚ [FLUTTER] ↔️ Jumping to exercise at index $exerciseIndex');

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Validate index
    if (exerciseIndex < 0 || exerciseIndex >= workout.exercises.length) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ Invalid exerciseIndex $exerciseIndex (have ${workout.exercises.length} exercises)',
      );
      return;
    }

    final targetExercise = workout.exercises[exerciseIndex];
    debugPrint('⌚ [FLUTTER] 🎯 Target exercise: ${targetExercise.name}');

    // Update Watch with the new exercise state
    _notifyWatchWorkoutUpdate();

    // Note: The UI will automatically show the correct exercise because
    // _notifyWatchWorkoutUpdate sends the current state based on first incomplete set
    debugPrint(
      '⌚ [FLUTTER] ✅ Jumped to exercise ${exerciseIndex + 1}: ${targetExercise.name}',
    );
  }

  /// ⌚ Jump to a specific set when triggered from Apple Watch
  /// - setNumber: 1-indexed set number to navigate to
  void _jumpToSetFromWatch(int setNumber) {
    debugPrint('⌚ [FLUTTER] ↕️ Jumping to set $setNumber');

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Find the current exercise (first with incomplete sets)
    Exercise? currentExercise;
    for (final exercise in workout.exercises) {
      if (exercise is SupersetExercise) {
        if (exercise.supersetSets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      } else {
        if (exercise.sets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      }
    }

    // Fallback to last exercise
    currentExercise ??= workout.exercises.isNotEmpty
        ? workout.exercises.last
        : null;

    if (currentExercise == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No exercise found');
      return;
    }

    // Validate setNumber (1-indexed)
    final setIndex = setNumber - 1;
    if (setIndex < 0 || setIndex >= currentExercise.sets.length) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ Invalid setNumber $setNumber (have ${currentExercise.sets.length} sets)',
      );
      return;
    }

    debugPrint(
      '⌚ [FLUTTER] 🎯 Target set: $setNumber of ${currentExercise.name}',
    );

    // Update Watch with the new state
    _notifyWatchWorkoutUpdate();

    debugPrint('⌚ [FLUTTER] ✅ Jumped to set $setNumber');
  }

  /// ⌚ Copy weight and reps to all sets when triggered from Apple Watch
  /// - weight: Weight value to apply
  /// - reps: Reps value to apply
  void _copyToAllSetsFromWatch(double weight, int reps) {
    debugPrint('⌚ [FLUTTER] 📄 Copying to all sets: ${weight}kg × $reps');

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Find the current exercise (first with incomplete sets)
    Exercise? currentExercise;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is SupersetExercise) {
        if (exercise.supersetSets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          exerciseIndex = i;
          break;
        }
      } else {
        if (exercise.sets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          exerciseIndex = i;
          break;
        }
      }
    }

    // Fallback to last exercise
    if (currentExercise == null && workout.exercises.isNotEmpty) {
      currentExercise = workout.exercises.last;
      exerciseIndex = workout.exercises.length - 1;
    }

    if (currentExercise == null || exerciseIndex < 0) {
      debugPrint('⌚ [FLUTTER] ⚠️ No exercise found');
      return;
    }

    // Update ALL sets with the new weight and reps (for non-superset exercises)
    if (currentExercise is! SupersetExercise) {
      final updatedSets = currentExercise.sets.map((set) {
        return set.copyWith(weight: weight, reps: reps);
      }).toList();

      final updatedExercise = currentExercise.copyWith(sets: updatedSets);
      final updatedExercises = List<Exercise>.from(workout.exercises);
      updatedExercises[exerciseIndex] = updatedExercise;

      state = workout.copyWith(
        exercises: updatedExercises,
        updatedAt: DateTime.now(),
      );

      debugPrint(
        '⌚ [FLUTTER] ✅ Copied ${weight}kg × $reps to all ${updatedSets.length} sets of ${currentExercise.name}',
      );

      // Auto-save
      _autoSaveIfNeeded();

      // Update Watch with new state
      _notifyWatchWorkoutUpdate();
    } else {
      debugPrint('⌚ [FLUTTER] ⚠️ Copy to all sets not supported for supersets');
    }
  }

  /// ⌚ Copy from previous set when triggered from Apple Watch
  void _copyFromPreviousSetFromWatch() {
    debugPrint('⌚ [FLUTTER] 📋 Copying from previous set');

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Find the current exercise (first with incomplete sets)
    Exercise? currentExercise;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is! SupersetExercise &&
          exercise.sets.any((s) => !s.isCompleted)) {
        currentExercise = exercise;
        exerciseIndex = i;
        break;
      }
    }

    if (currentExercise == null || exerciseIndex < 0) {
      debugPrint('⌚ [FLUTTER] ⚠️ No exercise with incomplete sets found');
      return;
    }

    // Find the first incomplete set
    final firstIncompleteIndex = currentExercise.sets.indexWhere(
      (s) => !s.isCompleted,
    );
    if (firstIncompleteIndex <= 0) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ No previous set to copy from (current is first set)',
      );
      return;
    }

    // Get previous completed set
    final previousSet = currentExercise.sets[firstIncompleteIndex - 1];
    final currentSet = currentExercise.sets[firstIncompleteIndex];

    // Copy weight and reps from previous set
    final updatedSet = currentSet.copyWith(
      weight: previousSet.weight,
      reps: previousSet.reps,
    );

    final updatedSets = List<ExerciseSet>.from(currentExercise.sets);
    updatedSets[firstIncompleteIndex] = updatedSet;

    final updatedExercise = currentExercise.copyWith(sets: updatedSets);
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;

    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint(
      '⌚ [FLUTTER] ✅ Copied ${previousSet.weight}kg × ${previousSet.reps} from set ${firstIncompleteIndex} to set ${firstIncompleteIndex + 1}',
    );

    // Auto-save
    _autoSaveIfNeeded();

    // Update Watch with new state
    _notifyWatchWorkoutUpdate();
  }

  /// ⌚ Start a new timer with specific duration when triggered from Apple Watch
  /// - duration: Timer duration in seconds
  void _startNewTimerFromWatch(int duration) {
    debugPrint('⌚ [FLUTTER] ⏱️ Starting new timer: ${duration}s');

    // Use the unified timer provider to start a new rest timer
    final timerActions = ref.read(tier1TimerActionsProvider);

    // Get current exercise name for context
    String exerciseName = 'Rest';
    if (state != null) {
      for (final exercise in state!.exercises) {
        if (exercise is SupersetExercise) {
          if (exercise.supersetSets.any((s) => !s.isCompleted)) {
            exerciseName = exercise.name;
            break;
          }
        } else {
          if (exercise.sets.any((s) => !s.isCompleted)) {
            exerciseName = exercise.name;
            break;
          }
        }
      }
    }

    timerActions.startExerciseRest(
      seconds: duration,
      exerciseName: exerciseName,
      currentSet: 1,
      totalSets: 1,
    );

    debugPrint('⌚ [FLUTTER] ✅ Timer started: ${duration}s for $exerciseName');
  }

  void completeSet(String exerciseId, String setId) {
    debugPrint(
      '🏋️ [completeSet] Called with exerciseId=$exerciseId, setId=$setId',
    );
    if (state == null) {
      debugPrint('🏋️ [completeSet] ❌ state is null, returning early');
      return;
    }
    debugPrint('🏋️ [completeSet] ✅ state exists, proceeding...');

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

      // 🔄 WEIGHT CARRY-FORWARD: Propagate weight to subsequent incomplete sets
      if (completedSet != null &&
          completedSet!.weight != null &&
          completedSet!.weight! > 0) {
        final completedWeight = completedSet!.weight!;

        final exercisesWithCarryForward = state!.exercises.map((exercise) {
          if (exercise.id == exerciseId) {
            var weightUpdated = false;
            final updatedSets = exercise.sets.map((set) {
              // Only update sets AFTER the completed one that have 0 or null weight
              if (set.setNumber > completedSetNumber &&
                  !set.isCompleted &&
                  (set.weight == null || set.weight == 0)) {
                weightUpdated = true;
                return set.copyWith(weight: completedWeight);
              }
              return set;
            }).toList();

            if (weightUpdated && kDebugMode) {
              debugLog(
                LogCategory.workout,
                '🔄 [WEIGHT-CARRY] Propagated ${completedWeight}kg from set $completedSetNumber to subsequent sets',
              );
            }

            return exercise.copyWith(sets: updatedSets);
          }
          return exercise;
        }).toList();

        state = state!.copyWith(exercises: exercisesWithCarryForward);
      }

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

      // ⌚ Notify Apple Watch about set completion
      _notifyWatchWorkoutUpdate();

      // 🔍 DEBUG: Log timer decision parameters
      debugPrint(
        '⏰ [TIMER DEBUG] completeSet finished - checking timer conditions:',
      );
      debugPrint(
        '⏰ [TIMER DEBUG] targetExercise: ${targetExercise?.name ?? "NULL"}',
      );
      debugPrint('⏰ [TIMER DEBUG] completedSetNumber: $completedSetNumber');
      debugPrint('⏰ [TIMER DEBUG] totalSets: $totalSets');

      // ✅ BUG #2 FIX: Auto-start rest timer after completing a set
      if (targetExercise != null && completedSetNumber > 0) {
        // Check if not the last set
        final isLastSet = completedSetNumber >= totalSets;
        debugPrint('⏰ [TIMER DEBUG] isLastSet: $isLastSet');

        if (!isLastSet) {
          // Get rest time from exercise (default 90 seconds)
          final restTime = targetExercise!.restTime ?? 90;
          final nextSetNumber = completedSetNumber + 1;

          debugPrint(
            '⏰ [TIMER] 🚀 Starting rest timer: ${restTime}s for set $nextSetNumber/$totalSets',
          );

          // Start the timer automatically
          ref
              .read(unifiedTimerProvider.notifier)
              .startTimer(
                durationSeconds: restTime,
                exerciseName: targetExercise!.name,
                currentSet: nextSetNumber,
                totalSets: totalSets,
                exerciseId: targetExercise!.id,
                completedSetId: setId, // ✅ Rest Timer Tracking: pass completed set ID
              );

          debugPrint('⏰ [TIMER] ✅ Timer start called!');

          // 📱 iOS 17+: Transition Live Activity to rest mode
          if (Platform.isIOS) {
            final laState = ref.read(workoutSessionLAProvider);
            debugPrint(
              '[WorkoutProvider] 📱 LA state before transition: isActive=${laState.isActive}, activityId=${laState.activityId}',
            );

            ref
                .read(workoutSessionLAProvider.notifier)
                .transitionToRest(
                  restDurationSeconds: restTime,
                  nextExercise: targetExercise!,
                  nextSetIndex: nextSetNumber,
                );
          }
        } else {
          // Last set of this exercise - check for inter-exercise timer
          final nextExercise = _getNextIncompleteExercise(state!, targetExercise!);

          if (nextExercise != null) {
            // Start inter-exercise rest timer
            final interExerciseRest = _resolveInterExerciseRest(targetExercise!);
            final nextExerciseTotalSets = _getExerciseTotalSets(nextExercise);

            debugPrint(
              '⏰ [TIMER] 🏋️ Starting INTER-EXERCISE timer: ${interExerciseRest}s before ${nextExercise.name}',
            );

            ref
                .read(unifiedTimerProvider.notifier)
                .startTimer(
                  durationSeconds: interExerciseRest,
                  type: TimerType.interExercise,
                  exerciseName: nextExercise.name,
                  currentSet: 1,
                  totalSets: nextExerciseTotalSets,
                  exerciseId: nextExercise.id,
                  completedSetId: setId, // ✅ Rest Timer Tracking: pass completed set ID
                );

            // 📱 iOS 17+: Transition Live Activity to inter-exercise rest mode
            if (Platform.isIOS) {
              ref
                  .read(workoutSessionLAProvider.notifier)
                  .transitionToRest(
                    restDurationSeconds: interExerciseRest,
                    nextExercise: nextExercise,
                    nextSetIndex: 1,
                  );
            }
          } else {
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '⏰ [AUTO-TIMER] Last exercise completed - workout finished!',
              );
            }
          }
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error completing set: $e',
        );
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

      // ⌚ BUG FIX #2: Notify Watch when set completion state changes
      // This ensures deselecting a set (marking incomplete) syncs to Watch
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error updating exercise set: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// ✅ Rest Timer Tracking: Update a completed set with rest timer data
  /// Called by unified_timer_provider when the rest timer completes or is skipped
  void updateSetRestTimerData({
    required String exerciseId,
    required String setId,
    required bool restTimerSkipped,
    int? restTimerSecondsRemaining,
    int? restTimerSecondsAdded,
    int? actualRestSeconds,
  }) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId) {
          final updatedSets = exercise.sets.map((set) {
            if (set.id == setId) {
              return set.copyWith(
                restTimerSkipped: restTimerSkipped,
                restTimerSecondsRemaining: restTimerSecondsRemaining,
                restTimerSecondsAdded: restTimerSecondsAdded,
                actualRestSeconds: actualRestSeconds,
              );
            }
            return set;
          }).toList();
          return exercise.copyWith(sets: updatedSets);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      if (kDebugMode) {
        debugPrint(
          '⏱️ [REST-TIMER] Updated set $setId: skipped=$restTimerSkipped, remaining=${restTimerSecondsRemaining}s, added=${restTimerSecondsAdded}s, actual=${actualRestSeconds}s',
        );
      }

      // 💾 Auto-save modifications
      _autoSaveIfNeeded();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error updating set rest timer data: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
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

      // ⌚ Sync to Watch
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error updating superset set: $e',
        );
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

      // ⌚ Sync to Watch
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error adding set to exercise: $e',
        );
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
          final updatedSets = exercise.sets
              .where((set) => set.id != setId)
              .toList();

          // Prevent removing last set
          if (updatedSets.isEmpty) {
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '⚠️ [WorkoutProvider] Cannot remove last set from exercise',
              );
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

      // ⌚ Sync to Watch
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error removing set from exercise: $e',
        );
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
              targetWeight:
                  lastData?.targetWeight ?? lastData?.actualWeight ?? 0.0,
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
            supersetSets: [...exercise.supersetSets, newRound],
          );
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      // ⌚ Sync to Watch
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error adding round to superset: $e',
        );
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
              debugLog(
                LogCategory.workout,
                '⚠️ [WorkoutProvider] Cannot remove last round from superset',
              );
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

      // ⌚ Sync to Watch
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error removing round from superset: $e',
        );
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
        debugLog(
          LogCategory.workout,
          '🔄 [WorkoutProvider] Undoing workout completion: ${state!.name}',
        );
      }

      // Restore workout to active state
      state = state!.copyWith(status: WorkoutStatus.inProgress, endTime: null);

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

        // ⌚ BUG FIX: Notify Watch to discard HKWorkoutSession
        // Without this, Watch keeps its session running and SAVES to HealthKit
        // when the session eventually ends, adding phantom workout minutes
        ref.read(watchConnectivityProvider.notifier).notifyWorkoutEnded();

        // 📱 End iOS 17+ Workout Session Live Activity
        if (Platform.isIOS) {
          ref
              .read(workoutSessionLAProvider.notifier)
              .endLiveActivity(dismissPolicy: 'immediate');
        }
      }

      state = null;

      // 💾 BUG FIX #5: Stop auto-save and clear draft when workout is cancelled
      ref.read(workoutAutoSaveProvider.notifier).stopAutoSave(clearDraft: true);

      // Disattiva wakelock quando si cancella il workout
      ref.read(screenWakelockProvider.notifier).stopWakelock();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error clearing workout: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Ensure state is cleared even if wakelock fails
      state = null;
      // Still try to stop auto-save
      ref.read(workoutAutoSaveProvider.notifier).stopAutoSave(clearDraft: true);
    }
  }

  /// Maps shared PRType to domain-layer PRType
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

  // ══════════════════════════════════════════════════════════════════════════
  // INTER-EXERCISE REST TIMER HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Finds the next exercise with incomplete sets after the given exercise.
  /// Returns null if current exercise is the last one or all following are complete.
  Exercise? _getNextIncompleteExercise(Workout workout, Exercise current) {
    final currentIndex = workout.exercises.indexWhere((e) => e.id == current.id);
    if (currentIndex == -1) return null;

    for (int i = currentIndex + 1; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (!exercise.isCompleted) {
        return exercise;
      }
    }
    return null;
  }

  /// Resolves the rest time between exercises with priority:
  /// 1. Exercise.restAfterExercise (if set)
  /// 2. AppConfig.defaultRestBetweenExercises
  /// 3. 90 seconds (hardcoded fallback)
  int _resolveInterExerciseRest(Exercise exercise) {
    // 1. Exercise-specific override
    if (exercise.restAfterExercise != null) {
      return exercise.restAfterExercise!;
    }

    // 2. Global default from config
    final appConfig = ref.read(appConfigProvider);
    return appConfig.defaultRestBetweenExercises;
  }

  /// Gets total sets count for any exercise type (polymorphic)
  int _getExerciseTotalSets(Exercise exercise) {
    if (exercise is SupersetExercise) {
      return exercise.supersetSets.length;
    } else if (exercise is DropSetExercise) {
      return exercise.stages.length;
    } else if (exercise is RestPauseExercise) {
      return exercise.restPauseSets.length;
    }
    return exercise.sets.length;
  }

  // Note: Notifier doesn't have dispose() - use ref.onDispose() in build() instead
}

// Exercise suggestions provider (static exercise name database for autocomplete)
final exerciseTemplatesProvider = Provider<Map<ExerciseCategory, List<String>>>(
  (ref) {
    return ExerciseSuggestions.exerciseDatabase;
  },
);

// Exercise search provider
final exerciseSearchProvider = createStateProvider<String>('');

final filteredExercisesProvider = Provider<List<String>>((ref) {
  final searchQuery = ref.watch(exerciseSearchProvider);

  if (searchQuery.isEmpty) {
    return [];
  }

  return ExerciseSuggestions.searchExercises(searchQuery);
});

// Selected exercise category for modal
final selectedExerciseCategoryProvider = createStateProvider<ExerciseCategory>(
  ExerciseCategory.chest,
);

// Selected exercise type for modal
final selectedExerciseTypeProvider = createStateProvider<ExerciseType>(
  ExerciseType.single,
);

/// Provider for fetching workouts from the last N days
///
/// Usage: ref.watch(recentWorkoutsProvider(7)) → Last 7 days
///
/// Returns: List of Workout filtered by:
/// - startTime is not null
/// - startTime is after cutoff date (now - N days)
///
/// Throws: Exception if repository fetch fails
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final recentWorkoutsProvider = FutureProvider.autoDispose
    .family<List<Workout>, int>((ref, days) async {
      final repository = ref.watch(workoutRepositoryProvider);
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final result = await repository.getWorkouts(limit: 50);

      return result.fold(
        (failure) =>
            throw Exception('Failed to load workouts: ${failure.message}'),
        (workouts) => workouts
            .where(
              (w) => w.startTime != null && w.startTime!.isAfter(cutoffDate),
            )
            .toList(),
      );
    });
