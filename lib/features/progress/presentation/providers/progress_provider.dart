import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/progress/domain/entities/progress_data.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';

/// ✅ MIGRATED: Removed ExerciseActivityRepository dependency
/// This provider is DEPRECATED - use workout-based providers instead
/// Kept for backward compatibility during migration
@Deprecated('Use workout-based progress providers instead')
final progressDataProvider = FutureProvider.autoDispose<ProgressData?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser == null) {
    return null;
  }

  // TODO: Implement ProgressData calculation from workouts collection
  // For now, return null to avoid querying empty exerciseActivities
  return null;
});

/// Provider per le statistiche rapide mostrate nella home
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final quickStatsProvider = FutureProvider.autoDispose<QuickStats?>((ref) async {
  final progressData = await ref.watch(progressDataProvider.future);
  return progressData?.quickStats;
});

/// ✅ MIGRATED: Query workouts collection for most recent activity
/// Uses completedAt field to get last completed workout date
final recentActivityProvider = FutureProvider.autoDispose<DateTime?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.uid == null) {
    return null;
  }

  try {
    final firestore = FirebaseFirestore.instance;
    final query = await firestore
        .collection('workouts')
        .where('userId', isEqualTo: currentUser!.uid)
        .where('status', isEqualTo: 'completed')
        .orderBy('endTime', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [RecentActivity] No workouts found for userId: ${currentUser.uid}');
      }
      return null;
    }

    final doc = query.docs.first;
    final data = doc.data();
    final timestamp = data['endTime'] as Timestamp?;
    final date = timestamp?.toDate();

    if (kDebugMode) {
      debugPrint('✅ [RecentActivity] Last workout: $date');
    }

    return date;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [RecentActivity] Error: $e');
    }
    return null;
  }
});

/// ⚡ OPTIMIZED: Count completed workouts from LOCAL Hive instead of Firestore
/// Each workout = 1 completed workout (much simpler than counting exercise activities)
final completedWorkoutsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.uid == null) {
    return 0;
  }

  try {
    // ✅ FIX: Read from LOCAL Hive instead of Firestore
    final hiveDataSource = ref.watch(hiveWorkoutDataSourceProvider);
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));

    final workouts = await hiveDataSource.getWorkouts(
      currentUser!.uid,
      startDate: oneYearAgo,
      limit: 500,
    );

    if (kDebugMode) {
      debugPrint('✅ [CompletedWorkouts-HIVE] Found ${workouts.length} workouts in last year (LOCAL)');
    }

    return workouts.length;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [CompletedWorkouts-HIVE] Error: $e');
    }
    return 0;
  }
});

/// ⚡ OPTIMIZED: Calculate streak from LOCAL Hive workouts instead of Firestore
/// Counts consecutive days with completed workouts (uses completedAt/startTime field)
final currentStreakProvider = FutureProvider.autoDispose<int>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.uid == null) {
    if (kDebugMode) {
      debugPrint('🔥 [STREAK] No user UID - returning 0');
    }
    return 0;
  }

  // ✅ FIX: Read from LOCAL Hive instead of Firestore
  final hiveDataSource = ref.watch(hiveWorkoutDataSourceProvider);
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

  if (kDebugMode) {
    debugPrint('⚡ [STREAK-HIVE] Reading from LOCAL storage (no Firestore query)');
  }

  final workouts = await hiveDataSource.getWorkouts(
    currentUser!.uid,
    startDate: thirtyDaysAgo,
    limit: 100,
  );

  if (workouts.isEmpty) {
    if (kDebugMode) {
      debugPrint('⚠️ [STREAK-HIVE] No workouts found in local storage');
    }
    return 0;
  }

  // Group workouts by day (use endTime for completed workouts)
  final Map<String, bool> workoutDays = {};
  for (final workout in workouts) {
    // Use endTime if available, otherwise startTime
    final date = workout.endTime ?? workout.startTime;
    if (date != null) {
      final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      workoutDays[dayKey] = true;
    }
  }

  // Calculate streak starting from today
  int streak = 0;
  final today = DateTime.now();

  // Check if there's a workout today or in recent days
  for (int i = 0; i < 30; i++) {
    final checkDate = today.subtract(Duration(days: i));
    final dayKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

    if (workoutDays.containsKey(dayKey)) {
      streak++;
    } else if (i <= 1) {
      // If no workout today or yesterday, keep searching
      continue;
    } else {
      // Break only if there's already a streak and a day is missing
      if (streak > 0) {
        break;
      }
    }
  }

  if (kDebugMode) {
    debugPrint('✅ [STREAK-HIVE] Streak: $streak days (from ${workouts.length} local workouts)');
  }
  return streak;
});

/// ⚡ OPTIMIZED: Calculate weekly frequency from LOCAL Hive workouts instead of Firestore
/// Counts unique days with workouts in last 30 days, then averages per week
final weeklyFrequencyProvider = FutureProvider.autoDispose<double>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.uid == null) {
    return 0.0;
  }

  // ✅ FIX: Read from LOCAL Hive instead of Firestore
  final hiveDataSource = ref.watch(hiveWorkoutDataSourceProvider);
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));

  final workouts = await hiveDataSource.getWorkouts(
    currentUser!.uid,
    startDate: thirtyDaysAgo,
    limit: 100,
  );

  if (workouts.isEmpty) return 0.0;

  // Count unique workout days per week
  final Map<int, Set<String>> workoutDaysByWeek = {};

  for (final workout in workouts) {
    // Use endTime if available, otherwise startTime
    final date = workout.endTime ?? workout.startTime;
    if (date == null) continue;

    // Use only date without time for proper day grouping
    final nowDate = DateTime(now.year, now.month, now.day);
    final workoutDate = DateTime(date.year, date.month, date.day);

    // Calculate days difference based on date only
    final daysDifference = nowDate.difference(workoutDate).inDays;

    // Count only unique workout days in last 30 days
    if (daysDifference >= 0 && daysDifference < 30) {
      // Determine which week this workout falls into
      final int weekNumber = daysDifference ~/ 7;

      if (weekNumber < 5) { // Max 4.x weeks in 30 days
        workoutDaysByWeek.putIfAbsent(weekNumber, () => <String>{});
        // Use date (year-month-day) to identify unique days
        final dayKey = '${date.year}-${date.month}-${date.day}';
        workoutDaysByWeek[weekNumber]!.add(dayKey);
      }
    }
  }

  // Count total workout days in last 30 days
  final totalWorkoutDays = workoutDaysByWeek.values.fold(0, (sum, days) => sum + days.length);

  // Calculate weekly average based on 30 days (~4.3 weeks)
  const weeksIn30Days = 30.0 / 7.0; // ~4.3 weeks
  final average = totalWorkoutDays / weeksIn30Days;

  if (kDebugMode) {
    debugPrint('✅ [WeeklyFrequency-HIVE] Total workout days: $totalWorkoutDays, Average: ${average.toStringAsFixed(1)}/week (LOCAL)');
  }

  return average;
});