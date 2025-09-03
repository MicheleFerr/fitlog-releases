import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

/// Provider for managing workout edit mode state
final workoutEditModeProvider = StateNotifierProvider<WorkoutEditModeNotifier, WorkoutEditModeState>((ref) {
  return WorkoutEditModeNotifier();
});

class WorkoutEditModeState {
  final bool isEditMode;
  final bool showSwipeHint;
  final DateTime? lastInteraction;

  WorkoutEditModeState({
    this.isEditMode = false,
    this.showSwipeHint = true,
    this.lastInteraction,
  });

  WorkoutEditModeState copyWith({
    bool? isEditMode,
    bool? showSwipeHint,
    DateTime? lastInteraction,
  }) {
    return WorkoutEditModeState(
      isEditMode: isEditMode ?? this.isEditMode,
      showSwipeHint: showSwipeHint ?? this.showSwipeHint,
      lastInteraction: lastInteraction ?? this.lastInteraction,
    );
  }
}

class WorkoutEditModeNotifier extends StateNotifier<WorkoutEditModeState> {
  Timer? _hintTimer;
  Timer? _autoExitTimer;

  WorkoutEditModeNotifier() : super(WorkoutEditModeState()) {
    _startHintTimer();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _autoExitTimer?.cancel();
    super.dispose();
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    // Show hint after 2 seconds, hide after 6 seconds total
    _hintTimer = Timer(const Duration(seconds: 2), () {
      if (!state.isEditMode) {
        state = state.copyWith(showSwipeHint: true);
        
        // Hide hint after 4 more seconds
        Timer(const Duration(seconds: 4), () {
          if (!state.isEditMode) {
            state = state.copyWith(showSwipeHint: false);
          }
        });
      }
    });
  }

  void enterEditMode() {
    _hintTimer?.cancel();
    _autoExitTimer?.cancel();
    
    state = state.copyWith(
      isEditMode: true,
      showSwipeHint: false,
      lastInteraction: DateTime.now(),
    );

    // Auto-exit after 30 seconds of inactivity
    _startAutoExitTimer();
  }

  void exitEditMode() {
    _autoExitTimer?.cancel();
    
    state = state.copyWith(
      isEditMode: false,
      showSwipeHint: false,
    );

    // Restart hint timer
    _startHintTimer();
  }

  void toggleEditMode() {
    if (state.isEditMode) {
      exitEditMode();
    } else {
      enterEditMode();
    }
  }

  void updateInteraction() {
    if (state.isEditMode) {
      state = state.copyWith(lastInteraction: DateTime.now());
      _startAutoExitTimer(); // Reset auto-exit timer
    }
  }

  void _startAutoExitTimer() {
    _autoExitTimer?.cancel();
    _autoExitTimer = Timer(const Duration(seconds: 30), () {
      if (state.isEditMode) {
        exitEditMode();
      }
    });
  }

  void resetHintTimer() {
    if (!state.isEditMode) {
      _startHintTimer();
    }
  }
}