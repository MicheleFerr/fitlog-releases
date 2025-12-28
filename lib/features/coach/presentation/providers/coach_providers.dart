/// Coach Providers
///
/// Riverpod providers for coach mode functionality.
/// Handles account mode, coach relationships, and athlete management.
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/coach/data/repositories/coach_repository_impl.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/account_mode.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_relationship.dart';
import 'package:gymbro_flutter_new/features/coach/domain/repositories/coach_repository.dart';

// ============================================================
// REPOSITORY PROVIDER
// ============================================================

/// Provider for CoachRepository
final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  return CoachRepositoryImpl();
});

// ============================================================
// ACCOUNT MODE PROVIDERS
// ============================================================

/// Provider for current account mode
///
/// Reads from UserProfile.preferences['accountMode']
/// Defaults to AccountMode.solo if not set
final accountModeProvider = Provider<AccountMode>((ref) {
  final userProfile = ref.watch(userProfileProvider).valueOrNull;
  if (userProfile == null) return AccountMode.solo;

  return userProfile.preferences.accountMode;
});

/// StateNotifier for managing account mode changes
class AccountModeNotifier extends StateNotifier<AccountMode> {
  AccountModeNotifier(this._ref) : super(AccountMode.solo) {
    _init();
  }

  final Ref _ref;

  void _init() {
    final userProfile = _ref.read(userProfileProvider).valueOrNull;
    if (userProfile != null) {
      state = userProfile.preferences.accountMode;
    }
  }

  /// Change account mode
  ///
  /// Updates Firestore user preferences
  Future<void> setMode(AccountMode mode) async {
    final user = _ref.read(firebaseUserProvider).valueOrNull;
    if (user == null) return;

    // Update Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'preferences.accountMode': mode.value,
    });

    state = mode;
  }

  /// Set to coach mode and generate code if needed
  Future<String?> enableCoachMode() async {
    final user = _ref.read(firebaseUserProvider).valueOrNull;
    if (user == null) return null;

    // Set mode
    await setMode(AccountMode.coach);

    // Generate coach code
    final repository = _ref.read(coachRepositoryProvider);
    final code = await repository.getOrCreateCoachCode(user.uid);

    return code;
  }

  /// Set to coached mode
  Future<void> enableCoachedMode() async {
    await setMode(AccountMode.coached);
  }

  /// Reset to solo mode
  Future<void> resetToSoloMode() async {
    await setMode(AccountMode.solo);
  }
}

/// Provider for AccountModeNotifier
final accountModeNotifierProvider =
    StateNotifierProvider<AccountModeNotifier, AccountMode>((ref) {
  return AccountModeNotifier(ref);
});

// ============================================================
// COACH CODE PROVIDER
// ============================================================

/// Provider for coach code (only for coaches)
///
/// Returns null if user is not in coach mode
final coachCodeProvider = FutureProvider.autoDispose<String?>((ref) async {
  final mode = ref.watch(accountModeProvider);
  if (!mode.isCoach) return null;

  final user = ref.watch(firebaseUserProvider).valueOrNull;
  if (user == null) return null;

  final repository = ref.watch(coachRepositoryProvider);
  return repository.getOrCreateCoachCode(user.uid);
});

// ============================================================
// ATHLETES LIST PROVIDER (Coach perspective)
// ============================================================

/// Provider for list of athletes (for coaches)
///
/// Returns empty list if user is not in coach mode
final athletesListProvider =
    StreamProvider.autoDispose<List<CoachRelationship>>((ref) {
  final mode = ref.watch(accountModeProvider);
  if (!mode.isCoach) return Stream.value([]);

  final user = ref.watch(firebaseUserProvider).valueOrNull;
  if (user?.email == null) return Stream.value([]);

  final repository = ref.watch(coachRepositoryProvider);
  return repository.watchAthletes(user!.email!);
});

/// Provider for active athletes count
final activeAthletesCountProvider = Provider.autoDispose<int>((ref) {
  final athletes = ref.watch(athletesListProvider).valueOrNull ?? [];
  return athletes.where((a) => a.isActive).length;
});

/// Provider for pending invitations count
final pendingInvitationsCountProvider = Provider.autoDispose<int>((ref) {
  final athletes = ref.watch(athletesListProvider).valueOrNull ?? [];
  return athletes.where((a) => a.isPending).length;
});

// ============================================================
// MY COACH PROVIDER (Athlete perspective)
// ============================================================

/// Provider for athlete's coach relationship
///
/// Returns null if user is not in coached mode or has no coach
final myCoachProvider =
    StreamProvider.autoDispose<CoachRelationship?>((ref) {
  final mode = ref.watch(accountModeProvider);
  if (!mode.isCoached) return Stream.value(null);

  final user = ref.watch(firebaseUserProvider).valueOrNull;
  if (user == null) return Stream.value(null);

  final repository = ref.watch(coachRepositoryProvider);
  return repository.watchMyCoach(user.uid);
});

/// Provider for coach name (convenience)
final myCoachNameProvider = Provider.autoDispose<String?>((ref) {
  final coach = ref.watch(myCoachProvider).valueOrNull;
  return coach?.coachName;
});

// ============================================================
// SINGLE ATHLETE PROFILE PROVIDER
// ============================================================

/// Provider for single athlete relationship (for coach viewing athlete)
final athleteRelationshipProvider = FutureProvider.autoDispose
    .family<CoachRelationship?, String>((ref, athleteId) async {
  final user = ref.watch(firebaseUserProvider).valueOrNull;
  if (user == null) return null;

  final repository = ref.watch(coachRepositoryProvider);
  return repository.getAthleteRelationship(user.uid, athleteId);
});

// ============================================================
// COACH LOOKUP PROVIDER
// ============================================================

/// Provider for looking up coach by code
final coachLookupProvider = FutureProvider.autoDispose
    .family<CoachInfo?, String>((ref, code) async {
  if (code.length != 6) return null;

  final repository = ref.watch(coachRepositoryProvider);
  return repository.findCoachByCode(code.toUpperCase());
});

// ============================================================
// COACH ACTIONS PROVIDER
// ============================================================

/// Provider for coach actions (invite, remove, etc.)
class CoachActionsNotifier extends StateNotifier<AsyncValue<void>> {
  CoachActionsNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Invite an athlete by email
  Future<String?> inviteAthlete(String athleteEmail) async {
    final user = _ref.read(firebaseUserProvider).valueOrNull;
    if (user == null) return null;

    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(coachRepositoryProvider);
      final id = await repository.inviteAthlete(
        coachId: user.uid,
        coachEmail: user.email!,
        coachName: user.displayName ?? 'Coach',
        athleteEmail: athleteEmail,
      );
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Remove an athlete
  Future<void> removeAthlete(String relationshipId) async {
    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(coachRepositoryProvider);
      await repository.removeAthlete(relationshipId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Regenerate coach code
  Future<String?> regenerateCode() async {
    final user = _ref.read(firebaseUserProvider).valueOrNull;
    if (user == null) return null;

    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(coachRepositoryProvider);
      final code = await repository.regenerateCoachCode(user.uid);
      state = const AsyncValue.data(null);
      return code;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

/// Provider for coach actions
final coachActionsProvider =
    StateNotifierProvider<CoachActionsNotifier, AsyncValue<void>>((ref) {
  return CoachActionsNotifier(ref);
});

// ============================================================
// ATHLETE ACTIONS PROVIDER
// ============================================================

/// Provider for athlete actions (link, disconnect, etc.)
class AthleteActionsNotifier extends StateNotifier<AsyncValue<void>> {
  AthleteActionsNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Link to coach via code
  Future<String?> linkViaCode(String code) async {
    final user = _ref.read(firebaseUserProvider).valueOrNull;
    if (user == null) return null;

    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(coachRepositoryProvider);
      final id = await repository.linkViaCode(
        athleteId: user.uid,
        athleteEmail: user.email!,
        athleteName: user.displayName ?? 'Athlete',
        coachCode: code,
      );

      // Switch to coached mode
      await _ref.read(accountModeNotifierProvider.notifier).enableCoachedMode();

      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Disconnect from coach
  Future<void> disconnectFromCoach(String relationshipId) async {
    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(coachRepositoryProvider);
      await repository.disconnectFromCoach(relationshipId);

      // Switch back to solo mode
      await _ref.read(accountModeNotifierProvider.notifier).resetToSoloMode();

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for athlete actions
final athleteActionsProvider =
    StateNotifierProvider<AthleteActionsNotifier, AsyncValue<void>>((ref) {
  return AthleteActionsNotifier(ref);
});

// ============================================================
// CONVENIENCE PROVIDERS
// ============================================================

/// Whether user has completed coach onboarding
final hasCompletedCoachOnboardingProvider = Provider.autoDispose<bool>((ref) {
  final userProfile = ref.watch(userProfileProvider).valueOrNull;
  return userProfile?.preferences.hasCompletedCoachOnboarding ?? false;
});

/// Whether user is currently a coach with athletes
final isActiveCoachProvider = Provider.autoDispose<bool>((ref) {
  final mode = ref.watch(accountModeProvider);
  if (!mode.isCoach) return false;

  final athleteCount = ref.watch(activeAthletesCountProvider);
  return athleteCount > 0;
});

/// Whether user is currently being coached
final isActivelyCoachedProvider = Provider.autoDispose<bool>((ref) {
  final mode = ref.watch(accountModeProvider);
  if (!mode.isCoached) return false;

  final coach = ref.watch(myCoachProvider).valueOrNull;
  return coach?.isActive ?? false;
});

// ============================================================
// ATHLETE WORKOUT PROVIDERS
// ============================================================

/// Provider for athlete workout history (for coaches)
///
/// [athleteId] - ID of the athlete to fetch workouts for
/// Returns list of workout summaries ordered by date (newest first)
final athleteWorkoutsProvider = FutureProvider.autoDispose
    .family<List<AthleteWorkoutSummary>, String>((ref, athleteId) async {
  final user = ref.watch(firebaseUserProvider).valueOrNull;
  if (user?.email == null) return [];

  final repository = ref.watch(coachRepositoryProvider);
  return repository.fetchAthleteWorkouts(
    coachEmail: user!.email!,
    athleteId: athleteId,
    limit: 20,
  );
});

/// Provider for athlete weekly stats (for coaches)
///
/// [athleteId] - ID of the athlete to fetch stats for
/// Returns weekly stats including compliance %, volume, etc.
final athleteWeeklyStatsProvider = FutureProvider.autoDispose
    .family<AthleteWeeklyStats, String>((ref, athleteId) async {
  final user = ref.watch(firebaseUserProvider).valueOrNull;
  if (user?.email == null) return const AthleteWeeklyStats.empty();

  final repository = ref.watch(coachRepositoryProvider);
  return repository.getAthleteWeeklyStats(
    coachEmail: user!.email!,
    athleteId: athleteId,
  );
});
