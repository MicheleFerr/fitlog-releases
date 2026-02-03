import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/contribution_filters.dart';
import 'package:gymbro_flutter_new/features/community/data/repositories/community_repository.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';

// Repository provider è già definito in community_repository.dart

// Provider per contributions di un esercizio specifico
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically cancels Firestore listener when widget is disposed
final exerciseContributionsProvider = StreamProvider.autoDispose
    .family<List<CommunityContribution>, String>((ref, exerciseId) {
      final repository = ref.watch(communityRepositoryProvider);
      return repository.getContributions(exerciseId: exerciseId);
    });

// Provider per trending contributions
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final trendingContributionsProvider =
    StreamProvider.autoDispose<List<CommunityContribution>>((ref) {
      final repository = ref.watch(communityRepositoryProvider);
      return repository.getTrendingContributions();
    });

// Provider per contributions da revieware
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final contributionsForReviewProvider =
    StreamProvider.autoDispose<List<CommunityContribution>>((ref) async* {
      final userAsync = await ref.watch(currentUserProvider.future);
      if (userAsync == null) {
        yield [];
        return;
      }

      final repository = ref.watch(communityRepositoryProvider);
      yield* repository.getContributionsForReview(userAsync.uid);
    });

// Provider per user stats
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final userContributionStatsProvider =
    StreamProvider.autoDispose<UserContributionStats>((ref) async* {
      final userAsync = await ref.watch(currentUserProvider.future);
      if (userAsync == null) {
        // Ritorna stats vuote ma valide per utente non autenticato
        yield const UserContributionStats(
          userId: 'guest',
          totalContributions: 0,
          approvedContributions: 0,
          rejectedContributions: 0,
          pendingContributions: 0,
          totalVotes: 0,
          totalPoints: 0,
          currentStreak: 0,
          longestStreak: 0,
          level: 'Rookie',
          badges: [],
          lastContributionDate: null,
          contributionsByType: {},
          approvalRate: 0.0,
          weeklyRank: 0,
          monthlyRank: 0,
          allTimeRank: 0,
        );
        return;
      }

      final repository = ref.watch(communityRepositoryProvider);
      yield* repository.getUserStats(userAsync.uid);
    });

// Provider per user contributions
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final userContributionsProvider =
    StreamProvider.autoDispose<List<CommunityContribution>>((ref) async* {
      if (kDebugMode) {
        debugPrint('🔍 [userContributionsProvider] Stream started');
      }
      final userAsync = await ref.watch(currentUserProvider.future);
      if (userAsync == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [userContributionsProvider] No user authenticated');
        }
        yield [];
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '👤 [userContributionsProvider] Fetching contributions for user: ${userAsync.uid}',
        );
      }
      final repository = ref.watch(communityRepositoryProvider);

      // Stream dei contributi con logging
      await for (final contributions in repository.getContributions(
        userId: userAsync.uid,
      )) {
        if (kDebugMode) {
          debugPrint(
            '📊 [userContributionsProvider] Received ${contributions.length} contributions from stream',
          );
        }
        for (var contrib in contributions) {
          if (kDebugMode) {
            debugPrint('   📝 ${contrib.title} - ${contrib.status.name}');
          }
        }
        yield contributions;
      }
    });

// State notifier per gestire submission di contributions
class ContributionSubmissionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Ref get _ref => ref;

  Future<void> submitContribution({
    required String exerciseId,
    required String exerciseName,
    required ContributionType type,
    required String title,
    required String description,
    String? originalValue,
    String? suggestedValue,
    Map<String, dynamic>? metadata,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userAsync = await _ref.read(currentUserProvider.future);
      if (userAsync == null) throw Exception('User not authenticated');

      if (kDebugMode) {
        debugPrint(
          '📤 [ContributionSubmission] Starting submission for user: ${userAsync.uid}',
        );
      }

      final contribution = CommunityContribution(
        id: '', // Will be set by repository
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        userId: userAsync.uid,
        userName: userAsync.displayName,
        type: type,
        status: ContributionStatus.pending,
        title: title,
        description: description,
        originalValue: originalValue,
        suggestedValue: suggestedValue,
        metadata: metadata,
        createdAt: DateTime.now(),
      );

      final repository = _ref.read(communityRepositoryProvider);
      await repository.submitContribution(contribution);

      if (kDebugMode) {
        debugPrint(
          '✅ [ContributionSubmission] Contribution saved to Firestore',
        );
      }

      // CRITICAL FIX: Invalidate providers to force refresh and show the new contribution
      if (kDebugMode) {
        debugPrint(
          '🔄 [ContributionSubmission] Invalidating providers to refresh UI',
        );
      }
      _ref.invalidate(userContributionsProvider);
      _ref.invalidate(userContributionStatsProvider);
      _ref.invalidate(trendingContributionsProvider);

      // Small delay to ensure Firestore propagation
      await Future.delayed(const Duration(milliseconds: 300));

      if (kDebugMode) {
        debugPrint(
          '✅ [ContributionSubmission] Providers invalidated, UI should refresh',
        );
      }

      state = const AsyncValue.data(null);
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('❌ [ContributionSubmission] Error: $error');
      }
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> voteOnContribution(String contributionId, bool isUpvote) async {
    try {
      final userAsync = await _ref.read(currentUserProvider.future);
      if (userAsync == null) throw Exception('User not authenticated');

      final repository = _ref.read(communityRepositoryProvider);
      await repository.voteOnContribution(
        contributionId,
        userAsync.uid,
        isUpvote,
      );
    } catch (error) {
      // Handle error silently or show snackbar
    }
  }

  Future<void> commentOnContribution(String contributionId, String text) async {
    try {
      final userAsync = await _ref.read(currentUserProvider.future);
      if (userAsync == null) throw Exception('User not authenticated');

      final comment = ContributionComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userAsync.uid,
        userName: userAsync.displayName,
        text: text,
        createdAt: DateTime.now(),
      );

      final repository = _ref.read(communityRepositoryProvider);
      await repository.commentOnContribution(contributionId, comment);
    } catch (error) {}
  }
}

final contributionSubmissionProvider =
    NotifierProvider<ContributionSubmissionNotifier, AsyncValue<void>>(
      ContributionSubmissionNotifier.new,
    );

// Provider per statistiche exercise-specific
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseStatsProvider = FutureProvider.autoDispose
    .family<ExerciseStats, String>((ref, exerciseId) async {
      // In futuro questo potrebbe venire da un endpoint dedicato
      // Per ora calcoliamo dalle contributions
      final contributions = await ref.watch(
        exerciseContributionsProvider(exerciseId).future,
      );

      final approved = contributions
          .where((c) => c.status == ContributionStatus.approved)
          .toList();

      // Calcola statistiche comuni
      final Map<String, int> commonTips = {};
      final Map<String, int> commonWarnings = {};

      for (final contribution in approved) {
        if (contribution.type == ContributionType.tip) {
          commonTips[contribution.title] =
              (commonTips[contribution.title] ?? 0) + 1;
        } else if (contribution.type == ContributionType.warning) {
          commonWarnings[contribution.title] =
              (commonWarnings[contribution.title] ?? 0) + 1;
        }
      }

      // Ordina per popolarità
      final sortedTips = commonTips.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final sortedWarnings = commonWarnings.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return ExerciseStats(
        exerciseId: exerciseId,
        totalContributions: contributions.length,
        approvedContributions: approved.length,
        topTips: sortedTips.take(3).map((e) => e.key).toList(),
        topWarnings: sortedWarnings.take(3).map((e) => e.key).toList(),
        lastUpdated: approved.isNotEmpty ? approved.first.createdAt : null,
      );
    });

// ============================================================================
// DISCOVERY & SEARCH PROVIDERS
// ============================================================================

// Provider 1: Search Query State
final searchQueryProvider = createStateProvider<String>('');

// Provider 2: Active Filters State
final activeFiltersProvider = createStateProvider<ContributionFilters>(
  const ContributionFilters(), // Default empty filters
);

// Provider 3: Search Results Stream
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final searchResultsProvider =
    StreamProvider.autoDispose<List<CommunityContribution>>((ref) {
      final query = ref.watch(searchQueryProvider);
      final filters = ref.watch(activeFiltersProvider);
      final repository = ref.watch(communityRepositoryProvider);

      // If query is empty, use filter-only search
      if (query.isEmpty) {
        return repository.filterContributions(filters: filters, limit: 50);
      }

      // Otherwise, search with filters
      return repository.searchContributionsStream(
        query: query,
        filters: filters,
        limit: 50,
      );
    });

// Provider 4: Saved Contribution IDs
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final savedContributionIdsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final userAsync = await ref.watch(currentUserProvider.future);
  if (userAsync == null) return [];

  final repository = ref.read(communityRepositoryProvider);
  return repository.getSavedContributionIds(userAsync.uid);
});

// Provider 5: Save/Unsave Notifier
class SaveContributionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Ref get _ref => ref;

  Future<void> saveContribution(String contributionId) async {
    state = const AsyncValue.loading();

    try {
      final userAsync = await _ref.read(currentUserProvider.future);
      if (userAsync == null) throw Exception('User not authenticated');

      final repository = _ref.read(communityRepositoryProvider);
      await repository.saveContribution(contributionId, userAsync.uid);

      // Invalidate saved IDs to refresh
      _ref.invalidate(savedContributionIdsProvider);

      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> unsaveContribution(String contributionId) async {
    state = const AsyncValue.loading();

    try {
      final userAsync = await _ref.read(currentUserProvider.future);
      if (userAsync == null) throw Exception('User not authenticated');

      final repository = _ref.read(communityRepositoryProvider);
      await repository.unsaveContribution(contributionId, userAsync.uid);

      // Invalidate saved IDs to refresh
      _ref.invalidate(savedContributionIdsProvider);

      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final saveContributionProvider =
    NotifierProvider<SaveContributionNotifier, AsyncValue<void>>(
      SaveContributionNotifier.new,
    );

// ============================================================================

// Model per statistiche exercise
class ExerciseStats {
  ExerciseStats({
    required this.exerciseId,
    required this.totalContributions,
    required this.approvedContributions,
    required this.topTips,
    required this.topWarnings,
    this.lastUpdated,
  });
  final String exerciseId;
  final int totalContributions;
  final int approvedContributions;
  final List<String> topTips;
  final List<String> topWarnings;
  final DateTime? lastUpdated;

  bool get hasContributions => totalContributions > 0;
  bool get needsReview => totalContributions > 5 && approvedContributions < 3;
  String get trustLevel {
    if (approvedContributions >= 10) return 'Highly Verified';
    if (approvedContributions >= 5) return 'Verified';
    if (approvedContributions >= 1) return 'Community Reviewed';
    return 'Needs Review';
  }
}
