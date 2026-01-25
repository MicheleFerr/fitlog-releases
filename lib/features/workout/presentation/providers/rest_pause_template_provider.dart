import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/rest_pause_template.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/rest_pause_template_repository.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';

// Repository provider
final restPauseTemplateRepositoryProvider = Provider<RestPauseTemplateRepository>((ref) {
  return RestPauseTemplateRepository();
});

// All templates (predefined + custom)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final allRestPauseTemplatesProvider =
    FutureProvider.autoDispose<List<RestPauseTemplate>>((ref) async {
  if (kDebugMode) {
    debugPrint('🔗 [ALL_RESTPAUSE_TEMPLATES] Provider called');
  }

  final repository = ref.watch(restPauseTemplateRepositoryProvider);
  final templates = await repository.getAllTemplates();

  if (kDebugMode) {
    debugPrint(
      '🔗 [ALL_RESTPAUSE_TEMPLATES] Got ${templates.length} templates',
    );
  }

  return templates;
});

// Predefined templates only
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final predefinedRestPauseTemplatesProvider =
    FutureProvider.autoDispose<List<RestPauseTemplate>>((ref) async {
  final repository = ref.watch(restPauseTemplateRepositoryProvider);
  return repository.getPredefinedTemplates();
});

// Custom templates only
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final customRestPauseTemplatesProvider =
    FutureProvider.autoDispose<List<RestPauseTemplate>>((ref) async {
  final repository = ref.watch(restPauseTemplateRepositoryProvider);
  return repository.getCustomTemplates();
});

// Search query state
final restPauseTemplateSearchQueryProvider = StateProvider<String>((ref) => '');

// Search results
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final restPauseTemplateSearchResultsProvider =
    FutureProvider.autoDispose<List<RestPauseTemplate>>((ref) async {
  final repository = ref.watch(restPauseTemplateRepositoryProvider);
  final query = ref.watch(restPauseTemplateSearchQueryProvider);

  if (query.isEmpty) {
    return repository.getAllTemplates();
  }

  return repository.searchTemplates(query);
});

// Filter by difficulty
final restPauseTemplateDifficultyFilterProvider =
    StateProvider<RestPauseDifficulty?>((ref) => null);

/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final filteredRestPauseTemplatesByDifficultyProvider =
    FutureProvider.autoDispose<List<RestPauseTemplate>>((ref) async {
  final repository = ref.watch(restPauseTemplateRepositoryProvider);
  final difficulty = ref.watch(restPauseTemplateDifficultyFilterProvider);

  if (difficulty == null) {
    return repository.getAllTemplates();
  }

  return repository.getTemplatesByDifficulty(difficulty);
});

// Notifier for template management
final restPauseTemplateNotifierProvider =
    NotifierProvider<RestPauseTemplateNotifier, RestPauseTemplateState>(
  RestPauseTemplateNotifier.new,
);

class RestPauseTemplateState {
  const RestPauseTemplateState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
    this.selectedTemplate,
  });

  final List<RestPauseTemplate> templates;
  final bool isLoading;
  final String? error;
  final RestPauseTemplate? selectedTemplate;

  RestPauseTemplateState copyWith({
    List<RestPauseTemplate>? templates,
    bool? isLoading,
    String? error,
    RestPauseTemplate? selectedTemplate,
  }) {
    return RestPauseTemplateState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
    );
  }
}

class RestPauseTemplateNotifier extends Notifier<RestPauseTemplateState> {
  bool _initialized = false;

  @override
  RestPauseTemplateState build() {
    _initialized = false;
    return const RestPauseTemplateState(isLoading: true);
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
      final repository = ref.read(restPauseTemplateRepositoryProvider);
      final templates = await repository.getAllTemplates();

      state = state.copyWith(templates: templates, isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RESTPAUSE PROVIDER: Error loading templates: $e');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Save a custom template
  Future<void> saveCustomTemplate(RestPauseTemplate template) async {
    await _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint(
          '💾 RESTPAUSE PROVIDER: Saving custom template "${template.name}"',
        );
      }

      final repository = ref.read(restPauseTemplateRepositoryProvider);
      final entitlements = ref.read(tierEntitlementsProvider);
      await repository.saveCustomTemplate(
        template,
        maxCustomRestPause: entitlements.maxCustomRestPause,
      );

      if (kDebugMode) {
        debugPrint('💾 RESTPAUSE PROVIDER: Template saved, reloading...');
      }

      // Reload templates
      await loadTemplates();

      // Invalidate all related providers
      ref.invalidate(allRestPauseTemplatesProvider);
      ref.invalidate(customRestPauseTemplatesProvider);
      ref.invalidate(restPauseTemplateSearchResultsProvider);
      ref.invalidate(filteredRestPauseTemplatesByDifficultyProvider);

      if (kDebugMode) {
        debugPrint('✅ RESTPAUSE PROVIDER: Template save completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RESTPAUSE PROVIDER: Error saving template: $e');
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
        debugPrint('🗑️ RESTPAUSE PROVIDER: Deleting template $templateId');
      }

      final repository = ref.read(restPauseTemplateRepositoryProvider);
      await repository.deleteCustomTemplate(templateId);

      // Remove from local list
      final updatedTemplates = state.templates
          .where((template) => template.id != templateId)
          .toList();

      state = state.copyWith(templates: updatedTemplates);

      // Invalidate providers
      ref.invalidate(allRestPauseTemplatesProvider);
      ref.invalidate(customRestPauseTemplatesProvider);
      ref.invalidate(restPauseTemplateSearchResultsProvider);
      ref.invalidate(filteredRestPauseTemplatesByDifficultyProvider);

      if (kDebugMode) {
        debugPrint('✅ RESTPAUSE PROVIDER: Template deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RESTPAUSE PROVIDER: Error deleting template: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Select a template
  void selectTemplate(RestPauseTemplate? template) {
    state = state.copyWith(selectedTemplate: template);
  }

  /// Clear errors
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Family provider to get a single template by ID
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final restPauseTemplateByIdProvider = FutureProvider.autoDispose
    .family<RestPauseTemplate?, String>((ref, templateId) async {
  final templates = await ref.watch(allRestPauseTemplatesProvider.future);

  try {
    return templates.firstWhere((template) => template.id == templateId);
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
        '⚠️ RestPause template with ID $templateId not found in ${templates.length} templates',
      );
    }
    return null;
  }
});
