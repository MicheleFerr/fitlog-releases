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
import 'package:gymbro_flutter_new/features/coach/data/repositories/coach_templates_repository.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/account_mode.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/assigned_template.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_relationship.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_template.dart';
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
  // 🔧 PERF FIX: Use .select() to only rebuild when value changes
  final userProfile = ref.watch(
    userProfileProvider.select((async) => async.value),
  );
  if (userProfile == null) return AccountMode.solo;

  return userProfile.preferences.accountMode;
});

/// Notifier for managing account mode changes
class AccountModeNotifier extends Notifier<AccountMode> {
  @override
  AccountMode build() {
    // Initialize from user profile
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile != null) {
      return userProfile.preferences.accountMode;
    }
    return AccountMode.solo;
  }

  /// Change account mode
  ///
  /// Updates Firestore user preferences
  Future<void> setMode(AccountMode mode) async {
    final user = ref.read(firebaseUserProvider).value;
    if (user == null) return;

    // Update Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'preferences.accountMode': mode.value,
    });

    state = mode;
  }

  /// Set to coach mode and generate code if needed
  Future<String?> enableCoachMode() async {
    final user = ref.read(firebaseUserProvider).value;
    if (user == null) return null;

    // Set mode
    await setMode(AccountMode.coach);

    // Generate coach code
    final repository = ref.read(coachRepositoryProvider);
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
final accountModeNotifierProvider = NotifierProvider<AccountModeNotifier, AccountMode>(
  AccountModeNotifier.new,
);

// ============================================================
// COACH CODE PROVIDER
// ============================================================

/// Provider for coach code (only for coaches)
///
/// Returns null if user is not in coach mode
final coachCodeProvider = FutureProvider.autoDispose<String?>((ref) async {
  final mode = ref.watch(accountModeProvider);
  if (!mode.isCoach) return null;

  // 🔧 PERF FIX: Use .select() to only rebuild when user value changes
  final user = ref.watch(
    firebaseUserProvider.select((async) => async.value),
  );
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

      // 🔧 PERF FIX: Use .select() to only rebuild when user value changes
      final user = ref.watch(
        firebaseUserProvider.select((async) => async.value),
      );
      if (user?.email == null) return Stream.value([]);

      final repository = ref.watch(coachRepositoryProvider);
      return repository.watchAthletes(user!.email!);
    });

/// Provider for active athletes count
final activeAthletesCountProvider = Provider.autoDispose<int>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when athletes list changes
  final athletes = ref.watch(
    athletesListProvider.select((async) => async.value ?? []),
  );
  return athletes.where((a) => a.isActive).length;
});

/// Provider for pending invitations count
final pendingInvitationsCountProvider = Provider.autoDispose<int>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when athletes list changes
  final athletes = ref.watch(
    athletesListProvider.select((async) => async.value ?? []),
  );
  return athletes.where((a) => a.isPending).length;
});

// ============================================================
// MY COACH PROVIDER (Athlete perspective)
// ============================================================

/// Provider for athlete's coach relationship
///
/// Returns null if user is not in coached mode or has no coach
final myCoachProvider = StreamProvider.autoDispose<CoachRelationship?>((ref) {
  final mode = ref.watch(accountModeProvider);
  if (!mode.isCoached) return Stream.value(null);

  // 🔧 PERF FIX: Use .select() to only rebuild when user value changes
  final user = ref.watch(
    firebaseUserProvider.select((async) => async.value),
  );
  if (user == null) return Stream.value(null);

  final repository = ref.watch(coachRepositoryProvider);
  return repository.watchMyCoach(user.uid);
});

/// Provider for coach name (convenience)
final myCoachNameProvider = Provider.autoDispose<String?>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when coach value changes
  final coach = ref.watch(myCoachProvider.select((async) => async.value));
  return coach?.coachName;
});

// ============================================================
// SINGLE ATHLETE PROFILE PROVIDER
// ============================================================

/// Provider for single athlete relationship (for coach viewing athlete)
final athleteRelationshipProvider = FutureProvider.autoDispose
    .family<CoachRelationship?, String>((ref, athleteId) async {
      // 🔧 PERF FIX: Use .select() to only rebuild when user value changes
      final user = ref.watch(
        firebaseUserProvider.select((async) => async.value),
      );
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
class CoachActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Invite an athlete by email
  Future<String?> inviteAthlete(String athleteEmail) async {
    final user = ref.read(firebaseUserProvider).value;
    if (user == null) return null;

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(coachRepositoryProvider);
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
      final repository = ref.read(coachRepositoryProvider);
      await repository.removeAthlete(relationshipId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Regenerate coach code
  Future<String?> regenerateCode() async {
    final user = ref.read(firebaseUserProvider).value;
    if (user == null) return null;

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(coachRepositoryProvider);
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
final coachActionsProvider = NotifierProvider<CoachActionsNotifier, AsyncValue<void>>(
  CoachActionsNotifier.new,
);

// ============================================================
// ATHLETE ACTIONS PROVIDER
// ============================================================

/// Provider for athlete actions (link, disconnect, etc.)
class AthleteActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Link to coach via code
  Future<String?> linkViaCode(String code) async {
    final user = ref.read(firebaseUserProvider).value;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(coachRepositoryProvider);
      final id = await repository.linkViaCode(
        athleteId: user.uid,
        athleteEmail: user.email!,
        athleteName: user.displayName ?? 'Athlete',
        coachCode: code,
      );

      // Switch to coached mode
      await ref.read(accountModeNotifierProvider.notifier).enableCoachedMode();

      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Disconnect from coach
  Future<void> disconnectFromCoach(String relationshipId) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(coachRepositoryProvider);
      await repository.disconnectFromCoach(relationshipId);

      // Switch back to solo mode
      await ref.read(accountModeNotifierProvider.notifier).resetToSoloMode();

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for athlete actions
final athleteActionsProvider = NotifierProvider<AthleteActionsNotifier, AsyncValue<void>>(
  AthleteActionsNotifier.new,
);

// ============================================================
// CONVENIENCE PROVIDERS
// ============================================================

/// Whether user has completed coach onboarding
final hasCompletedCoachOnboardingProvider = Provider.autoDispose<bool>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when user value changes
  final userProfile = ref.watch(
    userProfileProvider.select((async) => async.value),
  );
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

  // 🔧 PERF FIX: Use .select() to only rebuild when coach value changes
  final coach = ref.watch(myCoachProvider.select((async) => async.value));
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
      // 🔧 PERF FIX: Use .select() to only rebuild when user value changes
      final user = ref.watch(
        firebaseUserProvider.select((async) => async.value),
      );
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
      // 🔧 PERF FIX: Use .select() to only rebuild when user value changes
      final user = ref.watch(
        firebaseUserProvider.select((async) => async.value),
      );
      if (user?.email == null) return const AthleteWeeklyStats.empty();

      final repository = ref.watch(coachRepositoryProvider);
      return repository.getAthleteWeeklyStats(
        coachEmail: user!.email!,
        athleteId: athleteId,
      );
    });

// ============================================================
// COACH TEMPLATES PROVIDERS
// ============================================================

/// Provider for CoachTemplatesRepository
final coachTemplatesRepositoryProvider = Provider<CoachTemplatesRepository>((
  ref,
) {
  return CoachTemplatesRepository();
});

/// Provider for all coach templates
///
/// Returns stream of templates owned by the current coach
final coachTemplatesProvider = StreamProvider.autoDispose<List<CoachTemplate>>((
  ref,
) {
  final mode = ref.watch(accountModeProvider);
  if (!mode.isCoach) return Stream.value([]);

  // 🔧 PERF FIX: Use .select() to only rebuild when user value changes
  final user = ref.watch(
    firebaseUserProvider.select((async) => async.value),
  );
  if (user == null) return Stream.value([]);

  final repository = ref.watch(coachTemplatesRepositoryProvider);
  return repository.watchCoachTemplates(user.uid);
});

/// Provider for templates with assignments (assigned to at least one athlete)
final assignedCoachTemplatesProvider =
    Provider.autoDispose<List<CoachTemplate>>((ref) {
      // 🔧 PERF FIX: Use .select() to only rebuild when templates list changes
      final templates = ref.watch(
        coachTemplatesProvider.select((async) => async.value ?? []),
      );
      return templates.where((t) => t.hasAssignments).toList();
    });

/// Provider for single coach template by ID
final coachTemplateProvider = FutureProvider.autoDispose
    .family<CoachTemplate?, String>((ref, templateId) async {
      final repository = ref.watch(coachTemplatesRepositoryProvider);
      return repository.getTemplate(templateId);
    });

/// Provider for assignment state of a template
///
/// Returns map of athleteId -> isAssigned
final templateAssignmentsProvider = Provider.autoDispose
    .family<Map<String, bool>, String>((ref, templateId) {
      // 🔧 PERF FIX: Use .select() to only rebuild when data changes
      final athletes = ref.watch(
        athletesListProvider.select((async) => async.value ?? []),
      );
      final templates = ref.watch(
        coachTemplatesProvider.select((async) => async.value ?? []),
      );

      final template = templates.where((t) => t.id == templateId).firstOrNull;
      if (template == null) return {};

      return {
        for (final athlete in athletes)
          athlete.athleteId: template.isAssignedTo(athlete.athleteId),
      };
    });

/// Coach template count
final coachTemplateCountProvider = Provider.autoDispose<int>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when templates list changes
  final templates = ref.watch(
    coachTemplatesProvider.select((async) => async.value ?? []),
  );
  return templates.length;
});

// ============================================================
// ATHLETE ASSIGNED TEMPLATES PROVIDERS
// ============================================================

/// Provider for templates assigned to current athlete (from their coach)
final assignedTemplatesProvider =
    StreamProvider.autoDispose<List<AssignedTemplate>>((ref) {
      final mode = ref.watch(accountModeProvider);
      if (!mode.isCoached) return Stream.value([]);

      // 🔧 PERF FIX: Use .select() to only rebuild when user value changes
      final user = ref.watch(
        firebaseUserProvider.select((async) => async.value),
      );
      if (user == null) return Stream.value([]);

      final repository = ref.watch(coachTemplatesRepositoryProvider);
      return repository.watchAssignedTemplates(user.uid);
    });

/// Provider for count of assigned templates
final assignedTemplateCountProvider = Provider.autoDispose<int>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when templates list changes
  final templates = ref.watch(
    assignedTemplatesProvider.select((async) => async.value ?? []),
  );
  return templates.length;
});

/// Provider for full template data of an assigned template
final assignedTemplateDataProvider = FutureProvider.autoDispose
    .family<CoachTemplate?, String>((ref, templateId) async {
      final repository = ref.watch(coachTemplatesRepositoryProvider);
      return repository.getAssignedTemplateData(templateId);
    });

// ============================================================
// COACH TEMPLATE ACTIONS
// ============================================================

/// Notifier for coach template actions
class CoachTemplateActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Create a new coach template
  Future<String?> createTemplate(CoachTemplate template) async {
    final user = ref.read(firebaseUserProvider).value;
    if (user == null) return null;

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(coachTemplatesRepositoryProvider);
      final id = await repository.createTemplate(
        template.copyWith(coachId: user.uid),
      );
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Update an existing template
  Future<void> updateTemplate(CoachTemplate template) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(coachTemplatesRepositoryProvider);
      await repository.updateTemplate(template);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a template
  Future<void> deleteTemplate(String templateId) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(coachTemplatesRepositoryProvider);
      await repository.deleteTemplate(templateId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Assign template to athletes
  Future<void> assignTemplate({
    required String templateId,
    required List<String> athleteIds,
  }) async {
    final user = ref.read(firebaseUserProvider).value;
    if (user == null) return;

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(coachTemplatesRepositoryProvider);
      await repository.assignTemplate(
        templateId: templateId,
        athleteIds: athleteIds,
        coachId: user.uid,
        coachName: user.displayName ?? 'Coach',
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update assignments (add/remove in one operation)
  Future<void> updateAssignments({
    required String templateId,
    required List<String> athleteIds,
  }) async {
    final user = ref.read(firebaseUserProvider).value;
    if (user == null) return;

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(coachTemplatesRepositoryProvider);
      await repository.updateAssignments(
        templateId: templateId,
        athleteIds: athleteIds,
        coachId: user.uid,
        coachName: user.displayName ?? 'Coach',
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for coach template actions
final coachTemplateActionsProvider = NotifierProvider<CoachTemplateActionsNotifier, AsyncValue<void>>(
  CoachTemplateActionsNotifier.new,
);
