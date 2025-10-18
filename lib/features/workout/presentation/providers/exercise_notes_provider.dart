/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 📱 Platform: Universal
///
/// Exercise notes state provider
/// Manages notes editing with auto-save debounce
library;

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// State for exercise notes
class ExerciseNotesState {

  const ExerciseNotesState({
    this.notes = '',
    this.isEditing = false,
    this.isSaving = false,
    this.lastSaved,
  });
  final String notes;
  final bool isEditing;
  final bool isSaving;
  final DateTime? lastSaved;

  ExerciseNotesState copyWith({
    String? notes,
    bool? isEditing,
    bool? isSaving,
    DateTime? lastSaved,
  }) {
    return ExerciseNotesState(
      notes: notes ?? this.notes,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      lastSaved: lastSaved ?? this.lastSaved,
    );
  }
}

/// Notifier for managing exercise notes
class ExerciseNotesNotifier extends StateNotifier<ExerciseNotesState> {

  ExerciseNotesNotifier({
    required String initialNotes,
    this.onSave,
  }) : super(ExerciseNotesState(notes: initialNotes));
  Timer? _saveDebounceTimer;
  final Function(Exercise)? onSave;

  /// Start editing notes
  void startEditing() {
    state = state.copyWith(isEditing: true);
  }

  /// Stop editing notes
  void stopEditing() {
    state = state.copyWith(isEditing: false);
    // Trigger final save if there are unsaved changes
    if (_saveDebounceTimer?.isActive ?? false) {
      _saveDebounceTimer?.cancel();
      _triggerSave();
    }
  }

  /// Update notes text (triggers debounced save)
  void updateNotes(String newNotes) {
    state = state.copyWith(notes: newNotes);

    // Cancel previous timer
    _saveDebounceTimer?.cancel();

    // Start new debounce timer (750ms)
    _saveDebounceTimer = Timer(const Duration(milliseconds: 750), () {
      _triggerSave();
    });
  }

  /// Trigger the actual save operation
  Future<void> _triggerSave() async {
    if (state.isSaving) return;

    state = state.copyWith(isSaving: true);

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Simulate save operation (callback will be provided by widget)
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      state = state.copyWith(
        isSaving: false,
        lastSaved: DateTime.now(),
      );
    }
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for exercise notes state
/// Family provider indexed by exercise ID
final exerciseNotesProvider = StateNotifierProvider.family<
  ExerciseNotesNotifier,
  ExerciseNotesState,
  String
>((ref, exerciseId) {
  return ExerciseNotesNotifier(initialNotes: '');
});
