import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/workout_template.dart';
import '../../domain/entities/exercise.dart';
import '../../data/repositories/workout_template_repository.dart';
import '../../data/repositories/firebase_workout_template_repository.dart';

// Repository provider - Firebase se utente autenticato, altrimenti locale
final workoutTemplateRepositoryProvider = Provider<dynamic>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  debugPrint('🔍 REPO: User autenticato: ${user != null ? "SI" : "NO"}');
  
  // Usa Firebase se l'utente è autenticato
  if (user != null) {
    debugPrint('🔍 REPO: Usando FirebaseWorkoutTemplateRepository');
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
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  return repository.getCustomTemplates();
});

// Template più utilizzati (per quick start)
final popularTemplatesProvider = FutureProvider<List<WorkoutTemplate>>((ref) async {
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  final templates = await repository.getAllTemplates();
  
  // Ordina per utilizzo e prende i primi 6
  templates.sort((a, b) => b.usageCount.compareTo(a.usageCount));
  return templates.take(6).toList();
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
  final List<WorkoutTemplate> templates;
  final bool isLoading;
  final String? error;
  final WorkoutTemplate? selectedTemplate;

  const WorkoutTemplateState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
    this.selectedTemplate,
  });

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
      print('❌ PROVIDER: Error loading templates: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Salva un nuovo template
  Future<void> saveTemplate(WorkoutTemplate template) async {
    try {
      print('💾 PROVIDER: Starting template save for "${template.name}"');
      print('   - Template has ${template.exercises.length} exercises');
      
      final repository = ref.read(workoutTemplateRepositoryProvider);
      await repository.saveTemplate(template);
      
      print('💾 PROVIDER: Template saved to repository, reloading local state...');
      
      // Ricarica i template
      await loadTemplates();
      
      print('💾 PROVIDER: Invalidating all related providers...');
      
      // Invalida TUTTI i provider cache - Enhanced invalidation
      ref.invalidate(allWorkoutTemplatesProvider);
      ref.invalidate(customWorkoutTemplatesProvider);
      ref.invalidate(popularTemplatesProvider);
      ref.invalidate(templateSearchResultsProvider);
      ref.invalidate(filteredTemplatesProvider);
      ref.invalidate(availableTemplateTagsProvider);
      
      // Force refresh dei provider che potrebbero essere cached
      try {
        final _ = await ref.refresh(allWorkoutTemplatesProvider.future);
        print('✅ PROVIDER: Successfully refreshed allWorkoutTemplatesProvider');
      } catch (e) {
        print('⚠️  PROVIDER: Error refreshing allWorkoutTemplatesProvider: $e');
      }
      
      try {
        final _ = await ref.refresh(customWorkoutTemplatesProvider.future);
        print('✅ PROVIDER: Successfully refreshed customWorkoutTemplatesProvider');
      } catch (e) {
        print('⚠️  PROVIDER: Error refreshing customWorkoutTemplatesProvider: $e');
      }
      
      print('✅ PROVIDER: Template save and invalidation completed');
    } catch (e) {
      print('❌ PROVIDER: Error saving template: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Elimina un template
  Future<void> deleteTemplate(String templateId) async {
    try {
      print('🗑️ PROVIDER: Deleting template with ID: $templateId');
      
      final repository = ref.read(workoutTemplateRepositoryProvider);
      await repository.deleteTemplate(templateId);
      
      // Rimuovi dalla lista locale
      final updatedTemplates = state.templates
          .where((template) => template.id != templateId)
          .toList();
      
      state = state.copyWith(templates: updatedTemplates);
      
      print('🗑️ PROVIDER: Template deleted, invalidating providers...');
      
      // Invalida TUTTI i provider cache - Enhanced invalidation
      ref.invalidate(allWorkoutTemplatesProvider);
      ref.invalidate(customWorkoutTemplatesProvider);
      ref.invalidate(popularTemplatesProvider);
      ref.invalidate(templateSearchResultsProvider);
      ref.invalidate(filteredTemplatesProvider);
      ref.invalidate(availableTemplateTagsProvider);
      
      print('✅ PROVIDER: Template deletion completed');
    } catch (e) {
      print('❌ PROVIDER: Error deleting template: $e');
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
      print('🆕 PROVIDER: Creating template from workout: "$name"');
      print('   - Source exercises: ${exercises.length}');
      
      final repository = ref.read(workoutTemplateRepositoryProvider);
      final template = await repository.createTemplateFromWorkout(
        name: name,
        description: description,
        exercises: exercises,
        tags: tags,
        imageUrl: imageUrl,
      );
      
      print('🆕 PROVIDER: Template created with ${template.exercises.length} exercises');
      
      // Ricarica i template
      await loadTemplates();
      
      // Invalida TUTTI i provider cache - Enhanced invalidation
      ref.invalidate(allWorkoutTemplatesProvider);
      ref.invalidate(customWorkoutTemplatesProvider);
      ref.invalidate(popularTemplatesProvider);
      ref.invalidate(templateSearchResultsProvider);
      ref.invalidate(filteredTemplatesProvider);
      ref.invalidate(availableTemplateTagsProvider);
      
      print('✅ PROVIDER: Template creation completed');
      return template;
    } catch (e) {
      print('❌ PROVIDER: Error creating template from workout: $e');
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
      print('Errore nell\'incremento utilizzo: $e');
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