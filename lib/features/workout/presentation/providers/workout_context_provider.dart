/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: provider (state management)
/// 🌍 Localization: N/A (provider logic)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/experience_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for workout context (null = not gathered yet)
final workoutContextProvider =
    StateNotifierProvider<WorkoutContextNotifier, WorkoutContext?>(
  (ref) => WorkoutContextNotifier(),
);

/// Notifier for managing workout context state
///
/// Responsibilities:
/// - Store current workout context
/// - Save/restore context from SharedPreferences (for mid-flow abandonment)
/// - Clear context after workout completion
/// - Provide analytics data
class WorkoutContextNotifier extends StateNotifier<WorkoutContext?> {
  WorkoutContextNotifier() : super(null) {
    _restoreContext();
  }

  /// Restore context from SharedPreferences (if user abandoned mid-flow)
  Future<void> _restoreContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if there's a saved context
      final timeAvailable = prefs.getInt('context_time');
      if (timeAvailable == null) return;

      final experienceLevelStr = prefs.getString('context_level');
      final gender = prefs.getString('context_gender');
      final timestampStr = prefs.getString('context_timestamp');
      final completionTimeMs = prefs.getInt('context_completion_time_ms');

      state = WorkoutContext(
        timeAvailable: timeAvailable,
        experienceLevel:
            experienceLevelStr != null && experienceLevelStr.isNotEmpty
                ? ExperienceLevel.fromString(experienceLevelStr)
                : null,
        gender: gender,
        timestamp:
            timestampStr != null ? DateTime.parse(timestampStr) : DateTime.now(),
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

      await prefs.setInt('context_time', context.timeAvailable);
      await prefs.setString(
          'context_level', context.experienceLevel?.name ?? '');
      await prefs.setString('context_gender', context.gender ?? '');
      await prefs.setString('context_timestamp', context.timestamp.toIso8601String());
      if (context.completionTimeMs != null) {
        await prefs.setInt(
            'context_completion_time_ms', context.completionTimeMs!);
      }
    } catch (e) {
      // If save fails, continue (non-critical)
    }
  }

  /// Clear saved context from SharedPreferences
  Future<void> _clearSavedContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('context_time');
      await prefs.remove('context_level');
      await prefs.remove('context_gender');
      await prefs.remove('context_timestamp');
      await prefs.remove('context_completion_time_ms');
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
      return prefs.containsKey('context_time');
    } catch (e) {
      return false;
    }
  }

  /// Get analytics map (for Firebase logging)
  Map<String, dynamic>? getAnalyticsMap() {
    return state?.toMap();
  }
}
