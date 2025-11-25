/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/workout/domain/entities
/// Feature: Paginated Result Entity
/// Type: Entity
///
/// Generic pagination result for cursor-based Firestore pagination.
/// Used by WorkoutHistoryNotifier for infinite scroll.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Generic pagination result containing items and cursor metadata.
///
/// [T] - The type of items in the paginated list (e.g., Workout)
///
/// Example usage:
/// ```dart
/// final result = await repository.getWorkoutsPaginated(
///   userId: userId,
///   pageSize: 20,
///   startAfter: lastDocument,
/// );
///
/// if (result.hasMore) {
///   // Load next page using result.lastDocument as cursor
/// }
/// ```
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.hasMore,
    this.lastDocument,
    this.totalCount,
  });

  /// The list of items for the current page.
  final List<T> items;

  /// Whether there are more items available to load.
  final bool hasMore;

  /// The last document snapshot, used as cursor for the next page.
  /// Null if this is the last page or no items were returned.
  final DocumentSnapshot? lastDocument;

  /// Optional total count (if available from count query).
  /// Note: Firestore count queries have cost implications.
  final int? totalCount;

  /// Creates a copy with optional field overrides.
  PaginatedResult<T> copyWith({
    List<T>? items,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
    int? totalCount,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  /// Creates an empty result (no items, no more pages).
  factory PaginatedResult.empty() => PaginatedResult<T>(
        items: [],
        hasMore: false,
      );

  /// Creates a result from a list with automatic hasMore detection.
  ///
  /// [items] - The items fetched
  /// [requestedPageSize] - The page size that was requested
  /// [lastDocument] - The last document for cursor
  ///
  /// If items.length > requestedPageSize, hasMore is true and
  /// only the first requestedPageSize items are kept.
  factory PaginatedResult.fromList({
    required List<T> items,
    required int requestedPageSize,
    DocumentSnapshot? lastDocument,
  }) {
    final hasMore = items.length > requestedPageSize;
    final trimmedItems = hasMore ? items.sublist(0, requestedPageSize) : items;

    return PaginatedResult<T>(
      items: trimmedItems,
      hasMore: hasMore,
      lastDocument: lastDocument,
    );
  }

  /// Number of items in this page.
  int get itemCount => items.length;

  /// Whether this page is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether this page has items.
  bool get isNotEmpty => items.isNotEmpty;

  @override
  String toString() {
    return 'PaginatedResult(items: $itemCount, hasMore: $hasMore, totalCount: $totalCount)';
  }
}

/// State for paginated data loading in UI.
///
/// Tracks loading state, error state, and accumulated items
/// across multiple pages.
class PaginatedState<T> {
  const PaginatedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.lastDocument,
  });

  /// All items loaded so far (accumulated across pages).
  final List<T> items;

  /// Whether initial load is in progress.
  final bool isLoading;

  /// Whether loading more (next page) is in progress.
  final bool isLoadingMore;

  /// Whether there are more items to load.
  final bool hasMore;

  /// Error message if load failed.
  final String? error;

  /// Cursor for next page.
  final DocumentSnapshot? lastDocument;

  /// Initial loading state.
  factory PaginatedState.initial() => const PaginatedState();

  /// Loading state (initial load).
  factory PaginatedState.loading() => const PaginatedState(isLoading: true);

  /// Creates a copy with optional field overrides.
  PaginatedState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    DocumentSnapshot? lastDocument,
    bool clearError = false,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }

  /// Whether any loading operation is in progress.
  bool get isAnyLoading => isLoading || isLoadingMore;

  /// Whether the state has an error.
  bool get hasError => error != null;

  /// Whether initial load has completed (has items or no more).
  bool get hasLoaded => items.isNotEmpty || !hasMore;

  /// Number of items loaded so far.
  int get itemCount => items.length;

  @override
  String toString() {
    return 'PaginatedState(items: $itemCount, loading: $isLoading, loadingMore: $isLoadingMore, hasMore: $hasMore, error: $error)';
  }
}
