import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart'
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
import 'package:gymbro_flutter_new/features/workout/timer/presentation/providers/unified_timer_provider.dart';
import 'package:gymbro_flutter_new/features/workout/timer/presentation/providers/unified_timer_extensions.dart';
// 🏋️ TimerType enum for inter-exercise timer
import 'package:gymbro_flutter_new/features/workout/timer/domain/models/unified_timer_state.dart';
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
// 📊 Historical Workouts Provider for exercise progress metrics refresh
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart'
    show historicalWorkoutsProvider;
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
import 'package:gymbro_flutter_new/shared/domain/user/user_xp_provider.dart';
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
// 🔄 RPE Autoregulation for rest time adjustment
import 'package:gymbro_flutter_new/features/workout/domain/services/rpe_autoregulation_service.dart';
// 📱 iOS 17+ Workout Session Live Activity
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_session_la_provider.dart';
// 📊 Exercise Usage Tracker for recent exercises in exercise picker
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_usage_tracker.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/workout_session_la_service.dart'
    show WorkoutSessionMode;
// ⚖️ Weight Auto-Fill for pre-filling sets from previous session
import 'package:gymbro_flutter_new/features/workout/presentation/providers/weight_auto_fill_provider.dart';

part 'parts/workout_core_mixin.dart';
part 'parts/workout_helpers_mixin.dart';
part 'parts/workout_lifecycle_mixin.dart';
part 'parts/workout_exercise_mixin.dart';
part 'parts/workout_set_mixin.dart';
part 'parts/workout_save_mixin.dart';
part 'parts/workout_save_cloud_mixin.dart';
part 'parts/workout_watch_notify_mixin.dart';
part 'parts/workout_watch_compound_mixin.dart';
part 'parts/workout_watch_commands_mixin.dart';
part 'parts/workout_watch_navigation_mixin.dart';
part 'parts/workout_watch_type_mixin.dart';

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

class CurrentWorkoutNotifier extends Notifier<Workout?>
    with
        WorkoutCoreMixin,
        WorkoutHelpersMixin,
        WorkoutWatchNotifyMixin,
        WorkoutWatchTypeMixin,
        WorkoutWatchCompoundMixin,
        WorkoutWatchCommandsMixin,
        WorkoutWatchNavigationMixin,
        WorkoutSaveCloudMixin,
        WorkoutSaveMixin,
        WorkoutExerciseMixin,
        WorkoutSetMixin,
        WorkoutLifecycleMixin {
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

  /// ⌚ Register all Apple Watch callbacks.
  ///
  /// This method lives in the main class (not in a mixin) so it can reference
  /// methods from all applied mixins without triggering circular `on` constraints.
  /// Called from WorkoutWatchNotifyMixin._notifyWatchWorkoutStarted().
  void _setupWatchCallbacks() {
    final watchNotifier = ref.read(watchConnectivityProvider.notifier);
    watchNotifier.onSetCompletedFromWatch = completeCurrentSetFromWatch;
    watchNotifier.onSkipRestFromWatch = _skipRestFromWatch;
    watchNotifier.onHealthMetricsFromWatch = _handleHealthMetricsFromWatch;
    watchNotifier.onEndWorkoutFromWatch = _endWorkoutFromWatch;
    watchNotifier.onEditCompletedSetRepsFromWatch = _editCompletedSetRepsFromWatch;
    watchNotifier.onUncompleteSetFromWatch = _uncompleteSetFromWatch;
    watchNotifier.onSetModificationFromWatch = _updateCurrentSetTargetFromWatch;
    watchNotifier.onSupersetRoundCompletedFromWatch = _completeSupersetRoundFromWatch;
    // 🔥 DROPSET: Register callbacks
    watchNotifier.onDropsetStageCompletedFromWatch = _completeDropsetStageFromWatch;
    watchNotifier.onDropsetCompletedFromWatch = _completeDropsetFromWatch;
    // 🔥 REST-PAUSE: Register callbacks
    watchNotifier.onRestPauseSetCompletedFromWatch = _completeRestPauseSetFromWatch;
    watchNotifier.onRestPauseCompletedFromWatch = _completeRestPauseFromWatch;
    // 🔄 Navigation & Copy callbacks from Watch
    watchNotifier.onJumpToExerciseFromWatch = _jumpToExerciseFromWatch;
    watchNotifier.onJumpToSetFromWatch = _jumpToSetFromWatch;
    watchNotifier.onCopyToAllSetsFromWatch = _copyToAllSetsFromWatch;
    watchNotifier.onCopyFromPreviousSetFromWatch = _copyFromPreviousSetFromWatch;
    watchNotifier.onStartNewTimerFromWatch = _startNewTimerFromWatch;
  }
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

/// Infers a sensible TUT string from exercise metadata when no explicit
/// [tempoEsecuzione] is stored in the database.
///
/// Logic (priority: patternMovimento > tipoEsercizio > default):
/// - Powerlifting / heavy compound patterns → 2-1-2-0 (controlled, short pause)
/// - Push/Pull/Hinge/Squat/Lunge → 3-1-2-0 (hypertrophy standard)
/// - Isolation / Functional → 2-0-2-0 (peak contraction focus)
/// - Stretching / Flexibility → 1-0-3-0 (hold for stretch)
/// - Cardio → 1-0-1-0 (explosive rhythm)
/// - Unknown → [defaultTut] passed in (keeps existing behavior)
/// Infers a sensible TUT string from exercise metadata when no explicit
/// [tempoEsecuzione] is stored in the database.
///
/// Format: eccentrica-pausa_basso-concentrica-pausa_alto
/// Priority: patternMovimento > tipoEsercizio > defaultTut
///
/// Sources: exercise science literature (Schoenfeld 2010, Pereira 2016)
String? _inferTutFromExercise({
  String? tipoEsercizio,
  String? patternMovimento,
  String? defaultTut,
}) {
  final pattern = patternMovimento?.toLowerCase() ?? '';
  final tipo = tipoEsercizio?.toLowerCase() ?? '';

  // Stretching/Flexibility: TUT non si applica a movimenti statici
  if (pattern.contains('flexibility') || tipo == 'stretching') return null;

  // Isometrico / Anti-Rotation / Core Stability: hold isometrico
  // formato 0-hold-0-hold (es. Pallof Press, Plank, Ab Wheel)
  if (pattern.contains('anti-rotation') ||
      pattern.contains('core stability')) {
    return '0-2-0-2';
  }

  // Powerlifting: velocità + elasticità (stretch-shortening cycle)
  if (pattern.contains('powerlifting')) return '2-1-2-0';

  // Squat / Lunge: eccentric e concentric lunghi per ipertrofia quad
  if (pattern.contains('squat') || pattern.contains('lunge')) return '3-1-3-0';

  // Hinge (RDL, Good Morning): NO pausa bassa con carico (rischio lesione ischio)
  if (pattern.contains('hinge')) return '3-0-2-0';

  // Pull (Rows, Pullup): controllo scapolare, eccentrico dominante
  if (pattern.contains('pull')) return '3-1-2-0';

  // Push (Bench, OHP): simmetrico, eccentrico moderato
  if (pattern.contains('push')) return '2-1-2-0';

  // Strength generico: sub-massimale con controllo
  if (pattern.contains('strength')) return '3-1-2-0';

  // Isolation / Functional: flusso continuo, picco di contrazione
  if (pattern.contains('isolation') ||
      pattern.contains('functional')) {
    return '2-0-2-0';
  }

  // Fallback su tipoEsercizio
  if (tipo == 'compound') return '3-1-2-0';
  if (tipo == 'isolation') return '2-0-2-0';
  if (tipo == 'cardio') return '1-0-1-0';

  return defaultTut;
}
