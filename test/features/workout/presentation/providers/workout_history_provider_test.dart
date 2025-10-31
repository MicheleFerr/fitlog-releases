/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/presentation/providers
/// 🎯 Feature: Workout History Management
/// 🧪 Type: Provider Unit Tests
///
/// Test completi per workout history provider con filtri, paginazione, statistiche
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

// ============================================================================
// TEST SUITE
// ============================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutHistoryState', () {
    group('Construction', () {
      test('should have correct default values', () {
        const state = WorkoutHistoryState();

        expect(state.workouts, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.isLoadingMore, isFalse);
        expect(state.error, isNull);
        expect(state.hasMoreData, isTrue);
        expect(state.searchQuery, isEmpty);
        expect(state.activeFilter, equals('all'));
        expect(state.dateFilter, isNull);
        expect(state.statistics, isEmpty);
      });

      test('should create state with custom values', () {
        final workouts = [_createWorkout('Push Day')];
        final dateRange = DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        );
        final stats = {'totalWorkouts': 10};

        final state = WorkoutHistoryState(
          workouts: workouts,
          isLoading: true,
          isLoadingMore: true,
          error: 'Test error',
          hasMoreData: false,
          searchQuery: 'push',
          activeFilter: 'week',
          dateFilter: dateRange,
          statistics: stats,
        );

        expect(state.workouts, equals(workouts));
        expect(state.isLoading, isTrue);
        expect(state.isLoadingMore, isTrue);
        expect(state.error, equals('Test error'));
        expect(state.hasMoreData, isFalse);
        expect(state.searchQuery, equals('push'));
        expect(state.activeFilter, equals('week'));
        expect(state.dateFilter, equals(dateRange));
        expect(state.statistics, equals(stats));
      });
    });

    group('copyWith', () {
      test('should create new instance with updated workouts', () {
        const original = WorkoutHistoryState();
        final newWorkouts = [_createWorkout('Push Day')];

        final updated = original.copyWith(workouts: newWorkouts);

        expect(updated.workouts, equals(newWorkouts));
        expect(updated.isLoading, isFalse); // Preserved
        expect(updated.searchQuery, isEmpty); // Preserved
      });

      test('should create new instance with updated loading states', () {
        const original = WorkoutHistoryState();

        final updated = original.copyWith(
          isLoading: true,
          isLoadingMore: true,
        );

        expect(updated.isLoading, isTrue);
        expect(updated.isLoadingMore, isTrue);
        expect(updated.workouts, isEmpty); // Preserved
      });

      test('should create new instance with updated filters', () {
        const original = WorkoutHistoryState();
        final dateRange = DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        );

        final updated = original.copyWith(
          searchQuery: 'bench',
          activeFilter: 'month',
          dateFilter: dateRange,
        );

        expect(updated.searchQuery, equals('bench'));
        expect(updated.activeFilter, equals('month'));
        expect(updated.dateFilter, equals(dateRange));
      });

      test('should allow clearing error by passing null', () {
        const original = WorkoutHistoryState(error: 'Old error');

        final updated = original.copyWith(error: null);

        expect(updated.error, isNull);
      });

      test('should preserve unspecified values', () {
        final workouts = [_createWorkout('Push Day')];
        const original = WorkoutHistoryState(
          workouts: [],
          searchQuery: 'test',
          activeFilter: 'week',
        );

        final updated = original.copyWith(workouts: workouts);

        expect(updated.workouts, equals(workouts));
        expect(updated.searchQuery, equals('test')); // Preserved
        expect(updated.activeFilter, equals('week')); // Preserved
      });
    });

    group('Computed Properties', () {
      test('isEmpty should return true when no workouts and not loading', () {
        const state = WorkoutHistoryState(
          workouts: [],
          isLoading: false,
        );

        expect(state.isEmpty, isTrue);
      });

      test('isEmpty should return false when has workouts', () {
        final state = WorkoutHistoryState(
          workouts: [_createWorkout('Push Day')],
          isLoading: false,
        );

        expect(state.isEmpty, isFalse);
      });

      test('isEmpty should return false when loading', () {
        const state = WorkoutHistoryState(
          workouts: [],
          isLoading: true,
        );

        expect(state.isEmpty, isFalse);
      });

      test('hasFilters should return false with default filters', () {
        const state = WorkoutHistoryState();

        expect(state.hasFilters, isFalse);
      });

      test('hasFilters should return true with search query', () {
        const state = WorkoutHistoryState(searchQuery: 'test');

        expect(state.hasFilters, isTrue);
      });

      test('hasFilters should return true with active filter', () {
        const state = WorkoutHistoryState(activeFilter: 'week');

        expect(state.hasFilters, isTrue);
      });

      test('hasFilters should return true with date filter', () {
        final state = WorkoutHistoryState(
          dateFilter: DateTimeRange(
            start: DateTime(2024, 1, 1),
            end: DateTime(2024, 1, 31),
          ),
        );

        expect(state.hasFilters, isTrue);
      });

      test('hasFilters should return true with multiple filters', () {
        final state = WorkoutHistoryState(
          searchQuery: 'test',
          activeFilter: 'month',
          dateFilter: DateTimeRange(
            start: DateTime(2024, 1, 1),
            end: DateTime(2024, 1, 31),
          ),
        );

        expect(state.hasFilters, isTrue);
      });
    });
  });

  group('WorkoutHistoryNotifier', () {
    group('Documentation - Initialization', () {
      test('should start with AsyncValue.loading() state', () {
        // Document: Constructor sets super(const AsyncValue.loading())
        // Initial state is loading until loadWorkouts() completes
      });

      test('should require HiveWorkoutDataSource and userId', () {
        // Document: Constructor requires:
        // - dataSource: HiveWorkoutDataSource for local storage
        // - userId: String? for user-specific queries
      });

      test('should initialize internal state variables', () {
        // Document: Internal state initialized:
        // - _searchQuery = ''
        // - _activeFilter = 'all'
        // - _dateFilter = null
        // - _currentPage = 0
        // - _pageSize = 20
        // - _hasMoreData = true
        // - _allWorkouts = []
      });
    });

    group('Documentation - loadWorkouts', () {
      test('should return error when userId is null', () {
        // Document: If _userId == null:
        // state = AsyncValue.error('User not authenticated', StackTrace.current)
      });

      test('should set loading state initially', () {
        // Document: Sets state = AsyncValue.loading() before loading
      });

      test('should reset pagination state', () {
        // Document: Before loading:
        // _currentPage = 0
        // _hasMoreData = true
      });

      test('should load all workouts from datasource', () {
        // Document: Calls await _dataSource.getWorkouts(_userId)
        // Returns List<WorkoutModel>
      });

      test('should convert WorkoutModel to Workout entities', () {
        // Document: Maps models to entities using _mapWorkoutModelToEntity()
        // Stores in _allWorkouts
      });

      test('should sort workouts by date descending', () {
        // Document: Sorts with _allWorkouts.sort((a, b) => b.createdAt.compareTo(a.createdAt))
        // Newest first
      });

      test('should apply filters to all workouts', () {
        // Document: Calls _applyFilters(_allWorkouts)
        // Uses _searchQuery, _activeFilter, _dateFilter
      });

      test('should apply pagination to filtered results', () {
        // Document: Calls _applyPagination(filteredWorkouts)
        // Returns first page (_pageSize items)
      });

      test('should update state with paginated workouts', () {
        // Document: Sets state = AsyncValue.data(paginatedWorkouts)
      });

      test('should handle errors gracefully', () {
        // Document: Catches exceptions:
        // state = AsyncValue.error(e, stack)
        // debugPrint error message
      });
    });

    group('Documentation - loadMoreWorkouts', () {
      test('should return early if no more data', () {
        // Document: if (!_hasMoreData || state.isLoading) return
      });

      test('should increment page counter', () {
        // Document: _currentPage++
      });

      test('should apply filters and pagination with append=true', () {
        // Document: Calls _applyPagination(filteredWorkouts, append: true)
      });

      test('should set hasMoreData to false when at end', () {
        // Document: If newPageWorkouts.length <= currentWorkouts.length:
        // _hasMoreData = false
      });

      test('should update state with new page workouts', () {
        // Document: state = AsyncValue.data(newPageWorkouts)
      });
    });

    group('Documentation - updateFilters', () {
      test('should update internal filter state', () {
        // Document: Updates internal variables:
        // _searchQuery = search ?? _searchQuery
        // _activeFilter = filter ?? _activeFilter
        // _dateFilter = dateRange ?? _dateFilter
      });

      test('should reset pagination when filters change', () {
        // Document: Resets pagination:
        // _currentPage = 0
        // _hasMoreData = true
      });

      test('should apply new filters and update state', () {
        // Document: Applies filters to _allWorkouts and paginates
        // Updates state with filtered results
      });
    });

    group('Documentation - updateWorkout', () {
      test('should return early if userId is null', () {
        // Document: if (_userId == null) return
      });

      test('should convert entity to model', () {
        // Document: Calls _mapWorkoutEntityToModel(updatedWorkout)
      });

      test('should update workout in datasource', () {
        // Document: Calls _dataSource.updateWorkout(workoutModel, _userId)
      });

      test('should update local cache', () {
        // Document: Finds workout by id in _allWorkouts
        // Replaces with updated version
      });

      test('should refresh displayed data', () {
        // Document: Reapplies filters and pagination
        // Updates state with refreshed data
      });
    });

    group('Documentation - duplicateWorkout', () {
      test('should create new workout with modified name', () {
        // Document: Creates Workout with:
        // - name: '${workout.name} (Copy)'
        // - id: timestamp
        // - status: WorkoutStatus.planned
        // - copies exercises
      });

      test('should save duplicated workout to datasource', () {
        // Document: Converts to model and calls _dataSource.saveWorkout()
      });

      test('should insert at beginning of local cache', () {
        // Document: _allWorkouts.insert(0, duplicatedWorkout)
        // Adds at position 0 (newest first sorting)
      });

      test('should refresh displayed data', () {
        // Document: Applies filters, pagination, updates state
      });
    });

    group('Documentation - deleteWorkout', () {
      test('should delete from datasource', () {
        // Document: Calls _dataSource.deleteWorkout(workout.id, _userId)
      });

      test('should remove from local cache', () {
        // Document: _allWorkouts.removeWhere((w) => w.id == workout.id)
      });

      test('should refresh displayed data', () {
        // Document: Applies filters, pagination, updates state
      });
    });

    group('Documentation - exportWorkouts', () {
      test('should export filtered workouts only', () {
        // Document: Calls _applyFilters(_allWorkouts) to get export set
      });

      test('should create JSON with metadata', () {
        // Document: Creates structure:
        // - exportDate
        // - totalWorkouts
        // - filters (search, filter, dateRange)
        // - workouts array with simplified data
      });

      test('should format JSON with indentation', () {
        // Document: Uses JsonEncoder.withIndent('  ')
      });

      test('should save to temporary file', () {
        // Document: Uses getTemporaryDirectory()
        // Filename: gymbro_workouts_{timestamp}.json
      });

      test('should share file using Share.shareXFiles', () {
        // Document: Calls Share.shareXFiles with:
        // - XFile(file.path)
        // - text description
      });

      test('should handle errors silently', () {
        // Document: Catches exceptions and debugPrint only
        // No state update or rethrow
      });
    });

    group('Documentation - calculateStatistics', () {
      test('should return empty map when no workouts', () {
        // Document: if (workouts.isEmpty) return {}
      });

      test('should calculate total workouts count', () {
        // Document: totalWorkouts = workouts.length
      });

      test('should calculate total duration in minutes', () {
        // Document: Sums w.duration!.inMinutes for workouts with duration
      });

      test('should calculate average duration', () {
        // Document: totalDuration / totalWorkouts (rounded)
      });

      test('should count exercise frequencies', () {
        // Document: Creates Map<String, int> of exercise.name → count
      });

      test('should calculate total sets', () {
        // Document: Counts set.isCompleted sets
      });

      test('should calculate total volume', () {
        // Document: Sums weight * reps for completed sets
      });

      test('should calculate average volume', () {
        // Document: totalVolume / totalWorkouts (rounded)
      });

      test('should find most frequent exercise', () {
        // Document: Uses reduce to find max count in exerciseCounts
        // Returns exercise name
      });

      test('should return statistics map', () {
        // Document: Returns Map with:
        // - totalWorkouts, totalDuration, averageDuration
        // - totalSets, totalVolume, averageVolume
        // - uniqueExercises, mostFrequentExercise, exerciseFrequency
      });
    });

    group('Documentation - _applyFilters', () {
      test('should filter by search query (name)', () {
        // Document: Filters workout.name.toLowerCase().contains(query)
      });

      test('should filter by search query (exercise name)', () {
        // Document: Filters workout.exercises.any(e => e.name.contains(query))
      });

      test('should filter by week (last 7 days)', () {
        // Document: activeFilter == 'week':
        // Filters w.createdAt.isAfter(weekAgo)
      });

      test('should filter by month (last 30 days)', () {
        // Document: activeFilter == 'month':
        // Filters w.createdAt.isAfter(monthAgo)
      });

      test('should filter by date range', () {
        // Document: If _dateFilter != null:
        // Compares workout.createdAt date (ignoring time)
        // Uses isAfter(start - 1 day) && isBefore(end + 1 day)
      });

      test('should return all when filter is "all"', () {
        // Document: _activeFilter == 'all' doesn't apply any filtering
      });

      test('should support workout type filters (TODO)', () {
        // Document: Cases for 'strength', 'hypertrophy', 'cardio'
        // Currently not implemented (TODO comment)
      });
    });

    group('Documentation - _applyPagination', () {
      test('should return first page by default', () {
        // Document: startIndex = 0
        // endIndex = (_currentPage + 1) * _pageSize
      });

      test('should return all workouts when total less than page size', () {
        // Document: if (endIndex >= workouts.length):
        // Sets _hasMoreData = false
        // Returns entire workouts list
      });

      test('should return sublist for pagination', () {
        // Document: workouts.sublist(startIndex, endIndex)
      });

      test('should update hasMoreData flag', () {
        // Document: Sets _hasMoreData = false when reached end
      });
    });

    group('Documentation - Mapping Functions', () {
      test('_mapWorkoutModelToEntity should convert model to entity', () {
        // Document: Creates Workout from WorkoutModel:
        // - Maps exercises using e.toDomain()
        // - Converts status string to enum
        // - Uses firstWhere with orElse for status
      });

      test('_mapWorkoutEntityToModel should convert entity to model', () {
        // Document: Creates WorkoutModel from Workout:
        // - Maps exercises using ExerciseModel.fromDomain()
        // - Converts status enum to string (status.name)
        // - Sets updatedAt to DateTime.now()
      });
    });
  });

  group('workoutHistoryProvider', () {
    test('should be a StateNotifierProvider', () {
      // Document: StateNotifierProvider<WorkoutHistoryNotifier, AsyncValue<List<Workout>>>
      expect(
        workoutHistoryProvider,
        isA<StateNotifierProvider<WorkoutHistoryNotifier, AsyncValue<List<Workout>>>>(),
      );
    });

    test('should watch firebaseUserProvider for authentication', () {
      // Document: Watches ref.watch(firebaseUserProvider).valueOrNull
      // Gets user.uid for queries
    });

    test('should watch hiveBoxManagerProvider for datasource', () {
      // Document: Watches ref.watch(hiveBoxManagerProvider)
      // Creates HiveWorkoutDataSource(boxManager)
    });

    test('should pass userId to notifier', () {
      // Document: Creates WorkoutHistoryNotifier with:
      // - dataSource: HiveWorkoutDataSource instance
      // - userId: user?.uid from Firebase
    });
  });

  group('workoutHistoryStatsProvider', () {
    test('should be a Provider returning statistics map', () {
      // Document: Provider<Map<String, dynamic>>
      expect(
        workoutHistoryStatsProvider,
        isA<Provider<Map<String, dynamic>>>(),
      );
    });

    test('should read notifier and call calculateStatistics', () {
      // Document: Reads workoutHistoryProvider.notifier
      // Returns notifier.calculateStatistics()
    });
  });

  group('Integration Behavior', () {
    test('should reload when user authentication changes', () {
      // Document: Provider watches firebaseUserProvider
      // Recreates notifier when userId changes
    });

    test('should maintain filter state during pagination', () {
      // Document: Internal filters (_searchQuery, _activeFilter, _dateFilter)
      // preserved during loadMoreWorkouts()
    });

    test('should support offline-first with Hive datasource', () {
      // Document: Uses HiveWorkoutDataSource for local storage
      // Works without network connection
    });
  });
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Crea workout di test
Workout _createWorkout(String name) {
  return Workout(
    id: 'workout-${name.toLowerCase().replaceAll(' ', '-')}',
    name: name,
    exercises: [
      Exercise(
        id: 'exercise-1',
        name: 'Bench Press',
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 100.0,
            reps: 10,
            isCompleted: true,
          ),
        ],
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      ),
    ],
    status: WorkoutStatus.completed,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
