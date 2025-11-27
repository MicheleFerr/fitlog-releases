/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: progress
/// 🔧 Type: provider
/// 🌍 Localization: N/A - Provider class
/// 🎨 Theme: N/A - Provider class
/// 📱 Platform: Universal
///
/// OPTIMIZED PROGRESS PROVIDER
/// Uses pre-calculated counters from user profile to minimize Firebase reads
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/progress/domain/entities/progress_data.dart';
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

/// Provider for dashboard stats - combines multiple optimized providers
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final optimizedDashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final streak = await ref.watch(optimizedStreakProvider.future);
  final quickStats = await ref.watch(optimizedQuickStatsProvider.future);
  final frequency = await ref.watch(optimizedMonthlyFrequencyProvider.future);

  if (kDebugMode) {
    debugPrint('📊 Dashboard Stats Debug:');
  }
  if (kDebugMode) {
    debugPrint('  - Streak: $streak');
  }
  if (kDebugMode) {
    debugPrint('  - Total Workouts: ${quickStats?.totalWorkouts ?? 0}');
  }
  if (kDebugMode) {
    debugPrint('  - Weekly Frequency: $frequency');
  }
  if (kDebugMode) {
    debugPrint('  - Total Volume: ${quickStats?.totalVolume ?? 0.0}');
  }

  return DashboardStats(
    currentStreak: streak,
    totalWorkouts: quickStats?.totalWorkouts ?? 0,
    weeklyFrequency: frequency,
    totalVolume: quickStats?.totalVolume ?? 0.0,
    volumeIncrease: quickStats?.volumeIncrease ?? 0.0,
    maxPR: quickStats?.maxPR ?? 0.0,
    prExercise: quickStats?.prExercise ?? 'N/A',
  );
});

/// Provider for quick stats using pre-calculated counters
/// MUCH MORE EFFICIENT than counting all documents
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final optimizedQuickStatsProvider = FutureProvider.autoDispose<QuickStats?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser == null) {
    return null;
  }

  try {
    // Get user document with pre-calculated stats
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!userDoc.exists) {
      if (kDebugMode) {
        debugPrint('⚠️ User document does not exist for ${currentUser.uid}');
      }
      return QuickStats.empty();
    }

    final data = userDoc.data() ?? {};
    final stats = data['stats'] as Map<String, dynamic>? ?? {};

    if (kDebugMode) {
      debugPrint('📊 User Stats from Firebase:');
    }
    if (kDebugMode) {
      debugPrint('  - Full stats object: $stats');
    }

    // Get total workouts from pre-calculated counter
    var totalWorkouts = stats['totalWorkouts'] as int? ?? 0;

    // Get total volume from pre-calculated counter
    var totalVolume = (stats['totalVolume'] as num?)?.toDouble() ?? 0.0;

    // FALLBACK: If stats don't exist, count actual workouts
    if (totalWorkouts == 0 && stats.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ No pre-calculated stats found, counting workouts manually...');
      }

      // Count actual workouts from exerciseActivities
      final workoutQuery = await FirebaseFirestore.instance
          .collection('exerciseActivities')
          .where('email', isEqualTo: currentUser.email!.toLowerCase().trim())
          .limit(500)  // Limit to prevent excessive reads
          .get();

      totalWorkouts = workoutQuery.docs.length;
      if (kDebugMode) {
        debugPrint('  - Found $totalWorkouts workouts by counting');
      }

      // Calculate total volume from these workouts
      for (final doc in workoutQuery.docs) {
        final data = doc.data();
        final sets = data['sets'] as List<dynamic>? ?? [];

        for (final set in sets) {
          if (set is Map<String, dynamic> && (set['done'] == true || set['isCompleted'] == true)) {
            final weight = (set['weight'] as num?)?.toDouble() ?? 0;
            final reps = (set['reps'] as num?)?.toInt() ?? 0;
            totalVolume += weight * reps;
          }
        }
      }

      // Update user document with calculated stats for future use
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'stats.totalWorkouts': totalWorkouts,
          'stats.totalVolume': totalVolume,
          'stats.lastUpdated': FieldValue.serverTimestamp(),
        });
        if (kDebugMode) {
          debugPrint('✅ Updated user stats in Firebase');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Could not update user stats: $e');
        }
      }
    }

    // For volume increase, we still need recent data (last 30 days)
    // But we can limit the query significantly
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentQuery = await FirebaseFirestore.instance
        .collection('exerciseActivities')
        .where('email', isEqualTo: currentUser.email!.toLowerCase().trim())
        .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .orderBy('createdAt', descending: true)
        .limit(50)  // Only need recent ones for trend
        .get();

    double recentVolume = 0;
    double maxPR = 0;
    String prExercise = 'N/A';

    for (final doc in recentQuery.docs) {
      final data = doc.data();
      final sets = data['sets'] as List<dynamic>? ?? [];

      for (final set in sets) {
        if (set is Map<String, dynamic> && (set['done'] == true || set['isCompleted'] == true)) {
          final weight = (set['weight'] as num?)?.toDouble() ?? 0;
          final reps = (set['reps'] as num?)?.toInt() ?? 0;
          recentVolume += weight * reps;

          // Track max weight for PR
          if (weight > maxPR) {
            maxPR = weight;
            prExercise = data['exerciseName'] as String? ?? 'N/A';
          }
        }
      }
    }

    // Calculate volume increase (simplified)
    final monthlyAverage = totalVolume / (totalWorkouts > 0 ? totalWorkouts : 1) * 4;
    final volumeIncrease = monthlyAverage > 0
        ? ((recentVolume - monthlyAverage) / monthlyAverage * 100)
        : 0;

    return QuickStats(
      totalVolume: totalVolume,
      volumeIncrease: volumeIncrease.toDouble(),
      maxPR: maxPR,
      prExercise: prExercise,
      totalWorkouts: totalWorkouts,
    );
  } catch (e) {
    return QuickStats.empty();
  }
});

/// Optimized workout count using pre-calculated counter
final optimizedWorkoutCountProvider = Provider<int>((ref) {
  final userProfile = ref.watch(cachedUserProfileProvider);

  return userProfile.when(
    data: (profile) {
      final stats = profile?.stats ?? {};
      return stats['totalWorkouts'] as int? ?? 0;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Optimized streak calculation
/// Still needs to query recent activities but with strict limit
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final optimizedStreakProvider = FutureProvider.autoDispose<int>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser?.email == null) {
    return 0;
  }

  // Get last workout date from user stats (cached)
  final userProfile = await ref.read(cachedUserProfileProvider.future);
  final lastWorkoutTimestamp = userProfile?.stats['lastWorkoutDate'];

  // If no last workout date, try to find workouts
  if (lastWorkoutTimestamp == null) {
    if (kDebugMode) {
      debugPrint('⚠️ No lastWorkoutDate in stats, checking for actual workouts...');
    }
  }

  // Only query last 7 days for streak calculation
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

  final query = await FirebaseFirestore.instance
      .collection('exerciseActivities')
      .where('email', isEqualTo: currentUser!.email!.toLowerCase().trim())
      .where('createdAt', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
      .orderBy('createdAt', descending: true)
      .limit(20)  // Max 20 workouts in 7 days is plenty
      .get();

  if (query.docs.isEmpty) return 0;

  // Calculate streak from recent workouts
  final workoutDays = <String>{};
  for (final doc in query.docs) {
    final timestamp = doc.data()['createdAt'] as Timestamp?;
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
      if (streak > 0) break;
    }
  }

  return streak;
});

/// Optimized monthly frequency
/// Uses pre-calculated monthly counter with fallback
/// Alias providers for backwards compatibility
final optimizedCompletedWorkoutsCountProvider = optimizedWorkoutCountProvider;
final optimizedCurrentStreakProvider = optimizedStreakProvider;

/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final optimizedMonthlyFrequencyProvider = FutureProvider.autoDispose<double>((ref) async {
  final userProfile = await ref.watch(cachedUserProfileProvider.future);

  if (userProfile == null) {
    return 0.0;
  }

  final stats = userProfile.stats;
  var monthlyWorkouts = stats['monthlyWorkouts'] as int? ?? 0;

  // FALLBACK: If no monthly count, count from last 30 days
  if (monthlyWorkouts == 0 && stats.isEmpty) {
    if (kDebugMode) {
      debugPrint('⚠️ No monthly workout count, calculating from recent workouts...');
    }

    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser?.email != null) {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final monthQuery = await FirebaseFirestore.instance
          .collection('exerciseActivities')
          .where('email', isEqualTo: currentUser!.email!.toLowerCase().trim())
          .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .limit(100)
          .get();

      monthlyWorkouts = monthQuery.docs.length;
      if (kDebugMode) {
        debugPrint('  - Found $monthlyWorkouts workouts in last 30 days');
      }
    }
  }

  // Convert to weekly average (divide by ~4.3 weeks per month)
  return monthlyWorkouts / 4.3;
});