import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/data/repositories/community_repository.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';

// Repository provider è già definito in community_repository.dart

// Provider per contributions di un esercizio specifico
final exerciseContributionsProvider = StreamProvider.family<List<CommunityContribution>, String>((ref, exerciseId) {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getContributions(exerciseId: exerciseId);
});

// Provider per trending contributions
final trendingContributionsProvider = StreamProvider<List<CommunityContribution>>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getTrendingContributions();
});

// Provider per contributions da revieware
final contributionsForReviewProvider = StreamProvider<List<CommunityContribution>>((ref) async* {
  final userAsync = await ref.watch(currentUserProvider.future);
  if (userAsync == null) {
    yield [];
    return;
  }
  
  final repository = ref.watch(communityRepositoryProvider);
  yield* repository.getContributionsForReview(userAsync.uid);
});

// Provider per user stats
final userContributionStatsProvider = StreamProvider<UserContributionStats>((ref) async* {
  final userAsync = await ref.watch(currentUserProvider.future);
  if (userAsync == null) {
    // Ritorna stats vuote ma valide per utente non autenticato
    yield UserContributionStats(
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
      badges: const [],
      lastContributionDate: null,
      contributionsByType: const {},
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
final userContributionsProvider = StreamProvider<List<CommunityContribution>>((ref) async* {
  final userAsync = await ref.watch(currentUserProvider.future);
  if (userAsync == null) {
    yield [];
    return;
  }
  
  final repository = ref.watch(communityRepositoryProvider);
  yield* repository.getContributions(userId: userAsync.uid);
});

// State notifier per gestire submission di contributions
class ContributionSubmissionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  
  ContributionSubmissionNotifier(this._ref) : super(const AsyncValue.data(null));
  
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
      
      final contribution = CommunityContribution(
        id: '', // Will be set by repository
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        userId: userAsync.uid,
        userName: userAsync.displayName ?? 'Anonymous',
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
      
      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
  
  Future<void> voteOnContribution(String contributionId, bool isUpvote) async {
    try {
      final userAsync = await _ref.read(currentUserProvider.future);
      if (userAsync == null) throw Exception('User not authenticated');
      
      final repository = _ref.read(communityRepositoryProvider);
      await repository.voteOnContribution(contributionId, userAsync.uid, isUpvote);
    } catch (error) {
      // Handle error silently or show snackbar
      print('Error voting: $error');
    }
  }
  
  Future<void> commentOnContribution(String contributionId, String text) async {
    try {
      final userAsync = await _ref.read(currentUserProvider.future);
      if (userAsync == null) throw Exception('User not authenticated');
      
      final comment = ContributionComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userAsync.uid,
        userName: userAsync.displayName ?? 'Anonymous',
        text: text,
        createdAt: DateTime.now(),
      );
      
      final repository = _ref.read(communityRepositoryProvider);
      await repository.commentOnContribution(contributionId, comment);
    } catch (error) {
      print('Error commenting: $error');
    }
  }
}

final contributionSubmissionProvider = 
    StateNotifierProvider<ContributionSubmissionNotifier, AsyncValue<void>>((ref) {
  return ContributionSubmissionNotifier(ref);
});

// Provider per statistiche exercise-specific
final exerciseStatsProvider = FutureProvider.family<ExerciseStats, String>((ref, exerciseId) async {
  // In futuro questo potrebbe venire da un endpoint dedicato
  // Per ora calcoliamo dalle contributions
  final contributions = await ref.watch(
    exerciseContributionsProvider(exerciseId).future
  );
  
  final approved = contributions.where(
    (c) => c.status == ContributionStatus.approved
  ).toList();
  
  // Calcola statistiche comuni
  final Map<String, int> commonTips = {};
  final Map<String, int> commonWarnings = {};
  
  for (final contribution in approved) {
    if (contribution.type == ContributionType.tip) {
      commonTips[contribution.title] = (commonTips[contribution.title] ?? 0) + 1;
    } else if (contribution.type == ContributionType.warning) {
      commonWarnings[contribution.title] = (commonWarnings[contribution.title] ?? 0) + 1;
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
    lastUpdated: approved.isNotEmpty 
      ? approved.first.createdAt 
      : null,
  );
});

// Model per statistiche exercise
class ExerciseStats {
  final String exerciseId;
  final int totalContributions;
  final int approvedContributions;
  final List<String> topTips;
  final List<String> topWarnings;
  final DateTime? lastUpdated;
  
  ExerciseStats({
    required this.exerciseId,
    required this.totalContributions,
    required this.approvedContributions,
    required this.topTips,
    required this.topWarnings,
    this.lastUpdated,
  });
  
  bool get hasContributions => totalContributions > 0;
  bool get needsReview => totalContributions > 5 && approvedContributions < 3;
  String get trustLevel {
    if (approvedContributions >= 10) return 'Highly Verified';
    if (approvedContributions >= 5) return 'Verified';
    if (approvedContributions >= 1) return 'Community Reviewed';
    return 'Needs Review';
  }
}