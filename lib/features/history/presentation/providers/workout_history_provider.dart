/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: history
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Riverpod provider for workout history state management
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/sync_status.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

/// Provider for the enhanced workout history repository
final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepositoryEnhanced>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return WorkoutHistoryRepositoryEnhanced(boxManager: boxManager);
});

/// Provider for workout history list with real-time updates
final workoutHistoryProvider = StreamProvider<List<WorkoutHistoryDetail>>((ref) async* {
  final repository = ref.watch(workoutHistoryRepositoryProvider);

  await for (final result in repository.getWorkoutsStream()) {
    yield result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('❌ [WorkoutHistoryProvider] Stream error: ${failure.message}');
        }
        throw Exception(failure.message);
      },
      (workouts) {
        if (kDebugMode) {
          debugPrint('✅ [WorkoutHistoryProvider] Stream updated with ${workouts.length} workouts');
        }
        return workouts;
      },
    );
  }
});

/// Provider for sync status
final workoutHistorySyncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final repository = ref.watch(workoutHistoryRepositoryProvider);
  return repository.syncStatusStream;
});

/// Provider for current sync status value
final currentSyncStatusProvider = Provider<SyncStatus>((ref) {
  final repository = ref.watch(workoutHistoryRepositoryProvider);
  return repository.currentSyncStatus;
});

/// Provider for workout history operations (update, delete, force sync)
final workoutHistoryOperationsProvider = Provider<WorkoutHistoryOperations>((ref) {
  final repository = ref.watch(workoutHistoryRepositoryProvider);
  return WorkoutHistoryOperations(repository);
});

/// Class to handle workout history operations
class WorkoutHistoryOperations {

  WorkoutHistoryOperations(this._repository);
  final WorkoutHistoryRepositoryEnhanced _repository;

  /// Update a workout
  Future<Either<Failure, void>> updateWorkout(WorkoutHistoryDetail workout) {
    return _repository.updateWorkout(workout);
  }

  /// Delete a workout
  Future<Either<Failure, void>> deleteWorkout(String workoutId) {
    return _repository.deleteWorkout(workoutId);
  }

  /// Force sync with Firebase
  Future<void> forceSync() {
    return _repository.forceSync();
  }

  /// Clear local cache
  Future<void> clearCache() {
    return _repository.clearCache();
  }
}

/// Utility provider for filtered workouts based on search/date
final filteredWorkoutHistoryProvider = Provider.family<List<WorkoutHistoryDetail>, WorkoutHistoryFilter>((ref, filter) {
  final workoutsAsync = ref.watch(workoutHistoryProvider);

  return workoutsAsync.when(
    loading: () => [],
    error: (error, stack) {
      if (kDebugMode) {
        debugPrint('❌ [FilteredWorkoutHistory] Error loading workouts: $error');
      }
      return [];
    },
    data: (workouts) {
      try {
        var filtered = workouts;

        // Apply search filter
        if (filter.searchQuery.isNotEmpty) {
          filtered = filtered.where((workout) {
            try {
              return workout.name.toLowerCase().contains(filter.searchQuery.toLowerCase()) ||
                workout.exercises.any((exercise) =>
                  exercise.name.toLowerCase().contains(filter.searchQuery.toLowerCase())
                );
            } catch (e) {
              if (kDebugMode) {
                debugPrint('⚠️ [FilteredWorkoutHistory] Error filtering workout ${workout.id}: $e');
              }
              return false; // Exclude workouts that cause errors
            }
          }).toList();
        }

        // Apply date range filter
        if (filter.startDate != null) {
          filtered = filtered.where((workout) {
            try {
              return workout.completedAt.isAfter(filter.startDate!);
            } catch (e) {
              if (kDebugMode) {
                debugPrint('⚠️ [FilteredWorkoutHistory] Error checking start date for workout ${workout.id}: $e');
              }
              return false;
            }
          }).toList();
        }

        if (filter.endDate != null) {
          filtered = filtered.where((workout) {
            try {
              return workout.completedAt.isBefore(filter.endDate!);
            } catch (e) {
              if (kDebugMode) {
                debugPrint('⚠️ [FilteredWorkoutHistory] Error checking end date for workout ${workout.id}: $e');
              }
              return false;
            }
          }).toList();
        }

        // Apply sorting with error handling
        try {
          switch (filter.sortBy) {
            case WorkoutSortOption.dateDesc:
              filtered.sort((a, b) => b.completedAt.compareTo(a.completedAt));
              break;
            case WorkoutSortOption.dateAsc:
              filtered.sort((a, b) => a.completedAt.compareTo(b.completedAt));
              break;
            case WorkoutSortOption.name:
              filtered.sort((a, b) => a.name.compareTo(b.name));
              break;
            case WorkoutSortOption.duration:
              filtered.sort((a, b) => b.duration.compareTo(a.duration));
              break;
            case WorkoutSortOption.volume:
              filtered.sort((a, b) => b.totalVolume.compareTo(a.totalVolume));
              break;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ [FilteredWorkoutHistory] Error sorting workouts: $e');
          }
          // Continue with unsorted list if sorting fails
        }

        if (kDebugMode) {
          debugPrint('✅ [FilteredWorkoutHistory] Filtered ${workouts.length} → ${filtered.length} workouts');
        }

        return filtered;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ [FilteredWorkoutHistory] Error filtering workouts: $e');
          debugPrint('📍 Stack trace: $stackTrace');
        }
        // Return unfiltered list as fallback
        return workouts;
      }
    },
  );
});

/// Filter options for workout history
class WorkoutHistoryFilter {

  const WorkoutHistoryFilter({
    this.searchQuery = '',
    this.startDate,
    this.endDate,
    this.sortBy = WorkoutSortOption.dateDesc,
  });
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final WorkoutSortOption sortBy;

  WorkoutHistoryFilter copyWith({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    WorkoutSortOption? sortBy,
  }) {
    return WorkoutHistoryFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// Sort options for workouts
enum WorkoutSortOption {
  dateDesc,   // Most recent first
  dateAsc,    // Oldest first
  name,       // Alphabetical
  duration,   // Longest first
  volume,     // Highest volume first
}

/// Provider for workout statistics
final workoutStatsProvider = Provider<WorkoutStats>((ref) {
  final workoutsAsync = ref.watch(workoutHistoryProvider);

  return workoutsAsync.when(
    loading: () => const WorkoutStats.empty(),
    error: (error, stack) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutStats] Error loading workout data: $error');
      }
      return const WorkoutStats.empty();
    },
    data: (workouts) {
      try {
        return WorkoutStats.fromWorkouts(workouts);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ [WorkoutStats] Error calculating stats: $e');
          debugPrint('📍 Stack trace: $stackTrace');
        }
        return const WorkoutStats.empty();
      }
    },
  );
});

/// Workout statistics calculation
class WorkoutStats {

  const WorkoutStats({
    required this.totalWorkouts,
    required this.totalTime,
    required this.totalVolume,
    required this.totalSets,
    required this.totalReps,
    required this.averageRPE,
    required this.lastWorkout,
    required this.averageWorkoutDuration,
  });

  const WorkoutStats.empty()
      : totalWorkouts = 0,
        totalTime = Duration.zero,
        totalVolume = 0.0,
        totalSets = 0,
        totalReps = 0,
        averageRPE = 0.0,
        lastWorkout = null,
        averageWorkoutDuration = Duration.zero;

  factory WorkoutStats.fromWorkouts(List<WorkoutHistoryDetail> workouts) {
    if (workouts.isEmpty) {
      return const WorkoutStats.empty();
    }

    try {
      final totalTime = workouts.fold<Duration>(
        Duration.zero,
        (sum, workout) {
          try {
            return sum + workout.duration;
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ [WorkoutStats] Error adding duration for workout ${workout.id}: $e');
            }
            return sum; // Skip this workout
          }
        },
      );

      final totalVolume = workouts.fold<double>(
        0.0,
        (sum, workout) {
          try {
            return sum + workout.totalVolume;
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ [WorkoutStats] Error adding volume for workout ${workout.id}: $e');
            }
            return sum;
          }
        },
      );

      final totalSets = workouts.fold<int>(
        0,
        (sum, workout) {
          try {
            return sum + workout.totalSets;
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ [WorkoutStats] Error adding sets for workout ${workout.id}: $e');
            }
            return sum;
          }
        },
      );

      final totalReps = workouts.fold<int>(
        0,
        (sum, workout) {
          try {
            return sum + workout.totalReps;
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ [WorkoutStats] Error adding reps for workout ${workout.id}: $e');
            }
            return sum;
          }
        },
      );

      // Calculate average RPE with error handling
      List<double> allRPEs = [];
      try {
        allRPEs = workouts
            .expand((w) => w.exercises)
            .expand((e) => e.sets)
            .where((s) => s.rpe > 0)
            .map((s) => s.rpe.toDouble())
            .toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [WorkoutStats] Error extracting RPEs: $e');
        }
      }

      final averageRPE = allRPEs.isNotEmpty
          ? allRPEs.reduce((a, b) => a + b) / allRPEs.length
          : 0.0;

      final lastWorkout = workouts.isNotEmpty
          ? workouts.first.completedAt
          : null;

      final averageWorkoutDuration = workouts.isNotEmpty
          ? Duration(milliseconds: totalTime.inMilliseconds ~/ workouts.length)
          : Duration.zero;

      if (kDebugMode) {
        debugPrint('✅ [WorkoutStats] Calculated stats for ${workouts.length} workouts: $totalSets sets, $totalReps reps, ${totalVolume.toStringAsFixed(1)}kg volume');
      }

      return WorkoutStats(
        totalWorkouts: workouts.length,
        totalTime: totalTime,
        totalVolume: totalVolume,
        totalSets: totalSets,
        totalReps: totalReps,
        averageRPE: averageRPE,
        lastWorkout: lastWorkout,
        averageWorkoutDuration: averageWorkoutDuration,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutStats] Critical error calculating stats: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Return empty stats as safe fallback
      return const WorkoutStats.empty();
    }
  }
  final int totalWorkouts;
  final Duration totalTime;
  final double totalVolume;
  final int totalSets;
  final int totalReps;
  final double averageRPE;
  final DateTime? lastWorkout;
  final Duration averageWorkoutDuration;
}

/// Provider for managing workout history filter state
final workoutHistoryFilterProvider = StateProvider<WorkoutHistoryFilter>((ref) {
  return const WorkoutHistoryFilter();
});

/// Provider that combines filter and data
final filteredWorkoutsProvider = Provider<List<WorkoutHistoryDetail>>((ref) {
  final filter = ref.watch(workoutHistoryFilterProvider);
  return ref.watch(filteredWorkoutHistoryProvider(filter));
});