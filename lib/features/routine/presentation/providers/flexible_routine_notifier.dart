/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/providers
/// 🎯 Feature: flexible_routine
/// 🔧 Type: state notifier
/// 🌍 Localization: N/A
/// 📱 Platform: Universal
///
/// FLEXIBLE ROUTINE NOTIFIER - State Management for Routine CRUD (v2.0)
///
/// Manages:
/// - Creating new routines (auto-deactivates old active routine)
/// - Updating existing routines
/// - Deleting routines
/// - Activating/deactivating routines
/// - Loading/error/success states
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/analytics/analytics_constants.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_providers.dart';

/// State for routine operations
class RoutineState {
  const RoutineState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  RoutineState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return RoutineState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  /// Reset to initial state
  RoutineState reset() {
    return const RoutineState();
  }
}

// ──────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ──────────────────────────────────────────────────────────────────────────

/// Routine operations notifier (CRUD + state management)
class FlexibleRoutineNotifier extends StateNotifier<RoutineState> {
  FlexibleRoutineNotifier({
    required RoutineRepository repository,
    required this.userId,
    required IAnalyticsService analytics,
  })  : _repository = repository,
        _analytics = analytics,
        super(const RoutineState());

  final RoutineRepository _repository;
  final IAnalyticsService _analytics;
  final String userId;

  // ────────────────────────────────────────────────────────────────────────
  // CREATE
  // ────────────────────────────────────────────────────────────────────────

  /// Create new routine (auto-deactivates existing active routines)
  ///
  /// Parameters:
  /// - routine: FlexibleRoutine entity to create
  ///
  /// Side effects:
  /// - Deactivates all existing active routines for this user
  /// - Sets new routine as active
  /// - Updates state: loading → success/error
  /// - Tracks analytics event
  Future<void> createRoutine(FlexibleRoutine routine) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.createRoutine(routine);

      // Track analytics
      await _analytics.logEvent(
        name: AnalyticsEvents.routineCreated,
        parameters: {
          AnalyticsParameters.routineId: routine.id,
          AnalyticsParameters.routineName: routine.name,
          AnalyticsParameters.presetType: routine.presetType.name,
          'training_days_count': routine.trainingDays.length,
          'workout_schedule_count': routine.workoutSchedule.length,
          'source': 'routine_center_v2',
        },
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Routine created successfully',
      );

      _log('Created routine: ${routine.id}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      _log('Failed to create routine: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // UPDATE
  // ────────────────────────────────────────────────────────────────────────

  /// Update existing routine
  ///
  /// Parameters:
  /// - routine: Updated FlexibleRoutine entity
  ///
  /// Side effects:
  /// - Updates Firestore document
  /// - Sets updatedAt to DateTime.now()
  /// - Updates state: loading → success/error
  /// - Tracks analytics event
  Future<void> updateRoutine(FlexibleRoutine routine) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.updateRoutine(routine);

      // Track analytics
      await _analytics.logEvent(
        name: AnalyticsEvents.templateEdited,
        parameters: {
          AnalyticsParameters.routineId: routine.id,
          AnalyticsParameters.routineName: routine.name,
          AnalyticsParameters.presetType: routine.presetType.name,
          'training_days_count': routine.trainingDays.length,
          'workout_schedule_count': routine.workoutSchedule.length,
          'source': 'routine_center_v2',
        },
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Routine updated successfully',
      );

      _log('Updated routine: ${routine.id}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      _log('Failed to update routine: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // DELETE
  // ────────────────────────────────────────────────────────────────────────

  /// Delete routine
  ///
  /// Parameters:
  /// - routineId: ID of routine to delete
  ///
  /// Side effects:
  /// - Deletes Firestore document
  /// - If deleted routine was active, auto-activates most recent inactive routine
  /// - Updates state: loading → success/error
  /// - Tracks analytics event
  Future<void> deleteRoutine(String routineId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deleteRoutine(routineId);

      // Track analytics
      await _analytics.logEvent(
        name: AnalyticsEvents.templateDeleted,
        parameters: {
          AnalyticsParameters.routineId: routineId,
          'source': 'routine_center_v2',
        },
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Routine deleted successfully',
      );

      _log('Deleted routine: $routineId');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      _log('Failed to delete routine: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // ACTIVATE / DEACTIVATE
  // ────────────────────────────────────────────────────────────────────────

  /// Activate a routine (deactivates all others)
  ///
  /// Parameters:
  /// - routineId: ID of routine to activate
  ///
  /// Side effects:
  /// - Deactivates all other routines for this user
  /// - Sets target routine as active
  /// - Updates state: loading → success/error
  /// - Tracks analytics event
  Future<void> activateRoutine(String routineId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.activateRoutine(routineId);

      // Track analytics
      await _analytics.logEvent(
        name: AnalyticsEvents.routineStarted,
        parameters: {
          AnalyticsParameters.routineId: routineId,
          'source': 'routine_center_v2',
          AnalyticsParameters.action: 'activated',
        },
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Routine activated successfully',
      );

      _log('Activated routine: $routineId');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      _log('Failed to activate routine: $e');
    }
  }

  /// Deactivate all routines for this user
  ///
  /// Side effects:
  /// - Sets isActive = false for all user's routines
  /// - Updates state: loading → success/error
  Future<void> deactivateAllRoutines() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deactivateAllRoutines(userId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'All routines deactivated',
      );

      _log('Deactivated all routines for user: $userId');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      _log('Failed to deactivate routines: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // STATE MANAGEMENT
  // ────────────────────────────────────────────────────────────────────────

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  /// Reset state to initial
  void reset() {
    state = state.reset();
  }

  // ────────────────────────────────────────────────────────────────────────
  // LOGGING
  // ────────────────────────────────────────────────────────────────────────

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[FlexibleRoutineNotifier] $message');
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────
// PROVIDER
// ──────────────────────────────────────────────────────────────────────────

/// Routine notifier provider (singleton per user)
///
/// Usage:
/// ```dart
/// final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
/// await notifier.createRoutine(routine);
///
/// // Watch state for loading/error
/// final state = ref.watch(flexibleRoutineNotifierProvider);
/// if (state.isLoading) { /* show loading */ }
/// if (state.errorMessage != null) { /* show error */ }
/// ```
final flexibleRoutineNotifierProvider =
    StateNotifierProvider<FlexibleRoutineNotifier, RoutineState>((ref) {
  final repository = ref.watch(routineRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  final analytics = ref.watch(analyticsServiceProvider);

  // Require user ID (throw if not logged in)
  if (userId == null) {
    throw Exception('User must be logged in to use RoutineNotifier');
  }

  return FlexibleRoutineNotifier(
    repository: repository,
    userId: userId,
    analytics: analytics,
  );
});
