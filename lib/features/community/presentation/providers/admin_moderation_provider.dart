import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/community/data/repositories/community_repository.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';

// Provider per pending contributions (solo admin)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically cancels Firestore listener when widget is disposed
final pendingContributionsProvider = StreamProvider.autoDispose<List<CommunityContribution>>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getContributions(status: ContributionStatus.pending);
});

// State notifier per gestire moderazione
class AdminModerationNotifier extends StateNotifier<AsyncValue<void>> {

  AdminModerationNotifier(this._ref) : super(const AsyncValue.data(null));
  final Ref _ref;

  /// Approva un contributo
  Future<void> approveContribution(String contributionId) async {
    state = const AsyncValue.loading();

    try {
      final user = await _ref.read(currentUserProvider.future);
      if (user == null) throw Exception('User not authenticated');

      // Verifica che l'utente sia admin
      if (user.email != 'ferrara-michele@hotmail.it') {
        throw Exception('Unauthorized: Admin only');
      }

      final repository = _ref.read(communityRepositoryProvider);
      await repository.approveContribution(contributionId, user.uid);

      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Rifiuta un contributo con reason
  Future<void> rejectContribution(String contributionId, String reason) async {
    state = const AsyncValue.loading();

    try {
      final user = await _ref.read(currentUserProvider.future);
      if (user == null) throw Exception('User not authenticated');

      // Verifica che l'utente sia admin
      if (user.email != 'ferrara-michele@hotmail.it') {
        throw Exception('Unauthorized: Admin only');
      }

      final repository = _ref.read(communityRepositoryProvider);
      await repository.rejectContribution(contributionId, user.uid, reason);

      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Approva tutti i contributi di un certo tipo (batch)
  Future<void> approveAllByType(ContributionType type, List<CommunityContribution> contributions) async {
    state = const AsyncValue.loading();

    try {
      final user = await _ref.read(currentUserProvider.future);
      if (user == null) throw Exception('User not authenticated');

      if (user.email != 'ferrara-michele@hotmail.it') {
        throw Exception('Unauthorized: Admin only');
      }

      final repository = _ref.read(communityRepositoryProvider);
      final filtered = contributions.where((c) => c.type == type && c.status == ContributionStatus.pending).toList();

      for (final contribution in filtered) {
        await repository.approveContribution(contribution.id, user.uid);
      }

      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final adminModerationProvider = StateNotifierProvider<AdminModerationNotifier, AsyncValue<void>>((ref) {
  return AdminModerationNotifier(ref);
});

// Provider per verificare se l'utente corrente è admin
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final isAdminProvider = FutureProvider.autoDispose<bool>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return user?.email == 'ferrara-michele@hotmail.it';
});

// Provider per statistiche moderazione (quanti pending, reviewed, etc.)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically cancels Firestore listener when widget is disposed
final moderationStatsProvider = StreamProvider.autoDispose<ModerationStats>((ref) async* {
  final pending = await ref.watch(pendingContributionsProvider.future);

  yield ModerationStats(
    pendingCount: pending.length,
    tipCount: pending.where((c) => c.type == ContributionType.tip).length,
    warningCount: pending.where((c) => c.type == ContributionType.warning).length,
    correctionCount: pending.where((c) => c.type == ContributionType.correction).length,
    techniqueCount: pending.where((c) => c.type == ContributionType.technique).length,
  );
});

// Model per statistiche moderazione
class ModerationStats {

  ModerationStats({
    required this.pendingCount,
    required this.tipCount,
    required this.warningCount,
    required this.correctionCount,
    required this.techniqueCount,
  });
  final int pendingCount;
  final int tipCount;
  final int warningCount;
  final int correctionCount;
  final int techniqueCount;

  int get totalCount => pendingCount;

  bool get hasPending => pendingCount > 0;

  String get summary {
    final parts = <String>[];
    if (tipCount > 0) parts.add('$tipCount tips');
    if (warningCount > 0) parts.add('$warningCount warnings');
    if (correctionCount > 0) parts.add('$correctionCount corrections');
    if (techniqueCount > 0) parts.add('$techniqueCount techniques');
    return parts.join(', ');
  }
}
