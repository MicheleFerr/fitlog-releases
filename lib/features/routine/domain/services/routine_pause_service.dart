/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain
/// 🎯 Feature: routine_pause
/// 🔧 Type: service
/// 🌍 Localization: N/A (domain logic only)
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ROUTINE PAUSE SERVICE - Auto-resume and management
///
/// This service provides:
/// - Auto-resume logic for expired pauses
/// - Periodic checks for expired pauses
/// - Integration with notification service
/// - Background task registration (future: WorkManager)
///
/// Dependencies:
/// - RoutinePauseRepository
/// - NotificationService (optional)
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_pause.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/routine_pause_repository.dart';

/// Service for managing routine pauses and auto-resume
class RoutinePauseService {
  const RoutinePauseService({
    required RoutinePauseRepository pauseRepository,
  }) : _pauseRepository = pauseRepository;

  final RoutinePauseRepository _pauseRepository;

  // === APP LIFECYCLE HOOKS ===

  /// Call this when app initializes (from main.dart or App widget)
  ///
  /// Checks for expired pauses and auto-resumes them.
  Future<void> onAppInitialization(String userId) async {
    try {
      await _processExpiredPauses(userId);
    } catch (e) {
      debugPrint('❌ Error in onAppInitialization: $e');
    }
  }

  /// Call this when app comes to foreground
  ///
  /// Useful for checking pauses when user returns to app after hours.
  Future<void> onAppResumed(String userId) async {
    try {
      await _processExpiredPauses(userId);
    } catch (e) {
      debugPrint('❌ Error in onAppResumed: $e');
    }
  }

  // === AUTO-RESUME LOGIC ===

  /// Process all expired pauses for a user
  ///
  /// This method:
  /// 1. Gets all active pauses
  /// 2. Filters for expired ones (endDate < now)
  /// 3. Resumes them using batch operation
  /// 4. Returns count of resumed pauses
  Future<int> _processExpiredPauses(String userId) async {
    debugPrint('🔍 Checking for expired pauses for user: $userId');

    // Get all expired pauses
    final expiredPauses = await _pauseRepository.getExpiredPauses(userId);

    if (expiredPauses.isEmpty) {
      debugPrint('✅ No expired pauses found');
      return 0;
    }

    debugPrint('⏰ Found ${expiredPauses.length} expired pauses, resuming...');

    // Resume all expired pauses (batch operation)
    final resumedPauses = expiredPauses
        .map((pause) => pause.resume(userInitiated: false))
        .toList();

    await _pauseRepository.resumePauses(resumedPauses);

    debugPrint('✅ Auto-resumed ${resumedPauses.length} pauses');

    // TODO: Send notification to user (optional)
    // await _notificationService?.notifyPausesResumed(resumedPauses);

    return resumedPauses.length;
  }

  // === MANUAL RESUME ===

  /// Manually resume a specific pause (user-initiated)
  Future<void> resumePause(RoutinePause pause) async {
    final resumedPause = pause.resume(userInitiated: true);
    await _pauseRepository.updatePause(resumedPause);

    debugPrint('✅ User manually resumed pause: ${pause.id}');
  }

  // === QUERY HELPERS ===

  /// Check if a routine is currently paused (and not expired)
  Future<bool> isRoutinePaused(String routineId) async {
    return _pauseRepository.isRoutinePaused(routineId);
  }

  /// Get active pause for routine (null if not paused)
  Future<RoutinePause?> getActivePause(String routineId) async {
    return _pauseRepository.getActivePause(routineId);
  }

  /// Check if a specific date is paused for a routine
  Future<bool> isDatePaused(String routineId, DateTime date) async {
    final pause = await getActivePause(routineId);
    if (pause == null) return false;

    return pause.isPaused(date);
  }

  // === STATS & ANALYTICS ===

  /// Get pause history for a routine
  Future<List<RoutinePause>> getPauseHistory(String routineId) async {
    return _pauseRepository.getAllPausesForRoutine(routineId);
  }

  /// Get total days paused for a routine
  Future<int> getTotalDaysPaused(String routineId) async {
    final pauses = await getPauseHistory(routineId);

    int totalDays = 0;
    for (final pause in pauses) {
      totalDays += pause.durationDays;
    }

    return totalDays;
  }

  /// Get most common pause reason for a routine
  Future<PauseReason?> getMostCommonReason(String routineId) async {
    final pauses = await getPauseHistory(routineId);

    if (pauses.isEmpty) return null;

    // Count reasons
    final reasonCounts = <PauseReason, int>{};
    for (final pause in pauses) {
      reasonCounts[pause.reason] = (reasonCounts[pause.reason] ?? 0) + 1;
    }

    // Find most common
    PauseReason? mostCommon;
    int maxCount = 0;

    reasonCounts.forEach((reason, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = reason;
      }
    });

    return mostCommon;
  }

  // === CONFLICT DETECTION ===

  /// Get workouts scheduled in a date range
  ///
  /// This is used to warn users about workouts that will be auto-skipped
  /// when creating a pause.
  ///
  /// NOTE: This requires integration with WorkoutRepository.
  /// For now, returns empty list. Implement in Phase 2.
  Future<List<String>> getWorkoutsInRange({
    required String routineId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // TODO: Implement workout query by date range
    // Example:
    // final workouts = await _workoutRepository.getWorkoutsForRoutine(
    //   routineId: routineId,
    //   startDate: startDate,
    //   endDate: endDate,
    // );
    // return workouts.map((w) => w.id).toList();

    debugPrint('⚠️  Workout conflict detection not yet implemented');
    return [];
  }

  // === FUTURE: BACKGROUND TASKS ===

  /// Setup periodic pause check (via WorkManager)
  ///
  /// This will be implemented in Phase 3 using workmanager package.
  /// For now, we rely on app initialization and resume hooks.
  ///
  /// TODO: Integrate with workmanager package for:
  /// - Periodic task every 1-6 hours
  /// - Auto-resume expired pauses in background
  /// - Send notification when routine resumes
  Future<void> setupPeriodicPauseCheck() async {
    // TODO: Implement WorkManager integration
    debugPrint('⚠️  WorkManager integration not yet implemented');

    // Example future code:
    // await Workmanager().registerPeriodicTask(
    //   'pause_check',
    //   'checkExpiredPauses',
    //   frequency: Duration(hours: 1),
    // );
  }

  /// Cancel periodic pause check
  Future<void> cancelPeriodicPauseCheck() async {
    // TODO: Implement WorkManager cancellation
    debugPrint('⚠️  WorkManager integration not yet implemented');

    // Example future code:
    // await Workmanager().cancelByUniqueName('pause_check');
  }
}
