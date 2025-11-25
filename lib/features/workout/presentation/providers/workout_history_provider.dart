/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/providers
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - workout/domain/entities: Workout
/// - workout/data/datasources: HiveWorkoutDataSource
/// - auth/presentation/providers: AuthProvider
library;

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';

/// State class for workout history management
class WorkoutHistoryState {

  const WorkoutHistoryState({
    this.workouts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMoreData = true,
    this.searchQuery = '',
    this.activeFilter = 'all',
    this.dateFilter,
    this.statistics = const {},
  });
  final List<Workout> workouts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMoreData;
  final String searchQuery;
  final String activeFilter;
  final DateTimeRange? dateFilter;
  final Map<String, dynamic> statistics;

  WorkoutHistoryState copyWith({
    List<Workout>? workouts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMoreData,
    String? searchQuery,
    String? activeFilter,
    DateTimeRange? dateFilter,
    Map<String, dynamic>? statistics,
  }) {
    return WorkoutHistoryState(
      workouts: workouts ?? this.workouts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      dateFilter: dateFilter ?? this.dateFilter,
      statistics: statistics ?? this.statistics,
    );
  }

  bool get isEmpty => workouts.isEmpty && !isLoading;
  bool get hasFilters => searchQuery.isNotEmpty || activeFilter != 'all' || dateFilter != null;
}

/// Notifier for managing workout history state
class WorkoutHistoryNotifier extends StateNotifier<AsyncValue<List<Workout>>> {

  WorkoutHistoryNotifier({
    required HiveWorkoutDataSource dataSource,
    String? userId,
  })  : _dataSource = dataSource,
        _userId = userId,
        super(const AsyncValue.loading());
  final HiveWorkoutDataSource _dataSource;
  final String? _userId;
  
  // Internal state for filtering and pagination
  String _searchQuery = '';
  String _activeFilter = 'all';
  DateTimeRange? _dateFilter;
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  List<Workout> _allWorkouts = [];

  bool get hasMoreData => _hasMoreData;

  /// Load initial workout data
  Future<void> loadWorkouts() async {
    if (_userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    _currentPage = 0;
    _hasMoreData = true;
    
    try {
      // Load all workouts from local storage
      final allWorkouts = await _dataSource.getWorkouts(_userId);
      _allWorkouts = allWorkouts.map((model) => _mapWorkoutModelToEntity(model)).toList();
      
      // Sort by date (newest first)
      _allWorkouts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Apply filters and pagination
      final filteredWorkouts = _applyFilters(_allWorkouts);
      final paginatedWorkouts = _applyPagination(filteredWorkouts);
      
      state = AsyncValue.data(paginatedWorkouts);
      
      debugPrint('📊 Loaded ${_allWorkouts.length} total workouts, showing ${paginatedWorkouts.length}');
    } catch (e, stack) {
      debugPrint('❌ Error loading workouts: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Load more workouts for pagination
  Future<void> loadMoreWorkouts() async {
    if (!_hasMoreData || state.isLoading) return;

    final currentWorkouts = state.value ?? [];
    
    try {
      _currentPage++;
      final filteredWorkouts = _applyFilters(_allWorkouts);
      final newPageWorkouts = _applyPagination(filteredWorkouts, append: true);
      
      if (newPageWorkouts.length <= currentWorkouts.length) {
        _hasMoreData = false;
      }
      
      state = AsyncValue.data(newPageWorkouts);
    } catch (e, stack) {
      debugPrint('❌ Error loading more workouts: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refresh workout data
  Future<void> refreshWorkouts() async {
    await loadWorkouts();
  }

  /// Update filters and reload data
  Future<void> updateFilters({
    String? search,
    String? filter,
    DateTimeRange? dateRange,
  }) async {
    _searchQuery = search ?? _searchQuery;
    _activeFilter = filter ?? _activeFilter;
    _dateFilter = dateRange ?? _dateFilter;
    
    _currentPage = 0;
    _hasMoreData = true;
    
    try {
      final filteredWorkouts = _applyFilters(_allWorkouts);
      final paginatedWorkouts = _applyPagination(filteredWorkouts);
      
      state = AsyncValue.data(paginatedWorkouts);
      
      debugPrint('📊 Applied filters - showing ${paginatedWorkouts.length} workouts');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update a workout
  Future<void> updateWorkout(Workout updatedWorkout) async {
    if (_userId == null) return;

    try {
      final workoutModel = _mapWorkoutEntityToModel(updatedWorkout);
      await _dataSource.updateWorkout(workoutModel, _userId);
      
      // Update local cache
      final index = _allWorkouts.indexWhere((w) => w.id == updatedWorkout.id);
      if (index >= 0) {
        _allWorkouts[index] = updatedWorkout;
        
        // Refresh displayed data
        final filteredWorkouts = _applyFilters(_allWorkouts);
        final paginatedWorkouts = _applyPagination(filteredWorkouts);
        state = AsyncValue.data(paginatedWorkouts);
      }
      
      debugPrint('✅ Updated workout: ${updatedWorkout.name}');
    } catch (e, stack) {
      debugPrint('❌ Error updating workout: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Duplicate a workout
  Future<void> duplicateWorkout(Workout workout) async {
    if (_userId == null) return;

    try {
      final now = DateTime.now();
      final duplicatedWorkout = Workout(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '${workout.name} (Copy)',
        exercises: workout.exercises,
        status: WorkoutStatus.planned,
        notes: workout.notes,
        createdAt: now,
        updatedAt: now,
      );
      
      final workoutModel = _mapWorkoutEntityToModel(duplicatedWorkout);
      await _dataSource.saveWorkout(workoutModel, _userId);
      
      // Add to local cache
      _allWorkouts.insert(0, duplicatedWorkout); // Add at beginning (newest first)
      
      // Refresh displayed data
      final filteredWorkouts = _applyFilters(_allWorkouts);
      final paginatedWorkouts = _applyPagination(filteredWorkouts);
      state = AsyncValue.data(paginatedWorkouts);
      
      debugPrint('✅ Duplicated workout: ${duplicatedWorkout.name}');
    } catch (e, stack) {
      debugPrint('❌ Error duplicating workout: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Delete a workout
  Future<void> deleteWorkout(Workout workout) async {
    if (_userId == null) return;

    try {
      await _dataSource.deleteWorkout(workout.id, _userId);
      
      // Remove from local cache
      _allWorkouts.removeWhere((w) => w.id == workout.id);
      
      // Refresh displayed data
      final filteredWorkouts = _applyFilters(_allWorkouts);
      final paginatedWorkouts = _applyPagination(filteredWorkouts);
      state = AsyncValue.data(paginatedWorkouts);
      
      debugPrint('✅ Deleted workout: ${workout.name}');
    } catch (e, stack) {
      debugPrint('❌ Error deleting workout: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Export workouts to JSON
  Future<void> exportWorkouts() async {
    try {
      final workoutsToExport = _applyFilters(_allWorkouts);
      
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'totalWorkouts': workoutsToExport.length,
        'filters': {
          'search': _searchQuery,
          'filter': _activeFilter,
          'dateRange': _dateFilter != null 
              ? {
                  'start': _dateFilter!.start.toIso8601String(),
                  'end': _dateFilter!.end.toIso8601String(),
                }
              : null,
        },
        'workouts': workoutsToExport.map((workout) => {
          'id': workout.id,
          'name': workout.name,
          'createdAt': workout.createdAt.toIso8601String(),
          'duration': workout.duration?.inMinutes,
          'exercises': workout.exercises.map((exercise) => {
            'name': exercise.name,
            'sets': exercise.sets.map((set) => {
              'weight': set.weight,
              'reps': set.reps,
              'rpe': set.rpe,
              'isCompleted': set.isCompleted,
            }).toList(),
          }).toList(),
        }).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/gymbro_workouts_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'GymBro Workout Export - ${workoutsToExport.length} workouts',
      );
      
      debugPrint('✅ Exported ${workoutsToExport.length} workouts');
    } catch (e) {
      debugPrint('❌ Error exporting workouts: $e');
    }
  }

  /// Calculate workout statistics
  Map<String, dynamic> calculateStatistics() {
    final workouts = state.value ?? [];
    
    if (workouts.isEmpty) {
      return {};
    }

    final totalWorkouts = workouts.length;
    final totalDuration = workouts
        .where((w) => w.duration != null)
        .map((w) => w.duration!.inMinutes)
        .fold<int>(0, (sum, minutes) => sum + minutes);
    
    final exerciseCounts = <String, int>{};
    int totalSets = 0;
    double totalVolume = 0;
    
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        exerciseCounts[exercise.name] = (exerciseCounts[exercise.name] ?? 0) + 1;
        
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            totalSets++;
            final weight = set.weight ?? 0.0;
            final reps = set.reps ?? 0;
            totalVolume += weight * reps;
          }
        }
      }
    }
    
    final mostFrequentExercise = exerciseCounts.isNotEmpty
        ? exerciseCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;

    return {
      'totalWorkouts': totalWorkouts,
      'totalDuration': totalDuration,
      'averageDuration': totalWorkouts > 0 ? (totalDuration / totalWorkouts).round() : 0,
      'totalSets': totalSets,
      'totalVolume': totalVolume.round(),
      'averageVolume': totalWorkouts > 0 ? (totalVolume / totalWorkouts).round() : 0,
      'uniqueExercises': exerciseCounts.length,
      'mostFrequentExercise': mostFrequentExercise,
      'exerciseFrequency': exerciseCounts,
    };
  }

  // Private helper methods

  List<Workout> _applyFilters(List<Workout> workouts) {
    var filtered = workouts;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((workout) {
        return workout.name.toLowerCase().contains(query) ||
               workout.exercises.any((exercise) => 
                 exercise.name.toLowerCase().contains(query));
      }).toList();
    }

    // Apply category filter
    if (_activeFilter != 'all') {
      switch (_activeFilter) {
        case 'week':
          final weekAgo = DateTime.now().subtract(const Duration(days: 7));
          filtered = filtered.where((w) => w.createdAt.isAfter(weekAgo)).toList();
          break;
        case 'month':
          final monthAgo = DateTime.now().subtract(const Duration(days: 30));
          filtered = filtered.where((w) => w.createdAt.isAfter(monthAgo)).toList();
          break;
        case 'strength':
        case 'hypertrophy':
        case 'cardio':
          // TODO: Implement workout type classification
          break;
      }
    }

    // Apply date range filter
    if (_dateFilter != null) {
      filtered = filtered.where((workout) {
        final date = DateTime(
          workout.createdAt.year,
          workout.createdAt.month,
          workout.createdAt.day,
        );
        return date.isAfter(_dateFilter!.start.subtract(const Duration(days: 1))) &&
               date.isBefore(_dateFilter!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  List<Workout> _applyPagination(List<Workout> workouts, {bool append = false}) {
    final startIndex = append ? 0 : 0;
    final endIndex = (_currentPage + 1) * _pageSize;
    
    if (endIndex >= workouts.length) {
      _hasMoreData = false;
      return workouts;
    }
    
    return workouts.sublist(startIndex, endIndex);
  }

  Workout _mapWorkoutModelToEntity(WorkoutModel model) {
    // Simple mapping - in a real app you'd use a proper mapper
    return Workout(
      id: model.id,
      name: model.name,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      exercises: model.exercises.map((e) => e.toDomain()).toList(),
      status: WorkoutStatus.values.firstWhere(
        (s) => s.name == model.status,
        orElse: () => WorkoutStatus.planned,
      ),
      startTime: model.startTime,
      endTime: model.endTime,
      notes: model.notes,
    );
  }

  WorkoutModel _mapWorkoutEntityToModel(Workout entity) {
    return WorkoutModel(
      id: entity.id,
      name: entity.name,
      createdAt: entity.createdAt,
      updatedAt: DateTime.now(),
      exercises: entity.exercises.map((e) => ExerciseModel.fromDomain(e)).toList(),
      status: entity.status.name,
      startTime: entity.startTime,
      endTime: entity.endTime,
      notes: entity.notes,
    );
  }
}

/// Main provider for workout history
final workoutHistoryProvider = StateNotifierProvider<WorkoutHistoryNotifier, AsyncValue<List<Workout>>>((ref) {
  final user = ref.watch(firebaseUserProvider).valueOrNull;
  final boxManager = ref.watch(hiveBoxManagerProvider);
  final dataSource = HiveWorkoutDataSource(boxManager);

  return WorkoutHistoryNotifier(
    dataSource: dataSource,
    userId: user?.uid,
  );
});

/// Provider for workout statistics
final workoutHistoryStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(workoutHistoryProvider.notifier);
  return notifier.calculateStatistics();
});

/// Provider to check if user has completed a workout today (after user's day cutoff)
///
/// Returns the completed workout if found, null otherwise.
/// Uses configurable cutoff (default 04:00): workout after cutoff counts as "today".
/// Cutoff can be customized in user preferences (useful for shift workers).
final todayCompletedWorkoutProvider = FutureProvider.autoDispose<Workout?>((ref) async {
  final userId = ref.watch(firebaseUserProvider).valueOrNull?.uid;

  if (kDebugMode) {
    debugPrint('🔍 [todayCompletedWorkoutProvider] START - userId: $userId');
  }

  if (userId == null) {
    if (kDebugMode) {
      debugPrint('⚠️ [todayCompletedWorkoutProvider] No userId, returning null');
    }
    return null;
  }

  // Get user's day cutoff preference (default: 4 = 04:00)
  final userProfile = ref.watch(userProfileProvider).valueOrNull;
  final cutoffHour = userProfile?.dayCutoffHour ?? 4;

  if (kDebugMode) {
    debugPrint('⚙️ [todayCompletedWorkoutProvider] Using cutoff hour: $cutoffHour:00');
  }

  final dataSource = ref.watch(hiveWorkoutDataSourceProvider);

  try {
    // Get last completed workout with timeout
    final lastWorkoutModel = await dataSource
        .getLastCompletedWorkout(userId)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            if (kDebugMode) {
              debugPrint('⏱️ [todayCompletedWorkoutProvider] Timeout after 5s');
            }
            return null;
          },
        );

    if (lastWorkoutModel == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [todayCompletedWorkoutProvider] No last workout found');
      }
      return null;
    }

    // Map WorkoutModel to Workout entity
    final lastWorkout = Workout(
      id: lastWorkoutModel.id,
      name: lastWorkoutModel.name,
      createdAt: lastWorkoutModel.createdAt,
      updatedAt: lastWorkoutModel.updatedAt,
      exercises: lastWorkoutModel.exercises.map((e) => e.toDomain()).toList(),
      status: WorkoutStatus.values.firstWhere(
        (s) => s.name == lastWorkoutModel.status,
        orElse: () => WorkoutStatus.planned,
      ),
      startTime: lastWorkoutModel.startTime,
      endTime: lastWorkoutModel.endTime,
      notes: lastWorkoutModel.notes,
    );

    // Check if startTime is null
    if (lastWorkout.startTime == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [todayCompletedWorkoutProvider] Workout has no startTime');
      }
      return null;
    }

    // Calculate today's cutoff using user preference
    final now = DateTime.now();
    final todayCutoff = DateTime(now.year, now.month, now.day, cutoffHour, 0);

    // Check if workout was at or after cutoff (inclusive)
    if (lastWorkout.startTime!.compareTo(todayCutoff) >= 0) {
      if (kDebugMode) {
        debugPrint('✅ [todayCompletedWorkoutProvider] Workout done today: ${lastWorkout.id}');
      }
      return lastWorkout;
    }

    if (kDebugMode) {
      debugPrint('⚠️ [todayCompletedWorkoutProvider] Last workout was before cutoff');
    }
    return null;

  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [todayCompletedWorkoutProvider] Error: $e');
    }
    return null; // Graceful fallback
  }
});