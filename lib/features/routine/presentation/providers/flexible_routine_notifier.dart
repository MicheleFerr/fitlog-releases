/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation
/// 🎯 Feature: flexible_routine
/// 🔧 Type: notifier
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FLEXIBLE ROUTINE NOTIFIER - CRUD operations for flexible routine
///
/// Provides methods for:
/// - Creating/updating/deleting routines
/// - Activating/deactivating routines
/// - Archiving/unarchiving routines
/// - Completing/skipping/recovering days
/// - Managing routine patterns
///
/// Error handling:
/// - Try-catch all operations
/// - Return success/failure with error messages
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_pattern.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/flexible_routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_repository_provider.dart';

/// State for flexible routine operations
class FlexibleRoutineState {

  const FlexibleRoutineState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });
  final bool isLoading;
  final String? error;
  final String? successMessage;

  FlexibleRoutineState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return FlexibleRoutineState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Notifier for flexible routine CRUD operations
class FlexibleRoutineNotifier extends StateNotifier<FlexibleRoutineState> {

  FlexibleRoutineNotifier(this._repository, this._userId)
      : super(const FlexibleRoutineState());
  final FlexibleRoutineRepository _repository;
  final String? _userId;

  /// Get current user ID
  String get userId {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    return _userId;
  }

  // === CRUD OPERATIONS ===

  /// Create a new routine
  Future<bool> createRoutine({
    required String name,
    required RoutineType type,
    required DateTime startDate,
    required DateTime endDate,
    required RoutinePattern pattern,
    List<String> templateIds = const [],
    String? description,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Create routine with pattern
      final routine = FlexibleRoutine.create(
        userId: userId,
        name: name,
        type: type,
        startDate: startDate,
        endDate: endDate,
        pattern: pattern,
      );

      // Generate schedule from pattern with template assignments
      final routineWithSchedule = _generateScheduleWithTemplates(
        routine,
        pattern,
        templateIds,
      );

      await _repository.createRoutine(routineWithSchedule);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Routine created successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create routine: ${e.toString()}',
      );
      return false;
    }
  }

  /// Update an existing routine
  Future<bool> updateRoutine(FlexibleRoutine routine) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.updateRoutine(routine);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Routine updated successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update routine: ${e.toString()}',
      );
      return false;
    }
  }

  /// Delete a routine
  Future<bool> deleteRoutine(String routineId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.deleteRoutine(routineId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Routine deleted successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete routine: ${e.toString()}',
      );
      return false;
    }
  }

  // === ACTIVE ROUTINE MANAGEMENT ===

  /// Set a routine as active (deactivates all others)
  Future<bool> activateRoutine(String routineId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.activateRoutine(routineId, userId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Routine activated successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to activate routine: ${e.toString()}',
      );
      return false;
    }
  }

  /// Deactivate the current active routine
  Future<bool> deactivateCurrentRoutine() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.deactivateCurrentRoutine(userId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Routine deactivated',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to deactivate routine: ${e.toString()}',
      );
      return false;
    }
  }

  // === ROUTINE STATE OPERATIONS ===

  /// Archive a routine
  Future<bool> archiveRoutine(String routineId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.archiveRoutine(routineId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Routine archived',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to archive routine: ${e.toString()}',
      );
      return false;
    }
  }

  /// Unarchive a routine
  Future<bool> unarchiveRoutine(String routineId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.unarchiveRoutine(routineId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Routine unarchived',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to unarchive routine: ${e.toString()}',
      );
      return false;
    }
  }

  /// Mark routine as completed
  Future<bool> completeRoutine(String routineId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.completeRoutine(routineId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Routine completed! 🎉',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to complete routine: ${e.toString()}',
      );
      return false;
    }
  }

  // === DAY OPERATIONS ===

  /// Complete a day's workout
  Future<bool> completeDayWorkout({
    required String routineId,
    required DateTime date,
    required String workoutId,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.completeDayWorkout(
        routineId: routineId,
        date: date,
        workoutId: workoutId,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Day completed! 💪',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to complete day: ${e.toString()}',
      );
      return false;
    }
  }

  /// Complete a day manually (without workout)
  Future<bool> completeDayManual({
    required String routineId,
    required DateTime date,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get routine first
      final routine = await _repository.getRoutineById(routineId);
      if (routine == null) {
        throw Exception('Routine not found');
      }

      // Update day status to completed
      final dateKey = _dateToString(date);
      final currentDay = routine.schedule[dateKey];

      if (currentDay == null) {
        throw Exception('Day not found in schedule');
      }

      final updatedDay = currentDay.copyWith(status: DayStatus.completed);
      final updatedSchedule = Map<String, ScheduledDay>.from(routine.schedule);
      updatedSchedule[dateKey] = updatedDay;

      final updatedRoutine = routine.copyWith(schedule: updatedSchedule);
      await _repository.updateRoutine(updatedRoutine);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Day marked as completed',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to complete day: ${e.toString()}',
      );
      return false;
    }
  }

  /// Skip a day
  Future<bool> skipDay({
    required String routineId,
    required DateTime date,
    String? reason,
    String? notes,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.skipDay(
        routineId: routineId,
        date: date,
        reason: reason,
        notes: notes,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Day skipped',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to skip day: ${e.toString()}',
      );
      return false;
    }
  }

  /// Recover a skipped day
  Future<bool> recoverDay({
    required String routineId,
    required DateTime originalDate,
    required DateTime recoveryDate,
    String? notes,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.recoverDay(
        routineId: routineId,
        originalDate: originalDate,
        recoveryDate: recoveryDate,
        notes: notes,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Day recovered! 🔥',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to recover day: ${e.toString()}',
      );
      return false;
    }
  }

  // === QUERY OPERATIONS ===

  /// Get routine by ID
  Future<FlexibleRoutine?> getRoutineById(String routineId) async {
    try {
      return await _repository.getRoutineById(routineId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load routine: ${e.toString()}');
      return null;
    }
  }

  /// Get statistics for a routine
  Future<RoutineStatistics?> getRoutineStatistics(String routineId) async {
    try {
      return await _repository.getRoutineStatistics(routineId);
    } catch (e) {
      state =
          state.copyWith(error: 'Failed to load statistics: ${e.toString()}');
      return null;
    }
  }

  /// Check if user has active routines
  Future<bool> hasActiveRoutines() async {
    try {
      return await _repository.hasActiveRoutines(userId);
    } catch (e) {
      return false;
    }
  }

  /// Clear success/error messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }

  // === HELPER METHODS ===

  /// Generate schedule with automatic template rotation
  FlexibleRoutine _generateScheduleWithTemplates(
    FlexibleRoutine routine,
    RoutinePattern pattern,
    List<String> templateIds,
  ) {
    // If no templates provided, use default schedule generation
    if (templateIds.isEmpty) {
      return routine.generateSchedule();
    }

    // Generate base schedule
    final scheduleWithTemplates = routine.generateSchedule();

    // Calculate total days
    final totalDays = routine.endDate.difference(routine.startDate).inDays + 1;

    // Rotate templates across workout days
    int templateIndex = 0;
    final updatedDays = <String, ScheduledDay>{};

    for (int i = 0; i < totalDays; i++) {
      final date = routine.startDate.add(Duration(days: i));
      final dateKey = _dateToString(date);
      final dayName = pattern.sequence[i % pattern.sequence.length];
      final isRest = dayName.toLowerCase() == 'rest';

      if (!isRest) {
        // Assign template in rotation
        final templateId = templateIds[templateIndex % templateIds.length];
        updatedDays[dateKey] = ScheduledDay(
          date: date,
          templateId: templateId,
          status: DayStatus.scheduled,
        );
        templateIndex++;
      } else {
        // Rest day
        updatedDays[dateKey] = ScheduledDay(
          date: date,
          templateId: null,
          status: DayStatus.rest,
        );
      }
    }

    // Return routine with updated schedule
    return scheduleWithTemplates.copyWith(schedule: updatedDays);
  }

  /// Convert DateTime to string key for schedule map
  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Provider for FlexibleRoutineNotifier
final flexibleRoutineNotifierProvider =
    StateNotifierProvider<FlexibleRoutineNotifier, FlexibleRoutineState>((ref) {
  final repository = ref.watch(flexibleRoutineRepositoryProvider);
  final userId = FirebaseAuth.instance.currentUser?.uid;

  return FlexibleRoutineNotifier(repository, userId);
});
