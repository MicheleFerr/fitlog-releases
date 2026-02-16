import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/core/utils/app_logger.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_draft_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/services/request_throttler.dart';

/// Provider for the draft repository
/// FIX: keepAlive() previene disposal/ricreazione che causava 5x init all'avvio
final workoutDraftRepositoryProvider = Provider<WorkoutDraftRepository>((ref) {
  ref.keepAlive(); // Previene ricreazione su hot reload o dispose
  return WorkoutDraftRepository(ref.watch(hiveBoxManagerProvider));
});

/// Provider for workout auto-save functionality
final workoutAutoSaveProvider =
    NotifierProvider<WorkoutAutoSaveNotifier, WorkoutAutoSaveState>(
      WorkoutAutoSaveNotifier.new,
    );

/// State for auto-save functionality
class WorkoutAutoSaveState {
  WorkoutAutoSaveState({
    this.isAutoSaveEnabled = true,
    this.lastSaveTime,
    this.isSaving = false,
    this.lastError,
  });
  final bool isAutoSaveEnabled;
  final DateTime? lastSaveTime;
  final bool isSaving;
  final String? lastError;

  WorkoutAutoSaveState copyWith({
    bool? isAutoSaveEnabled,
    DateTime? lastSaveTime,
    bool? isSaving,
    String? lastError,
  }) {
    return WorkoutAutoSaveState(
      isAutoSaveEnabled: isAutoSaveEnabled ?? this.isAutoSaveEnabled,
      lastSaveTime: lastSaveTime ?? this.lastSaveTime,
      isSaving: isSaving ?? this.isSaving,
      lastError: lastError,
    );
  }
}

/// Notifier for managing workout auto-save
/// NOTE: Emergency save is handled centrally by AppLifecycleManager (app_lifecycle_manager.dart)
/// This notifier focuses ONLY on periodic auto-save and draft recovery.
class WorkoutAutoSaveNotifier extends Notifier<WorkoutAutoSaveState> {
  late final WorkoutDraftRepository _repository;
  Timer? _autoSaveTimer;
  late final Debouncer _saveDebouncer;
  Workout? _lastSavedWorkout;

  // FIX #2: Reduced auto-save interval to prevent workout data loss
  // Previous value (10 minutes) was too long - if iOS kills the app,
  // user could lose up to 10 minutes of workout progress.
  // 2 minutes is a better balance between battery usage and data safety.
  static const Duration _autoSaveInterval = Duration(minutes: 2);
  static const Duration _debounceDelay = Duration(seconds: 1);

  @override
  WorkoutAutoSaveState build() {
    // FIX: Use ref.read() to avoid re-initialization on rebuild
    // Repository doesn't change, so we don't need to watch it
    _repository = ref.read(workoutDraftRepositoryProvider);

    // Setup disposal on provider cleanup
    ref.onDispose(() {
      // CRITICAL CPU FIX: Force cancel all timers immediately
      if (_autoSaveTimer != null) {
        _autoSaveTimer!.cancel();
        _autoSaveTimer = null;
      }

      // Dispose debouncer properly
      _saveDebouncer.dispose();

      // Clear references to prevent memory leaks
      _lastSavedWorkout = null;
    });

    _init();
    return WorkoutAutoSaveState();
  }

  void _init() {
    // 🔐 SECURITY: Initialize save debouncer with error handling
    _saveDebouncer = Debouncer(
      duration: _debounceDelay,
      onError: (error, stackTrace) {
        AppLogger.error(
          'Debouncer error: $error',
          tag: 'WorkoutAutoSave',
          error: error,
          stackTrace: stackTrace,
        );
        state = state.copyWith(isSaving: false, lastError: error.toString());
      },
    );

    // NOTE: Lifecycle observer REMOVED - emergency save handled by AppLifecycleManager

    // Initialize repository
    _repository.init();

    // Clean old drafts on startup
    _repository.clearOldDrafts();
  }

  /// Start auto-saving for a workout
  void startAutoSave(Workout workout) {
    if (!state.isAutoSaveEnabled) return;

    // Cancel existing timer
    _autoSaveTimer?.cancel();

    // Save immediately on start
    _saveWorkout(workout);

    // Setup periodic auto-save (every 10 minutes)
    // BUG FIX: Read CURRENT workout from provider, not the captured reference!
    // The captured `workout` parameter is stale after state changes.
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) {
      // Read fresh workout state from provider
      final currentWorkout = ref.read(currentWorkoutProvider);
      if (currentWorkout == null) {
        // No active workout, cancel timer
        _autoSaveTimer?.cancel();
        return;
      }

      if (_hasWorkoutChanged(currentWorkout)) {
        _saveWorkout(currentWorkout);
      }
    });
  }

  /// Save workout on specific events (set completion, exercise added, etc.)
  void triggerSave(Workout workout) {
    if (!state.isAutoSaveEnabled) return;

    // 🔐 SECURITY: Use Debouncer for throttling rapid saves (1s delay)
    _saveDebouncer.run(() {
      if (_hasWorkoutChanged(workout)) {
        _saveWorkout(workout);
      }
    });
  }

  /// Emergency save (app going to background, etc.)
  ///
  /// FIX #3: This method now uses synchronous Hive write to ensure
  /// the save completes before iOS terminates the app.
  /// iOS gives apps ~5 seconds to complete background tasks.
  Future<void> emergencySave(Workout workout) async {
    // Cancel timers to prevent concurrent saves
    _autoSaveTimer?.cancel();
    _saveDebouncer.cancel();

    // FIX #3: Use synchronous save path for emergency situations
    // This bypasses the async _saveWorkout to ensure completion
    try {
      state = state.copyWith(isSaving: true, lastError: null);

      // Direct synchronous save to repository
      await _repository.saveCurrentDraft(workout);
      _lastSavedWorkout = workout;

      state = state.copyWith(isSaving: false, lastSaveTime: DateTime.now());

      AppLogger.info(
        'Emergency save completed at ${DateTime.now()}',
        tag: 'WorkoutAutoSave',
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, lastError: e.toString());

      AppLogger.error(
        'Emergency save failed: $e',
        tag: 'WorkoutAutoSave',
        error: e,
      );

      // Rethrow so caller knows it failed
      rethrow;
    }
  }

  /// Stop auto-saving (workout completed or cancelled)
  void stopAutoSave({bool clearDraft = true}) {
    _autoSaveTimer?.cancel();
    _saveDebouncer.cancel();

    if (clearDraft) {
      _repository.clearCurrentDraft();
    }

    _lastSavedWorkout = null;
  }

  /// Check if workout has changed since last save
  bool _hasWorkoutChanged(Workout workout) {
    if (_lastSavedWorkout == null) return true;

    // Compare JSON representations for deep equality
    return workout.toJson() != _lastSavedWorkout!.toJson();
  }

  /// Save workout to local storage
  Future<void> _saveWorkout(Workout workout, {bool force = false}) async {
    if (state.isSaving) return;

    if (!force && !_hasWorkoutChanged(workout)) return;

    state = state.copyWith(isSaving: true, lastError: null);

    try {
      await _repository.saveCurrentDraft(workout);
      _lastSavedWorkout = workout;

      state = state.copyWith(isSaving: false, lastSaveTime: DateTime.now());

      AppLogger.info(
        'Auto-save completed at ${DateTime.now()}',
        tag: 'WorkoutAutoSave',
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, lastError: e.toString());

      AppLogger.error('Auto-save failed: $e', tag: 'WorkoutAutoSave', error: e);
    }
  }

  /// Check for recoverable draft on app startup
  Future<bool> hasRecoverableDraft() async {
    return await _repository.hasRecoverableDraft();
  }

  /// Recover draft workout
  Future<Workout?> recoverDraft() async {
    final workout = await _repository.recoverDraft();
    if (workout != null) {
      // Start auto-save for recovered workout
      startAutoSave(workout);
    }
    return workout;
  }

  /// Discard draft without recovering
  Future<void> discardDraft() async {
    await _repository.clearCurrentDraft();
  }

  /// Toggle auto-save on/off
  void toggleAutoSave() {
    state = state.copyWith(isAutoSaveEnabled: !state.isAutoSaveEnabled);

    if (!state.isAutoSaveEnabled) {
      _autoSaveTimer?.cancel();
      _saveDebouncer.cancel();
    }
  }

  // NOTE: didChangeAppLifecycleState REMOVED
  // Emergency save is now handled ONLY by AppLifecycleManager (single source of truth)
  // This eliminates redundant lifecycle observers and prevents race conditions
}
