/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/providers
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: StateNotifierProvider
/// - Exercise History Service
library;

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/workout_history_service.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/user_provider_v2.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart'; // Import for hybridExerciseActivityRepositoryProvider
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

// Service provider (OLD - uses Hive local storage)
final exerciseHistoryServiceProvider = Provider<ExerciseHistoryService>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return ExerciseHistoryService(boxManager: boxManager, enableDebugLogging: true);
});

// Repository provider (OLD - uses only Firestore)
final exerciseActivityRepositoryProvider = Provider<ExerciseActivityRepository>((ref) {
  return ExerciseActivityRepository();
});

// NEW: Workout History Service provider (reads from 'workouts' collection)
final workoutHistoryServiceProvider = Provider<WorkoutHistoryService>((ref) {
  return WorkoutHistoryService();
});

// NOTE: hybridExerciseActivityRepositoryProvider is already defined in workout_provider.dart

// Recent weights provider
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final recentWeightsProvider = FutureProvider.autoDispose.family<List<double>, String>((ref, exerciseName) async {
  try {
    // Input validation
    if (exerciseName.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] recentWeights: Empty exercise name');
      }
      return [];
    }

    final service = ref.read(exerciseHistoryServiceProvider);
    final userState = ref.read(currentUserStateProvider);

    final uid = userState.profileOrNull?.uid;
    if (uid == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] recentWeights: No user ID');
      }
      return [];
    }

    final result = await service.getRecentWeights(exerciseName, uid, limit: 5)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            if (kDebugMode) {
              debugPrint('⚠️ [ExerciseHistory] recentWeights: Timeout after 10s');
            }
            return <double>[];
          },
        );

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] recentWeights: Found ${result.length} weights for "$exerciseName"');
    }

    return result;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] recentWeights error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    return [];
  }
});

// Recent weights with details provider (weight, reps, date)
// SYNC FIX: Added autoDispose to ensure fresh data when analytics refresh
// Updated to filter by last 3 days and show 6-8 weights
final recentWeightsWithDetailsProvider = FutureProvider.family.autoDispose<List<ExerciseHistoryData>, String>((ref, exerciseName) async {
  final service = ref.read(exerciseHistoryServiceProvider);
  
  // Try to get user ID directly from Firebase Auth first
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    // Fallback to provider
    final userState = ref.read(currentUserStateProvider);
    final providerUid = userState.profileOrNull?.uid;
    if (providerUid == null) {
      if (kDebugMode) {
        debugPrint('[ExerciseHistory] recentWeightsWithDetails: No user ID from Firebase or provider');
      }
      return [];
    }
  }
  
  final finalUid = uid ?? ref.read(currentUserStateProvider).profileOrNull?.uid;
  if (finalUid == null) {
    if (kDebugMode) {
      debugPrint('[ExerciseHistory] recentWeightsWithDetails: No user ID available');
    }
    return [];
  }

  if (kDebugMode) {
    debugPrint('[ExerciseHistory] recentWeightsWithDetails: Looking for "$exerciseName" (uid: $finalUid)');
  }

  // First, let's debug what exercise names we have in the database
  final allExerciseNames = await service.getAllExerciseNames(finalUid);
  if (kDebugMode) {
    debugPrint('[ExerciseHistory] recentWeightsWithDetails: Exercise names in DB: ${allExerciseNames.length} total');
  }
  
  try {
    // Get recent history with more items to have better filtering
    final history = await service.getExerciseHistory(exerciseName, finalUid, limit: 50);
    if (kDebugMode) {
      debugPrint('[ExerciseHistory] recentWeightsWithDetails: Found ${history.length} history items');
    }

    if (history.isEmpty) {
      // Try with variations of the name
      final similarNames = allExerciseNames.where((name) {
        final nameLower = name.toLowerCase();
        final searchLower = exerciseName.toLowerCase();
        return nameLower.contains(searchLower) || searchLower.contains(nameLower);
      }).toList();

      if (similarNames.isNotEmpty && kDebugMode) {
        debugPrint('[ExerciseHistory] recentWeightsWithDetails: Trying ${similarNames.length} similar names');
        // Try with the first similar name
        final alternateHistory = await service.getExerciseHistory(similarNames.first, finalUid, limit: 50);
        if (alternateHistory.isNotEmpty) {
          history.addAll(alternateHistory);
        }
      }
    }
    
    // Filter weights from last 3 days first
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    final recentWeights = <ExerciseHistoryData>[];

    for (final data in history) {
      if (data.weight != null && data.weight! > 0 && data.date.isAfter(threeDaysAgo)) {
        recentWeights.add(data);
      }
    }

    // If we don't have enough from last 3 days, include all historical weights
    final allWeights = <ExerciseHistoryData>[];
    if (recentWeights.length < 8) {
      // Add recent weights first, then fill with older weights
      allWeights.addAll(recentWeights);

      for (final data in history) {
        if (data.weight != null && data.weight! > 0 && !recentWeights.contains(data)) {
          allWeights.add(data);
          if (allWeights.length >= 20) break; // Limit total consideration
        }
      }
    } else {
      allWeights.addAll(recentWeights);
    }
    
    // Sort by weight descending (heaviest first)
    allWeights.sort((a, b) => (b.weight ?? 0).compareTo(a.weight ?? 0));

    // Get unique weights, prioritizing heavier weights
    final uniqueWeights = <double, ExerciseHistoryData>{};
    final seenWeights = <double>{};

    for (final data in allWeights) {
      final weight = data.weight!;

      // Skip if we already have this weight or a very similar one (within 2.5kg)
      bool tooSimilar = false;
      for (final seen in seenWeights) {
        if ((weight - seen).abs() < 2.5) {
          tooSimilar = true;
          break;
        }
      }

      if (!tooSimilar && !uniqueWeights.containsKey(weight)) {
        uniqueWeights[weight] = data;
        seenWeights.add(weight);

        if (uniqueWeights.length >= 8) break; // Increased limit to 8 unique weights
      }
    }

    // Sort the final list by weight descending for display
    final result = uniqueWeights.values.toList()
      ..sort((a, b) => (b.weight ?? 0).compareTo(a.weight ?? 0));

    if (kDebugMode) {
      debugPrint('[ExerciseHistory] recentWeightsWithDetails: Returning ${result.length} unique weights');
    }
    return result;
  } catch (e, stack) {
    debugPrint('❌ [ExerciseHistory] recentWeightsWithDetails error: $e');
    if (kDebugMode) {
      debugPrint('Stack: $stack');
    }
    return [];
  }
});

// Last exercise data provider
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final lastExerciseDataProvider = FutureProvider.autoDispose.family<({double? weight, DateTime? date}), String>((ref, exerciseName) async {
  try {
    // Input validation
    if (exerciseName.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] lastExerciseData: Empty exercise name');
      }
      return (weight: null, date: null);
    }

    final service = ref.read(exerciseHistoryServiceProvider);
    final userState = ref.read(currentUserStateProvider);

    final uid = userState.profileOrNull?.uid;
    if (uid == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] lastExerciseData: No user ID');
      }
      return (weight: null, date: null);
    }

    final result = await service.getLastExerciseData(exerciseName, uid)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            if (kDebugMode) {
              debugPrint('⚠️ [ExerciseHistory] lastExerciseData: Timeout after 10s');
            }
            return (weight: null, date: null);
          },
        );

    if (kDebugMode && result.weight != null) {
      debugPrint('✅ [ExerciseHistory] lastExerciseData: Found ${result.weight}kg on ${result.date} for "$exerciseName"');
    }

    return result;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] lastExerciseData error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    return (weight: null, date: null);
  }
});

/// ⚠️ MIGRATED: Now reads from 'workouts' collection instead of Hive
/// Redirects to exerciseHistoryDataGroupedProvider which uses WorkoutHistoryService
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseHistoryProvider = FutureProvider.autoDispose.family<List<ExerciseHistoryData>, String>((ref, exerciseName) async {
  try {
    // MIGRATION: Use new workouts-based provider
    final grouped = await ref.watch(exerciseHistoryDataGroupedProvider(exerciseName).future);

    // Flatten grouped data to list
    final allHistory = <ExerciseHistoryData>[];
    for (final dayHistory in grouped.values) {
      allHistory.addAll(dayHistory);
    }

    // Sort by date descending
    allHistory.sort((a, b) => b.date.compareTo(a.date));

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] exerciseHistory (MIGRATED): Found ${allHistory.length} entries for "$exerciseName"');
    }

    return allHistory;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] exerciseHistory error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    return [];
  }
});

/// ⚠️ MIGRATED: Now reads from 'workouts' collection instead of Hive
/// Redirects to exerciseHistoryDataGroupedProvider which uses WorkoutHistoryService
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseHistoryGroupedProvider = FutureProvider.autoDispose.family<Map<DateTime, List<ExerciseHistoryData>>, String>((ref, exerciseName) async {
  try {
    // MIGRATION: Direct redirect to new workouts-based provider
    final result = await ref.watch(exerciseHistoryDataGroupedProvider(exerciseName).future);

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] exerciseHistoryGrouped (MIGRATED): Found ${result.length} days for "$exerciseName"');
    }

    return result;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] exerciseHistoryGrouped error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    return {};
  }
});

// OLD: Exercise activities provider using only Firestore
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseActivitiesProvider = FutureProvider.autoDispose.family<List<ExerciseActivity>, String>((ref, exerciseName) async {
  try {
    // Input validation
    if (exerciseName.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseActivities: Empty exercise name');
      }
      return [];
    }

    final repository = ref.read(exerciseActivityRepositoryProvider);
    final firebaseUser = ref.read(firebaseUserProvider).value;

    final userEmail = firebaseUser?.email;
    if (userEmail == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseActivities: No user email');
      }
      return [];
    }

    final activities = await repository.getActivitiesByExercise(
      userEmail: userEmail,
      exerciseName: exerciseName,
      limit: 50,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        if (kDebugMode) {
          debugPrint('⚠️ [ExerciseHistory] exerciseActivities: Timeout after 15s');
        }
        return <ExerciseActivity>[];
      },
    );

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] exerciseActivities: Found ${activities.length} activities');
    }

    return activities;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] exerciseActivities error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    return [];
  }
});

// NEW: Exercise activities provider using LOCAL FIRST (hybrid approach)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseActivitiesLocalProvider = FutureProvider.autoDispose.family<List<ExerciseActivity>, String>((ref, exerciseName) async {
  try {
    // Input validation
    if (exerciseName.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseActivitiesLocal: Empty exercise name');
      }
      return [];
    }

    final repository = ref.read(hybridExerciseActivityRepositoryProvider);
    final firebaseUser = ref.read(firebaseUserProvider).value;

    final userEmail = firebaseUser?.email;
    if (userEmail == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseActivitiesLocal: No user email');
      }
      return [];
    }

    final activities = await repository.getActivitiesByExercise(
      userEmail: userEmail,
      exerciseName: exerciseName,
      limit: 50,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        if (kDebugMode) {
          debugPrint('⚠️ [ExerciseHistory] exerciseActivitiesLocal: Timeout after 15s');
        }
        return <ExerciseActivity>[];
      },
    );

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] exerciseActivitiesLocal: Found ${activities.length} activities (LOCAL)');
    }

    return activities;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] exerciseActivitiesLocal error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    return [];
  }
});

// NEW: Exercise activities grouped by date
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseActivitiesGroupedProvider = FutureProvider.autoDispose.family<Map<DateTime, List<ExerciseActivity>>, String>((ref, exerciseName) async {
  try {
    // Input validation
    if (exerciseName.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseActivitiesGrouped: Empty exercise name');
      }
      return {};
    }

    final activities = await ref.watch(exerciseActivitiesProvider(exerciseName).future);

    // Group activities by date
    final Map<DateTime, List<ExerciseActivity>> grouped = {};

    for (final activity in activities) {
      final dateOnly = DateTime(
        activity.createdAt.year,
        activity.createdAt.month,
        activity.createdAt.day,
      );

      grouped.putIfAbsent(dateOnly, () => []).add(activity);
    }

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] exerciseActivitiesGrouped: Grouped ${activities.length} activities into ${grouped.length} days');
    }

    return grouped;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] exerciseActivitiesGrouped error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    return {};
  }
});

// NEW: Convert ExerciseActivity to ExerciseHistoryData format (using NEW WORKOUTS collection)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseHistoryDataGroupedProvider = FutureProvider.autoDispose.family<Map<DateTime, List<ExerciseHistoryData>>, String>((ref, exerciseName) async {
  try {
    // Input validation
    if (exerciseName.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseHistoryDataGrouped: Empty exercise name');
      }
      return {};
    }

    // NEW: Use the new workout history service that reads from 'workouts' collection
    final service = ref.read(workoutHistoryServiceProvider);

    // Get UID directly from Firebase Auth (not from provider which might be loading)
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseHistoryDataGrouped: No user UID');
      }
      return {};
    }

    // Fetch history data from new 'workouts' collection
    final historyDataList = await service.getExerciseHistory(
      exerciseName: exerciseName,
      userId: uid,
      limit: 100,
    );

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] exerciseHistoryDataGrouped: Found ${historyDataList.length} history items from workouts collection');
    }

    // ✅ FIX: Trigger fallback if new collection has no data (might be incomplete migration)
    if (historyDataList.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] No data in workouts collection, triggering fallback to old collection');
      }
      throw Exception('Empty history from workouts collection, trying fallback');
    }

    // Group by date
    final Map<DateTime, List<ExerciseHistoryData>> grouped = {};

    for (final historyData in historyDataList) {
      final dateOnly = DateTime(
        historyData.date.year,
        historyData.date.month,
        historyData.date.day,
      );

      grouped.putIfAbsent(dateOnly, () => []).add(historyData);
    }

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] exerciseHistoryDataGrouped: Grouped ${historyDataList.length} items into ${grouped.length} days');
    }

    return grouped;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] exerciseHistoryDataGrouped error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }

    // FALLBACK: Try the old method if new method fails
    if (kDebugMode) {
      debugPrint('🔄 [ExerciseHistory] Falling back to old exerciseActivitiesLocal method...');
    }

    try {
      final activities = await ref.watch(exerciseActivitiesLocalProvider(exerciseName).future);

      // Convert activities to ExerciseHistoryData and group by date
      final Map<DateTime, List<ExerciseHistoryData>> groupedFallback = {};

      for (final activity in activities) {
        final dateOnly = DateTime(
          activity.createdAt.year,
          activity.createdAt.month,
          activity.createdAt.day,
        );

        // Convert each set to ExerciseHistoryData
        final historyDataList = <ExerciseHistoryData>[];

        for (final setData in activity.sets) {
          if (setData.done) { // Only include completed sets
            final weight = double.tryParse(setData.weight);
            final reps = int.tryParse(setData.actualReps ?? setData.reps);

            historyDataList.add(ExerciseHistoryData(
              weight: weight,
              reps: reps,
              date: activity.createdAt,
              workoutName: activity.schedaName, // Use schedaName as workoutName
            ));
          }
        }

        if (historyDataList.isNotEmpty) {
          groupedFallback.putIfAbsent(dateOnly, () => []).addAll(historyDataList);
        }
      }

      if (kDebugMode) {
        debugPrint('✅ [ExerciseHistory] exerciseHistoryDataGrouped FALLBACK: Converted ${activities.length} activities to ${groupedFallback.length} days');
      }

      return groupedFallback;
    } catch (fallbackError, fallbackStackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [ExerciseHistory] exerciseHistoryDataGrouped FALLBACK error: $fallbackError');
        debugPrint('📍 Stack trace: $fallbackStackTrace');
      }
      return {};
    }
  }
});

// Exercise stats provider (OLD - uses Hive)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseStatsProvider = FutureProvider.autoDispose.family<({
  double? maxWeight,
  int totalSets,
  double avgWeight,
  DateTime? firstWorkout,
  DateTime? lastWorkout,
}), String>((ref, exerciseName) async {
  try {
    // Input validation
    if (exerciseName.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseStats: Empty exercise name');
      }
      return (
        maxWeight: null,
        totalSets: 0,
        avgWeight: 0.0,
        firstWorkout: null,
        lastWorkout: null,
      );
    }

    final service = ref.read(exerciseHistoryServiceProvider);
    final userState = ref.read(currentUserStateProvider);

    final uid = userState.profileOrNull?.uid;
    if (uid == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseStats: No user ID');
      }
      return (
        maxWeight: null,
        totalSets: 0,
        avgWeight: 0.0,
        firstWorkout: null,
        lastWorkout: null,
      );
    }

    final result = await service.getExerciseStats(exerciseName, uid)
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            if (kDebugMode) {
              debugPrint('⚠️ [ExerciseHistory] exerciseStats: Timeout after 15s');
            }
            return (
              maxWeight: null,
              totalSets: 0,
              avgWeight: 0.0,
              firstWorkout: null,
              lastWorkout: null,
            );
          },
        );

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] exerciseStats: Stats for "$exerciseName" - max: ${result.maxWeight}kg, sets: ${result.totalSets}');
    }

    return result;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] exerciseStats error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    return (
      maxWeight: null,
      totalSets: 0,
      avgWeight: 0.0,
      firstWorkout: null,
      lastWorkout: null,
    );
  }
});

// NEW: Exercise stats provider using NEW WORKOUTS collection
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseStatsFromActivitiesProvider = FutureProvider.autoDispose.family<({
  double? maxWeight,
  int totalSets,
  double avgWeight,
  DateTime? firstWorkout,
  DateTime? lastWorkout,
}), String>((ref, exerciseName) async {
  try {
    // Input validation
    if (exerciseName.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseStatsFromActivities: Empty exercise name');
      }
      return (
        maxWeight: null,
        totalSets: 0,
        avgWeight: 0.0,
        firstWorkout: null,
        lastWorkout: null,
      );
    }

    // NEW: Use the new workout history service that reads from 'workouts' collection
    final service = ref.read(workoutHistoryServiceProvider);

    // Get UID directly from Firebase Auth
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseStatsFromActivities: No user UID');
      }
      return (
        maxWeight: null,
        totalSets: 0,
        avgWeight: 0.0,
        firstWorkout: null,
        lastWorkout: null,
      );
    }

    // Fetch history data from new 'workouts' collection
    final historyDataList = await service.getExerciseHistory(
      exerciseName: exerciseName,
      userId: uid,
      limit: 100,
    );

    // ✅ FIX: Trigger fallback if new collection has no data (might be incomplete migration)
    if (historyDataList.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] No data in workouts collection, triggering fallback to old collection');
      }
      throw Exception('Empty history from workouts collection, trying fallback');
    }

    // Calculate stats from history data
    double maxWeight = 0;
    final int totalSets = historyDataList.length; // Each history item is a set
    double totalWeightSum = 0;
    int weightCount = 0;
    DateTime? firstWorkout;
    DateTime? lastWorkout;

    for (final historyData in historyDataList) {
      // Update first/last workout dates
      if (firstWorkout == null || historyData.date.isBefore(firstWorkout)) {
        firstWorkout = historyData.date;
      }
      if (lastWorkout == null || historyData.date.isAfter(lastWorkout)) {
        lastWorkout = historyData.date;
      }

      // Calculate weight stats
      final weight = historyData.weight;
      if (weight != null && weight > 0) {
        if (weight > maxWeight) {
          maxWeight = weight;
        }
        totalWeightSum += weight;
        weightCount++;
      }
    }

    final avgWeight = weightCount > 0 ? totalWeightSum / weightCount : 0.0;

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] exerciseStatsFromActivities: Stats - max: ${maxWeight}kg, sets: $totalSets, avg: ${avgWeight.toStringAsFixed(1)}kg');
    }

    return (
      maxWeight: maxWeight > 0 ? maxWeight : null,
      totalSets: totalSets,
      avgWeight: avgWeight,
      firstWorkout: firstWorkout,
      lastWorkout: lastWorkout,
    );
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] exerciseStatsFromActivities error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }

    // FALLBACK: Try the old method
    if (kDebugMode) {
      debugPrint('🔄 [ExerciseHistory] Falling back to old method for stats...');
    }

    try {
      final activities = await ref.watch(exerciseActivitiesLocalProvider(exerciseName).future);

      if (activities.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ [ExerciseHistory] exerciseStatsFromActivities FALLBACK: No activities found');
        }
        return (
          maxWeight: null,
          totalSets: 0,
          avgWeight: 0.0,
          firstWorkout: null,
          lastWorkout: null,
        );
      }

      // Calculate stats from activities
      double maxWeight = 0;
      int totalSets = 0;
      double totalWeightSum = 0;
      int weightCount = 0;
      DateTime? firstWorkout;
      DateTime? lastWorkout;

      for (final activity in activities) {
        // Update first/last workout dates
        if (firstWorkout == null || activity.createdAt.isBefore(firstWorkout)) {
          firstWorkout = activity.createdAt;
        }
        if (lastWorkout == null || activity.createdAt.isAfter(lastWorkout)) {
          lastWorkout = activity.createdAt;
        }

        // Calculate weight stats from sets
        for (final set in activity.sets) {
          if (set.done) {
            totalSets++;

            final weight = double.tryParse(set.weight);
            if (weight != null && weight > 0) {
              if (weight > maxWeight) {
                maxWeight = weight;
              }
              totalWeightSum += weight;
              weightCount++;
            }
          }
        }
      }

      final avgWeight = weightCount > 0 ? totalWeightSum / weightCount : 0.0;

      if (kDebugMode) {
        debugPrint('✅ [ExerciseHistory] exerciseStatsFromActivities FALLBACK: "$exerciseName" - max: ${maxWeight}kg, sets: $totalSets, avg: ${avgWeight.toStringAsFixed(1)}kg');
      }

      return (
        maxWeight: maxWeight > 0 ? maxWeight : null,
        totalSets: totalSets,
        avgWeight: avgWeight,
        firstWorkout: firstWorkout,
        lastWorkout: lastWorkout,
      );
    } catch (fallbackError, fallbackStackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [ExerciseHistory] exerciseStatsFromActivities FALLBACK error: $fallbackError');
        debugPrint('📍 Stack trace: $fallbackStackTrace');
      }
      return (
        maxWeight: null,
        totalSets: 0,
        avgWeight: 0.0,
        firstWorkout: null,
        lastWorkout: null,
      );
    }
  }
});

// ============================================================================
// NEW PROVIDERS - Read from 'workouts' collection after migration
// ============================================================================

/// NEW: Exercise activities provider using workouts collection
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseActivitiesFromWorkoutsProvider = FutureProvider.autoDispose.family<List<ExerciseActivity>, String>((ref, exerciseName) async {
  try {
    // Input validation
    if (exerciseName.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseActivitiesFromWorkouts: Empty exercise name');
      }
      return [];
    }

    final service = ref.read(workoutHistoryServiceProvider);
    final firebaseUser = ref.read(firebaseUserProvider).value;

    final userEmail = firebaseUser?.email;
    if (userEmail == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseActivitiesFromWorkouts: No user email');
      }
      return [];
    }

    final activities = await service.getActivitiesByExercise(
      userEmail: userEmail,
      exerciseName: exerciseName,
      limit: 50,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        if (kDebugMode) {
          debugPrint('⚠️ [ExerciseHistory] exerciseActivitiesFromWorkouts: Timeout after 15s');
        }
        return <ExerciseActivity>[];
      },
    );

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] exerciseActivitiesFromWorkouts: Found ${activities.length} activities');
    }

    return activities;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] exerciseActivitiesFromWorkouts error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    return [];
  }
});

/// NEW: Last exercise data provider using workouts collection
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final lastExerciseDataFromWorkoutsProvider = FutureProvider.autoDispose.family<({double? weight, DateTime? date}), String>((ref, exerciseName) async {
  try {
    // Input validation
    if (exerciseName.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] lastExerciseDataFromWorkouts: Empty exercise name');
      }
      return (weight: null, date: null);
    }

    final service = ref.read(workoutHistoryServiceProvider);
    final userState = ref.read(currentUserStateProvider);

    final uid = userState.profileOrNull?.uid;
    if (uid == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] lastExerciseDataFromWorkouts: No user ID');
      }
      return (weight: null, date: null);
    }

    final result = await service.getLastExerciseData(exerciseName: exerciseName, userId: uid)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            if (kDebugMode) {
              debugPrint('⚠️ [ExerciseHistory] lastExerciseDataFromWorkouts: Timeout after 10s');
            }
            return (weight: null, date: null);
          },
        );

    if (kDebugMode && result.weight != null) {
      debugPrint('✅ [ExerciseHistory] lastExerciseDataFromWorkouts: Found ${result.weight}kg on ${result.date}');
    }

    return result;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] lastExerciseDataFromWorkouts error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    return (weight: null, date: null);
  }
});

/// NEW: Exercise history provider using workouts collection
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseHistoryFromWorkoutsProvider = FutureProvider.autoDispose.family<List<ExerciseHistoryData>, String>((ref, exerciseName) async {
  try {
    // Input validation
    if (exerciseName.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseHistoryFromWorkouts: Empty exercise name');
      }
      return [];
    }

    final service = ref.read(workoutHistoryServiceProvider);

    // Get UID directly from Firebase Auth (not from provider which might be loading)
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] exerciseHistoryFromWorkouts: No user ID');
      }
      return [];
    }

    final result = await service.getExerciseHistory(exerciseName: exerciseName, userId: uid, limit: 50)
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            if (kDebugMode) {
              debugPrint('⚠️ [ExerciseHistory] exerciseHistoryFromWorkouts: Timeout after 15s');
            }
            return <ExerciseHistoryData>[];
          },
        );

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] exerciseHistoryFromWorkouts: Returned ${result.length} entries');
    }

    return result;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] exerciseHistoryFromWorkouts error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    return [];
  }
});

/// NEW: Recent weights with details provider using workouts collection
final recentWeightsWithDetailsFromWorkoutsProvider = FutureProvider.family.autoDispose<List<ExerciseHistoryData>, String>((ref, exerciseName) async {
  try {
    // Input validation
    if (exerciseName.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] recentWeightsFromWorkouts: Empty exercise name');
      }
      return [];
    }

    final service = ref.read(workoutHistoryServiceProvider);

    // Try to get user ID directly from Firebase Auth first
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // Fallback to provider
      final userState = ref.read(currentUserStateProvider);
      final providerUid = userState.profileOrNull?.uid;
      if (providerUid == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [ExerciseHistory] recentWeightsFromWorkouts: No user ID from Firebase or provider');
        }
        return [];
      }
    }

    final finalUid = uid ?? ref.read(currentUserStateProvider).profileOrNull?.uid;
    if (finalUid == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] recentWeightsFromWorkouts: No final user ID');
      }
      return [];
    }
    // Get recent history with more items to have better filtering
    final history = await service.getExerciseHistory(exerciseName: exerciseName, userId: finalUid, limit: 50)
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            if (kDebugMode) {
              debugPrint('⚠️ [ExerciseHistory] recentWeightsFromWorkouts: Timeout after 15s');
            }
            return <ExerciseHistoryData>[];
          },
        );
    if (history.isEmpty) return [];

    // Filter weights from last 3 days first
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    final recentWeights = <ExerciseHistoryData>[];

    for (final data in history) {
      if (data.weight != null && data.weight! > 0 && data.date.isAfter(threeDaysAgo)) {
        recentWeights.add(data);
      }
    }

    // If we don't have enough from last 3 days, include all historical weights
    final allWeights = <ExerciseHistoryData>[];
    if (recentWeights.length < 8) {
      // Add recent weights first, then fill with older weights
      allWeights.addAll(recentWeights);

      for (final data in history) {
        if (data.weight != null && data.weight! > 0 && !recentWeights.contains(data)) {
          allWeights.add(data);
          if (allWeights.length >= 20) break; // Limit total consideration
        }
      }
    } else {
      allWeights.addAll(recentWeights);
    }

    // Sort by weight descending (heaviest first)
    allWeights.sort((a, b) => (b.weight ?? 0).compareTo(a.weight ?? 0));

    // Get unique weights, prioritizing heavier weights
    final uniqueWeights = <double, ExerciseHistoryData>{};
    final seenWeights = <double>{};

    for (final data in allWeights) {
      final weight = data.weight!;

      // Skip if we already have this weight or a very similar one (within 2.5kg)
      bool tooSimilar = false;
      for (final seen in seenWeights) {
        if ((weight - seen).abs() < 2.5) {
          tooSimilar = true;
          break;
        }
      }

      if (!tooSimilar && !uniqueWeights.containsKey(weight)) {
        uniqueWeights[weight] = data;
        seenWeights.add(weight);

        if (uniqueWeights.length >= 8) break; // Increased limit to 8 unique weights
      }
    }

    // Sort the final list by weight descending for display
    final result = uniqueWeights.values.toList()
      ..sort((a, b) => (b.weight ?? 0).compareTo(a.weight ?? 0));

    if (kDebugMode) {
      debugPrint('✅ [ExerciseHistory] recentWeightsFromWorkouts: Returning ${result.length} unique weights');
    }
    return result;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseHistory] recentWeightsFromWorkouts error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    return [];
  }
});