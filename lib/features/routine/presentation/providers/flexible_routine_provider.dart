/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation
/// 🎯 Feature: flexible_routine
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FLEXIBLE ROUTINE PROVIDER - State management for flexible routine
///
/// Provides:
/// - Stream of active routine (real-time updates)
/// - Stream of all user routines (real-time updates)
/// - Active/archived routines filtering
/// - Routine statistics
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/flexible_routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_repository_provider.dart';
import 'package:flutter/foundation.dart';

/// Helper class for checking day completion status
class DayCheckParams {

  const DayCheckParams({
    required this.date,
    this.scheduledTemplateId,
  });
  final DateTime date;
  final String? scheduledTemplateId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayCheckParams &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          scheduledTemplateId == other.scheduledTemplateId;

  @override
  int get hashCode => date.hashCode ^ scheduledTemplateId.hashCode;
}

/// Result of auto-complete check
class DayAutoCompleteStatus {

  const DayAutoCompleteStatus({
    required this.shouldAutoComplete,
    required this.reason,
    this.hasAlternativeWorkout = false,
    this.workoutId,
    this.completedTemplateId,
  });
  final bool shouldAutoComplete;
  final String reason;
  final bool hasAlternativeWorkout;
  final String? workoutId;
  final String? completedTemplateId;
}

/// Provider for current user ID from Firebase Auth
final _currentUserIdProvider = Provider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
});

/// Stream provider for active routine (real-time updates)
final activeFlexibleRoutineProvider = StreamProvider<FlexibleRoutine?>((ref) {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) {
    return Stream.error(
      Exception('User not authenticated. Please sign in to view routines.'),
    );
  }

  final repository = ref.watch(flexibleRoutineRepositoryProvider);
  return repository.watchActiveRoutine(userId);
});

/// Stream provider for all user routines (real-time updates)
final userFlexibleRoutinesProvider =
    StreamProvider<List<FlexibleRoutine>>((ref) {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(flexibleRoutineRepositoryProvider);
  return repository.watchUserRoutines(userId);
});

/// Provider for active routines only (filters out archived)
final activeFlexibleRoutinesProvider =
    Provider<List<FlexibleRoutine>>((ref) {
  final routinesAsync = ref.watch(userFlexibleRoutinesProvider);

  return routinesAsync.when(
    data: (routines) => routines
        .where((r) => !r.isArchived && !r.isCompleted)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for archived routines only
final archivedFlexibleRoutinesProvider =
    Provider<List<FlexibleRoutine>>((ref) {
  final routinesAsync = ref.watch(userFlexibleRoutinesProvider);

  return routinesAsync.when(
    data: (routines) => routines
        .where((r) => r.isArchived)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider to check if user has any active routines
final hasActiveFlexibleRoutinesProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) {
    return false;
  }

  final repository = ref.watch(flexibleRoutineRepositoryProvider);
  return repository.hasActiveRoutines(userId);
});

/// Family provider for routine statistics by ID
final routineStatisticsProvider =
    FutureProvider.family<RoutineStatistics?, String>((ref, routineId) async {
  final repository = ref.watch(flexibleRoutineRepositoryProvider);
  try {
    return await repository.getRoutineStatistics(routineId);
  } catch (e) {
    return null;
  }
});

/// Family provider for routine by ID (real-time stream)
final routineByIdProvider =
    StreamProvider.family<FlexibleRoutine?, String>((ref, routineId) {
  final repository = ref.watch(flexibleRoutineRepositoryProvider);
  return repository.watchRoutineById(routineId);
});

/// Provider to get completed workouts for a specific date
final completedWorkoutsByDateProvider =
    FutureProvider.family<List<Map<String, dynamic>>, DateTime>((ref, date) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) {
    return [];
  }

  // Normalize date to start and end of day
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

  try {
    // Query workouts completed on this specific date
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .where('status', isEqualTo: 'completed')
        .where('endTime', isGreaterThanOrEqualTo: startOfDay)
        .where('endTime', isLessThanOrEqualTo: endOfDay)
        .orderBy('endTime', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Error fetching workouts for date $date: $e');
    }
    return [];
  }
});

/// Provider to check if a day should be auto-completed based on workout instances
final dayAutoCompleteStatusProvider =
    FutureProvider.family<DayAutoCompleteStatus, DayCheckParams>((ref, params) async {
  final completedWorkouts = await ref.watch(completedWorkoutsByDateProvider(params.date).future);

  if (completedWorkouts.isEmpty) {
    return const DayAutoCompleteStatus(
      shouldAutoComplete: false,
      reason: 'No workouts completed on this date',
    );
  }

  // Check if any completed workout matches the scheduled template (case-insensitive)
  for (final workout in completedWorkouts) {
    final workoutTemplateId = workout['templateId'] as String?;

    if (workoutTemplateId != null &&
        workoutTemplateId.toLowerCase() == params.scheduledTemplateId?.toLowerCase()) {
      return DayAutoCompleteStatus(
        shouldAutoComplete: true,
        reason: 'Completed workout matches scheduled template',
        workoutId: workout['id'] as String?,
        completedTemplateId: workoutTemplateId,
      );
    }
  }

  // If workouts exist but don't match, offer substitution
  final firstWorkout = completedWorkouts.first;
  return DayAutoCompleteStatus(
    shouldAutoComplete: false,
    reason: 'Completed workout does not match scheduled template',
    hasAlternativeWorkout: true,
    workoutId: firstWorkout['id'] as String?,
    completedTemplateId: firstWorkout['templateId'] as String?,
  );
});
