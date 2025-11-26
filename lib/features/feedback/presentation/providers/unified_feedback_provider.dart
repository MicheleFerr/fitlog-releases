/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/presentation/providers
/// 🎯 Feature: unified_feedback
/// 🔧 Type: riverpod_providers
///
/// Unified Feedback Providers - Riverpod state management
///
/// **Architecture**: Following 2025 Admin Dashboard UI/UX Best Practices
/// - Real-time streams for live updates
/// - Progressive disclosure (summary → details)
/// - Role-based access (user vs admin views)
/// - Filtering & sorting with immediate feedback
/// - AutoDispose for memory efficiency
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/feedback/data/repositories/unified_feedback_repository_impl.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/entities/unified_feedback.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/enums/unified_feedback_type.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/repositories/i_unified_feedback_repository.dart';
import 'package:gymbro_flutter_new/core/providers/firebase_providers.dart';

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================
// NOTE: firestoreProvider is now in core/providers/firebase_providers.dart (canonical)

/// Unified feedback repository provider (singleton)
final unifiedFeedbackRepositoryProvider =
    Provider<IUnifiedFeedbackRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return UnifiedFeedbackRepositoryImpl(firestore: firestore);
});

// ============================================================================
// USER FEEDBACK PROVIDERS
// ============================================================================

/// User's feedback list provider (all types)
///
/// **Usage**: User feedback history screen
/// **AutoDispose**: Prevents memory leaks when user navigates away
final userFeedbackProvider = FutureProvider.autoDispose
    .family<List<UnifiedFeedback>, String>((ref, userId) async {
  final repository = ref.watch(unifiedFeedbackRepositoryProvider);
  final result = await repository.getUserFeedback(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (feedback) => feedback,
  );
});

/// User's feedback filtered by type
///
/// **Usage**: User feedback filtered view (e.g., "Show only my exercise feedback")
/// **AutoDispose**: Prevents memory leaks
final userFeedbackByTypeProvider = FutureProvider.autoDispose
    .family<List<UnifiedFeedback>, ({String userId, UnifiedFeedbackType type})>(
  (ref, params) async {
    final repository = ref.watch(unifiedFeedbackRepositoryProvider);
    final result =
        await repository.getUserFeedbackByType(params.userId, params.type);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (feedback) => feedback,
    );
  },
);

/// Watch user feedback in real-time
///
/// **Usage**: User feedback screen with live updates
/// **2025 UX**: Real-time feedback without refresh
final userFeedbackStreamProvider = StreamProvider.autoDispose
    .family<List<UnifiedFeedback>, String>((ref, userId) {
  final repository = ref.watch(unifiedFeedbackRepositoryProvider);

  return repository.watchUserFeedback(userId).map((either) {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (feedback) => feedback,
    );
  });
});

// ============================================================================
// ADMIN QUERY PROVIDERS
// ============================================================================

/// All feedback provider (admin only)
///
/// **Usage**: Admin dashboard - complete feedback list
/// **Filtering**: Supports type, status, severity, limit filters
/// **AutoDispose**: Prevents memory leaks
final allFeedbackProvider = FutureProvider.autoDispose.family<
    List<UnifiedFeedback>,
    ({
      int? limit,
      UnifiedFeedbackType? type,
      UnifiedFeedbackStatus? status,
      FeedbackSeverity? severity
    })>((ref, filters) async {
  final repository = ref.watch(unifiedFeedbackRepositoryProvider);

  final result = await repository.getAllFeedback(
    limit: filters.limit,
    type: filters.type,
    status: filters.status,
    severity: filters.severity,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (feedback) => feedback,
  );
});

/// Pending feedback provider (open + reviewing status)
///
/// **Usage**: Admin dashboard - priority queue
/// **Sorting**: By severity (critical first), then by age (oldest first)
/// **2025 UX**: Prioritization with visual hierarchy
final pendingFeedbackProvider =
    FutureProvider.autoDispose<List<UnifiedFeedback>>((ref) async {
  final repository = ref.watch(unifiedFeedbackRepositoryProvider);
  final result = await repository.getPendingFeedback();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (feedback) => feedback,
  );
});

/// Pending feedback count stream (real-time)
///
/// **Usage**: Admin dashboard header badge
/// **2025 UX**: Live notification count without refresh
/// **Visual**: Red badge with count (e.g., "42 pending")
final pendingFeedbackCountStreamProvider =
    StreamProvider.autoDispose<int>((ref) {
  final repository = ref.watch(unifiedFeedbackRepositoryProvider);

  return repository.watchPendingFeedbackCount().map((either) {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (count) => count,
    );
  });
});

/// Feedback by type provider (admin only)
///
/// **Usage**: Admin dashboard - filter by feedback type
/// **2025 UX**: Filtering with immediate visual feedback
final feedbackByTypeProvider = FutureProvider.autoDispose
    .family<List<UnifiedFeedback>, ({UnifiedFeedbackType type, int? limit})>(
  (ref, params) async {
    final repository = ref.watch(unifiedFeedbackRepositoryProvider);
    final result = await repository.getFeedbackByType(
      params.type,
      limit: params.limit,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (feedback) => feedback,
    );
  },
);

/// Feedback by status provider (admin only)
///
/// **Usage**: Admin dashboard - filter by status
/// **2025 UX**: Status-based views (Open, Reviewing, Resolved, etc.)
final feedbackByStatusProvider = FutureProvider.autoDispose.family<
    List<UnifiedFeedback>,
    ({UnifiedFeedbackStatus status, int? limit})>((ref, params) async {
  final repository = ref.watch(unifiedFeedbackRepositoryProvider);
  final result = await repository.getFeedbackByStatus(
    params.status,
    limit: params.limit,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (feedback) => feedback,
  );
});

/// Feedback by ID provider
///
/// **Usage**: Feedback detail view (user or admin)
/// **AutoDispose**: Memory efficient when navigating away
final feedbackByIdProvider = FutureProvider.autoDispose
    .family<UnifiedFeedback, String>((ref, feedbackId) async {
  final repository = ref.watch(unifiedFeedbackRepositoryProvider);
  final result = await repository.getFeedbackById(feedbackId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (feedback) => feedback,
  );
});

/// Watch feedback by type in real-time (admin only)
///
/// **Usage**: Admin dashboard with live updates per type
/// **2025 UX**: Real-time filtering without refresh
final feedbackByTypeStreamProvider = StreamProvider.autoDispose
    .family<List<UnifiedFeedback>, UnifiedFeedbackType>((ref, type) {
  final repository = ref.watch(unifiedFeedbackRepositoryProvider);

  return repository.watchFeedbackByType(type).map((either) {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (feedback) => feedback,
    );
  });
});

// ============================================================================
// ADMIN STATISTICS PROVIDERS
// ============================================================================

/// Feedback statistics provider (admin dashboard metrics)
///
/// **Usage**: Admin dashboard overview cards
/// **Metrics**:
/// - Total feedback count
/// - Counts by type (exercise: 50, aiInsight: 30, etc.)
/// - Counts by status (open: 10, resolved: 80, etc.)
/// - Counts by severity (critical: 2, high: 8, etc.)
/// - Average resolution time
/// - Top 10 most active reporters
///
/// **2025 UX**: Data visualization with cards and charts
final feedbackStatisticsProvider =
    FutureProvider.autoDispose<FeedbackStatistics>((ref) async {
  final repository = ref.watch(unifiedFeedbackRepositoryProvider);
  final result = await repository.getFeedbackStatistics();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (statistics) => statistics,
  );
});

/// Derived provider: Total feedback count
///
/// **Usage**: Admin dashboard summary card
final totalFeedbackCountProvider = Provider.autoDispose<int>((ref) {
  final statsAsync = ref.watch(feedbackStatisticsProvider);

  return statsAsync.when(
    data: (stats) => stats.totalCount,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Derived provider: Pending feedback count (static)
///
/// **Usage**: Admin dashboard priority badge (from statistics)
/// **Note**: Use pendingFeedbackCountStreamProvider for real-time count
final pendingFeedbackCountProvider = Provider.autoDispose<int>((ref) {
  final statsAsync = ref.watch(feedbackStatisticsProvider);

  return statsAsync.when(
    data: (stats) => stats.pendingCount,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Derived provider: Critical/high priority count
///
/// **Usage**: Admin dashboard alert indicator
/// **Visual**: Red badge if > 0
final criticalFeedbackCountProvider = Provider.autoDispose<int>((ref) {
  final statsAsync = ref.watch(feedbackStatisticsProvider);

  return statsAsync.when(
    data: (stats) => stats.highPriorityCount,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Derived provider: Has critical issues
///
/// **Usage**: Admin dashboard alert state
/// **2025 UX**: Triggers notification system for critical issues
final hasCriticalIssuesProvider = Provider.autoDispose<bool>((ref) {
  final criticalCount = ref.watch(criticalFeedbackCountProvider);
  return criticalCount > 0;
});

/// Derived provider: Average resolution time (hours)
///
/// **Usage**: Admin dashboard performance metric
/// **Visual**: Display with trend indicator (↑ ↓)
final avgResolutionTimeProvider = Provider.autoDispose<double>((ref) {
  final statsAsync = ref.watch(feedbackStatisticsProvider);

  return statsAsync.when(
    data: (stats) => stats.avgResolutionTimeHours,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Derived provider: Completed feedback count
///
/// **Usage**: Admin dashboard success metric
final completedFeedbackCountProvider = Provider.autoDispose<int>((ref) {
  final statsAsync = ref.watch(feedbackStatisticsProvider);

  return statsAsync.when(
    data: (stats) => stats.completedCount,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Derived provider: Feedback by type counts
///
/// **Usage**: Admin dashboard pie chart / bar chart
/// **2025 UX**: Interactive data visualization
final feedbackByTypeCountsProvider =
    Provider.autoDispose<Map<UnifiedFeedbackType, int>>((ref) {
  final statsAsync = ref.watch(feedbackStatisticsProvider);

  return statsAsync.when(
    data: (stats) => stats.countsByType,
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Derived provider: Feedback by status counts
///
/// **Usage**: Admin dashboard workflow progress chart
final feedbackByStatusCountsProvider =
    Provider.autoDispose<Map<UnifiedFeedbackStatus, int>>((ref) {
  final statsAsync = ref.watch(feedbackStatisticsProvider);

  return statsAsync.when(
    data: (stats) => stats.countsByStatus,
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Derived provider: Most active reporters (top 10)
///
/// **Usage**: Admin dashboard leaderboard
/// **2025 UX**: Gamification element
final mostActiveReportersProvider =
    Provider.autoDispose<List<(String, int)>>((ref) {
  final statsAsync = ref.watch(feedbackStatisticsProvider);

  return statsAsync.when(
    data: (stats) => stats.mostActiveReporters,
    loading: () => [],
    error: (_, __) => [],
  );
});

// ============================================================================
// ADMIN ACTION PROVIDERS
// ============================================================================

/// Submit feedback action provider
///
/// **Usage**: User submits new feedback
/// **Returns**: Feedback ID on success
final submitFeedbackProvider = FutureProvider.autoDispose
    .family<String, UnifiedFeedback>((ref, feedback) async {
  final repository = ref.watch(unifiedFeedbackRepositoryProvider);
  final result = await repository.submitFeedback(feedback);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (feedbackId) => feedbackId,
  );
});

/// Update feedback status action provider (admin only)
///
/// **Usage**: Admin marks feedback as reviewing/resolved/dismissed/closed
/// **2025 UX**: Action buttons with confirmation dialog
final updateFeedbackStatusProvider = FutureProvider.autoDispose.family<
    void,
    ({
      String feedbackId,
      UnifiedFeedbackStatus newStatus,
      String adminUserId,
      String? adminNote
    })>((ref, params) async {
  final repository = ref.watch(unifiedFeedbackRepositoryProvider);

  final result = await repository.updateFeedbackStatus(
    feedbackId: params.feedbackId,
    newStatus: params.newStatus,
    adminUserId: params.adminUserId,
    adminNote: params.adminNote,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

/// Update feedback severity action provider (admin only)
///
/// **Usage**: Admin changes priority level
/// **Visual**: Severity badge color change
final updateFeedbackSeverityProvider = FutureProvider.autoDispose
    .family<void, ({String feedbackId, FeedbackSeverity newSeverity})>(
  (ref, params) async {
    final repository = ref.watch(unifiedFeedbackRepositoryProvider);

    final result = await repository.updateFeedbackSeverity(
      feedbackId: params.feedbackId,
      newSeverity: params.newSeverity,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  },
);

/// Add admin note action provider (admin only)
///
/// **Usage**: Admin adds comment/note to feedback
/// **2025 UX**: Inline editing with auto-save
final addAdminNoteProvider = FutureProvider.autoDispose
    .family<void, ({String feedbackId, String note, String adminUserId})>(
  (ref, params) async {
    final repository = ref.watch(unifiedFeedbackRepositoryProvider);

    final result = await repository.addAdminNote(
      feedbackId: params.feedbackId,
      note: params.note,
      adminUserId: params.adminUserId,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  },
);

/// Delete feedback action provider (soft delete - sets status to closed)
///
/// **Usage**: Admin closes feedback (soft delete)
/// **Note**: Does NOT permanently delete, sets status=closed
final deleteFeedbackProvider = FutureProvider.autoDispose
    .family<void, String>((ref, feedbackId) async {
  final repository = ref.watch(unifiedFeedbackRepositoryProvider);
  final result = await repository.deleteFeedback(feedbackId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

// ============================================================================
// CONVENIENCE PROVIDERS (UI STATE HELPERS)
// ============================================================================

/// Loading state provider
///
/// **Usage**: Show/hide loading indicators in UI
/// **2025 UX**: Skeleton loaders instead of spinners
final isLoadingFeedbackProvider = Provider.autoDispose<bool>((ref) {
  // Watch any provider that might be loading
  final pendingAsync = ref.watch(pendingFeedbackProvider);
  final statsAsync = ref.watch(feedbackStatisticsProvider);

  return pendingAsync.isLoading || statsAsync.isLoading;
});

/// Error state provider
///
/// **Usage**: Display error messages in UI
/// **2025 UX**: Non-intrusive error toasts
final feedbackErrorProvider = Provider.autoDispose<String?>((ref) {
  final pendingAsync = ref.watch(pendingFeedbackProvider);
  final statsAsync = ref.watch(feedbackStatisticsProvider);

  // Check for errors in any provider
  if (pendingAsync.hasError) {
    return pendingAsync.error.toString();
  }
  if (statsAsync.hasError) {
    return statsAsync.error.toString();
  }

  return null;
});

// ============================================================================
// FILTER STATE PROVIDERS (UI STATE MANAGEMENT)
// ============================================================================

/// Selected feedback type filter
///
/// **Usage**: Admin dashboard filter dropdown
/// **2025 UX**: Filter chips with immediate visual feedback
final selectedFeedbackTypeProvider =
    StateProvider.autoDispose<UnifiedFeedbackType?>((ref) => null);

/// Selected feedback status filter
///
/// **Usage**: Admin dashboard status filter
final selectedFeedbackStatusProvider =
    StateProvider.autoDispose<UnifiedFeedbackStatus?>((ref) => null);

/// Selected feedback severity filter
///
/// **Usage**: Admin dashboard severity filter
final selectedFeedbackSeverityProvider =
    StateProvider.autoDispose<FeedbackSeverity?>((ref) => null);

/// Search query provider
///
/// **Usage**: Admin dashboard search bar
/// **2025 UX**: Real-time search with debouncing
final feedbackSearchQueryProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

/// Filtered feedback provider (combines all filters)
///
/// **Usage**: Admin dashboard main list
/// **2025 UX**: Progressive disclosure - filters apply instantly
final filteredFeedbackProvider =
    Provider.autoDispose<AsyncValue<List<UnifiedFeedback>>>((ref) {
  // Get filter states
  final typeFilter = ref.watch(selectedFeedbackTypeProvider);
  final statusFilter = ref.watch(selectedFeedbackStatusProvider);
  final severityFilter = ref.watch(selectedFeedbackSeverityProvider);
  final searchQuery = ref.watch(feedbackSearchQueryProvider);

  // Watch all feedback with filters
  final feedbackAsync = ref.watch(
    allFeedbackProvider((
      limit: null,
      type: typeFilter,
      status: statusFilter,
      severity: severityFilter,
    )),
  );

  // Apply search query if present
  if (searchQuery.trim().isEmpty) {
    return feedbackAsync;
  }

  return feedbackAsync.whenData((feedback) {
    final query = searchQuery.toLowerCase();
    return feedback.where((f) {
      return f.message.toLowerCase().contains(query) ||
          f.userDisplayName?.toLowerCase().contains(query) == true ||
          f.userEmail?.toLowerCase().contains(query) == true;
    }).toList();
  });
});
