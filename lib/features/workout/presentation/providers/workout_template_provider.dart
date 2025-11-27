import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_stats.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/firebase_workout_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_history_provider.dart';

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
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final allWorkoutTemplatesProvider = FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
  if (kDebugMode || kProfileMode) {
    debugPrint('🔍 [ALL_TEMPLATES] Provider called');
  }

  final repository = ref.watch(workoutTemplateRepositoryProvider);

  if (kDebugMode || kProfileMode) {
    debugPrint('🔍 [ALL_TEMPLATES] Repository type: ${repository.runtimeType}');
  }

  final templates = await repository.getAllTemplates();

  if (kDebugMode || kProfileMode) {
    debugPrint('🔍 [ALL_TEMPLATES] Got ${templates.length} templates from repository');
    for (final template in templates) {
      debugPrint('  - ${template.name} (${template.id})');
    }
  }

  return templates;
});

// Solo template personalizzati
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final customWorkoutTemplatesProvider = FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
  debugPrint('🔍 customWorkoutTemplatesProvider: START');

  // 1. Prendi i template dal repository legacy (esistenti)
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  debugPrint('🔍 customWorkoutTemplatesProvider: Repository type: ${repository.runtimeType}');

  final legacyTemplates = await repository.getCustomTemplates();
  debugPrint('🔍 customWorkoutTemplatesProvider: Got ${legacyTemplates.length} legacy templates');

  for (final template in legacyTemplates) {
    debugPrint('  - ${template.name}: isCustom=${template.isCustom}, id=${template.id}');
  }

  debugPrint('🔍 customWorkoutTemplatesProvider: Returning ${legacyTemplates.length} templates');
  return legacyTemplates;
});

// Template più utilizzati (per quick start)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final popularTemplatesProvider = FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
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

/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final templateSearchResultsProvider = FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  final query = ref.watch(templateSearchQueryProvider);
  
  if (query.isEmpty) {
    return repository.getAllTemplates();
  }
  
  return repository.searchTemplates(query);
});

// Provider per filtri tag
final templateTagFilterProvider = StateProvider<List<String>>((ref) => []);

/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final filteredTemplatesProvider = FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  final selectedTags = ref.watch(templateTagFilterProvider);
  
  if (selectedTags.isEmpty) {
    return repository.getAllTemplates();
  }
  
  return repository.getTemplatesByTags(selectedTags);
});

// Notifier per gestione template
final workoutTemplateNotifierProvider = NotifierProvider<WorkoutTemplateNotifier, WorkoutTemplateState>(WorkoutTemplateNotifier.new);

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

class WorkoutTemplateNotifier extends Notifier<WorkoutTemplateState> {
  @override
  WorkoutTemplateState build() {
    loadTemplates();
    return const WorkoutTemplateState();
  }

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

      // Delete from legacy repository
      final repository = ref.read(workoutTemplateRepositoryProvider);
      await repository.deleteTemplate(templateId);
      if (kDebugMode) {
        debugPrint('🗑️ PROVIDER: Deleted from legacy repository');
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

      // Force refresh key providers
      await Future.wait([
        ref.refresh(customWorkoutTemplatesProvider.future),
      ]).catchError((e) {
        if (kDebugMode) {
          debugPrint('⚠️ PROVIDER: Error refreshing providers after delete: $e');
        }
        return [<WorkoutTemplate>[]];
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
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final availableTemplateTagsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
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
/// FIX: Use customWorkoutTemplatesProvider to include templates from unified repository
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final templateByIdProvider = FutureProvider.autoDispose.family<WorkoutTemplate?, String>((ref, templateId) async {
  // Use customWorkoutTemplatesProvider which includes both legacy and unified repository templates
  final templates = await ref.watch(customWorkoutTemplatesProvider.future);

  try {
    return templates.firstWhere((template) => template.id == templateId);
  } catch (e) {
    debugPrint('⚠️ Template with ID $templateId not found in ${templates.length} available templates');
    if (kDebugMode) {
      debugPrint('   Available template IDs: ${templates.map((t) => t.id).take(5).join(", ")}${templates.length > 5 ? "..." : ""}');
    }
    return null;
  }
});

/// Provider for template statistics (average duration, last performed, completions)
///
/// Calculates real statistics based on completed workouts that used this template.
/// Returns TemplateStats with:
/// - avgDuration: Average duration of completed workouts
/// - lastPerformed: Date of most recent workout with this template
/// - totalCompletions: Number of times this template was used
///
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final templateStatsProvider = FutureProvider.autoDispose.family<TemplateStats, String>((ref, templateId) async {
  // Get all workouts from history
  final workoutsAsync = ref.watch(workoutHistoryProvider);

  return workoutsAsync.when(
    data: (workouts) {
      // Filter completed workouts that used this template
      final templateWorkouts = workouts.where((workout) =>
        workout.templateId == templateId &&
        workout.status == WorkoutStatus.completed &&
        workout.duration != null
      ).toList();

      if (templateWorkouts.isEmpty) {
        return TemplateStats.empty();
      }

      // Sort by date (newest first) to get lastPerformed
      templateWorkouts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final lastPerformed = templateWorkouts.first.startTime ?? templateWorkouts.first.createdAt;

      // Calculate average duration
      final totalMinutes = templateWorkouts
          .map((w) => w.duration!.inMinutes)
          .fold<int>(0, (sum, minutes) => sum + minutes);
      final avgMinutes = totalMinutes ~/ templateWorkouts.length;

      if (kDebugMode) {
        debugPrint('📊 [templateStatsProvider] Template $templateId: '
            '${templateWorkouts.length} completions, '
            'avg ${avgMinutes}min, '
            'last ${lastPerformed.toIso8601String()}');
      }

      return TemplateStats(
        lastPerformed: lastPerformed,
        totalCompletions: templateWorkouts.length,
        avgDuration: Duration(minutes: avgMinutes),
      );
    },
    loading: () => TemplateStats.empty(),
    error: (_, __) => TemplateStats.empty(),
  );
});

/// Provider for all template stats at once (batch loading for list view)
///
/// More efficient than calling templateStatsProvider for each template
/// when displaying a list of templates.
final allTemplateStatsProvider = FutureProvider.autoDispose<Map<String, TemplateStats>>((ref) async {
  // Get all workouts from history
  final workoutsAsync = ref.watch(workoutHistoryProvider);

  return workoutsAsync.when(
    data: (workouts) {
      final statsMap = <String, TemplateStats>{};

      // Group completed workouts by templateId
      final workoutsByTemplate = <String, List<_WorkoutData>>{};

      for (final workout in workouts) {
        if (workout.templateId != null &&
            workout.status == WorkoutStatus.completed &&
            workout.duration != null) {
          workoutsByTemplate
              .putIfAbsent(workout.templateId!, () => [])
              .add(_WorkoutData(
                startTime: workout.startTime ?? workout.createdAt,
                durationMinutes: workout.duration!.inMinutes,
              ));
        }
      }

      // Calculate stats for each template
      for (final entry in workoutsByTemplate.entries) {
        final templateId = entry.key;
        final templateWorkouts = entry.value;

        // Sort by date (newest first)
        templateWorkouts.sort((a, b) => b.startTime.compareTo(a.startTime));

        // Calculate average duration
        final totalMinutes = templateWorkouts
            .map((w) => w.durationMinutes)
            .fold<int>(0, (sum, minutes) => sum + minutes);
        final avgMinutes = totalMinutes ~/ templateWorkouts.length;

        statsMap[templateId] = TemplateStats(
          lastPerformed: templateWorkouts.first.startTime,
          totalCompletions: templateWorkouts.length,
          avgDuration: Duration(minutes: avgMinutes),
        );
      }

      if (kDebugMode) {
        debugPrint('📊 [allTemplateStatsProvider] Calculated stats for ${statsMap.length} templates');
      }

      return statsMap;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Helper class for workout data aggregation
class _WorkoutData {
  const _WorkoutData({
    required this.startTime,
    required this.durationMinutes,
  });

  final DateTime startTime;
  final int durationMinutes;
}