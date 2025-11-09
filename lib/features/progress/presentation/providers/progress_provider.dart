import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/progress/domain/entities/progress_data.dart';

/// ✅ MIGRATED: Query 'workouts' collection instead of 'exerciseActivities'
/// Uses userId field instead of email for better data consistency
Future<QuerySnapshot> _queryWorkoutsOptimized({
  required FirebaseFirestore firestore,
  required String userId,
  required String orderByField,
  DateTime? startDate,
  DateTime? endDate,
  int? limit,
  bool descending = true,
}) async {
  Query query = firestore
      .collection('workouts')
      .where('userId', isEqualTo: userId);

  // Add date filters if provided
  if (startDate != null) {
    query = query.where(orderByField, isGreaterThan: Timestamp.fromDate(startDate));
  }

  if (endDate != null) {
    query = query.where(orderByField, isLessThan: Timestamp.fromDate(endDate));
  }

  // Add ordering
  query = query.orderBy(orderByField, descending: descending);

  // Add limit if provided
  if (limit != null) {
    query = query.limit(limit);
  }

  return await query.get();
}

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
    final query = await _queryWorkoutsOptimized(
      firestore: firestore,
      userId: currentUser!.uid,
      orderByField: 'completedAt',
      limit: 1,
      descending: true,
    );

    if (query.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [RecentActivity] No workouts found for userId: ${currentUser.uid}');
      }
      return null;
    }

    final doc = query.docs.first;
    final data = doc.data() as Map<String, dynamic>?;
    final timestamp = data?['completedAt'] as Timestamp?;
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

/// ✅ MIGRATED: Count actual completed workouts from workouts collection
/// Each workout document = 1 completed workout (much simpler than counting exercise activities)
final completedWorkoutsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.uid == null) {
    return 0;
  }

  try {
    final firestore = FirebaseFirestore.instance;

    // Query last 365 days of workouts (optimization)
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));

    final query = await _queryWorkoutsOptimized(
      firestore: firestore,
      userId: currentUser!.uid,
      orderByField: 'completedAt',
      startDate: oneYearAgo,
      limit: 500, // Max 500 workouts (sufficient for 1 year)
      descending: true,
    );

    if (kDebugMode) {
      debugPrint('✅ [CompletedWorkouts] Found ${query.docs.length} workouts in last year');
    }

    // Each document = 1 completed workout (no need to count unique days)
    return query.docs.length;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [CompletedWorkouts] Error: $e');
    }
    return 0;
  }
});

/// ✅ MIGRATED: Calculate streak from workouts collection
/// Counts consecutive days with completed workouts (uses completedAt field)
final currentStreakProvider = FutureProvider.autoDispose<int>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.uid == null) {
    debugPrint('🔥 [STREAK DEBUG] No user UID - returning 0');
    return 0;
  }

  final firestore = FirebaseFirestore.instance;

  // Query last 30 days of workouts for streak calculation
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

  debugPrint('🔥 [STREAK DEBUG] =====================');
  debugPrint('🔥 User ID: ${currentUser!.uid}');
  debugPrint('🔥 Querying from: $thirtyDaysAgo');
  debugPrint('🔥 Querying to: ${DateTime.now()}');

  final query = await _queryWorkoutsOptimized(
    firestore: firestore,
    userId: currentUser.uid,
    orderByField: 'completedAt',
    startDate: thirtyDaysAgo,
    limit: 100, // Max 100 workouts (sufficient for 30 days)
    descending: true,
  );

  debugPrint('🔥 Query result: ${query.docs.length} workout documents found');

  if (query.docs.isEmpty) {
    debugPrint('❌ NO WORKOUTS FOUND! Possible reasons:');
    debugPrint('  1. userId mismatch - check Firestore for correct userId field');
    debugPrint('  2. Timestamp issue - check completedAt field format');
    debugPrint('  3. Security rules blocking query');
    debugPrint('  4. User has no workouts in last 30 days');
    return 0;
  }

  // Log first few workout documents for debugging
  debugPrint('🔥 First 3 workout documents:');
  for (var i = 0; i < query.docs.length && i < 3; i++) {
    final doc = query.docs[i];
    final data = doc.data() as Map<String, dynamic>?;
    debugPrint('  Workout $i: id=${doc.id}');
    debugPrint('    userId: ${data?['userId']}');
    debugPrint('    name: ${data?['name']}');
    debugPrint('    completedAt: ${data?['completedAt']}');
    debugPrint('    exercises: ${(data?['exercises'] as List?)?.length ?? 0}');
  }

  // Group workouts by day
  final Map<String, bool> workoutDays = {};
  for (final doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>?;
    final timestamp = data?['completedAt'] as Timestamp?;
    if (timestamp != null) {
      final date = timestamp.toDate();
      final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      workoutDays[dayKey] = true;
    }
  }

  // Calculate streak starting from today
  int streak = 0;
  final today = DateTime.now();

  debugPrint('🔥 Calculating streak from workout days: ${workoutDays.keys.toList()}');

  // Check if there's a workout today or in recent days
  for (int i = 0; i < 30; i++) {
    final checkDate = today.subtract(Duration(days: i));
    final dayKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

    if (workoutDays.containsKey(dayKey)) {
      streak++;
      debugPrint('  Day $i ($dayKey): ✅ HAS WORKOUT (streak now: $streak)');
    } else if (i <= 1) {
      // If no workout today or yesterday, keep searching
      debugPrint('  Day $i ($dayKey): ❌ NO WORKOUT (but i <= 1, continuing)');
      continue;
    } else {
      // Break only if there's already a streak and a day is missing
      if (streak > 0) {
        debugPrint('  Day $i ($dayKey): ❌ NO WORKOUT (breaking streak at $streak)');
        break;
      }
      debugPrint('  Day $i ($dayKey): ❌ NO WORKOUT (no streak yet, continuing)');
    }
  }

  debugPrint('✅ Final streak: $streak days');
  return streak;
});

/// ✅ MIGRATED: Calculate weekly workout frequency from workouts collection
/// Counts unique days with workouts in last 30 days, then averages per week
final weeklyFrequencyProvider = FutureProvider.autoDispose<double>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.uid == null) {
    return 0.0;
  }

  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));

  final query = await _queryWorkoutsOptimized(
    firestore: firestore,
    userId: currentUser!.uid,
    orderByField: 'completedAt',
    startDate: thirtyDaysAgo,
    limit: 100, // Max 100 workouts for frequency calculation
    descending: true,
  );

  if (query.docs.isEmpty) return 0.0;

  // Count unique workout days per week
  final Map<int, Set<String>> workoutDaysByWeek = {};

  for (final doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) continue;

    final timestamp = data['completedAt'] as Timestamp?;

    if (timestamp != null) {
      final date = timestamp.toDate();

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
  }

  // Count total workout days in last 30 days
  final totalWorkoutDays = workoutDaysByWeek.values.fold(0, (sum, days) => sum + days.length);

  // Calculate weekly average based on 30 days (~4.3 weeks)
  const weeksIn30Days = 30.0 / 7.0; // ~4.3 weeks
  final average = totalWorkoutDays / weeksIn30Days;

  if (kDebugMode) {
    debugPrint('✅ [WeeklyFrequency] Total workout days: $totalWorkoutDays, Average: ${average.toStringAsFixed(1)}/week');
  }

  return average;
});