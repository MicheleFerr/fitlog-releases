import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_draft_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/services/request_throttler.dart';
import 'package:gymbro_flutter_new/core/utils/app_logger.dart';

/// Provider for the draft repository
final workoutDraftRepositoryProvider = Provider<WorkoutDraftRepository>((ref) {
  return WorkoutDraftRepository(ref.watch(hiveBoxManagerProvider));
});

/// Provider for workout auto-save functionality
final workoutAutoSaveProvider = StateNotifierProvider<WorkoutAutoSaveNotifier, WorkoutAutoSaveState>((ref) {
  final repository = ref.watch(workoutDraftRepositoryProvider);
  return WorkoutAutoSaveNotifier(repository);
});

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
class WorkoutAutoSaveNotifier extends StateNotifier<WorkoutAutoSaveState> with WidgetsBindingObserver {      // Increased from 2 to 5 seconds

  WorkoutAutoSaveNotifier(this._repository) : super(WorkoutAutoSaveState()) {
    _init();
  }
  final WorkoutDraftRepository _repository;
  Timer? _autoSaveTimer;
  late final Debouncer _saveDebouncer;
  Workout? _lastSavedWorkout;

  // CPU OPTIMIZATION: Increased intervals to reduce background activity
  static const Duration _autoSaveInterval = Duration(minutes: 10);  // Reduced from 5 to 10 minutes
  static const Duration _debounceDelay = Duration(seconds: 1);      // Optimized for responsive UX

  void _init() {
    // 🔐 SECURITY: Initialize save debouncer with error handling
    _saveDebouncer = Debouncer(
      duration: _debounceDelay,
      onError: (error, stackTrace) {
        AppLogger.error('Debouncer error: $error', tag: 'WorkoutAutoSave', error: error, stackTrace: stackTrace);
        state = state.copyWith(
          isSaving: false,
          lastError: error.toString(),
        );
      },
    );

    // Add lifecycle observer to save on app pause
    WidgetsBinding.instance.addObserver(this);

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
    
    // Setup periodic auto-save (every 5 minutes)
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) {
      if (_hasWorkoutChanged(workout)) {
        _saveWorkout(workout);
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
  Future<void> emergencySave(Workout workout) async {
    // Cancel timers to prevent concurrent saves
    _autoSaveTimer?.cancel();
    _saveDebouncer.cancel();

    // Force save regardless of changes
    await _saveWorkout(workout, force: true);
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
      
      state = state.copyWith(
        isSaving: false,
        lastSaveTime: DateTime.now(),
      );

      AppLogger.info('Auto-save completed at ${DateTime.now()}', tag: 'WorkoutAutoSave');
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        lastError: e.toString(),
      );

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    // Save when app goes to background
    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.inactive) {
      if (_lastSavedWorkout != null) {
        emergencySave(_lastSavedWorkout!);
      }
    }
  }

  @override
  void dispose() {
    // CRITICAL CPU FIX: Force cancel all timers immediately
    if (_autoSaveTimer != null) {
      _autoSaveTimer!.cancel();
      _autoSaveTimer = null;
    }

    // 🔐 SECURITY: Dispose debouncer properly
    _saveDebouncer.dispose();

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Clear references to prevent memory leaks
    _lastSavedWorkout = null;

    super.dispose();
  }
}