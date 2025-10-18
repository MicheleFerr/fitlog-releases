import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/data/repositories/unified_template_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/helpers/template_migration_helpers.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/firebase_workout_template_repository.dart';

// Repository provider - Firebase se utente autenticato, altrimenti locale
final workoutTemplateRepositoryProvider = Provider<dynamic>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  debugPrint('🔍 REPO: User autenticato: ${user != null ? "SI (${user.uid})" : "NO"}');
  debugPrint('🔍 REPO: User email: ${user?.email ?? "N/A"}');

  // Usa Firebase se l'utente è autenticato
  if (user != null) {
    debugPrint('🔍 REPO: Usando FirebaseWorkoutTemplateRepository per user ${user.uid}');
    return FirebaseWorkoutTemplateRepository();
  }

  // Altrimenti usa repository locale
  debugPrint('🔍 REPO: Usando WorkoutTemplateRepository locale');
  return WorkoutTemplateRepository();
});

// Tutti i template (predefiniti + personalizzati)
final allWorkoutTemplatesProvider = FutureProvider<List<WorkoutTemplate>>((ref) async {
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  return repository.getAllTemplates();
});

// Solo template personalizzati
final customWorkoutTemplatesProvider = FutureProvider<List<WorkoutTemplate>>((ref) async {
  debugPrint('🔍 customWorkoutTemplatesProvider: START');

  // 1. Prendi i template dal repository legacy (esistenti)
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  debugPrint('🔍 customWorkoutTemplatesProvider: Repository type: ${repository.runtimeType}');

  final legacyTemplates = await repository.getCustomTemplates();
  debugPrint('🔍 customWorkoutTemplatesProvider: Got ${legacyTemplates.length} legacy templates');

  // 2. Prendi i template dal repository unificato (nuovi)
  try {
    final unifiedTemplates = await ref.watch(userTemplatesProvider.future);
    debugPrint('🔍 customWorkoutTemplatesProvider: Got ${unifiedTemplates.length} unified templates');

    // 3. Converti i template unificati in formato legacy e filtra solo i custom
    final convertedTemplates = unifiedTemplates
      .where((t) => t.isCustom)
      .map((t) => TemplateMigrationHelpers.toLegacyTemplate(t))
      .toList();
    debugPrint('🔍 customWorkoutTemplatesProvider: Converted ${convertedTemplates.length} custom unified templates');

    // 4. Combina e rimuovi duplicati usando l'ID come chiave
    final allTemplates = <String, WorkoutTemplate>{};

    // Aggiungi prima i template legacy
    for (final template in legacyTemplates) {
      allTemplates[template.id] = template;
      debugPrint('  - Legacy: ${template.name} (${template.id})');
    }

    // Aggiungi i template unificati (sovrascrivendo duplicati)
    for (final template in convertedTemplates) {
      allTemplates[template.id] = template;
      debugPrint('  - Unified: ${template.name} (${template.id})');
    }

    final result = allTemplates.values.toList();
    debugPrint('🔍 customWorkoutTemplatesProvider: Returning ${result.length} total unique templates');

    return result;
  } catch (e) {
    // Se c'è un errore con il repository unificato, ritorna almeno i template legacy
    debugPrint('⚠️ customWorkoutTemplatesProvider: Error loading unified templates: $e');
    debugPrint('🔍 customWorkoutTemplatesProvider: Falling back to legacy templates only');

    for (final template in legacyTemplates) {
      debugPrint('  - ${template.name}: isCustom=${template.isCustom}, id=${template.id}');
    }

    return legacyTemplates;
  }
});

// Template più utilizzati (per quick start)
final popularTemplatesProvider = FutureProvider<List<WorkoutTemplate>>((ref) async {
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  final templates = await repository.getAllTemplates();

  debugPrint('🔍 popularTemplatesProvider: Found ${templates.length} total templates');
  for (final template in templates) {
    debugPrint('  - ${template.name}: usageCount=${template.usageCount}, isCustom=${template.isCustom}');
  }

  // Ordina per utilizzo e prende i primi 6
  templates.sort((a, b) => b.usageCount.compareTo(a.usageCount));

  final popularTemplates = templates.take(6).toList();
  debugPrint('🔍 popularTemplatesProvider: Returning ${popularTemplates.length} popular templates');

  return popularTemplates;
});

// Provider per ricerca template
final templateSearchQueryProvider = StateProvider<String>((ref) => '');

final templateSearchResultsProvider = FutureProvider<List<WorkoutTemplate>>((ref) async {
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  final query = ref.watch(templateSearchQueryProvider);
  
  if (query.isEmpty) {
    return repository.getAllTemplates();
  }
  
  return repository.searchTemplates(query);
});

// Provider per filtri tag
final templateTagFilterProvider = StateProvider<List<String>>((ref) => []);

final filteredTemplatesProvider = FutureProvider<List<WorkoutTemplate>>((ref) async {
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  final selectedTags = ref.watch(templateTagFilterProvider);
  
  if (selectedTags.isEmpty) {
    return repository.getAllTemplates();
  }
  
  return repository.getTemplatesByTags(selectedTags);
});

// Notifier per gestione template
final workoutTemplateNotifierProvider = StateNotifierProvider<WorkoutTemplateNotifier, WorkoutTemplateState>((ref) {
  return WorkoutTemplateNotifier(ref);
});

class WorkoutTemplateState {

  const WorkoutTemplateState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
    this.selectedTemplate,
  });
  final List<WorkoutTemplate> templates;
  final bool isLoading;
  final String? error;
  final WorkoutTemplate? selectedTemplate;

  WorkoutTemplateState copyWith({
    List<WorkoutTemplate>? templates,
    bool? isLoading,
    String? error,
    WorkoutTemplate? selectedTemplate,
  }) {
    return WorkoutTemplateState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
    );
  }
}

class WorkoutTemplateNotifier extends StateNotifier<WorkoutTemplateState> {
  WorkoutTemplateNotifier(this.ref) : super(const WorkoutTemplateState()) {
    loadTemplates();
  }

  final Ref ref;

  /// Carica tutti i template
  Future<void> loadTemplates() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final repository = ref.read(workoutTemplateRepositoryProvider);
      final templates = await repository.getAllTemplates();
      
      state = state.copyWith(
        templates: templates,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PROVIDER: Error loading templates: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Salva un nuovo template
  Future<void> saveTemplate(WorkoutTemplate template) async {
    try {
      if (kDebugMode) {
        debugPrint('💾 PROVIDER: Starting template save for "${template.name}"');
      }
      if (kDebugMode) {
        debugPrint('   - Template has ${template.exercises.length} exercises');
      }
      
      final repository = ref.read(workoutTemplateRepositoryProvider);
      await repository.saveTemplate(template);
      
      if (kDebugMode) {
        debugPrint('💾 PROVIDER: Template saved to repository, reloading local state...');
      }
      
      // Ricarica i template
      await loadTemplates();
      
      if (kDebugMode) {
        debugPrint('💾 PROVIDER: Invalidating all related providers...');
      }
      
      // Invalida TUTTI i provider cache - Enhanced invalidation
      ref.invalidate(allWorkoutTemplatesProvider);
      ref.invalidate(customWorkoutTemplatesProvider);
      ref.invalidate(popularTemplatesProvider);
      ref.invalidate(templateSearchResultsProvider);
      ref.invalidate(filteredTemplatesProvider);
      ref.invalidate(availableTemplateTagsProvider);
      ref.invalidate(userTemplatesProvider);
      
      // Force refresh dei provider che potrebbero essere cached
      try {
        final _ = await ref.refresh(allWorkoutTemplatesProvider.future);
        if (kDebugMode) {
          debugPrint('✅ PROVIDER: Successfully refreshed allWorkoutTemplatesProvider');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️  PROVIDER: Error refreshing allWorkoutTemplatesProvider: $e');
        }
      }
      
      try {
        final _ = await ref.refresh(customWorkoutTemplatesProvider.future);
        if (kDebugMode) {
          debugPrint('✅ PROVIDER: Successfully refreshed customWorkoutTemplatesProvider');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️  PROVIDER: Error refreshing customWorkoutTemplatesProvider: $e');
        }
      }
      
      if (kDebugMode) {
        debugPrint('✅ PROVIDER: Template save and invalidation completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PROVIDER: Error saving template: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Elimina un template
  Future<void> deleteTemplate(String templateId) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ PROVIDER: Deleting template with ID: $templateId');
      }

      // Delete from unified repository first (handles all sources)
      final unifiedRepo = ref.read(unifiedTemplateRepositoryProvider);
      await unifiedRepo.deleteTemplate(templateId);
      if (kDebugMode) {
        debugPrint('🗑️ PROVIDER: Deleted from unified repository');
      }

      // Also try legacy repository for backward compatibility
      try {
        final repository = ref.read(workoutTemplateRepositoryProvider);
        await repository.deleteTemplate(templateId);
        if (kDebugMode) {
          debugPrint('🗑️ PROVIDER: Also deleted from legacy repository');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('ℹ️ PROVIDER: Not in legacy repository (expected for new templates)');
        }
      }

      // Rimuovi dalla lista locale
      final updatedTemplates = state.templates
          .where((template) => template.id != templateId)
          .toList();

      state = state.copyWith(templates: updatedTemplates);

      if (kDebugMode) {
        debugPrint('🗑️ PROVIDER: Template deleted, invalidating providers...');
      }

      // Invalida TUTTI i provider cache - Enhanced invalidation
      ref.invalidate(allWorkoutTemplatesProvider);
      ref.invalidate(customWorkoutTemplatesProvider);
      ref.invalidate(popularTemplatesProvider);
      ref.invalidate(templateSearchResultsProvider);
      ref.invalidate(filteredTemplatesProvider);
      ref.invalidate(availableTemplateTagsProvider);
      ref.invalidate(userTemplatesProvider);

      // Force refresh key providers
      await Future.wait([
        ref.refresh(customWorkoutTemplatesProvider.future),
        ref.refresh(userTemplatesProvider.future),
      ]).catchError((e) {
        if (kDebugMode) {
          debugPrint('⚠️ PROVIDER: Error refreshing providers after delete: $e');
        }
        return <List<Object>>[];
      });

      if (kDebugMode) {
        debugPrint('✅ PROVIDER: Template deletion completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PROVIDER: Error deleting template: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Crea un template da un workout esistente
  Future<WorkoutTemplate> createTemplateFromWorkout({
    required String name,
    required String description,
    required List<Exercise> exercises,
    List<String>? tags,
    String? imageUrl,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🆕 PROVIDER: Creating template from workout: "$name"');
      }
      if (kDebugMode) {
        debugPrint('   - Source exercises: ${exercises.length}');
      }
      
      final repository = ref.read(workoutTemplateRepositoryProvider);
      final template = await repository.createTemplateFromWorkout(
        name: name,
        description: description,
        exercises: exercises,
        tags: tags,
        imageUrl: imageUrl,
      );
      
      if (kDebugMode) {
        debugPrint('🆕 PROVIDER: Template created with ${template.exercises.length} exercises');
      }
      
      // Ricarica i template
      await loadTemplates();
      
      // Invalida TUTTI i provider cache - Enhanced invalidation
      ref.invalidate(allWorkoutTemplatesProvider);
      ref.invalidate(customWorkoutTemplatesProvider);
      ref.invalidate(popularTemplatesProvider);
      ref.invalidate(templateSearchResultsProvider);
      ref.invalidate(filteredTemplatesProvider);
      ref.invalidate(availableTemplateTagsProvider);
      ref.invalidate(userTemplatesProvider);
      
      if (kDebugMode) {
        debugPrint('✅ PROVIDER: Template creation completed');
      }
      return template;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PROVIDER: Error creating template from workout: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Incrementa il contatore di utilizzo
  Future<void> incrementUsage(String templateId) async {
    try {
      final repository = ref.read(workoutTemplateRepositoryProvider);
      await repository.incrementUsage(templateId);
      
      // Aggiorna la lista locale
      final updatedTemplates = state.templates.map((template) {
        if (template.id == templateId) {
          return template.incrementUsage();
        }
        return template;
      }).toList();
      
      state = state.copyWith(templates: updatedTemplates);
      
      // Invalida i provider cache
      ref.invalidate(popularTemplatesProvider);
    } catch (e) {
      // Silently fail per incrementUsage
      if (kDebugMode) {
        debugPrint('Errore nell\'incremento utilizzo: $e');
      }
    }
  }

  /// Seleziona un template
  void selectTemplate(WorkoutTemplate? template) {
    state = state.copyWith(selectedTemplate: template);
  }

  /// Pulisce gli errori
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider per ottenere tutti i tag disponibili
final availableTemplateTagsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  final templates = await repository.getAllTemplates();

  final allTags = <String>{};
  for (final template in templates) {
    allTags.addAll(template.tags);
  }

  final sortedTags = allTags.toList()..sort();
  return sortedTags;
});

/// Family provider to get a single template by ID
final templateByIdProvider = FutureProvider.family<WorkoutTemplate?, String>((ref, templateId) async {
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  final templates = await repository.getAllTemplates();

  try {
    return templates.firstWhere((template) => template.id == templateId);
  } catch (e) {
    debugPrint('⚠️ Template with ID $templateId not found');
    return null;
  }
});