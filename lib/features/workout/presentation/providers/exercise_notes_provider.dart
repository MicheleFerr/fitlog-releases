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
import 'package:gymbro_flutter_new/shared/domain/services/request_throttler.dart';
import 'package:gymbro_flutter_new/core/utils/app_logger.dart';

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

/// Notifier for managing exercise notes (Riverpod 2.0)
class ExerciseNotesNotifier extends FamilyNotifier<ExerciseNotesState, String> {
  late final Debouncer _saveDebouncer;
  Function(Exercise)? onSave;

  @override
  ExerciseNotesState build(String exerciseId) {
    // Initialize with empty notes
    _initDebouncer();

    // Cleanup on dispose
    ref.onDispose(() {
      _saveDebouncer.dispose();
    });

    return const ExerciseNotesState(notes: '');
  }

  void _initDebouncer() {
    // 🔐 SECURITY: Initialize save debouncer (750ms delay for note editing)
    _saveDebouncer = Debouncer(
      duration: const Duration(milliseconds: 750),
      onError: (error, stackTrace) {
        AppLogger.error('Debouncer error: $error', tag: 'ExerciseNotes', error: error, stackTrace: stackTrace);
        state = state.copyWith(isSaving: false);
      },
    );
  }

  /// Start editing notes
  void startEditing() {
    state = state.copyWith(isEditing: true);
  }

  /// Stop editing notes
  void stopEditing() {
    state = state.copyWith(isEditing: false);
    // Trigger final save if there are unsaved changes
    if (_saveDebouncer.isActive) {
      _saveDebouncer.cancel();
      _triggerSave();
    }
  }

  /// Update notes text (triggers debounced save)
  void updateNotes(String newNotes) {
    state = state.copyWith(notes: newNotes);

    // 🔐 SECURITY: Use Debouncer for throttling note saves (750ms delay)
    _saveDebouncer.run(() {
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

    state = state.copyWith(
      isSaving: false,
      lastSaved: DateTime.now(),
    );
  }
}

/// Provider for exercise notes state (Riverpod 2.0)
/// Family provider indexed by exercise ID
final exerciseNotesProvider = NotifierProvider.family<
  ExerciseNotesNotifier,
  ExerciseNotesState,
  String
>(ExerciseNotesNotifier.new);
