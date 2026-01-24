import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/superset_template_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';

// Repository provider
// Injects HybridExerciseRepository for localized exercise name lookup
final supersetTemplateRepositoryProvider = Provider<SupersetTemplateRepository>((ref) {
  final exerciseRepository = ref.watch(hybridExerciseRepositoryProvider);
  return SupersetTemplateRepository(
    exerciseRepository: exerciseRepository,
  );
});

// All templates (predefined + custom)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final allSupersetTemplatesProvider =
    FutureProvider.autoDispose<List<SupersetTemplate>>((ref) async {
  if (kDebugMode) {
    debugPrint('🔗 [ALL_SUPERSET_TEMPLATES] Provider called');
  }

  final repository = ref.watch(supersetTemplateRepositoryProvider);
  final templates = await repository.getAllTemplates();

  if (kDebugMode) {
    debugPrint(
      '🔗 [ALL_SUPERSET_TEMPLATES] Got ${templates.length} templates',
    );
  }

  return templates;
});

// Predefined templates only
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final predefinedSupersetTemplatesProvider =
    FutureProvider.autoDispose<List<SupersetTemplate>>((ref) async {
  final repository = ref.watch(supersetTemplateRepositoryProvider);
  return repository.getPredefinedTemplates();
});

// Custom templates only
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final customSupersetTemplatesProvider =
    FutureProvider.autoDispose<List<SupersetTemplate>>((ref) async {
  final repository = ref.watch(supersetTemplateRepositoryProvider);
  return repository.getCustomTemplates();
});

// Templates for specific persona
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final supersetTemplatesForPersonaProvider = FutureProvider.autoDispose
    .family<List<SupersetTemplate>, UserPersona>((ref, persona) async {
  final repository = ref.watch(supersetTemplateRepositoryProvider);
  return repository.getTemplatesForPersona(persona);
});

// Evidence-based templates
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final evidenceBasedSupersetTemplatesProvider =
    FutureProvider.autoDispose<List<SupersetTemplate>>((ref) async {
  final repository = ref.watch(supersetTemplateRepositoryProvider);
  return repository.getEvidenceBasedTemplates();
});

// Time-efficient templates (15-20min)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final timeEfficientSupersetTemplatesProvider =
    FutureProvider.autoDispose<List<SupersetTemplate>>((ref) async {
  final repository = ref.watch(supersetTemplateRepositoryProvider);
  return repository.getTimeEfficientTemplates();
});

// Beginner-friendly templates
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final beginnerSupersetTemplatesProvider =
    FutureProvider.autoDispose<List<SupersetTemplate>>((ref) async {
  final repository = ref.watch(supersetTemplateRepositoryProvider);
  return repository.getBeginnerTemplates();
});

// Advanced templates
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final advancedSupersetTemplatesProvider =
    FutureProvider.autoDispose<List<SupersetTemplate>>((ref) async {
  final repository = ref.watch(supersetTemplateRepositoryProvider);
  return repository.getAdvancedTemplates();
});

// Search query state
final supersetTemplateSearchQueryProvider = StateProvider<String>((ref) => '');

// Search results
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final supersetTemplateSearchResultsProvider =
    FutureProvider.autoDispose<List<SupersetTemplate>>((ref) async {
  final repository = ref.watch(supersetTemplateRepositoryProvider);
  final query = ref.watch(supersetTemplateSearchQueryProvider);

  if (query.isEmpty) {
    return repository.getAllTemplates();
  }

  return repository.searchTemplates(query);
});

// Filter by difficulty
final supersetTemplateDifficultyFilterProvider =
    StateProvider<TemplateDifficulty?>((ref) => null);

/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final filteredSupersetTemplatesByDifficultyProvider =
    FutureProvider.autoDispose<List<SupersetTemplate>>((ref) async {
  final repository = ref.watch(supersetTemplateRepositoryProvider);
  final difficulty = ref.watch(supersetTemplateDifficultyFilterProvider);

  if (difficulty == null) {
    return repository.getAllTemplates();
  }

  return repository.getTemplatesByDifficulty(difficulty);
});

// Notifier for template management
final supersetTemplateNotifierProvider =
    NotifierProvider<SupersetTemplateNotifier, SupersetTemplateState>(
  SupersetTemplateNotifier.new,
);

class SupersetTemplateState {
  const SupersetTemplateState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
    this.selectedTemplate,
  });

  final List<SupersetTemplate> templates;
  final bool isLoading;
  final String? error;
  final SupersetTemplate? selectedTemplate;

  SupersetTemplateState copyWith({
    List<SupersetTemplate>? templates,
    bool? isLoading,
    String? error,
    SupersetTemplate? selectedTemplate,
  }) {
    return SupersetTemplateState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
    );
  }
}

class SupersetTemplateNotifier extends Notifier<SupersetTemplateState> {
  bool _initialized = false;

  @override
  SupersetTemplateState build() {
    _initialized = false;
    return const SupersetTemplateState(isLoading: true);
  }

  /// Ensure templates are loaded
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _initialized = true;
      await _doLoadTemplates();
    }
  }

  /// Load all templates
  Future<void> loadTemplates() async {
    await _doLoadTemplates();
  }

  Future<void> _doLoadTemplates() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(supersetTemplateRepositoryProvider);
      final templates = await repository.getAllTemplates();

      state = state.copyWith(templates: templates, isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SUPERSET PROVIDER: Error loading templates: $e');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Save a custom template
  Future<void> saveCustomTemplate(SupersetTemplate template) async {
    await _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint(
          '💾 SUPERSET PROVIDER: Saving custom template "${template.name}"',
        );
      }

      final repository = ref.read(supersetTemplateRepositoryProvider);
      await repository.saveCustomTemplate(template);

      if (kDebugMode) {
        debugPrint('💾 SUPERSET PROVIDER: Template saved, reloading...');
      }

      // Reload templates
      await loadTemplates();

      // Invalidate all related providers
      ref.invalidate(allSupersetTemplatesProvider);
      ref.invalidate(customSupersetTemplatesProvider);
      ref.invalidate(supersetTemplateSearchResultsProvider);
      ref.invalidate(filteredSupersetTemplatesByDifficultyProvider);

      if (kDebugMode) {
        debugPrint('✅ SUPERSET PROVIDER: Template save completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SUPERSET PROVIDER: Error saving template: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Delete a custom template
  Future<void> deleteCustomTemplate(String templateId) async {
    await _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint('🗑️ SUPERSET PROVIDER: Deleting template $templateId');
      }

      final repository = ref.read(supersetTemplateRepositoryProvider);
      await repository.deleteCustomTemplate(templateId);

      // Remove from local list
      final updatedTemplates = state.templates
          .where((template) => template.id != templateId)
          .toList();

      state = state.copyWith(templates: updatedTemplates);

      // Invalidate providers
      ref.invalidate(allSupersetTemplatesProvider);
      ref.invalidate(customSupersetTemplatesProvider);
      ref.invalidate(supersetTemplateSearchResultsProvider);
      ref.invalidate(filteredSupersetTemplatesByDifficultyProvider);

      if (kDebugMode) {
        debugPrint('✅ SUPERSET PROVIDER: Template deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SUPERSET PROVIDER: Error deleting template: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Select a template
  void selectTemplate(SupersetTemplate? template) {
    state = state.copyWith(selectedTemplate: template);
  }

  /// Clear errors
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Family provider to get a single template by ID
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final supersetTemplateByIdProvider = FutureProvider.autoDispose
    .family<SupersetTemplate?, String>((ref, templateId) async {
  final templates = await ref.watch(allSupersetTemplatesProvider.future);

  try {
    return templates.firstWhere((template) => template.id == templateId);
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
        '⚠️ Superset template with ID $templateId not found in ${templates.length} templates',
      );
    }
    return null;
  }
});

/// Provider for templates recommended for user (based on persona)
/// This will be enhanced with actual persona detection in the future
/// For now, returns a mix of beginner-friendly and evidence-based templates
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final recommendedSupersetTemplatesProvider =
    FutureProvider.autoDispose<List<SupersetTemplate>>((ref) async {
  final repository = ref.watch(supersetTemplateRepositoryProvider);

  // TODO: Get user persona from profile
  // For now, combine beginner-friendly and evidence-based
  final beginner = await repository.getBeginnerTemplates();
  final evidence = await repository.getEvidenceBasedTemplates();

  // Merge and deduplicate
  final merged = <String, SupersetTemplate>{};
  for (final template in [...beginner, ...evidence]) {
    merged[template.id] = template;
  }

  // Take top 6
  return merged.values.take(6).toList();
});
