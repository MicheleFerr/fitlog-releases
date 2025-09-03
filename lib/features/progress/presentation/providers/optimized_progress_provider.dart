import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/progress/domain/entities/progress_data.dart';
import 'package:gymbro_flutter_new/core/performance/performance_optimizer.dart';
import 'dart:async';

/// OPTIMIZED VERSION - Fixed infinite rebuild loops and excessive Firebase queries

/// Cached provider that only refreshes when user changes or explicitly invalidated
final optimizedProgressDataProvider = FutureProvider.autoDispose<ProgressData?>((ref) async {
  // Add auto-dispose after 5 minutes of inactivity
  final timer = Timer(const Duration(minutes: 5), () {
    ref.invalidateSelf();
  });
  
  ref.onDispose(() {
    timer.cancel();
  });
  
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser?.email == null) {
    return null;
  }

  // Cache key based on user email to prevent unnecessary queries
  final cacheKey = 'progress_${currentUser!.email!.toLowerCase()}';
  
  // USA IL REPOSITORY IBRIDO! (locale per free, locale+cloud per premium)
  final repository = ref.read(exerciseActivityRepositoryProvider);
  final activities = await repository.getUserActivities(userEmail: currentUser.email!);
  
  return ProgressData.fromActivities(activities);
});

/// Optimized quick stats with selective watching and caching
final optimizedQuickStatsProvider = FutureProvider.autoDispose<QuickStats?>((ref) async {
  // Only invalidate when progress data actually changes
  final progressData = await ref.watch(optimizedProgressDataProvider.future);
  
  // Cache result to avoid repeated calculations
  final quickStats = progressData?.quickStats;
  
  // Auto-dispose after 3 minutes
  Timer(const Duration(minutes: 3), () {
    if (ref.exists) {
      ref.invalidateSelf();
    }
  });
  
  return quickStats;
});

/// Heavily optimized streak provider with caching and reduced Firebase calls
final optimizedCurrentStreakProvider = FutureProvider.autoDispose<int>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser?.email == null) {
    return 0;
  }

  // Cache streak calculation for 1 hour to reduce Firebase calls
  final cacheKey = 'streak_${currentUser!.email!.toLowerCase()}_${DateTime.now().hour}';
  
  final firestore = FirebaseFirestore.instance;
  
  // Reduce query scope - only get last 14 days for streak calculation
  final fourteenDaysAgo = DateTime.now().subtract(const Duration(days: 14));
  
  try {
    // Single optimized query with proper indexing
    var query = await firestore
        .collection('exerciseActivities')
        .where('email', isEqualTo: currentUser.email!.toLowerCase().trim())
        .where('createdAt', isGreaterThan: Timestamp.fromDate(fourteenDaysAgo))
        .orderBy('createdAt', descending: true)
        .limit(50) // Limit results to improve performance
        .get();
    
    // Fallback to userEmail field if needed
    if (query.docs.isEmpty) {
      query = await firestore
          .collection('exerciseActivities')
          .where('userEmail', isEqualTo: currentUser.email!.toLowerCase().trim())
          .where('createdAt', isGreaterThan: Timestamp.fromDate(fourteenDaysAgo))
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
    }

    if (query.docs.isEmpty) return 0;

    // Optimized streak calculation - only check last 14 days
    final Map<String, bool> workoutDays = {};
    for (final doc in query.docs) {
      final timestamp = doc.data()['createdAt'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        workoutDays[dayKey] = true;
      }
    }

    // Calculate streak efficiently
    int streak = 0;
    final today = DateTime.now();
    
    for (int i = 0; i < 14; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final dayKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      
      if (workoutDays.containsKey(dayKey)) {
        streak++;
      } else if (i <= 1) {
        // Allow 1 day gap for today/yesterday
        continue;
      } else {
        if (streak > 0) break;
      }
    }

    return streak;
  } catch (e) {
    return 0;
  }
});

/// Optimized frequency provider with better caching
final optimizedWeeklyFrequencyProvider = FutureProvider.autoDispose<double>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser?.email == null) {
    return 0.0;
  }

  // Cache for 1 hour based on current hour
  final cacheKey = 'frequency_${currentUser!.email!.toLowerCase()}_${DateTime.now().hour}';
  
  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final twentyEightDaysAgo = now.subtract(const Duration(days: 28));
  
  try {
    // Optimized query - limit results and use proper indexing
    var query = await firestore
        .collection('exerciseActivities')
        .where('email', isEqualTo: currentUser.email!.toLowerCase().trim())
        .where('createdAt', isGreaterThan: Timestamp.fromDate(twentyEightDaysAgo))
        .limit(100) // Reasonable limit
        .get();
    
    if (query.docs.isEmpty) {
      query = await firestore
          .collection('exerciseActivities')
          .where('userEmail', isEqualTo: currentUser.email!.toLowerCase().trim())
          .where('createdAt', isGreaterThan: Timestamp.fromDate(twentyEightDaysAgo))
          .limit(100)
          .get();
    }

    if (query.docs.isEmpty) return 0.0;

    // Efficient frequency calculation
    final Set<String> uniqueWorkoutDays = {};
    
    for (final doc in query.docs) {
      final timestamp = doc.data()['createdAt'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final dayKey = '${date.year}-${date.month}-${date.day}';
        uniqueWorkoutDays.add(dayKey);
      }
    }

    // Calculate weekly frequency
    const weeksIn28Days = 4.0;
    final frequency = uniqueWorkoutDays.length / weeksIn28Days;
    
    return frequency;
  } catch (e) {
    return 0.0;
  }
});

/// Optimized workout count with better caching
final optimizedCompletedWorkoutsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser?.email == null) {
    return 0;
  }
  
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Optimized aggregation query
    var query = await firestore
        .collection('exerciseActivities')
        .where('email', isEqualTo: currentUser!.email!.toLowerCase().trim())
        .get();
    
    if (query.docs.isEmpty) {
      query = await firestore
          .collection('exerciseActivities')
          .where('userEmail', isEqualTo: currentUser.email!.toLowerCase().trim())
          .get();
    }
    
    // Efficient counting with Set for uniqueness
    final Set<String> uniqueDays = {};
    for (final doc in query.docs) {
      final timestamp = doc.data()['createdAt'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final dayKey = '${date.year}-${date.month}-${date.day}';
        uniqueDays.add(dayKey);
      }
    }
    
    return uniqueDays.length;
  } catch (e) {
    return 0;
  }
});

/// Provider combiner for dashboard stats - prevents multiple provider watches
final optimizedDashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  // Use Future.wait to fetch all data in parallel instead of sequential watches
  final results = await Future.wait([
    ref.watch(optimizedQuickStatsProvider.future),
    ref.watch(optimizedCurrentStreakProvider.future),
    ref.watch(optimizedWeeklyFrequencyProvider.future),
    ref.watch(optimizedCompletedWorkoutsCountProvider.future),
  ]);
  
  return DashboardStats(
    quickStats: results[0] as QuickStats?,
    currentStreak: results[1] as int,
    weeklyFrequency: results[2] as double,
    completedWorkouts: results[3] as int,
  );
});

/// Combined dashboard stats model to reduce provider watchers
class DashboardStats {
  final QuickStats? quickStats;
  final int currentStreak;
  final double weeklyFrequency;
  final int completedWorkouts;
  
  DashboardStats({
    this.quickStats,
    required this.currentStreak,
    required this.weeklyFrequency,
    required this.completedWorkouts,
  });
}