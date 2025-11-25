/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/workout/presentation/providers
/// Feature: Paginated Workout History Provider
/// Type: AsyncNotifier Provider
///
/// Optimized workout history provider using cursor-based pagination.
/// Replaces the old provider that loaded ALL workouts into memory.
///
/// **Performance Improvements (2024 Best Practices)**:
/// - Cursor-based pagination with Firestore startAfterDocument
/// - Loads only 20 items per page (configurable)
/// - AsyncNotifier pattern (Riverpod 2.x)
/// - No memory leak from holding all workouts in state
/// - Infinite scroll support with hasMore detection
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/paginated_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';

/// State for paginated workout history
///
/// Uses [PaginatedState] pattern with additional filter support.
@immutable
class WorkoutHistoryPaginatedState {
  const WorkoutHistoryPaginatedState({
    this.workouts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.lastDocument,
    this.searchQuery = '',
    this.statusFilter,
    this.dateFrom,
    this.dateTo,
    this.lastWorkoutId,
  });

  /// Accumulated workouts across all loaded pages
  final List<Workout> workouts;

  /// Whether initial load is in progress
  final bool isLoading;

  /// Whether loading more (next page) is in progress
  final bool isLoadingMore;

  /// Whether there are more items to load
  final bool hasMore;

  /// Error message if load failed
  final String? error;

  /// Firestore cursor for next page (cloud pagination)
  final DocumentSnapshot? lastDocument;

  /// Current search query filter
  final String searchQuery;

  /// Status filter (e.g., 'completed', 'inProgress')
  final String? statusFilter;

  /// Date range filter - start
  final DateTime? dateFrom;

  /// Date range filter - end
  final DateTime? dateTo;

  /// Last workout ID for local pagination (Hive fallback)
  final String? lastWorkoutId;

  /// Initial state factory
  factory WorkoutHistoryPaginatedState.initial() =>
      const WorkoutHistoryPaginatedState();

  /// Loading state factory
  factory WorkoutHistoryPaginatedState.loading() =>
      const WorkoutHistoryPaginatedState(isLoading: true);

  /// Creates a copy with optional field overrides
  WorkoutHistoryPaginatedState copyWith({
    List<Workout>? workouts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    DocumentSnapshot? lastDocument,
    String? searchQuery,
    String? statusFilter,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? lastWorkoutId,
    bool clearError = false,
    bool clearLastDocument = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    bool clearStatusFilter = false,
  }) {
    return WorkoutHistoryPaginatedState(
      workouts: workouts ?? this.workouts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      lastDocument: clearLastDocument ? null : (lastDocument ?? this.lastDocument),
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      lastWorkoutId: lastWorkoutId ?? this.lastWorkoutId,
    );
  }

  /// Whether any loading operation is in progress
  bool get isAnyLoading => isLoading || isLoadingMore;

  /// Whether the state has an error
  bool get hasError => error != null;

  /// Whether initial load has completed
  bool get hasLoaded => workouts.isNotEmpty || !hasMore;

  /// Number of items loaded so far
  int get itemCount => workouts.length;

  /// Whether the list is empty after loading
  bool get isEmpty => workouts.isEmpty && !isLoading;

  /// Whether any filters are active
  bool get hasFilters =>
      searchQuery.isNotEmpty ||
      statusFilter != null ||
      dateFrom != null ||
      dateTo != null;

  @override
  String toString() {
    return 'WorkoutHistoryPaginatedState(items: $itemCount, loading: $isLoading, loadingMore: $isLoadingMore, hasMore: $hasMore, error: $error)';
  }
}

/// Default page size for workout history pagination
const int kDefaultWorkoutPageSize = 20;

/// Optimized workout history notifier using cursor-based pagination
///
/// **Key Features**:
/// - Cursor-based pagination (no memory overload)
/// - AsyncNotifier pattern (Riverpod 2.x)
/// - Supports infinite scroll UI
/// - Filter support (search, status, date range)
/// - Offline-first with cloud sync (premium users)
///
/// **Usage Example**:
/// ```dart
/// // In widget
/// final state = ref.watch(workoutHistoryPaginatedProvider);
///
/// // Load initial data
/// ref.read(workoutHistoryPaginatedProvider.notifier).loadInitial();
///
/// // Load more (infinite scroll)
/// ref.read(workoutHistoryPaginatedProvider.notifier).loadMore();
///
/// // Apply filters
/// ref.read(workoutHistoryPaginatedProvider.notifier).applyFilters(
///   searchQuery: 'bench',
///   statusFilter: 'completed',
/// );
/// ```
class WorkoutHistoryPaginatedNotifier
    extends Notifier<WorkoutHistoryPaginatedState> {
  @override
  WorkoutHistoryPaginatedState build() {
    // Auto-load on first access
    Future.microtask(() => loadInitial());
    return WorkoutHistoryPaginatedState.initial();
  }

  WorkoutRepository get _repository => ref.read(workoutRepositoryProvider);
  String? get _userId => ref.read(firebaseUserProvider).valueOrNull?.uid;

  /// Load initial page of workouts
  ///
  /// Resets pagination state and loads first page.
  /// Call this on screen init or pull-to-refresh.
  Future<void> loadInitial() async {
    if (_userId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'User not authenticated',
        hasMore: false,
      );
      return;
    }

    // Set loading state
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearLastDocument: true,
      workouts: [], // Reset workouts
      hasMore: true,
    );

    if (kDebugMode) {
      debugPrint('📖 [WorkoutHistoryPaginated] Loading initial page...');
      debugPrint('📖 [WorkoutHistoryPaginated] Filters: search="${state.searchQuery}", status=${state.statusFilter}');
    }

    try {
      final result = await _repository.getWorkoutsPaginated(
        pageSize: kDefaultWorkoutPageSize,
        dateFrom: state.dateFrom,
        dateTo: state.dateTo,
        status: state.statusFilter,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
            hasMore: false,
          );
          if (kDebugMode) {
            debugPrint('❌ [WorkoutHistoryPaginated] Error: ${failure.message}');
          }
        },
        (paginatedResult) {
          // Apply client-side search filter (Firestore doesn't support text search)
          final filteredWorkouts = _applyClientSideFilters(paginatedResult.items);

          // Get last workout ID for local pagination fallback
          final lastId = filteredWorkouts.isNotEmpty ? filteredWorkouts.last.id : null;

          state = state.copyWith(
            isLoading: false,
            workouts: filteredWorkouts,
            hasMore: paginatedResult.hasMore,
            lastDocument: paginatedResult.lastDocument,
            lastWorkoutId: lastId,
          );

          if (kDebugMode) {
            debugPrint('✅ [WorkoutHistoryPaginated] Loaded ${filteredWorkouts.length} workouts');
            debugPrint('✅ [WorkoutHistoryPaginated] HasMore: ${paginatedResult.hasMore}');
          }
        },
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutHistoryPaginated] Exception: $e');
        debugPrint('📍 Stack: $stack');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load workouts: $e',
        hasMore: false,
      );
    }
  }

  /// Load more workouts (next page)
  ///
  /// Call this when user scrolls near the bottom of the list.
  /// Automatically handles hasMore check and loading state.
  Future<void> loadMore() async {
    // Guard: Don't load if already loading or no more data
    if (state.isAnyLoading || !state.hasMore) {
      if (kDebugMode && !state.hasMore) {
        debugPrint('📖 [WorkoutHistoryPaginated] No more data to load');
      }
      return;
    }

    if (_userId == null) return;

    state = state.copyWith(isLoadingMore: true);

    if (kDebugMode) {
      debugPrint('📖 [WorkoutHistoryPaginated] Loading more...');
      debugPrint('📖 [WorkoutHistoryPaginated] Cursor: ${state.lastDocument?.id ?? state.lastWorkoutId}');
    }

    try {
      final result = await _repository.getWorkoutsPaginated(
        pageSize: kDefaultWorkoutPageSize,
        startAfter: state.lastDocument,
        dateFrom: state.dateFrom,
        dateTo: state.dateTo,
        status: state.statusFilter,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoadingMore: false,
            error: failure.message,
          );
          if (kDebugMode) {
            debugPrint('❌ [WorkoutHistoryPaginated] LoadMore error: ${failure.message}');
          }
        },
        (paginatedResult) {
          // Apply client-side search filter
          final newWorkouts = _applyClientSideFilters(paginatedResult.items);

          // Append to existing workouts (no duplicates)
          final existingIds = state.workouts.map((w) => w.id).toSet();
          final uniqueNewWorkouts = newWorkouts
              .where((w) => !existingIds.contains(w.id))
              .toList();

          final allWorkouts = [...state.workouts, ...uniqueNewWorkouts];

          // Get last workout ID
          final lastId = allWorkouts.isNotEmpty ? allWorkouts.last.id : null;

          state = state.copyWith(
            isLoadingMore: false,
            workouts: allWorkouts,
            hasMore: paginatedResult.hasMore && uniqueNewWorkouts.isNotEmpty,
            lastDocument: paginatedResult.lastDocument,
            lastWorkoutId: lastId,
          );

          if (kDebugMode) {
            debugPrint('✅ [WorkoutHistoryPaginated] Added ${uniqueNewWorkouts.length} workouts');
            debugPrint('✅ [WorkoutHistoryPaginated] Total: ${allWorkouts.length}, HasMore: ${state.hasMore}');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutHistoryPaginated] LoadMore exception: $e');
      }
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Failed to load more workouts: $e',
      );
    }
  }

  /// Refresh workout list (pull-to-refresh)
  ///
  /// Resets pagination and reloads from first page.
  Future<void> refresh() async {
    await loadInitial();
  }

  /// Apply filters and reload
  ///
  /// Resets pagination and applies new filters.
  /// All parameters are optional - pass null to keep existing filter.
  Future<void> applyFilters({
    String? searchQuery,
    String? statusFilter,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearStatusFilter = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
  }) async {
    // Update filter state
    state = state.copyWith(
      searchQuery: searchQuery ?? state.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? state.statusFilter),
      dateFrom: clearDateFrom ? null : (dateFrom ?? state.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? state.dateTo),
      // Reset pagination
      clearLastDocument: true,
      workouts: [],
      hasMore: true,
    );

    if (kDebugMode) {
      debugPrint('📖 [WorkoutHistoryPaginated] Applying filters:');
      debugPrint('   search: "${state.searchQuery}"');
      debugPrint('   status: ${state.statusFilter}');
      debugPrint('   dateFrom: ${state.dateFrom}');
      debugPrint('   dateTo: ${state.dateTo}');
    }

    // Reload with new filters
    await loadInitial();
  }

  /// Clear all filters and reload
  Future<void> clearFilters() async {
    state = state.copyWith(
      searchQuery: '',
      clearStatusFilter: true,
      clearDateFrom: true,
      clearDateTo: true,
    );
    await loadInitial();
  }

  /// Update search query (debounced)
  ///
  /// Note: This only updates the state. Call refresh() after debounce.
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Remove a workout from the list (after deletion)
  void removeWorkout(String workoutId) {
    final updatedWorkouts = state.workouts
        .where((w) => w.id != workoutId)
        .toList();

    state = state.copyWith(workouts: updatedWorkouts);

    if (kDebugMode) {
      debugPrint('🗑️ [WorkoutHistoryPaginated] Removed workout: $workoutId');
    }
  }

  /// Update a workout in the list (after edit)
  void updateWorkout(Workout updatedWorkout) {
    final updatedWorkouts = state.workouts.map((w) {
      return w.id == updatedWorkout.id ? updatedWorkout : w;
    }).toList();

    state = state.copyWith(workouts: updatedWorkouts);

    if (kDebugMode) {
      debugPrint('✏️ [WorkoutHistoryPaginated] Updated workout: ${updatedWorkout.id}');
    }
  }

  /// Add a new workout to the top of the list
  void addWorkout(Workout newWorkout) {
    final updatedWorkouts = [newWorkout, ...state.workouts];
    state = state.copyWith(workouts: updatedWorkouts);

    if (kDebugMode) {
      debugPrint('➕ [WorkoutHistoryPaginated] Added workout: ${newWorkout.id}');
    }
  }

  /// Apply client-side filters (search)
  ///
  /// Firestore doesn't support full-text search, so we filter client-side.
  /// This is only applied to already-loaded items.
  List<Workout> _applyClientSideFilters(List<Workout> workouts) {
    if (state.searchQuery.isEmpty) {
      return workouts;
    }

    final query = state.searchQuery.toLowerCase().trim();

    return workouts.where((workout) {
      // Match workout name
      if (workout.name.toLowerCase().contains(query)) {
        return true;
      }

      // Match exercise names
      for (final exercise in workout.exercises) {
        if (exercise.name.toLowerCase().contains(query)) {
          return true;
        }
      }

      // Match notes
      if (workout.notes?.toLowerCase().contains(query) ?? false) {
        return true;
      }

      return false;
    }).toList();
  }
}

/// Main paginated workout history provider
///
/// **Usage**:
/// ```dart
/// // Watch state
/// final state = ref.watch(workoutHistoryPaginatedProvider);
///
/// // Access notifier methods
/// ref.read(workoutHistoryPaginatedProvider.notifier).loadMore();
/// ref.read(workoutHistoryPaginatedProvider.notifier).refresh();
/// ```
final workoutHistoryPaginatedProvider =
    NotifierProvider<WorkoutHistoryPaginatedNotifier, WorkoutHistoryPaginatedState>(
  WorkoutHistoryPaginatedNotifier.new,
);

/// Provider to check if more workouts can be loaded
final canLoadMoreWorkoutsProvider = Provider<bool>((ref) {
  final state = ref.watch(workoutHistoryPaginatedProvider);
  return state.hasMore && !state.isAnyLoading;
});

/// Provider for filtered workout count
final filteredWorkoutCountProvider = Provider<int>((ref) {
  final state = ref.watch(workoutHistoryPaginatedProvider);
  return state.workouts.length;
});

/// Provider to check if any filters are active
final hasActiveFiltersProvider = Provider<bool>((ref) {
  final state = ref.watch(workoutHistoryPaginatedProvider);
  return state.hasFilters;
});
