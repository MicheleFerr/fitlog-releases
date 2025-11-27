/// Advanced Exercise Template Provider
///
/// Riverpod providers for managing advanced exercise templates.
/// Handles freemium limits and template operations.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/workout/domain/entities/advanced_exercise_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/advanced_exercise_template_repository.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';

// =========================================================================
// REPOSITORY PROVIDER
// =========================================================================

/// Provider for the template repository instance
final advancedExerciseTemplateRepositoryProvider =
    Provider<HiveAdvancedExerciseTemplateRepository>((ref) {
  return HiveAdvancedExerciseTemplateRepository();
});

/// Provider to ensure repository is initialized
final templateRepositoryInitProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(advancedExerciseTemplateRepositoryProvider);
  await repository.init();
});

// =========================================================================
// TEMPLATE LIST PROVIDERS
// =========================================================================

/// Provider for all user templates
final advancedExerciseTemplatesProvider =
    FutureProvider<List<AdvancedExerciseTemplate>>((ref) async {
  // Ensure repository is initialized
  await ref.watch(templateRepositoryInitProvider.future);

  final repository = ref.watch(advancedExerciseTemplateRepositoryProvider);
  final user = ref.watch(currentUserProvider).valueOrNull;

  if (user == null) return [];

  return repository.getTemplates(user.uid);
});

/// Provider for template count
final advancedExerciseTemplateCountProvider = FutureProvider<int>((ref) async {
  final templates = await ref.watch(advancedExerciseTemplatesProvider.future);
  return templates.length;
});

/// Provider for favorite templates
final favoriteTemplatesProvider =
    FutureProvider<List<AdvancedExerciseTemplate>>((ref) async {
  final templates = await ref.watch(advancedExerciseTemplatesProvider.future);
  return templates.where((t) => t.isFavorite).toList();
});

/// Provider for templates filtered by type
final templatesByTypeProvider = FutureProvider.family<
    List<AdvancedExerciseTemplate>, AdvancedExerciseType>((ref, type) async {
  final templates = await ref.watch(advancedExerciseTemplatesProvider.future);
  return templates.where((t) => t.type == type).toList();
});

// =========================================================================
// FREEMIUM LIMIT PROVIDERS
// =========================================================================

/// Provider to check if user can create more templates
final canCreateTemplateProvider = FutureProvider<bool>((ref) async {
  final count = await ref.watch(advancedExerciseTemplateCountProvider.future);
  final isPremium = ref.watch(isPremiumUserProvider);

  return canCreateTemplate(count, isPremium);
});

/// Provider for remaining template slots (free users only)
final remainingTemplateSlotsProvider = FutureProvider<int>((ref) async {
  final count = await ref.watch(advancedExerciseTemplateCountProvider.future);
  final isPremium = ref.watch(isPremiumUserProvider);

  return getRemainingTemplateSlots(count, isPremium);
});

/// Provider for template limit info
final templateLimitInfoProvider = FutureProvider<TemplateLimitInfo>((ref) async {
  final count = await ref.watch(advancedExerciseTemplateCountProvider.future);
  final isPremium = ref.watch(isPremiumUserProvider);

  return TemplateLimitInfo(
    currentCount: count,
    maxCount: isPremium ? -1 : kFreeTemplateLimit,
    isPremium: isPremium,
    canCreate: canCreateTemplate(count, isPremium),
    remainingSlots: getRemainingTemplateSlots(count, isPremium),
  );
});

// =========================================================================
// TEMPLATE OPERATIONS PROVIDER
// =========================================================================

/// State notifier for template operations
class AdvancedExerciseTemplateNotifier extends StateNotifier<AsyncValue<void>> {
  AdvancedExerciseTemplateNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  HiveAdvancedExerciseTemplateRepository get _repository =>
      _ref.read(advancedExerciseTemplateRepositoryProvider);

  String? get _userId => _ref.read(currentUserProvider).valueOrNull?.uid;

  /// Create a new template from a superset
  Future<AdvancedExerciseTemplate?> createFromSuperset({
    required String name,
    required SupersetExercise superset,
    String? description,
    List<String> tags = const [],
  }) async {
    final userId = _userId;
    if (userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return null;
    }

    // Check freemium limit
    final canCreate = await _ref.read(canCreateTemplateProvider.future);
    if (!canCreate) {
      state = AsyncValue.error('Template limit reached', StackTrace.current);
      return null;
    }

    state = const AsyncValue.loading();

    try {
      await _repository.init();

      final template = AdvancedExerciseTemplate.fromSuperset(
        id: '',
        userId: userId,
        name: name,
        superset: superset,
        description: description,
        tags: tags,
      );

      final created = await _repository.createTemplate(template);

      // Refresh template list
      _ref.invalidate(advancedExerciseTemplatesProvider);

      state = const AsyncValue.data(null);

      if (kDebugMode) {
        debugPrint('Created superset template: ${created.name}');
      }

      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Create a new template from a dropset
  Future<AdvancedExerciseTemplate?> createFromDropSet({
    required String name,
    required DropSetExercise dropSet,
    String? description,
    List<String> tags = const [],
  }) async {
    final userId = _userId;
    if (userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return null;
    }

    // Check freemium limit
    final canCreate = await _ref.read(canCreateTemplateProvider.future);
    if (!canCreate) {
      state = AsyncValue.error('Template limit reached', StackTrace.current);
      return null;
    }

    state = const AsyncValue.loading();

    try {
      await _repository.init();

      final template = AdvancedExerciseTemplate.fromDropSet(
        id: '',
        userId: userId,
        name: name,
        dropSet: dropSet,
        description: description,
        tags: tags,
      );

      final created = await _repository.createTemplate(template);

      // Refresh template list
      _ref.invalidate(advancedExerciseTemplatesProvider);

      state = const AsyncValue.data(null);

      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Create a new template from a rest-pause
  Future<AdvancedExerciseTemplate?> createFromRestPause({
    required String name,
    required RestPauseExercise restPause,
    String? description,
    List<String> tags = const [],
  }) async {
    final userId = _userId;
    if (userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return null;
    }

    // Check freemium limit
    final canCreate = await _ref.read(canCreateTemplateProvider.future);
    if (!canCreate) {
      state = AsyncValue.error('Template limit reached', StackTrace.current);
      return null;
    }

    state = const AsyncValue.loading();

    try {
      await _repository.init();

      final template = AdvancedExerciseTemplate.fromRestPause(
        id: '',
        userId: userId,
        name: name,
        restPause: restPause,
        description: description,
        tags: tags,
      );

      final created = await _repository.createTemplate(template);

      // Refresh template list
      _ref.invalidate(advancedExerciseTemplatesProvider);

      state = const AsyncValue.data(null);

      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Delete a template
  Future<bool> deleteTemplate(String id) async {
    state = const AsyncValue.loading();

    try {
      await _repository.init();
      await _repository.deleteTemplate(id);

      // Refresh template list
      _ref.invalidate(advancedExerciseTemplatesProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    try {
      await _repository.init();
      await _repository.toggleFavorite(id);

      // Refresh template list
      _ref.invalidate(advancedExerciseTemplatesProvider);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error toggling favorite: $e');
      }
    }
  }

  /// Record template usage
  Future<void> recordUsage(String id) async {
    try {
      await _repository.init();
      await _repository.incrementUsageCount(id);

      // Refresh template list
      _ref.invalidate(advancedExerciseTemplatesProvider);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error recording usage: $e');
      }
    }
  }

  /// Update template
  Future<AdvancedExerciseTemplate?> updateTemplate(
    AdvancedExerciseTemplate template,
  ) async {
    state = const AsyncValue.loading();

    try {
      await _repository.init();
      final updated = await _repository.updateTemplate(template);

      // Refresh template list
      _ref.invalidate(advancedExerciseTemplatesProvider);

      state = const AsyncValue.data(null);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

/// Provider for template operations
final advancedExerciseTemplateNotifierProvider =
    StateNotifierProvider<AdvancedExerciseTemplateNotifier, AsyncValue<void>>(
  (ref) => AdvancedExerciseTemplateNotifier(ref),
);

// =========================================================================
// HELPER CLASSES
// =========================================================================

/// Information about template limits
class TemplateLimitInfo {
  final int currentCount;
  final int maxCount; // -1 for unlimited
  final bool isPremium;
  final bool canCreate;
  final int remainingSlots; // -1 for unlimited

  const TemplateLimitInfo({
    required this.currentCount,
    required this.maxCount,
    required this.isPremium,
    required this.canCreate,
    required this.remainingSlots,
  });

  bool get isAtLimit => !isPremium && currentCount >= kFreeTemplateLimit;

  String get limitDisplayText {
    if (isPremium) return 'Unlimited';
    return '$currentCount / $maxCount';
  }
}
