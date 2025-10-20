import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_draft_repository.dart';
import 'package:flutter/widgets.dart';

/// Provider for the draft repository
final workoutDraftRepositoryProvider = Provider<WorkoutDraftRepository>((ref) {
  return WorkoutDraftRepository();
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
  Timer? _debounceTimer;
  Workout? _lastSavedWorkout;
  
  // CPU OPTIMIZATION: Increased intervals to reduce background activity
  static const Duration _autoSaveInterval = Duration(minutes: 10);  // Reduced from 5 to 10 minutes
  static const Duration _debounceDelay = Duration(seconds: 1);      // Optimized for responsive UX

  void _init() {
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
    
    // Debounce rapid saves
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      if (_hasWorkoutChanged(workout)) {
        _saveWorkout(workout);
      }
    });
  }

  /// Emergency save (app going to background, etc.)
  Future<void> emergencySave(Workout workout) async {
    // Cancel timers to prevent concurrent saves
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel();
    
    // Force save regardless of changes
    await _saveWorkout(workout, force: true);
  }

  /// Stop auto-saving (workout completed or cancelled)
  void stopAutoSave({bool clearDraft = true}) {
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel();
    
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
      
      debugPrint('✅ Auto-save completed at ${DateTime.now()}');
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        lastError: e.toString(),
      );
      
      debugPrint('❌ Auto-save failed: $e');
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
      _debounceTimer?.cancel();
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
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
      _debounceTimer = null;
    }
    
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    
    // Clear references to prevent memory leaks
    _lastSavedWorkout = null;
    
    super.dispose();
  }
}