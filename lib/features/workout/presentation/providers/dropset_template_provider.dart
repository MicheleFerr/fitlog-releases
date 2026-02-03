import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/dropset_template.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/dropset_template_repository.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';

// Repository provider
final dropsetTemplateRepositoryProvider = Provider<DropsetTemplateRepository>((
  ref,
) {
  return DropsetTemplateRepository();
});

// All templates (predefined + custom)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final allDropsetTemplatesProvider =
    FutureProvider.autoDispose<List<DropsetTemplate>>((ref) async {
      if (kDebugMode) {
        debugPrint('🔗 [ALL_DROPSET_TEMPLATES] Provider called');
      }

      final repository = ref.watch(dropsetTemplateRepositoryProvider);
      final templates = await repository.getAllTemplates();

      if (kDebugMode) {
        debugPrint(
          '🔗 [ALL_DROPSET_TEMPLATES] Got ${templates.length} templates',
        );
      }

      return templates;
    });

// Predefined templates only
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final predefinedDropsetTemplatesProvider =
    FutureProvider.autoDispose<List<DropsetTemplate>>((ref) async {
      final repository = ref.watch(dropsetTemplateRepositoryProvider);
      return repository.getPredefinedTemplates();
    });

// Custom templates only
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final customDropsetTemplatesProvider =
    FutureProvider.autoDispose<List<DropsetTemplate>>((ref) async {
      final repository = ref.watch(dropsetTemplateRepositoryProvider);
      return repository.getCustomTemplates();
    });

// Search query state
final dropsetTemplateSearchQueryProvider = createStateProvider<String>('');

// Search results
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final dropsetTemplateSearchResultsProvider =
    FutureProvider.autoDispose<List<DropsetTemplate>>((ref) async {
      final repository = ref.watch(dropsetTemplateRepositoryProvider);
      final query = ref.watch(dropsetTemplateSearchQueryProvider);

      if (query.isEmpty) {
        return repository.getAllTemplates();
      }

      return repository.searchTemplates(query);
    });

// Filter by difficulty
final dropsetTemplateDifficultyFilterProvider =
    createStateProvider<DropsetDifficulty?>(null);

/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final filteredDropsetTemplatesByDifficultyProvider =
    FutureProvider.autoDispose<List<DropsetTemplate>>((ref) async {
      final repository = ref.watch(dropsetTemplateRepositoryProvider);
      final difficulty = ref.watch(dropsetTemplateDifficultyFilterProvider);

      if (difficulty == null) {
        return repository.getAllTemplates();
      }

      return repository.getTemplatesByDifficulty(difficulty);
    });

// Notifier for template management
final dropsetTemplateNotifierProvider =
    NotifierProvider<DropsetTemplateNotifier, DropsetTemplateState>(
      DropsetTemplateNotifier.new,
    );

class DropsetTemplateState {
  const DropsetTemplateState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
    this.selectedTemplate,
  });

  final List<DropsetTemplate> templates;
  final bool isLoading;
  final String? error;
  final DropsetTemplate? selectedTemplate;

  DropsetTemplateState copyWith({
    List<DropsetTemplate>? templates,
    bool? isLoading,
    String? error,
    DropsetTemplate? selectedTemplate,
  }) {
    return DropsetTemplateState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
    );
  }
}

class DropsetTemplateNotifier extends Notifier<DropsetTemplateState> {
  bool _initialized = false;

  @override
  DropsetTemplateState build() {
    _initialized = false;
    return const DropsetTemplateState(isLoading: true);
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
      final repository = ref.read(dropsetTemplateRepositoryProvider);
      final templates = await repository.getAllTemplates();

      state = state.copyWith(templates: templates, isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DROPSET PROVIDER: Error loading templates: $e');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Save a custom template
  Future<void> saveCustomTemplate(DropsetTemplate template) async {
    await _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint(
          '💾 DROPSET PROVIDER: Saving custom template "${template.name}"',
        );
      }

      final repository = ref.read(dropsetTemplateRepositoryProvider);
      final entitlements = ref.read(tierEntitlementsProvider);
      await repository.saveCustomTemplate(
        template,
        maxCustomDropsets: entitlements.maxCustomDropsets,
      );

      if (kDebugMode) {
        debugPrint('💾 DROPSET PROVIDER: Template saved, reloading...');
      }

      // Reload templates
      await loadTemplates();

      // Invalidate all related providers
      ref.invalidate(allDropsetTemplatesProvider);
      ref.invalidate(customDropsetTemplatesProvider);
      ref.invalidate(dropsetTemplateSearchResultsProvider);
      ref.invalidate(filteredDropsetTemplatesByDifficultyProvider);

      if (kDebugMode) {
        debugPrint('✅ DROPSET PROVIDER: Template save completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DROPSET PROVIDER: Error saving template: $e');
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
        debugPrint('🗑️ DROPSET PROVIDER: Deleting template $templateId');
      }

      final repository = ref.read(dropsetTemplateRepositoryProvider);
      await repository.deleteCustomTemplate(templateId);

      // Remove from local list
      final updatedTemplates = state.templates
          .where((template) => template.id != templateId)
          .toList();

      state = state.copyWith(templates: updatedTemplates);

      // Invalidate providers
      ref.invalidate(allDropsetTemplatesProvider);
      ref.invalidate(customDropsetTemplatesProvider);
      ref.invalidate(dropsetTemplateSearchResultsProvider);
      ref.invalidate(filteredDropsetTemplatesByDifficultyProvider);

      if (kDebugMode) {
        debugPrint('✅ DROPSET PROVIDER: Template deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DROPSET PROVIDER: Error deleting template: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Select a template
  void selectTemplate(DropsetTemplate? template) {
    state = state.copyWith(selectedTemplate: template);
  }

  /// Clear errors
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Family provider to get a single template by ID
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final dropsetTemplateByIdProvider = FutureProvider.autoDispose
    .family<DropsetTemplate?, String>((ref, templateId) async {
      final templates = await ref.watch(allDropsetTemplatesProvider.future);

      try {
        return templates.firstWhere((template) => template.id == templateId);
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ Dropset template with ID $templateId not found in ${templates.length} templates',
          );
        }
        return null;
      }
    });
