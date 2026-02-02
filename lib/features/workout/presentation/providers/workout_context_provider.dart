/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: provider (state management)
/// 🌍 Localization: N/A (provider logic)
///
/// 🔐 USER ISOLATION: Cache keys are user-scoped to prevent data leakage
/// when switching between accounts.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/experience_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_context.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Provider for workout context (null = not gathered yet)
final workoutContextProvider =
    NotifierProvider<WorkoutContextNotifier, WorkoutContext?>(
      WorkoutContextNotifier.new,
    );

/// Notifier for managing workout context state
///
/// Responsibilities:
/// - Store current workout context
/// - Save/restore context from SharedPreferences (for mid-flow abandonment)
/// - Clear context after workout completion
/// - Provide analytics data
class WorkoutContextNotifier extends Notifier<WorkoutContext?> {
  @override
  WorkoutContext? build() {
    _restoreContext();
    return null;
  }

  /// Restore context from SharedPreferences (if user abandoned mid-flow)
  Future<void> _restoreContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 🔐 User-scoped cache keys
      final timeKey = userCacheKeys.userScopedKey('context_time');
      final levelKey = userCacheKeys.userScopedKey('context_level');
      final genderKey = userCacheKeys.userScopedKey('context_gender');
      final timestampKey = userCacheKeys.userScopedKey('context_timestamp');
      final completionKey = userCacheKeys.userScopedKey(
        'context_completion_time_ms',
      );

      // Check if there's a saved context
      final timeAvailable = prefs.getInt(timeKey);
      if (timeAvailable == null) return;

      final experienceLevelStr = prefs.getString(levelKey);
      final gender = prefs.getString(genderKey);
      final timestampStr = prefs.getString(timestampKey);
      final completionTimeMs = prefs.getInt(completionKey);

      state = WorkoutContext(
        timeAvailable: timeAvailable,
        experienceLevel:
            experienceLevelStr != null && experienceLevelStr.isNotEmpty
            ? ExperienceLevel.fromString(experienceLevelStr)
            : null,
        gender: gender,
        timestamp: timestampStr != null
            ? DateTime.parse(timestampStr)
            : DateTime.now(),
        completionTimeMs: completionTimeMs,
      );
    } catch (e) {
      // If restoration fails, start fresh
      state = null;
    }
  }

  /// Save context to SharedPreferences (for mid-flow abandonment recovery)
  Future<void> _saveContext(WorkoutContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 🔐 User-scoped cache keys
      final timeKey = userCacheKeys.userScopedKey('context_time');
      final levelKey = userCacheKeys.userScopedKey('context_level');
      final genderKey = userCacheKeys.userScopedKey('context_gender');
      final timestampKey = userCacheKeys.userScopedKey('context_timestamp');
      final completionKey = userCacheKeys.userScopedKey(
        'context_completion_time_ms',
      );

      await prefs.setInt(timeKey, context.timeAvailable);
      await prefs.setString(levelKey, context.experienceLevel?.name ?? '');
      await prefs.setString(genderKey, context.gender ?? '');
      await prefs.setString(timestampKey, context.timestamp.toIso8601String());
      if (context.completionTimeMs != null) {
        await prefs.setInt(completionKey, context.completionTimeMs!);
      }
    } catch (e) {
      // If save fails, continue (non-critical)
    }
  }

  /// Clear saved context from SharedPreferences
  Future<void> _clearSavedContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 🔐 User-scoped cache keys
      final timeKey = userCacheKeys.userScopedKey('context_time');
      final levelKey = userCacheKeys.userScopedKey('context_level');
      final genderKey = userCacheKeys.userScopedKey('context_gender');
      final timestampKey = userCacheKeys.userScopedKey('context_timestamp');
      final completionKey = userCacheKeys.userScopedKey(
        'context_completion_time_ms',
      );

      await prefs.remove(timeKey);
      await prefs.remove(levelKey);
      await prefs.remove(genderKey);
      await prefs.remove(timestampKey);
      await prefs.remove(completionKey);
    } catch (e) {
      // If clear fails, continue (non-critical)
    }
  }

  /// Update context (during step-by-step gathering)
  Future<void> updateContext(WorkoutContext context) async {
    state = context;
    await _saveContext(context);
  }

  /// Set context (after completion)
  Future<void> setContext(WorkoutContext context) async {
    state = context;
    await _saveContext(context);
  }

  /// Clear context (after workout completion or reset)
  Future<void> clearContext() async {
    state = null;
    await _clearSavedContext();
  }

  /// Check if there's a saved context to restore
  Future<bool> hasSavedContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 🔐 User-scoped cache key
      final timeKey = userCacheKeys.userScopedKey('context_time');
      return prefs.containsKey(timeKey);
    } catch (e) {
      return false;
    }
  }

  /// Get analytics map (for Firebase logging)
  Map<String, dynamic>? getAnalyticsMap() {
    return state?.toMap();
  }
}
