/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation
/// 🎯 Feature: routine_pause
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ROUTINE PAUSE PROVIDER - State management for routine pauses
///
/// This provider manages:
/// - Active pauses for a routine
/// - Create/resume/delete pause operations
/// - Real-time updates via Stream
///
/// Example:
/// ```dart
/// final pausesAsync = ref.watch(routinePauseProvider(routineId));
/// final activePause = pausesAsync.value?.firstOrNull;
/// ```
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/data/repositories/firebase_routine_pause_repository.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_pause.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/routine_pause_repository.dart';
import 'package:gymbro_flutter_new/features/routine/domain/services/routine_pause_service.dart';

// === REPOSITORY PROVIDER ===

/// Provides RoutinePauseRepository instance
final routinePauseRepositoryProvider = Provider<RoutinePauseRepository>((ref) {
  return FirebaseRoutinePauseRepository();
});

// === SERVICE PROVIDER ===

/// Provides RoutinePauseService instance
final routinePauseServiceProvider = Provider<RoutinePauseService>((ref) {
  final repository = ref.watch(routinePauseRepositoryProvider);
  return RoutinePauseService(pauseRepository: repository);
});

// === STATE PROVIDERS ===

/// Provides active pauses for a routine (Stream-based)
///
/// Returns AsyncValue<List<RoutinePause>> with real-time updates
final routinePauseProvider =
    StreamProvider.family<List<RoutinePause>, String>((ref, routineId) {
  final repository = ref.watch(routinePauseRepositoryProvider);
  return repository.watchActivePauses(routineId).map(
        (pauses) => pauses.where((p) => p.routineId == routineId).toList(),
      );
});

/// Provides single active pause for a routine (null if not paused)
final activeRoutinePauseProvider =
    StreamProvider.family<RoutinePause?, String>((ref, routineId) {
  final repository = ref.watch(routinePauseRepositoryProvider);
  return repository.watchRoutinePause(routineId);
});

// === NOTIFIER FOR MUTATIONS ===

/// Notifier for pause operations (create, resume, delete)
final routinePauseNotifierProvider =
    NotifierProvider.family<RoutinePauseNotifier, void, String>(
  RoutinePauseNotifier.new,
);

/// Notifier implementation
class RoutinePauseNotifier extends FamilyNotifier<void, String> {
  @override
  void build(String arg) {
    // No initial state needed
  }

  /// Get repository
  RoutinePauseRepository get _repository =>
      ref.read(routinePauseRepositoryProvider);

  /// Get service
  RoutinePauseService get _service => ref.read(routinePauseServiceProvider);

  /// Create a new pause
  Future<RoutinePause> createPause(RoutinePause pause) async {
    final createdPause = await _repository.createPause(pause);

    // Invalidate providers to trigger refresh
    ref.invalidate(routinePauseProvider(pause.routineId));
    ref.invalidate(activeRoutinePauseProvider(pause.routineId));

    return createdPause;
  }

  /// Resume a pause (user-initiated)
  Future<void> resumePause(RoutinePause pause) async {
    await _service.resumePause(pause);

    // Invalidate providers
    ref.invalidate(routinePauseProvider(pause.routineId));
    ref.invalidate(activeRoutinePauseProvider(pause.routineId));
  }

  /// Delete a pause
  Future<void> deletePause(String pauseId, String routineId) async {
    await _repository.deletePause(pauseId);

    // Invalidate providers
    ref.invalidate(routinePauseProvider(routineId));
    ref.invalidate(activeRoutinePauseProvider(routineId));
  }

  /// Check if routine is paused
  Future<bool> isRoutinePaused(String routineId) async {
    return _service.isRoutinePaused(routineId);
  }

  /// Check if specific date is paused
  Future<bool> isDatePaused(String routineId, DateTime date) async {
    return _service.isDatePaused(routineId, date);
  }
}
