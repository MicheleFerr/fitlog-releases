/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation
/// 🎯 Feature: flexible_routine
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// DAY STATS PROVIDER - State management for day statistics
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/day_stats.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:flutter/foundation.dart';

/// Provider for current user ID
final _currentUserIdProvider = Provider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
});

/// Fetches workout completed on specific date
final workoutForDateProvider = FutureProvider.family<WorkoutHistoryDetail?, DateTime>((ref, date) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return null;

  // Normalize date to start and end of day
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('completedAt', isGreaterThanOrEqualTo: startOfDay)
        .where('completedAt', isLessThanOrEqualTo: endOfDay)
        .orderBy('completedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return WorkoutHistoryDetail.fromFirestore(snapshot.docs.first);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Error fetching workout for date $date: $e');
    }
    return null;
  }
});

/// 🆕 Fetches all workouts completed in a month (for calendar coloring)
///
/// Returns a Map where key = "YYYY-MM-DD" and value = WorkoutHistoryDetail
/// This allows efficient lookup for calendar day coloring without 30+ separate queries.
///
/// Usage:
/// ```dart
/// final workoutsMap = ref.watch(workoutsForMonthProvider(DateTime(2025, 1, 1)));
/// final hasWorkout = workoutsMap.value?['2025-01-15'] != null;
/// ```
final workoutsForMonthProvider = FutureProvider.family<Map<String, WorkoutHistoryDetail>, DateTime>((ref, month) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return {};

  // Normalize to start and end of month
  final startOfMonth = DateTime(month.year, month.month, 1);
  final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('completedAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('completedAt', isLessThanOrEqualTo: endOfMonth)
        .orderBy('completedAt', descending: false)
        .get();

    // Build map with date key "YYYY-MM-DD"
    final workoutsMap = <String, WorkoutHistoryDetail>{};
    for (final doc in snapshot.docs) {
      final workout = WorkoutHistoryDetail.fromFirestore(doc);
      final dateKey = '${workout.completedAt.year}-${workout.completedAt.month.toString().padLeft(2, '0')}-${workout.completedAt.day.toString().padLeft(2, '0')}';

      // If multiple workouts same day, keep the latest (last one in iteration)
      workoutsMap[dateKey] = workout;
    }

    if (kDebugMode) {
      debugPrint('✅ Loaded ${workoutsMap.length} workouts for month ${month.month}/${month.year}');
    }

    return workoutsMap;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Error fetching workouts for month $month: $e');
    }
    return {};
  }
});

/// Fetches history of workouts with same template
final templateHistoryProvider = FutureProvider.family<List<WorkoutHistoryDetail>, String>((ref, templateId) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return [];

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('templateId', isEqualTo: templateId)
        .orderBy('completedAt', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => WorkoutHistoryDetail.fromFirestore(doc))
        .toList();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Error fetching template history for $templateId: $e');
    }
    return [];
  }
});

/// Calculates complete statistics for a routine day
final dayStatsProvider = FutureProvider.family<DayStats, DayStatsParams>((ref, params) async {
  try {
    // Fetch completed workout for this date (ALWAYS check, even if rest day)
    final completedWorkout = await ref.watch(workoutForDateProvider(params.date).future);

    // 🆕 FIXED: If no template ID BUT there's a completed workout → show it!
    // This handles the case where user did a workout on a "rest day" in the schedule
    if (params.templateId == null) {
      // If no workout completed that day either → truly empty
      if (completedWorkout == null) {
        return DayStats.empty(params.date);
      }

      // ✅ Workout completed on rest day → show workout stats with its template
      final workoutTemplateId = completedWorkout.templateId;
      final template = workoutTemplateId != null
          ? await ref.watch(templateByIdProvider(workoutTemplateId).future)
          : null;

      // Get history for this workout's template (if exists)
      final previousWorkouts = workoutTemplateId != null
          ? await ref.watch(templateHistoryProvider(workoutTemplateId).future)
          : <WorkoutHistoryDetail>[];

      final filteredHistory = previousWorkouts
          .where((w) => w.id != completedWorkout.id)
          .toList();

      // Calculate metrics
      final totalVolume = completedWorkout.totalVolume;
      final duration = completedWorkout.duration;
      final totalExercises = completedWorkout.exercises.length;
      final completedExercises = completedWorkout.exercises.length;
      final averageRPE = completedWorkout.averageRPE;

      // Calculate comparison with last workout
      double? volumeChangePercent;
      Duration? durationChange;
      bool isPersonalRecord = false;

      if (filteredHistory.isNotEmpty) {
        final lastWorkout = filteredHistory.first;

        // Volume change
        if (lastWorkout.totalVolume > 0) {
          volumeChangePercent = ((totalVolume - lastWorkout.totalVolume) / lastWorkout.totalVolume) * 100;
        }

        // Duration change
        durationChange = duration - lastWorkout.duration;

        // Check if personal record (highest volume ever)
        final maxVolume = filteredHistory.fold<double>(
          0,
          (max, workout) => workout.totalVolume > max ? workout.totalVolume : max,
        );
        isPersonalRecord = totalVolume > maxVolume;
      }

      // Calculate streak
      final currentStreak = await _calculateStreak(ref, params.date);

      // Check if after rest day
      final isAfterRestDay = await _isAfterRestDay(ref, params.date);

      return DayStats(
        date: params.date,
        templateId: workoutTemplateId,
        templateName: template?.name ?? completedWorkout.name,
        completedWorkout: completedWorkout,
        totalVolume: totalVolume,
        duration: duration,
        totalExercises: totalExercises,
        completedExercises: completedExercises,
        averageRPE: averageRPE,
        previousWorkouts: filteredHistory,
        volumeChangePercent: volumeChangePercent,
        durationChange: durationChange,
        isPersonalRecord: isPersonalRecord,
        currentStreak: currentStreak,
        isAfterRestDay: isAfterRestDay,
        totalWorkoutsWithTemplate: filteredHistory.length + 1,
      );
    }

    // Normal case: templateId exists in schedule
    // Fetch template name
    final template = await ref.watch(templateByIdProvider(params.templateId!).future);
    final templateName = template?.name;

    // Fetch historical workouts with same template
    final previousWorkouts = await ref.watch(templateHistoryProvider(params.templateId!).future);

    // Remove current workout from history if present
    final filteredHistory = previousWorkouts
        .where((w) => w.id != completedWorkout?.id)
        .toList();

    // Calculate metrics
    final totalVolume = completedWorkout?.totalVolume ?? 0;
    final duration = completedWorkout?.duration ?? Duration.zero;
    final totalExercises = completedWorkout?.exercises.length ?? 0;
    final completedExercises = completedWorkout?.exercises.length ?? 0;
    final averageRPE = completedWorkout?.averageRPE ?? 0;

    // Calculate comparison with last workout
    double? volumeChangePercent;
    Duration? durationChange;
    bool isPersonalRecord = false;

    if (filteredHistory.isNotEmpty && completedWorkout != null) {
      final lastWorkout = filteredHistory.first;

      // Volume change
      if (lastWorkout.totalVolume > 0) {
        volumeChangePercent = ((totalVolume - lastWorkout.totalVolume) / lastWorkout.totalVolume) * 100;
      }

      // Duration change
      durationChange = duration - lastWorkout.duration;

      // Check if personal record (highest volume ever)
      final maxVolume = filteredHistory.fold<double>(
        0,
        (max, workout) => workout.totalVolume > max ? workout.totalVolume : max,
      );
      isPersonalRecord = totalVolume > maxVolume;
    }

    // Calculate streak (simplified - would need more complex logic)
    final currentStreak = await _calculateStreak(ref, params.date);

    // Check if after rest day (simplified)
    final isAfterRestDay = await _isAfterRestDay(ref, params.date);

    return DayStats(
      date: params.date,
      templateId: params.templateId,
      templateName: templateName,
      completedWorkout: completedWorkout,
      totalVolume: totalVolume,
      duration: duration,
      totalExercises: totalExercises,
      completedExercises: completedExercises,
      averageRPE: averageRPE,
      previousWorkouts: filteredHistory,
      volumeChangePercent: volumeChangePercent,
      durationChange: durationChange,
      isPersonalRecord: isPersonalRecord,
      currentStreak: currentStreak,
      isAfterRestDay: isAfterRestDay,
      totalWorkoutsWithTemplate: filteredHistory.length + (completedWorkout != null ? 1 : 0),
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Error calculating day stats: $e');
    }
    return DayStats.empty(params.date);
  }
});

/// Calculate current streak
Future<int> _calculateStreak(Ref ref, DateTime date) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return 0;

  try {
    int streak = 0;
    DateTime checkDate = date.subtract(const Duration(days: 1));

    // Check last 30 days for consecutive workouts
    for (int i = 0; i < 30; i++) {
      final startOfDay = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final endOfDay = DateTime(checkDate.year, checkDate.month, checkDate.day, 23, 59, 59);

      final snapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .where('completedAt', isGreaterThanOrEqualTo: startOfDay)
          .where('completedAt', isLessThanOrEqualTo: endOfDay)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) break;

      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  } catch (e) {
    return 0;
  }
}

/// Check if day is after rest day
Future<bool> _isAfterRestDay(Ref ref, DateTime date) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return false;

  try {
    final yesterday = date.subtract(const Duration(days: 1));
    final startOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final endOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('completedAt', isGreaterThanOrEqualTo: startOfDay)
        .where('completedAt', isLessThanOrEqualTo: endOfDay)
        .limit(1)
        .get();

    return snapshot.docs.isEmpty;
  } catch (e) {
    return false;
  }
}

/// Provider for recovery suggestions
final recoverySuggestionsProvider = FutureProvider.family<List<String>, DayStats>((ref, stats) async {
  final suggestions = <String>[];

  // High RPE warning
  if (stats.averageRPE >= 8.5) {
    suggestions.add('Consider a lighter session tomorrow - high RPE detected');
  }

  // Volume spike warning
  if (stats.volumeChangePercent != null && stats.volumeChangePercent! > 20) {
    suggestions.add('Volume increased significantly - monitor for fatigue');
  }

  // Streak milestone
  if (stats.currentStreak > 0 && stats.currentStreak % 7 == 0) {
    suggestions.add('🔥 ${stats.currentStreak} day streak! Consider a rest day soon');
  }

  // After rest day
  if (stats.isAfterRestDay) {
    suggestions.add('💪 Fresh after rest - good time for intensity');
  }

  // Personal record
  if (stats.isPersonalRecord) {
    suggestions.add('🎯 New PR! Great work - ensure proper recovery');
  }

  // No suggestions
  if (suggestions.isEmpty) {
    suggestions.add('Keep up the consistent work! 💪');
  }

  return suggestions;
});
