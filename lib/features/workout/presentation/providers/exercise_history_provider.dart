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
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart'; // Import for hybridExerciseActivityRepositoryProvider
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/last_workout_set_data.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/set_progress_data.dart';

// Service provider (uses Hive local storage for exercise history)
// ✅ PERFORMANCE FIX: Disabled verbose logging to prevent log spam on repeated queries
// Set enableDebugLogging: false to reduce console output during normal operation
// Enable only when debugging specific history issues
final exerciseHistoryServiceProvider = Provider<ExerciseHistoryService>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return ExerciseHistoryService(
    boxManager: boxManager,
    enableDebugLogging: false,
  );
});

// NOTE: exerciseActivityRepositoryProvider is defined in workout_provider.dart (canonical location)
// Do NOT define it here to avoid duplication

// Workout History Service provider (reads from 'workouts' collection)
final workoutHistoryServiceProvider = Provider<WorkoutHistoryService>((ref) {
  return WorkoutHistoryService();
});

// NOTE: hybridExerciseActivityRepositoryProvider is already defined in workout_provider.dart

// Recent weights provider
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
/// ✅ PERFORMANCE FIX: Added keepAlive to cache during session
final recentWeightsProvider = FutureProvider.autoDispose.family<List<double>, String>((
  ref,
  exerciseName,
) async {
  // ✅ CRITICAL FIX: Keep provider alive during session to prevent repeated queries
  ref.keepAlive();

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

    final uid = userState.value?.uid;
    if (uid == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseHistory] recentWeights: No user ID');
      }
      return [];
    }

    final result = await service
        .getRecentWeights(exerciseName, uid, limit: 5)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            if (kDebugMode) {
              debugPrint(
                '⚠️ [ExerciseHistory] recentWeights: Timeout after 10s',
              );
            }
            return <double>[];
          },
        );

    if (kDebugMode) {
      debugPrint(
        '✅ [ExerciseHistory] recentWeights: Found ${result.length} weights for "$exerciseName"',
      );
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
// ✅ PERFORMANCE FIX: Added keepAlive to prevent repeated queries on widget rebuilds
// The autoDispose is kept for memory cleanup on logout, but keepAlive prevents
// disposal during normal widget rebuilds (scroll, expansion, etc.)
final recentWeightsWithDetailsProvider = FutureProvider.family.autoDispose<List<ExerciseHistoryData>, String>((
  ref,
  exerciseName,
) async {
  // ✅ CRITICAL FIX: Keep provider alive during session to prevent repeated queries
  // Without this, every widget rebuild causes provider to re-execute from scratch
  // The provider will still be disposed on logout/app termination
  ref.keepAlive();

  final service = ref.read(exerciseHistoryServiceProvider);

  // Try to get user ID directly from Firebase Auth first
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    // Fallback to provider
    final userState = ref.read(currentUserStateProvider);
    final providerUid = userState.value?.uid;
    if (providerUid == null) {
      if (kDebugMode) {
        debugPrint(
          '[ExerciseHistory] recentWeightsWithDetails: No user ID from Firebase or provider',
        );
      }
      return [];
    }
  }

  final finalUid = uid ?? ref.read(currentUserStateProvider).value?.uid;
  if (finalUid == null) {
    if (kDebugMode) {
      debugPrint(
        '[ExerciseHistory] recentWeightsWithDetails: No user ID available',
      );
    }
    return [];
  }

  if (kDebugMode) {
    debugPrint(
      '[ExerciseHistory] recentWeightsWithDetails: Looking for "$exerciseName" (uid: $finalUid)',
    );
  }

  // First, let's debug what exercise names we have in the database
  final allExerciseNames = await service.getAllExerciseNames(finalUid);
  if (kDebugMode) {
    debugPrint(
      '[ExerciseHistory] recentWeightsWithDetails: Exercise names in DB: ${allExerciseNames.length} total',
    );
  }

  try {
    // Get recent history with more items to have better filtering
    final history = await service.getExerciseHistory(
      exerciseName,
      finalUid,
      limit: 50,
    );
    if (kDebugMode) {
      debugPrint(
        '[ExerciseHistory] recentWeightsWithDetails: Found ${history.length} history items',
      );
    }

    if (history.isEmpty) {
      // Try with variations of the name
      final similarNames = allExerciseNames.where((name) {
        final nameLower = name.toLowerCase();
        final searchLower = exerciseName.toLowerCase();
        return nameLower.contains(searchLower) ||
            searchLower.contains(nameLower);
      }).toList();

      if (similarNames.isNotEmpty && kDebugMode) {
        debugPrint(
          '[ExerciseHistory] recentWeightsWithDetails: Trying ${similarNames.length} similar names',
        );
        // Try with the first similar name
        final alternateHistory = await service.getExerciseHistory(
          similarNames.first,
          finalUid,
          limit: 50,
        );
        if (alternateHistory.isNotEmpty) {
          history.addAll(alternateHistory);
        }
      }
    }

    // Filter weights from last 3 days first
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    final recentWeights = <ExerciseHistoryData>[];

    for (final data in history) {
      if (data.weight != null &&
          data.weight! > 0 &&
          data.date.isAfter(threeDaysAgo)) {
        recentWeights.add(data);
      }
    }

    // If we don't have enough from last 3 days, include all historical weights
    final allWeights = <ExerciseHistoryData>[];
    if (recentWeights.length < 8) {
      // Add recent weights first, then fill with older weights
      allWeights.addAll(recentWeights);

      for (final data in history) {
        if (data.weight != null &&
            data.weight! > 0 &&
            !recentWeights.contains(data)) {
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

        if (uniqueWeights.length >= 8) {
          break; // Increased limit to 8 unique weights
        }
      }
    }

    // Sort the final list by weight descending for display
    final result = uniqueWeights.values.toList()
      ..sort((a, b) => (b.weight ?? 0).compareTo(a.weight ?? 0));

    if (kDebugMode) {
      debugPrint(
        '[ExerciseHistory] recentWeightsWithDetails: Returning ${result.length} unique weights',
      );
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
/// ✅ PERFORMANCE FIX: Added keepAlive to cache during session
final lastExerciseDataProvider = FutureProvider.autoDispose
    .family<({double? weight, DateTime? date}), String>((
      ref,
      exerciseName,
    ) async {
      // ✅ CRITICAL FIX: Keep provider alive during session
      ref.keepAlive();

      try {
        // Input validation
        if (exerciseName.trim().isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] lastExerciseData: Empty exercise name',
            );
          }
          return (weight: null, date: null);
        }

        final service = ref.read(exerciseHistoryServiceProvider);
        final userState = ref.read(currentUserStateProvider);

        final uid = userState.value?.uid;
        if (uid == null) {
          if (kDebugMode) {
            debugPrint('⚠️ [ExerciseHistory] lastExerciseData: No user ID');
          }
          return (weight: null, date: null);
        }

        final result = await service
            .getLastExerciseData(exerciseName, uid)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ [ExerciseHistory] lastExerciseData: Timeout after 10s',
                  );
                }
                return (weight: null, date: null);
              },
            );

        if (kDebugMode && result.weight != null) {
          debugPrint(
            '✅ [ExerciseHistory] lastExerciseData: Found ${result.weight}kg on ${result.date} for "$exerciseName"',
          );
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
final exerciseHistoryProvider = FutureProvider.autoDispose
    .family<List<ExerciseHistoryData>, String>((ref, exerciseName) async {
      try {
        // MIGRATION: Use new workouts-based provider
        final grouped = await ref.watch(
          exerciseHistoryDataGroupedProvider(exerciseName).future,
        );

        // Flatten grouped data to list
        final allHistory = <ExerciseHistoryData>[];
        for (final dayHistory in grouped.values) {
          allHistory.addAll(dayHistory);
        }

        // Sort by date descending
        allHistory.sort((a, b) => b.date.compareTo(a.date));

        if (kDebugMode) {
          debugPrint(
            '✅ [ExerciseHistory] exerciseHistory (MIGRATED): Found ${allHistory.length} entries for "$exerciseName"',
          );
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
final exerciseHistoryGroupedProvider = FutureProvider.autoDispose
    .family<Map<DateTime, List<ExerciseHistoryData>>, String>((
      ref,
      exerciseName,
    ) async {
      try {
        // MIGRATION: Direct redirect to new workouts-based provider
        final result = await ref.watch(
          exerciseHistoryDataGroupedProvider(exerciseName).future,
        );

        if (kDebugMode) {
          debugPrint(
            '✅ [ExerciseHistory] exerciseHistoryGrouped (MIGRATED): Found ${result.length} days for "$exerciseName"',
          );
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
final exerciseActivitiesProvider = FutureProvider.autoDispose
    .family<List<ExerciseActivity>, String>((ref, exerciseName) async {
      try {
        // Input validation
        if (exerciseName.trim().isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseActivities: Empty exercise name',
            );
          }
          return [];
        }

        final repository = ref.read(exerciseActivityRepositoryProvider);
        final firebaseUser = ref.read(firebaseUserProvider).value;

        final userEmail = firebaseUser?.email;
        if (userEmail == null) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseActivities: No user email',
            );
          }
          return [];
        }

        final activities = await repository
            .getActivitiesByExercise(
              userId:
                  userEmail, // ⚠️ Parameter name is userId (expects user ID/email string)
              exerciseName: exerciseName,
              limit: 50,
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ [ExerciseHistory] exerciseActivities: Timeout after 15s',
                  );
                }
                return <ExerciseActivity>[];
              },
            );

        if (kDebugMode) {
          debugPrint(
            '✅ [ExerciseHistory] exerciseActivities: Found ${activities.length} activities',
          );
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
final exerciseActivitiesLocalProvider = FutureProvider.autoDispose
    .family<List<ExerciseActivity>, String>((ref, exerciseName) async {
      try {
        // Input validation
        if (exerciseName.trim().isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseActivitiesLocal: Empty exercise name',
            );
          }
          return [];
        }

        final repository = ref.read(hybridExerciseActivityRepositoryProvider);
        final firebaseUser = ref.read(firebaseUserProvider).value;

        final userEmail = firebaseUser?.email;
        if (userEmail == null) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseActivitiesLocal: No user email',
            );
          }
          return [];
        }

        final activities = await repository
            .getActivitiesByExercise(
              userEmail:
                  userEmail, // HybridExerciseActivityRepository uses userEmail parameter
              exerciseName: exerciseName,
              limit: 50,
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ [ExerciseHistory] exerciseActivitiesLocal: Timeout after 15s',
                  );
                }
                return <ExerciseActivity>[];
              },
            );

        if (kDebugMode) {
          debugPrint(
            '✅ [ExerciseHistory] exerciseActivitiesLocal: Found ${activities.length} activities (LOCAL)',
          );
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
final exerciseActivitiesGroupedProvider = FutureProvider.autoDispose
    .family<Map<DateTime, List<ExerciseActivity>>, String>((
      ref,
      exerciseName,
    ) async {
      try {
        // Input validation
        if (exerciseName.trim().isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseActivitiesGrouped: Empty exercise name',
            );
          }
          return {};
        }

        final activities = await ref.watch(
          exerciseActivitiesProvider(exerciseName).future,
        );

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
          debugPrint(
            '✅ [ExerciseHistory] exerciseActivitiesGrouped: Grouped ${activities.length} activities into ${grouped.length} days',
          );
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
final exerciseHistoryDataGroupedProvider = FutureProvider.autoDispose
    .family<Map<DateTime, List<ExerciseHistoryData>>, String>((
      ref,
      exerciseName,
    ) async {
      try {
        // Input validation
        if (exerciseName.trim().isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseHistoryDataGrouped: Empty exercise name',
            );
          }
          return {};
        }

        // NEW: Use the new workout history service that reads from 'workouts' collection
        final service = ref.read(workoutHistoryServiceProvider);

        // Get UID directly from Firebase Auth (not from provider which might be loading)
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseHistoryDataGrouped: No user UID',
            );
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
          debugPrint(
            '✅ [ExerciseHistory] exerciseHistoryDataGrouped: Found ${historyDataList.length} history items from workouts collection',
          );
        }

        // ✅ FIX: Trigger fallback if new collection has no data (might be incomplete migration)
        if (historyDataList.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] No data in workouts collection, triggering fallback to old collection',
            );
          }
          throw Exception(
            'Empty history from workouts collection, trying fallback',
          );
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
          debugPrint(
            '✅ [ExerciseHistory] exerciseHistoryDataGrouped: Grouped ${historyDataList.length} items into ${grouped.length} days',
          );
        }

        return grouped;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint(
            '❌ [ExerciseHistory] exerciseHistoryDataGrouped error: $e',
          );
          debugPrint('📍 Stack trace: $stackTrace');
        }

        // FALLBACK: Try the old method if new method fails
        if (kDebugMode) {
          debugPrint(
            '🔄 [ExerciseHistory] Falling back to old exerciseActivitiesLocal method...',
          );
        }

        try {
          final activities = await ref.watch(
            exerciseActivitiesLocalProvider(exerciseName).future,
          );

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
              if (setData.done) {
                // Only include completed sets
                final weight = double.tryParse(setData.weight);
                final reps = int.tryParse(setData.actualReps ?? setData.reps);

                historyDataList.add(
                  ExerciseHistoryData(
                    weight: weight,
                    reps: reps,
                    rpe: setData.rpe, // ✅ FIX: Include RPE from set
                    date: activity.createdAt,
                    workoutName:
                        activity.schedaName, // Use schedaName as workoutName
                  ),
                );
              }
            }

            if (historyDataList.isNotEmpty) {
              groupedFallback
                  .putIfAbsent(dateOnly, () => [])
                  .addAll(historyDataList);
            }
          }

          if (kDebugMode) {
            debugPrint(
              '✅ [ExerciseHistory] exerciseHistoryDataGrouped FALLBACK: Converted ${activities.length} activities to ${groupedFallback.length} days',
            );
          }

          return groupedFallback;
        } catch (fallbackError, fallbackStackTrace) {
          if (kDebugMode) {
            debugPrint(
              '❌ [ExerciseHistory] exerciseHistoryDataGrouped FALLBACK error: $fallbackError',
            );
            debugPrint('📍 Stack trace: $fallbackStackTrace');
          }
          return {};
        }
      }
    });

// Exercise stats provider (OLD - uses Hive)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseStatsProvider = FutureProvider.autoDispose
    .family<
      ({
        double? maxWeight,
        int totalSets,
        double avgWeight,
        DateTime? firstWorkout,
        DateTime? lastWorkout,
      }),
      String
    >((ref, exerciseName) async {
      try {
        // Input validation
        if (exerciseName.trim().isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseStats: Empty exercise name',
            );
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

        final uid = userState.value?.uid;
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

        final result = await service
            .getExerciseStats(exerciseName, uid)
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ [ExerciseHistory] exerciseStats: Timeout after 15s',
                  );
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
          debugPrint(
            '✅ [ExerciseHistory] exerciseStats: Stats for "$exerciseName" - max: ${result.maxWeight}kg, sets: ${result.totalSets}',
          );
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
final exerciseStatsFromActivitiesProvider = FutureProvider.autoDispose
    .family<
      ({
        double? maxWeight,
        int totalSets,
        double avgWeight,
        DateTime? firstWorkout,
        DateTime? lastWorkout,
      }),
      String
    >((ref, exerciseName) async {
      try {
        // Input validation
        if (exerciseName.trim().isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseStatsFromActivities: Empty exercise name',
            );
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
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseStatsFromActivities: No user UID',
            );
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
            debugPrint(
              '⚠️ [ExerciseHistory] No data in workouts collection, triggering fallback to old collection',
            );
          }
          throw Exception(
            'Empty history from workouts collection, trying fallback',
          );
        }

        // Calculate stats from history data
        double maxWeight = 0;
        final int totalSets =
            historyDataList.length; // Each history item is a set
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
          debugPrint(
            '✅ [ExerciseHistory] exerciseStatsFromActivities: Stats - max: ${maxWeight}kg, sets: $totalSets, avg: ${avgWeight.toStringAsFixed(1)}kg',
          );
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
          debugPrint(
            '❌ [ExerciseHistory] exerciseStatsFromActivities error: $e',
          );
          debugPrint('📍 Stack trace: $stackTrace');
        }

        // FALLBACK: Try the old method
        if (kDebugMode) {
          debugPrint(
            '🔄 [ExerciseHistory] Falling back to old method for stats...',
          );
        }

        try {
          final activities = await ref.watch(
            exerciseActivitiesLocalProvider(exerciseName).future,
          );

          if (activities.isEmpty) {
            if (kDebugMode) {
              debugPrint(
                '⚠️ [ExerciseHistory] exerciseStatsFromActivities FALLBACK: No activities found',
              );
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
            if (firstWorkout == null ||
                activity.createdAt.isBefore(firstWorkout)) {
              firstWorkout = activity.createdAt;
            }
            if (lastWorkout == null ||
                activity.createdAt.isAfter(lastWorkout)) {
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

          final avgWeight = weightCount > 0
              ? totalWeightSum / weightCount
              : 0.0;

          if (kDebugMode) {
            debugPrint(
              '✅ [ExerciseHistory] exerciseStatsFromActivities FALLBACK: "$exerciseName" - max: ${maxWeight}kg, sets: $totalSets, avg: ${avgWeight.toStringAsFixed(1)}kg',
            );
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
            debugPrint(
              '❌ [ExerciseHistory] exerciseStatsFromActivities FALLBACK error: $fallbackError',
            );
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
final exerciseActivitiesFromWorkoutsProvider = FutureProvider.autoDispose
    .family<List<ExerciseActivity>, String>((ref, exerciseName) async {
      try {
        // Input validation
        if (exerciseName.trim().isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseActivitiesFromWorkouts: Empty exercise name',
            );
          }
          return [];
        }

        final service = ref.read(workoutHistoryServiceProvider);
        final firebaseUser = ref.read(firebaseUserProvider).value;

        final userEmail = firebaseUser?.email;
        if (userEmail == null) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseActivitiesFromWorkouts: No user email',
            );
          }
          return [];
        }

        final activities = await service
            .getActivitiesByExercise(
              userEmail: userEmail,
              exerciseName: exerciseName,
              limit: 50,
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ [ExerciseHistory] exerciseActivitiesFromWorkouts: Timeout after 15s',
                  );
                }
                return <ExerciseActivity>[];
              },
            );

        if (kDebugMode) {
          debugPrint(
            '✅ [ExerciseHistory] exerciseActivitiesFromWorkouts: Found ${activities.length} activities',
          );
        }

        return activities;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint(
            '❌ [ExerciseHistory] exerciseActivitiesFromWorkouts error: $e',
          );
          debugPrint('📍 Stack trace: $stackTrace');
        }
        return [];
      }
    });

/// NEW: Last exercise data provider using workouts collection
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final lastExerciseDataFromWorkoutsProvider = FutureProvider.autoDispose
    .family<({double? weight, DateTime? date}), String>((
      ref,
      exerciseName,
    ) async {
      try {
        // Input validation
        if (exerciseName.trim().isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] lastExerciseDataFromWorkouts: Empty exercise name',
            );
          }
          return (weight: null, date: null);
        }

        final service = ref.read(workoutHistoryServiceProvider);
        final userState = ref.read(currentUserStateProvider);

        final uid = userState.value?.uid;
        if (uid == null) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] lastExerciseDataFromWorkouts: No user ID',
            );
          }
          return (weight: null, date: null);
        }

        final result = await service
            .getLastExerciseData(exerciseName: exerciseName, userId: uid)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ [ExerciseHistory] lastExerciseDataFromWorkouts: Timeout after 10s',
                  );
                }
                return (weight: null, date: null);
              },
            );

        if (kDebugMode && result.weight != null) {
          debugPrint(
            '✅ [ExerciseHistory] lastExerciseDataFromWorkouts: Found ${result.weight}kg on ${result.date}',
          );
        }

        return result;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint(
            '❌ [ExerciseHistory] lastExerciseDataFromWorkouts error: $e',
          );
          debugPrint('📍 Stack trace: $stackTrace');
        }
        return (weight: null, date: null);
      }
    });

/// NEW: Exercise history provider using workouts collection
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseHistoryFromWorkoutsProvider = FutureProvider.autoDispose
    .family<List<ExerciseHistoryData>, String>((ref, exerciseName) async {
      try {
        // Input validation
        if (exerciseName.trim().isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseHistoryFromWorkouts: Empty exercise name',
            );
          }
          return [];
        }

        final service = ref.read(workoutHistoryServiceProvider);

        // Get UID directly from Firebase Auth (not from provider which might be loading)
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] exerciseHistoryFromWorkouts: No user ID',
            );
          }
          return [];
        }

        final result = await service
            .getExerciseHistory(
              exerciseName: exerciseName,
              userId: uid,
              limit: 50,
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ [ExerciseHistory] exerciseHistoryFromWorkouts: Timeout after 15s',
                  );
                }
                return <ExerciseHistoryData>[];
              },
            );

        if (kDebugMode) {
          debugPrint(
            '✅ [ExerciseHistory] exerciseHistoryFromWorkouts: Returned ${result.length} entries',
          );
        }

        return result;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint(
            '❌ [ExerciseHistory] exerciseHistoryFromWorkouts error: $e',
          );
          debugPrint('📍 Stack trace: $stackTrace');
        }
        return [];
      }
    });

/// NEW: Recent weights with details provider using workouts collection
final recentWeightsWithDetailsFromWorkoutsProvider = FutureProvider.family
    .autoDispose<List<ExerciseHistoryData>, String>((ref, exerciseName) async {
      try {
        // Input validation
        if (exerciseName.trim().isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] recentWeightsFromWorkouts: Empty exercise name',
            );
          }
          return [];
        }

        final service = ref.read(workoutHistoryServiceProvider);

        // Try to get user ID directly from Firebase Auth first
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          // Fallback to provider
          final userState = ref.read(currentUserStateProvider);
          final providerUid = userState.value?.uid;
          if (providerUid == null) {
            if (kDebugMode) {
              debugPrint(
                '⚠️ [ExerciseHistory] recentWeightsFromWorkouts: No user ID from Firebase or provider',
              );
            }
            return [];
          }
        }

        final finalUid =
            uid ?? ref.read(currentUserStateProvider).value?.uid;
        if (finalUid == null) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] recentWeightsFromWorkouts: No final user ID',
            );
          }
          return [];
        }
        // Get recent history with more items to have better filtering
        final history = await service
            .getExerciseHistory(
              exerciseName: exerciseName,
              userId: finalUid,
              limit: 50,
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ [ExerciseHistory] recentWeightsFromWorkouts: Timeout after 15s',
                  );
                }
                return <ExerciseHistoryData>[];
              },
            );
        if (history.isEmpty) return [];

        // Filter weights from last 3 days first
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        final recentWeights = <ExerciseHistoryData>[];

        for (final data in history) {
          if (data.weight != null &&
              data.weight! > 0 &&
              data.date.isAfter(threeDaysAgo)) {
            recentWeights.add(data);
          }
        }

        // If we don't have enough from last 3 days, include all historical weights
        final allWeights = <ExerciseHistoryData>[];
        if (recentWeights.length < 8) {
          // Add recent weights first, then fill with older weights
          allWeights.addAll(recentWeights);

          for (final data in history) {
            if (data.weight != null &&
                data.weight! > 0 &&
                !recentWeights.contains(data)) {
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

            if (uniqueWeights.length >= 8) {
              break; // Increased limit to 8 unique weights
            }
          }
        }

        // Sort the final list by weight descending for display
        final result = uniqueWeights.values.toList()
          ..sort((a, b) => (b.weight ?? 0).compareTo(a.weight ?? 0));

        if (kDebugMode) {
          debugPrint(
            '✅ [ExerciseHistory] recentWeightsFromWorkouts: Returning ${result.length} unique weights',
          );
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

// ============================================================================
// FEATURE: Pre-fill Last Workout Data
// ============================================================================

/// Provider to fetch the last completed workout set data for a specific exercise and set number.
/// Used in QuickEditOverlayV2 to show "Last Workout" badge with pre-fill functionality.
///
/// Returns null if no previous workout data exists for this exercise/set combination.
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final lastCompletedWorkoutSetProvider = FutureProvider.family
    .autoDispose<LastWorkoutSetData?, LastWorkoutSetParams>((
      ref,
      params,
    ) async {
      try {
        // Input validation
        if (params.exerciseName.trim().isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] lastCompletedWorkoutSet: Empty exercise name',
            );
          }
          return null;
        }

        if (params.setNumber < 1) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] lastCompletedWorkoutSet: Invalid set number ${params.setNumber}',
            );
          }
          return null;
        }

        final service = ref.read(workoutHistoryServiceProvider);

        // Get UID directly from Firebase Auth
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseHistory] lastCompletedWorkoutSet: No user UID',
            );
          }
          return null;
        }

        // Fetch exercise history from workouts collection
        // We need to find workouts that have this exercise with at least setNumber sets
        final historyDataList = await service
            .getExerciseHistoryWithSetDetails(
              exerciseName: params.exerciseName,
              userId: uid,
              limit: 50, // Get recent workouts to find matching set
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ [ExerciseHistory] lastCompletedWorkoutSet: Timeout after 10s',
                  );
                }
                return <Map<String, dynamic>>[];
              },
            );

        if (historyDataList.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              'ℹ️ [ExerciseHistory] lastCompletedWorkoutSet: No history found for "${params.exerciseName}"',
            );
          }
          return null;
        }

        // Find the most recent workout that has data for the requested set number
        // historyDataList is sorted by date descending (most recent first)
        for (final workoutData in historyDataList) {
          final sets = workoutData['sets'] as List<dynamic>?;
          if (sets == null || sets.length < params.setNumber) continue;

          // Get the specific set (setNumber is 1-based, list is 0-indexed)
          final setData = sets[params.setNumber - 1] as Map<String, dynamic>?;
          if (setData == null) continue;

          // Extract weight and reps from set data
          final weight = _parseDouble(setData['weight']);
          final reps = _parseInt(setData['actualReps'] ?? setData['reps']);

          if (weight == null || reps == null) continue;

          // Parse date
          final dateValue = workoutData['date'];
          DateTime date;
          if (dateValue is DateTime) {
            date = dateValue;
          } else if (dateValue is String) {
            date = DateTime.tryParse(dateValue) ?? DateTime.now();
          } else {
            date = DateTime.now();
          }

          final result = LastWorkoutSetData(
            weight: weight,
            reps: reps,
            rpe: _parseInt(setData['rpe']),
            date: date,
            workoutName: workoutData['workoutName'] as String?,
            setNumber: params.setNumber,
            exerciseName: params.exerciseName,
          );

          if (kDebugMode) {
            debugPrint(
              '✅ [ExerciseHistory] lastCompletedWorkoutSet: Found ${result.weight}kg x ${result.reps} for "${params.exerciseName}" set #${params.setNumber}',
            );
          }

          return result;
        }

        if (kDebugMode) {
          debugPrint(
            'ℹ️ [ExerciseHistory] lastCompletedWorkoutSet: No matching set #${params.setNumber} found for "${params.exerciseName}"',
          );
        }
        return null;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ [ExerciseHistory] lastCompletedWorkoutSet error: $e');
          debugPrint('📍 Stack trace: $stackTrace');
        }
        return null;
      }
    });

/// Helper function to parse double from various types
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Helper function to parse int from various types
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

// =========================================================================
// FEATURE 2: SET PROGRESS PROVIDER
// =========================================================================
// Provides progress comparison data for displaying progress arrows in set rows.
// Compares current weight/reps with the last workout for the same exercise/set.
// =========================================================================

/// Provider that computes progress data for a specific set.
/// Returns SetProgressData comparing current values with the last workout.
final setProgressProvider = FutureProvider.family
    .autoDispose<SetProgressData?, SetProgressParams>((ref, params) async {
      try {
        // Validate inputs
        if (params.exerciseName.isEmpty) {
          if (kDebugMode) {
            debugPrint('📊 setProgressProvider: Empty exercise name');
          }
          return null;
        }

        // Get last workout data for this exercise/set using the existing provider
        final lastWorkoutParams = LastWorkoutSetParams(
          exerciseName: params.exerciseName,
          setNumber: params.setNumber,
        );

        final lastWorkoutData = await ref.watch(
          lastCompletedWorkoutSetProvider(lastWorkoutParams).future,
        );

        if (lastWorkoutData == null) {
          if (kDebugMode) {
            debugPrint(
              '📊 setProgressProvider: No last workout data for '
              '${params.exerciseName} set ${params.setNumber}',
            );
          }
          return null;
        }

        // Create progress data comparing current vs last
        final progressData = SetProgressData(
          currentWeight: params.currentWeight,
          lastWeight: lastWorkoutData.weight,
          currentReps: params.currentReps,
          lastReps: lastWorkoutData.reps,
          lastWorkoutDate: lastWorkoutData.date,
          setNumber: params.setNumber,
          exerciseName: params.exerciseName,
        );

        if (kDebugMode) {
          debugPrint(
            '📊 setProgressProvider: Progress for ${params.exerciseName} '
            'set ${params.setNumber}: '
            '${params.currentWeight}kg → ${lastWorkoutData.weight}kg, '
            '${params.currentReps}reps → ${lastWorkoutData.reps}reps '
            '(${progressData.overallStatus})',
          );
        }

        return progressData;
      } catch (e, stack) {
        if (kDebugMode) {
          debugPrint('❌ setProgressProvider error: $e');
          debugPrint('Stack: $stack');
        }
        return null;
      }
    });

// ============================================================================
// DROPSET VOLUME COMPARISON PROVIDER (Task 3)
// ============================================================================

/// Provider to get the previous dropset volume for comparison
/// Returns the total volume (weight × reps) from the last completed dropset
/// of the same exercise name
final previousDropsetVolumeProvider = FutureProvider.autoDispose
    .family<double?, String>((ref, exerciseName) async {
      try {
        // Clean exercise name for comparison (remove " - Drop Set" suffix if present)
        final cleanName = exerciseName.replaceAll(RegExp(r'\s*-\s*Drop Set$'), '');

        if (cleanName.trim().isEmpty) {
          return null;
        }

        // Get history grouped by date
        final historyGrouped = await ref.watch(
          exerciseHistoryDataGroupedProvider(cleanName).future,
        );

        if (historyGrouped.isEmpty) {
          return null;
        }

        // Get all history entries sorted by date descending
        final allEntries = <ExerciseHistoryData>[];
        for (final dayHistory in historyGrouped.values) {
          allEntries.addAll(dayHistory);
        }
        allEntries.sort((a, b) => b.date.compareTo(a.date));

        // Skip today's entries (we want previous, not current)
        final today = DateTime.now();
        final previousEntries = allEntries.where((e) =>
            e.date.year != today.year ||
            e.date.month != today.month ||
            e.date.day != today.day).toList();

        if (previousEntries.isEmpty) {
          return null;
        }

        // Calculate volume from previous session (same day entries)
        final prevDate = previousEntries.first.date;
        final sameDayEntries = previousEntries.where((e) =>
            e.date.year == prevDate.year &&
            e.date.month == prevDate.month &&
            e.date.day == prevDate.day).toList();

        // Sum up volume (weight × reps for each entry)
        double totalVolume = 0.0;
        for (final entry in sameDayEntries) {
          if (entry.weight != null && entry.reps != null) {
            totalVolume += entry.weight! * entry.reps!;
          }
        }

        if (kDebugMode) {
          debugPrint(
            '📊 [DropsetVolume] Previous volume for "$cleanName": $totalVolume kg '
            '(from ${sameDayEntries.length} entries on $prevDate)',
          );
        }

        return totalVolume > 0 ? totalVolume : null;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ previousDropsetVolumeProvider error: $e');
        }
        return null;
      }
    });
