/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// SIMPLE PROGRESS PROVIDER
/// Versione semplificata che conta direttamente i workout
/// senza ottimizzazioni complesse
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';

/// Dashboard stats entity for home screen
class DashboardStats {

  const DashboardStats({
    required this.currentStreak,
    required this.totalWorkouts,
    required this.weeklyFrequency,
    required this.totalVolume,
    required this.volumeIncrease,
    required this.maxPR,
    required this.prExercise,
  });

  factory DashboardStats.empty() {
    return const DashboardStats(
      currentStreak: 0,
      totalWorkouts: 0,
      weeklyFrequency: 0.0,
      totalVolume: 0.0,
      volumeIncrease: 0.0,
      maxPR: 0.0,
      prExercise: 'N/A',
    );
  }
  final int currentStreak;
  final int totalWorkouts;
  final double weeklyFrequency;
  final double totalVolume;
  final double volumeIncrease;
  final double maxPR;
  final String prExercise;
}

/// ULTRA SIMPLE Provider - just counts workouts, no complex calculations
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final ultraSimpleDashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.email == null) {
    return DashboardStats.empty();
  }

  try {
    // ✅ MIGRATED: Query workouts collection
    final query = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: currentUser!.uid)
        .get();

    final totalWorkouts = query.docs.length;

    // Return basic stats with just the count
    return DashboardStats(
      currentStreak: 0,
      totalWorkouts: totalWorkouts,
      weeklyFrequency: 0.0,
      totalVolume: 0.0,
      volumeIncrease: 0.0,
      maxPR: 0.0,
      prExercise: 'N/A',
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Error in ultra simple provider: $e');
    }
    return DashboardStats.empty();
  }
});

/// SIMPLE Provider that directly counts workouts
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final simpleDashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.email == null) {
    if (kDebugMode) {
      debugPrint('❌ No user logged in');
    }
    return DashboardStats.empty();
  }

  final userEmail = currentUser!.email!.toLowerCase().trim();
  if (kDebugMode) {
    debugPrint('📊 Fetching stats for user: $userEmail');
  }

  try {
    // ✅ MIGRATED: Count total workouts from workouts collection
    final allWorkoutsQuery = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: currentUser.uid)
        .get();

    final totalWorkouts = allWorkoutsQuery.docs.length;
    if (kDebugMode) {
      debugPrint('  ✅ Total workouts: $totalWorkouts');
    }

    // ✅ MIGRATED: Calculate streak from workouts (last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentWorkoutsQuery = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: currentUser.uid)
        .where('completedAt', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
        .orderBy('completedAt', descending: true)
        .get();

    // Calculate streak from recent workouts
    final workoutDays = <String>{};
    for (final doc in recentWorkoutsQuery.docs) {
      final timestamp = doc.data()['completedAt'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        workoutDays.add(dayKey);
      }
    }

    // Count consecutive days
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final dayKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

      if (workoutDays.contains(dayKey)) {
        streak++;
      } else if (i <= 1) {
        // Allow 1 day gap
        continue;
      } else {
        // Streak broken
        break;
      }
    }
    if (kDebugMode) {
      debugPrint('  ✅ Current streak: $streak days');
    }

    // ✅ MIGRATED: Calculate weekly frequency from workouts (last 30 days)
    // NOTE: workouts collection has one document per workout (simpler than exerciseActivities)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final monthlyWorkoutsQuery = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: currentUser.uid)
        .where('completedAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .get();

    // Group workouts by date to count unique workout days
    final workoutDates = <String>{};
    for (final doc in monthlyWorkoutsQuery.docs) {
      final timestamp = doc.data()['completedAt'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        workoutDates.add(dateKey);
      }
    }

    final uniqueWorkoutDays = workoutDates.length;
    if (kDebugMode) {
      debugPrint('  📊 Found ${monthlyWorkoutsQuery.docs.length} exercises in $uniqueWorkoutDays unique days in last 30 days');
    }

    // Convert to weekly average based on unique days
    final weeklyFrequency = uniqueWorkoutDays * 7 / 30; // Convert days to weekly frequency
    if (kDebugMode) {
      debugPrint('  ✅ Weekly frequency: ${weeklyFrequency.toStringAsFixed(1)} days/week');
    }

    // ✅ MIGRATED: Calculate volume and PR from nested workout structure
    double totalVolume = 0;
    double maxPR = 0;
    String prExercise = 'N/A';

    for (final doc in allWorkoutsQuery.docs) {
      final data = doc.data();
      final exercises = data['exercises'] as List<dynamic>? ?? [];

      for (final exercise in exercises) {
        if (exercise is! Map<String, dynamic>) continue;

        final exerciseData = exercise['exerciseData'] as Map<String, dynamic>?;
        final exerciseName = exerciseData?['name'] as String? ?? 'Unknown';
        final sets = exercise['sets'] as List<dynamic>? ?? [];

        for (final set in sets) {
          if (set is Map<String, dynamic>) {
            // Weight and reps are num in new structure
            final weight = (set['weight'] as num?)?.toDouble() ?? 0;
            final reps = (set['reps'] as num?)?.toInt() ?? 0;

            if (weight > 0 && reps > 0) {
              totalVolume += weight * reps;

              // Track max weight for PR
              if (weight > maxPR) {
                maxPR = weight;
                prExercise = exerciseName;
              }
            }
          }
        }
      }
    }
    if (kDebugMode) {
      debugPrint('  ✅ Total volume: ${totalVolume.toStringAsFixed(0)} kg');
    }
    if (kDebugMode) {
      debugPrint('  ✅ Max PR: ${maxPR.toStringAsFixed(1)} kg on $prExercise');
    }

    // ✅ MIGRATED: Calculate volume increase from nested workout structure
    double recentVolume = 0;
    for (final doc in monthlyWorkoutsQuery.docs) {
      final data = doc.data();
      final exercises = data['exercises'] as List<dynamic>? ?? [];

      for (final exercise in exercises) {
        if (exercise is! Map<String, dynamic>) continue;

        final sets = exercise['sets'] as List<dynamic>? ?? [];

        for (final set in sets) {
          if (set is Map<String, dynamic>) {
            final weight = (set['weight'] as num?)?.toDouble() ?? 0;
            final reps = (set['reps'] as num?)?.toInt() ?? 0;

            if (weight > 0 && reps > 0) {
              recentVolume += weight * reps;
            }
          }
        }
      }
    }

    final averageVolume = totalWorkouts > 0 ? totalVolume / totalWorkouts * 4 : 0.0;
    final volumeIncrease = averageVolume > 0
        ? ((recentVolume - averageVolume) / averageVolume * 100)
        : 0.0;

    if (kDebugMode) {
      debugPrint('  ✅ Volume increase: ${volumeIncrease.toStringAsFixed(1)}%');
    }

    return DashboardStats(
      currentStreak: streak,
      totalWorkouts: totalWorkouts,
      weeklyFrequency: weeklyFrequency,
      totalVolume: totalVolume,
      volumeIncrease: volumeIncrease,
      maxPR: maxPR,
      prExercise: prExercise,
    );
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('❌ Error fetching dashboard stats: $e');
    }
    if (kDebugMode) {
      debugPrint('Stack: $stack');
    }
    return DashboardStats.empty();
  }
});